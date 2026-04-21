#!/usr/bin/env bash
# ci-example/review.sh
#
# Headless Claude Code invocation for a CI code-review gate.  This is
# the exact shape you would use in a GitHub Actions job: produce a PR
# diff, feed it to `claude -p`, and constrain the response shape with
# --json-schema so the downstream step can branch on `status` and
# iterate over `issues[]` without parsing prose.
#
# Prerequisites:
#   - ANTHROPIC_API_KEY exported in the environment (use CI secrets in a
#     real pipeline, never commit the key).
#   - `claude` on PATH.
#   - `jq` on PATH (only used for the pretty-print at the end).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${HERE}/.." && pwd)"
SCHEMA="${REPO_ROOT}/schema.json"

: "${ANTHROPIC_API_KEY:?ANTHROPIC_API_KEY must be set}"

# In a real pipeline this would be `git diff origin/main...HEAD`.  For
# the demo we review a single file so the recording stays deterministic.
TARGET_FILE="${1:-example-project/src/api/handler.ts}"
DIFF="$(cd "${REPO_ROOT}" && git --no-pager diff HEAD~0 -- "${TARGET_FILE}" 2>/dev/null || true)"
if [[ -z "${DIFF}" ]]; then
  # No diff (fresh bootstrap) — fall back to reviewing the file itself.
  DIFF="$(cat "${REPO_ROOT}/${TARGET_FILE}")"
fi

PROMPT="You are running as a non-interactive CI reviewer for the Acme Commerce API.
Review the following change against the project CLAUDE.md and any rule files
whose glob matches the target path.  Respond as JSON that conforms to the
schema provided via --json-schema.  Do not include any prose outside the JSON.

Target file: ${TARGET_FILE}

--- BEGIN CHANGE ---
${DIFF}
--- END CHANGE ---"

# --output-format json    : single JSON object on stdout (no REPL framing).
# --json-schema <path>    : Claude Code retries internally until stdout validates.
# --append-system-prompt  : ensures the reviewer persona sticks even though we are
#                           running headless and the interactive system prompt
#                           is absent.
claude -p "${PROMPT}" \
  --output-format json \
  --json-schema "${SCHEMA}" \
  --append-system-prompt "You are a strict, fair CI reviewer.  Prefer fewer, higher-signal issues over exhaustive nits."

# The CI job would then parse the JSON.  For the demo, pretty-print it
# so viewers can see the shape:
echo "--- last response (pretty) ---"
claude -p "${PROMPT}" \
  --output-format json \
  --json-schema "${SCHEMA}" \
  --append-system-prompt "You are a strict, fair CI reviewer.  Prefer fewer, higher-signal issues over exhaustive nits." \
  | jq '.'
