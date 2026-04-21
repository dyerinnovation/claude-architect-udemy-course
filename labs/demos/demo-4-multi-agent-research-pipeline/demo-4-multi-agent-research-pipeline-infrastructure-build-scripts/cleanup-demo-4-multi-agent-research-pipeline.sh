#!/usr/bin/env bash
# Cleanup Demo 4 — removes .venv and per-run research output.
# Leaves code and .env in place so a rerun is cheap.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[cleanup] cwd: $SCRIPT_DIR"

if [ -d ".venv" ]; then
  echo "[cleanup] removing .venv/"
  rm -rf .venv
else
  echo "[cleanup] no .venv to remove."
fi

if [ -d "./research-output" ]; then
  echo "[cleanup] removing ./research-output/"
  rm -rf ./research-output
else
  echo "[cleanup] no ./research-output to remove."
fi

echo "[cleanup] done. .env preserved; delete it manually if you want a totally clean slate."
