# Claude Certified Architect – Foundations: Complete Study Guide

> **Exam tomorrow (March 22, 2026). Passing score: 720/1000. No penalty for guessing — answer every question.**

---

## Exam At a Glance

| Item | Detail |
|------|--------|
| Format | Multiple choice — 1 correct answer, 3 distractors |
| Scoring | Scaled 100–1,000; passing = **720** |
| Scenarios | **4 of 6** presented at random; questions are scenario-based |
| Penalty for guessing | **None** — always answer |

### Domain Weights (memorize this)

| # | Domain | Weight |
|---|--------|--------|
| 1 | Agentic Architecture & Orchestration | **27%** |
| 2 | Tool Design & MCP Integration | **18%** |
| 3 | Claude Code Configuration & Workflows | **20%** |
| 4 | Prompt Engineering & Structured Output | **20%** |
| 5 | Context Management & Reliability | **15%** |

### The 6 Exam Scenarios (4 will appear)

1. **Customer Support Resolution Agent** — Domains 1, 2, 5
2. **Code Generation with Claude Code** — Domains 3, 5
3. **Multi-Agent Research System** — Domains 1, 2, 5
4. **Developer Productivity with Claude** — Domains 2, 3, 1
5. **Claude Code for CI/CD** — Domains 3, 4
6. **Structured Data Extraction** — Domains 4, 5

---

## Domain 1: Agentic Architecture & Orchestration (27%)

### The Agentic Loop — Core Pattern

The loop is driven entirely by `stop_reason`:

```
send request → inspect stop_reason
  "tool_use"  → execute tool → append result to history → loop
  "end_turn"  → present final response → stop
```

**Critical anti-patterns (wrong answers on the exam):**
- Parsing Claude's natural language text to decide when to stop
- Setting an arbitrary iteration cap as the *primary* stopping mechanism
- Checking for assistant text content as a completion indicator

**Tool results MUST be appended to conversation history** so Claude can reason about the next step.

**Model-driven vs pre-configured**: Claude decides which tool to call based on context (model-driven). This is different from hard-coded decision trees.

---

### Task Statement 1.2: Multi-Agent Coordinator-Subagent Pattern

**Hub-and-spoke**: the coordinator manages ALL inter-subagent communication, error handling, and routing. Subagents never talk to each other directly.

**Critical facts:**
- Subagents have **isolated context** — they do NOT inherit the coordinator's conversation history
- Context must be **explicitly passed in the prompt**
- The coordinator does: task decomposition, delegation, result aggregation, dynamic subagent selection

**Risk**: Overly narrow task decomposition = incomplete coverage (e.g., decomposing "creative industries" into only visual arts subtasks — see Sample Question 7)

---

### Task Statement 1.3: Subagent Spawning

- **`Task` tool** = the mechanism for spawning subagents
- `allowedTools` **must include `"Task"`** for a coordinator to invoke subagents
- **Parallel execution**: emit multiple `Task` tool calls in a **single coordinator response** (not separate turns)
- **Structured context passing**: include source URLs, document names, page numbers to preserve attribution
- **Fork-based session management**: for divergent approaches from a shared baseline

**Coordinator prompt design**: specify research *goals and quality criteria*, not step-by-step procedures (enables subagent adaptability)

---

### Task Statement 1.4: Multi-Step Workflows & Enforcement

**Key distinction**: programmatic enforcement vs prompt-based guidance

| Approach | Reliability | Use when |
|----------|-------------|----------|
| Programmatic prerequisite gate | **Deterministic** | Financial ops, identity verification, compliance |
| Prompt instruction | Probabilistic (non-zero failure rate) | Soft guidelines, style preferences |

**Example**: Block `process_refund` until `get_customer` has returned a verified customer ID — do this programmatically, not via prompt.

**Handoff summaries** when escalating: customer ID, root cause, refund amount, recommended action — because the human agent has no conversation transcript.

---

### Task Statement 1.5: Agent SDK Hooks

| Hook type | Purpose |
|-----------|---------|
| `PostToolUse` | Intercept tool *results* for normalization before the model processes them |
| Tool call interception | Intercept *outgoing* tool calls to enforce compliance rules |

**Use case for PostToolUse**: normalize heterogeneous data formats (Unix timestamps, ISO 8601, numeric status codes) from different MCP tools.

**Use case for interception**: block refunds > $500, redirect to human escalation.

**Rule**: Use hooks for deterministic guarantees; use prompts for probabilistic guidance.

---

### Task Statement 1.6: Task Decomposition Strategies

| Pattern | When to use |
|---------|-------------|
| **Prompt chaining** (fixed sequential) | Predictable multi-aspect reviews (e.g., per-file then cross-file) |
| **Dynamic adaptive decomposition** | Open-ended investigation (generate subtasks based on discoveries) |

**Code review pattern**: analyze each file individually → then a separate cross-file integration pass → avoids attention dilution.

**Open-ended tasks**: first map structure → identify high-impact areas → create prioritized plan that adapts as dependencies are discovered.

---

### Task Statement 1.7: Session Management

| Feature | What it does |
|---------|-------------|
| `--resume <session-name>` | Continue a named prior conversation |
| `fork_session` | Create independent branches from a shared analysis baseline |
| `/compact` | Reduce context usage during extended sessions |

**When to resume vs fresh start**:
- Resume: prior context is mostly valid
- Fresh start with injected summary: prior tool results are stale

**After file changes**: inform the resumed session about specific changed files for targeted re-analysis (don't require full re-exploration).

---

## Domain 2: Tool Design & MCP Integration (18%)

### Task Statement 2.1: Effective Tool Descriptions

**Tool descriptions = the primary mechanism LLMs use for tool selection.**

A good description includes:
- Purpose and scope
- Input formats
- Example queries
- Edge cases
- Boundary explanations (when to use THIS tool vs similar alternatives)

**Ambiguous/overlapping descriptions = misrouting.** Example: `analyze_content` vs `analyze_document` with near-identical descriptions.

**Fix**: rename + update descriptions to eliminate overlap. Split generic tools into purpose-specific tools:
- `analyze_document` → `extract_data_points`, `summarize_content`, `verify_claim_against_source`

**Watch out**: system prompt keywords can create unintended tool associations.

---

### Task Statement 2.2: Structured MCP Error Responses

MCP uses the `isError` flag to communicate tool failures.

**Error categories:**

| Category | Examples |
|----------|---------|
| Transient | Timeouts, service unavailability |
| Validation | Invalid input |
| Business | Policy violations |
| Permission | Access denied |

**Error response must include:**
- `errorCategory` (transient/validation/permission)
- `isRetryable` boolean
- Human-readable description

**Distinguish**: access failure (timeout, needs retry decision) vs valid empty result (successful query, no matches found).

**Anti-pattern**: generic "Operation failed" → prevents agent from making appropriate recovery decisions.

**Local recovery**: subagents handle transient failures locally; only propagate errors they cannot resolve (with partial results + what was attempted).

---

### Task Statement 2.3: Tool Distribution & `tool_choice`

**Key principle**: 4–5 tools per agent is optimal. 18 tools = degraded selection reliability.

Agents with out-of-scope tools tend to misuse them (e.g., synthesis agent attempting web searches).

**`tool_choice` options:**

| Value | Behavior |
|-------|----------|
| `"auto"` | Model may return text OR call a tool |
| `"any"` | Model MUST call a tool (any available one) |
| `{"type": "tool", "name": "X"}` | Model MUST call tool X specifically |

**Use `tool_choice: "any"`** to guarantee structured output when the model might otherwise return conversational text.

**Use forced selection** to ensure a specific tool runs first (e.g., `extract_metadata` before enrichment tools).

---

### Task Statement 2.4: MCP Server Configuration

| Scope | File | Use for |
|-------|------|---------|
| Project (shared, version-controlled) | `.mcp.json` | Team tooling |
| User (personal) | `~/.claude.json` | Personal/experimental servers |

**Environment variables in `.mcp.json`**: `${GITHUB_TOKEN}` — never commit secrets.

**All configured MCP servers are discovered at connection time and available simultaneously.**

**MCP Resources**: expose content catalogs (issue summaries, documentation hierarchies, database schemas) to reduce exploratory tool calls.

**Community vs custom**: prefer existing community MCP servers for standard integrations (e.g., Jira); build custom only for team-specific workflows.

---

### Task Statement 2.5: Built-in Tool Selection

| Tool | Use for |
|------|---------|
| `Grep` | Search file *contents* (patterns, function names, error messages) |
| `Glob` | Find files by *name/path patterns* (e.g., `**/*.test.tsx`) |
| `Read` | Load full file contents |
| `Write` | Full file operations |
| `Edit` | Targeted modifications using unique text matching |

**Edit fallback**: when Edit fails due to non-unique text matches → Read + Write.

**Incremental codebase exploration**: start with Grep to find entry points → Read to follow imports and trace flows (don't read all files upfront).

---

## Domain 3: Claude Code Configuration & Workflows (20%)

### Task Statement 3.1: CLAUDE.md Hierarchy

**Three levels (top-down priority):**

```
~/.claude/CLAUDE.md          ← user-level (NOT shared via version control)
.claude/CLAUDE.md (or root)  ← project-level (shared, version-controlled)
src/module/CLAUDE.md         ← directory-level (applies to that subtree)
```

**Critical**: instructions in `~/.claude/CLAUDE.md` are personal only — teammates won't see them.

**`@import` syntax**: include external files to keep CLAUDE.md modular.

**`.claude/rules/`**: alternative to a monolithic CLAUDE.md — organize topic-specific rule files (`testing.md`, `api-conventions.md`, `deployment.md`).

**`/memory` command**: verify which memory files are loaded; diagnose inconsistent behavior across sessions.

---

### Task Statement 3.2: Custom Slash Commands & Skills

| Item | Location | Scope |
|------|----------|-------|
| Project commands | `.claude/commands/` | Shared via version control |
| Personal commands | `~/.claude/commands/` | Personal only |
| Project skills | `.claude/skills/` | Shared via version control |
| Personal skills | `~/.claude/skills/` | Personal only |

**SKILL.md frontmatter options:**

| Option | Purpose |
|--------|---------|
| `context: fork` | Run skill in isolated sub-agent; prevents output from polluting main conversation |
| `allowed-tools` | Restrict which tools the skill can use |
| `argument-hint` | Prompt developers for required parameters when invoked without arguments |

**Skills vs CLAUDE.md:**
- Skills: on-demand invocation for task-specific workflows
- CLAUDE.md: always-loaded universal standards

**`context: fork`** is essential for skills with verbose output (codebase analysis) or exploratory context (brainstorming).

---

### Task Statement 3.3: Path-Specific Rules

**`.claude/rules/` with YAML frontmatter:**

```yaml
---
paths: ["terraform/**/*"]
---
# Terraform conventions here...
```

Rules load ONLY when editing matching files — reduces irrelevant context and token usage.

**Use glob patterns** to apply conventions to files by type regardless of directory location (e.g., `**/*.test.tsx` for ALL test files across the codebase).

**vs subdirectory CLAUDE.md**: use path-specific rules when conventions span multiple directories (test files spread throughout the codebase can't be handled by a single subdirectory CLAUDE.md).

---

### Task Statement 3.4: Plan Mode vs Direct Execution

| Use Plan Mode | Use Direct Execution |
|--------------|---------------------|
| Large-scale changes (45+ files) | Single-file bug fix with clear stack trace |
| Multiple valid approaches exist | Simple, well-scoped change |
| Architectural decisions | Adding one validation check to one function |
| Microservice restructuring | Clear, unambiguous task |
| Library migrations | — |

**Plan mode**: enables safe codebase exploration and design *before* committing to changes — prevents costly rework.

**Explore subagent**: isolates verbose discovery output → returns summaries → preserves main conversation context.

**Combining**: use plan mode for investigation, direct execution for implementation.

---

### Task Statement 3.5: Iterative Refinement

| Technique | When to use |
|-----------|-------------|
| Concrete input/output examples (2–3) | Prose descriptions produce inconsistent results |
| Test-driven iteration | Write tests first, share failures to guide improvement |
| Interview pattern | Have Claude ask questions before implementing (surfaces edge cases) |
| Single message with all issues | When fixes interact with each other |
| Sequential iteration | When issues are independent |

**Input/output examples** are the most effective way to communicate expected transformations.

---

### Task Statement 3.6: CI/CD Integration

**Non-interactive mode**: use `-p` or `--print` flag.

```bash
claude -p "Analyze this PR for security issues"
```

**Structured CI output:**
```bash
claude -p "..." --output-format json --json-schema schema.json
```

**CLAUDE.md in CI**: provides project context (testing standards, fixture conventions, review criteria).

**Session isolation for review**: the Claude session that *generated* code is less effective at reviewing its own changes — use an independent review instance.

**Deduplication**: include prior review findings in context when re-running; instruct Claude to report only new or still-unaddressed issues.

---

## Domain 4: Prompt Engineering & Structured Output (20%)

### Task Statement 4.1: Explicit Criteria Over Vague Instructions

**Bad**: "be conservative", "only report high-confidence findings" — these do NOT improve precision.

**Good**: "flag comments only when claimed behavior contradicts actual code behavior"

**Define explicitly what to report vs skip:**
- Report: bugs, security issues
- Skip: minor style, local patterns

**Severity criteria**: define with concrete code examples for each severity level.

**High false positives**: temporarily disable those categories while fixing prompts — preserves developer trust.

---

### Task Statement 4.2: Few-Shot Prompting

**Most effective technique** when detailed instructions alone produce inconsistent results.

**What few-shot examples do:**
- Demonstrate ambiguous-case handling
- Show desired output format (location, issue, severity, suggested fix)
- Enable generalization to novel patterns (not just matching pre-specified cases)
- Reduce hallucination in extraction tasks

**Best practices:**
- 2–4 targeted examples for ambiguous scenarios
- Show *why* one action was chosen over plausible alternatives
- Include examples that distinguish acceptable patterns from genuine issues
- Use to demonstrate correct handling of varied document structures

---

### Task Statement 4.3: Structured Output via Tool Use

**Most reliable approach**: `tool_use` with JSON schemas — eliminates JSON syntax errors.

**`tool_choice` recap:**
- `"auto"` → model may return text (not guaranteed structured output)
- `"any"` → model MUST call a tool (use when document type is unknown)
- `{"type": "tool", "name": "extract_metadata"}` → specific tool forced

**Tool use eliminates syntax errors but NOT semantic errors** (line items don't sum to total, values in wrong fields).

**Schema design:**
- Make fields `nullable`/optional when source documents may not contain the info → **prevents fabrication**
- Use enum with `"other"` + detail string for extensible categories
- Use `"unclear"` enum value for ambiguous cases

---

### Task Statement 4.4: Validation & Retry Loops

**Retry-with-error-feedback**: on failure, send follow-up with:
1. Original document
2. Failed extraction
3. Specific validation errors

**When retries work**: format mismatches, structural output errors.

**When retries DON'T work**: information is simply absent from the source document.

**`detected_pattern` field**: add to findings to track which code constructs trigger false positives — enables systematic analysis.

**Self-correction flow**: extract `calculated_total` alongside `stated_total` → flag discrepancies. Add `conflict_detected` boolean for inconsistent source data.

---

### Task Statement 4.5: Batch Processing

**Message Batches API:**
- 50% cost savings
- Up to 24-hour processing window
- **No guaranteed latency SLA**
- Does NOT support multi-turn tool calling within a single request
- Use `custom_id` to correlate request/response pairs

| Workflow | API to use |
|----------|-----------|
| Blocking pre-merge check | Synchronous (real-time) API |
| Overnight tech debt report | Batch API |
| Weekly security audit | Batch API |
| Nightly test generation | Batch API |

**Calculating batch cadence**: if SLA = 30 hours and batch takes up to 24 hours, submit every 4 hours.

**Handling failures**: resubmit only failed documents (by `custom_id`) with modifications (e.g., chunk oversized documents).

---

### Task Statement 4.6: Multi-Instance Review Architecture

**Self-review limitation**: model retains reasoning context from generation → less likely to question its own decisions.

**Independent review instance** (without prior reasoning context) is more effective than self-review instructions or extended thinking.

**Multi-pass review pattern**:
1. Per-file passes for local issues
2. Separate cross-file integration pass for data flow analysis

**Verification pass**: model self-reports confidence alongside each finding → enables calibrated review routing.

---

## Domain 5: Context Management & Reliability (15%)

### Task Statement 5.1: Context Preservation

**Progressive summarization risks**: loses numerical values, percentages, dates, customer-stated expectations.

**"Lost in the middle" effect**: models reliably process info at beginning and end of long inputs; middle sections may be omitted.

**Verbose tool outputs**: can consume tokens disproportionately (40+ fields when only 5 are relevant).

**Strategies:**
- Extract transactional facts (amounts, dates, order numbers) into a persistent "case facts" block outside summarized history
- Trim tool outputs to only relevant fields
- Place key findings summaries at the **beginning** of aggregated inputs
- Use explicit section headers to organize detailed results
- Have subagents return structured data (key facts, citations, relevance scores), not verbose reasoning chains

---

### Task Statement 5.2: Escalation Patterns

**When to escalate (triggers):**
- Customer explicitly requests a human → **immediately, without attempting to investigate first**
- Policy exceptions/gaps (not just complex cases)
- Unable to make meaningful progress

**Unreliable escalation proxies** (wrong answers):
- Sentiment-based escalation
- Self-reported confidence scores

**Multiple customer matches**: ask for additional identifiers — do NOT select based on heuristics.

**Appropriate response to frustrated customer**: acknowledge frustration + offer to resolve → only escalate if customer reiterates preference for human.

**Policy ambiguity**: escalate when policy is silent on the specific request (e.g., competitor price matching when policy only covers own-site adjustments).

---

### Task Statement 5.3: Error Propagation in Multi-Agent Systems

**Structured error context must include:**
- Failure type
- What was attempted
- Partial results
- Potential alternative approaches

**Anti-patterns:**
- Silent suppression (returning empty results as success)
- Terminating entire workflow on single failure
- Generic "search unavailable" status (hides context from coordinator)

**Local recovery**: subagents handle transient failures themselves; propagate only what they cannot resolve.

**Coverage annotations**: structure synthesis output to indicate which findings are well-supported vs which topic areas have gaps due to unavailable sources.

---

### Task Statement 5.4: Context in Large Codebase Exploration

**Context degradation signs**: model starts referencing "typical patterns" rather than specific classes discovered earlier.

**Scratchpad files**: persist key findings across context boundaries — agents reference these for subsequent questions.

**Subagent delegation**: spawn subagents for specific investigation questions → main agent preserves high-level coordination.

**Crash recovery**: each agent exports state (manifests) to known location; coordinator loads manifest on resume and injects into agent prompts.

**`/compact`**: reduces context usage when context fills with verbose discovery output.

**Pattern for multi-phase work**: summarize key findings from phase N → inject into initial context of phase N+1 subagents.

---

### Task Statement 5.5: Human Review Workflows

**Aggregate accuracy can be misleading**: 97% overall may mask poor performance on specific document types.

**Stratified random sampling**: measure error rates in high-confidence extractions; detect novel error patterns.

**Field-level confidence scores**: calibrate using labeled validation sets → route review attention.

**Before automating**: validate accuracy by document type AND field segment — ensure consistent performance across ALL segments.

**Routing**: low confidence or ambiguous/contradictory source documents → human review.

---

### Task Statement 5.6: Information Provenance

**Source attribution is lost during summarization** when findings are compressed without preserving claim-source mappings.

**Subagents must output** structured claim-source mappings: source URL, document name, relevant excerpts, publication dates.

**Conflicting statistics**: annotate conflicts with source attribution — do NOT arbitrarily select one value.

**Temporal data**: require publication/collection dates to prevent temporal differences from being misinterpreted as contradictions.

**Synthesis output format**: financial data as tables, news as prose, technical findings as structured lists — don't convert everything to a uniform format.

---

## Sample Questions (with Answers)

### Q1 — Domain 1 (Agent Reliability)
Agent skips `get_customer` in 12% of cases → wrong account identified → incorrect refunds. Fix?

**A) Programmatic prerequisite blocking `lookup_order`/`process_refund` until `get_customer` returns verified ID** ✓

Why B/C are wrong: prompt instructions and few-shot examples are probabilistic — non-zero failure rate for financial operations.
Why D is wrong: addresses tool *availability*, not tool *ordering*.

---

### Q2 — Domain 2 (Tool Selection)
Agent calls `get_customer` for order queries due to minimal descriptions. First step?

**B) Expand each tool's description to include input formats, example queries, edge cases, and boundaries** ✓

Why A is wrong: few-shot examples add token overhead without fixing root cause.
Why C is wrong: over-engineered routing layer bypasses LLM's natural language understanding.
Why D is wrong: requires more effort than "first step" warrants.

---

### Q3 — Domain 5 (Escalation)
Agent at 55% FCR: escalates straightforward cases, handles complex ones autonomously. Fix?

**A) Add explicit escalation criteria with few-shot examples demonstrating when to escalate vs resolve** ✓

Why B is wrong: LLM self-reported confidence is poorly calibrated.
Why C is wrong: over-engineered — prompt optimization hasn't been tried yet.
Why D is wrong: sentiment ≠ case complexity.

---

### Q4 — Domain 3 (Claude Code)
Team slash command `/review` should be available when any developer clones the repo. Where?

**A) `.claude/commands/` directory in the project repository** ✓

`~/.claude/commands/` = personal only. CLAUDE.md = context, not commands.

---

### Q5 — Domain 3 (Plan Mode)
Restructuring monolith to microservices: dozens of files, architectural decisions. Which approach?

**A) Plan mode** ✓

Known complexity up front; plan mode prevents costly rework from late-discovered dependencies.

---

### Q6 — Domain 3 (Path-Specific Rules)
Test files spread throughout codebase; need consistent conventions regardless of location.

**A) `.claude/rules/` with YAML frontmatter glob patterns** ✓

Subdirectory CLAUDE.md can't handle files spread across many directories.

---

### Q7 — Domain 1 (Coordinator Decomposition)
System covers only visual arts despite topic being "creative industries." Root cause?

**B) Coordinator's task decomposition is too narrow** ✓

Subagents executed correctly within their assigned scope — the coordinator assigned the wrong scope.

---

### Q8 — Domain 5 (Error Propagation)
Web search subagent times out. Best error propagation approach?

**A) Return structured error context (failure type, attempted query, partial results, alternatives)** ✓

Generic status (B) hides context. Empty "success" (C) prevents recovery. Terminating workflow (D) is unnecessary.

---

### Q9 — Domain 2 (Tool Distribution)
85% of synthesis agent's verifications are simple fact-checks; 15% need deep investigation. Reduce 40% latency overhead?

**A) Give synthesis agent a scoped `verify_fact` tool for simple lookups; complex verifications route through coordinator** ✓

Batching (B) creates blocking dependencies. Full web tools for synthesis (C) over-provisions. Speculative caching (D) can't reliably predict needs.

---

### Q10 — Domain 3 (CI/CD)
Pipeline hangs — Claude Code waiting for interactive input.

**A) `claude -p "Analyze this pull request for security issues"`** ✓

`CLAUDE_HEADLESS` and `--batch` don't exist. `/dev/null` redirect doesn't fix Claude's syntax.

---

### Q11 — Domain 4 (Batch Processing)
Pre-merge check (blocking) + overnight tech debt report. Switch both to Batch API?

**A) Batch API for overnight reports only; keep real-time for pre-merge checks** ✓

Batch API has no latency SLA — unsuitable for blocking workflows.

---

### Q12 — Domain 4 (Multi-Pass Review)
14-file PR → inconsistent review, attention dilution, contradictory findings.

**A) Per-file passes for local issues + separate cross-file integration pass** ✓

Larger context window (C) doesn't fix attention quality. Consensus-required (D) suppresses intermittent bug detection.

---

## Critical Concepts Quick Reference

### The Programmatic vs Prompt Enforcement Rule
**Programmatic enforcement** = deterministic (use for financial ops, identity verification, compliance)
**Prompt instructions** = probabilistic, non-zero failure rate (use for style, preferences)

### Tool Description Quality Rule
Tool descriptions are the primary selection mechanism. Minimal descriptions = unreliable selection. Always include: input formats, example queries, edge cases, boundaries vs similar tools.

### Context Isolation Rule
Subagents have isolated context — they do NOT inherit coordinator history. Must be explicitly passed.

### Few-Shot Examples Rule
Most effective technique when instructions alone produce inconsistent results. 2–4 examples for ambiguous scenarios. Show reasoning for choices.

### Batch API Rule
50% savings, up to 24-hour processing, no latency SLA. For latency-tolerant workloads ONLY. Not for blocking workflows. Does not support multi-turn tool calling.

### `tool_choice` Rules
- `"auto"` = might not call a tool
- `"any"` = must call a tool (use to guarantee structured output)
- `{"type": "tool", "name": "X"}` = must call that specific tool

### Escalation Rules
- Customer requests human? Escalate **immediately** — don't attempt investigation first
- Policy silent on case? Escalate
- Sentiment? NOT a reliable escalation trigger
- Multiple matches? Ask for more identifiers — don't guess

### Error Propagation Rules
- Never suppress errors silently
- Never terminate entire workflow on single subagent failure
- Return structured context: type, what was attempted, partial results, alternatives
- Distinguish access failure (timeout) vs valid empty result (no matches)

### Lost in the Middle
Place key findings at **beginning** of aggregated inputs. Use explicit section headers. Don't rely on middle-of-context information being reliably attended to.

### CLAUDE.md Hierarchy
- User-level (`~/.claude/CLAUDE.md`) = NOT shared, personal only
- Project-level (`.claude/CLAUDE.md`) = shared via version control
- Directory-level = applies to subtree
- `.claude/rules/` with `paths:` frontmatter = conditional, glob-scoped rules

### Self-Review Limitation
Same Claude session that generated code is less effective at reviewing it — retains generation reasoning context. Use independent instance.

---

## Out of Scope (Don't Study These)

- Fine-tuning / training custom models
- API authentication, billing, account management
- Deploying/hosting MCP servers (infrastructure, networking)
- Claude's internal architecture, training, model weights
- Constitutional AI, RLHF, safety training methodologies
- Embeddings, vector databases
- Computer use (browser automation, desktop)
- Vision/image analysis
- Streaming API / server-sent events
- Rate limiting, quotas, pricing calculations
- OAuth, API key rotation
- Specific cloud provider configs (AWS, GCP, Azure)
- Performance benchmarking / model comparison
- Prompt caching details (beyond knowing it exists)
- Token counting algorithms

---

## Last-Night Checklist

Focus on scenario pattern recognition — the exam tests *judgment*, not trivia.

- [ ] Know the 5 domain weights cold
- [ ] Know the 6 scenarios and their primary domains
- [ ] Know when to use programmatic enforcement vs prompt guidance
- [ ] Know `stop_reason` loop control flow
- [ ] Know `tool_choice` options and when to use each
- [ ] Know CLAUDE.md hierarchy and what's shared vs personal
- [ ] Know `.claude/commands/` vs `~/.claude/commands/`
- [ ] Know `context: fork` in SKILL.md
- [ ] Know `.claude/rules/` with YAML frontmatter glob patterns
- [ ] Know `-p` flag for CI/CD
- [ ] Know Batch API limitations (no latency SLA, no multi-turn tool calling)
- [ ] Know escalation triggers (explicit customer request, policy gaps)
- [ ] Know subagents have isolated context — must be explicitly passed
- [ ] Know `Task` tool + `allowedTools` must include `"Task"` for subagent spawning
- [ ] Know parallel subagents = multiple Task calls in SINGLE coordinator response
- [ ] Know few-shot examples are most effective for consistency
- [ ] Know nullable fields prevent hallucination of missing data
- [ ] Know tool use eliminates syntax errors but NOT semantic errors

**Score target: answer every question. No penalty for guessing.**
