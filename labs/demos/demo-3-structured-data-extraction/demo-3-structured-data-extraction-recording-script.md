# Demo: Structured Data Extraction Pipeline — Recording Script

- **Module/Section:** Section 10 — Demo 3
- **Target duration:** ~6–8 min
- **OBS setup:** split screen — terminal (left) + `extract.py` / `schema.json` in editor (right). Font size bumped, line numbers on.

---

### [0:00] Opening — the pain

Structured data extraction is the single most common production Claude use case, and it's also the one where prompt-only approaches fail the hardest. The failure mode is always the same: you ask for JSON, you get JSON, but the field names drift between runs, nullable fields come back as hallucinated plausible values, and your downstream parser breaks on the fourth document. In this six-minute demo we're going to fix that with three Domain 4 anchors: `tool_use` with a JSON schema, `tool_choice` to force the call, and a validation-retry loop. Plus one bonus — a `detected_pattern` field that shows up on the exam.

*On-screen actions:*
- Open `README.md` in the editor, highlight the Learning Objectives block.
- Open a clean terminal in `demo-3-structured-data-extraction-infrastructure-build-scripts/`.

---

### [0:45] Unreliable baseline — prompt-only extraction

Let's start with what NOT to do. I've wired up a baseline mode that just asks Claude to "return JSON with the following fields." No tool, no schema, just a prompt. Watch what happens on five documents in a row.

*On-screen actions:*
- Run `python extract.py --input sample-inputs/ --mode baseline`.
- Point at the output: document 1 returns `"customer_name"`, document 2 returns `"customerName"`, document 3 wraps everything in `{"data": {...}}`, and document 4 — this is the nasty one — fabricates a `tax_id` value that isn't in the source document at all. That's schema drift plus hallucination in sixty seconds of runtime.

---

### [1:45] Move to tool_use with a JSON schema

Now the fix. Instead of asking for JSON in the prompt, we define an extraction tool and pass its JSON schema via the `tools` parameter. The schema is no longer a suggestion — it's the contract the model MUST match to call the tool at all. Let's open `schema.json` and `extract.py` side by side.

*On-screen actions:*
- Show `schema.json` — the `extract_document` tool with its `input_schema`. Emphasize the `description` field: this is where you disambiguate similar tools (Domain 2 anchor — tool descriptions matter even in single-tool setups).
- In `extract.py`, scroll to the `run_structured_extraction` function. Point at `tools=[EXTRACTION_TOOL]` on the `messages.create` call.
- Run `python extract.py --input sample-inputs/ --mode structured`. Same five inputs, but now every output has identical keys, correct types, and null where the source is silent.

---

### [3:00] tool_choice — guaranteeing the call

There's one more thing. By default Claude may respond with text OR a tool call — `tool_choice: "auto"`. For extraction pipelines that's the wrong default. We want to guarantee a tool call on every turn. Two options: `tool_choice: "any"` forces some tool (useful when you have multiple extraction schemas), and `tool_choice: {"type": "tool", "name": "extract_document"}` forces this specific tool. In extraction pipelines, forced is almost always correct.

*On-screen actions:*
- In `extract.py`, highlight the `tool_choice={"type": "tool", "name": "extract_document"}` parameter.
- Briefly flip to `run_auto` to show the same call with `tool_choice="auto"` and note the comment: "Don't do this in extraction — the model can return prose and skip the tool."

---

### [3:45] Schema design — required, optional, nullable, enum

The schema is where the real engineering happens. Four field types, four distinct jobs. Required — must always be present; omit and the tool call fails validation. Optional — can be omitted entirely; use this when the field only applies to some document types. Nullable — the field name is always present but the value may legitimately be `null`; this is how you TELL the model "return null, don't fabricate." And enum plus an `"other"` + detail-string — the model picks from a closed set, and for genuinely novel cases falls through to `"other"` and explains in a free-text field. No fabrication, no drift, extensible.

*On-screen actions:*
- In `schema.json`, highlight each role in turn: `required: ["document_type", "detected_pattern"]`, the `customer_name` field without a default and not in `required` (optional), `tax_id` with `"type": ["string", "null"]` (nullable), and `document_type` with its enum `["invoice", "receipt", "support_ticket", "other"]` paired with `document_type_detail`.

---

### [4:45] Validation retry loop — when retries help and when they don't

Even with a schema, validation can still fail — dates in the wrong format, numeric totals that don't sum, an enum value the model tried to invent. The fix is a retry loop: catch the Pydantic error, build a new turn that says "here was the document, here was your extraction, here is the specific error, try again." Critically — retries fix FORMAT errors; they do NOT fix MISSING INFORMATION. If the tax ID is absent from the source, no retry in the world will materialize it. That distinction is an exam question.

*On-screen actions:*
- In `extract.py`, scroll to `extract_with_retry`. Walk through the loop: `ValidationError` caught, specific error passed back as a user message, second API call. Limit is 2 retries.
- Run a targeted test on `invoice-missing-tax-id.txt` — show the extraction correctly returns `"tax_id": null` on the first try, no retry needed. Then show a (commented) example of a malformed-date retry where the second turn fixes the format.

---

### [5:45] The detected_pattern field — false-positive analysis

Last anchor, this one's directly from the exam guide. When your extraction pipeline handles ambiguous inputs, the model should emit a `detected_pattern` field describing WHY the input is ambiguous. This turns downstream human review from "triage one-off failures" into "spot systematic false-positive clusters." Let's run against `support-ticket-ambiguous.txt` and see the model populate that field on its own.

*On-screen actions:*
- Run `python extract.py --input sample-inputs/support-ticket-ambiguous.txt --mode structured`.
- Highlight the output: `"detected_pattern": "language-mixed-with-invoice-terms"`. Explain: you can now group all extractions by `detected_pattern`, quickly identify which patterns produce the most false positives, and fix the root cause instead of one-offs.

---

### [6:30] Recap and exam framing

Three things to remember. First — `tool_use` with a JSON schema is the structured-output mechanism on the exam; prompt-only "return JSON" is a wrong-answer distractor. Second — `tool_choice` with forced tool selection guarantees the call; `"auto"` is wrong when your pipeline expects structured output every turn. Third — the validation-retry loop fixes format errors, NOT missing-information errors, and `detected_pattern` fields are what turn false-positive analysis from anecdote into data. That's Scenario 6, that's Domain 4, that's what you'll see tested.

*On-screen actions:*
- Close terminal, back to the editor with `README.md` Learning Objectives visible. End on a clean frame.
