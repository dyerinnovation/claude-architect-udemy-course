# Quiz: Section 3 — Domain 1: Agentic Architecture & Orchestration (27%)

**Scope**: Section 3 lectures 3.1–3.14. The agentic loop and `stop_reason`, `tool_use` vs `end_turn`, the five agentic-loop anti-patterns, hub-and-spoke coordination, the coordinator's decompose-delegate-aggregate role, subagent context isolation, the Task tool, parallel subagent execution, explicit context passing, programmatic vs prompt-based enforcement, PostToolUse hooks, task decomposition patterns, session management (`--resume` / `fork_session` / `/compact`), and structured handoff summaries.

**Format**: 10 questions — ~6 multiple choice, ~2 true/false, ~2 multi-select. Every distractor is "almost-right" — a pattern that works in another context but fails in this one. Domain 1 is 27% of the exam and tested most heavily in Scenarios 1 (Customer Support) and 3 (Multi-Agent Research).

---

## Q1 (multiple choice) — Domain 1 · Scenario 1

**Stem:**
You're reviewing a teammate's agent implementation. The main loop looks like this:
```python
for attempt in range(10):
    response = client.messages.create(...)
    if "task complete" in response.content[0].text.lower():
        break
```
Which anti-pattern is present? Pick the most severe issue.

A) The iteration cap is too low — 10 is insufficient for multi-step agents.
B) The loop uses text parsing instead of `response.stop_reason` as the control signal.
C) The loop should use `while True` with no cap at all — caps silently truncate.
D) The loop should parse `response.content[-1]` instead of `[0]` to catch the latest block.

**Correct Answer:** B

### Explanation
The fundamental flaw is using response *text* to decide continuation instead of `response.stop_reason`. `stop_reason` is a structured API contract — always present, always one of a defined set — while text output is nondeterministic. (A) is a legitimate secondary concern, but even raising the cap doesn't fix text parsing. (C) is itself an anti-pattern — caps belong as safety guards, just not as the primary exit. (D) is syntactic nitpicking and doesn't address the structural problem.

---

## Q2 (multiple choice) — Domain 1 · Scenario 1

**Stem:**
A `lookup_order` tool returns an error ("Order not found"). Your agent loop currently terminates on any tool error and surfaces the error to the user. What should change?

A) Keep terminating — tool errors are unrecoverable; retrying wastes tokens.
B) Append the error as a `tool_result` with `is_error: true` and continue the loop so Claude can reason about alternatives.
C) Swallow the error silently, re-run the tool with the same arguments, and only surface after three retries.
D) Re-prompt the user to clarify their request before continuing.

**Correct Answer:** B

### Explanation
Tool errors belong back in the loop as `tool_result` blocks with `is_error: true`. Claude can then reason about the failure — try different arguments, switch to a different tool, or explain the situation to the user. (A) is the textbook anti-pattern from Lecture 3.3 and collapses Claude's recovery ability. (C) hides errors and creates retry storms — an exam classic wrong-answer. (D) bypasses Claude's reasoning with a hardcoded clarification step, which is exactly what the agent should be choosing itself.

---

## Q3 (multiple choice) — Domain 1 · Scenario 3

**Stem:**
A coordinator needs to research three competing vendors in parallel. Which Task-tool invocation pattern correctly achieves parallel subagent execution?

A) One Task call containing all three vendors; the subagent researches them sequentially.
B) Three Task calls issued in the same `assistant` turn's `content` array.
C) Three serial Task calls, each after the prior subagent returns, so results accumulate cleanly.
D) A single Task call to a "research-all" subagent that loops internally over vendors.

**Correct Answer:** B

### Explanation
True parallel execution happens when the coordinator emits multiple Task tool-use blocks in a *single* assistant turn. The Agent SDK fans those out concurrently and returns all results before the coordinator's next turn. (A) is pseudo-parallel — one subagent doing sequential work is just serial in disguise. (C) is explicitly serial — what Scenario 3 distractors try to sell as "safer." (D) collapses the fan-out entirely and loses the parallelism benefit. Parallel = multiple Task blocks in one turn.

---

## Q4 (multiple choice) — Domain 1 · Scenario 3

**Stem:**
A new developer assumes that because the coordinator has the full conversation history, any subagent it spawns via the Task tool "inherits" that history. Why is this assumption a problem?

A) It's not a problem — subagents do inherit the coordinator's history automatically.
B) Subagents spawned by Task do NOT inherit history; context must be explicitly passed in the subagent's prompt.
C) Subagents inherit only the last three turns, so history is partially lost — design around the truncation.
D) History inheritance depends on the Claude model; Opus inherits, Sonnet doesn't.

**Correct Answer:** B

### Explanation
Every Task call creates a fresh, isolated subagent instance. Subagents receive *only* what's in their prompt — no coordinator turns, no prior tool results, no standing context. The developer must explicitly pass whatever the subagent needs to know. (A) is the most common and dangerous misconception — assume it, and your subagent operates on empty context. (C) invents a partial-inheritance rule that doesn't exist. (D) invents a model-dependent behavior that doesn't exist.

---

## Q5 (multiple choice) — Domain 1 · Scenarios 1, 3

**Stem:**
Your refund-processing agent has a policy: refunds over $500 must always route to a human. A teammate proposes enforcing this with a line in the system prompt: "Never process refunds over $500." Why is this the wrong approach?

A) System-prompt-only enforcement is probabilistic, not deterministic — Claude may comply most of the time but can be jailbroken or confused. Hard business constraints need programmatic enforcement.
B) The system prompt is fine as long as `temperature = 0`; deterministic sampling makes it safe.
C) System prompts only apply for the first three turns, so the constraint will decay.
D) Claude can't compare numeric values reliably; the $500 threshold won't be respected.

**Correct Answer:** A

### Explanation
The fundamental fork: **programmatic = deterministic, prompt = probabilistic**. Financial controls, identity checks, and compliance boundaries must be programmatic (e.g., wrap `process_refund` in code that enforces the cap and rejects before Claude ever calls it). System-prompt rules are fine for style, tone, and soft preferences. (B) misunderstands `temperature` — low temperature doesn't make prompt compliance deterministic. (C) invents a decay rule that doesn't exist. (D) misrepresents Claude's actual reasoning ability. The exam tests this fork repeatedly.

---

## Q6 (true/false) — Domain 1 · Scenarios 1, 3

**Stem:**
**True or False:** In a hub-and-spoke multi-agent system, the primary architectural value is load balancing — distributing work evenly across subagents so the total system runs faster.

A) True
B) False

**Correct Answer:** B (False)

### Explanation
The hub-and-spoke pattern's real value is **centralized observability, control, and coordination** — the coordinator can see every subagent's result, route between them, and maintain system-wide reasoning. Speed-through-load-balancing is a nice side effect but not the *primary* justification, and it's the tempting almost-right answer. Peer-to-peer topologies can also load-balance, but they lose the observability benefit. When an exam question asks "why hub-and-spoke," the answer is centralized control, not speed.

---

## Q7 (multiple choice) — Domain 1 · Scenario 3

**Stem:**
A research subagent finishes and the coordinator needs the findings plus source attribution. What's the right way to pass results back to the coordinator?

A) A single natural-language summary paragraph; the coordinator re-derives citations from context.
B) A structured payload: claim-source mappings with source URL, document name, page number, publication date.
C) The raw tool outputs concatenated, so nothing is lost in translation.
D) A compressed summary; full attribution is only needed for human review, not agent-to-agent handoff.

**Correct Answer:** B

### Explanation
Explicit context passing preserves attribution metadata — claim, source URL, document, page, date — in a structured form the coordinator can act on without re-research. (A) is the common lazy pattern; the coordinator can't re-derive citations it never saw. (C) bloats the coordinator's context with unfiltered data and defeats the subagent's purpose. (D) confuses human-readable with agent-readable; both layers need the same attribution fidelity for multi-hop research.

---

## Q8 (multi-select) — Domain 1 · Scenario 1

**Stem:**
Select ALL of the elements that a structured handoff summary to a human support agent MUST include. (Choose three.)

A) The full Claude conversation transcript, turn by turn.
B) Customer identifier (e.g., customer_id or email).
C) Root cause and amounts in dispute.
D) Recommended action and what the agent already attempted.
E) The Claude model version used and temperature setting.

**Correct Answers:** B, C, D

### Explanation
Human agents receiving an escalation don't have the Claude transcript — they need a structured summary of what matters: **who** (customer ID), **what's wrong and how much** (root cause + amounts), **what's been tried and what should happen next** (attempted steps + recommendation). (A) is the wrong instinct — the transcript is noise for a human and bloats the handoff. (E) is implementation metadata that has no bearing on the human's next action. This pattern is tested directly in Scenario 1 (Customer Support).

---

## Q9 (multiple choice) — Domain 1 · Scenario 1

**Stem:**
An agent has been running for 30 turns on a long-running debugging session. The context is getting heavy but the work is not complete and the tool results so far are still valid. What's the right session-management move?

A) `fork_session` — create a divergent branch from the current state.
B) Start a fresh agent with no context and let it re-derive everything.
C) Use `/compact` — summarize the existing context in place, preserving prior tool results.
D) Use `--resume` on a different session ID to merge contexts.

**Correct Answer:** C

### Explanation
`/compact` summarizes the running session in place, keeping the valid tool results and decisions while reducing token weight. That's exactly the "context getting heavy but results still valid" case. (A) `fork_session` is for exploring *divergent approaches* from a shared baseline — wrong tool for in-place compression. (B) throws away valid work and forces re-derivation. (D) misrepresents `--resume` — it reloads a prior session, not merges across them. Know each of these four levers and the situation it fits.

---

## Q10 (multiple choice) — Domain 1 · Scenario 3

**Stem:**
A junior engineer decomposes a "build a product research report" task into 17 tiny subagents: one per metric, one per competitor, one per section heading. Why is this worse than decomposing into 4–5 larger subagents?

A) Narrow subagents refuse to complete tasks too small for their reasoning budget.
B) Every extra subagent adds coordination overhead, fragments context, and increases the chance of redundant work or lost attribution.
C) Anthropic's API rate-limits parallel subagents at 4 per coordinator turn.
D) Narrow decomposition makes the system run faster but with degraded accuracy.

**Correct Answer:** B

### Explanation
Over-decomposition creates coordination overhead, context fragmentation (each subagent only knows its tiny slice), redundant work, and higher latency. Decompose by **logical cohesion**, not granularity — a subagent should own a unit of work a single capable agent could complete. (A) invents a behavioral rule that doesn't exist. (C) invents a rate limit that doesn't exist. (D) is the tempting almost-right — narrower subagents sound more parallel, but the coordination tax usually makes the *system* slower, not faster.
