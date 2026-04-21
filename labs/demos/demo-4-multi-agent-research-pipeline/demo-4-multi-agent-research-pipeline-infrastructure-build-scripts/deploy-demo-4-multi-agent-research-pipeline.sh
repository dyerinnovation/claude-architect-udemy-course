#!/usr/bin/env bash
# Deploy Demo 4 — Multi-Agent Research Pipeline.
# Creates a local venv, installs pinned deps, and prepares the output dir.
# Does NOT execute a run — the student / instructor runs research_pipeline.py
# manually with --question after deploying.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[deploy] cwd: $SCRIPT_DIR"

# 1. Python venv.
if [ ! -d ".venv" ]; then
  echo "[deploy] creating .venv (Python 3.10+ required)..."
  python3 -m venv .venv
else
  echo "[deploy] .venv already exists — reusing."
fi

# shellcheck disable=SC1091
source .venv/bin/activate

# 2. Dependencies.
echo "[deploy] installing requirements..."
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt

# 3. Output directory.
mkdir -p ./research-output

# 4. .env scaffolding (never overwrite an existing .env).
if [ ! -f ".env" ]; then
  cp .env.example .env
  echo "[deploy] wrote .env (edit this file and set ANTHROPIC_API_KEY before running)."
else
  echo "[deploy] .env already exists — leaving it alone."
fi

echo ""
echo "[deploy] done. Next steps:"
echo "  1. Edit .env and set ANTHROPIC_API_KEY."
echo "  2. source .venv/bin/activate"
echo "  3. export \$(grep -v '^#' .env | xargs)"
echo "  4. python research_pipeline.py --question \"\$(head -n1 sample-questions.txt)\""
