#!/usr/bin/env bash
# Cleanup script for Demo 3 — Structured Data Extraction Pipeline.
#
# Removes the virtualenv and any local artifacts. Does not delete sample
# inputs or the code itself. Safe to re-run.
#
# Usage:
#   bash cleanup-demo-3-structured-data-extraction.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Demo 3 cleanup — Structured Data Extraction ==="

# Deactivate the venv if this shell has it active. We can't reliably detect
# this without the VIRTUAL_ENV env var, so we emit a reminder instead.
if [ -n "${VIRTUAL_ENV:-}" ] && [ "${VIRTUAL_ENV}" = "$SCRIPT_DIR/.venv" ]; then
  echo "NOTE: your current shell still has the venv activated."
  echo "      Run 'deactivate' to clear it after this script finishes."
fi

# --- Remove virtualenv ------------------------------------------------------
if [ -d ".venv" ]; then
  echo "Removing .venv/"
  rm -rf .venv
else
  echo "No .venv/ to remove."
fi

# --- Remove Python caches ---------------------------------------------------
find . -type d -name "__pycache__" -prune -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true

# --- Remove any local .env copies (keep .env.example) -----------------------
if [ -f ".env" ]; then
  echo "Removing local .env (contains your API key)."
  rm -f .env
fi

echo ""
echo "=== Cleanup complete. ==="
echo "Preserved: source files (extract.py, schema.json, sample-inputs/, .env.example)."
