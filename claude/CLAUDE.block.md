<!-- dev-quickstart:begin -->
## Masters India dev environment (installed by dev-quickstart)

You (Claude) have the tools below available **whenever their credential files exist**.
Use them directly — don't ask the user to re-supply anything already configured.
To add or repair a connection, tell the user to run `dev-quickstart` in their terminal.
**Never ask the user to paste secrets into chat.** Never emit customer PII or secrets in output.

Per-user credential/config files (all mode 0600, in $HOME):
- **VPN** — `~/.mi_vpn_secret`, `~/.mi_vpn.env` (`MI_VPN_SERVER`). Most tools below are VPN-only.
- **Databases** — `~/.mi_db_creds.env` → `MI_MONGO_URI`, `MI_PG_HOST/PORT/DB/USER/PASSWORD`. Read-only; never write.
- **Metabase** — `~/.mi_metabase_session` → `MI_METABASE_URL`, `MI_METABASE_SESSION` (expires; re-run if 401).
- **S3 raw-archive** — `~/.mi_s3_creds.env` → `AWS_ACCESS_KEY_ID/SECRET_ACCESS_KEY/DEFAULT_REGION`. Read-only.
- **Gmail + Drive** (acts as the user) — `~/.mi_gmail_ack/{credentials.json,token.json}`, scopes gmail.send + drive.
- **Repos** — cloned under the workspace dir (default `~/Documents/mastersindia`), checked out on prod branches.
- **Graphify** — `graphify` CLI on PATH; per-repo graphs in each repo's `graphify-out/`.
- **Notion / Jira+Confluence** — user-scope MCP servers (`claude mcp list`), authorized as the user.

How to use:
- **Codebase / architecture / "where is X" questions** → prefer graphify first:
  `cd <repo> && graphify query "<question>"` (also `graphify path A B`, `graphify explain X`) before grep/glob.
- **DB / Metabase / S3 / repos** need the VPN up.
- If a tool's credential file is **missing**, don't improvise — tell the user:
  "run `dev-quickstart` and set up <connector>". They enter secrets in their own terminal.
<!-- dev-quickstart:end -->
