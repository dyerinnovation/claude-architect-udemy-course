# Claude Certified Architect – Foundations: Udemy Course Outline

## Course Overview

**Title**: Claude Certified Architect – Foundations: Complete Certification Prep
**Target audience**: Solution architects, senior engineers building production AI applications with Claude
**Prerequisites**: Basic familiarity with LLM APIs; some Python or TypeScript
**Exam alignment**: Covers all 5 domains per the official Anthropic exam guide (v0.1, Feb 2025)

---

## Section 1: Course Introduction & Exam Strategy

### Lectures
1.1 Welcome & What You'll Learn
1.2 Exam Format Deep Dive — Multiple Choice, Scoring, Passing Threshold (720/1000)
1.3 The 5 Domains & Their Weights (Domain 1 = 27% — your biggest lever)
1.4 How to Use the 6 Scenarios — 4 Will Appear, Know All 6
1.5 Study Strategy for Tomorrow vs 2 Weeks Out
1.6 How to Navigate the Official Exam Guide

### Quiz: Exam Mechanics Check
- What is the passing score?
- How many scenarios appear on the exam?
- Is there a penalty for guessing?
- Which domain has the highest weight?

### Downloadable Resources
- Domain weight cheat sheet (1-page)
- Scenario-to-domain mapping table
- Official exam guide PDF

---

## Section 2: Domain 1 — Agentic Architecture & Orchestration (27%)

*The highest-weighted domain. Master this section first.*

### Lectures
2.1 The Agentic Loop: `stop_reason` Is Everything
2.2 `"tool_use"` vs `"end_turn"` — Control Flow Patterns
2.3 Anti-Patterns: What NOT to Do in Agentic Loops
2.4 Multi-Agent Hub-and-Spoke Architecture
2.5 The Coordinator's Role: Decompose, Delegate, Aggregate
2.6 Subagent Context Isolation — Why They Don't Inherit History
2.7 The `Task` Tool: Spawning Subagents + `allowedTools` Requirement
2.8 Parallel Subagent Execution — Single Response, Multiple Task Calls
2.9 Explicit Context Passing Between Agents
2.10 Programmatic Enforcement vs Prompt-Based Guidance
2.11 Agent SDK Hooks: `PostToolUse` and Tool Call Interception
2.12 Task Decomposition: Prompt Chaining vs Dynamic Adaptive
2.13 Session Management: `--resume`, `fork_session`, When to Start Fresh
2.14 Structured Handoff Summaries for Human Escalation

### Scenario Lab: Customer Support Resolution Agent
- Build: coordinator agent + `get_customer`, `lookup_order`, `process_refund`, `escalate_to_human` tools
- Implement programmatic prerequisite blocking `process_refund` until `get_customer` resolves
- Add `PostToolUse` hook to normalize heterogeneous tool response formats
- Test: multi-concern customer request → parallel investigation → unified resolution

### Scenario Lab: Multi-Agent Research Pipeline
- Build: coordinator + web search + document analysis + synthesis + report generation subagents
- Implement parallel subagent spawning (single coordinator response)
- Design structured claim-source mappings in subagent outputs
- Debug: overly narrow task decomposition

### Quiz: Domain 1
- What does `allowedTools` need to include for a coordinator to spawn subagents?
- When should you use programmatic enforcement vs prompt instructions for workflow ordering?
- How do you spawn parallel subagents — in one response or multiple turns?
- What is the risk of overly narrow task decomposition?
- When should you start a new session vs resume an existing one?

---

## Section 3: Domain 2 — Tool Design & MCP Integration (18%)

### Lectures
3.1 Why Tool Descriptions Are the Most Important Thing You Write
3.2 What Makes a Great Tool Description (inputs, examples, boundaries)
3.3 Diagnosing and Fixing Tool Selection Failures
3.4 Splitting Generic Tools vs Consolidating — When to Do Each
3.5 MCP Error Response Design: Categories, `isError`, `isRetryable`
3.6 Transient vs Validation vs Business vs Permission Errors
3.7 Local Recovery vs Propagating to Coordinator
3.8 Tool Distribution: How Many Tools Per Agent?
3.9 `tool_choice`: `"auto"`, `"any"`, Forced Selection
3.10 MCP Server Configuration: Project vs User Scope
3.11 `.mcp.json` with Environment Variable Expansion
3.12 MCP Resources vs MCP Tools — When to Use Each
3.13 Built-in Tool Selection: Grep vs Glob vs Read vs Edit
3.14 Incremental Codebase Exploration Pattern

### Hands-on Lab: MCP Tool Design Workshop
- Write descriptions for three similar tools; identify and eliminate overlap
- Implement structured error responses with all required fields
- Configure a shared MCP server in `.mcp.json` with `${API_TOKEN}` expansion
- Configure a personal MCP server in `~/.claude.json`
- Test tool selection reliability with ambiguous queries

### Quiz: Domain 2
- What are the `tool_choice` options and when do you use each?
- What fields must a structured MCP error response include?
- What's the difference between project-scoped and user-scoped MCP server config?
- When should you use Grep vs Glob?
- What is the correct scope for shared team MCP servers?

---

## Section 4: Domain 3 — Claude Code Configuration & Workflows (20%)

### Lectures
4.1 The CLAUDE.md Configuration Hierarchy (user / project / directory)
4.2 What Gets Shared via Version Control and What Doesn't
4.3 The `@import` Syntax for Modular CLAUDE.md
4.4 `.claude/rules/` — Topic-Specific Rule Files
4.5 Path-Specific Rules with YAML Frontmatter Glob Patterns
4.6 Custom Slash Commands: `.claude/commands/` vs `~/.claude/commands/`
4.7 Skills in `.claude/skills/`: SKILL.md Frontmatter Deep Dive
4.8 `context: fork` — Isolating Skill Execution
4.9 `allowed-tools` and `argument-hint` Frontmatter Options
4.10 Plan Mode vs Direct Execution — Decision Framework
4.11 The Explore Subagent for Verbose Discovery Phases
4.12 Iterative Refinement Techniques (examples, TDD, interview pattern)
4.13 CI/CD Integration: `-p` Flag, `--output-format json`, `--json-schema`
4.14 Session Context Isolation for Independent Code Review
4.15 The `/memory` and `/compact` Commands

### Scenario Lab: Team Workflow Configuration
- Create project-level CLAUDE.md with testing conventions
- Create `.claude/rules/` file with glob-pattern scoping for test files (`**/*.test.tsx`)
- Create a project-scoped `/review` slash command
- Build a skill with `context: fork` and `allowed-tools` restriction
- Configure MCP server integration

### Scenario Lab: CI/CD Pipeline Integration
- Run Claude Code with `-p` flag in a simulated CI job
- Output structured JSON findings with `--output-format json --json-schema`
- Handle deduplication when re-running after new commits
- Configure CLAUDE.md for test generation context

### Quiz: Domain 3
- Where do project-scoped slash commands live?
- What does `context: fork` do in a SKILL.md file?
- When should you use plan mode vs direct execution?
- What does `.claude/rules/` with YAML frontmatter `paths:` enable?
- What flag is required to run Claude Code non-interactively in CI?

---

## Section 5: Domain 4 — Prompt Engineering & Structured Output (20%)

### Lectures
5.1 Explicit Criteria vs Vague Instructions — Why It Matters
5.2 Designing Review Prompts That Reduce False Positives
5.3 Few-Shot Prompting: When and How to Use It
5.4 Crafting Few-Shot Examples for Ambiguous Scenarios
5.5 `tool_use` with JSON Schemas — The Most Reliable Structured Output
5.6 `tool_choice` for Guaranteed Structured Output
5.7 Schema Design: Required, Optional, Nullable, Enum + `"other"`
5.8 Syntax Errors vs Semantic Errors — What Tool Use Does and Doesn't Solve
5.9 Validation-Retry Loops: When They Work and When They Don't
5.10 The `detected_pattern` Field for False Positive Analysis
5.11 The Message Batches API: 50% Savings, 24-Hour Window, Limitations
5.12 Matching API Choice to Latency Requirements
5.13 Batch Failure Handling with `custom_id`
5.14 Multi-Instance Review Architecture
5.15 Multi-Pass Review: Per-File + Cross-File Integration Pass

### Scenario Lab: Structured Data Extraction Pipeline
- Define extraction tool with JSON schema (required, optional, nullable fields)
- Use `tool_choice: "any"` for unknown document types
- Implement validation-retry loop with error feedback
- Add few-shot examples for varied document structures
- Batch 20 documents using Message Batches API; handle failures by `custom_id`

### Scenario Lab: CI Code Review Prompt Engineering
- Write explicit criteria (which issues to flag vs skip)
- Create 3 few-shot examples for ambiguous code patterns
- Define severity levels with concrete code examples
- Design multi-pass review: per-file + integration pass

### Quiz: Domain 4
- What does `tool_choice: "any"` guarantee?
- When should you use the Message Batches API vs synchronous API?
- What does tool use eliminate? What does it NOT eliminate?
- When is retry-with-feedback ineffective?
- Why is a second independent Claude instance better than self-review for code?

---

## Section 6: Domain 5 — Context Management & Reliability (15%)

### Lectures
6.1 The "Lost in the Middle" Effect — What It Means and How to Counter It
6.2 Progressive Summarization Risks — What Gets Lost
6.3 Trimming Verbose Tool Outputs
6.4 The Persistent "Case Facts" Block Pattern
6.5 Escalation Decision Framework — When to Escalate vs Resolve
6.6 Honoring Explicit Customer Requests for Human Agents
6.7 Sentiment vs Complexity — Why They're Not the Same
6.8 Structured Error Propagation Across Multi-Agent Systems
6.9 Access Failure vs Valid Empty Result
6.10 Coverage Annotations in Synthesis Output
6.11 Context Degradation in Long Sessions
6.12 Scratchpad Files for Cross-Context Persistence
6.13 Crash Recovery with Structured Agent State Manifests
6.14 Human Review Workflows and Confidence Calibration
6.15 Stratified Sampling for Accuracy Measurement
6.16 Information Provenance: Claim-Source Mappings
6.17 Handling Conflicting Sources — Annotate, Don't Arbitrarily Choose

### Scenario Lab: Customer Support Context Management
- Implement persistent "case facts" block extracted from tool outputs
- Add escalation criteria with few-shot examples
- Handle multiple customer matches requiring clarification
- Test policy ambiguity escalation trigger

### Scenario Lab: Research Pipeline Reliability
- Implement structured error propagation from failing subagent
- Add coverage gap annotations to synthesis output
- Design crash recovery using agent state manifests
- Require claim-source mappings in subagent outputs

### Quiz: Domain 5
- What is the "lost in the middle" effect?
- What should a structured error response from a subagent include?
- When should a customer support agent escalate immediately without attempting resolution?
- What is stratified random sampling used for in this context?
- How should conflicting statistics from two credible sources be handled in synthesis?

---

## Section 7: Scenario Deep Dives

*Scenario-by-scenario analysis of likely question patterns.*

### Lectures
7.1 Scenario 1: Customer Support Resolution Agent — Common Question Traps
7.2 Scenario 2: Code Generation with Claude Code — Key Decisions
7.3 Scenario 3: Multi-Agent Research System — Coordination Pitfalls
7.4 Scenario 4: Developer Productivity with Claude — Tool Design Focus
7.5 Scenario 5: Claude Code for CI/CD — Prompt Engineering Focus
7.6 Scenario 6: Structured Data Extraction — Schema & Batch Design
7.7 Cross-Domain Question Patterns — When Multiple Domains Overlap

### Resource: Scenario-to-Domain Matrix
Full breakdown of which task statements are most likely per scenario.

---

## Section 8: Practice Exam & Answer Review

### Lectures
8.1 Practice Exam Walkthrough — All 12 Sample Questions from Exam Guide
8.2 Understanding Why Distractors Are Wrong (not just why the answer is right)
8.3 Common Trap Patterns — Prompt vs Programmatic, Over-Engineering, Missing Root Cause
8.4 Final Exam Strategy: Time Management, Elimination Technique

### Full Practice Quiz
- 40 questions covering all 5 domains, scenario-weighted
- Detailed explanations for all answer choices
- Domain tagging for each question

---

## Section 9: Quick Reference & Final Review

### Lectures
9.1 The 20 Things You Must Know Cold
9.2 Out-of-Scope Topics — What to Ignore
9.3 Last-Hour Review Guide

### Downloadable Cheat Sheets
- `tool_choice` options quick reference
- CLAUDE.md hierarchy diagram
- Error response required fields checklist
- Escalation decision flowchart
- Batch API vs synchronous API decision table
- Domain weight breakdown
- `stop_reason` loop control flow diagram
- Built-in tool selection guide (Grep vs Glob vs Read vs Edit)

---

## Course Resource List

### Official Resources
- Claude Agent SDK documentation
- Model Context Protocol (MCP) specification
- Claude API reference (tool_use, tool_choice, stop_reason)
- Claude Code documentation (CLAUDE.md, .claude/ directory structure)
- Message Batches API documentation

### Supplementary
- Anthropic cookbook examples for agentic patterns
- Claude Code README on GitHub
- MCP community server registry

---

## Lab Prerequisites

Students will need:
- Anthropic API key with Claude access
- Node.js 18+ or Python 3.10+ environment
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- Basic familiarity with JSON schema syntax

---

## Course Completion Path

```
Section 1 (30 min) → Domain overview, exam strategy
Section 2 (3 hr)   → Domain 1: Agentic Architecture [HIGHEST WEIGHT - start here]
Section 3 (2 hr)   → Domain 2: Tool Design & MCP
Section 4 (2.5 hr) → Domain 3: Claude Code Config
Section 5 (2.5 hr) → Domain 4: Prompt Engineering
Section 6 (2 hr)   → Domain 5: Context & Reliability
Section 7 (1.5 hr) → Scenario deep dives
Section 8 (2 hr)   → Practice exam + review
Section 9 (30 min) → Final review + cheat sheets
```

**Total: ~16.5 hours of instruction + labs**

For exam-day cramming: Sections 9 → 8 → domain section for your weakest area.
