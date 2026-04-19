# Quiz: Final Review — 20 Things Cold

**Section**: Section 10 — Quick Reference & Final Review
**Coverage**: All 5 domains — rapid-fire on highest-probability concepts
**Questions**: 10

---

## Question 1
**Which of the following is the COMPLETE set of required fields for a structured MCP error response?**

- A) `errorCode`, `message`, `retryable`
- B) `errorCategory`, `isRetryable`, `description`
- C) `error`, `type`, `canRetry`, `message`
- D) `status`, `errorCategory`, `isRetryable`

**Correct Answer**: B

**Explanation**: The three required fields are exactly: `errorCategory` (the type of error), `isRetryable` (boolean — can the caller retry this operation), and `description` (human-readable explanation). (A) uses incorrect field names (`errorCode`, `retryable`). (C) adds an extra field (`canRetry` vs `isRetryable`) and uses wrong names. (D) adds a `status` field that is not part of the standard error response.

**Domain**: Domain 2 — Tool Design & MCP

---

## Question 2
**What does setting `tool_choice: "any"` guarantee about Claude's response?**

- A) Claude will call exactly one tool
- B) Claude will call the first tool in the tools array
- C) Claude must call at least one tool — it cannot return a text-only response
- D) Claude will select the most recently used tool

**Correct Answer**: C

**Explanation**: `tool_choice: "any"` guarantees that Claude will use at least one of the available tools — it cannot return a pure text response. This is the mechanism for guaranteeing structured output when tool use is required. (A) is wrong — "any" doesn't limit to exactly one call; Claude may call multiple tools. (B) is wrong — Claude selects based on relevance, not array position. (D) is invented behavior that doesn't exist.

**Domain**: Domain 2 / Domain 4 — Tool choice, structured output

---

## Question 3
**In the CLAUDE.md configuration hierarchy, which rule takes precedence when a conflict exists?**

- A) User-level rules (~/CLAUDE.md) always override project-level rules
- B) Project-level rules always override directory-level rules
- C) The most specific matching rule takes precedence — directory-level overrides project-level overrides user-level
- D) Rules are additive — all matching rules apply equally with no precedence

**Correct Answer**: C

**Explanation**: The CLAUDE.md hierarchy follows specificity: directory-level (most specific) overrides project-level, which overrides user-level. This allows teams to set broad project guidelines while allowing directory-specific overrides for specialized components. (A) is backwards — user-level is least specific. (B) is partially right about the direction but misses that directory-level is even more specific than project-level. (D) is wrong — when rules conflict, the most specific wins.

**Domain**: Domain 3 — Claude Code configuration

---

## Question 4
**A database tool returns `{"results": []}`. Which of the following best describes this response?**

- A) An error occurred — the tool should set `is_error: true`
- B) A successful response — the query ran correctly but found no matching records
- C) An ambiguous state — the caller should retry to confirm
- D) A permission error — the tool could not access the database

**Correct Answer**: B

**Explanation**: An empty results array is a successful response — the query executed correctly and found nothing matching the criteria. This is distinct from an error, where the operation failed (permissions, connectivity, malformed query). (A) is wrong — errors use `is_error: true` and contain errorCategory, not an empty results array. (C) is wrong — empty results are deterministic; retrying won't change a genuinely empty dataset. (D) is wrong — a permission error would use errorCategory: "permission" with isRetryable: false, not an empty results array.

**Domain**: Domain 2 / Domain 5 — Error handling, empty vs. failure

---

## Question 5
**When should you use the Message Batches API instead of the synchronous Messages API? (Select all that apply.)**

- A) When you need real-time response streaming
- B) When processing a large volume of independent, non-time-sensitive requests
- C) When you need multi-turn tool use within each request
- D) When cost optimization is the primary concern and 24-hour latency is acceptable
- E) When requests can run in parallel and don't depend on each other's outputs

**Correct Answers**: B, D, E

**Explanation**: The Batches API is appropriate when: (B) you have many independent requests to process (the batch approach excels at scale), (D) you don't have real-time latency requirements and want 50% cost savings, and (E) requests are independent (the Batches API doesn't support chaining outputs). (A) is wrong — the Batches API does NOT support streaming; use synchronous API for real-time needs. (C) is wrong — multi-turn tool use requires synchronous API because each turn depends on the previous tool result.

**Domain**: Domain 4 — Message Batches API

---

## Question 6
**What is the "lost in the middle" effect in the context of Claude's context window?**

- A) Important information placed in the middle of a long conversation is less reliably attended to than information at the beginning or end
- B) Tool results that appear in the middle of a multi-turn conversation are silently discarded
- C) Claude loses track of the original user request after more than 10 tool calls
- D) Instructions in the middle of the system prompt are overridden by instructions at the beginning

**Correct Answer**: A

**Explanation**: The "lost in the middle" effect describes the observation that language models — including Claude — attend more reliably to information at the beginning and end of context than in the middle of long inputs. This is a fundamental characteristic of attention patterns in transformer models. (B) is fabricated — tool results are not discarded. (C) is fabricated — there's no 10-tool-call limit. (D) describes instruction conflict, not the middle effect.

**Domain**: Domain 5 — Context management

---

## Question 7
**Which of the following is the correct `tool_choice` value to force Claude to call a specific tool named `extract_invoice_data`?**

- A) `"extract_invoice_data"`
- B) `{"type": "auto", "name": "extract_invoice_data"}`
- C) `{"type": "tool", "name": "extract_invoice_data"}`
- D) `{"force": true, "tool": "extract_invoice_data"}`

**Correct Answer**: C

**Explanation**: Forcing a specific tool requires the object form `{"type": "tool", "name": "tool_name"}`. (A) is wrong — a bare string is not valid for named tool forcing. (B) uses `"auto"` type, which means Claude decides; `"auto"` with a name is not a valid combination. (D) uses invented field names (`force`, `tool`) that don't match the API.

**Domain**: Domain 2 / Domain 4 — tool_choice

---

## Question 8
**True or False: When a subagent in a hub-and-spoke architecture completes its task, it should send its results directly to sibling subagents that depend on those results.**

- A) True — direct communication between subagents is faster and reduces coordinator overhead
- B) False — all communication flows through the coordinator; subagents never communicate directly

**Correct Answer**: B

**Explanation**: In hub-and-spoke architecture, subagents never communicate directly with each other. All results flow back to the coordinator, which then decides what to pass to dependent subagents. This is a fundamental principle of the architecture that enables centralized observability and error handling. Direct subagent-to-subagent communication creates mesh topology with unpredictable behavior.

**Domain**: Domain 1 — Multi-agent architecture

---

## Question 9
**Which of the following topics are explicitly OUT OF SCOPE for the CCA-F exam? (Select all that apply.)**

- A) Fine-tuning Claude models on custom datasets
- B) Tool description design and selection reliability
- C) Prompt caching internals and cache hit rates
- D) MCP server configuration at project and user scope
- E) Embeddings and vector database integration

**Correct Answers**: A, C, E

**Explanation**: (A) Fine-tuning is out of scope — the CCA-F tests how to use Claude, not how to train it. (C) Prompt caching internals are out of scope — caching may be mentioned but detailed mechanics are not tested. (E) Embeddings and vector databases are out of scope — the exam focuses on the Messages API, Claude Code, and MCP, not retrieval architectures. (B) and (D) are in scope — tool description design is Domain 2 and MCP scope configuration is Domain 2/3.

**Domain**: Overview — Out-of-scope topics

---

## Question 10
**What is the escalation decision rule for a customer support agent that receives this message: "I've been on the phone with three agents today, and nobody can help me. I just want to cancel my account."?**

- A) Escalate immediately — account cancellation is a high-value action requiring human judgment
- B) The agent should attempt to retain the customer before escalating
- C) Escalate immediately — the customer has explicitly requested resolution from a higher authority (multiple agents)
- D) Escalate immediately — the customer explicitly stated their desired action (cancel), which constitutes an explicit request

**Correct Answer**: D

**Explanation**: The customer explicitly stated "I want to cancel my account" — this is an explicit customer-directed action. Explicit requests must be honored immediately without attempting to override or delay. (A) is partially right reasoning but the correct reason is explicit request, not complexity. (B) is wrong — attempting retention after an explicit cancellation request violates the escalation principle of honoring explicit requests. (C) is wrong reasoning — the trigger isn't that they talked to multiple agents (that's frustration/complexity), it's the explicit stated desire to cancel.

**Domain**: Domain 1 / Domain 5 — Escalation framework
