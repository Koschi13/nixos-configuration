"""The web app: sign in with Firefly III, upload an ING export, preview the
conversion, send it to the data importer and check what arrived.

Only what a user configures is stored (see `models`). An upload stays in
the memory of this process (see `uploads`), so the app has to run in a
single worker process.

Configuration, from the environment:

    DATABASE_URL        SQLAlchemy URL, e.g. postgresql+psycopg:///
                        firefly-importer-ing?host=/run/postgresql. Its
                        schema is migrated by `firefly-importer-ing-migrate`
    FIREFLY_URL         where this service calls Firefly III (API, tokens)
    FIREFLY_VANITY_URL  where the browser reaches Firefly III (default:
                        FIREFLY_URL)
    IMPORTER_URL        where this service calls the data importer
    PUBLIC_URL          where the browser reaches this service, for the OAuth
                        callback
    SECRET_KEY          at least 32 characters; encrypts the stored secrets
    AUTO_IMPORT_SECRET  the importer's AUTO_IMPORT_SECRET

The two secrets can also come from a file (`SECRET_KEY_FILE`, ...) or from
systemd credentials named `secret-key` and `auto-import-secret`.
"""

from __future__ import annotations

import functools
import json
import os
import re
import secrets
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal, InvalidOperation
from pathlib import Path
from urllib.parse import urlsplit

import requests
from flask import (
    Flask,
    Response,
    abort,
    current_app,
    flash,
    g,
    redirect,
    render_template,
    request,
    session,
    url_for,
)
from flask_wtf.csrf import CSRFError, CSRFProtect
from itsdangerous import BadSignature, URLSafeSerializer
from sqlalchemy.orm import sessionmaker

from . import converter, db, firefly, uploads
from .crypto import Vault
from .models import User
from .uploads import Check, Upload, UploadStore

# The user interface is German only: the texts in the templates and the
# messages shown to the user are written in German, everything else in
# English.

PROCESSOR_KINDS = {
    "visa_prefix": "VISA-Händlerpräfix",
    "girocard_payee": "Girocard-Empfänger",
}
RULE_FIELDS = {"payee": "Empfänger", "description": "Beschreibung"}
RULE_MATCHES = {"regex": "Regex", "contains": "Enthält", "exact": "Exakt"}

# The sign-in page offers only the profiles that signed in on this browser,
# remembered in a signed cookie, so it doesn't list everyone's email address
PROFILES_COOKIE = "profiles"
PROFILES_LIFETIME = timedelta(days=400)
PROFILES_LIMIT = 10

ACCOUNT_NEEDED = "Zuerst das Firefly-III-Konto wählen."


def _secret(name: str, credential: str) -> str:
    if value := os.environ.get(name):
        return value.strip()
    if path := os.environ.get(f"{name}_FILE"):
        return Path(path).read_text().strip()
    if directory := os.environ.get("CREDENTIALS_DIRECTORY"):
        path = Path(directory) / credential
        if path.exists():
            return path.read_text().strip()
    raise RuntimeError(f"{name} is not set")


def create_app(config: dict | None = None) -> Flask:
    app = Flask(__name__)
    app.config.update(
        DATABASE_URL=os.environ.get("DATABASE_URL", ""),
        FIREFLY_URL=os.environ.get("FIREFLY_URL", "http://localhost"),
        FIREFLY_VANITY_URL=os.environ.get("FIREFLY_VANITY_URL", ""),
        IMPORTER_URL=os.environ.get("IMPORTER_URL", "http://localhost"),
        PUBLIC_URL=os.environ.get("PUBLIC_URL", ""),
        MAX_CONTENT_LENGTH=20 * 1024 * 1024,
        SESSION_COOKIE_HTTPONLY=True,
        SESSION_COOKIE_SAMESITE="Lax",
        PERMANENT_SESSION_LIFETIME=timedelta(days=30),
        # A form stays valid as long as the session: a preview may be left
        # open for hours before it is sent
        WTF_CSRF_TIME_LIMIT=None,
    )
    if config:
        app.config.update(config)
    if "SECRET_KEY_RAW" not in app.config:
        app.config["SECRET_KEY_RAW"] = _secret("SECRET_KEY", "secret-key")
    if "AUTO_IMPORT_SECRET" not in app.config:
        app.config["AUTO_IMPORT_SECRET"] = _secret(
            "AUTO_IMPORT_SECRET", "auto-import-secret"
        )
    app.config["FIREFLY_VANITY_URL"] = (
        app.config["FIREFLY_VANITY_URL"] or app.config["FIREFLY_URL"]
    )

    vault = Vault(app.config["SECRET_KEY_RAW"])
    app.secret_key = vault.session_key
    app.extensions["vault"] = vault
    app.extensions["http"] = (
        app.config.get("HTTP_SESSION") or firefly.new_session()
    )
    app.extensions["uploads"] = UploadStore()
    CSRFProtect(app)

    engine = db.create_engine(app.config["DATABASE_URL"])
    app.extensions["engine"] = engine
    sessions = sessionmaker(engine)

    app.jinja_env.filters["money"] = _money
    app.jinja_env.filters["de_date"] = _de_date
    app.jinja_env.globals["PROCESSOR_KINDS"] = PROCESSOR_KINDS
    app.jinja_env.globals["RULE_FIELDS"] = RULE_FIELDS
    app.jinja_env.globals["RULE_MATCHES"] = RULE_MATCHES
    app.jinja_env.globals["NAME_SETTINGS"] = converter.NAME_SETTINGS

    @app.before_request
    def _open_db():
        if request.endpoint == "static":
            return
        g.db = sessions()
        g.user = None
        if user_id := session.get("user_id"):
            g.user = db.get_user(g.db, user_id)
            if g.user is None:
                session.clear()

    @app.teardown_request
    def _close_db(exc):
        database = g.pop("db", None)
        if database is not None:
            if exc is None:
                database.commit()
            else:
                database.rollback()
            database.close()

    @app.errorhandler(firefly.AuthError)
    def _auth_error(exc):
        session.pop("user_id", None)
        flash(
            f"Firefly III hat das Token abgelehnt ({exc}). Bitte neu"
            " anmelden.",
            "error",
        )
        return redirect(url_for("login"))

    @app.errorhandler(CSRFError)
    def _csrf_error(exc):
        flash(
            "Die Seite war nicht mehr gültig. Bitte noch einmal versuchen.",
            "error",
        )
        return redirect(url_for("index"))

    @app.errorhandler(converter.ConversionError)
    def _conversion_error(exc):
        flash(f"Diese Datei lässt sich nicht lesen: {exc}", "error")
        return redirect(url_for("index"))

    _register_auth(app)
    _register_import(app)
    _register_settings(app)
    return app


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _money(value) -> str:
    try:
        amount = Decimal(str(value))
    except (InvalidOperation, ValueError):
        return str(value)
    text = f"{abs(amount):,.2f}".replace(",", "_").replace(".", ",")
    return ("−" if amount < 0 else "") + text.replace("_", ".")


def _de_date(value) -> str:
    if not value:
        return ""
    if isinstance(value, str):
        value = date.fromisoformat(value[:10])
    return f"{value:%d.%m.%Y}"


def _vault() -> Vault:
    return current_app.extensions["vault"]


def _http() -> requests.Session:
    return current_app.extensions["http"]


def _config(key: str):
    return current_app.config[key]


def _redirect_uri() -> str:
    public = _config("PUBLIC_URL")
    if public:
        return f"{public.rstrip('/')}/oauth/callback"
    return url_for("oauth_callback", _external=True)


def login_required(view):
    @functools.wraps(view)
    def wrapper(*args, **kwargs):
        if g.user is None:
            # Only a page can be returned to after the sign-in, not a form
            back = request.full_path if request.method == "GET" else None
            return redirect(url_for("login", next=back))
        return view(*args, **kwargs)

    return wrapper


def _safe_next(target: str | None) -> str:
    """`target` if it is a path on this site, else "": a sign-in must not
    end on another site (`//evil.example`, `/\\evil.example`, ...)."""
    if not target or not target.startswith("/") or target.startswith("//"):
        return ""
    # Browsers read a backslash as "/" and drop tabs and newlines
    if "\\" in target or any(ord(character) < 0x20 for character in target):
        return ""
    parts = urlsplit(target)
    if parts.scheme or parts.netloc:
        return ""
    return target


def _known_profile_ids() -> list[int]:
    """The profiles that signed in on this browser, latest first."""
    serializer = URLSafeSerializer(current_app.secret_key, salt="profiles")
    try:
        ids = serializer.loads(request.cookies.get(PROFILES_COOKIE, ""))
    except BadSignature:
        return []
    if not isinstance(ids, list):
        return []
    return [user_id for user_id in ids if isinstance(user_id, int)]


def _remember_profiles(response: Response, ids: list[int]) -> Response:
    serializer = URLSafeSerializer(current_app.secret_key, salt="profiles")
    response.set_cookie(
        PROFILES_COOKIE,
        serializer.dumps(ids[:PROFILES_LIMIT]),
        max_age=int(PROFILES_LIFETIME.total_seconds()),
        httponly=True,
        samesite="Lax",
    )
    return response


def _valid_access_token(user: User) -> str | None:
    token = _vault().decrypt(user.access_token_enc)
    expires = user.token_expires_at
    soon = datetime.now(UTC) + timedelta(minutes=5)
    if token and (expires is None or expires > soon):
        return token
    return None


def _access_token() -> str:
    """The user's access token, refreshed when it is about to expire.

    Firefly III revokes a refresh token when it is used, so two requests
    must not refresh at the same time: the second one would be refused and
    sign the user out. The user's row is locked while refreshing; whoever
    waited for the lock finds the new token and uses it.
    """
    if token := _valid_access_token(g.user):
        return token
    # The same object as `g.user`, reread under the lock
    user = db.get_user(g.db, g.user.id, lock=True)
    if user is None:
        raise firefly.AuthError("das Profil wurde gelöscht")
    if token := _valid_access_token(user):  # refreshed by another request
        g.db.commit()  # releases the lock
        return token
    vault = _vault()
    refresh_token = vault.decrypt(user.refresh_token_enc)
    client_id = vault.decrypt(user.client_id_enc)
    if not refresh_token or not client_id:
        raise firefly.AuthError("kein gültiges Token gespeichert")
    tokens = firefly.refresh(
        _http(), _config("FIREFLY_URL"), client_id, refresh_token
    )
    user.access_token_enc = vault.encrypt(tokens.access_token)
    user.refresh_token_enc = (
        vault.encrypt(tokens.refresh_token) if tokens.refresh_token else None
    )
    user.token_expires_at = tokens.expires_at
    g.db.commit()  # releases the lock
    return tokens.access_token


def _api() -> firefly.FireflyAPI:
    return firefly.FireflyAPI(_http(), _config("FIREFLY_URL"), _access_token())


def _asset_accounts() -> tuple[list[dict], str | None]:
    try:
        return _api().asset_accounts(), None
    except firefly.Unavailable as exc:
        return [], f"Die Konten ließen sich nicht aus Firefly III laden: {exc}"


def _posted_account() -> dict | None:
    """The asset account a form chose, looked up in Firefly III: only an
    account that exists is stored, under its current name. Without one the
    user is told why."""
    try:
        account_id = int(request.form["account_id"])
    except (KeyError, ValueError):
        abort(400)
    accounts, error = _asset_accounts()
    matches = [account for account in accounts if account["id"] == account_id]
    if matches:
        return matches[0]
    flash(
        error or "Firefly III hat kein Bestandskonto mit dieser ID.", "error"
    )
    return None


def _parse_tags(text: str) -> list[str]:
    return [
        tag.strip() for tag in re.split(r"[,;]", text or "") if tag.strip()
    ]


# ---------------------------------------------------------------------------
# Sign-in
# ---------------------------------------------------------------------------


def _register_auth(app: Flask) -> None:
    def start_oauth(client_id: str, next_url: str | None):
        verifier, challenge = firefly.pkce_pair()
        state = secrets.token_urlsafe(32)
        session["oauth"] = {
            "state": state,
            "verifier": verifier,
            "client_id": client_id,
            "next": _safe_next(next_url),
        }
        return redirect(
            firefly.authorize_url(
                _config("FIREFLY_VANITY_URL"),
                client_id,
                _redirect_uri(),
                state,
                challenge,
            )
        )

    @app.route("/login", methods=["GET", "POST"])
    def login():
        if request.method == "POST":
            client_id = request.form.get("client_id", "").strip()
            if not client_id:
                flash("Die ID deines OAuth-Clients eingeben.", "error")
                return redirect(url_for("login"))
            return start_oauth(client_id, request.args.get("next"))
        return render_template(
            "login.html",
            profiles=db.list_users(g.db, _known_profile_ids()),
            firefly_url=_config("FIREFLY_VANITY_URL"),
        )

    @app.post("/oauth/start/<int:user_id>")
    def oauth_start(user_id: int):
        if user_id not in _known_profile_ids():
            abort(404)
        user = db.get_user(g.db, user_id)
        client_id = _vault().decrypt(user.client_id_enc) if user else None
        if not client_id:
            flash(
                "Die gespeicherte Client-ID ist nicht mehr lesbar, bitte neu"
                " eingeben.",
                "error",
            )
            return redirect(url_for("login"))
        return start_oauth(client_id, request.args.get("next"))

    @app.get("/oauth/callback")
    def oauth_callback():
        pending = session.pop("oauth", None)
        if request.args.get("error"):
            flash(
                "Firefly III hat den Zugriff nicht gewährt: "
                + request.args.get("error_description", request.args["error"]),
                "error",
            )
            return redirect(url_for("login"))
        if not pending or request.args.get("state") != pending["state"]:
            flash(
                "Die Anmeldung ist abgelaufen oder wurde verändert, bitte"
                " noch einmal versuchen.",
                "error",
            )
            return redirect(url_for("login"))
        http = _http()
        try:
            tokens = firefly.exchange_code(
                http,
                _config("FIREFLY_URL"),
                pending["client_id"],
                _redirect_uri(),
                request.args.get("code", ""),
                pending["verifier"],
            )
            firefly_user = firefly.FireflyAPI(
                http, _config("FIREFLY_URL"), tokens.access_token
            ).about_user()
        except firefly.FireflyError as exc:
            flash(
                f"Die Anmeldung bei Firefly III ist fehlgeschlagen: {exc}",
                "error",
            )
            return redirect(url_for("login"))
        vault = _vault()
        user, created = db.upsert_user(
            g.db,
            firefly_user_id=firefly_user["id"],
            email=firefly_user["email"],
            client_id_enc=vault.encrypt(pending["client_id"]),
            access_token_enc=vault.encrypt(tokens.access_token),
            refresh_token_enc=(
                vault.encrypt(tokens.refresh_token)
                if tokens.refresh_token
                else None
            ),
            token_expires_at=tokens.expires_at,
        )
        user_id = user.id
        if created:
            db.seed_defaults(g.db, user_id)
        session.clear()
        session.permanent = True
        session["user_id"] = user_id
        flash(f"Angemeldet als {firefly_user['email']}.", "success")
        others = [known for known in _known_profile_ids() if known != user_id]
        return _remember_profiles(
            redirect(_safe_next(pending["next"]) or url_for("index")),
            [user_id, *others],
        )

    @app.post("/logout")
    def logout():
        if g.user:
            _uploads().discard(g.user.id)
        session.clear()
        return redirect(url_for("login"))

    @app.post("/login/forget/<int:user_id>")
    def forget_profile(user_id: int):
        """Remove a profile from this browser's sign-in page."""
        if session.get("user_id") == user_id:
            session.clear()
        remaining = [
            known for known in _known_profile_ids() if known != user_id
        ]
        return _remember_profiles(redirect(url_for("login")), remaining)


# ---------------------------------------------------------------------------
# Import
# ---------------------------------------------------------------------------


class NoUpload(Exception):
    """The user has no upload (anymore): it expired, was discarded or
    replaced, or the service restarted."""


def _uploads() -> UploadStore:
    return current_app.extensions["uploads"]


def _upload() -> Upload:
    """The upload the signed-in user is working on."""
    upload = _uploads().get(g.user.id)
    if upload is None:
        raise NoUpload
    return upload


def _to_import(**window):
    """Redirect to the page of the upload, optionally with a window."""
    return redirect(url_for("show_import", **window))


def _requested_window() -> dict:
    """The window of this request, to carry it over a redirect."""
    return {
        "start": request.values.get("start"),
        "stop": request.values.get("stop"),
    }


def _converted(upload: Upload) -> list[dict]:
    """The bookings of an upload, converted with the user's settings."""
    return converter.convert(upload.export, db.load_settings(g.db, g.user.id))


def _window(rows: list[dict]) -> tuple[date, date]:
    """The window from the request, else the whole file. Sending bookings
    again does no harm: the importer skips those it knows by their internal
    reference."""
    dates = converter.booking_dates(rows)
    start, stop = min(dates), max(dates)
    try:
        if request.values.get("start"):
            start = converter.parse_user_date(
                request.values["start"], end=False
            )
        if request.values.get("stop"):
            stop = converter.parse_user_date(request.values["stop"], end=True)
    except ValueError as exc:
        flash(str(exc), "error")
    return start, stop


def _selection(upload: Upload) -> tuple[list[dict], date, date]:
    """The bookings of an upload and their window: what was sent, or for a
    draft what the requested window selects."""
    if upload.state != uploads.DRAFT:
        return upload.rows, upload.start, upload.stop
    rows = _converted(upload)
    start, stop = _window(rows)
    return converter.filter_window(rows, start, stop), start, stop


def _attachment(
    upload: Upload, data: bytes | str, mimetype: str, extension: str
) -> Response:
    """A download named after the account and window of the upload."""
    _, start, stop = _selection(upload)
    iban = upload.export.iban[-4:] if upload.export.iban else "ing"
    name = f"firefly-{iban}-{start:%Y%m%d}-{stop:%Y%m%d}.{extension}"
    return Response(
        data,
        mimetype=mimetype,
        headers={"Content-Disposition": f"attachment; filename={name}"},
    )


def _account_of(iban: str) -> tuple[int | None, str]:
    """The Firefly III account (ID, name) for the exports of an IBAN: the
    one the user assigned, else the asset account with that IBAN."""
    if not iban:
        return None, ""
    assigned = db.get_bank_account(g.db, g.user.id, iban)
    if assigned:
        return assigned.firefly_account_id, assigned.name
    accounts, _ = _asset_accounts()
    for account in accounts:
        if account["iban"] == iban:
            return account["id"], account["name"]
    return None, ""


def _reconcile(upload: Upload) -> int:
    """Compare the sent rows with what Firefly III has in the window, keep
    the result with the upload and return how many bookings are missing.

    The importer's answer says nothing about single bookings, so this is
    the only reliable result.
    """
    splits = _api().account_transactions(
        upload.account_id, upload.start, upload.stop
    )
    in_firefly = {split["internal_reference"] for split in splits}
    sent = {row["internal_reference"] for row in upload.rows}
    upload.check = Check(
        missing=[
            row
            for row in upload.rows
            if row["internal_reference"] not in in_firefly
        ],
        others=[
            split
            for split in splits
            if split["internal_reference"] not in sent
        ],
        checked_at=datetime.now(UTC),
    )
    return len(upload.check.missing)


def _check(upload: Upload) -> None:
    """Reconcile a sent upload and tell the user the outcome."""
    try:
        missing = _reconcile(upload)
    except firefly.Unavailable as exc:
        flash(f"Firefly III ließ sich nicht prüfen: {exc}", "error")
        return
    sent = len(upload.rows)
    if missing:
        flash(
            f"{missing} von {sent} gesendeten Buchungen fehlen in Firefly"
            " III.",
            "error",
        )
    else:
        flash(
            f"Alle {sent} gesendeten Buchungen wurden in Firefly III"
            " gefunden.",
            "success",
        )


def _preview_page(upload: Upload) -> str:
    rows = _converted(upload)
    start, stop = _window(rows)
    accounts, accounts_error = ([], None)
    choose_account = (
        upload.account_id is None or "change_account" in request.args
    )
    if choose_account:
        accounts, accounts_error = _asset_accounts()
    dates = converter.booking_dates(rows)
    return render_template(
        "preview.html",
        upload=upload,
        metadata=upload.export.metadata,
        warnings=upload.export.warnings,
        months=converter.month_overview(dates),
        first=min(dates),
        last=max(dates),
        total=len(rows),
        rows=converter.filter_window(rows, start, stop),
        start=start,
        stop=stop,
        choose_account=choose_account,
        accounts=accounts,
        accounts_error=accounts_error,
    )


def _register_import(app: Flask) -> None:
    @app.errorhandler(NoUpload)
    def _no_upload(exc):
        flash(
            "Es ist keine Datei (mehr) hochgeladen. Hochgeladene Dateien"
            " werden nicht gespeichert und nach einer Stunde ohne Nutzung"
            " verworfen.",
            "error",
        )
        return redirect(url_for("index"))

    @app.route("/", methods=["GET", "POST"])
    @login_required
    def index():
        if request.method == "GET":
            return render_template(
                "upload.html", upload=_uploads().get(g.user.id)
            )
        file = request.files.get("file")
        if not file or not file.filename:
            flash("Die CSV-Datei des ING-Exports auswählen.", "error")
            return redirect(url_for("index"))
        upload = Upload(file.filename, converter.read_export(file.read()))
        if not _converted(upload):
            flash("Die Datei enthält keine Buchungen.", "error")
            return redirect(url_for("index"))
        upload.account_id, upload.account_name = _account_of(
            upload.export.iban
        )
        _uploads().put(g.user.id, upload)
        return _to_import()

    @app.get("/import")
    @login_required
    def show_import():
        upload = _upload()
        if upload.state == uploads.DRAFT:
            return _preview_page(upload)
        return render_template("result.html", upload=upload)

    @app.post("/import/account")
    @login_required
    def set_account():
        upload = _upload()
        if upload.state != uploads.DRAFT:
            return _to_import()
        account = _posted_account()
        if account is not None:
            upload.account_id = account["id"]
            upload.account_name = account["name"]
            if upload.export.iban and request.form.get("remember"):
                db.save_bank_account(
                    g.db,
                    g.user.id,
                    upload.export.iban,
                    account["id"],
                    account["name"],
                )
        return _to_import(**_requested_window())

    @app.get("/import/csv")
    @login_required
    def download_csv():
        upload = _upload()
        rows, _, _ = _selection(upload)
        return _attachment(upload, converter.to_csv(rows), "text/csv", "csv")

    @app.get("/import/json")
    @login_required
    def download_json():
        upload = _upload()
        if upload.account_id is None:
            # The configuration names the account the importer books on
            flash(ACCOUNT_NEEDED, "error")
            return _to_import(**_requested_window())
        config = converter.build_config(upload.account_id)
        return _attachment(
            upload,
            json.dumps(config, indent=4, ensure_ascii=False) + "\n",
            "application/json",
            "json",
        )

    @app.post("/import/send")
    @login_required
    def send_import():
        upload = _upload()
        if upload.state != uploads.DRAFT:
            return _to_import()
        if upload.account_id is None:
            flash(ACCOUNT_NEEDED, "error")
            return _to_import()
        rows, start, stop = _selection(upload)
        if start > stop:
            flash("Der Beginn liegt nach dem Ende.", "error")
            return _to_import()
        if not rows:
            flash("In diesem Zeitraum gibt es keine Buchungen.", "error")
            return _to_import(start=start, stop=stop)
        try:
            token = _access_token()
        except firefly.Unavailable as exc:
            flash(f"Firefly III war nicht erreichbar: {exc}", "error")
            return _to_import(start=start, stop=stop)
        if not upload.begin_send(rows, start, stop):
            return _to_import()  # another request sent it in the meantime
        # The upload can take minutes: no transaction stays open meanwhile
        g.db.commit()
        ok, message = firefly.autoupload(
            _http(),
            _config("IMPORTER_URL"),
            _config("AUTO_IMPORT_SECRET"),
            token,
            converter.to_csv(rows),
            json.dumps(converter.build_config(upload.account_id)).encode(),
        )
        upload.finish_send(ok, message)
        if not ok:
            flash(f"Der Import ist fehlgeschlagen: {message}", "error")
            return _to_import(start=start, stop=stop)
        # The importer's answer doesn't tell whether the bookings arrived:
        # check in Firefly III right away
        _check(upload)
        return _to_import()

    @app.post("/import/check")
    @login_required
    def check_import():
        """Ask Firefly III again what arrived of a sent upload."""
        upload = _upload()
        if upload.state != uploads.DRAFT:
            _check(upload)
        return _to_import()

    @app.post("/import/reset")
    @login_required
    def reset_import():
        """Back to the preview of a sent upload, to send another window."""
        upload = _upload()
        if upload.state == uploads.SENT:
            upload.reset()
        return _to_import()

    @app.post("/import/discard")
    @login_required
    def discard_import():
        _uploads().discard(g.user.id)
        flash("Die hochgeladene Datei wurde verworfen.", "success")
        return redirect(url_for("index"))


# ---------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------


def _rule_values(form) -> dict:
    values = {
        "match": form.get("match", "regex"),
        "field": form.get("field", "payee"),
        "pattern": form.get("pattern", "").strip(),
        "new_name": form.get("new_name", "").strip(),
        "category": form.get("category", "").strip(),
        "tags": _parse_tags(form.get("tags", "")),
        "enabled": bool(form.get("enabled")),
    }
    if not values["pattern"]:
        raise ValueError("Das Muster ist leer.")
    if not (values["new_name"] or values["category"] or values["tags"]):
        raise ValueError(
            "Einen neuen Namen, eine Kategorie oder Schlagwörter angeben."
        )
    # Validates match, field and the regex
    converter.Rule(
        pattern=values["pattern"],
        match=values["match"],
        field=values["field"],
    )
    return values


def _register_settings(app: Flask) -> None:
    @app.get("/settings")
    @login_required
    def settings():
        return redirect(url_for("settings_rules"))

    @app.get("/settings/rules")
    @login_required
    def settings_rules():
        rules = db.list_rules(g.db, g.user.id)
        test = None
        payee = request.args.get("test_payee", "")
        description = request.args.get("test_description", "")
        if payee or description:
            settings = db.load_settings(g.db, g.user.id)
            rule = settings.rule_for(payee, description)
            test = {"payee": payee, "description": description, "rule": rule}
        return render_template("settings/rules.html", rules=rules, test=test)

    @app.post("/settings/rules")
    @login_required
    def settings_rules_add():
        try:
            db.add_rule(g.db, g.user.id, _rule_values(request.form))
        except (ValueError, re.error) as exc:
            flash(f"Nicht gespeichert: {exc}", "error")
        else:
            flash("Regel hinzugefügt.", "success")
        return redirect(url_for("settings_rules"))

    @app.post("/settings/rules/<int:rule_id>")
    @login_required
    def settings_rules_update(rule_id: int):
        try:
            db.update_rule(
                g.db, g.user.id, rule_id, _rule_values(request.form)
            )
        except (ValueError, re.error) as exc:
            flash(f"Nicht gespeichert: {exc}", "error")
        else:
            flash("Regel gespeichert.", "success")
        return redirect(url_for("settings_rules") + f"#rule-{rule_id}")

    @app.post("/settings/rules/<int:rule_id>/move")
    @login_required
    def settings_rules_move(rule_id: int):
        direction = -1 if request.form.get("direction") == "up" else 1
        db.move_rule(g.db, g.user.id, rule_id, direction)
        return redirect(url_for("settings_rules") + f"#rule-{rule_id}")

    @app.post("/settings/rules/<int:rule_id>/delete")
    @login_required
    def settings_rules_delete(rule_id: int):
        db.delete_rule(g.db, g.user.id, rule_id)
        flash("Regel gelöscht.", "success")
        return redirect(url_for("settings_rules"))

    @app.route("/settings/accounts", methods=["GET", "POST"])
    @login_required
    def settings_accounts():
        if request.method == "POST":
            iban = converter.normalize_iban(request.form.get("iban", ""))
            if not iban:
                flash("Die IBAN des ING-Kontos eingeben.", "error")
            elif (account := _posted_account()) is not None:
                db.save_bank_account(
                    g.db, g.user.id, iban, account["id"], account["name"]
                )
                flash("Kontozuordnung gespeichert.", "success")
            return redirect(url_for("settings_accounts"))
        accounts, error = _asset_accounts()
        return render_template(
            "settings/accounts.html",
            mappings=db.list_bank_accounts(g.db, g.user.id),
            accounts=accounts,
            accounts_error=error,
        )

    @app.post("/settings/accounts/<int:mapping_id>/delete")
    @login_required
    def settings_accounts_delete(mapping_id: int):
        db.delete_bank_account(g.db, g.user.id, mapping_id)
        flash("Kontozuordnung entfernt.", "success")
        return redirect(url_for("settings_accounts"))

    @app.route("/settings/names", methods=["GET", "POST"])
    @login_required
    def settings_names():
        if request.method == "POST":
            names = {
                key: request.form.get(key, "").strip()
                for key in converter.NAME_SETTINGS
            }
            empty = [key for key, value in names.items() if not value]
            if empty:
                flash("Jedes Feld braucht einen Wert.", "error")
            elif "{card}" not in names["card_tag_format"]:
                flash(
                    "Das Kartenschlagwort braucht den Platzhalter {card}.",
                    "error",
                )
            else:
                db.set_names(g.db, g.user.id, names)
                flash("Namen gespeichert.", "success")
            return redirect(url_for("settings_names"))
        return render_template(
            "settings/names.html", names=db.get_names(g.db, g.user.id)
        )

    @app.route("/settings/processors", methods=["GET", "POST"])
    @login_required
    def settings_processors():
        if request.method == "POST":
            kind = request.form.get("kind", "")
            pattern = request.form.get("pattern", "").strip()
            if kind not in PROCESSOR_KINDS or not pattern:
                flash("Eine Art wählen und den Namen eingeben.", "error")
            else:
                db.add_processor(
                    g.db,
                    g.user.id,
                    kind,
                    pattern,
                    request.form.get("tag", ""),
                )
                flash("Zahlungsdienstleister gespeichert.", "success")
            return redirect(url_for("settings_processors"))
        return render_template(
            "settings/processors.html",
            processors=db.list_processors(g.db, g.user.id),
        )

    @app.post("/settings/processors/<int:processor_id>/delete")
    @login_required
    def settings_processors_delete(processor_id: int):
        db.delete_processor(g.db, g.user.id, processor_id)
        flash("Zahlungsdienstleister entfernt.", "success")
        return redirect(url_for("settings_processors"))

    @app.route("/settings/profile", methods=["GET", "POST"])
    @login_required
    def settings_profile():
        if request.method == "POST":
            client_id = request.form.get("client_id", "").strip()
            if client_id:
                g.user.client_id_enc = _vault().encrypt(client_id)
                flash(
                    "Client-ID gespeichert. Sie gilt ab der nächsten Anmeldung.",
                    "success",
                )
            return redirect(url_for("settings_profile"))
        return render_template(
            "settings/profile.html",
            redirect_uri=_redirect_uri(),
            client_id_ok=_vault().decrypt(g.user.client_id_enc) is not None,
        )

    @app.post("/settings/profile/delete")
    @login_required
    def settings_profile_delete():
        if request.form.get("confirm") != g.user.email:
            flash(
                "Zur Bestätigung die eigene E-Mail-Adresse eingeben.", "error"
            )
            return redirect(url_for("settings_profile"))
        user_id = g.user.id
        db.delete_user(g.db, user_id)
        _uploads().discard(user_id)
        session.clear()
        flash(
            "Dein Profil samt allen Einstellungen und Importen wurde"
            " gelöscht.",
            "success",
        )
        remaining = [
            known for known in _known_profile_ids() if known != user_id
        ]
        return _remember_profiles(redirect(url_for("login")), remaining)
