#!/usr/bin/env bash
#
# Cleanup Demo 1 — Multi-Tool Agent with Escalation.
#
# Removes the .venv directory created by deploy. No cloud resources,
# no external state — this is a local-only demo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Cleaning up Demo 1 in $SCRIPT_DIR"

if [[ -d .venv ]]; then
    echo "==> Removing .venv/"
    rm -rf .venv
else
    echo "==> No .venv to remove (already clean)."
fi

# Leave the optional .env file in place by default — it may contain
# the student's API key. Uncomment the next block if you want to nuke it.
# if [[ -f .env ]]; then
#     echo "==> Removing .env"
#     rm -f .env
# fi

echo "==> Cleanup complete."
