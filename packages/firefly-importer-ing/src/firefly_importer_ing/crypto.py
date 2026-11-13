"""Encryption of the per-user secrets (client ID, tokens) in the database.

One secret key (at least 32 characters) is stretched with HKDF into the
Fernet key for the database fields and the key that signs the session
cookie. Changing it logs everyone out and makes the stored client IDs and
tokens unreadable: users then sign in again with their client ID.
"""

from __future__ import annotations

import base64

from cryptography.fernet import Fernet, InvalidToken
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

MIN_SECRET_LENGTH = 32


def _derive(secret: bytes, info: bytes) -> bytes:
    return HKDF(
        algorithm=hashes.SHA256(), length=32, salt=None, info=info
    ).derive(secret)


class Vault:
    def __init__(self, secret: str) -> None:
        if len(secret) < MIN_SECRET_LENGTH:
            raise ValueError(
                f"the secret key needs at least {MIN_SECRET_LENGTH} characters"
            )
        raw = secret.encode()
        fernet_key = _derive(raw, b"firefly-importer-ing/fernet")
        self._fernet = Fernet(base64.urlsafe_b64encode(fernet_key))
        self.session_key = _derive(raw, b"firefly-importer-ing/session")

    def encrypt(self, value: str) -> bytes:
        return self._fernet.encrypt(value.encode())

    def decrypt(self, token: bytes | memoryview | None) -> str | None:
        """None for a missing value or one encrypted with another key."""
        if token is None:
            return None
        try:
            return self._fernet.decrypt(bytes(token)).decode()
        except InvalidToken:
            return None
