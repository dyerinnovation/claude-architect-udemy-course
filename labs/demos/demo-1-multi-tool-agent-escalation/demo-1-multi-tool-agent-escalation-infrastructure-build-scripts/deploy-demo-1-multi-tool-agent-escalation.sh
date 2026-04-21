#!/usr/bin/env bash
#
# Deploy Demo 1 — Multi-Tool Agent with Escalation.
#
# Creates a Python virtualenv in ./.venv, installs pinned deps, and
# prints the two commands students run to execute the demo scenarios.
#
# Idempotent: re-running is safe; it upgrades pip and reinstalls deps.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PY="${PYTHON:-python3}"

echo "==> Deploying Demo 1 in $SCRIPT_DIR"

# Guard against Python < 3.10 (the agent uses PEP 604 union types).
"$PY" - <<'PYCHECK'
import sys
major, minor = sys.version_info[:2]
if (major, minor) < (3, 10):
    sys.exit(f"ERROR: Python 3.10+ required, got {major}.{minor}")
PYCHECK

# Create venv if missing.
if [[ ! -d .venv ]]; then
    echo "==> Creating virtualenv at .venv/"
    "$PY" -m venv .venv
else
    echo "==> Reusing existing virtualenv at .venv/"
fi

# shellcheck disable=SC1091
source .venv/bin/activate

echo "==> Upgrading pip and installing requirements.txt"
python -m pip install --upgrade pip >/dev/null
pip install -r requirements.txt

echo ""
echo "==> Deploy complete."
echo ""
echo "Next steps:"
echo "  1. Activate the venv:       source .venv/bin/activate"
echo "  2. Set your API key:        export ANTHROPIC_API_KEY=sk-ant-..."
echo "     (or copy .env.example to .env and fill it in)"
echo "  3. Run the happy path:      python agent.py --scenario happy-path"
echo "  4. Run the edge case:       python agent.py --scenario edge-case"
echo ""
echo "Teardown when done:           bash cleanup-demo-1-multi-tool-agent-escalation.sh"
