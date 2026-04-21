# Quiz: Prompt Engineering (Domain 4)

Domain 4 - Prompt Engineering & Structured Output (20% of exam). Primary scenarios: 5 (CI/CD), 6 (Structured Extraction).

---

## Question 1
**A code-review pipeline is producing too many false positives. The current prompt says "be conservative and only flag high-confidence issues." Which change will most reliably reduce false positives?**

- A) Tighten the instruction to "be extremely conservative and only flag issues you are very confident about"
- B) Add a post-filter that discards findings below a self-reported confidence threshold of 0.8
- C) Replace the vague instructions with explicit categorical criteria — named severity tiers, with one concrete code example per tier and an explicit skip list
- D) Lower the model temperature to 0.2

**Correct Answer**: C

### Explanation
"Be conservative" is an adjective, not a category — it doesn't change what the model counts as a finding. The fix is explicit categorical criteria: name the severities, show a concrete code example of each, and list what to skip. (A) doubles down on adjectives; same behavior. (B) is the classic almost-right distractor — self-reported confidence isn't calibrated, so a 0.8 threshold filters randomly, not meaningfully. (D) addresses variability, not the review taxonomy that's producing the false positives in the first place.

**Domain**: Domain 4 · **Scenarios**: 5 · **Format**: Multiple choice

---

## Question 2
**True or False: `tool_use` with a strict JSON schema eliminates all extraction errors, including cases where line items don't sum to the invoice total.**

- A) True
- B) False

**Correct Answer**: B (False)

### Explanation
`tool_use` with a schema eliminates syntax errors — malformed JSON, missing fields, wrong types, truncated output. It does NOT eliminate semantic errors: values placed in the wrong field, totals that don't add up, logical contradictions. The invoice-line-items-don't-sum-to-total case is the canonical semantic error. The fix is a separate validation layer (compute `calculated_total`, compare to `stated_total`) — not the schema. Conflating the two error classes is one of the most reliably-tested traps in Domain 4.

**Domain**: Domain 4 · **Scenarios**: 6 · **Format**: True/False

---

## Question 3
**When is few-shot prompting the right tool to reach for?**

- A) When the output format needs to be guaranteed machine-parseable JSON
- B) When the prose specification is already clear and the model is getting it right consistently
- C) When the task has ambiguous edge cases and you want to teach judgment by showing 2–4 examples with reasoning traces
- D) When you want to enforce that the model always picks from a fixed set of categories

**Correct Answer**: C

### Explanation
Few-shot examples earn their cost on ambiguous, judgment-dependent cases — not well-defined ones. 2–4 examples with reasoning traces generalize better than more verbose prose, especially when the examples are edge cases rather than easy ones. (A) describes `tool_use` with a schema, not few-shot — prose examples don't guarantee JSON syntax. (B) is when you skip few-shots — they add token cost with no benefit. (D) describes enum-constrained schemas, again a tool_use pattern.

**Domain**: Domain 4 · **Scenarios**: 1, 5, 6 · **Format**: Multiple choice

---

## Question 4
**An invoice-extraction pipeline is over-filling required fields — customers are reporting "fabricated" values on invoices that genuinely lacked that data. Which schema-design changes actually address the root cause? Select all that apply.**

- A) Mark fields that may legitimately be absent as optional AND nullable, so the model can return null instead of inventing a value
- B) Add an "unclear" option to every enum category, giving the model a valid home for ambiguous cases
- C) Move every field to `required: true` so the model is forced to extract — fabrication is a model problem, not a schema problem
- D) Wrap the extraction in a validation-retry loop that re-prompts until every required field has a non-null value

**Correct Answer**: A and B (multi-select)

### Explanation
Required fields + absent data = fabrication, full stop. The model has no escape hatch, so it invents. Making the field nullable/optional gives it one. Adding "unclear" to enums does the same job for categorical fields. (C) inverts the fix — doubling down on required guarantees more fabrication, not less. (D) is the almost-right distractor: retrying when the data isn't there won't summon it, it'll just produce a worse fabrication with more tokens burned.

**Domain**: Domain 4 · **Scenarios**: 6 · **Format**: Multi-select

---

## Question 5
**A structured-extraction pipeline runs a validation-retry loop. Which scenario is the loop actually effective for?**

- A) The customer ID is not present anywhere in the source document — the retry keeps returning null
- B) The extracted date is in `MM/DD/YYYY` format but the schema wants ISO 8601 — the retry with a specific format-mismatch error succeeds
- C) The model has misunderstood what the document is about — every retry returns similar wrong content
- D) The source document exceeded the context window — the retry fails identically each time

**Correct Answer**: B

### Explanation
Retry-with-feedback works when the information is present and the error is fixable: format mismatches, structural errors, or semantic errors the document itself resolves. The date-format case is textbook — Claude sees the specific error and produces ISO 8601 on the next pass. (A) is the classic "information absent" trap: retrying can't summon data that isn't there. (C) is a conceptual misunderstanding — retries with the same inputs don't address root-cause misinterpretation. (D) is a hard context-window failure; the retry hits the same wall.

**Domain**: Domain 4 · **Scenarios**: 6 · **Format**: Multiple choice

---

## Question 6
**A code-review system produces findings, and developers dismiss roughly 60% of them. What design change gives the team the best chance of fixing the false-positive problem systematically rather than case-by-case?**

- A) Add a `detected_pattern` field to every finding — then aggregate dismissals by pattern and refine the prompt for the noisy ones
- B) Track aggregate false-positive rate and tune the prompt when the number gets too high
- C) Have the model self-rate its confidence per finding and suppress anything under 0.75
- D) Add a second review pass where Claude critiques its own findings before emitting them

**Correct Answer**: A

### Explanation
`detected_pattern` turns case-by-case dismissals into pattern-level signal: if "missing_null_check" is dismissed 80% of the time, you know exactly where the prompt needs tightening. (B) tracks the symptom without pointing at the cause — you can't fix what you can't see. (C) is the confidence-threshold distractor again: self-reported confidence isn't calibrated, so the filter is arbitrary. (D) may help marginally, but it's a per-finding band-aid, not the systematic analysis the question asks for.

**Domain**: Domain 4 · **Scenarios**: 5 · **Format**: Multiple choice

---

## Question 7
**Match each workflow to the right API choice:**

- A) Pre-merge PR security check (developer is waiting) → Message Batches API for the 50% cost savings
- B) Weekly tech-debt audit running overnight (no user blocked) → Message Batches API for the 50% cost savings
- C) Pre-merge PR security check (developer is waiting) → synchronous Messages API for predictable second-scale latency
- D) Weekly tech-debt audit running overnight → synchronous Messages API to avoid the batch API's 24-hour SLA uncertainty

**Correct Answer**: B and C (multi-select)

### Explanation
Latency drives the API choice, not cost. Pre-merge checks block a developer in seconds — sync is the only fit. Overnight audits can tolerate up to a 24-hour window — batch saves 50%. The exam's most common distractor pair is "batch everything for the savings" (A, wrong) or "sync everything for reliability" (D, wrong) — the right answer is *both* APIs used in parallel, each for the workflow it fits.

**Domain**: Domain 4 · **Scenarios**: 5, 6 · **Format**: Multi-select

---

## Question 8
**True or False: When a Message Batches API run completes with some failed entries (context-limit exceeded, rate-limit hits), the correct recovery is to resubmit the entire batch so all `custom_id`s align.**

- A) True
- B) False

**Correct Answer**: B (False)

### Explanation
Resubmit only the failed entries, identified by `custom_id`. That's the whole point of `custom_id` — it correlates request to response and to retry. Fix what failed (chunk the oversized doc, adjust the prompt), resubmit with the same or derived `custom_id`s, and merge with the successful results. Resubmitting the whole batch wastes 50% of the cost savings the batch API was supposed to deliver, and re-risks the already-successful entries.

**Domain**: Domain 4 · **Scenarios**: 6 · **Format**: True/False

---

## Question 9
**Why is a second, independent Claude instance a better reviewer than asking the same session that generated the code to critique itself?**

- A) The second instance has access to more tools and can run more thorough static analysis
- B) Extended thinking mode in the second instance automatically catches issues self-review misses
- C) The generating session carries reasoning context that justifies the code it wrote; an independent instance reviews without that self-justification bias
- D) A second instance distributes token cost across two sessions, which makes the review cheaper overall

**Correct Answer**: C

### Explanation
The answer hinges on reasoning-context bias: the generator has already internally justified its decisions and is less likely to challenge them. A fresh instance with only the code + project conventions doesn't carry that bias. (A) is false — both instances see the same tools. (B) is the almost-right distractor — extended thinking still runs in the same context and doesn't solve the self-justification problem. (D) is unrelated to quality; it's a cost argument, not a reliability argument.

**Domain**: Domain 4 · **Scenarios**: 5 · **Format**: Multiple choice

---

## Question 10
**A team reviews a 40-file PR with a single review prompt and finds almost no issues. Re-running the exact same prompt on one file at a time surfaces dozens of bugs. Which architectural change best explains what was going wrong and how to fix it?**

- A) Attention dilution across 40 files — fix with a multi-pass review: a per-file pass for local issues, followed by one cross-file pass for integration concerns
- B) Random variance in the model — fix by running the same 40-file prompt three times and aggregating the findings
- C) The 40-file prompt needs a higher temperature to "explore" more thoroughly
- D) The single-prompt pass is correct architecturally; the per-file findings are over-reporting and should be ignored

**Correct Answer**: A

### Explanation
One prompt reviewing 40 files spreads attention too thin — the "find nothing in every file" failure mode. Multi-pass architecture fixes it: per-file passes catch local bugs and style issues; a separate cross-file pass catches integration, interface, and data-flow issues across modules. Each pass has one job. (B) doesn't address attention dilution — three thin passes still miss. (C) inverts the problem — higher temperature adds noise, not focus. (D) denies the evidence; the per-file findings existed and were real.

**Domain**: Domain 4 · **Scenarios**: 5 · **Format**: Multiple choice
