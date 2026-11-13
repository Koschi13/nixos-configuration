"""End-to-end tests of the web app against a fake Firefly III and importer,
and a real PostgreSQL (see `conftest`)."""

import io
from datetime import UTC, datetime, timedelta
from urllib.parse import parse_qs, urlsplit

import pytest
import requests
import sample
import sqlalchemy
from conftest import DATABASE_URL, needs_database
from fake_firefly import ACCOUNT, FIREFLY, IMPORTER, FakeFirefly, session_for
from firefly_importer_ing import db, uploads, web
from firefly_importer_ing.models import Base, User
from flask import g
from sqlalchemy import select, text
from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import set_committed_value

pytestmark = needs_database

IMPORT = "/import"


@pytest.fixture
def fake():
    return FakeFirefly()


@pytest.fixture
def app(fake, empty_database):
    db.upgrade(DATABASE_URL)
    app = web.create_app(
        {
            "TESTING": True,
            "WTF_CSRF_ENABLED": False,
            "DATABASE_URL": DATABASE_URL,
            "FIREFLY_URL": FIREFLY,
            "IMPORTER_URL": IMPORTER,
            "PUBLIC_URL": "http://ing.test",
            "SECRET_KEY_RAW": "k" * 40,
            "AUTO_IMPORT_SECRET": fake.secret,
            "HTTP_SESSION": session_for(fake),
        }
    )
    yield app
    app.extensions["engine"].dispose()


@pytest.fixture
def database(app, empty_database):
    """A connection to look into, or change, what the app stored."""
    with empty_database.connect() as connection:
        yield connection
        connection.commit()


def sign_in(client, fake, user_id="1", client_id="7", next_url=None):
    """Sign in through the fake Firefly III, return where it lands."""
    response = client.post(
        "/login",
        query_string={"next": next_url} if next_url else None,
        data={"client_id": client_id},
    )
    assert response.status_code == 302
    location = urlsplit(response.headers["Location"])
    assert f"{location.scheme}://{location.netloc}" == FIREFLY
    assert location.path == "/oauth/authorize"
    query = {
        key: values[0] for key, values in parse_qs(location.query).items()
    }
    assert query["redirect_uri"] == "http://ing.test/oauth/callback"
    code = fake.authorize(query, user_id)
    response = client.get(
        "/oauth/callback", query_string={"code": code, "state": query["state"]}
    )
    assert response.status_code == 302, response.data
    if next_url is None:
        assert response.headers["Location"] == "/"
    return response.headers["Location"]


def upload(client, data=None):
    response = client.post(
        "/",
        data={"file": (io.BytesIO(data or sample.export()), "Umsatz.csv")},
        content_type="multipart/form-data",
    )
    assert response.status_code == 302, response.data
    assert response.headers["Location"] == IMPORT


def signed_in_with_upload(app, fake):
    client = app.test_client()
    sign_in(client, fake)
    upload(client)
    return client


def the_upload(app) -> uploads.Upload:
    """The only upload the app holds."""
    ((held, _),) = app.extensions["uploads"]._uploads.values()
    return held


def page(client, url=IMPORT) -> str:
    return client.get(url, follow_redirects=True).get_data(as_text=True)


def expire_tokens(database):
    database.execute(
        text("UPDATE users SET token_expires_at = :expired"),
        {"expired": datetime.now(UTC) - timedelta(minutes=1)},
    )
    database.commit()


# --- sign-in ---------------------------------------------------------------


def test_requires_sign_in(app):
    response = app.test_client().get("/")
    assert response.status_code == 302
    assert "/login" in response.headers["Location"]


@pytest.mark.parametrize(
    "target",
    [
        "//evil.example/phish",
        "/\\evil.example",
        "/\t/evil.example",
        "https://evil.example/",
        "evil.example",
    ],
)
def test_sign_in_stays_on_this_site(app, fake, target):
    assert sign_in(app.test_client(), fake, next_url=target) == "/"


def test_sign_in_returns_to_the_page_asked_for(app, fake):
    target = "/settings/rules?test_payee=x"
    assert sign_in(app.test_client(), fake, next_url=target) == target


def test_sign_in_does_not_return_to_a_form(app):
    response = app.test_client().post(IMPORT + "/send")
    assert response.headers["Location"] == "/login"


def test_sign_in_page_shows_only_this_browsers_profiles(app, fake, database):
    erika = app.test_client()
    sign_in(erika, fake, user_id="1")
    sign_in(app.test_client(), fake, user_id="2")

    stranger = page(app.test_client(), "/login")
    assert "@example.org" not in stranger

    erika.post("/logout")
    login_page = page(erika, "/login")
    assert "erika@example.org" in login_page
    assert "max@example.org" not in login_page
    # a profile of another browser can't be started from here
    ids = dict(database.execute(text("SELECT email, id FROM users")).all())
    max_id, erika_id = ids["max@example.org"], ids["erika@example.org"]
    assert erika.post(f"/oauth/start/{max_id}").status_code == 404

    erika.post(f"/login/forget/{erika_id}")
    assert "erika@example.org" not in page(erika, "/login")


def test_expired_token_is_refreshed(app, fake, database):
    client = app.test_client()
    sign_in(client, fake)
    expire_tokens(database)
    tokens_before = set(fake.tokens)
    assert ACCOUNT["name"] in page(client, "/settings/accounts")
    assert set(fake.tokens) - tokens_before  # a new token was issued


def test_one_refresh_per_request(app, fake, database):
    """Sending calls Firefly III twice (upload, then the check); the
    second call must use the new token, not refresh with the used one."""
    client = signed_in_with_upload(app, fake)
    expire_tokens(database)
    client.post(IMPORT + "/send", data={"start": "2026-11-01"})
    assert fake.refresh_count == 1
    assert "Was in Firefly III angekommen ist" in page(client)


def test_a_parallel_refresh_is_used_not_repeated(app, fake):
    """A request that saw the token expire waits for the row lock and
    then finds the token another request just refreshed."""
    sign_in(app.test_client(), fake)
    with app.test_request_context("/"):
        g.db = Session(app.extensions["engine"])  # closed by the teardown
        g.user = g.db.scalars(select(User)).one()
        # what this request read before the other one refreshed
        set_committed_value(
            g.user,
            "token_expires_at",
            datetime.now(UTC) - timedelta(minutes=1),
        )
        token = web._access_token()
    assert fake.refresh_count == 0
    assert token in fake.tokens


def test_stored_secrets_are_encrypted(app, fake, database):
    sign_in(app.test_client(), fake)
    client_id, access_token = database.execute(
        text("SELECT client_id_enc, access_token_enc FROM users")
    ).one()
    assert bytes(client_id).startswith(b"gAAAA")
    assert all(
        token.encode() not in bytes(access_token) for token in fake.tokens
    )


# --- import ----------------------------------------------------------------


def test_upload_send_and_check(app, fake):
    client = signed_in_with_upload(app, fake)
    preview = page(client)
    # account found by the IBAN of the export
    assert f"{ACCOUNT['name']}</span>" in preview
    assert f"#{ACCOUNT['id']}" in preview
    assert "CAFE BEISPIEL" in preview
    # a default rule of the new user applied
    assert "dm-drogerie markt" in preview

    response = client.post(
        IMPORT + "/send", data={"start": "2026-10-01", "stop": "2026-10-31"}
    )
    assert response.status_code == 302
    (sent,) = fake.uploads
    assert sent["config"]["default_account"] == ACCOUNT["id"]
    assert {row["date"][:7] for row in sent["rows"]} == {"2026-10"}

    result = page(client)
    assert "Was in Firefly III angekommen ist" in result
    assert "Fehlen in Firefly III" not in result

    # sending a finished import again does nothing
    client.post(IMPORT + "/send", data={"start": "2026-10-01"})
    assert len(fake.uploads) == 1


def test_nothing_about_an_upload_is_stored(app, fake, database):
    client = signed_in_with_upload(app, fake)
    client.post(IMPORT + "/send")
    assert len(fake.uploads) == 1

    tables = set(sqlalchemy.inspect(database).get_table_names())
    assert tables == {"alembic_version", *Base.metadata.tables}
    # the account was found by its IBAN in Firefly III, not remembered
    assert database.execute(text("SELECT * FROM bank_accounts")).all() == []


def test_another_window_of_the_same_upload(app, fake):
    client = signed_in_with_upload(app, fake)
    client.post(IMPORT + "/send", data={"start": "2026-11-01"})
    client.post(IMPORT + "/reset")
    assert "4 an Firefly III senden" in page(
        client, IMPORT + "?start=2026-11-01"
    )
    client.post(
        IMPORT + "/send", data={"start": "2026-10-01", "stop": "2026-10-31"}
    )
    assert len(fake.uploads) == 2


def test_a_discarded_upload_is_gone(app, fake):
    client = signed_in_with_upload(app, fake)
    assert "Umsatz.csv" in page(client, "/")
    client.post(IMPORT + "/discard")
    assert app.extensions["uploads"]._uploads == {}
    assert "Es ist keine Datei (mehr) hochgeladen" in page(client)
    assert client.post(IMPORT + "/send").headers["Location"] == "/"
    assert fake.uploads == []


def test_signing_out_discards_the_upload(app, fake):
    client = signed_in_with_upload(app, fake)
    client.post("/logout")
    assert app.extensions["uploads"]._uploads == {}


def test_users_are_separated(app, fake):
    erika = signed_in_with_upload(app, fake)

    max_ = app.test_client()
    sign_in(max_, fake, user_id="2")
    assert max_.get(IMPORT).headers["Location"] == "/"
    assert "CAFE BEISPIEL" not in page(max_)
    assert "CAFE BEISPIEL" in page(erika)


def test_missing_bookings_are_listed(app, fake):
    fake.drop_first_upload_row = True
    client = signed_in_with_upload(app, fake)
    client.post(
        IMPORT + "/send", data={"start": "2026-11-01", "stop": "2026-11-30"}
    )
    result = page(client)
    assert "1 von 4 gesendeten Buchungen fehlen in Firefly III" in result
    assert "Fehlen in Firefly III" in result


def test_viewing_a_sent_upload_asks_firefly_nothing(app, fake):
    client = signed_in_with_upload(app, fake)
    client.post(IMPORT + "/send", data={"start": "2026-11-01"})

    # deleted in Firefly III afterwards: only an explicit check notices
    fake.transactions.clear()
    assert "Fehlen in Firefly III" not in page(client)

    client.post(IMPORT + "/check")
    result = page(client)
    assert "4 von 4 gesendeten Buchungen fehlen in Firefly III" in result
    assert "Fehlen in Firefly III" in result


def test_an_upload_in_progress_is_not_sent_again(app, fake):
    client = signed_in_with_upload(app, fake)
    the_upload(app).state = uploads.SENDING
    client.post(IMPORT + "/send", data={"start": "2026-11-01"})
    assert fake.uploads == []
    assert "Der Importer hat noch nicht geantwortet" in page(client)


def test_an_unanswered_upload_counts_as_sent(app, fake, monkeypatch):
    """The importer may still be working after a timeout, so the upload is
    checked in Firefly III instead of being offered for sending again."""

    def no_answer(*args, **kwargs):
        raise requests.ReadTimeout("read timed out")

    client = signed_in_with_upload(app, fake)
    monkeypatch.setattr(app.extensions["http"], "post", no_answer)
    client.post(IMPORT + "/send", data={"start": "2026-11-01"})
    result = page(client)
    assert "hat nicht rechtzeitig geantwortet" in result
    assert "Fehlen in Firefly III" in result
    assert the_upload(app).state == uploads.SENT


def test_send_survives_an_unreachable_firefly(
    app, fake, database, monkeypatch
):
    def unreachable(*args, **kwargs):
        raise requests.ConnectionError("connection refused")

    client = signed_in_with_upload(app, fake)
    expire_tokens(database)
    monkeypatch.setattr(app.extensions["http"], "request", unreachable)
    response = client.post(IMPORT + "/send", data={"start": "2026-11-01"})
    assert response.status_code == 302
    assert fake.uploads == []
    preview = page(client, response.headers["Location"])
    assert "Firefly III war nicht erreichbar" in preview
    assert "4 an Firefly III senden" in preview


def test_a_refused_upload_stays_a_draft(app, fake):
    fake.importer_fails = True
    client = signed_in_with_upload(app, fake)
    client.post(IMPORT + "/send", data={"start": "2026-11-01"})
    preview = page(client)
    assert "letzter Versuch fehlgeschlagen" in preview
    assert "Too many errors" in preview


def test_an_account_has_to_exist_in_firefly(app, fake, database):
    client = signed_in_with_upload(app, fake)
    the_upload(app).account_id = None

    # without an account there is no configuration to download
    assert client.get(IMPORT + "/json").status_code == 302

    client.post(
        IMPORT + "/account", data={"account_id": "99", "remember": "1"}
    )
    client.post(
        "/settings/accounts",
        data={"iban": ACCOUNT["iban"], "account_id": "99"},
    )
    assert the_upload(app).account_id is None
    assert database.execute(text("SELECT * FROM bank_accounts")).all() == []
    assert "Firefly III hat kein Bestandskonto mit dieser ID." in page(client)

    client.post(
        IMPORT + "/account",
        data={"account_id": ACCOUNT["id"], "remember": "1"},
    )
    config = client.get(IMPORT + "/json").get_json()
    assert config["default_account"] == ACCOUNT["id"]
    assert database.execute(
        text("SELECT iban, firefly_account_id, name FROM bank_accounts")
    ).all() == [(ACCOUNT["iban"], ACCOUNT["id"], ACCOUNT["name"])]


def test_downloads(app, fake):
    client = signed_in_with_upload(app, fake)
    csv_ = client.get(IMPORT + "/csv", query_string={"start": "2026-11-01"})
    assert csv_.headers["Content-Disposition"].endswith(
        "firefly-5678-20261101-20261110.csv"
    )
    assert csv_.data.startswith(b"date,interest_date,payment_date")
    config = client.get(IMPORT + "/json").get_json()
    assert config["default_account"] == ACCOUNT["id"]


def test_a_file_that_is_no_export_is_refused(app, fake):
    client = app.test_client()
    sign_in(client, fake)
    client.post(
        "/",
        data={"file": (io.BytesIO(b"not;an;export\n"), "x.csv")},
        content_type="multipart/form-data",
    )
    assert "Diese Datei lässt sich nicht lesen" in page(client, "/")
    assert app.extensions["uploads"]._uploads == {}


# --- settings --------------------------------------------------------------


def test_rule_changes_the_preview(app, fake):
    client = app.test_client()
    sign_in(client, fake)
    response = client.post(
        "/settings/rules",
        data={
            "match": "contains",
            "field": "payee",
            "pattern": "cafe beispiel",
            "new_name": "Lieblingscafé",
            "category": "Essen & Trinken",
            "tags": "Kaffee, Draußen",
            "enabled": "1",
        },
    )
    assert response.status_code == 302
    upload(client)
    preview = page(client)
    assert "Lieblingscafé" in preview
    assert "Essen &amp; Trinken" in preview
    assert "Kaffee" in preview

    tested = client.get(
        "/settings/rules", query_string={"test_payee": "CAFE BEISPIEL"}
    ).get_data(as_text=True)
    assert "Lieblingscafé" in tested


def test_rules_can_be_changed_moved_and_deleted(app, fake, database):
    client = app.test_client()
    sign_in(client, fake)

    def rules():
        return database.execute(
            text("SELECT id, new_name FROM payee_rules ORDER BY position")
        ).all()

    (first_id, first_name), (second_id, _), *_ = before = rules()
    client.post(f"/settings/rules/{first_id}/move", data={"direction": "down"})
    database.commit()
    assert [rule_id for rule_id, _ in rules()[:2]] == [second_id, first_id]

    client.post(
        f"/settings/rules/{first_id}",
        data={
            "match": "exact",
            "field": "payee",
            "pattern": "x",
            "new_name": first_name + " neu",
        },
    )
    database.commit()
    assert (first_id, first_name + " neu") in rules()

    client.post(f"/settings/rules/{first_id}/delete")
    database.commit()
    assert len(rules()) == len(before) - 1


def test_names_and_processors_are_saved(app, fake):
    client = app.test_client()
    sign_in(client, fake)
    names = {
        key: default
        for key, (default, _) in web.converter.NAME_SETTINGS.items()
    }
    client.post("/settings/names", data={**names, "tag_visa": "Kreditkarte"})
    client.post("/settings/names", data={**names, "tag_visa": "Karte"})
    assert 'value="Karte"' in page(client, "/settings/names")

    for tag in ("Alt", "Neu"):
        client.post(
            "/settings/processors",
            data={"kind": "visa_prefix", "pattern": "testpay", "tag": tag},
        )
    processors = page(client, "/settings/processors")
    assert processors.count("TESTPAY") == 1
    assert "Neu" in processors


def test_invalid_regex_is_not_saved(app, fake):
    client = app.test_client()
    sign_in(client, fake)
    client.post(
        "/settings/rules",
        data={
            "match": "regex",
            "field": "payee",
            "pattern": "([",
            "new_name": "x",
        },
    )
    assert "Nicht gespeichert" in page(client, "/settings/rules")


def test_deleting_the_profile_deletes_everything(app, fake, database):
    client = signed_in_with_upload(app, fake)
    client.post("/settings/profile/delete", data={"confirm": "wrong"})
    assert database.execute(text("SELECT count(*) FROM users")).scalar() == 1
    database.commit()

    client.post(
        "/settings/profile/delete", data={"confirm": "erika@example.org"}
    )
    for table in Base.metadata.tables:
        count = database.execute(text(f"SELECT count(*) FROM {table}"))
        assert count.scalar() == 0, table
    assert app.extensions["uploads"]._uploads == {}
