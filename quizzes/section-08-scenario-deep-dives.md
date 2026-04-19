# Quiz: Scenario Deep Dives

**Section**: Section 8 — Scenario Deep Dives
**Coverage**: All 6 exam scenarios — common traps and cross-domain patterns
**Questions**: 10

---

## Question 1
**In the Customer Support Resolution Agent scenario, a customer message says: "I've been waiting three weeks for my refund and I am furious. This is completely unacceptable." What is the correct agent response?**

- A) Escalate immediately to a human agent because the customer expressed strong frustration
- B) Attempt to resolve the refund issue using available tools, but offer escalation if the customer explicitly requests it
- C) Apologize and close the ticket without taking action because emotional customers cannot be helped by automated systems
- D) Continue investigating the refund without acknowledging the customer's emotional state

**Correct Answer**: B

**Explanation**: Frustration and emotional intensity are NOT valid escalation triggers. The correct triggers are: the customer explicitly requests a human agent, policy is silent on the situation, or the agent is unable to progress. (A) is wrong because sentiment alone does not mandate escalation — the agent should attempt resolution first and offer escalation. (C) is wrong because automated agents can and should help emotional customers with concrete actions. (D) is wrong because ignoring emotional state leads to poor customer experience even if the action taken is correct.

**Domain**: Domain 1 / Domain 5 — Agentic Architecture, Context Management

---

## Question 2
**In the Multi-Agent Research System scenario, the web search subagent successfully returns results but the document analysis subagent fails with a timeout. What should the coordinator do?**

- A) Terminate the entire pipeline and return an error to the user
- B) Retry the document analysis subagent up to 3 times, then terminate if it still fails
- C) Continue with available results, include a coverage gap annotation in the synthesis output noting the failed subagent, and propagate a structured error upward
- D) Silently ignore the failed subagent and synthesize only from the web search results without noting the gap

**Correct Answer**: C

**Explanation**: When a subagent fails, the coordinator should continue with available results and explicitly annotate coverage gaps in the output. This preserves the value of completed work while being transparent about what's missing. (A) is too aggressive — partial results are often useful. (B) is reasonable in some contexts but the answer choice doesn't include coverage annotations and structured error propagation, which are required. (D) is wrong because silently ignoring the gap is a reliability failure — the consumer of the synthesis output has no way to know the information is incomplete.

**Domain**: Domain 1 / Domain 5 — Multi-agent coordination, Error propagation

---

## Question 3
**The Developer Productivity with Claude scenario involves designing a tool that searches a codebase. A developer reports that Claude is calling `search_files` when it should be using `search_code_content`. Which is the most likely root cause?**

- A) Claude's context window is too full to make good tool selections
- B) The tool descriptions for `search_files` and `search_code_content` overlap or don't clearly distinguish their use cases
- C) The developer is using too many tools — the tool list should be reduced to one search tool
- D) Claude cannot reliably select between two tools with similar names

**Correct Answer**: B

**Explanation**: Tool selection failures are almost always caused by overlapping or ambiguous tool descriptions. When two tools have similar names and unclear descriptions, Claude cannot reliably distinguish when to use each. (A) is possible but not the most likely cause for a selection error between two specific tools. (C) is the wrong direction — reducing to one tool loses capability; the fix is better descriptions. (D) is false — Claude can reliably select between similarly-named tools when their descriptions clearly specify different use cases.

**Domain**: Domain 2 — Tool Design

---

## Question 4
**In the CI/CD Pipeline scenario, a code review runs successfully on the first commit but returns duplicate findings when the pipeline re-runs after a minor whitespace change. What is the best architectural fix?**

- A) Disable the code review for commits that don't change logic files
- B) Add a deduplication step that compares new findings against previously reported ones using stable finding identifiers
- C) Use the Message Batches API instead of synchronous API to avoid duplicate runs
- D) Reduce the review scope to only changed lines rather than the full file

**Correct Answer**: B

**Explanation**: The correct solution is deduplication using stable identifiers (e.g., file + line + rule hash). This allows the pipeline to re-run safely without flooding issue trackers with repeated findings. (A) is too aggressive — whitespace changes often accompany logic changes. (C) uses the wrong tool for this problem — Batches API doesn't solve deduplication logic. (D) only reviewing changed lines would miss context-dependent issues and is an incomplete approach.

**Domain**: Domain 3 / Domain 4 — Claude Code CI integration, Prompt engineering

---

## Question 5
**In the Structured Data Extraction scenario, Claude is tasked with extracting invoice data from documents with varying formats. Some documents use "Total Due" and others use "Amount Owed" for the same field. Which approach most reliably ensures correct extraction?**

- A) Add explicit instructions in the system prompt listing all known field name variants
- B) Define a JSON schema with the target output structure and use tool_choice: "any" to guarantee structured output
- C) Use the Message Batches API because the extraction is idempotent and cost is a concern
- D) Use few-shot examples showing extractions from documents with different field names

**Correct Answer**: D

**Explanation**: When Claude makes systematic errors on ambiguous inputs (like varying field names), few-shot examples are the most effective tool. They show Claude exactly how to map non-standard field names to the expected schema. (A) is a reasonable first attempt but listing variants in a prompt is brittle — new variants won't be covered. (B) is valuable for structure enforcement but doesn't solve the field-name mapping problem. (C) addresses cost and scale but not the core accuracy problem. The right answer is (D) because few-shot examples teach Claude the mapping pattern, which generalizes to new field name variants.

**Domain**: Domain 4 — Prompt engineering, Few-shot examples

---

## Question 6
**In the Code Generation with Claude Code scenario, a developer wants certain team-wide coding standards enforced for all TypeScript files. Which CLAUDE.md configuration achieves this most precisely?**

- A) Add rules to the project-level CLAUDE.md with instructions covering all TypeScript conventions
- B) Create a `.claude/rules/` file with YAML frontmatter `paths: ["**/*.ts", "**/*.tsx"]` containing the TypeScript-specific rules
- C) Add the rules to `~/.claude.json` so they apply to all Claude Code sessions
- D) Create a custom slash command that developers must run manually before committing

**Correct Answer**: B

**Explanation**: `.claude/rules/` files with YAML frontmatter glob patterns apply rules specifically to matched file paths. This is the most precise configuration for TypeScript-specific rules because the rules only activate when Claude is working on `.ts`/`.tsx` files. (A) would apply the TypeScript rules to all files, not just TypeScript. (C) is user-scoped (personal) and wouldn't apply across the team. (D) requires manual execution and can be skipped.

**Domain**: Domain 3 — Claude Code configuration

---

## Question 7
**A Customer Support agent correctly identifies that a customer's order hasn't shipped, but the customer's account shows a billing dispute that prevents processing refunds. The agent has a `process_refund` tool and a `check_billing_status` tool. What is the correct action?**

- A) Attempt to process the refund anyway and handle any errors from the payment system
- B) Escalate immediately because the agent cannot complete the task
- C) Use `check_billing_status` first; if a dispute is confirmed, explain the constraint to the customer and offer escalation
- D) Call `process_refund` and `check_billing_status` in parallel to save time

**Correct Answer**: C

**Explanation**: The correct pattern is: check constraints before taking irreversible actions. If a billing dispute blocks the refund, the agent should explain the situation clearly and offer escalation. (A) is wrong — attempting an action that's known to be blocked wastes a tool call and may generate a confusing error. (B) is premature — the agent hasn't reached a genuine dead end yet; it can still communicate the situation. (D) is wrong because checking billing status is a prerequisite for deciding whether to process the refund — these are sequential, not parallel.

**Domain**: Domain 1 — Agentic Architecture, programmatic enforcement

---

## Question 8
**In the Multi-Agent Research System scenario, the coordinator spawns three subagents for parallel research. In the coordinator's response, how many Task tool calls should appear?**

- A) Three Task calls, each in a separate coordinator response turn
- B) Three Task calls, all appearing in a single coordinator response
- C) One Task call per subagent, sent sequentially after each previous subagent returns
- D) The coordinator sends a single Task call with a list of three tasks in the input

**Correct Answer**: B

**Explanation**: Parallel subagent execution requires all Task tool calls to appear in a single coordinator response. The coordinator issues all three Task calls in one turn, then the framework executes them in parallel and returns all results together. (A) is sequential execution across three turns, which is not parallel. (C) is also sequential, explicitly waiting for each subagent before spawning the next. (D) is not the Task tool API format — Task spawns one agent per call.

**Domain**: Domain 1 — Multi-agent orchestration, parallel execution

---

## Question 9
**Which of the following is a cross-domain pattern that appears in BOTH the Customer Support scenario (Domain 1) and the Structured Data Extraction scenario (Domain 4)?**

- A) Programmatic enforcement of workflow ordering
- B) Using tool_choice: "any" to guarantee structured output
- C) Distinguishing between an empty valid result and an access failure
- D) Path-specific rules via CLAUDE.md frontmatter

**Correct Answer**: C

**Explanation**: Distinguishing empty valid results (the query succeeded but found nothing) from access failures (the tool couldn't run) appears in both scenarios. In Customer Support, an order search returning no results is different from a database connection failure. In Structured Data Extraction, a document with no matching fields is different from a parsing error. (A) appears in Domain 1 scenarios but not prominently in Domain 4. (B) is Domain 4-specific. (D) is Domain 3-specific.

**Domain**: Domain 5 / Cross-domain — Error handling, reliability

---

## Question 10
**A Claude Code CI/CD pipeline is generating too many false-positive security findings, causing developers to ignore the review output. Which is the MOST effective first intervention?**

- A) Switch to a larger model (Opus) for the code review task
- B) Add explicit criteria to the prompt specifying exactly which patterns to flag and which to skip, with concrete examples for ambiguous cases
- C) Reduce the review scope to only flag critical severity issues
- D) Run the review multiple times and take the majority result

**Correct Answer**: B

**Explanation**: False positives are primarily caused by vague prompt criteria. Adding explicit criteria with concrete examples of what to flag versus skip is the highest-leverage intervention — it addresses the root cause. (A) model capability is not the bottleneck when the issue is unclear instructions. (C) reduces scope but doesn't fix the underlying vagueness — you'll still get false positives within the reduced scope. (D) majority voting doesn't help with systematic false positives caused by vague criteria — all instances will make the same mistakes.

**Domain**: Domain 4 — Prompt engineering, reducing false positives
