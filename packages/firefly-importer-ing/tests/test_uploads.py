"""The in-memory store of the uploads users are working on."""

from datetime import date, timedelta

from firefly_importer_ing import converter, uploads
from firefly_importer_ing.uploads import Upload, UploadStore


class Clock:
    def __init__(self):
        self.now = 0.0

    def __call__(self) -> float:
        return self.now


def new_upload() -> Upload:
    return Upload("Umsatz.csv", converter.Export({}, []))


def test_each_user_has_one_upload():
    store = UploadStore()
    first, second, other = new_upload(), new_upload(), new_upload()
    store.put(1, first)
    store.put(2, other)
    store.put(1, second)
    assert store.get(1) is second
    assert store.get(2) is other
    store.discard(1)
    assert store.get(1) is None
    assert store.get(2) is other


def test_an_unused_upload_expires():
    clock = Clock()
    store = UploadStore(lifetime=timedelta(minutes=10), clock=clock)
    store.put(1, new_upload())
    clock.now = 9 * 60
    assert store.get(1) is not None  # using it keeps it
    clock.now = 18 * 60
    assert store.get(1) is not None
    clock.now = 29 * 60
    assert store.get(1) is None


def test_an_upload_being_sent_does_not_expire():
    clock = Clock()
    store = UploadStore(lifetime=timedelta(minutes=10), clock=clock)
    upload = new_upload()
    store.put(1, upload)
    upload.begin_send([], date(2026, 11, 1), date(2026, 11, 30))
    clock.now = 60 * 60
    assert store.get(1) is upload


def test_an_upload_is_sent_once():
    upload = new_upload()
    window = (date(2026, 11, 1), date(2026, 11, 30))
    assert upload.begin_send([{"date": "2026-11-02"}], *window)
    assert not upload.begin_send([], *window)
    upload.finish_send(True, "taken")
    assert upload.state == uploads.SENT
    assert not upload.begin_send([], *window)
    assert upload.rows == [{"date": "2026-11-02"}]


def test_a_refused_upload_can_be_sent_again():
    upload = new_upload()
    window = (date(2026, 11, 1), date(2026, 11, 30))
    upload.begin_send([{"date": "2026-11-02"}], *window)
    upload.finish_send(False, "refused")
    assert upload.state == uploads.DRAFT
    assert upload.failure == "refused"
    assert upload.rows == []
    assert upload.begin_send([], *window)
    assert upload.failure == ""
