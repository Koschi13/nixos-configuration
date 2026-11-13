"""The uploads users are working on, kept in the memory of this process.

Nothing about an upload is written to the database or to disk: an export is
read, previewed, sent to the importer and then forgotten. Each user has at
most one upload; it is dropped when they discard it, upload another file,
leave it untouched for `UPLOAD_LIFETIME`, or when the service restarts.

Because the uploads live in one process, the web app has to run in a single
worker process (with threads).
"""

from __future__ import annotations

import threading
import time
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta

from . import converter

UPLOAD_LIFETIME = timedelta(hours=1)

# The states of an upload
DRAFT = "draft"  # being previewed, can be sent
SENDING = "sending"  # handed to the importer, which has not answered yet
SENT = "sent"  # the importer has the bookings


@dataclass
class Check:
    """What Firefly III has of the bookings that were sent."""

    missing: list[dict]  # sent rows it lacks
    others: list[dict]  # its transactions in the window that were not sent
    checked_at: datetime


@dataclass
class Upload:
    file_name: str
    export: converter.Export
    # The Firefly III asset account the bookings go to
    account_id: int | None = None
    account_name: str = ""
    state: str = DRAFT
    # Why the importer refused the last attempt to send
    failure: str = ""
    # What was sent: the rows of the window, and the importer's answer
    rows: list[dict] = field(default_factory=list)
    start: date | None = None
    stop: date | None = None
    answer: str = ""
    check: Check | None = None
    _lock: threading.Lock = field(default_factory=threading.Lock, repr=False)

    def begin_send(self, rows: list[dict], start: date, stop: date) -> bool:
        """Claim the upload for sending these rows. False if it is being
        sent or was sent already: of two requests only one gets to send."""
        with self._lock:
            if self.state != DRAFT:
                return False
            self.state = SENDING
        self.rows, self.start, self.stop = rows, start, stop
        self.failure, self.answer, self.check = "", "", None
        return True

    def finish_send(self, ok: bool, message: str) -> None:
        """Store the importer's answer. Without `ok` nothing was imported
        and the upload can be sent again."""
        if ok:
            self.state, self.answer = SENT, message
        else:
            self.reset()
            self.failure = message

    def reset(self) -> None:
        """Back to the preview, e.g. to send another window of the file."""
        self.rows, self.start, self.stop = [], None, None
        self.failure, self.answer, self.check = "", "", None
        self.state = DRAFT


class UploadStore:
    """The current upload of each user. Safe to use from several threads."""

    def __init__(
        self,
        lifetime: timedelta = UPLOAD_LIFETIME,
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        self._lifetime = lifetime.total_seconds()
        self._clock = clock
        self._lock = threading.Lock()
        # user ID -> (upload, when it was last used)
        self._uploads: dict[int, tuple[Upload, float]] = {}

    def _drop_expired(self) -> None:
        oldest = self._clock() - self._lifetime
        self._uploads = {
            user_id: (upload, used)
            for user_id, (upload, used) in self._uploads.items()
            # an upload the importer is working on is still in use
            if used >= oldest or upload.state == SENDING
        }

    def put(self, user_id: int, upload: Upload) -> None:
        """Make this the upload of the user, replacing an earlier one."""
        with self._lock:
            self._drop_expired()
            self._uploads[user_id] = (upload, self._clock())

    def get(self, user_id: int) -> Upload | None:
        """The upload of the user, which counts as using it."""
        with self._lock:
            self._drop_expired()
            if user_id not in self._uploads:
                return None
            upload, _ = self._uploads[user_id]
            self._uploads[user_id] = (upload, self._clock())
            return upload

    def discard(self, user_id: int) -> None:
        with self._lock:
            self._uploads.pop(user_id, None)
