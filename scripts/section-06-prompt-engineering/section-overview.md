# Section 5: Domain 4 — Prompt Engineering & Structured Output (20%)

## Overview
- **Domain**: Domain 4: Prompt Engineering & Structured Output
- **Exam Weight**: 20%
- **Lecture Count**: 15 lectures
- **Estimated Duration**: ~2.5 hours

## Learning Objectives

By the end of this section, students will be able to:
- Design prompts that use explicit criteria and well-chosen few-shot examples to reduce false positives in review tasks.
- Implement reliable structured output with `tool_use`, JSON Schemas, and `tool_choice`, including required, optional, nullable, and enum-with-`"other"` fields.
- Distinguish syntax errors that tool use eliminates from semantic errors it does not, and decide when validation-retry loops will and will not converge.
- Match API choice to workload: use the Message Batches API for asynchronous savings (50%, 24-hour window) and the synchronous API for latency-bound paths.
- Architect multi-instance and multi-pass review pipelines (per-file plus cross-file integration) to improve accuracy on large code or document corpora.

## Lectures

| # | Title | Duration | Status |
|---|-------|----------|--------|
| 5.1 | Explicit Criteria vs Vague Instructions — Why It Matters | ~8 min | Todo |
| 5.2 | Designing Review Prompts That Reduce False Positives | ~8 min | Todo |
| 5.3 | Few-Shot Prompting: When and How to Use It | ~8 min | Todo |
| 5.4 | Crafting Few-Shot Examples for Ambiguous Scenarios | ~8 min | Todo |
| 5.5 | `tool_use` with JSON Schemas — The Most Reliable Structured Output | ~8 min | Todo |
| 5.6 | `tool_choice` for Guaranteed Structured Output | ~8 min | Todo |
| 5.7 | Schema Design: Required, Optional, Nullable, Enum + `"other"` | ~8 min | Todo |
| 5.8 | Syntax Errors vs Semantic Errors — What Tool Use Does and Doesn't Solve | ~8 min | Todo |
| 5.9 | Validation-Retry Loops: When They Work and When They Don't | ~8 min | Todo |
| 5.10 | The `detected_pattern` Field for False Positive Analysis | ~8 min | Todo |
| 5.11 | The Message Batches API: 50% Savings, 24-Hour Window, Limitations | ~8 min | Todo |
| 5.12 | Matching API Choice to Latency Requirements | ~8 min | Todo |
| 5.13 | Batch Failure Handling with `custom_id` | ~8 min | Todo |
| 5.14 | Multi-Instance Review Architecture | ~8 min | Todo |
| 5.15 | Multi-Pass Review: Per-File + Cross-File Integration Pass | ~8 min | Todo |

## Quiz

Section quiz: `quizzes/section-05-prompt-engineering.md` (10 questions)
