# shellcheck shell=bash
# Jira / Confluence — Atlassian MCP server for Claude Code (OAuth as you).

c_jira_status() { _mcp_registered "atlassian|jira"; }

c_jira_setup() {
  pointer jira
  if ! command -v claude >/dev/null 2>&1; then
    warn "Claude Code CLI not found. Install it first: https://docs.claude.com/claude-code"
    return 0
  fi
  say "Adding Atlassian (Jira + Confluence) as a user-scope MCP server…"
  if claude mcp add --scope user --transport sse atlassian https://mcp.atlassian.com/v1/sse; then
    ok "Atlassian MCP added. Inside Claude Code, run '/mcp' and authenticate as yourself."
  else
    warn "Could not add Atlassian MCP (maybe already added). Check: claude mcp list"
  fi
}
