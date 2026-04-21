#!/usr/bin/env bash
# Deploy script for Demo 3 — Structured Data Extraction Pipeline.
#
# Stands up a Python virtual environment and installs the Anthropic SDK
# plus Pydantic. Safe to re-run (idempotent).
#
# Usage:
#   bash deploy-demo-3-structured-data-extraction.sh
#   source .venv/bin/activate
#   export ANTHROPIC_API_KEY=sk-ant-...
#   python extract.py --input sample-inputs/ --mode structured

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Demo 3 deploy — Structured Data Extraction ==="

# --- 1. Python version check ------------------------------------------------
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 not found on PATH." >&2
  exit 1
fi

PY_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')
echo "Python: $PY_VERSION"
PY_MAJOR=$(echo "$PY_VERSION" | cut -d. -f1)
PY_MINOR=$(echo "$PY_VERSION" | cut -d. -f2)
if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 10 ]; }; then
  echo "ERROR: Python 3.10+ required (found $PY_VERSION)." >&2
  exit 1
fi

# --- 2. Virtualenv ----------------------------------------------------------
if [ ! -d ".venv" ]; then
  echo "Creating virtualenv at .venv"
  python3 -m venv .venv
else
  echo "Virtualenv already exists at .venv (reusing)."
fi

# shellcheck disable=SC1091
source .venv/bin/activate

# --- 3. Dependencies --------------------------------------------------------
echo "Installing dependencies from requirements.txt"
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt

# --- 4. Sanity check --------------------------------------------------------
python -c "import anthropic, pydantic; print(f'anthropic={anthropic.__version__}, pydantic={pydantic.VERSION}')"

echo ""
echo "=== Deploy complete. Next steps: ==="
echo "  1. source .venv/bin/activate"
echo "  2. export ANTHROPIC_API_KEY=sk-ant-..."
echo "  3. python extract.py --input sample-inputs/ --mode structured"
echo ""
echo "To tear down:"
echo "  bash cleanup-demo-3-structured-data-extraction.sh"
