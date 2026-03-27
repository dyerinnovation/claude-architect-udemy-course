# Claude Certified Architect – Foundations: Complete Certification Prep

## Course Overview

The definitive Udemy course for passing the **Anthropic Claude Certified Architect – Foundations (CCA-F)** exam. Built by someone who took the exam, documented every question pattern, and reverse-engineered the exam's decision frameworks — not just someone who read the docs.

This course covers all 5 exam domains weighted by their actual exam importance, walks through all 6 exam scenarios, and teaches you the judgment patterns the exam actually tests — not just feature trivia.

## Target Audience

- **Solution architects** designing production AI systems with Claude
- **Senior engineers** building agentic applications (Agent SDK, MCP, Claude Code)
- **Technical leads** evaluating Claude for enterprise adoption
- **Anyone preparing** for the CCA-F certification exam

## Prerequisites

- Basic familiarity with LLM APIs (you've called Claude or GPT at least once)
- Some Python or TypeScript experience
- Willingness to build hands-on — this is not a slide-reading course

## Learning Objectives

By the end of this course, you will be able to:

1. **Design agentic architectures** using hub-and-spoke patterns, the Task tool, and programmatic enforcement — and know when NOT to over-engineer
2. **Write effective tool descriptions** and configure MCP servers that Claude selects reliably
3. **Configure Claude Code** for team workflows using CLAUDE.md hierarchy, path-scoped rules, skills, and CI/CD integration
4. **Engineer prompts** that produce structured, reliable output using tool_use, few-shot examples, and the Batches API
5. **Manage context** across long sessions and multi-agent systems without losing critical information
6. **Pass the CCA-F exam** by recognizing distractor patterns, applying the intervention hierarchy, and making the judgment calls the exam rewards

## Course Structure

| Section | Domain/Topic | Weight | Duration |
|---------|-------------|--------|----------|
| 1 | Course Intro & Exam Strategy | — | 30 min |
| 2 | Agentic Architecture & Orchestration | 27% | 3 hr |
| 3 | Tool Design & MCP Integration | 18% | 2 hr |
| 4 | Claude Code Configuration & Workflows | 20% | 2.5 hr |
| 5 | Prompt Engineering & Structured Output | 20% | 2.5 hr |
| 6 | Context Management & Reliability | 15% | 2 hr |
| 7 | Scenario Deep Dives | — | 1.5 hr |
| 8 | Practice Exam & Answer Review | — | 2 hr |
| 9 | Quick Reference & Final Review | — | 30 min |

**Total: ~16.5 hours of instruction + labs**

## Exam Alignment

- Covers all 5 domains per the official Anthropic exam guide (v0.1, Feb 2025)
- Walks through all 6 exam scenarios with scenario-to-domain mapping
- Includes 40-question practice exam weighted by domain
- Explains WHY distractors are wrong, not just which answer is right

## What Makes This Course Different

- **Real exam experience**: The instructor took the exam and documented the question patterns, trap answers, and decision frameworks
- **Practice exam notes**: Detailed analysis of every missed question with the reasoning hierarchy that resolves each one
- **Scenario-first approach**: You learn concepts through the 6 exam scenarios, the same way the exam tests them
- **Judgment over trivia**: The exam tests architectural judgment — this course teaches you how to think through tradeoffs, not memorize flags

## Downloadable Resources

- Domain weight cheat sheet
- Scenario-to-domain mapping table
- `tool_choice` options quick reference
- CLAUDE.md hierarchy diagram
- Error response required fields checklist
- Escalation decision flowchart
- Batch API vs synchronous API decision table
- `stop_reason` loop control flow diagram
- Built-in tool selection guide (Grep vs Glob vs Read vs Edit)

## Lab Prerequisites

- Anthropic API key with Claude access
- Node.js 18+ or Python 3.10+ environment
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- Basic familiarity with JSON schema syntax
