# Demo: Structured Data Extraction Pipeline

**Section**: 10 | **Duration**: ~15 min | **Demo**: 3

---

## Overview

This demo builds a structured data-extraction pipeline that uses `tool_use` with a carefully designed JSON schema (required, optional, nullable fields, plus an `enum` with an `"other"` + detail-string pattern) to pull fields from heterogeneous documents. You will see a validation-retry loop that feeds Pydantic errors back to the model, few-shot examples that teach the model to handle varied document structures, and batch processing via the Message Batches API with per-document `custom_id` failure tracking and a human-review routing strategy driven by field-level confidence scores.

## Learning Objectives

By the end of this demo, you will be able to:

- Design an extraction JSON schema with required / optional / nullable fields and an `"other"` + detail-string enum pattern that prevents fabrication.
- Verify the model returns `null` for fields that are absent in the source rather than hallucinating plausible values.
- Implement a validation-retry loop: on Pydantic failure, send back the document, the failed extraction, and the specific error.
- Use few-shot examples to teach the model to handle format variety (inline citations vs bibliographies, narrative vs tables).
- Submit a 100-document batch via the Message Batches API, handle per-`custom_id` failures, and resubmit with modifications (e.g., chunking oversized docs).
- Emit field-level confidence scores and route low-confidence extractions to human review, segmented by document type and field.

## Claude Surfaces Used

- **Claude API** - `messages.create` with `tools` + `tool_choice` for structured output.
- **Message Batches API** - bulk document processing, `custom_id` correlation, 24-hour window, 50% cost savings.
- **Pydantic** - schema validation and semantic error messages fed back into retries.

## Domains Reinforced

| Domain | % | How this demo tests it |
|---|---|---|
| Domain 4: Prompt Engineering & Structured Output | 20% | JSON schema with required/optional/nullable + enum+other pattern; few-shot prompting for format variety; `tool_use` for structured output. |
| Domain 5: Context Management & Reliability | 18% | Validation-retry loop, batch failure handling by `custom_id`, confidence-based human-review routing. |

## Quick Start

### Deploy

```bash
cd demo-3-structured-data-extraction-infrastructure-build-scripts
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt   # anthropic, pydantic
export ANTHROPIC_API_KEY=...
python extraction_pipeline.py --input ./sample-docs --batch
```

### Record

Follow `demo-3-structured-data-extraction-recording-script.md` for timestamped narration.

### Cleanup

```bash
deactivate
rm -rf .venv ./batch-results
```

## Additional Resources

- Anthropic Exam Guide, *Preparation Exercises* - Exercise 3.
- Anthropic Exam Guide, *Technologies and Concepts* - JSON Schema (required/optional, enum, nullable, `"other"` pattern), Pydantic, Message Batches API, few-shot prompting.
- Anthropic API docs - [Tool use for structured outputs](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview) and [Message Batches API](https://docs.anthropic.com/en/docs/build-with-claude/batch-processing).
