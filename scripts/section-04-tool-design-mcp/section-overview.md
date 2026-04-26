# Section 6: Domain 2 — Tool Design & MCP Integration (18%)

## Overview
- **Domain**: Domain 2: Tool Design & MCP Integration
- **Exam Weight**: 18%
- **Lecture Count**: 14 lectures
- **Estimated Duration**: ~2 hours

## Learning Objectives

By the end of this section, students will be able to:
- Design tool descriptions that drive correct selection — covering inputs, examples, boundaries, and the split-vs-consolidate decision for similar tools.
- Implement structured MCP error responses with `errorCategory`, `isError`, and `isRetryable`, and decide between local recovery and propagation to the coordinator.
- Apply `tool_choice` (`"auto"`, `"any"`, forced) and tool-distribution heuristics to keep agent toolsets focused and selectable.
- Configure MCP servers at the correct scope (project vs. user) using `.mcp.json` with environment variable expansion, and choose between MCP resources and MCP tools.
- Evaluate built-in Claude Code tools (Grep, Glob, Read, Edit) and apply incremental codebase exploration patterns.

## Lectures

| # | Title | Duration | Status |
|---|-------|----------|--------|
| 6.1 | Why Tool Descriptions Are the Most Important Thing You Write | ~8 min | Todo |
| 6.2 | What Makes a Great Tool Description (inputs, examples, boundaries) | ~8 min | Todo |
| 6.3 | Diagnosing and Fixing Tool Selection Failures | ~8 min | Todo |
| 6.4 | Splitting Generic Tools vs Consolidating — When to Do Each | ~8 min | Todo |
| 6.5 | MCP Error Response Design: Categories, `isError`, `isRetryable` | ~8 min | Todo |
| 6.6 | Transient vs Validation vs Business vs Permission Errors | ~8 min | Todo |
| 6.7 | Local Recovery vs Propagating to Coordinator | ~8 min | Todo |
| 6.8 | Tool Distribution: How Many Tools Per Agent? | ~8 min | Todo |
| 6.9 | `tool_choice`: `"auto"`, `"any"`, Forced Selection | ~8 min | Todo |
| 6.10 | MCP Server Configuration: Project vs User Scope | ~8 min | Todo |
| 6.11 | `.mcp.json` with Environment Variable Expansion | ~8 min | Todo |
| 6.12 | MCP Resources vs MCP Tools — When to Use Each | ~8 min | Todo |
| 6.13 | Built-in Tool Selection: Grep vs Glob vs Read vs Edit | ~8 min | Todo |
| 6.14 | Incremental Codebase Exploration Pattern | ~8 min | Todo |

## Quiz

Section quiz: `quizzes/section-06-tool-design-mcp.md` (10 questions)
