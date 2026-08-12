#!/usr/bin/env bash
# Sends one prompt (read from stdin) to the Codex CLI non-interactively and
# prints Codex's reply to stdout. `codex exec -` reads the full prompt from
# stdin, which avoids shell-quoting/length issues with long, multi-line
# review prompts.
#
# Usage:
#   ./ask_codex.sh <<'EOF'
#   <prompt text, can be multi-line>
#   EOF
set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  cat >&2 <<'MSG'
ERROR: 'codex' CLI not found on PATH.

Install it with:
  npm install -g @openai/codex

(Not `npm i -g codex` -- that unscoped package is an unrelated 2012 project.)

Then authenticate with:
  codex auth
  # or sign in with a ChatGPT Plus/Pro/Team/Edu/Enterprise account

Verify with:
  codex --version

Then retry.
MSG
  exit 1
fi

codex exec -
