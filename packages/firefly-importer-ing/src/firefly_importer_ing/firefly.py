"""Talking to Firefly III and its data importer.

The messages of the errors and of `autoupload` are shown to the user and
therefore German.

Sign-in uses the OAuth authorization code flow with PKCE, like the data
importer does: each user creates a (not confidential) OAuth client in
Firefly III whose callback is this service's `/oauth/callback`. The
resulting access token authorizes both the Firefly III API calls and the
upload to the importer's `/autoupload`.
"""

from __future__ import annotations

import base64
import hashlib
import re
import secrets
from dataclasses import dataclass
from datetime import UTC, date, datetime, timedelta
from http.cookiejar import DefaultCookiePolicy
from urllib.parse import urlencode

import requests

from .converter import normalize_iban

API_HEADERS = {"Accept": "application/vnd.api+json"}
TIMEOUT = 30
# The importer converts and imports while the request waits
UPLOAD_TIMEOUT = 900
UPLOAD_UNANSWERED = (
    "Der Importer hat nicht rechtzeitig geantwortet und importiert"
    " möglicherweise noch. In ein paar Minuten erneut prüfen."
)


class FireflyError(Exception):
    """Firefly III did not do what was asked."""


class AuthError(FireflyError):
    """The token was refused: the user has to sign in again."""


class Unavailable(FireflyError):
    """Firefly III could not be reached or answered with an error."""


def new_session() -> requests.Session:
    """The session for all outgoing calls. It is shared by every user and
    thread, so it reuses connections but keeps no cookies: a session cookie
    of Firefly III or the importer must not carry over to the next user."""
    http = requests.Session()
    http.headers["User-Agent"] = "firefly-importer-ing"
    http.cookies.set_policy(DefaultCookiePolicy(allowed_domains=[]))
    return http


def _send(
    http: requests.Session,
    method: str,
    url: str,
    *,
    refused: tuple[int, ...] = (401,),
    **kwargs,
) -> requests.Response:
    """The answer of Firefly III. A status in `refused` means the token or
    grant was not accepted."""
    try:
        response = http.request(method, url, timeout=TIMEOUT, **kwargs)
    except requests.RequestException as exc:
        raise Unavailable(f"keine Antwort ({exc})") from exc
    if response.status_code in refused:
        raise AuthError(_error_text(response))
    if not response.ok:
        raise Unavailable(_error_text(response))
    return response


# ---------------------------------------------------------------------------
# OAuth
# ---------------------------------------------------------------------------


def pkce_pair() -> tuple[str, str]:
    """(verifier, S256 challenge)"""
    verifier = secrets.token_urlsafe(64)
    digest = hashlib.sha256(verifier.encode()).digest()
    challenge = base64.urlsafe_b64encode(digest).rstrip(b"=").decode()
    return verifier, challenge


def authorize_url(
    vanity_url: str,
    client_id: str,
    redirect_uri: str,
    state: str,
    challenge: str,
) -> str:
    query = urlencode(
        {
            "client_id": client_id,
            "redirect_uri": redirect_uri,
            "response_type": "code",
            "scope": "",
            "state": state,
            "code_challenge": challenge,
            "code_challenge_method": "S256",
        }
    )
    return f"{vanity_url.rstrip('/')}/oauth/authorize?{query}"


@dataclass
class Tokens:
    access_token: str
    refresh_token: str | None
    expires_at: datetime | None


def _request_tokens(
    http: requests.Session, firefly_url: str, grant: dict
) -> Tokens:
    data = _send(
        http,
        "POST",
        f"{firefly_url.rstrip('/')}/oauth/token",
        refused=(400, 401),
        data=grant,
        headers={"Accept": "application/json"},
    ).json()
    expires_in = data.get("expires_in")
    expires_at = (
        datetime.now(UTC) + timedelta(seconds=int(expires_in))
        if expires_in
        else None
    )
    return Tokens(data["access_token"], data.get("refresh_token"), expires_at)


def exchange_code(
    http: requests.Session,
    firefly_url: str,
    client_id: str,
    redirect_uri: str,
    code: str,
    verifier: str,
) -> Tokens:
    return _request_tokens(
        http,
        firefly_url,
        {
            "grant_type": "authorization_code",
            "client_id": client_id,
            "redirect_uri": redirect_uri,
            "code_verifier": verifier,
            "code": code,
        },
    )


def refresh(
    http: requests.Session,
    firefly_url: str,
    client_id: str,
    refresh_token: str,
) -> Tokens:
    tokens = _request_tokens(
        http,
        firefly_url,
        {
            "grant_type": "refresh_token",
            "client_id": client_id,
            "refresh_token": refresh_token,
            "scope": "",
        },
    )
    tokens.refresh_token = tokens.refresh_token or refresh_token
    return tokens


# ---------------------------------------------------------------------------
# API
# ---------------------------------------------------------------------------


def _error_text(response: requests.Response) -> str:
    try:
        data = response.json()
    except ValueError:
        text = re.sub(r"<[^>]+>", " ", response.text)
        text = re.sub(r"\s+", " ", text).strip()
        return f"HTTP {response.status_code}: {text[:300]}"
    for key in ("error", "message", "hint", "error_description"):
        if isinstance(data, dict) and data.get(key):
            return f"HTTP {response.status_code}: {data[key]}"
    return f"HTTP {response.status_code}"


class FireflyAPI:
    def __init__(
        self, http: requests.Session, base_url: str, token: str
    ) -> None:
        self.http = http
        self.base_url = base_url.rstrip("/")
        self.headers = {**API_HEADERS, "Authorization": f"Bearer {token}"}

    def _get(self, path: str, params: dict | None = None) -> dict:
        return _send(
            self.http,
            "GET",
            f"{self.base_url}/api/v1/{path}",
            params=params,
            headers=self.headers,
        ).json()

    def _pages(self, path: str, params: dict | None = None):
        page = 1
        while True:
            data = self._get(path, {**(params or {}), "page": page})
            yield from data.get("data", [])
            pagination = data.get("meta", {}).get("pagination", {})
            if page >= int(pagination.get("total_pages", 1) or 1):
                return
            page += 1

    def about_user(self) -> dict:
        """{"id": ..., "email": ...} of the token's user."""
        data = self._get("about/user")["data"]
        return {"id": str(data["id"]), "email": data["attributes"]["email"]}

    def asset_accounts(self) -> list[dict]:
        accounts = []
        for item in self._pages("accounts", {"type": "asset", "limit": 100}):
            attributes = item["attributes"]
            accounts.append(
                {
                    "id": int(item["id"]),
                    "name": attributes.get("name", ""),
                    # the same normalisation as the export's IBAN, so the
                    # two can be compared
                    "iban": normalize_iban(attributes.get("iban") or ""),
                    "active": attributes.get("active", True),
                }
            )
        return accounts

    def account_transactions(
        self, account_id: int, start: date, stop: date
    ) -> list[dict]:
        """The splits booked on an account in a date range."""
        splits = []
        for item in self._pages(
            f"accounts/{account_id}/transactions",
            {
                "start": start.isoformat(),
                "end": stop.isoformat(),
                "limit": 500,
            },
        ):
            for split in item["attributes"].get("transactions", []):
                splits.append(
                    {
                        "group_id": item["id"],
                        "date": (split.get("date") or "")[:10],
                        "amount": split.get("amount"),
                        "type": split.get("type"),
                        "description": split.get("description", ""),
                        "source_name": split.get("source_name", ""),
                        "destination_name": split.get("destination_name", ""),
                        "internal_reference": split.get("internal_reference"),
                    }
                )
        return splits


# ---------------------------------------------------------------------------
# Data importer
# ---------------------------------------------------------------------------


def autoupload(
    http: requests.Session,
    importer_url: str,
    secret: str,
    token: str,
    csv_data: bytes,
    config_data: bytes,
) -> tuple[bool, str]:
    """Upload a CSV and its config to the importer's `/autoupload`, which
    converts and imports while the request waits. (ok, message)

    `ok` only means the importer has the file: it answers 200 with a fixed
    text even when single bookings fail (they only show up in its log), and
    when it doesn't answer in time it may still be importing. Whether the
    bookings arrived has to be checked in Firefly III. Not `ok` means that
    nothing was imported and the upload can be repeated."""
    try:
        response = http.post(
            f"{importer_url.rstrip('/')}/autoupload",
            data={"secret": secret},
            files={
                "importable": ("import.csv", csv_data, "text/csv"),
                "json": ("config.json", config_data, "application/json"),
            },
            headers={
                "Authorization": f"Bearer {token}",
                "Accept": "application/json",
            },
            timeout=UPLOAD_TIMEOUT,
        )
    except requests.ReadTimeout:
        return True, UPLOAD_UNANSWERED
    except requests.RequestException as exc:
        return False, f"Der Importer war nicht erreichbar: {exc}"
    if response.ok:
        return True, "Der Importer hat die Datei angenommen."
    if response.status_code == requests.codes.gateway_timeout:
        return True, UPLOAD_UNANSWERED
    return False, _error_text(response)
