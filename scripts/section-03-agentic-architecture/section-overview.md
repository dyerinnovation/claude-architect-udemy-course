# Section 3: Domain 1 — Agentic Architecture & Orchestration (27%)

## Overview
- **Domain**: Domain 1: Agentic Architecture & Orchestration
- **Exam Weight**: 27%
- **Lecture Count**: 14 lectures
- **Estimated Duration**: ~3 hours

## Learning Objectives

By the end of this section, students will be able to:
- Design agentic loops driven by `stop_reason`, branching correctly between `"tool_use"` and `"end_turn"` and avoiding text-parsing anti-patterns.
- Architect hub-and-spoke multi-agent systems where a coordinator decomposes work, delegates via the `Task` tool with the required `allowedTools`, and aggregates results.
- Apply explicit context passing and parallel subagent execution patterns to overcome subagent context isolation.
- Distinguish programmatic enforcement from prompt-based guidance and select the right approach for compliance-critical workflows.
- Evaluate session management strategies (`--resume`, `fork_session`, fresh start) and craft structured handoff summaries for human escalation.

## Lectures

| # | Title | Duration | Status |
|---|-------|----------|--------|
| 3.1 | The Agentic Loop: `stop_reason` Is Everything | ~8 min | Todo |
| 3.2 | `"tool_use"` vs `"end_turn"` — Control Flow Patterns | ~8 min | Todo |
| 3.3 | Anti-Patterns: What NOT to Do in Agentic Loops | ~8 min | Todo |
| 3.4 | Multi-Agent Hub-and-Spoke Architecture | ~8 min | Todo |
| 3.5 | The Coordinator's Role: Decompose, Delegate, Aggregate | ~8 min | Todo |
| 3.6 | Subagent Context Isolation — Why They Don't Inherit History | ~8 min | Todo |
| 3.7 | The `Task` Tool: Spawning Subagents + `allowedTools` Requirement | ~8 min | Todo |
| 3.8 | Parallel Subagent Execution — Single Response, Multiple Task Calls | ~8 min | Todo |
| 3.9 | Explicit Context Passing Between Agents | ~8 min | Todo |
| 3.10 | Programmatic Enforcement vs Prompt-Based Guidance | ~8 min | Todo |
| 3.11 | Agent SDK Hooks: `PostToolUse` and Tool Call Interception | ~8 min | Todo |
| 3.12 | Task Decomposition: Prompt Chaining vs Dynamic Adaptive | ~8 min | Todo |
| 3.13 | Session Management: `--resume`, `fork_session`, When to Start Fresh | ~8 min | Todo |
| 3.14 | Structured Handoff Summaries for Human Escalation | ~8 min | Todo |

## Quiz

Section quiz: `quizzes/section-03-agentic-architecture.md` (10 questions)
