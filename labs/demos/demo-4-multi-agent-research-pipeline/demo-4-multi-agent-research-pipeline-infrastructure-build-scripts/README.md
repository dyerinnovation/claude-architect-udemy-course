# Demo 4 — Infrastructure & Code Walkthrough

This directory contains the runnable implementation of the Multi-Agent Research Pipeline demo (Section 11, Demo 4).

## Architecture

```
                            ┌───────────────────────────────┐
                            │        COORDINATOR (hub)      │
       research question ──▶│  1. decompose → N sub-Qs      │
                            │  2. dispatch N subagents      │
                            │  3. aggregate handoffs        │
                            │  4. flag conflicts + gaps     │
                            └────┬──────┬─────────┬─────────┘
                                 │      │         │            parallel dispatch
                                 ▼      ▼         ▼           (ThreadPoolExecutor
                         ┌───────────┐ ┌──────────┐ ┌──────────┐  in demo; Task tool
                         │subagent-1 │ │subagent-2│ │subagent-3│  in production SDK)
                         │           │ │          │ │          │
                         │ PRIVATE   │ │ PRIVATE  │ │ PRIVATE  │  <-- context isolation
                         │ messages[]│ │messages[]│ │messages[]│      (Domain 5)
                         └─────┬─────┘ └────┬─────┘ └────┬─────┘
                               │            │            │
                               │ emit_handoff tool_use   │
                               ▼            ▼            ▼
                      ┌─────────────────────────────────────────┐
                      │   structured handoffs (JSON-schema)     │
                      │   { subagent_id, sub_question,          │
                      │     coverage, claims: [{                │
                      │       text, source_url, confidence,     │
                      │       entity                            │
                      │     }] }                                │
                      └─────────────────────┬───────────────────┘
                                            │
                                            ▼
                            ┌───────────────────────────────┐
                            │      final_report.json        │
                            │  claims[] with provenance:    │
                            │    text + subagent_id +       │
                            │    source_url + confidence    │
                            │  conflicts[] (deferred)       │
                            │  coverage_gaps[]              │
                            └───────────────────────────────┘
```

## Exam-anchor mapping

| Pattern in code | Where | Domain |
|---|---|---|
| Coordinator decomposes 1 broad question into N focused sub-questions | `coordinator_decompose()` | 1 (task decomposition) |
| Explicit `stop_reason == "tool_use"` check in coordinator loop | `coordinator_decompose()` | 1 (agentic loop / stop_reason handling) |
| Parallel subagent dispatch from a single coordinator step | `spawn_subagents_parallel()` | 1 (parallel subagent execution) |
| Each subagent runs with its own private `messages` list | `run_subagent()` | 1 + 5 (context isolation) |
| Sub-question passed into the subagent's opening prompt | `run_subagent()` | 5 (explicit context passing) |
| Structured handoff validated against `schemas/subagent_handoff.json` | `run_subagent()` | 5 (reliable structured handoffs) |
| Every claim in `final_report.json` carries subagent_id + source_url | `aggregate_report()` | 5 (claim-source provenance) |
| Conflicting claims flagged, resolution=`deferred_to_user` | `detect_conflicts()` | 5 (conflict annotation, not silent resolution) |
| Coverage gaps explicitly listed when a subagent returns no claims | `aggregate_report()` | 5 (coverage-gap reporting) |

## File inventory

| File | Purpose |
|---|---|
| `research_pipeline.py` | End-to-end coordinator + subagent implementation. |
| `schemas/subagent_handoff.json` | JSON Schema for every subagent's return payload. |
| `schemas/final_report.json` | JSON Schema for the coordinator's aggregated report. |
| `sample-questions.txt` | 3 research questions to exercise decomposition, provenance, and conflicts. |
| `requirements.txt` | Pinned dependencies (`anthropic`, `pydantic`, `jsonschema`). |
| `.env.example` | Template environment file. Copy to `.env` and set `ANTHROPIC_API_KEY`. |
| `deploy-demo-4-multi-agent-research-pipeline.sh` | Creates venv, installs deps, scaffolds `.env` and output dir. |
| `cleanup-demo-4-multi-agent-research-pipeline.sh` | Removes venv and per-run output. |

## Run

```bash
bash deploy-demo-4-multi-agent-research-pipeline.sh
source .venv/bin/activate
# edit .env and set ANTHROPIC_API_KEY
export $(grep -v '^#' .env | xargs)
python research_pipeline.py --question "$(head -n1 sample-questions.txt)"
```

Per-subagent handoffs are written to `./research-output/handoff-subagent-N.json` and the aggregated report lands at `./research-output/report-<utc-stamp>.json`.

## Production vs demo — Task tool fallback

On the Claude Agent SDK the coordinator would spawn each subagent by emitting a `Task` tool_use block; the SDK runtime creates the isolated-context worker and schedules it. For reproducibility without pinning to a specific SDK version, `spawn_subagents_parallel()` uses `concurrent.futures.ThreadPoolExecutor` to run three parallel `messages.create` calls, each with its own `messages` list. The architectural properties the exam cares about are preserved: parallelism, isolated per-subagent context, and explicit context passing. The code flags the production-vs-demo substitution with `# PRODUCTION vs DEMO:` comments at the relevant lines.

## Documented failure mode — conflicting claims

When two subagents produce claims tagged with the same `entity` but different normalized text, `detect_conflicts()` emits a `conflicts` entry in the final report listing all competing claims with their `subagent_id`, `source_url`, and `confidence`, and sets `resolution: "deferred_to_user"`. The pipeline never silently collapses disagreements. An optional upgrade would swap in a Claude-based conflict-adjudication subagent and set `resolution: "highest_confidence_preferred"`; the schema already supports that value.

## Extension ideas (out of scope for the 8-10 min demo recording)

- Swap the ThreadPoolExecutor for the real Agent SDK Task tool once pinning is stable.
- Give subagents real retrieval tools (web_search, fetch_url) so claims come from live sources.
- Add a conflict-adjudication subagent that resolves `deferred_to_user` conflicts into a reasoned choice.
- Persist a coordinator state manifest for crash recovery mid-run (Domain 1 crash-recovery topic).
