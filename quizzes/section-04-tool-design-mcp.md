# Quiz: Section 4 — Domain 2: Tool Design & MCP Integration (18%)

**Scope**: Section 4 lectures 4.1–4.14. Tool descriptions as the primary lever for selection reliability, the four-part description anatomy, three tool-selection failure modes, split-vs-consolidate decision rule, the three-field MCP error response (`errorCategory` / `isRetryable` / `description`) and four error categories (transient / validation / business / permission), local recovery vs propagating to coordinator, tool count per agent, `tool_choice` modes, MCP server scope (`.mcp.json` vs `~/.claude.json`), env-variable expansion, MCP resources vs tools, built-in tool selection (Grep / Glob / Read / Edit), and incremental codebase exploration.

**Format**: 10 questions — ~6 multiple choice, ~2 true/false, ~2 multi-select. Every distractor is "almost-right" — a fix that's proportionate in another context but not the right first move here. Domain 2 is the "almost-right" trap domain — the Lecture 1.1 frame applies most directly here.

---

## Q1 (multiple choice) — Domain 2 · Scenarios 1, 4

**Stem:**
Your production agent exposes eight similar tools and misroutes in about 12% of cases — the agent calls `lookup_order` when it should have called `get_customer` first. Which single change is the **most proportionate** first fix?

A) Add a router classifier that pre-selects the tool subset before Claude sees the request.
B) Rewrite each tool's description to include input formats, example queries, edge cases, and the "do NOT use for..." boundary.
C) Switch to `tool_choice: "any"` to force Claude to commit to a tool each turn.
D) Add 3-shot examples in the system prompt showing the right tool for each input pattern.

**Correct Answer:** B

### Explanation
Tool descriptions are the #1 lever for selection reliability — they're what Claude literally reads when deciding. The proportionate fix is rewriting descriptions, especially the "do NOT use for..." boundary line. (A) pre-empts Claude's reasoning entirely and is brittle — the classic Domain 2 distractor. (C) doesn't help Claude pick the *right* tool; it just forces *a* tool call. (D) helps, but it's downstream of the root cause — fix the descriptions first, and few-shots become unnecessary. Every other lever (routers, few-shots, consolidation) is downstream of the description.

---

## Q2 (multiple choice) — Domain 2 · Scenarios 1, 4, 6

**Stem:**
Sample Question 2 of the official exam guide asks what makes a great tool description. Which four-part anatomy matches the exam-guide answer?

A) Name, return type, example output, error cases.
B) Purpose, input formats, example queries, boundaries (when NOT to use).
C) Summary, preconditions, postconditions, invariants.
D) Category, permissions, rate limit, description text.

**Correct Answer:** B

### Explanation
Memorize these four: **Purpose** (one-sentence unambiguous summary), **Input formats** (what identifiers/shapes this accepts), **Example queries** (2–3 concrete uses), **Boundaries** (when to use vs. when NOT to — the "versus" clause that eliminates 80% of misroutes). (A) is an API-doc template, not a description template. (C) is contract-programming vocabulary, not tool-description structure. (D) is operational metadata, not selection-guidance content.

---

## Q3 (multiple choice) — Domain 2 · Scenarios 1, 3

**Stem:**
An MCP tool needs to signal "refund amount exceeds $500 limit; requires human approval." Which three-field response structure does the exam expect?

A) `{ "error": "Operation failed" }`
B) `{ "errorCode": 403, "timestamp": "...", "message": "..." }`
C) `{ "isError": true, "errorCategory": "business", "isRetryable": false, "description": "Refund exceeds $500 limit; escalation required." }`
D) `{ "status": "failed", "retryAfter": 0, "trace": "..." }`

**Correct Answer:** C

### Explanation
Every MCP error response needs three content fields: **errorCategory** (transient / validation / business / permission), **isRetryable** (boolean — tells the agent whether retry is worth attempting), and a human-readable **description**. MCP additionally uses `isError: true` as the top-level failure signal. (A) is the uniform-failure anti-pattern. (B) looks like an HTTP error and is an extremely common almost-right distractor — wrong fields entirely. (D) has superficially reasonable-sounding fields but none of the three required ones. Miss one field → pick the distractor.

---

## Q4 (multiple choice) — Domain 2 · Scenario 1

**Stem:**
A `lookup_order` MCP tool times out. The tool returns `errorCategory: "transient"` with `isRetryable: true`. Meanwhile, a `process_refund` call fails with `errorCategory: "business"` and `isRetryable: false`. Which recovery strategy correctly handles both?

A) Retry both with exponential backoff — all errors are recoverable with enough attempts.
B) Propagate both to the coordinator — subagents should never handle errors locally.
C) Heal the transient locally with retry + backoff; propagate the business error to the coordinator with partial results and recommended action.
D) Swallow the transient (it'll likely resolve) and retry the business error once before escalating.

**Correct Answer:** C

### Explanation
The recovery rule: **transient and validation heal locally; business and permission propagate.** `process_refund` over $500 is a policy violation — retry will fail identically every time, and the right move is structured propagation with partial results so the coordinator or human can act. (A) ignores category semantics and turns business violations into retry storms. (B) bloats the coordinator's context with every recoverable blip. (D) swaps the logic — the transient should retry, not be swallowed; the business error should propagate, not retry.

---

## Q5 (multiple choice) — Domain 2 · Scenarios 3, 4

**Stem:**
A teammate proposes giving the multi-agent research coordinator 18 tools so it "has what it needs for anything." What's the right exam-aligned response?

A) Approve — more tools = more capability, and Claude handles tool selection natively.
B) Push back — selection reliability degrades past ~4–5 tools per agent; scope tools to role and route cross-role needs through the coordinator.
C) Approve, but wrap the 18 tools in a single "mega-tool" with an `action` enum.
D) Push back — 18 tools exceed the MCP tool-count API limit.

**Correct Answer:** B

### Explanation
Selection reliability collapses past ~4–5 tools per agent — 18 tools isn't 18× capability, it's 18× "not this one" reasoning overhead. The right move is scoped distribution: coordinator gets Task + a few policy tools; search subagent gets `web_search` + `load_document`; synthesis subagent gets `verify_fact`; everything else routes through the coordinator. (A) is the "more is better" distractor — the exam hates this answer. (C) just hides 18 tools behind one dispatcher and keeps the selection overhead. (D) invents an API limit that doesn't exist.

---

## Q6 (multiple choice) — Domain 2 · Scenario 6

**Stem:**
You're batch-processing 100 varied documents and need Claude to pick the right extraction schema per document — but you MUST get a tool call every time (no prose responses). Which `tool_choice` value is correct?

A) `"auto"` — let Claude decide whether to call a tool.
B) `"any"` — guarantee a tool call, and let Claude pick which extraction tool matches the document.
C) `{"type": "tool", "name": "extract_v1"}` — force the first extraction tool every time.
D) Leave `tool_choice` unset — the default does the right thing for extraction.

**Correct Answer:** B

### Explanation
`any` guarantees Claude calls *some* tool while still letting Claude pick which tool matches the document — exactly what varied-schema batch extraction needs. (A) doesn't guarantee a tool call; Claude can still return prose. (C) forces one schema regardless of fit, which defeats the per-document match. (D) is identical to `"auto"` (the default) — same problem. Scenario 6 loves this distinction: schema-compliance forcing = `any` with a set of extraction tools, not a single forced tool.

---

## Q7 (true/false) — Domain 2 · Scenarios 2, 4, 5

**Stem:**
**True or False:** An MCP server that's shared across the whole team should be configured in `~/.claude.json` because user scope is more secure than project scope.

A) True
B) False

**Correct Answer:** B (False)

### Explanation
Team-shared MCP servers belong in `.mcp.json` at the **project root**, which is version-controlled and onboards every team member automatically. `~/.claude.json` is **user scope** — personal, not shared. Security doesn't enter the scope decision at all; secrets are handled by env-var expansion (`${GITHUB_TOKEN}`), not by choosing a different file. Putting a shared server in `~/.claude.json` is the #1 Domain 2/3 onboarding bug — new hires silently lack tools, CI silently lacks tools, and only you (who has the user-scope config) don't see the breakage.

---

## Q8 (multi-select) — Domain 2 · Scenarios 2, 4, 5

**Stem:**
Select ALL of the following that correctly distinguish MCP **Resources** from MCP **Tools**. (Choose two.)

A) Tools perform actions or dynamic fetches — they have side effects or take parameters that drive the result.
B) Resources expose browsable content upfront (issue lists, doc catalogs, schemas) so Claude can reference them without a tool call.
C) Resources are deprecated; Tools are the modern replacement.
D) Resources are for file reads only; Tools are for everything else.

**Correct Answers:** A, B

### Explanation
The clean distinction: **tools DO, resources EXPOSE**. (A) captures tools — verbs, actions, parameterized. (B) captures resources — nouns, catalogs, browsable content that cuts exploratory tool calls. (C) is flatly wrong; both are first-class MCP primitives. (D) is the most tempting almost-right — it sounds like a reasonable simplification but miscategorizes file reads (which can be either — a catalog of available docs as a resource, a parameterized search as a tool).

---

## Q9 (multiple choice) — Domain 2 · Scenarios 2, 4, 5

**Stem:**
A developer needs Claude to find every caller of `process_refund` in a large codebase. Which built-in tool is correct?

A) `Glob` — pattern-match against paths like `**/*refund*`.
B) `Grep` — search file contents for the symbol `process_refund`.
C) `Read` — load every file in the repo to scan for callers.
D) `Edit` — use the find-and-replace feature to enumerate matches.

**Correct Answer:** B

### Explanation
**Grep = content.** Grep searches *inside* files for text — the right tool when you need "every caller of X." (A) `Glob` matches *paths*, not content — fine for `**/*.test.tsx`, wrong for symbol callers. (C) blows through context and is the canonical exploration anti-pattern — never read-everything-upfront. (D) misuses Edit, which is for targeted changes with a unique anchor, not for discovery. Treating Grep as a file finder or Glob as a content search is a Domain 2 classic distractor.

---

## Q10 (multiple choice) — Domain 2 · Scenarios 2, 4, 5

**Stem:**
A shared `.mcp.json` needs a GitHub token for a GitHub MCP server, but the repo is checked into version control. Which configuration is correct?

A) `"token": "ghp_abc123..."` — commit the token so new teammates have it on clone.
B) Put the token in `.mcp.json` but add `.mcp.json` to `.gitignore` so it isn't committed.
C) Use env-var expansion: `"env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }`, commit the config, and load the value from each developer's `.env`.
D) Create a second `~/.claude.json` that only holds the token and ignore `.mcp.json` for secrets.

**Correct Answer:** C

### Explanation
Env-var expansion is the right pattern: commit the config (with `${GITHUB_TOKEN}` placeholders), don't commit the secret (in `.env`, gitignored). Onboarding: clone repo → `cp .env.example .env` → fill in personal token → Claude starts → server authenticates. (A) leaks credentials into git history — always wrong. (B) defeats the point of the shared config; now new hires have no MCP setup at all. (D) splits configuration across files inconsistently and still doesn't solve the per-developer-token problem. If the question mentions team sharing AND credentials, the answer is env-var expansion.
