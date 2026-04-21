# Demo: Multi-Tool Agent with Escalation

- **Module/Section:** Section 8 — Demo 1
- **Duration:** ~6–8 min

---

## Overview

This demo walks through a runnable multi-tool customer-support agent that routes between four specialized tools, reads `stop_reason` to drive its own loop, and hands off to a human when the request is ambiguous or out of policy. The goal is to show the agentic loop as a real control-flow pattern rather than a diagram — one iteration ends with `stop_reason == "tool_use"` and the loop continues, the next ends with `end_turn` and the loop exits. Along the way, we exercise tool-description boundary-setting ("Do NOT use for...") and a structured escalation handoff that preserves context for the downstream human.

The agent models the customer-support scenario from the official Anthropic exam guide's Preparation Exercise 1. It demonstrates the failure mode the exam tests: when a tool's description overlaps with another, or when a refund exceeds business policy, the agent must pick `escalate_to_human` and return a structured summary the human can act on — rather than forcing a decision it shouldn't make. We run two requests back-to-back: a happy-path "simple refund" that the agent resolves with `lookup_order` + `process_refund`, and an edge case ("I need a $2,400 refund on a six-month-old order I can't find") that triggers escalation.

By the end of the demo, students will have seen the three concepts Domain 1 (27%) anchors on — `stop_reason`-driven control flow, tool-boundary disambiguation, and structured escalation handoff — in under 100 lines of production-shaped code they can copy into their own projects.

## Learning Objectives

By the end of this demo, you will be able to:

1. **Implement a `stop_reason`-driven agentic loop** that continues on `tool_use` and exits on `end_turn` (Domain 1, Task 1.1: agentic control flow).
2. **Write tool descriptions with explicit boundaries** ("Do NOT use for...") to prevent selection confusion between overlapping tools (Domain 2, Task 2.2: tool-description design).
3. **Design an `escalate_to_human` handoff tool** that returns a structured summary — customer, issue, attempted steps, recommended action — so a downstream human can resolve without re-interviewing the customer (Domain 1, Task 1.5: escalation patterns).
4. **Trigger and observe escalation deterministically** by sending a deliberately ambiguous or out-of-policy request, and read the tool-call transcript to verify the agent chose escalation over guessing (Domain 1, Task 1.2: task decomposition).
5. **Recognize the context packet an escalation must include** to preserve state across the human handoff — prior tool results, conversation summary, and a clear "recommended action" field (Domain 5, Task 5.3: context passing & handoff).

## Claude Surfaces Used

- **Claude Messages API** — `messages.create` with a `tools` list of four tool schemas.
- **Tool-use loop** — `stop_reason` branching (`tool_use` → continue; `end_turn` → exit), with `tool_result` content blocks appended back into the `messages` history each turn.
- **Claude Agent SDK patterns** — structured escalation tool modeling the "handoff summary" pattern students will see again in Demo 4's multi-agent pipeline.
- **Model:** `claude-sonnet-4-5` (or later Sonnet 4.x, pinned in `agent.py`).

## Exam Domains Reinforced

| Domain | Weight | Justification |
|---|---|---|
| **Domain 1: Agentic Architecture & Orchestration** | 27% | Implements a complete `stop_reason`-driven loop with explicit `tool_use`/`end_turn` branching. Includes task decomposition for multi-issue requests and an escalation hand-off — the three anchor concepts Domain 1 is built on. |
| **Domain 2: Tool Design & MCP Integration** | 18% | Demonstrates tool-description disambiguation: `process_refund` and `escalate_to_human` have overlapping surface area, and the agent uses the "Do NOT use for..." boundary text in each description to select correctly. |
| **Domain 5: Context Management & Reliability** | 15% | The escalation tool returns a structured handoff packet (customer, issue summary, attempted steps, recommended action) so context survives the human handoff rather than being lost. |

## Prerequisites

- **Python 3.10+** (the agent uses type hints and the `anthropic` SDK).
- **Anthropic API key** — get one at [console.anthropic.com](https://console.anthropic.com/). Export as `ANTHROPIC_API_KEY`.
- **Terminal** with `bash` or `zsh` and `python3` available.
- **~$0.01 of API credit** — one full demo run (both scenarios) costs well under a cent against Sonnet 4.5.

## Quick Start

### Deploy

```bash
cd demo-1-multi-tool-agent-escalation-infrastructure-build-scripts
bash deploy-demo-1-multi-tool-agent-escalation.sh
source .venv/bin/activate
export ANTHROPIC_API_KEY=sk-ant-...        # or copy .env.example → .env
python agent.py --scenario happy-path       # simple refund, ~3 turns
python agent.py --scenario edge-case        # ambiguous → escalation
```

### Record

Follow `demo-1-multi-tool-agent-escalation-recording-script.md` for timestamped narration. Keep two terminal panes visible: the left shows `agent.py` source, the right shows the live tool-call transcript as it streams.

### Cleanup

```bash
bash cleanup-demo-1-multi-tool-agent-escalation.sh
```

This deactivates and removes the `.venv`. No cloud resources to tear down.

## File Structure

```
demo-1-multi-tool-agent-escalation/
├── README.md                                                   # this file
├── demo-1-multi-tool-agent-escalation-recording-script.md      # timestamped narration
└── demo-1-multi-tool-agent-escalation-infrastructure-build-scripts/
    ├── README.md                                               # one-page code walk-through
    ├── agent.py                                                # runnable multi-tool agent (~230 lines)
    ├── requirements.txt                                        # pinned deps (anthropic==0.40.0)
    ├── .env.example                                            # ANTHROPIC_API_KEY=
    ├── deploy-demo-1-multi-tool-agent-escalation.sh            # creates venv + installs deps
    └── cleanup-demo-1-multi-tool-agent-escalation.sh           # removes venv
```

## Additional Resources

- [Anthropic Tool Use Overview](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview) — canonical reference for the `tool_use` / `tool_result` loop and `stop_reason` values.
- [How to implement tool use](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/implement-tool-use) — the specific `while` loop pattern this demo's `agent.py` is shaped after.
- [Tool description best practices](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview#tool-use-best-practices) — where the "Do NOT use for..." boundary pattern comes from.
- [Anthropic Exam Guide — Preparation Exercise 1](../../../resources/anthropic-exam-guide.md) — the five-step exercise this demo is the reference solution for.
- [Claude Agent SDK — Building Effective Agents](https://www.anthropic.com/research/building-effective-agents) — the "orchestrator-workers" and "routing" patterns this demo uses.
