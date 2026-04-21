# Demo: Multi-Agent Research Pipeline

- **Module/Section:** Section 11 — Demo 4
- **Duration:** ~8–10 min
- **Scenario:** Multi-Agent Research System (Exam Scenario 3)
- **Preparation Exercise:** Exercise 4 from the official Anthropic exam guide

---

## Overview

Single-context research agents degrade fast. Hand one agent a broad research question — "How do LLM agent memory architectures compare?" — and watch it drift: the context window fills with half-relevant search snippets, earlier findings get buried in the middle, and by the time the model writes the report it is confidently summarizing sources it can barely still see. The architectural answer is hub-and-spoke: a coordinator decomposes the question, spawns isolated-context subagents in parallel, and aggregates structured handoffs back into a single provenance-annotated report.

In this demo you will watch that pattern run end-to-end. A coordinator takes a research question, decomposes it into three focused sub-questions, and dispatches three subagents in parallel — each with its own private messages list so findings can't leak sideways. Each subagent returns a structured JSON handoff: a list of claims, each with a source URL and confidence score. The coordinator aggregates those handoffs into a final report that maps every single claim back to the subagent and source that produced it. When two subagents disagree about the same fact, the pipeline flags the conflict rather than silently picking one.

The point of the demo is not just "parallel is faster." The point is that context isolation plus structured handoffs plus explicit provenance is the production pattern — and it is exactly what Domain 1 (Agentic Architecture, 27%) and Domain 5 (Context Management & Reliability, 15%) ask you to design on exam day.

## Learning Objectives

By the end of this demo, you will be able to:

- Design a hub-and-spoke coordinator-subagent architecture and explain why it outperforms a single long-context research agent on broad questions.
- Use the Task tool (or a parallel-API-call fallback) to spawn multiple subagents from a single coordinator step.
- Enforce context isolation — give each subagent its own messages list so sibling findings do not leak across spokes.
- Pass context explicitly into each subagent's opening prompt rather than relying on automatic inheritance.
- Aggregate subagent handoffs into a final report with claim-to-source provenance mapping and explicit conflict flags.

## Claude Surfaces Used

- **Claude Agent SDK** — coordinator loop, subagent spawning, `allowedTools` scoping, `stop_reason` control flow.
- **Task tool** — the SDK-native primitive for launching an isolated-context subagent. When demonstrated in code we use `concurrent.futures.ThreadPoolExecutor` with parallel Messages-API calls as a reproducible stand-in; the production approach is the Task tool and that is called out in code comments.
- **`stop_reason` handling** — coordinator's agentic loop inspects `tool_use` vs `end_turn` to decide when to dispatch subagents and when to synthesize.
- **Structured output via JSON schema** — each subagent emits a handoff that validates against `schemas/subagent_handoff.json`; the coordinator emits a report that validates against `schemas/final_report.json`.

## Exam Domains Reinforced

| Domain | Weight | How this demo tests it |
|---|---|---|
| Domain 1: Agentic Architecture & Orchestration | 27% | Coordinator-subagent pattern, task decomposition, parallel subagent execution, `stop_reason`-driven agentic loop. |
| Domain 5: Context Management & Reliability | 15% | Subagent context isolation, explicit context passing, claim-source provenance mapping, conflict flagging. |

## Prerequisites

- Python 3.10+ (Agent SDK requirement).
- Anthropic API key exported as `ANTHROPIC_API_KEY`.
- `pip install -r requirements.txt` — pulls `anthropic`, `pydantic`, `jsonschema`.
- Basic familiarity with the agentic loop (Section 2) and structured output via `tool_use` (Section 5).

## Quick Start

```bash
cd demo-4-multi-agent-research-pipeline-infrastructure-build-scripts

# Deploy (venv + deps)
./deploy-demo-4-multi-agent-research-pipeline.sh

# Activate and set API key
source .venv/bin/activate
cp .env.example .env   # then edit .env with your key
export $(grep -v '^#' .env | xargs)

# Run the pipeline on one of the sample questions
python research_pipeline.py --question "$(head -n1 sample-questions.txt)"

# Cleanup when done
./cleanup-demo-4-multi-agent-research-pipeline.sh
```

The pipeline writes its final report to `./research-output/report-<timestamp>.json` and prints a human-readable summary to stdout.

## File Structure

```
demo-4-multi-agent-research-pipeline/
├── README.md                                                  # this file
├── demo-4-multi-agent-research-pipeline-recording-script.md   # 8-10 min timestamped OBS script
└── demo-4-multi-agent-research-pipeline-infrastructure-build-scripts/
    ├── README.md                                              # code walkthrough + ASCII architecture
    ├── deploy-demo-4-multi-agent-research-pipeline.sh         # venv + pip install
    ├── cleanup-demo-4-multi-agent-research-pipeline.sh        # tear down venv + output dir
    ├── research_pipeline.py                                   # coordinator + subagents
    ├── requirements.txt
    ├── sample-questions.txt                                   # 3 research questions to try
    ├── .env.example
    └── schemas/
        ├── subagent_handoff.json                              # per-subagent return schema
        └── final_report.json                                  # coordinator output schema
```

## Additional Resources

- Anthropic Exam Guide, *Preparation Exercises* — Exercise 4 (Design and Debug a Multi-Agent Research Pipeline).
- Anthropic Exam Guide, *Scenario 3* — Multi-Agent Research System.
- Anthropic blog — [Building effective agents](https://www.anthropic.com/research/building-effective-agents) (orchestrator-workers pattern).
- Anthropic Agent SDK docs — subagent spawning via the Task tool, `allowedTools`, `stop_reason` control flow.
