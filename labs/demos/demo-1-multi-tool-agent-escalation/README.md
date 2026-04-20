# Demo: Multi-Tool Agent with Escalation Logic

**Section**: 8 | **Duration**: ~15 min | **Demo**: 1

---

## Overview

This demo walks through designing an agentic loop with tool integration, structured error handling, and escalation patterns. You will see how 3-4 MCP tools with carefully written descriptions drive a Claude agent that reads `stop_reason` to decide whether to keep calling tools or finalize the response, and how a programmatic hook can intercept tool calls to enforce business rules and route work to an escalation workflow.

## Learning Objectives

By the end of this demo, you will be able to:

- Define MCP tools with descriptions that disambiguate similar-purpose tools and prevent selection confusion.
- Implement an agentic loop that branches on `stop_reason` (`tool_use` vs `end_turn`) to control continuation.
- Return structured error responses (`errorCategory` = transient/validation/permission, `isRetryable`, human-readable message) so the agent can react correctly.
- Install a `PostToolUse`/pre-execution hook that blocks operations above a business threshold and redirects to an escalation workflow.
- Decompose a multi-concern user message into sub-tasks, resolve each, and synthesize a unified final response.

## Claude Surfaces Used

- **Claude API** — `messages.create` with `tools`, `stop_reason`-driven loop, `tool_choice`.
- **MCP** — Tool definitions via `.mcp.json` style servers (in this demo, local tool functions that mirror the MCP shape).
- **Claude Agent SDK** — Programmatic hook pattern (tool-call interception) to enforce escalation policy.

## Domains Reinforced

| Domain | % | How this demo tests it |
|---|---|---|
| Domain 1: Agentic Architecture & Orchestration | 22% | Implements a complete agentic loop driven by `stop_reason` with multi-concern decomposition. |
| Domain 2: Tool Design & MCP Integration | 20% | Four tools with disambiguated descriptions plus structured error envelopes (transient / validation / permission, `isRetryable`). |
| Domain 5: Context Management & Reliability | 18% | Error handling, retry-vs-explain branching, and hook-based escalation for policy gaps. |

## Quick Start

### Deploy

```bash
cd demo-1-multi-tool-agent-escalation-infrastructure-build-scripts
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt   # anthropic, pydantic
export ANTHROPIC_API_KEY=...
python customer_support_agent.py  # starts the agentic loop
```

### Record

Follow `demo-1-multi-tool-agent-escalation-recording-script.md` for timestamped narration.

### Cleanup

```bash
deactivate
rm -rf .venv
```

## Additional Resources

- Anthropic Exam Guide, *Preparation Exercises* - Exercise 1.
- Anthropic Exam Guide, *Technologies and Concepts* - Claude Agent SDK (stop_reason handling, hooks).
- Anthropic API docs - [Tool use overview](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview).
- MCP spec - `isError` flag and structured tool error conventions.
