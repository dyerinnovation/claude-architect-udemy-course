# Claude Certified Architect – Foundations: Udemy Course Outline

## Course Overview

**Title**: Claude Certified Architect – Foundations: Complete Certification Prep
**Target audience**: Solution architects, senior engineers building production AI applications with Claude
**Prerequisites**: Basic familiarity with LLM APIs; some Python or TypeScript
**Exam alignment**: Covers all 5 domains per the official Anthropic exam guide (v0.1, Feb 2025)
**Structure**: 11 sections, ~18.5 hours of instruction + demo walkthroughs

> The only official practice exam is the sample question set inside `resources/anthropic-exam-guide.md`. There is no additional "Practice Exam" or "Final Review" section — Sections 8–11 replace that with four hands-on Preparation Exercise demos drawn directly from the exam guide.

---

## Section 1: Course Introduction & Exam Strategy

*One combined introduction lecture covering everything a student needs before Domain 1.*

**Estimated Duration**: ~15 minutes

### Lectures
1.1 Welcome, Exam Format, Domains, Scenarios, Study Strategy & Exam-Guide Navigation

Covers (in one combined walkthrough):
- Course welcome and what you'll learn
- Exam format: multiple choice, scaled scoring, passing threshold (720/1000)
- The 5 domains and their weights (Domain 1 = 27% — highest-leverage)
- The 6 scenarios (4 of 6 will appear on any given exam)
- Study strategy for "tomorrow" vs "2 weeks out"
- How to navigate the official Anthropic exam guide

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

## Section 2: Claude API Fundamentals Bootcamp

*Bridges the gap between "I've called Claude once" and "I can design agentic systems." Covers the API mechanics the exam tests at the hands-on level.*

**Estimated Duration**: ~90 minutes

### Lectures
2.1 The Messages API: Anatomy of a Request and Response
2.2 System Prompts: Where Instructions Live
2.3 Temperature, top_p, and top_k: Controlling Randomness
2.4 Prefilled Assistant Messages: Shaping Output from the Start
2.5 Stop Sequences: Teaching Claude Exactly When to Stop
2.6 Response Streaming: Real-Time Output
2.7 Structured Output via the API
2.8 XML Tags in Prompts: Structure Claude Understands
2.9 Multimodal Inputs: Images in the Messages API
2.10 Tool Use Fundamentals: Your First Function Call
2.11 The Complete Tool Use Loop (Hands-On)

### Hands-On Lab: API Fundamentals Playground
- Jupyter notebook with real API calls for each feature covered
- Exercises: basic message, system prompt, temperature experiments, streaming, prefilled messages, stop sequences, tool call
- Downloadable as a lab resource

### Quiz: Claude API Fundamentals
- System prompt placement and behavior across turns
- Temperature effects on output determinism
- When to use prefilled assistant messages vs system prompts
- Stop sequence matching rules and common gotchas
- Streaming event types and their order
- Tool use request/response format
- XML tag best practices
- Structured output approaches (tool_use vs JSON mode)
- Correct format for sending an image to Claude
- Role assignment: system prompt vs user message for persistent instructions

### Downloadable Resources
- API Quick Reference Card — Messages format, parameters, response structure
- XML Tag Patterns Cheat Sheet — Common tag structures with examples
- Tool Use Flow Diagram — Visual: define → call → execute → result → response
- Temperature Decision Guide — Use case → recommended temperature range
- Streaming Events Timeline — Visual sequence of SSE events

---

## Section 3: Domain 1 — Agentic Architecture & Orchestration (27%)

*The highest-weighted domain. Master this section first.*

### Lectures
3.1 The Agentic Loop: `stop_reason` Is Everything
3.2 `"tool_use"` vs `"end_turn"` — Control Flow Patterns
3.3 Anti-Patterns: What NOT to Do in Agentic Loops
3.4 Multi-Agent Hub-and-Spoke Architecture
3.5 The Coordinator's Role: Decompose, Delegate, Aggregate
3.6 Subagent Context Isolation — Why They Don't Inherit History
3.7 The `Task` Tool: Spawning Subagents + `allowedTools` Requirement
3.8 Parallel Subagent Execution — Single Response, Multiple Task Calls
3.9 Explicit Context Passing Between Agents
3.10 Programmatic Enforcement vs Prompt-Based Guidance
3.11 Agent SDK Hooks: `PostToolUse` and Tool Call Interception
3.12 Task Decomposition: Prompt Chaining vs Dynamic Adaptive
3.13 Session Management: `--resume`, `fork_session`, When to Start Fresh
3.14 Structured Handoff Summaries for Human Escalation

### Quiz: Domain 1
- What does `allowedTools` need to include for a coordinator to spawn subagents?
- When should you use programmatic enforcement vs prompt instructions for workflow ordering?
- How do you spawn parallel subagents — in one response or multiple turns?
- What is the risk of overly narrow task decomposition?
- When should you start a new session vs resume an existing one?

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

### Quiz: Domain 4
- What does `tool_choice: "any"` guarantee?
- When should you use the Message Batches API vs synchronous API?
- What does tool use eliminate? What does it NOT eliminate?
- When is retry-with-feedback ineffective?
- Why is a second independent Claude instance better than self-review for code?

---

## Section 6: Domain 2 — Tool Design & MCP Integration (18%)

### Lectures
6.1 Why Tool Descriptions Are the Most Important Thing You Write
6.2 What Makes a Great Tool Description (inputs, examples, boundaries)
6.3 Diagnosing and Fixing Tool Selection Failures
6.4 Splitting Generic Tools vs Consolidating — When to Do Each
6.5 MCP Error Response Design: Categories, `isError`, `isRetryable`
6.6 Transient vs Validation vs Business vs Permission Errors
6.7 Local Recovery vs Propagating to Coordinator
6.8 Tool Distribution: How Many Tools Per Agent?
6.9 `tool_choice`: `"auto"`, `"any"`, Forced Selection
6.10 MCP Server Configuration: Project vs User Scope
6.11 `.mcp.json` with Environment Variable Expansion
6.12 MCP Resources vs MCP Tools — When to Use Each
6.13 Built-in Tool Selection: Grep vs Glob vs Read vs Edit
6.14 Incremental Codebase Exploration Pattern

### Quiz: Domain 2
- What are the `tool_choice` options and when do you use each?
- What fields must a structured MCP error response include?
- What's the difference between project-scoped and user-scoped MCP server config?
- When should you use Grep vs Glob?
- What is the correct scope for shared team MCP servers?

---

## Section 7: Domain 5 — Context Management & Reliability (15%)

### Lectures
7.1 The "Lost in the Middle" Effect — What It Means and How to Counter It
7.2 Progressive Summarization Risks — What Gets Lost
7.3 Trimming Verbose Tool Outputs
7.4 The Persistent "Case Facts" Block Pattern
7.5 Escalation Decision Framework — When to Escalate vs Resolve
7.6 Honoring Explicit Customer Requests for Human Agents
7.7 Sentiment vs Complexity — Why They're Not the Same
7.8 Structured Error Propagation Across Multi-Agent Systems
7.9 Access Failure vs Valid Empty Result
7.10 Coverage Annotations in Synthesis Output
7.11 Context Degradation in Long Sessions
7.12 Scratchpad Files for Cross-Context Persistence
7.13 Crash Recovery with Structured Agent State Manifests
7.14 Human Review Workflows and Confidence Calibration
7.15 Stratified Sampling for Accuracy Measurement
7.16 Information Provenance: Claim-Source Mappings
7.17 Handling Conflicting Sources — Annotate, Don't Arbitrarily Choose

### Quiz: Domain 5
- What is the "lost in the middle" effect?
- What should a structured error response from a subagent include?
- When should a customer support agent escalate immediately without attempting resolution?
- What is stratified random sampling used for in this context?
- How should conflicting statistics from two credible sources be handled in synthesis?

---

## Section 8: Demo 1 — Multi-Tool Agent with Escalation Logic

*Reinforces Domains 1, 2, 5. Content lives in `labs/demos/demo-1-multi-tool-agent/`.*

**Estimated Duration**: ~15 minutes

**Objective**: Walk through designing an agentic loop with tool integration, structured error handling, and escalation patterns.

**Walkthrough covers:**
1. Defining 3–4 MCP tools with carefully differentiated descriptions (including two tools with similar functionality that require careful boundaries to avoid selection confusion)
2. Implementing an agentic loop that branches on `stop_reason` — handling both `"tool_use"` and `"end_turn"` correctly
3. Adding structured error responses: `errorCategory` (transient / validation / permission), `isRetryable` boolean, human-readable descriptions — and demonstrating how the agent retries transient errors vs explains business errors to the user
4. Implementing a programmatic hook that intercepts tool calls to enforce a business rule (e.g., block operations above a threshold amount) and redirects to escalation
5. Testing with multi-concern messages and verifying the agent decomposes, handles each concern, and synthesizes a unified response

**Domains reinforced**: Domain 1 (Agentic Architecture), Domain 2 (Tool Design & MCP), Domain 5 (Context Management & Reliability)

---

## Section 9: Demo 2 — Claude Code for a Team Dev Workflow

*Reinforces Domains 3, 2. Content lives in `labs/demos/demo-2-team-dev-workflow/`.*

**Estimated Duration**: ~15 minutes

**Objective**: Configure CLAUDE.md hierarchies, custom slash commands, path-specific rules, skills, and MCP servers for a multi-developer project.

**Walkthrough covers:**
1. Project-level CLAUDE.md with universal coding standards and testing conventions
2. `.claude/rules/` files with YAML frontmatter glob patterns (e.g., `paths: ["src/api/**/*"]`, `paths: ["**/*.test.*"]`) — rules load only when editing matching files
3. Project-scoped skill in `.claude/skills/` with `context: fork` and `allowed-tools` restriction — skill runs in isolation without polluting main conversation context
4. MCP server configuration: `.mcp.json` with environment variable expansion for credentials, plus a personal experimental server in `~/.claude.json`
5. Plan mode vs direct execution comparison across three tasks: single-file bug fix, multi-file library migration, new feature with multiple valid approaches

**Domains reinforced**: Domain 3 (Claude Code), Domain 2 (Tool Design & MCP)

---

## Section 10: Demo 3 — Structured Data Extraction Pipeline

*Reinforces Domains 4, 5. Content lives in `labs/demos/demo-3-extraction-pipeline/`.*

**Estimated Duration**: ~15 minutes

**Objective**: Design JSON schemas, use `tool_use` for structured output, implement validation-retry loops, and run batch processing.

**Walkthrough covers:**
1. Extraction tool with a JSON schema containing required + optional fields, enum with `"other"` + detail string, and nullable fields — demonstrating the model returning `null` instead of fabricating values
2. Validation-retry loop: when Pydantic/JSON schema validation fails, send a follow-up with document + failed extraction + specific validation error; distinguish format-mismatch retries (resolvable) from information-absent retries (not resolvable)
3. Few-shot examples for documents with varied formats (inline citations vs bibliographies, narrative vs tables)
4. Batch processing: 100 documents via Message Batches API, failure handling by `custom_id`, resubmission with chunking, SLA math
5. Human review routing: field-level confidence scores, low-confidence routing, accuracy analysis by document type and field

**Domains reinforced**: Domain 4 (Prompt Engineering & Structured Output), Domain 5 (Context Management & Reliability)

---

## Section 11: Demo 4 — Multi-Agent Research Pipeline

*Reinforces Domains 1, 2, 5. Content lives in `labs/demos/demo-4-research-pipeline/`.*

**Estimated Duration**: ~15 minutes

**Objective**: Orchestrate subagents, manage context passing, implement error propagation, and handle synthesis with provenance tracking.

**Walkthrough covers:**
1. Coordinator delegating to at least two subagents (web search, document analysis) with `allowedTools` including `"Task"` and explicit context passing in each subagent prompt
2. Parallel subagent execution via multiple `Task` tool calls in a single coordinator response — measuring latency improvement vs sequential
3. Structured subagent output separating content from metadata: claim, evidence excerpt, source URL/document name, publication date — preserving attribution through synthesis
4. Error propagation: simulated subagent timeout producing structured error context (failure type, attempted query, partial results); coordinator proceeds with partial results + annotates coverage gaps
5. Conflicting source data: synthesis preserves both values with source attribution rather than arbitrarily choosing, and distinguishes well-established from contested findings

**Domains reinforced**: Domain 1 (Agentic Architecture), Domain 2 (Tool Design & MCP), Domain 5 (Context Management & Reliability)

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
Section 1   (15 min)  → Course intro, exam format, domains, scenarios, study strategy (combined)
Section 2   (90 min)  → Claude API Fundamentals Bootcamp
Section 3   (3 hr)    → Domain 1: Agentic Architecture & Orchestration (27%) [HIGHEST WEIGHT]
Section 4   (2.5 hr)  → Domain 3: Claude Code Configuration & Workflows (20%)
Section 5   (2.5 hr)  → Domain 4: Prompt Engineering & Structured Output (20%)
Section 6   (2 hr)    → Domain 2: Tool Design & MCP Integration (18%)
Section 7   (2 hr)    → Domain 5: Context Management & Reliability (15%)
Section 8   (15 min)  → Demo 1: Multi-Tool Agent with Escalation Logic
Section 9   (15 min)  → Demo 2: Claude Code for a Team Dev Workflow
Section 10  (15 min)  → Demo 3: Structured Data Extraction Pipeline
Section 11  (15 min)  → Demo 4: Multi-Agent Research Pipeline
```

**Total: ~18.5 hours of instruction + demo walkthroughs**

For exam-day cramming: watch the Section 1 recap, then jump to your weakest domain section (3/4/5/6/7) and its matching demo (8/9/10/11).

---

## Filesystem Note

The section ordering in this outline is **by exam-domain weight** (Domain 1 → Domain 3 → Domain 4 → Domain 2 → Domain 5), which does **not** match the current physical folder names under `scripts/`. The script folders were created before the domain re-ordering and still carry their legacy names:

| Outline section | Exam domain | Current filesystem folder |
|----------------|-------------|---------------------------|
| Section 3 | Domain 1 | `scripts/section-03-agentic-architecture/` |
| Section 4 | Domain 3 | `scripts/section-05-claude-code-config/` |
| Section 5 | Domain 4 | `scripts/section-06-prompt-engineering/` |
| Section 6 | Domain 2 | `scripts/section-04-tool-design-mcp/` |
| Section 7 | Domain 5 | `scripts/section-07-context-reliability/` |

Folders will be renamed to match outline order in a follow-up rename sweep. Sections 8–11 have no `scripts/` folder — their content lives in `labs/demos/demo-N-*/` (README + recording script).
