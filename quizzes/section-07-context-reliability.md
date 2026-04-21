# Quiz: Context Management & Reliability (Domain 5)

Domain 5 - Context Management & Reliability (15% of exam). Primary scenarios: 1 (Customer Support), 3 (Multi-Agent Research), 6 (Structured Extraction).

---

## Question 1
**A multi-agent synthesis pipeline aggregates findings from 20 subagents into one document before producing a final report. The report consistently misses findings from the middle subagents, even though the subagents themselves ran successfully. Which set of mitigations targets the root cause?**

- A) Switch to a larger-context model; the middle findings are being truncated
- B) Put the synthesis summary at the TOP of the aggregated input, use explicit `## Source N` section headers, and order subagent outputs by importance rather than chronology
- C) Lower temperature on the synthesis call to reduce variance
- D) Run the synthesis twice and union the findings

**Correct Answer**: B

### Explanation
The symptom — middle-positioned findings omitted even though inputs were complete — is the "lost in the middle" effect, not truncation. Attention is strongest at the beginning and end of long inputs; the middle drops. The right fix is structural: lead with a synthesis summary, add explicit section headers, and place the highest-signal content where attention is strongest. (A) is the classic distractor — the issue isn't size, it's position; a larger context window has the same problem at a different scale. (C) and (D) don't address position at all.

**Domain**: Domain 5 · **Scenarios**: 1, 3, 6 · **Format**: Multiple choice

---

## Question 2
**A customer-support agent handles a session where the customer requests a $47.82 refund and mentions a specific policy exception. Three summarization rounds later, the agent remembers "customer wanted a refund" but has lost the exact amount and the exception. Which pattern would have prevented this?**

- A) Use a larger summarization window so more detail survives each round
- B) Add the customer's message verbatim to every future prompt
- C) Extract transactional facts (customer_id, amounts, dates, stated_expectations, policy_constraints) into a structured "case facts" block that's prepended to every prompt, outside of summarized conversation history
- D) Ask the customer to repeat the amount at the start of each new turn

**Correct Answer**: C

### Explanation
Progressive summarization reliably erases specifics: numbers become "a refund," policy citations become "an exception." The defense is to move transactional facts out of prose entirely and into a structured block that isn't subject to summarization. (A) delays the erosion but doesn't prevent it. (B) bloats context and doesn't scale past the first message. (D) shifts reliability work onto the customer, which is the agent's job.

**Domain**: Domain 5 · **Scenarios**: 1 · **Format**: Multiple choice

---

## Question 3
**True or False: Routing customer-support escalation decisions based on the agent's self-reported confidence score is a reliable way to catch cases the agent shouldn't resolve alone.**

- A) True
- B) False

**Correct Answer**: B (False)

### Explanation
Self-reported confidence on escalation is uncalibrated — agents are routinely and wrongly confident on hard cases, so the signal fails exactly where you need it. The exam-guide's explicit escalation triggers are: (1) the customer explicitly asks for a human, (2) policy is ambiguous or silent, (3) the agent cannot make meaningful progress. Confidence scoring and sentiment analysis are both known-wrong distractors on this topic. (Important: for structured extraction in Scenario 6, confidence-based routing DOES work — because confidence there is calibrated against a labeled validation set. Context matters, and Question 10 tests exactly that distinction.)

**Domain**: Domain 5 · **Scenarios**: 1 · **Format**: True/False

---

## Question 4
**A subagent responsible for web search hits a timeout before completing its query. What should it return to the coordinator?**

- A) An empty results list with status "success," so the coordinator proceeds with the report
- B) The string "search unavailable" so the coordinator knows something went wrong
- C) A structured error with `failure_type`, `attempted_query`, `partial_results`, and `alternatives`
- D) Nothing — let the coordinator timeout watchdog handle it

**Correct Answer**: C

### Explanation
Structured error propagation gives the coordinator enough information to make an intelligent recovery decision: which recovery type to attempt, what was already tried (so it doesn't repeat it), what partial data is usable, and what alternative approaches the subagent itself suggests. (A) is the worst anti-pattern — silent suppression — because the coordinator now thinks the research finished and shipped empty. (B) is a generic string with none of the signal the coordinator needs. (D) turns a recoverable failure into a hang, losing partial results and context.

**Domain**: Domain 5 · **Scenarios**: 3 · **Format**: Multiple choice

---

## Question 5
**A query runs against a customer database and returns an empty result. Which distinction must the tool's response preserve? Select all that apply.**

- A) "Query succeeded, zero matching customers" is a valid result the coordinator should treat as a real answer
- B) "Query failed to execute (database timeout, permission denied, etc.)" is an error state the coordinator should retry or route
- C) Both states can safely be collapsed into an empty list with `status: "success"` — the coordinator should treat "no results" identically regardless of cause
- D) The response should carry an explicit status field — e.g., `status: "empty_result"` vs `status: "access_failure"` — plus error context when applicable

**Correct Answer**: A, B, and D (multi-select)

### Explanation
Access failure and valid empty result are categorically different answers, and collapsing them is the worst error a tool can make — the coordinator loses the ability to distinguish "the customer doesn't exist" from "the database didn't respond." The fix is explicit status fields that name the two cases distinctly, plus error context for the failure case. (C) is the anti-pattern the other three correct answers are built to prevent.

**Domain**: Domain 5 · **Scenarios**: 1, 3, 6 · **Format**: Multi-select

---

## Question 6
**A multi-agent research pipeline produces a final report that reads as comprehensive, but a human reviewer notices entire subtopics weren't covered because one subagent silently failed. Which pattern would have surfaced the gap before the report shipped?**

- A) Each subagent self-reports coverage — `covered`, `gaps`, `partial` — and the coordinator preserves that coverage annotation through synthesis
- B) The coordinator runs a final "is this report complete?" pass on the finished output
- C) Swap to extended thinking so the synthesis step reasons more thoroughly
- D) Add a sentiment check on the report — if it reads as confident, it's comprehensive

**Correct Answer**: A

### Explanation
Coverage annotations surface gaps as structured data. Each subagent reports what it did and didn't cover; the coordinator aggregates; synthesis preserves those annotations instead of collapsing them into prose. (B) is reactive and unreliable — a confident-reading report can be missing entire subtopics precisely because it reads confidently. (C) doesn't address the structural problem. (D) confuses rhetorical style with content coverage.

**Domain**: Domain 5 · **Scenarios**: 3 · **Format**: Multiple choice

---

## Question 7
**During a 90-minute exploration session, the agent starts giving answers like "typical auth patterns would include..." instead of referencing the specific `SessionManager` class it found earlier. What's happening, and what's the right fix?**

- A) The model is lazy and needs a stronger system prompt telling it to be specific
- B) Context degradation — specific facts from early exploration have been diluted by later turns. Fix with a scratchpad file the agent writes findings to and explicitly references in future prompts, plus `/compact` at phase boundaries or a fresh session with an injected summary
- C) The model is running out of tokens; switch to a larger-context model
- D) The tools the agent used earlier returned stale data; re-invoke them

**Correct Answer**: B

### Explanation
"Typical patterns" appearing in place of specifics is the textbook symptom of context degradation: the discovered facts are still somewhere in the window but buried under later turns, so the model falls back to generic knowledge. The fix is to externalize findings to a scratchpad file and reference it explicitly — Claude won't implicitly remember a file — and to break the session at natural phase boundaries. (A) misdiagnoses the cause. (C) is the almost-right context-window distractor, but a larger model has the same degradation curve at larger scale. (D) addresses freshness of tool data, which isn't the problem here.

**Domain**: Domain 5 · **Scenarios**: 2, 4 · **Format**: Multiple choice

---

## Question 8
**A long-running multi-agent pipeline (6 agents, several hours of web searches) crashes after agent 4 completes. What's the right recovery architecture?**

- A) Restart the entire pipeline from agent 1 — it's the only way to guarantee consistency
- B) Each agent writes a state manifest (agent_id, completion_status, output_location, timestamp) to a known location on completion; the coordinator reads the manifest on resume, pulls outputs from the completed agents, and re-runs only the incomplete ones
- C) Keep all subagent state in the coordinator's conversation history, so any coordinator can resume anywhere by reading chat logs
- D) Run the pipeline in a single monolithic agent; one agent means one crash boundary

**Correct Answer**: B

### Explanation
State manifests turn "recover from crash" into filesystem discipline, not magic. Each agent exports its state to a known location; the coordinator reconstructs the pipeline's status from the manifest rather than from memory. (A) throws away hours of completed work — the exam calls this out as a distractor. (C) is fragile: conversation history is subject to summarization and context limits, exactly the failure modes Domain 5 is built to avoid. (D) trades multi-agent decomposition for a much larger crash blast radius.

**Domain**: Domain 5 · **Scenarios**: 3 · **Format**: Multiple choice

---

## Question 9
**A structured-extraction pipeline reports 97% aggregate accuracy against a labeled validation set. The team wants to reduce human review by auto-accepting high-confidence extractions. What must they validate before flipping the switch?**

- A) Nothing — 97% aggregate accuracy is well above most production thresholds
- B) Accuracy stratified by document type AND by field, because aggregate accuracy can mask a document type or field with 40% accuracy
- C) Whether the model's self-reported confidence calibrates linearly against accuracy on the validation set
- D) Both B and C — segment the accuracy AND verify that the confidence threshold is empirically calibrated, not self-reported

**Correct Answer**: D

### Explanation
Two things have to be true before auto-accept is safe: (1) aggregate accuracy doesn't mask a catastrophic segment — stratify by document type and field, because a 97% overall can hide a 40% segment; and (2) the confidence threshold is calibrated against the labeled validation set, not just trusted because it's "high." (A) is the naive mistake the exam loves to punish. (B) alone fixes segmentation but doesn't validate the routing signal. (C) alone validates routing but could still auto-accept a segment that performs badly.

**Domain**: Domain 5 · **Scenarios**: 6 · **Format**: Multiple choice

---

## Question 10
**Two scenarios both propose "route low-confidence outputs to human review." In which scenario is confidence-based routing the right architecture, and in which is it a known-wrong almost-right trap? Select all that apply.**

- A) Scenario 6 (structured extraction): CORRECT — field-level confidence calibrated against a labeled validation set is a reliable routing signal
- B) Scenario 1 (customer-support escalation): CORRECT — the agent's self-reported confidence reliably identifies cases it can't resolve
- C) Scenario 1 (customer-support escalation): WRONG — self-reported confidence is uncalibrated against case complexity; use explicit criteria (explicit customer request, policy ambiguity, inability to progress) with few-shot examples instead
- D) Scenario 6 (structured extraction): WRONG — confidence-based routing is an uncalibrated heuristic that will leak errors through at any threshold

**Correct Answer**: A and C (multi-select)

### Explanation
This is the hazard question: confidence-based routing looks universally correct but isn't. In Scenario 6 (extraction), confidence can be CALIBRATED — you have a labeled validation set, so you can empirically tune the threshold and measure per-field accuracy under it. In Scenario 1 (customer-support escalation), the model's self-reported confidence is UNCALIBRATED against case complexity, so it fails exactly on the hard cases that most need escalation. (B) is the almost-right trap the exam repeatedly tests — confidence-routing for escalation is one of the most reliably-marked-wrong distractors in Domain 5. (D) over-corrects and throws out a pattern that does work in its proper context. Memorize both halves: calibration against what, for what decision.

**Domain**: Domain 5 · **Scenarios**: 1, 6 · **Format**: Multi-select
