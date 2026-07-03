# shellcheck shell=bash
# Notion — registered as a user-scope MCP server for Claude Code (OAuth as you).

c_notion_status() {
  command -v claude >/dev/null 2>&1 || return 1
  claude mcp list 2>/dev/null | grep -qi notion
}

c_notion_setup() {
  pointer notion
  if ! command -v claude >/dev/null 2>&1; then
    warn "Claude Code CLI not found. Install it first: https://docs.claude.com/claude-code"
    return 0
  fi
  say "Adding Notion as a user-scope MCP server (available in every project)…"
  if claude mcp add --scope user --transport http notion https://mcp.notion.com/mcp; then
    ok "Notion MCP added. Inside Claude Code, run '/mcp' and authenticate as yourself."
  else
    warn "Could not add Notion MCP (maybe already added). Check: claude mcp list"
  fi
}
