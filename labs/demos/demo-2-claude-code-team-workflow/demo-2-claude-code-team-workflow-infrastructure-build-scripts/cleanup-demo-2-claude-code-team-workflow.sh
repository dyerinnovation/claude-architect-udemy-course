#!/usr/bin/env bash
# cleanup-demo-2-claude-code-team-workflow.sh
#
# Removes the bootstrapped /tmp/demo-2-team-workflow/ directory.
# Does NOT touch anything under the source-of-truth
# demo-2-claude-code-team-workflow-infrastructure-build-scripts/ folder.

set -euo pipefail

TARGET_DIR="${DEMO2_TARGET_DIR:-/tmp/demo-2-team-workflow}"

if [[ -e "${TARGET_DIR}" ]]; then
  echo "[demo-2] removing ${TARGET_DIR}"
  rm -rf "${TARGET_DIR}"
else
  echo "[demo-2] ${TARGET_DIR} does not exist; nothing to do"
fi

# We do NOT call `unset ANTHROPIC_API_KEY` here because this script runs
# in a subshell — the unset would not affect the caller.  If you set the
# key for this demo, run the following in your interactive shell:
#
#   unset ANTHROPIC_API_KEY
#
echo "[demo-2] done."
