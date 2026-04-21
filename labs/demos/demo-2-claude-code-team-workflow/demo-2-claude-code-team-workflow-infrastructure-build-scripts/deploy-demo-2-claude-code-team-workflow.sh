#!/usr/bin/env bash
# deploy-demo-2-claude-code-team-workflow.sh
#
# Bootstraps a throwaway repo in /tmp that demonstrates a Claude Code
# team-shared configuration: CLAUDE.md hierarchy, .claude/rules/ with
# glob-scoped rule loading, a /review slash command, a skill with
# context: fork, and a headless `claude -p` CI example with a JSON
# schema enforcing the output shape.
#
# Safe to re-run: it wipes the target directory first.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${DEMO2_TARGET_DIR:-/tmp/demo-2-team-workflow}"

echo "[demo-2] target directory: ${TARGET_DIR}"

if [[ -e "${TARGET_DIR}" ]]; then
  echo "[demo-2] removing existing ${TARGET_DIR} so we start clean"
  rm -rf "${TARGET_DIR}"
fi

mkdir -p "${TARGET_DIR}"

# Copy the checked-in scaffold into the target directory.  We intentionally
# use `cp -R` (not a symlink) so students can `cd` in and mutate files
# without touching the source of truth in this repo.
#
# NOTE: the source of truth stages the Claude Code config under
# `dot-claude/` (not `.claude/`) because this tutorial repo's sandbox
# blocks writes to dot-directories.  On deploy we rename it to
# `.claude/` so the bootstrapped project matches what students will
# have in a real repo.
cp    "${HERE}/CLAUDE.md"              "${TARGET_DIR}/CLAUDE.md"
cp    "${HERE}/schema.json"            "${TARGET_DIR}/schema.json"
cp -R "${HERE}/dot-claude"             "${TARGET_DIR}/.claude"
cp -R "${HERE}/example-project"        "${TARGET_DIR}/example-project"
cp -R "${HERE}/ci-example"             "${TARGET_DIR}/ci-example"

# Make the CI example executable.
chmod +x "${TARGET_DIR}/ci-example/review.sh"

# Initialize a git repo so Claude Code's CLAUDE.md discovery treats the
# project root correctly and so students can experiment with commits.
(
  cd "${TARGET_DIR}"
  git init -q
  git add -A
  git -c user.email="demo@example.com" \
      -c user.name="Demo Student" \
      commit -q -m "Bootstrap team workflow demo"
)

echo ""
echo "[demo-2] deployed. Next steps:"
echo "  1. cd ${TARGET_DIR}"
echo "  2. export ANTHROPIC_API_KEY=...   # only needed for the CI section"
echo "  3. claude                         # interactive walk-through"
echo "  4. ./ci-example/review.sh         # headless -p mode + JSON schema"
echo ""
echo "[demo-2] cleanup:"
echo "  ${HERE}/cleanup-demo-2-claude-code-team-workflow.sh"
