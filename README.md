# dev-quickstart

One command to give a new developer — and their Claude — the same access to Masters India's
stack that the rest of the team has: repos, databases, Metabase, S3, VPN, graphify, Gmail/Drive,
and Notion/Jira via MCP.

You bring your **own** credentials for everything. Nothing here contains secrets, and nothing you
type ever leaves your machine or lands in a chat transcript.

## Quick start

```bash
git clone https://github.com/akhilesh-mi/dev-quickstart.git
cd dev-quickstart
./install.sh            # puts `dev-quickstart` on your PATH
dev-quickstart          # opens the interactive menu
```

You'll see a checklist. Pick the connections you have credentials for — in any order, as many or
as few as you like — and come back later to add the rest:

```
 Masters India — dev-quickstart

  1. [✓] Source repos (GitLab)
  2. [✓] Graphify knowledge graph
  3. [○] Company VPN (L2TP)
  4. [○] Mongo + Postgres (read-only)
  5. [✓] Metabase (analytics)
  6. [○] S3 raw-archive (read-only)
  7. [✓] Gmail + Drive (as you)
  8. [○] Notion (MCP)
  9. [○] Jira / Confluence (MCP)

Pick numbers (e.g. "1 3 5"), a=all pending, q=save & quit:
```

Each item tells you exactly where to get the credential (a link to click, or a teammate to email),
prompts you for it privately, saves it to a `0600` file in your home directory, and turns green.

## Commands

| Command | What it does |
| --- | --- |
| `dev-quickstart` | interactive menu (default) |
| `dev-quickstart status` | show what's configured |
| `dev-quickstart add NAME` | configure one connector, e.g. `add databases` |
| `dev-quickstart list` | list connector names |
| `dev-quickstart claude-md` | (re)install the Claude knowledge block |

## How your Claude gets access

Two mechanisms, both handled for you:

- **MCP tools** (Notion, Jira/Confluence) are registered with `claude mcp add --scope user`, so
  they're live in every Claude Code session. You authorize each with your own login via `/mcp`.
- **Files + CLIs** (DB creds, Metabase token, S3 keys, VPN secret, Gmail/Drive token, cloned repos,
  graphify) are written to standard per-user locations.

The tool also installs a block into your global `~/.claude/CLAUDE.md` describing what exists and how
to use it — so Claude uses these tools automatically, without you explaining them each session.

## Where things get saved

| Connector | Location |
| --- | --- |
| VPN | `~/.mi_vpn_secret`, `~/.mi_vpn.env` |
| Databases | `~/.mi_db_creds.env` |
| Metabase | `~/.mi_metabase_session` |
| S3 | `~/.mi_s3_creds.env` |
| Gmail + Drive | `~/.mi_gmail_ack/{credentials.json,token.json}` |
| Repos | your workspace dir (default `~/Documents/mastersindia`) |
| Notion / Jira | Claude Code user-scope MCP servers |

## For the maintainer

- Edit **`config/connectors.conf`** to set the real contact email / help URL / note for each
  connector (the `CHANGEME@` placeholders).
- Distribute the shared Gmail/Drive **`credentials.json`** privately (not via this repo) — each dev
  drops it into `~/.mi_gmail_ack/` and OAuths into their own `token.json`.
- Share the repo list + prod branches with devs so they can fill `config/repos.conf`
  (see `config/repos.conf.example`). That file is gitignored on purpose.
- No internal hostnames, IPs, or secrets live in this repo — they're prompted at runtime.

## Security notes

- Run in your **own terminal**, not by pasting secrets into a chat window.
- Secret prompts are hidden (`read -s`); credential files are `chmod 600`.
- `repos.conf`, `credentials.json`, `token.json`, and any `*.env` are gitignored.
- Everything is per-user: your token, your access, your responsibility.
