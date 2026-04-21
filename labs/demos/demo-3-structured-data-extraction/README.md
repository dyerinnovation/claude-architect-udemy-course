# Demo: Structured Data Extraction Pipeline

- **Module/Section:** Section 10 — Demo 3
- **Duration:** ~6–8 min

---

## Overview

LLMs fail at structured data extraction in one very specific, very predictable way: they hallucinate field names and shapes. Ask a model to "return JSON" and you'll get `customerName` in one response, `customer_name` in the next, and `{"customer": {"name": "..."}}` in the third — plus the occasional plausible-but-fabricated value for fields that weren't in the source document at all. In production, this schema drift breaks every downstream consumer that dared to parse the output.

This demo fixes that with three Domain 4 anchors that every exam question in Scenario 6 leans on: `tool_use` with a proper JSON schema (the schema becomes the contract, not a prompt suggestion), `tool_choice` to guarantee the model actually calls the tool, and a validation-retry loop that feeds specific errors back on the next turn. We'll also wire in a `detected_pattern` field — a metadata slot the model fills in on ambiguous inputs so downstream human reviewers can diagnose systematic false positives rather than chasing one-off miscategorizations.

By the end you'll have a pipeline you can copy into a real project: baseline prompt-only extraction (which you can point at and say "don't do this"), a structured version with a hand-designed schema that uses required, optional, nullable, and enum fields in their exam-sanctioned roles, and a retry loop that's explicit about which errors retries can actually fix.

## Learning Objectives

By the end of this demo, you will be able to:

- Use `tool_use` with a JSON schema as the primary mechanism for structured output (Domain 4 core skill).
- Apply `tool_choice` (`"any"`, forced tool, or `"auto"`) to guarantee the model calls the extraction tool instead of returning prose.
- Design JSON schema fields in their correct roles: `required` for fields that must always be present, `optional` (omitted from `required`) for fields that may be missing, `nullable` (`["string", "null"]`) for fields where the answer may genuinely be null, and `enum` + `"other"` + detail-string for extensible categorization.
- Implement a validation-retry loop that re-prompts with the specific Pydantic/JSON-schema error, and recognize when retries help (format errors) vs. when they don't (information simply absent from the source).
- Add a `detected_pattern` field that lets downstream reviewers analyze false-positive clusters instead of triaging one-offs.

## Claude Surfaces Used

- **Claude API (Messages)** — `messages.create` with `tools` + `tool_choice` for structured output.
- **Tool use** — extraction tool with a JSON schema as its `input_schema`.
- **`tool_choice`** — demonstrated as `"any"` (guarantee some tool fires) and forced (`{"type": "tool", "name": "..."}`).
- **Pydantic** — schema validation layer whose error messages feed the retry loop.

## Exam Domains Reinforced

| Domain | Weight | How this demo reinforces it |
|---|---|---|
| Domain 4: Prompt Engineering & Structured Output | 20% | `tool_use` + JSON schema as the extraction contract; `tool_choice` for guaranteed selection; required/optional/nullable/enum field design; validation-retry with error feedback; `detected_pattern` for false-positive analysis. |
| Domain 2: Tool Design & MCP Integration | 18% | Tool description writing — the extraction tool's `description` field steers the model toward the correct extraction shape, exactly like an MCP tool description. |

## Prerequisites

- Python 3.10+
- An Anthropic API key (`ANTHROPIC_API_KEY`)
- Familiarity with Section 6 (Prompt Engineering) and at least a skim of Section 3 (Tool Use)

## Quick Start

```bash
cd demo-3-structured-data-extraction-infrastructure-build-scripts

# 1. Stand up the venv and install deps
bash deploy-demo-3-structured-data-extraction.sh

# 2. Activate the venv (the deploy script prints this reminder)
source .venv/bin/activate

# 3. Export your key
export ANTHROPIC_API_KEY="sk-ant-..."

# 4. Run the pipeline against all five sample inputs
python extract.py --input sample-inputs/ --mode structured

# Optional: compare the failing prompt-only baseline
python extract.py --input sample-inputs/ --mode baseline

# 5. Tear down
bash cleanup-demo-3-structured-data-extraction.sh
```

Each run prints per-document extractions side-by-side with validation results, retry attempts, and any `detected_pattern` values the model surfaced.

## File Structure

```
demo-3-structured-data-extraction/
├── README.md                                                 <- you are here
├── demo-3-structured-data-extraction-recording-script.md     <- OBS narration
└── demo-3-structured-data-extraction-infrastructure-build-scripts/
    ├── README.md                             <- code walkthrough
    ├── deploy-demo-3-structured-data-extraction.sh
    ├── cleanup-demo-3-structured-data-extraction.sh
    ├── extract.py                            <- runnable pipeline
    ├── schema.json                           <- extraction JSON schema
    ├── requirements.txt
    ├── .env.example
    └── sample-inputs/                        <- 5 documents to extract from
        ├── invoice-clean.txt
        ├── invoice-missing-tax-id.txt
        ├── support-ticket-billing.txt
        ├── support-ticket-ambiguous.txt
        └── receipt-partial.txt
```

## Additional Resources

- Anthropic Exam Guide — *Preparation Exercise 3: Build a Structured Data Extraction Pipeline*.
- Anthropic Exam Guide — *Scenario 6: Structured Data Extraction* (Task Statements 4.3, 4.4).
- Anthropic Exam Guide — *Technologies and Concepts* — JSON Schema (required / optional / enum / nullable / "other" pattern), `tool_choice` (`"auto"`, `"any"`, forced), Pydantic validation-retry loops, `detected_pattern` fields for false-positive analysis.
- Anthropic API docs — [Tool use for structured outputs](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview).
- Anthropic API docs — [`tool_choice` reference](https://docs.anthropic.com/en/docs/build-with-claude/tool-use#forcing-tool-use).
