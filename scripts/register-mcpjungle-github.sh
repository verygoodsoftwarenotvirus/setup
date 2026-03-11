#!/usr/bin/env bash
# Register the GitHub MCP server with MCPJungle using GITHUB_PERSONAL_ACCESS_TOKEN.
# Requires: mcpjungle CLI, jq. Run after filling ~/.env_vars.sh and with MCPJungle server running.
# Usage: ./scripts/register-mcpjungle-github.sh

set -e

if [ -f "$HOME/.env_vars.sh" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.env_vars.sh"
fi

if [ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
  echo "GITHUB_PERSONAL_ACCESS_TOKEN is not set. Add it to ~/.env_vars.sh and re-run." >&2
  exit 1
fi

if ! command -v mcpjungle >/dev/null 2>&1; then
  echo "mcpjungle CLI not found. Install with: brew install mcpjungle/mcpjungle/mcpjungle" >&2
  exit 1
fi

REGISTRY="${MCPJUNGLE_REGISTRY_URL:-http://127.0.0.1:8080}"
CONFIG=$(jq -n \
  --arg token "$GITHUB_PERSONAL_ACCESS_TOKEN" \
  '{
    name: "github",
    transport: "stdio",
    description: "GitHub MCP server (repos, issues, PRs)",
    command: "npx",
    args: ["-y", "@modelcontextprotocol/server-github"],
    env: { GITHUB_PERSONAL_ACCESS_TOKEN: $token }
  }')

TMP=$(mktemp)
echo "$CONFIG" > "$TMP"
trap 'rm -f "$TMP"' EXIT

mcpjungle --registry "$REGISTRY" register -c "$TMP"
echo "GitHub MCP server registered with MCPJungle at $REGISTRY"
