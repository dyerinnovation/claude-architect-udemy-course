# Demo 3 — Infrastructure & Code Walkthrough

This directory contains the runnable pipeline for Demo 3 (Structured Data Extraction). It's the code the recording script references and the code you copy into your own project.

---

## File inventory

| File | Purpose |
|---|---|
| `extract.py` | The pipeline. Baseline (prompt-only), structured (tool_use + forced `tool_choice`), and `structured-any` (`tool_choice="any"`) modes; Pydantic validation layer; retry loop. |
| `schema.json` | The JSON schema passed to Claude as the extraction tool's `input_schema`. Comments inline call out required / optional / nullable / enum + "other" field roles. |
| `sample-inputs/` | Five sample documents covering the exam-relevant extraction cases (clean invoice, missing nullable field, standard ticket, ambiguous ticket, partial receipt). |
| `requirements.txt` | `anthropic`, `pydantic`. That's it. |
| `deploy-demo-3-structured-data-extraction.sh` | Creates `.venv/`, installs deps, prints next steps. Idempotent. |
| `cleanup-demo-3-structured-data-extraction.sh` | Removes `.venv/`, caches, and any local `.env`. Preserves code and sample inputs. |
| `.env.example` | Template for the `ANTHROPIC_API_KEY` env var. |

---

## Quick start

```bash
# From inside demo-3-structured-data-extraction-infrastructure-build-scripts/
bash deploy-demo-3-structured-data-extraction.sh
source .venv/bin/activate
export ANTHROPIC_API_KEY=sk-ant-...

# Structured extraction (forced tool_choice) — what you want in production
python extract.py --input sample-inputs/ --mode structured

# Compare against the failing baseline
python extract.py --input sample-inputs/ --mode baseline

# Try tool_choice="any" instead of forced
python extract.py --input sample-inputs/invoice-clean.txt --mode structured-any

# Tear down
bash cleanup-demo-3-structured-data-extraction.sh
```

---

## The four Domain 4 anchors, mapped to code

### 1. `tool_use` with a JSON schema — the structured output contract

Defined in `schema.json`, loaded at import time in `extract.py`:

```python
EXTRACTION_TOOL = _load_tool_spec()   # reads schema.json, strips _comment_* keys
```

Sent to the API in `run_structured`:

```python
response = client.messages.create(
    ...,
    tools=[EXTRACTION_TOOL],
    tool_choice={"type": "tool", "name": "extract_document"},
    ...
)
```

Why this works where "return JSON" prompts fail: the JSON schema is enforced server-side as part of the tool-call contract. The model cannot emit a malformed key or an extra field; the call either matches the schema or it doesn't emit at all.

### 2. `tool_choice` — guaranteed selection

`extract.py` shows all three options:

| `tool_choice` | Behavior | When to use |
|---|---|---|
| `{"type": "tool", "name": "..."}` | Force THIS specific tool. | Extraction pipelines with one tool. **Default choice.** |
| `{"type": "any"}` | Force SOME tool. | Multiple extraction schemas; let the model pick. |
| `{"type": "auto"}` | Model decides — may return prose. | **Don't use for extraction.** Exam distractor. |

Toggle via `--mode structured` (forced) vs `--mode structured-any`.

### 3. Validation-retry loop — format errors yes, missing-info no

`extract.py::run_structured` loops up to `MAX_RETRIES + 1` times. On `ValidationError`:

```python
messages.append({"role": "assistant", "content": response.content})
messages.append({
    "role": "user",
    "content": [{
        "type": "tool_result",
        "tool_use_id": <the bad call's id>,
        "content": "Your extraction failed validation with these errors: ...",
        "is_error": True,
    }],
})
```

The key insight (Task Statement 4.4 on the exam): retries fix format mismatches (bad date format, wrong currency case). Retries do NOT fix missing information — if `tax_id` isn't in the source, no number of retries will produce one. The schema handles that case correctly by allowing `null`.

Comment in `extract.py` makes this explicit. If a retry fails repeatedly with the same error, that's your signal to route to human review, not to keep retrying.

### 4. `detected_pattern` — false-positive clustering

Required field in the schema. System prompt (in `extract.py::STRUCTURED_SYSTEM`) tells the model:

> For detected_pattern — populate with a short snake_case identifier for any unusual pattern in the document. Use "none" if the document is standard.

Downstream, you group extractions by `detected_pattern` value and look at the top N buckets. Each bucket is a systematic false-positive cluster. See `sample-inputs/support-ticket-ambiguous.txt` for the canonical ambiguous case — the model should populate `detected_pattern` with something like `"mixed_language"` or `"currency_ambiguous"`.

---

## Schema design notes (worth reading before you modify)

The schema encodes four distinct field roles. Mis-applying them is the most common exam wrong-answer:

| Role | Encoding | Tells the model |
|---|---|---|
| **Required** | field name in `"required": [...]` | Must always be present. Fails validation if absent. |
| **Optional** | field not in `"required"`, no `"null"` in type | Omit the key entirely if the field doesn't apply. |
| **Nullable** | field not in `"required"`, type is `["string", "null"]` | Key is always present; value may be `null` when data is missing. **Use this to prevent fabrication.** |
| **Enum + "other"** | `"enum": [..., "other"]` + paired detail-string field | Classify from a closed set, fall through to `"other"` with explanation for novel cases. |

Cross-reference the roles in `schema.json` — each field has a `_comment` tag calling out which role it plays.

### Why Pydantic AT ALL when the API enforces the schema?

1. Gives us a typed Python object instead of a dict.
2. Lets us add SEMANTIC validation the API can't enforce (ISO date format, currency code uppercase, total == sum(line_items)).
3. Produces structured error messages we can feed back into the retry turn verbatim.

The JSON schema handles SYNTAX. Pydantic handles SEMANTICS.

---

## Sample input coverage

| File | Tests |
|---|---|
| `invoice-clean.txt` | Happy path. All fields populated. Single-attempt success. |
| `invoice-missing-tax-id.txt` | Nullable field correctness. `tax_id` MUST come back as `null`, not a fabricated value. |
| `support-ticket-billing.txt` | Different document_type, different field subset. `line_items` omitted entirely (optional). |
| `support-ticket-ambiguous.txt` | `detected_pattern` exercise. Mixed language + ambiguous currency. |
| `receipt-partial.txt` | Partial-information handling + confidence score + `detected_pattern`. |

---

## Extending this demo

Students often ask about these next steps:

- **Add a new document type.** Add to the enum in `schema.json`, add any type-specific optional fields, add a sample input. No Python changes needed.
- **Swap in the Message Batches API.** Wrap the `run_structured` call in a batch submission with a `custom_id` per document. Failures are handled per-`custom_id` — resubmit only the failed docs.
- **Route low-confidence to human review.** Filter on `confidence < 0.8` after validation. The `detected_pattern` field lets you cluster the review queue.

See the parent `README.md` for exam-guide references.
