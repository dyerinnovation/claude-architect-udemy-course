# Demo: Multi-Agent Research Pipeline

**Section**: 11 | **Duration**: ~15 min | **Demo**: 4

---

## Overview

This demo designs and debugs a multi-agent research pipeline: a coordinator agent delegates to specialized subagents (web search, document analysis) running in parallel via multiple `Task` tool calls emitted in a single response. Each subagent returns structured findings that separate claim from evidence, source, and date. The synthesis step preserves provenance, a simulated subagent timeout exercises error propagation and coverage-gap annotation, and conflicting-source data proves that synthesis preserves both values with source attribution rather than arbitrarily picking one.

## Learning Objectives

By the end of this demo, you will be able to:

- Build a coordinator whose `allowedTools` includes `Task`, and pass research findings directly in each subagent's prompt instead of relying on automatic context inheritance.
- Emit multiple `Task` tool calls in a single coordinator response to run subagents in parallel, and measure latency improvement over sequential execution.
- Design structured subagent output that separates `claim`, `evidence`, `source_url`/`document_name`, and `publication_date`.
- Propagate errors when a subagent times out: capture failure type, attempted query, and partial results; continue with partial results and annotate coverage gaps.
- Handle conflicting source data in synthesis - preserve both values with source attribution and distinguish well-established from contested findings.

## Claude Surfaces Used

- **Claude Agent SDK** - subagent spawning via the `Task` tool, `allowedTools` configuration, parallel tool calls in a single response.
- **Claude API** - `messages.create` driving both the coordinator and each subagent.

## Domains Reinforced

| Domain | % | How this demo tests it |
|---|---|---|
| Domain 1: Agentic Architecture & Orchestration | 22% | Coordinator-subagent pattern, explicit context passing, parallel `Task` calls, synthesis with provenance. |
| Domain 2: Tool Design & MCP Integration | 20% | `Task`-tool-based subagent delegation and structured output (claim/evidence/source/date). |
| Domain 5: Context Management & Reliability | 18% | Error propagation on subagent timeout, coverage-gap annotation, conflicting-source handling. |

## Quick Start

### Deploy

```bash
cd demo-4-multi-agent-research-pipeline-infrastructure-build-scripts
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt   # anthropic, pydantic
export ANTHROPIC_API_KEY=...
python research_coordinator.py --question "What are the trade-offs of X vs Y?"
```

### Record

Follow `demo-4-multi-agent-research-pipeline-recording-script.md` for timestamped narration.

### Cleanup

```bash
deactivate
rm -rf .venv ./research-output
```

## Additional Resources

- Anthropic Exam Guide, *Preparation Exercises* - Exercise 4.
- Anthropic Exam Guide, *Technologies and Concepts* - Claude Agent SDK (subagent spawning via `Task`, `allowedTools`), in-scope topics on multi-agent orchestration and information provenance.
- Anthropic docs - [Building effective agents](https://www.anthropic.com/research/building-effective-agents) and Agent SDK subagent guidance.
