"""
Demo 4 — Multi-Agent Research Pipeline (hub-and-spoke).

Architecture
------------
    ┌─────────────────────────────┐
    │      COORDINATOR (hub)      │
    │  decompose → dispatch →     │
    │  aggregate + provenance     │
    └──────┬────────┬────────┬────┘
           │        │        │          <-- parallel dispatch
    ┌──────▼──┐ ┌───▼────┐ ┌─▼──────┐
    │subagent-1│ │subagent-2│ │subagent-3│  <-- ISOLATED contexts
    │ (private │ │ (private │ │ (private │
    │ msgs list│ │ msgs list│ │ msgs list│
    └──────────┘ └──────────┘ └──────────┘
           │        │        │
           └────────┴────────┘
                    │
          structured handoffs
          (subagent_handoff.json)
                    │
                    ▼
        final_report.json with
        claim-source provenance
        + conflicts + coverage gaps

Exam anchors
------------
- Domain 1 (Agentic Architecture, 27%):
    * Coordinator-subagent (hub-and-spoke) pattern.
    * Task decomposition — 1 broad question → N focused sub-questions.
    * Parallel subagent execution.
    * `stop_reason`-driven control flow in the coordinator loop.

- Domain 5 (Context Management & Reliability, 15%):
    * Subagent context isolation (each has its own messages list — nothing leaks).
    * Explicit context passing — sub-question embedded in subagent's opening prompt.
    * Claim-source provenance — every claim in the final report maps back to
      `{subagent_id, source_url, confidence}`.
    * Documented failure mode for conflicting subagent claims: flag + defer to user.

Production vs demo note
-----------------------
In production on the Claude Agent SDK the coordinator would emit multiple `Task`
tool_use blocks in a single assistant response to spawn isolated subagents
natively. For reproducible demo recording we use `concurrent.futures.ThreadPoolExecutor`
with parallel `messages.create` calls — same architectural properties (parallel,
isolated messages lists per subagent), just without the SDK runtime. The lines
where this matters are flagged with "# PRODUCTION vs DEMO:" comments.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import datetime as _dt
import json
import os
import pathlib
import sys
import textwrap
import time
from dataclasses import dataclass, field
from typing import Any

import jsonschema
from anthropic import Anthropic


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

HERE = pathlib.Path(__file__).resolve().parent
SCHEMA_DIR = HERE / "schemas"
DEFAULT_OUTPUT_DIR = HERE / "research-output"

MODEL = os.environ.get("CLAUDE_MODEL", "claude-sonnet-4-5-20250929")
SUBAGENT_COUNT = int(os.environ.get("SUBAGENT_COUNT", "3"))
MAX_COORDINATOR_STEPS = int(os.environ.get("MAX_COORDINATOR_STEPS", "6"))

HANDOFF_SCHEMA = json.loads((SCHEMA_DIR / "subagent_handoff.json").read_text())
REPORT_SCHEMA = json.loads((SCHEMA_DIR / "final_report.json").read_text())


# ---------------------------------------------------------------------------
# Coordinator — decomposition step
# ---------------------------------------------------------------------------

DECOMPOSE_SYSTEM = textwrap.dedent(
    f"""\
    You are the COORDINATOR of a hub-and-spoke research pipeline.

    Your first job is decomposition. Given one broad research question, you must
    produce exactly {SUBAGENT_COUNT} focused, NON-OVERLAPPING sub-questions. Each
    sub-question will be handed to a separate subagent with its own isolated context.

    Rules:
      - Each sub-question must be self-contained (a subagent will receive ONLY
        that sub-question plus the original question for orientation — no
        sibling context).
      - Sub-questions must NOT overlap. Overlap defeats parallelism and leaks
        context assumptions across spokes.
      - Prefer sub-questions that can each be answered from distinct source
        classes (e.g. one on benchmarks, one on architecture, one on trade-offs).

    You MUST respond by calling the `emit_decomposition` tool.
    """
)

DECOMPOSE_TOOL = {
    "name": "emit_decomposition",
    "description": "Emit the sub-question decomposition for the research question.",
    "input_schema": {
        "type": "object",
        "required": ["sub_questions"],
        "properties": {
            "sub_questions": {
                "type": "array",
                "minItems": SUBAGENT_COUNT,
                "maxItems": SUBAGENT_COUNT,
                "items": {"type": "string"},
            }
        },
    },
}


def coordinator_decompose(client: Anthropic, question: str) -> list[str]:
    """Run the coordinator's decomposition step.

    Uses `stop_reason` control flow: we force tool use, and we expect
    `stop_reason == "tool_use"` on the first turn. If the model instead
    returns `end_turn` we raise — that's a real failure the exam wants
    you to catch explicitly (Domain 1 agentic-loop handling).
    """
    response = client.messages.create(
        model=MODEL,
        max_tokens=1024,
        system=DECOMPOSE_SYSTEM,
        tools=[DECOMPOSE_TOOL],
        tool_choice={"type": "tool", "name": "emit_decomposition"},
        messages=[{"role": "user", "content": f"Research question: {question}"}],
    )

    # Domain 1 anchor: explicit stop_reason check.
    if response.stop_reason != "tool_use":
        raise RuntimeError(
            f"Coordinator decomposition expected stop_reason='tool_use', got "
            f"{response.stop_reason!r}. The coordinator refused to decompose."
        )

    for block in response.content:
        if getattr(block, "type", None) == "tool_use" and block.name == "emit_decomposition":
            return list(block.input["sub_questions"])

    raise RuntimeError("Coordinator returned tool_use stop_reason but no emit_decomposition block.")


# ---------------------------------------------------------------------------
# Subagents — parallel spokes with ISOLATED contexts
# ---------------------------------------------------------------------------

SUBAGENT_SYSTEM = textwrap.dedent(
    """\
    You are a RESEARCH SUBAGENT in a hub-and-spoke pipeline. You have been
    dispatched with one focused sub-question and NO access to what your
    sibling subagents are doing — your context is fully isolated.

    Your job is to produce a structured handoff for the coordinator:
      - 3 to 6 well-formed claims that answer the sub-question.
      - Each claim has a URL source and a confidence score in [0, 1].
      - If a claim is about a comparable named entity (a model, a benchmark,
        a product, an architecture), set the `entity` field so the coordinator
        can detect cross-subagent conflicts.
      - If you can't reliably answer, return an empty claims list and explain
        why in the `coverage` field. Do NOT fabricate sources.

    You MUST respond by calling the `emit_handoff` tool exactly once.
    """
)

HANDOFF_TOOL = {
    "name": "emit_handoff",
    "description": "Emit the structured research handoff to the coordinator.",
    "input_schema": {
        "type": "object",
        "required": ["subagent_id", "sub_question", "coverage", "claims"],
        "properties": {
            "subagent_id": {"type": "string"},
            "sub_question": {"type": "string"},
            "coverage": {"type": "string"},
            "claims": {
                "type": "array",
                "items": {
                    "type": "object",
                    "required": ["text", "source_url", "confidence"],
                    "properties": {
                        "text": {"type": "string"},
                        "source_url": {"type": "string"},
                        "confidence": {"type": "number", "minimum": 0, "maximum": 1},
                        "entity": {"type": "string"},
                    },
                },
            },
        },
    },
}


@dataclass
class SubagentResult:
    subagent_id: str
    handoff: dict[str, Any]
    latency_sec: float
    error: str | None = None


def run_subagent(
    subagent_id: str,
    sub_question: str,
    original_question: str,
) -> SubagentResult:
    """Run a single subagent with its own private messages list.

    Domain 5 anchor: the `messages` variable here is local to this call.
    Nothing in this list is ever shared with sibling subagents — that
    is the context-isolation guarantee the coordinator-subagent pattern
    depends on.

    Domain 1 anchor: explicit context passing. The sub-question and the
    framing of the original question are injected into the OPENING
    prompt, not inherited automatically.
    """
    client = Anthropic()

    # PRODUCTION vs DEMO: on the Claude Agent SDK, this subagent would be
    # spawned via a `Task` tool_use block from the coordinator, which creates
    # the isolated-context worker natively. Here we create a fresh messages
    # list per subagent — same effect for demo purposes.
    messages = [
        {
            "role": "user",
            "content": textwrap.dedent(
                f"""\
                You are {subagent_id}.

                Original research question (for orientation only; do not try to answer the whole thing):
                    {original_question}

                Your focused sub-question:
                    {sub_question}

                Produce your structured handoff now.
                """
            ),
        }
    ]

    t0 = time.monotonic()
    try:
        response = client.messages.create(
            model=MODEL,
            max_tokens=2048,
            system=SUBAGENT_SYSTEM,
            tools=[HANDOFF_TOOL],
            tool_choice={"type": "tool", "name": "emit_handoff"},
            messages=messages,
        )
    except Exception as exc:  # broad: subagent-level failures must propagate as structured handoff
        latency = time.monotonic() - t0
        return SubagentResult(
            subagent_id=subagent_id,
            latency_sec=latency,
            handoff={
                "subagent_id": subagent_id,
                "sub_question": sub_question,
                "coverage": f"Subagent dispatch failed: {exc!s}",
                "claims": [],
                "error": str(exc),
            },
            error=str(exc),
        )
    latency = time.monotonic() - t0

    handoff: dict[str, Any] | None = None
    for block in response.content:
        if getattr(block, "type", None) == "tool_use" and block.name == "emit_handoff":
            handoff = dict(block.input)
            # Force subagent_id to the caller-assigned value — don't trust the model
            # to self-identify correctly.
            handoff["subagent_id"] = subagent_id
            handoff["sub_question"] = sub_question
            break

    if handoff is None:
        return SubagentResult(
            subagent_id=subagent_id,
            latency_sec=latency,
            handoff={
                "subagent_id": subagent_id,
                "sub_question": sub_question,
                "coverage": "Subagent did not emit a handoff tool call.",
                "claims": [],
                "error": f"no_tool_use; stop_reason={response.stop_reason}",
            },
            error=f"no_tool_use; stop_reason={response.stop_reason}",
        )

    # Validate shape defensively before handing to the coordinator.
    try:
        jsonschema.validate(handoff, HANDOFF_SCHEMA)
    except jsonschema.ValidationError as ve:
        return SubagentResult(
            subagent_id=subagent_id,
            latency_sec=latency,
            handoff={
                "subagent_id": subagent_id,
                "sub_question": sub_question,
                "coverage": f"Subagent emitted invalid handoff: {ve.message}",
                "claims": [],
                "error": f"schema_validation: {ve.message}",
            },
            error=f"schema_validation: {ve.message}",
        )

    return SubagentResult(
        subagent_id=subagent_id,
        handoff=handoff,
        latency_sec=latency,
    )


def spawn_subagents_parallel(
    sub_questions: list[str],
    original_question: str,
) -> list[SubagentResult]:
    """Spawn all subagents in parallel.

    PRODUCTION vs DEMO: on the Claude Agent SDK, the coordinator would emit
    multiple `Task` tool_use blocks in a single assistant response; the SDK
    runtime runs them concurrently with isolated contexts. For reproducibility
    of this demo without depending on a specific SDK version, we use a
    ThreadPoolExecutor to dispatch the subagent API calls concurrently.
    Architectural properties (parallelism + context isolation) are preserved.
    """
    results: list[SubagentResult] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(sub_questions)) as pool:
        futures = {
            pool.submit(
                run_subagent,
                subagent_id=f"subagent-{i + 1}",
                sub_question=sq,
                original_question=original_question,
            ): i
            for i, sq in enumerate(sub_questions)
        }
        for fut in concurrent.futures.as_completed(futures):
            results.append(fut.result())
    # Sort back into dispatch order for stable reporting.
    results.sort(key=lambda r: int(r.subagent_id.split("-")[1]))
    return results


# ---------------------------------------------------------------------------
# Aggregation — claim-source provenance + conflict flagging
# ---------------------------------------------------------------------------


def detect_conflicts(
    results: list[SubagentResult],
) -> list[dict[str, Any]]:
    """Detect cross-subagent conflicts by grouping claims on the same `entity`.

    Failure-mode policy: when two subagents produce claims about the same
    entity whose normalized text differs, we DO NOT silently pick one. We
    emit a `conflicts` entry listing both claims with full provenance and
    mark `resolution = "deferred_to_user"`. This is the documented failure
    mode for contradictory claims.

    A richer implementation could call Claude as a conflict-adjudication
    subagent; the deferred-to-user policy here is deliberately conservative
    for the exam scenario.
    """
    by_entity: dict[str, list[dict[str, Any]]] = {}
    for res in results:
        for claim in res.handoff.get("claims", []):
            entity = claim.get("entity")
            if not entity:
                continue
            tagged = {
                "text": claim["text"],
                "subagent_id": res.subagent_id,
                "source_url": claim.get("source_url", "unknown"),
                "confidence": float(claim.get("confidence", 0.0)),
            }
            by_entity.setdefault(entity.strip().lower(), []).append(tagged)

    conflicts: list[dict[str, Any]] = []
    for entity_key, claims in by_entity.items():
        if len({_normalize(c["text"]) for c in claims}) <= 1:
            continue  # everyone agreed (or only one claim) — no conflict
        if len({c["subagent_id"] for c in claims}) < 2:
            continue  # conflicting claims from the same subagent — not a hub-and-spoke conflict
        conflicts.append(
            {
                "entity": entity_key,
                "competing_claims": claims,
                "resolution": "deferred_to_user",
            }
        )
    return conflicts


def _normalize(text: str) -> str:
    return " ".join(text.lower().split())


def aggregate_report(
    question: str,
    sub_questions: list[str],
    results: list[SubagentResult],
) -> dict[str, Any]:
    """Aggregate subagent handoffs into the final provenance-tagged report."""
    claims: list[dict[str, Any]] = []
    coverage_gaps: list[str] = []

    for res in results:
        handoff = res.handoff
        if not handoff.get("claims"):
            coverage_gaps.append(
                f"{res.subagent_id} produced no claims for '{handoff.get('sub_question')}': "
                f"{handoff.get('coverage', 'no coverage note')}"
            )
            continue
        for claim in handoff["claims"]:
            claims.append(
                {
                    "text": claim["text"],
                    "subagent_id": res.subagent_id,
                    "source_url": claim.get("source_url", "unknown"),
                    "confidence": float(claim.get("confidence", 0.0)),
                    **({"entity": claim["entity"]} if claim.get("entity") else {}),
                }
            )

    conflicts = detect_conflicts(results)

    report = {
        "question": question,
        "sub_questions": sub_questions,
        "subagent_ids": [r.subagent_id for r in results],
        "claims": claims,
        "conflicts": conflicts,
        "coverage_gaps": coverage_gaps,
        "generated_at": _dt.datetime.utcnow().isoformat() + "Z",
    }

    jsonschema.validate(report, REPORT_SCHEMA)
    return report


# ---------------------------------------------------------------------------
# Human-readable summary
# ---------------------------------------------------------------------------


def print_summary(report: dict[str, Any], results: list[SubagentResult]) -> None:
    print()
    print("=" * 72)
    print(f"Research question: {report['question']}")
    print("=" * 72)
    print()
    print("Sub-question decomposition:")
    for sid, sq in zip(report["subagent_ids"], report["sub_questions"]):
        print(f"  [{sid}] {sq}")
    print()
    print("Subagent latencies (parallel):")
    for r in results:
        marker = " (ERROR)" if r.error else ""
        print(f"  {r.subagent_id}: {r.latency_sec:5.2f}s{marker}")
    print()
    print(f"Aggregated claims ({len(report['claims'])}):")
    for c in report["claims"]:
        print(
            f"  - {c['text']}  "
            f"[{c['subagent_id']}, {c['source_url']}, conf={c['confidence']:.2f}]"
        )
    if report["conflicts"]:
        print()
        print(f"Conflicts flagged ({len(report['conflicts'])}) — resolution: deferred_to_user")
        for conflict in report["conflicts"]:
            print(f"  entity: {conflict['entity']}")
            for cc in conflict["competing_claims"]:
                print(f"    * [{cc['subagent_id']}] {cc['text']} ({cc['source_url']})")
    if report["coverage_gaps"]:
        print()
        print(f"Coverage gaps ({len(report['coverage_gaps'])}):")
        for gap in report["coverage_gaps"]:
            print(f"  - {gap}")
    print()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main() -> int:
    parser = argparse.ArgumentParser(description="Demo 4: Multi-Agent Research Pipeline.")
    parser.add_argument("--question", required=True, help="Broad research question to investigate.")
    parser.add_argument(
        "--output-dir",
        default=os.environ.get("OUTPUT_DIR", str(DEFAULT_OUTPUT_DIR)),
        help="Directory to write per-run report and per-subagent handoffs.",
    )
    args = parser.parse_args()

    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("ERROR: ANTHROPIC_API_KEY is not set. Copy .env.example to .env and export it.", file=sys.stderr)
        return 2

    out_dir = pathlib.Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    client = Anthropic()

    print(f"[coordinator] decomposing: {args.question}")
    sub_questions = coordinator_decompose(client, args.question)
    for i, sq in enumerate(sub_questions, 1):
        print(f"[coordinator]   sub-question {i}: {sq}")

    print(f"[coordinator] dispatching {len(sub_questions)} subagents in parallel...")
    t0 = time.monotonic()
    results = spawn_subagents_parallel(sub_questions, args.question)
    parallel_latency = time.monotonic() - t0
    print(f"[coordinator] all subagents returned in {parallel_latency:.2f}s (parallel wall-clock).")

    # Persist per-subagent handoffs for the recording script's jq demos.
    for r in results:
        (out_dir / f"handoff-{r.subagent_id}.json").write_text(
            json.dumps(r.handoff, indent=2)
        )

    report = aggregate_report(args.question, sub_questions, results)

    stamp = _dt.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    report_path = out_dir / f"report-{stamp}.json"
    report_path.write_text(json.dumps(report, indent=2))

    print_summary(report, results)
    print(f"[coordinator] wrote: {report_path}")
    for r in results:
        print(f"[coordinator] wrote: {out_dir / f'handoff-{r.subagent_id}.json'}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
