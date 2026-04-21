"""
Demo 1 — Multi-Tool Customer Support Agent with Escalation.

Runnable reference implementation for Preparation Exercise 1 from the
Anthropic Claude Certified Architect exam guide. Demonstrates:

  1. A tool_use loop driven by `stop_reason` (Domain 1 anchor concept).
  2. Tool descriptions with "Do NOT use for..." boundary language to
     prevent selection confusion between overlapping tools (Domain 2).
  3. An `escalate_to_human` tool that returns a structured handoff
     summary so context survives the human handoff (Domain 1 / Domain 5).

Run:
    python agent.py --scenario happy-path    # simple refund, resolves
    python agent.py --scenario edge-case     # ambiguous, escalates

Requires: anthropic>=0.40.0, Python 3.10+, ANTHROPIC_API_KEY env var.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from typing import Any

import anthropic


# ---------------------------------------------------------------------------
# Model configuration
# ---------------------------------------------------------------------------

# Sonnet 4.5 is the exam's reference model. Pin explicitly so behavior is
# reproducible when students run this after the course is published.
MODEL = "claude-sonnet-4-5"

# Upper bound on loop iterations. `stop_reason` governs exit in practice,
# but we cap as a safety net against a runaway loop (e.g., if a tool
# implementation silently errors and the model keeps retrying).
MAX_TURNS = 10


# ---------------------------------------------------------------------------
# System prompt — the agent's charter
# ---------------------------------------------------------------------------

SYSTEM_PROMPT = """You are a customer support agent for an e-commerce company.
Your job is to resolve customer issues by using the tools available to you.

Workflow:
- If the customer gives you an order ID, look it up first.
- Before processing any refund, check the refund policy.
- If a refund exceeds the auto-approve threshold, or if the order cannot
  be located, escalate to a human agent — do NOT attempt the refund.
- When you escalate, include everything the human will need: customer ID,
  a one-line issue summary, what you already tried, and a clear
  recommended next action.

Be empathetic and concise in your final reply to the customer."""


# ---------------------------------------------------------------------------
# Tool schemas
# ---------------------------------------------------------------------------
#
# Notice the boundary language in `process_refund.description`:
#   "Do NOT use for refunds over $500, or when the order cannot be found —
#    use escalate_to_human instead."
#
# That "Do NOT use for..." clause is the Domain 2 test material — it's what
# makes the agent pick `escalate_to_human` on the edge-case scenario instead
# of guessing or calling `process_refund` and letting it fail.

TOOLS: list[dict[str, Any]] = [
    {
        "name": "lookup_order",
        "description": (
            "Look up an order by its ID. Returns order details including "
            "customer_id, items, total, status, and order_date. Use this "
            "whenever the customer references an order and has given you "
            "an order ID. Returns an error dict if the order is not found."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "order_id": {
                    "type": "string",
                    "description": "The order identifier, e.g. 'ORD-1001'.",
                },
            },
            "required": ["order_id"],
        },
    },
    {
        "name": "get_refund_policy",
        "description": (
            "Return the company's current refund policy, including the "
            "auto-approve threshold (dollar amount above which human "
            "approval is required) and the return window in days. Call "
            "this before processing any refund to confirm the request "
            "is in policy."
        ),
        "input_schema": {
            "type": "object",
            "properties": {},
        },
    },
    {
        "name": "process_refund",
        "description": (
            "Issue a refund for an order. Requires a valid order_id and a "
            "refund_amount in dollars. Do NOT use for refunds over $500, "
            "or when the order cannot be found, or when the customer has "
            "not provided an order ID — use escalate_to_human instead. "
            "Returns a refund confirmation with refund_id and status."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "order_id": {"type": "string"},
                "refund_amount": {
                    "type": "number",
                    "description": "Refund amount in USD.",
                },
                "reason": {
                    "type": "string",
                    "description": "Short reason for the refund.",
                },
            },
            "required": ["order_id", "refund_amount", "reason"],
        },
    },
    {
        "name": "escalate_to_human",
        "description": (
            "Hand the case off to a human support agent. Use when the "
            "request is out of policy, ambiguous, missing critical "
            "information, or otherwise should not be auto-resolved. "
            "Returns a ticket_id. You MUST include a structured summary "
            "so the human has full context without re-interviewing the "
            "customer."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "customer_id": {
                    "type": "string",
                    "description": "Customer identifier, or 'unknown' if not yet established.",
                },
                "issue_summary": {
                    "type": "string",
                    "description": "One-line description of the customer's problem.",
                },
                "attempted_steps": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Each tool call you already made and what it returned.",
                },
                "recommended_action": {
                    "type": "string",
                    "description": "What you recommend the human do next.",
                },
            },
            "required": [
                "customer_id",
                "issue_summary",
                "attempted_steps",
                "recommended_action",
            ],
        },
    },
]


# ---------------------------------------------------------------------------
# Tool implementations (mocked — no external calls)
# ---------------------------------------------------------------------------

_ORDERS: dict[str, dict[str, Any]] = {
    "ORD-1001": {
        "order_id": "ORD-1001",
        "customer_id": "CUST-42",
        "items": [{"sku": "WIDGET-001", "qty": 1, "price": 89.00}],
        "total": 89.00,
        "status": "delivered",
        "order_date": "2026-04-02",
    },
}


def lookup_order(order_id: str) -> dict[str, Any]:
    """Mock order database. Returns order or a not-found error dict."""
    if order_id in _ORDERS:
        return _ORDERS[order_id]
    return {"error": "order_not_found", "order_id": order_id}


def get_refund_policy() -> dict[str, Any]:
    """Mock policy service. Threshold is what makes the edge case escalate."""
    return {
        "auto_approve_threshold_usd": 500,
        "return_window_days": 30,
        "notes": (
            "Refunds at or below the threshold may be processed by the "
            "agent. Refunds above the threshold require human approval."
        ),
    }


def process_refund(order_id: str, refund_amount: float, reason: str) -> dict[str, Any]:
    """Mock refund processor. Real impl would hit a payments API."""
    return {
        "refund_id": f"REF-{abs(hash(order_id)) % 1_000_000:06d}",
        "order_id": order_id,
        "amount_refunded": refund_amount,
        "reason": reason,
        "status": "approved",
    }


def escalate_to_human(
    customer_id: str,
    issue_summary: str,
    attempted_steps: list[str],
    recommended_action: str,
) -> dict[str, Any]:
    """Mock escalation. Real impl would create a ticket in Zendesk/Salesforce."""
    return {
        "ticket_id": f"TICKET-{abs(hash(issue_summary)) % 1_000_000:06d}",
        "assigned_to": "support_team",
        "priority": "medium",
        "handoff_packet": {
            "customer_id": customer_id,
            "issue_summary": issue_summary,
            "attempted_steps": attempted_steps,
            "recommended_action": recommended_action,
        },
    }


# Map tool names to their Python implementations so the loop can dispatch.
TOOL_IMPLS = {
    "lookup_order": lookup_order,
    "get_refund_policy": get_refund_policy,
    "process_refund": process_refund,
    "escalate_to_human": escalate_to_human,
}


def dispatch_tool(name: str, tool_input: dict[str, Any]) -> dict[str, Any]:
    """Dispatch a tool_use block to the matching Python function."""
    impl = TOOL_IMPLS.get(name)
    if impl is None:
        return {"error": f"unknown_tool: {name}"}
    try:
        return impl(**tool_input)
    except Exception as exc:  # noqa: BLE001 — surface the error into the loop
        return {"error": "tool_exception", "message": str(exc)}


# ---------------------------------------------------------------------------
# The agent loop — the heart of Domain 1
# ---------------------------------------------------------------------------

def run_agent(user_message: str) -> None:
    """
    Run the multi-tool agent loop against a single user message.

    The loop exit condition is `stop_reason == "end_turn"`. As long as the
    model keeps returning `stop_reason == "tool_use"`, we dispatch the
    tools, append their results, and call `messages.create` again.
    """
    client = anthropic.Anthropic()
    messages: list[dict[str, Any]] = [
        {"role": "user", "content": user_message}
    ]

    print(f"\nUSER: {user_message}\n" + "-" * 72)

    for turn in range(1, MAX_TURNS + 1):
        response = client.messages.create(
            model=MODEL,
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            tools=TOOLS,
            messages=messages,
        )

        print(f"turn={turn} stop_reason={response.stop_reason}")

        # Print any text the assistant produced on this turn.
        for block in response.content:
            if block.type == "text" and block.text.strip():
                print(f"ASSISTANT: {block.text.strip()}")

        # If the model is done, we exit — this is the Domain 1 test.
        if response.stop_reason == "end_turn":
            print("-" * 72 + "\n[loop exit: end_turn]\n")
            return

        # Otherwise, stop_reason should be "tool_use". Dispatch every
        # tool_use block in the response, collect results, and append
        # them back to `messages` as a single user turn.
        if response.stop_reason != "tool_use":
            print(f"[unexpected stop_reason: {response.stop_reason}] — exiting")
            return

        tool_results: list[dict[str, Any]] = []
        for block in response.content:
            if block.type != "tool_use":
                continue
            print(f"  TOOL CALL: {block.name}({json.dumps(block.input)})")
            result = dispatch_tool(block.name, block.input)
            print(f"  TOOL RESULT: {json.dumps(result)}")
            tool_results.append(
                {
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": json.dumps(result),
                }
            )

        # Append the assistant's turn (verbatim) and the tool results.
        messages.append({"role": "assistant", "content": response.content})
        messages.append({"role": "user", "content": tool_results})

    print(f"[loop exit: hit MAX_TURNS={MAX_TURNS} without end_turn]")


# ---------------------------------------------------------------------------
# CLI — two scenarios the recording script walks through
# ---------------------------------------------------------------------------

SCENARIOS = {
    "happy-path": (
        "Hi, my order ORD-1001 arrived broken. The widget was crushed in "
        "shipping. I'd like a refund please."
    ),
    "edge-case": (
        "Hi, I need a refund of $2,400 for an order I placed about six "
        "months ago. I don't remember the order ID. Can you just process "
        "the refund to my card on file?"
    ),
}


def main() -> int:
    parser = argparse.ArgumentParser(description="Demo 1 multi-tool agent.")
    parser.add_argument(
        "--scenario",
        choices=list(SCENARIOS.keys()),
        default="happy-path",
        help="Which canned user message to send.",
    )
    parser.add_argument(
        "--message",
        default=None,
        help="Custom user message (overrides --scenario).",
    )
    args = parser.parse_args()

    if not os.environ.get("ANTHROPIC_API_KEY"):
        print(
            "ERROR: ANTHROPIC_API_KEY is not set. Export it or copy "
            ".env.example to .env and fill it in.",
            file=sys.stderr,
        )
        return 2

    user_message = args.message or SCENARIOS[args.scenario]
    run_agent(user_message)
    return 0


if __name__ == "__main__":
    sys.exit(main())
