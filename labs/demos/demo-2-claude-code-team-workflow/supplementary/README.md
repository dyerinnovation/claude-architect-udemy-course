# Supplementary — Deep-Dive CI Patterns

These directories are **extensions**, not part of the core 7–9 minute
demo.  The primary demo covers the four exam-tested knobs (CLAUDE.md
hierarchy, `.claude/rules/` globs, slash commands, skills with
`context: fork`) and a minimal `claude -p` CI example.  The two
extensions here go further for anyone who wants to see a production-
shaped pipeline.

Skip them for the Udemy recording; reach for them when you are
actually building this for your own team.

## `ci-cd-pipeline/`

A fuller CI/CD example: how the same team-workflow config plugs into
a real pipeline.  Covers GitHub Actions job design, secrets
management for `ANTHROPIC_API_KEY`, caching strategies for `claude`
invocations, and rollout patterns (shadow mode → warn mode → block
mode) so the review gate can be introduced without blocking every
legitimate PR on day one.

Useful when you are asking: "how do I actually ship this review gate
in a team that already has a busy CI pipeline?"

## `ci-code-review/`

A richer code-review implementation: deeper prompt templates,
multi-file review strategies, issue-deduplication across runs,
confidence-score routing (low-confidence findings get human review
before being posted as PR comments), and schema-versioning so the
JSON contract can evolve without breaking existing jobs.

Useful when you are asking: "now that the gate runs, how do I make
its output trustworthy and sustainable as the team grows?"

## Exam framing

Neither extension introduces new Domain-3 surface area — the exam
tests the core knobs shown in the primary demo.  Both extensions sit
squarely inside Domain 3 territory (Claude Code for CI/CD is
explicitly listed under Scenario 5) but they are more about
production hardening than exam prep.

If your goal is to pass the exam, the primary demo is the priority.
If your goal is to ship this on Monday, spend time in these two
directories.
