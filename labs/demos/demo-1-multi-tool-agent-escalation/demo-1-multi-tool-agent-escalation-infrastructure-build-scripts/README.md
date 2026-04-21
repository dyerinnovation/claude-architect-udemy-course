# Demo 1 — Infrastructure Build Scripts

One-page code walk-through for the multi-tool escalation agent. See the parent `README.md` for learning objectives, exam-domain mapping, and the recording script.

## Files

| File | Purpose |
|---|---|
| `agent.py` | The runnable agent. ~230 lines, heavily commented. Implements the tool_use loop, four tool schemas, and four mock tool implementations. |
| `requirements.txt` | Pinned deps. Only `anthropic==0.40.0` — no other runtime dependencies. |
| `.env.example` | Template for the `ANTHROPIC_API_KEY` env var. Copy to `.env` and fill in. |
| `deploy-demo-1-multi-tool-agent-escalation.sh` | Creates `.venv`, installs deps, prints next-step commands. Idempotent. |
| `cleanup-demo-1-multi-tool-agent-escalation.sh` | Removes `.venv`. No cloud resources to tear down. |

## `agent.py` — what to read and in what order

1. **`TOOLS` list (lines ~65–165).** Four tool schemas. Read the `description` fields closely — that's the Domain 2 test surface. Specifically:
   - `process_refund.description` contains `"Do NOT use for refunds over $500, or when the order cannot be found — use escalate_to_human instead."` — the boundary clause that steers the model on the edge case.
   - `escalate_to_human.input_schema` requires four fields: `customer_id`, `issue_summary`, `attempted_steps`, `recommended_action`. This is the structured handoff packet Domain 5 tests.
2. **Tool implementations (lines ~170–230).** Four mock functions. `lookup_order` has one order (`ORD-1001`); anything else returns `{"error": "order_not_found"}`. `get_refund_policy` hardcodes a $500 auto-approve threshold — that's the policy the edge case violates.
3. **`run_agent()` (lines ~240–295).** The agentic loop. This is the Domain 1 anchor. Key lines:
   - `if response.stop_reason == "end_turn": return` — the exit condition.
   - The `for block in response.content` pass that collects `tool_use` blocks and dispatches each one.
   - `messages.append({"role": "user", "content": tool_results})` — appending results back so the model has context for the next turn.
4. **`SCENARIOS` dict (lines ~300–310).** The two canned user messages. `happy-path` resolves with three tool calls. `edge-case` escalates.

## How to verify the demo is working

After running `bash deploy-demo-1-multi-tool-agent-escalation.sh`:

```bash
source .venv/bin/activate
export ANTHROPIC_API_KEY=sk-ant-...
python agent.py --scenario happy-path
```

Expected shape of the happy-path output:

```
USER: Hi, my order ORD-1001 arrived broken...
------------------------------------------------------------------------
turn=1 stop_reason=tool_use
  TOOL CALL: lookup_order({"order_id": "ORD-1001"})
  TOOL RESULT: {"order_id": "ORD-1001", "customer_id": "CUST-42", ...}
turn=2 stop_reason=tool_use
  TOOL CALL: get_refund_policy({})
  TOOL RESULT: {"auto_approve_threshold_usd": 500, ...}
turn=3 stop_reason=tool_use
  TOOL CALL: process_refund({"order_id": "ORD-1001", "refund_amount": 89.0, ...})
  TOOL RESULT: {"refund_id": "REF-...", "status": "approved"}
turn=4 stop_reason=end_turn
ASSISTANT: I've processed your refund of $89.00 for order ORD-1001...
------------------------------------------------------------------------
[loop exit: end_turn]
```

Then:

```bash
python agent.py --scenario edge-case
```

The edge case should end with a `TOOL CALL: escalate_to_human(...)` that includes all four handoff-packet fields, followed by a `stop_reason=end_turn` turn where the agent tells the customer the case was escalated. If the agent instead calls `process_refund` directly, the tool-description boundary isn't holding — see the presenter troubleshooting note in the recording script.

## Extending this demo (optional exercises)

- **Add a `update_shipping_address` tool** and test a multi-concern request ("refund my order AND update my address") to demonstrate decomposition.
- **Return `{"errorCategory": "transient", "isRetryable": true}` from a simulated flaky tool** and observe retry behavior — this covers Exercise 1 step 3 on structured error envelopes.
- **Wrap tool dispatch with a policy hook** that blocks `process_refund` calls above $500 before they execute (rather than relying on the model to pick escalation) — this covers Exercise 1 step 4 on programmatic hooks.
