"""
Structured Data Extraction Pipeline — Demo 3

This pipeline demonstrates the four Domain 4 anchors from the Claude Certified
Architect exam (Scenario 6 / Preparation Exercise 3):

    1. tool_use with a JSON schema    — structured-output contract
    2. tool_choice (forced tool)      — guarantees the tool call
    3. Validation-retry loop          — format errors are retry-resolvable;
                                        missing-information errors are NOT.
    4. detected_pattern field         — enables false-positive clustering
                                        during downstream human review.

Two modes:
    --mode baseline   : prompt-only "return JSON" — the failing baseline.
    --mode structured : tool_use + schema + tool_choice + validation retry.

Usage:
    export ANTHROPIC_API_KEY=sk-ant-...
    python extract.py --input sample-inputs/ --mode structured
    python extract.py --input sample-inputs/invoice-clean.txt --mode structured
    python extract.py --input sample-inputs/ --mode baseline

Heavily commented — students are expected to copy-paste from this file.
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path
from typing import Any

import anthropic
from pydantic import BaseModel, Field, ValidationError, field_validator


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# Use Sonnet 4.6+ — tool_choice and structured tool use are well-calibrated here.
# The exam explicitly covers tool_choice options ("auto", "any", forced), so
# if you're tuning for cost, sonnet-4-6 is the sweet spot.
MODEL_ID = "claude-sonnet-4-6"

# Max tokens is intentionally generous. Tool_use responses include the full
# tool_use block; truncation is a painful failure mode worth the extra budget.
MAX_TOKENS = 2048

# Validation-retry bound. Two retries is the industry sweet spot:
#   attempt 0 = initial call
#   attempt 1 = retry with error feedback (fixes most format errors)
#   attempt 2 = final retry (rare; usually a signal the schema itself is wrong)
# Going higher wastes tokens on semantic errors that won't resolve via retry.
MAX_RETRIES = 2

# Path to the JSON-schema file. Keep it external so students can edit it
# without touching Python code.
SCHEMA_PATH = Path(__file__).parent / "schema.json"


# ---------------------------------------------------------------------------
# Load the extraction tool from schema.json
# ---------------------------------------------------------------------------

def _load_tool_spec() -> dict:
    """Load schema.json and strip the _comment_* keys so it's a valid tool spec.

    We keep inline _comment_ fields in schema.json for pedagogy — they're great
    in the editor view during recording. But the Anthropic API rejects unknown
    keys inside input_schema, so we drop them here before sending.
    """
    raw = json.loads(SCHEMA_PATH.read_text())

    def strip_comments(obj: Any) -> Any:
        if isinstance(obj, dict):
            return {k: strip_comments(v) for k, v in obj.items() if not k.startswith("_comment")}
        if isinstance(obj, list):
            return [strip_comments(x) for x in obj]
        return obj

    return strip_comments(raw)


EXTRACTION_TOOL = _load_tool_spec()


# ---------------------------------------------------------------------------
# Pydantic mirror of the schema — the validation layer
# ---------------------------------------------------------------------------
#
# Why have Pydantic AT ALL when we already pass a JSON schema to Claude?
# Because the model's JSON-schema compliance is very high but NOT 100%, and
# downstream consumers expect hard guarantees. Pydantic gives us:
#   - a concrete Python object to work with
#   - a place to add semantic validation (date format, total consistency)
#     that the API-side JSON schema can't enforce
#   - structured ValidationError objects whose messages we feed back into
#     the retry turn verbatim.


class LineItem(BaseModel):
    description: str
    quantity: float | None = None
    unit_price: float | None = None
    total_price: float | None = None


class ExtractedDocument(BaseModel):
    # Required
    document_type: str  # enum enforced below
    detected_pattern: str

    # Optional
    document_type_detail: str | None = None
    customer_name: str | None = None
    vendor_name: str | None = None
    line_items: list[LineItem] | None = None
    issue_summary: str | None = None
    severity: str | None = None

    # Nullable (always present, value may be null)
    invoice_number: str | None = None
    issue_date: str | None = None
    tax_id: str | None = None
    total_amount: float | None = None
    currency: str | None = None
    confidence: float | None = None

    @field_validator("document_type")
    @classmethod
    def validate_document_type(cls, v: str) -> str:
        allowed = {"invoice", "receipt", "support_ticket", "other"}
        if v not in allowed:
            # Semantic validator — surfaces a clear error message that we
            # feed back into the retry prompt verbatim.
            raise ValueError(f"document_type must be one of {sorted(allowed)}, got {v!r}")
        return v

    @field_validator("severity")
    @classmethod
    def validate_severity(cls, v: str | None) -> str | None:
        if v is None:
            return v
        if v not in {"low", "medium", "high"}:
            raise ValueError(f"severity must be one of ['low', 'medium', 'high'], got {v!r}")
        return v

    @field_validator("issue_date")
    @classmethod
    def validate_issue_date(cls, v: str | None) -> str | None:
        """ISO-8601 YYYY-MM-DD. Classic RETRY-RESOLVABLE error — format fix."""
        if v is None:
            return v
        if not re.match(r"^\d{4}-\d{2}-\d{2}$", v):
            raise ValueError(
                f"issue_date must match YYYY-MM-DD (ISO-8601), got {v!r}. "
                "Re-format the date using the original document content."
            )
        return v

    @field_validator("currency")
    @classmethod
    def validate_currency(cls, v: str | None) -> str | None:
        if v is None:
            return v
        if not re.match(r"^[A-Z]{3}$", v):
            raise ValueError(
                f"currency must be a 3-letter ISO code in UPPERCASE (e.g., USD), got {v!r}"
            )
        return v

    @field_validator("confidence")
    @classmethod
    def validate_confidence(cls, v: float | None) -> float | None:
        if v is None:
            return v
        if not (0.0 <= v <= 1.0):
            raise ValueError(f"confidence must be in [0.0, 1.0], got {v}")
        return v


# ---------------------------------------------------------------------------
# Baseline (prompt-only) extraction — intentionally fragile
# ---------------------------------------------------------------------------

BASELINE_PROMPT = """\
You are a document extraction system. Read the document below and return a JSON
object with the following fields: document_type, customer_name, vendor_name,
invoice_number, issue_date, tax_id, total_amount, currency, line_items, severity.

Return ONLY the JSON object. Do not include any explanation.

DOCUMENT:
{document}
"""


def run_baseline(client: anthropic.Anthropic, document_text: str) -> dict[str, Any]:
    """Prompt-only extraction. No schema, no tools, no tool_choice.

    This is the anti-pattern we use to motivate the switch to tool_use.
    Expect to see: inconsistent key casing, fabricated values for absent
    fields, occasional wrapping in {"data": {...}} or prose preamble.
    """
    response = client.messages.create(
        model=MODEL_ID,
        max_tokens=MAX_TOKENS,
        messages=[{"role": "user", "content": BASELINE_PROMPT.format(document=document_text)}],
    )

    # Best-effort JSON parsing — this is the fragile part students should see.
    text = response.content[0].text
    try:
        # Naive parse first
        return json.loads(text)
    except json.JSONDecodeError:
        # Try to find a JSON object anywhere in the string
        match = re.search(r"\{.*\}", text, re.DOTALL)
        if match:
            try:
                return json.loads(match.group(0))
            except json.JSONDecodeError:
                pass
        # Surface the parse failure honestly — this is the failure mode we want
        # students to see.
        return {"_parse_error": "could not parse JSON from model output", "_raw": text}


# ---------------------------------------------------------------------------
# Structured extraction — tool_use + schema + tool_choice + retry
# ---------------------------------------------------------------------------

STRUCTURED_SYSTEM = """\
You are a document extraction system. Your ONLY job is to call the \
extract_document tool with fields populated from the document below.

Rules:
1. Always call the extract_document tool. Never respond with text.
2. For nullable fields (invoice_number, issue_date, tax_id, total_amount,
   currency, confidence) — if the value is NOT present in the source document,
   return null. NEVER fabricate a plausible value to fill a gap.
3. For optional fields (customer_name, vendor_name, line_items, issue_summary,
   severity) — omit the field entirely if it does not apply to the document
   type.
4. For document_type — pick from the enum. If none fit, use "other" AND
   populate document_type_detail.
5. For detected_pattern — populate with a short snake_case identifier for any
   unusual pattern in the document (e.g., "mixed_language", "missing_header",
   "handwritten_insertion"). Use "none" if the document is standard.
6. All dates MUST be ISO-8601 (YYYY-MM-DD). All currencies MUST be 3-letter
   UPPERCASE ISO codes (USD, EUR, GBP).
"""


def _extract_tool_use_block(response: anthropic.types.Message) -> dict | None:
    """Pull the first tool_use block out of a response, if any."""
    for block in response.content:
        if getattr(block, "type", None) == "tool_use":
            return block.input  # dict of field → value
    return None


def run_structured(
    client: anthropic.Anthropic,
    document_text: str,
    force_tool: bool = True,
) -> tuple[ExtractedDocument | None, list[str], int]:
    """Tool_use extraction with validation-retry loop.

    Args:
        client: Anthropic client.
        document_text: the document to extract from.
        force_tool: if True, use tool_choice={"type": "tool", "name": ...}
            to FORCE the tool call (recommended). If False, uses
            tool_choice={"type": "any"} which forces SOME tool but leaves
            room for multi-tool setups. Never use "auto" for extraction
            pipelines — the model may return prose and skip the tool.

    Returns:
        (ExtractedDocument | None, errors_on_last_attempt, attempts_used)
    """
    # --- Choose tool_choice -------------------------------------------------
    if force_tool:
        # Forced tool — 99% of extraction pipelines want this.
        tool_choice = {"type": "tool", "name": EXTRACTION_TOOL["name"]}
    else:
        # "any" — guarantees some tool call, useful when you have multiple
        # extraction schemas and want the model to pick which one.
        tool_choice = {"type": "any"}

    # We'll build up the conversation across retries. Each retry APPENDS the
    # model's bad extraction + a user turn with the specific validation errors.
    messages: list[dict[str, Any]] = [
        {"role": "user", "content": f"DOCUMENT:\n{document_text}"}
    ]

    last_errors: list[str] = []

    for attempt in range(MAX_RETRIES + 1):
        response = client.messages.create(
            model=MODEL_ID,
            max_tokens=MAX_TOKENS,
            system=STRUCTURED_SYSTEM,
            tools=[EXTRACTION_TOOL],
            tool_choice=tool_choice,
            messages=messages,
        )

        tool_input = _extract_tool_use_block(response)

        if tool_input is None:
            # Shouldn't happen with forced tool_choice, but defense in depth.
            last_errors = ["model did not emit a tool_use block"]
            break

        # --- Validate with Pydantic -------------------------------------
        try:
            doc = ExtractedDocument(**tool_input)
            return doc, [], attempt + 1
        except ValidationError as ve:
            # Pydantic's error messages are already high-quality. We pass
            # them back to the model verbatim — this is the retry feedback
            # pattern from Task Statement 4.4.
            error_lines = []
            for err in ve.errors():
                loc = ".".join(str(p) for p in err["loc"])
                error_lines.append(f"  - {loc}: {err['msg']}")
            last_errors = error_lines

            if attempt >= MAX_RETRIES:
                break

            # Append model's bad extraction as an assistant message, then a
            # user message with the specific errors. This is how Claude "sees"
            # what went wrong.
            messages.append({"role": "assistant", "content": response.content})
            messages.append({
                "role": "user",
                "content": (
                    # We have to respond to the tool_use block with a
                    # tool_result block before adding new text.
                    [
                        {
                            "type": "tool_result",
                            "tool_use_id": next(
                                b.id for b in response.content
                                if getattr(b, "type", None) == "tool_use"
                            ),
                            "content": (
                                "Your extraction failed validation with these errors:\n"
                                + "\n".join(error_lines)
                                + "\n\nPlease call extract_document again with the errors fixed. "
                                "Remember: format errors (like date format) are fixable by re-reading "
                                "the source document. Do NOT fabricate values for fields that are "
                                "truly absent — return null for those."
                            ),
                            "is_error": True,
                        }
                    ]
                ),
            })
            # Loop continues to the next attempt.

    # Retries exhausted.
    return None, last_errors, MAX_RETRIES + 1


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _iter_inputs(path: Path) -> list[Path]:
    if path.is_file():
        return [path]
    if path.is_dir():
        return sorted(p for p in path.iterdir() if p.is_file() and p.suffix == ".txt")
    raise FileNotFoundError(f"Input path not found: {path}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Demo 3 — structured extraction pipeline")
    parser.add_argument("--input", required=True, help="Path to a .txt file or directory of .txt files")
    parser.add_argument(
        "--mode",
        choices=("baseline", "structured", "structured-any"),
        default="structured",
        help="baseline = prompt-only (failing). structured = tool_use + forced tool_choice. "
             "structured-any = tool_use + tool_choice='any'.",
    )
    args = parser.parse_args()

    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("ERROR: ANTHROPIC_API_KEY not set. Run: export ANTHROPIC_API_KEY=sk-ant-...", file=sys.stderr)
        return 2

    client = anthropic.Anthropic()
    inputs = _iter_inputs(Path(args.input))

    print(f"\n{'=' * 72}")
    print(f"Demo 3 — Structured Data Extraction — mode: {args.mode}")
    print(f"Running against {len(inputs)} document(s)\n")

    for path in inputs:
        print(f"--- {path.name} {'-' * (66 - len(path.name))}")
        text = path.read_text()

        if args.mode == "baseline":
            result = run_baseline(client, text)
            print(json.dumps(result, indent=2))
            # Point out drift: key set varies run-to-run.
            print(f"  [keys: {sorted(result.keys()) if isinstance(result, dict) else '??'}]")
        else:
            force = args.mode == "structured"
            doc, errors, attempts = run_structured(client, text, force_tool=force)
            if doc is not None:
                print(json.dumps(doc.model_dump(exclude_none=True), indent=2))
                print(f"  [validated in {attempts} attempt(s), detected_pattern={doc.detected_pattern!r}]")
            else:
                print("  EXTRACTION FAILED after retries. Last errors:")
                for e in errors:
                    print(f"    {e}")
                print(f"  [attempts: {attempts}]")
                print("  NOTE: if the error is 'information absent from source', retries won't help.")
                print("        Route to human review instead — see README for confidence-based routing.")
        print()

    return 0


if __name__ == "__main__":
    sys.exit(main())
