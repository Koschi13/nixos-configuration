"""A fake Firefly III plus data importer for the web tests, and a requests
adapter that routes the app's outgoing calls to it without a network."""

from __future__ import annotations

import base64
import csv
import hashlib
import io
import json
import secrets
from urllib.parse import urlsplit

import requests
from flask import Flask, jsonify, request
from requests.structures import CaseInsensitiveDict

FIREFLY = "http://firefly.test"
IMPORTER = "http://importer.test"
ACCOUNT = {"id": 3, "name": "ING Girokonto", "iban": "DE00123456789012345678"}


class FakeFirefly:
    def __init__(self, client_id: str = "7", secret: str = "s" * 20):
        self.client_id = client_id
        self.secret = secret
        self.codes: dict[str, dict] = {}
        self.tokens: dict[str, dict] = {}  # access token -> user
        self.refresh_tokens: dict[str, dict] = {}
        self.users = {
            "1": {"id": "1", "email": "erika@example.org"},
            "2": {"id": "2", "email": "max@example.org"},
        }
        self.transactions: list[dict] = []
        self.uploads: list[dict] = []
        self.drop_first_upload_row = False
        self.importer_fails = False
        self.refresh_count = 0
        self.firefly = self._firefly_app()
        self.importer = self._importer_app()

    # The browser part of the OAuth flow: Firefly III asks the user, then
    # redirects back with a code
    def authorize(self, query: dict, user_id: str = "1") -> str:
        assert query["client_id"] == self.client_id
        assert query["code_challenge_method"] == "S256"
        code = secrets.token_hex(8)
        self.codes[code] = {
            "challenge": query["code_challenge"],
            "redirect_uri": query["redirect_uri"],
            "user": self.users[user_id],
        }
        return code

    def _issue(self, user: dict) -> dict:
        access, refresh = secrets.token_hex(8), secrets.token_hex(8)
        self.tokens[access] = user
        self.refresh_tokens[refresh] = user
        return {
            "token_type": "Bearer",
            "expires_in": 3600,
            "access_token": access,
            "refresh_token": refresh,
        }

    def _user(self) -> dict | None:
        auth = request.headers.get("Authorization", "")
        return self.tokens.get(auth.removeprefix("Bearer "))

    def _firefly_app(self) -> Flask:
        app = Flask("fake-firefly")

        @app.post("/oauth/token")
        def token():
            form = request.form
            if form["client_id"] != self.client_id:
                return jsonify(error="invalid_client"), 401
            if form["grant_type"] == "refresh_token":
                self.refresh_count += 1
                # like Passport: a refresh token works only once
                user = self.refresh_tokens.pop(form["refresh_token"], None)
                if not user:
                    return jsonify(error="invalid_grant"), 400
                return jsonify(self._issue(user))
            pending = self.codes.pop(form["code"], None)
            if not pending or pending["redirect_uri"] != form["redirect_uri"]:
                return jsonify(error="invalid_grant"), 400
            digest = hashlib.sha256(form["code_verifier"].encode()).digest()
            challenge = base64.urlsafe_b64encode(digest).rstrip(b"=").decode()
            if challenge != pending["challenge"]:
                return jsonify(error="invalid_grant"), 400
            return jsonify(self._issue(pending["user"]))

        @app.get("/api/v1/about/user")
        def about_user():
            user = self._user()
            if not user:
                return jsonify(message="Unauthenticated."), 401
            return jsonify(
                data={"id": user["id"], "attributes": {"email": user["email"]}}
            )

        @app.get("/api/v1/accounts")
        def accounts():
            if not self._user():
                return jsonify(message="Unauthenticated."), 401
            return jsonify(
                data=[
                    {
                        "id": str(ACCOUNT["id"]),
                        "attributes": {
                            "name": ACCOUNT["name"],
                            "iban": "DE00 1234 5678 9012 3456 78",
                            "active": True,
                        },
                    }
                ],
                meta={"pagination": {"current_page": 1, "total_pages": 1}},
            )

        @app.get("/api/v1/accounts/<int:account_id>/transactions")
        def account_transactions(account_id):
            if not self._user():
                return jsonify(message="Unauthenticated."), 401
            start, end = request.args["start"], request.args["end"]
            data = [
                {"id": str(number), "attributes": {"transactions": [split]}}
                for number, split in enumerate(self.transactions, start=1)
                if split["account_id"] == account_id
                and start <= split["date"][:10] <= end
            ]
            return jsonify(
                data=data,
                meta={"pagination": {"current_page": 1, "total_pages": 1}},
            )

        return app

    def _importer_app(self) -> Flask:
        app = Flask("fake-importer")

        @app.post("/autoupload")
        def autoupload():
            if request.form.get("secret") != self.secret:
                return jsonify(error="wrong secret"), 400
            if not self._user():
                return jsonify(error="Could not connect to Firefly III"), 400
            if self.importer_fails:
                return jsonify(
                    error="Too many errors in the data conversion."
                ), 400
            config = json.loads(request.files["json"].read())
            rows = list(
                csv.DictReader(
                    io.StringIO(request.files["importable"].read().decode())
                )
            )
            self.uploads.append({"config": config, "rows": rows})
            for row in rows[1:] if self.drop_first_upload_row else rows:
                amount = row["amount"]
                self.transactions.append(
                    {
                        "account_id": config["default_account"],
                        "date": row["date"] + "T00:00:00+01:00",
                        "amount": amount.lstrip("-"),
                        "type": "withdrawal"
                        if amount.startswith("-")
                        else "deposit",
                        "description": row["description"],
                        "source_name": "ING Girokonto",
                        "destination_name": row["opposing_name"],
                        "internal_reference": row["internal_reference"],
                    }
                )
            return jsonify(
                message="Translate the import result to a JSON thing."
            )

        return app


class FlaskAdapter(requests.adapters.BaseAdapter):
    """Serve requests to the fake hosts with Flask test clients."""

    def __init__(self, apps: dict[str, Flask]):
        super().__init__()
        self.clients = {
            urlsplit(base).netloc: app.test_client()
            for base, app in apps.items()
        }

    def send(self, request, **kwargs):
        url = urlsplit(request.url)
        client = self.clients[url.netloc]
        body = request.body
        if isinstance(body, str):
            body = body.encode()
        result = client.open(
            url.path,
            method=request.method,
            query_string=url.query,
            headers=dict(request.headers),
            data=body or b"",
        )
        response = requests.Response()
        response.status_code = result.status_code
        response._content = result.data
        response.headers = CaseInsensitiveDict(result.headers)
        response.url = request.url
        response.request = request
        return response

    def close(self):
        pass


def session_for(fake: FakeFirefly) -> requests.Session:
    http = requests.Session()
    adapter = FlaskAdapter({FIREFLY: fake.firefly, IMPORTER: fake.importer})
    http.mount(FIREFLY, adapter)
    http.mount(IMPORTER, adapter)
    return http
