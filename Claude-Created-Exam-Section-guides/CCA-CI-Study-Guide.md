# Claude Certified Architect — Foundations: Study Guide

**Scenario 5: Claude Code for Continuous Integration**

*Coverage: Prompt-Based Output Control • CLI Flag Awareness • Severity Calibration • Inline Reasoning • Structured Output for CI*

## 1. Scenario Overview & Exam Positioning

The Claude Code for CI/CD scenario places you as the architect of an automated code review and analysis pipeline. You integrate Claude Code into continuous integration workflows:

- Running reviews on pull requests
- Generating test cases
- Producing security audits
- Managing API costs across different workload types

**Exam domains drawn from**

| Domain | Weight | Key Topics Tested |
|---|---|---|
| Domain 3: Claude Code Configuration & Workflows | 20% | `-p` flag, `--output-format json`, CLAUDE.md vs prompt, session isolation |
| Domain 4: Prompt Engineering & Structured Output | 20% | Few-shot prompting, explicit criteria, severity calibration, inline reasoning, `tool_use` schemas, validation-retry loops |
| Domain 5: Context Management & Reliability | 15% | Context overload, multi-pass decomposition, incremental review, prior findings, multi-instance review |

**What the exam expects**
- Production-grade architectural decisions, not just feature recall
- Distractors are plausible options engineers commonly reach for before understanding the production implications

**How this guide is organized** (mirrors how the scenario is tested)
- Terminology first
- Deep dives on the highest-leverage concepts (output control, batch vs sync, prompt precision, inline reasoning, validation-retry, multi-instance review)
- Recurring architectural patterns
- Structured-output and validation tooling that Domain 4 leans on heavily

## 2. Core Terminology & Definitions

### Claude Code CLI Flags

| Flag / Option | Purpose |
|---|---|
| `-p` / `--print` | Non-interactive mode. Sends prompt, outputs result to stdout, exits. REQUIRED for CI/CD pipelines. Without it, the job hangs waiting for interactive input. |
| `--output-format json` | Structures CLI output as JSON with metadata (`session_id`, cost, etc.). Used with `-p` for programmatic parsing. |
| `--output-format stream-json` | Streaming JSON output for real-time processing of large analyses. |
| `--output-format text` | Plain text output (default). Human-readable but harder to parse. |
| `--json-schema` | Constrains the JSON output to match a specific schema. Combined with `--output-format json` for guaranteed structured findings. |
| `--max-turns` | Limits execution turns. Controls cost and prevents runaway sessions. |
| `--allowedTools` | Restricts which tools Claude can use. Essential for CI security (e.g., only `Read`, no `Bash`). |
| `--dangerously-skip-permissions` | Bypasses all permission prompts. Use ONLY in fully isolated CI containers. |
| `--session-id` / `--resume` | Named sessions for multi-step CI workflows. Retains context across invocations. |
| `--append-system-prompt` | Adds instructions while preserving Claude Code defaults. Preferred for CI customization. |

> **KEY EXAM TRAP — Fabricated CLI Flags**
> - The exam includes plausible-sounding but nonexistent flags as distractors
> - Flags that DO NOT EXIST: `--batch`, `CLAUDE_HEADLESS=true` environment variable
> - If an answer references a flag not in the official Claude Code documentation, treat it as fabricated

### Message Batches API

The Message Batches API is Anthropic's cost-optimization endpoint for asynchronous workloads:

- 50% cost savings vs synchronous Messages API
- Processing window of up to 24 hours (often faster, but not guaranteed)
- Fire-and-forget: submit, poll for completion, retrieve results
- Supports the same request parameters as synchronous API (including tool definitions)
- Uses `custom_id` fields for correlating outputs back to input requests
- Cannot execute tool calls mid-request (no agentic loop support)

### CLAUDE.md in CI Context

In CI/CD, CLAUDE.md serves a specific role: providing project context.

- **Defines:** coding standards, architectural conventions, testing frameworks, review criteria Claude should know about
- **Does NOT control:** output format of specific CI tasks — output formatting belongs in the prompt for each invocation

### Session Context Isolation

- The same Claude session that generated code is less effective at reviewing its own changes
- It retains reasoning context that makes it less likely to question its decisions — the self-review limitation
- The fix is an independent review instance that does not see the generator's reasoning
- Mirrors human code review: a different person catches things the author missed

### `--print` Mode vs Interactive Mode

- **Interactive mode** (default): launches a conversational session that waits for user input
- **`--print` mode** (`-p`): one-shot execution — send prompt, get response, exit
- Every CI/CD integration must use `-p`
- Directly tested; the most fundamental prerequisite

## 3. Key Concept Deep Dives

### 3.1 Controlling Output Format: Prompt vs CLI Flags vs CLAUDE.md

**Domain:** 3 + 4

Three distinct mechanisms for influencing Claude Code output in CI:

| Mechanism | What It Controls | When to Use |
|---|---|---|
| Prompt instructions | Output format of a specific invocation | When you need structured, parseable output for a particular CI task (e.g., review findings as `[FILE:path] [LINE:n]`) |
| `--output-format json` | CLI wrapper metadata format | When you need to parse session metadata (`session_id`, cost) programmatically |
| `--json-schema` | Schema constraint on JSON output | Combined with `--output-format json` to enforce specific output structure |
| CLAUDE.md | Project context (standards, conventions) | For coding standards, architecture rules, review criteria — NOT for per-task output format |

> **Core concept**
> - In `--print` mode, OUTPUT CONTENT is shaped by the PROMPT, not by CLI flags
> - `--output-format json` wraps the response in JSON metadata, but the actual review content inside is still controlled by what the prompt asks for
> - To get `[FILE:path] [LINE:n] [SEVERITY:level]` structured findings, include that format requirement in the prompt text
> - CLAUDE.md provides context (what standards to review against), not format (how to structure output)

**Three-layer model**
- CLAUDE.md — outermost layer: always-present project context
- Prompt — middle layer: task-specific instructions including output format
- CLI flags — innermost layer: metadata wrapper and execution parameters

### 3.2 Latency Sensitivity: Synchronous vs Batch API

**Domain:** 3 + 5

| Workflow Characteristic | API Choice | Reasoning |
|---|---|---|
| Blocking / interactive (someone is waiting) | Synchronous Messages API | Developers can't wait up to 24 hours to merge a PR |
| Scheduled / background (no one is waiting) | Message Batches API | Overnight reports, weekly audits, nightly test gen — 50% savings |
| Agentic / multi-turn tool use | Synchronous Messages API | Batch API cannot execute tools mid-request and return results |

**Common distractor**
- "Batch both with timeout fallback to real-time" — over-engineered
- If a workflow needs real-time responses, use synchronous calls
- Don't build a fallback for something that should never be batched

### 3.3 Prompt Precision: Explicit Criteria vs Vague Instructions

**Domain:** 4

- When Claude produces both false positives (flagging acceptable patterns) and false negatives (missing real issues), the root cause is almost always vague prompt instructions
- The fix is making criteria specific and targeted

| Vague Instruction | Problem | Precise Replacement |
|---|---|---|
| "Check that comments are accurate" | Flags TODOs, simple descriptions, anything that looks off | "Flag comments only when their claimed behavior contradicts actual code behavior" |
| "Review for security issues" | Inconsistent depth, misses some patterns | "Check for: SQL injection, XSS, auth bypass, secrets in code. Flag with file, line, severity." |
| "Ensure code quality" | Vague — quality means different things | "Flag: functions >50 lines, cyclomatic complexity >10, missing error handling on I/O calls" |

> **Core concept**
> - Filtering findings after generation is a symptom-level fix — removes some noise but doesn't help Claude FIND the real issues
> - Explicit criteria fix both problems simultaneously:
>   - Stop false positives by narrowing what to flag
>   - Reduce false negatives by telling Claude exactly what to look for
> - **Rule of thumb:** if Claude is flagging wrong things AND missing right things, the prompt is too vague

### 3.4 Inline Reasoning for Developer Trust

**Domain:** 4 + 5

- When developers report investigating findings is slow, the bottleneck is per-finding triage time
- They must click into each finding to understand whether it's real
- **Fix:** include reasoning and confidence inline with each finding so developers can scan and triage without extra clicks

**Watch for stated constraints**
- A common scenario adds a constraint like "stakeholders have rejected any approach that filters findings before developer review"
- That eliminates auto-suppression and confidence filtering as options
- Read constraints carefully before evaluating options

- **Without inline reasoning:** "Potential null pointer" — developer must click in to understand
- **With inline reasoning:** "Potential null pointer (HIGH — `user` param nullable per line 42, dereferenced without check line 58)" — developer triages instantly

> **Core concept**
> - Categorization (blocking vs suggestion) helps with PRIORITIZATION — which to look at first
> - Inline reasoning helps with INVESTIGATION TIME — how long each one takes to evaluate
> - Always match the solution to the specific bottleneck stated in the question

### 3.5 Validation-Retry Loops: When They Work and When They Don't

**Domain:** 4

- A validation-retry loop sends Claude's failed output back as feedback ("your JSON is missing field X; please re-emit") and asks for a corrected response
- One of the highest-leverage reliability patterns in Domain 4 — but only when the failure type is recoverable

The exam tests whether candidates can distinguish two failure categories.

| Failure Type | Retry Outcome |
|---|---|
| Format mismatch (wrong date format, wrong units, value placed in wrong field) | RESOLVABLE — Claude has the correct value in context but emitted it incorrectly. The retry tells it specifically what to fix. |
| Schema violation (missing required field, invalid enum, wrong type) | RESOLVABLE — retry with the validation error guides correction. |
| Arithmetic error (line items don't sum to declared total) | RESOLVABLE — Claude can recompute when told what failed. |
| Information absent (data is not in the document Claude was given) | NOT RESOLVABLE — retrying produces another fabricated value or another null. Solve by making the field nullable, or by routing to human review. |
| Subjective judgment (no objectively correct answer) | NOT RESOLVABLE — no ground truth exists for the model to converge on. |

**Architectural rule**
- Before adding a retry, ask whether the missing or wrong value could *in principle* be derived from the input
- If yes → retry with specific error feedback
- If no → the right answer is one of:
  - Schema change (nullable field, additional `evidence` field)
  - Human routing
  - Accepting the gap
- NOT more attempts at the same impossible task

**Distractor pattern**
- Questions describing high failure rates often offer "increase the retry budget" as a tempting option
- When the underlying failure is information-absent, additional retries waste tokens and produce confidently fabricated values
- That outcome is worse than an honest null

### 3.6 The `detected_pattern` Field for False Positive Analysis

**Domain:** 4

**The pattern**
- When the extractor flags something as a problem, also have it return WHICH pattern it matched
- This single schema addition lets you quickly verify whether each flag is a true positive or a false positive of pattern matching
- Gives you data to systematically improve the prompt over time

**How to apply it**
- Add a `detected_pattern` field to every finding's structured output
- The value names the heuristic that fired (`"nested-null-check"`, `"unhandled-promise-rejection"`, `"magic-number-in-config"`)
- When developers dismiss findings, aggregate dismissals by `detected_pattern` to discover which patterns consistently produce noise

```yaml
finding:
  type: object
  required: [file, line, severity, message, detected_pattern]
  properties:
    file: {type: string}
    line: {type: integer}
    severity: {enum: [critical, warning, info]}
    message: {type: string}
    detected_pattern: {type: string}    # the heuristic that fired
    suggested_fix: {type: [string, "null"]}
```

**Why it matters**
- Without `detected_pattern`, dismissals are opaque — you know developers ignored 45 findings last week, but not which categories
- With it, you discover (for example) that `magic-number` findings are dismissed 80% of the time in config files while `unhandled-promise` findings are dismissed only 5% of the time
- You stop flagging magic numbers in config paths and the trust problem disappears, without sacrificing the high-value category
- This is the data-driven mechanism behind the trust-erosion fix in Section 5.3

### 3.7 Multi-Instance Review: Why Two Claude Instances Beat Self-Review

**Domain:** 5

**Why self-review fails**
- When the same Claude session that generated content reviews it, the review tends to defend the prior decision
- The model retains the reasoning context that produced the output
- It re-traverses the same logical path — exactly what made the decision feel correct in the first place

**Why a second instance works**
- A SECOND independent Claude instance gets the original input plus the first instance's output, but NO access to the first's reasoning
- It catches more issues because it evaluates the artifact on its own merits

**The two-instance pattern:**

1. **Generator instance:** receives the input (code, document, schema), produces the artifact (refactored code, summary, extracted data).
2. **Reviewer instance:** receives the original input AND the generator's output, but starts from a fresh context. Asked to critique the output against the input.

**Where it applies** (anywhere generation and review are both valuable)
- Code review of generated patches
- Fact-checking summarized documents
- Validating extracted data against source
- Second-opinion analysis of architectural recommendations

**Why "self-review with extended thinking" doesn't substitute**
- More thinking from the same context amplifies the same reasoning rather than challenging it
- The independence of context — not the depth of analysis — is what produces the second perspective
- Mirrors human code review: a different reviewer catches things the author missed precisely because they did not live through the decisions that produced the code

**Cost note**
- Two-instance review roughly doubles per-artifact API cost
- Use it where the cost of a missed defect is high (security-critical code, customer-facing summaries, regulated data extraction)
- NOT as a default for every CI run

## 4. The Prompting Technique Hierarchy for CI

The exam repeatedly tests selection of the right prompting technique for the right problem. The decision hierarchy, ordered from simplest to most complex:

**Level 1 — Explicit Criteria**
- **Solves:** Claude flags wrong things / misses right things (both FP and FN)
- **How:** replace vague instructions with specific, targeted criteria defining exactly what to flag
- **Example:** "Flag comments only when claimed behavior contradicts actual code" instead of "check comments are accurate"

**Level 2 — Few-Shot Examples**
- **Solves:** Claude understands WHAT to do but output FORMAT is inconsistent
- **How:** provide 2–4 concrete input/output examples showing the exact structure
- Few-shot examples beat more instructions when instructions alone produce variable results
- **Use for:** output formatting consistency, severity calibration, actionable feedback structure

**Level 3 — Context Provision**
- **Solves:** Claude produces duplicates or misses existing work
- **How:** include relevant context (existing tests, prior findings, related files) in the prompt
- **Example:** include existing test file so Claude doesn't suggest tests already covered

**Level 4 — Multi-Pass Decomposition**
- **Solves:** Claude produces inconsistent depth across many files (attention dilution)
- **How:** split into per-file analysis passes + separate cross-file integration pass
- **Needed for:** large PRs (10+ files) with inconsistent feedback quality, contradictory findings, or missed bugs

> **Exam decision rule**
> - Problem is WHAT Claude looks for → fix criteria (Level 1)
> - Problem is HOW Claude formats output → add examples (Level 2)
> - Problem is Claude lacking information → add context (Level 3)
> - Problem is inconsistent depth across many items → decompose (Level 4)

## 5. CI/CD Architecture Patterns

### 5.1 Self-Review Limitation Pattern

- The same Claude session that generated code retains its reasoning context
- When asked to review its own output, it re-traverses the same logic path and reaches the same conclusion
- A second, independent instance without the generator's reasoning evaluates the code on its own merits
- (Section 3.7 details the two-instance pattern)

**Pattern**
- Generator Instance → produces code → commits changes → Reviewer Instance (no access to generator reasoning) → reviews code independently

**Why self-review fails**
- Extended thinking amplifies the same reasoning
- Self-review instructions ask the same process to reconsider conclusions it already dismissed
- More context doesn't fix a judgment issue
- Only a fresh perspective introduces genuinely independent evaluation

### 5.2 Incremental Review Pattern

- When a review runs again after new commits, without prior context it produces duplicate findings on already-fixed code
- **Fix:** include prior review findings in the prompt and instruct Claude to only report new or still-unaddressed issues

**Anti-patterns**
- Post-processing filters (brittle text matching)
- Scope restriction to latest files only (misses cross-file impacts)
- Skipping intermediate reviews (loses feedback loop)

### 5.3 Trust Erosion Pattern

- High false positive rates in some finding categories undermine trust across ALL categories
- Developers start ignoring everything, including accurate findings
- **Fix:** disable noisy categories immediately, run only high-precision categories to rebuild trust, then re-enable improved categories once they meet quality thresholds

**Key principle**
- In automated review systems, precision (low false positives) matters more than recall for developer trust
- Remove the noise source immediately rather than gradually improving it while trust continues to erode

### 5.4 Attention Dilution Pattern

- When a single-pass review of many files produces inconsistent depth, contradictory feedback, and missed bugs, the root cause is attention dilution
- Too much content for consistent analysis in one pass

**Solution architecture**
- Pass 1 (per-file): analyze each file individually for local issues — consistent depth guaranteed
- Pass 2 (integration): separate pass examining cross-file data flow, interface consistency

**Common distractors**
- "Use a bigger model" — more context window doesn't fix attention distribution
- "Require smaller PRs" — changes developer workflow to accommodate tool limits
- "Run 3 times and majority vote" — expensive, doesn't fix systematic blind spots

## 6. Batch API: Technical Constraints

The Message Batches API has one critical technical constraint beyond latency: it cannot support agentic tool-use loops.

**How an agentic tool-use loop works** (and why batch can't do it)
1. Claude analyzes code
2. Decides it needs more context
3. Calls a tool (e.g., "get file contents")
4. Your code executes the tool, returns the result
5. Claude continues analysis

This requires real-time back-and-forth.

**Why Batch breaks this**
- Batches API is fire-and-forget: submit, poll later
- No mechanism to intercept a tool call mid-request, execute it, and return the result for Claude to continue
- The request either completes without tool execution or it doesn't work

| Batch API Capability | Status |
|---|---|
| Tool definitions in request parameters | Supported (same as sync API) |
| Request correlation via `custom_id` | Supported |
| Mid-request tool execution and return | NOT supported — fundamental blocker |
| Processing window | Up to 24 hours |
| Cost savings | 50% compared to synchronous |

> **Exam tip — Batch API distractor patterns**
> - "Batch API doesn't support tool definitions" → FALSE
> - "No request correlation IDs" → FALSE, `custom_id` handles this
> - "Latency too slow" → PARTIALLY TRUE but not the PRIMARY constraint for agentic workflows
> - The primary constraint for agentic loops is always: cannot execute tools mid-request

## 7. Quick Reference: Question Pattern Recognition

| If the question says... | The answer is usually... |
|---|---|
| "Output is inconsistent / vague / not actionable" | Few-shot examples (2–4 concrete input/output examples) |
| "Claude flags wrong things AND misses right things" | Explicit criteria (replace vague instructions with specific conditions) |
| "Developers waiting / blocks merging" | Synchronous API (never batch for blocking workflows) |
| "Runs overnight / scheduled / weekly" | Message Batches API (50% savings, latency doesn't matter) |
| "Pipeline hangs waiting for input" | `-p` flag (`--print` mode for non-interactive execution) |
| "Duplicate findings after new commits" | Include prior findings in context |
| "Duplicate test suggestions" | Include existing test file in context |
| "Inconsistent depth across many files" | Multi-pass decomposition (per-file + integration) |
| "Same instance reviews its own code" | Independent review instance (two-instance pattern) |
| "Developers ignoring all findings" | Disable noisy categories, keep high-precision ones |
| "High false positive rates" | Precision > recall; remove noise sources immediately |
| "Investigation time is the bottleneck" | Inline reasoning with confidence per finding |
| "Severity ratings are inconsistent" | Explicit criteria with concrete examples per severity level |
| "Validation fails because data isn't in the source" | Make the field nullable; do not retry |
| "Validation fails on format / structure" | Retry with specific error feedback |
| "Need to know which patterns produce noise" | Add `detected_pattern` field to schema for dismissal analysis |
| "Agentic workflow + batch?" | No — batch can't execute tools mid-request |

## 8. Structured Output Tooling for CI

Domain 4 leans heavily on the mechanics of producing reliable structured output.

### 8.1 CLAUDE.md for CI Test Generation Quality

- When Claude Code runs in CI to generate tests, it reads CLAUDE.md for project context
- Higher-quality, more relevant tests result when CLAUDE.md includes:
  - Team's testing standards
  - Preferred assertion libraries
  - Available test fixtures
  - Criteria for valuable tests

**Applied example**
- Team uses Vitest with React Testing Library and shared fixtures in `/test/fixtures/`
- Without CLAUDE.md guidance: Claude generates Jest-syntax tests with inline mock data
- With the right CLAUDE.md entry: it uses Vitest, references existing fixtures, and focuses on integration tests rather than trivial unit tests for getters/setters

```markdown
## Testing Standards
- Framework: Vitest + React Testing Library
- Shared fixtures: /test/fixtures/ (mock API responses, user objects)
- Valuable tests: Integration tests, error boundary tests, edge cases
- Low-value tests: Trivial getters/setters, snapshot tests of static content
- Always test error states alongside happy paths
```

**Exam trap**
- A question may present CLAUDE.md as a distractor for output formatting (wrong) versus a correct answer for test quality context (right)
- CLAUDE.md provides project context and standards, NOT per-task output format instructions

### 8.2 `tool_use` with JSON Schemas for Guaranteed Structured Output

**The pattern**
- Don't prompt Claude to "respond in JSON format" — that can produce malformed JSON, markdown-wrapped JSON, or extra explanatory text
- Instead: define a tool with a JSON schema and force Claude to call it

**What `tool_use` guarantees**
- Output matches the schema structurally: correct types, required fields present, enums respected

**What `tool_use` does NOT prevent**
- Semantic errors (e.g., line items that don't sum to the stated total, or values placed in the wrong fields)

| Error Type | Definition | Prevented by `tool_use`? |
|---|---|---|
| Syntax errors | Malformed JSON, missing brackets, extra text outside JSON | YES — eliminated entirely |
| Structural errors | Wrong types, missing required fields, invalid enum values | YES — schema enforces structure |
| Semantic errors | Valid JSON but wrong values: amounts don't sum, data in wrong field | NO — requires validation-retry loop |

**Applied example**
- A CI pipeline extracts code review findings
- Define a tool `report_finding` with schema `{ file: string, line: integer, severity: enum["critical","warning","info"], description: string, suggested_fix: string | null }`
- Force Claude to call it with `tool_choice: {"type": "tool", "name": "report_finding"}`
- Every finding has the correct structure
- Claude might still put a line number from the wrong file — that's a semantic error caught by validation

### 8.3 `tool_choice` Configuration Options

| `tool_choice` Value | Behavior | CI/CD Use Case |
|---|---|---|
| `"auto"` (default) | Claude decides whether to call a tool OR return text. May skip the tool entirely. | General operation where Claude might not need structured output for every response. |
| `"any"` | Claude MUST call a tool but picks which one. Guarantees structured output from one of the defined schemas. | Multiple finding schemas exist (`security_finding`, `style_finding`) and the applicable one isn't known in advance. |
| `{"type": "tool", "name": "extract_metadata"}` | Claude MUST call this specific named tool. No choice. | Force a mandatory first step: always extract file metadata before running the review analysis. |

**Exam trap**
- A question may describe output that sometimes comes back as conversational text instead of structured JSON
- With `tool_choice: "auto"`, Claude can choose to return text
- Switching to `"any"` forces it to always call a tool, guaranteeing structured output

### 8.4 Nullable/Optional Schema Fields to Prevent Hallucination

- When a JSON schema marks fields as required, Claude will fabricate data rather than leave a required field empty
- Example: if a code review finding might not have a suggested fix, making `suggested_fix` nullable means Claude returns null instead of inventing a fix

- **BAD:** `{ severity: required, suggested_fix: required }` → Claude fabricates: "Consider refactoring this section" (vague, unhelpful)
- **GOOD:** `{ severity: required, suggested_fix: string | null }` → Claude returns: null (honest — no concrete fix available)
- Also use enums with `"other"` + detail: `category: enum["security","performance","other"]` with `category_detail: string | null` for extensible classification.

**Exam trap**
- Questions about extraction accuracy often offer "add few-shot examples showing empty fields" as a distractor
- While that can help, the root fix is schema design: make fields nullable so the model isn't structurally forced to fill them
- Schema design is the programmatic fix; few-shot is the probabilistic fix

### 8.5 Retry-with-Error-Feedback Pattern

When structured output fails validation, don't retry blindly. Send a follow-up request that includes:

1. The original document/code
2. The failed extraction
3. The specific validation error

Claude uses the error message to self-correct. This is fundamentally different from simple retry. Section 3.5 covers when retries help versus when they don't.

**Applied example in CI**
- Claude extracts review findings from a PR diff
- Validation checks that every finding's file path actually exists in the PR's changed files
- Finding #3 references `src/utils/helpers.ts` but that file wasn't changed
- The retry prompt includes: "Finding #3 references `src/utils/helpers.ts`, but this file is not in the PR diff. The changed files are: [list]. Please re-extract finding #3 with the correct file path."

### 8.6 Batch Submission Frequency from SLA Constraints

- The Message Batches API can take up to 24 hours to process
- If the business has an SLA requiring results within a certain window, calculate how often to submit batches to guarantee meeting the SLA in the worst case

**Formula**
- Maximum submission interval = SLA deadline − Maximum batch processing time

**Example**
- SLA: security audit results within 30 hours of code commit
- Batch processing: up to 24 hours (worst case)
- Maximum submission interval: 30 − 24 = 6 hours → submit batches at least every 6 hours
- Commit at hour 0 + next batch at hour 6 → batch finishes at worst by hour 30 → meets SLA exactly
- Submit only once per day → commit at hour 1 isn't batched until hour 24 → finishes by hour 48 → SLA violated

**Exam trap**
- Distractor: "batch processing is often faster than 24 hours so you can submit less frequently"
- The exam rewards worst-case planning, not optimistic estimates
- Always calculate using the maximum 24-hour window

### 8.7 Handling Batch Failures by `custom_id`

- When a batch of 100 requests is submitted, each with a unique `custom_id`, some may fail while others succeed
- Identify failures by `custom_id` and resubmit only those, potentially with modifications

**Failure types and how to resubmit**
- **Context limit exceeded:** file too large → resubmit with the file chunked, or with only changed lines plus surrounding context
- **Validation failure:** output didn't match the schema → resubmit with error feedback appended (Section 8.5)
- **Transient error:** infrastructure failure → resubmit unchanged

**Applied example**
- Batch security audits for 100 files
- 92 succeed; 5 fail with context limit errors; 3 fail with validation errors
- Chunk the 5 large files and resubmit
- Add error feedback to the 3 validation failures and resubmit
- Total: 2 batch submissions instead of re-running all 100

### 8.8 Prompt Refinement Before Batch Processing

**The pattern**
- Before submitting an expensive batch of 1,000 documents, test the prompt on a small representative sample (20–50 documents)
- Fix prompt issues, validate output quality, and iterate until the success rate is high
- Then submit the full batch

**Cost math**
- Without refinement: 60% success rate on 1,000 → 400 fail → resubmit 400 → ~240 succeed, ~160 fail again → ~1,400 API calls total
- With refinement: ~150 test calls on a sample of 50 → achieve 95% success → batch 1,000 → only ~50 fail → ~1,200 calls total
- Cheaper and faster

**Exam trap**
- When batch results have a high failure rate, the distractor "resubmit all failed documents" is wrong
- Correct answer: "refine the prompt on a sample before resubmitting" — the underlying prompt issue causes the same failures again

### 8.9 Verification Passes with Confidence Self-Reporting

- After the initial review pass generates findings, run a second verification pass where Claude evaluates each finding and assigns a confidence level
- Confidence self-reporting is a **routing mechanism** (distinct from inline reasoning in Section 3.4, which reduces developer investigation time):
  - High-confidence findings → directly to developers
  - Low-confidence findings → additional review or human reviewers

| Concept | Purpose | Output |
|---|---|---|
| Inline reasoning | Reduce developer investigation time per finding | Reasoning text next to each finding for human scanning |
| Confidence self-reporting | Route findings to appropriate review channels | Numeric/categorical confidence used by automation to filter/route |

**Applied example**
- A CI pipeline generates 15 findings
- Verification pass scores each: 8 HIGH, 5 MEDIUM, 2 LOW
- HIGH findings post directly as inline PR comments
- MEDIUM findings go into a summary comment
- LOW findings are flagged for a senior engineer to evaluate
- Optimizes reviewer attention

**Important caveat**
- LLM self-reported confidence is not inherently well-calibrated
- Confidence scores should be calibrated using labeled validation sets
- Don't treat raw confidence scores as reliable without calibration

### 8.10 CLI Flags: `--append-system-prompt`, `--allowedTools`, `--dangerously-skip-permissions`

Additional CLI flags from the exam guide's Technologies and Concepts appendix for the CI/CD scenario:

| Flag | Purpose | CI/CD Usage |
|---|---|---|
| `--append-system-prompt` | Adds instructions while preserving Claude Code defaults | Preferred for CI: `claude -p "Review code" --append-system-prompt "Focus on security vulnerabilities"` |
| `--system-prompt` | Completely replaces the default system prompt | Advanced: only when built-in features are NOT needed |
| `--allowedTools` | Restricts which tools Claude can use | Security: `--allowedTools Read` for review-only pipelines; `Read,Write` for test generation |
| `--dangerously-skip-permissions` | Bypasses ALL permission prompts | Required for fully automated CI in isolated containers. Never local dev. |
| `--session-id` / `--resume` | Named sessions for multi-step CI workflows | Multi-turn: analyze, then continue with improvements. ~200k token context per session. |
| `--max-turns` | Limits execution turns | Cost control: prevent runaway sessions in CI |

**Key detail**
- Multi-turn sessions consume 30–50% more tokens than isolated one-shot calls
- For bulk file processing: individual `claude -p` calls per file may be more cost-efficient than maintaining a session
- For tasks where context improves quality (architecture reviews): sessions are worthwhile despite the token overhead
