# Demo: Structured Data Extraction Pipeline — Detailed Script

**Duration**: ~15 min | **Section**: 10 | **Demo**: 3

---

### [0:00] Introduction

- In this demo, we'll walk through a production-style structured data extraction pipeline end-to-end.
  - A JSON schema with required, optional, and nullable fields plus an `enum` + `"other"` detail-string pattern.
  - A validation-retry loop that feeds Pydantic errors back to the model.
  - A batch run over 100 documents with per-`custom_id` failure handling and confidence-based human-review routing.
- This prepares you for Domain 4 (structured output + few-shot) and Domain 5 (validation-retry, batch reliability, human-review routing).

---

### [0:30] Deploy Demo Environment

<!-- Walk through pip install, export ANTHROPIC_API_KEY, show the sample-docs directory with varied layouts (invoices with tables, narrative contracts, receipts). -->

---

### [2:00] JSON Schema Design: Required / Optional / Nullable + Enum-Other

<!-- Open the Pydantic schema. Call out: required fields (document_type, extracted_at), optional fields (vendor_address, tax_id), nullable fields for information that may not exist, and the enum {"invoice", "receipt", "po", "other"} with a paired `document_type_detail` string filled only when value is "other". Explain how this pattern prevents the model from fabricating a category. -->

---

### [4:30] Verify Null Returns for Absent Fields

<!-- Run the extractor against a document that omits tax_id. Show the tool_use input: "tax_id": null. Emphasize: the schema permits null, the prompt instructs null-on-absence, and the model complies rather than guessing. -->

---

### [6:30] Validation-Retry Loop with Pydantic Feedback

<!-- Force a schema violation (e.g., malformed date). Show the pipeline catching the ValidationError, constructing a retry message that includes: the original document, the failed extraction, the specific Pydantic error string. Show the corrected extraction on retry. Discuss: format mismatches are retry-resolvable; information-absent errors are not. -->

---

### [9:00] Few-Shot Examples for Format Variety

<!-- Show the few-shot block: one example with inline citations, one with a bibliography, one with a narrative description, one with a structured table. Run the same extractor on a new document that mixes formats and show it generalizing correctly. -->

---

### [11:00] Message Batches API: 100 Documents with custom_id

<!-- Submit the 100-doc batch. Show the response with the batch id. Poll for completion. Show the results keyed by custom_id. Surface two failures (e.g., an oversized document and a rate-limit blip). Resubmit with modifications — chunk the oversized doc, re-run the transient failure. -->

---

### [13:30] Confidence Scores and Human-Review Routing

<!-- Show field-level confidence scores in the output. Route all fields with confidence < 0.8 to a review queue. Segment accuracy by document type and field to prove the router isn't hiding a systematic weakness. -->

---

### [14:30] Cleanup and Wrap

<!-- Deactivate venv, clear batch-results. Recap: schema design, validation-retry, few-shot, batch+custom_id, confidence routing. -->
