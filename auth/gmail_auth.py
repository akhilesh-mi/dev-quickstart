#!/usr/bin/env python3
"""Mint a personal Gmail+Drive OAuth token from a shared OAuth client.

Reads   credentials.json  (the OAuth client, shared across the team)
Writes  token.json        (YOUR personal refresh token — never share)

Both live in $MI_GMAIL_DIR (default ~/.mi_gmail_ack).
Scopes: gmail.send + drive.
"""
import os
import sys

DIR = os.environ.get("MI_GMAIL_DIR", os.path.expanduser("~/.mi_gmail_ack"))
SCOPES = [
    "https://www.googleapis.com/auth/gmail.send",
    "https://www.googleapis.com/auth/drive",
]


def main():
    try:
        from google_auth_oauthlib.flow import InstalledAppFlow
        from google.auth.transport.requests import Request
        from google.oauth2.credentials import Credentials
    except ImportError:
        print(
            "Missing Google libraries. Run:\n"
            "  python3 -m pip install --user google-auth-oauthlib google-api-python-client",
            file=sys.stderr,
        )
        sys.exit(1)

    creds_path = os.path.join(DIR, "credentials.json")
    token_path = os.path.join(DIR, "token.json")

    if not os.path.exists(creds_path):
        print(f"Missing OAuth client: {creds_path}", file=sys.stderr)
        print("Get credentials.json from your contact (or create a Desktop OAuth client).", file=sys.stderr)
        sys.exit(1)

    creds = None
    if os.path.exists(token_path):
        creds = Credentials.from_authorized_user_file(token_path, SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(creds_path, SCOPES)
            creds = flow.run_local_server(port=0)
        with open(token_path, "w") as fh:
            fh.write(creds.to_json())
        os.chmod(token_path, 0o600)

    print(f"Token ready: {token_path}")


if __name__ == "__main__":
    main()
