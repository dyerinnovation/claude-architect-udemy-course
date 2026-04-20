# Demo: Multi-Tool Agent with Escalation Logic — Detailed Script

**Duration**: ~15 min | **Section**: 8 | **Demo**: 1

---

### [0:00] Introduction

- In this demo, we'll walk through building a multi-tool agent that handles customer-support requests end-to-end, including escalation.
  - Define 3-4 MCP-style tools with descriptions carefully crafted to avoid selection confusion.
  - Wire up an agentic loop that dispatches on `stop_reason` until the model returns `end_turn`.
  - Install a hook that intercepts tool calls, enforces a refund-amount threshold, and routes blocked calls to escalation.
- This prepares you for Domain 1 (agentic loop control), Domain 2 (tool and error design), and Domain 5 (reliability and escalation).

---

### [0:30] Deploy Demo Environment

<!-- Draft the deploy narration here — walk through `python -m venv`, pip install, exporting ANTHROPIC_API_KEY, and kicking off customer_support_agent.py. Surface the tool-registry file that the agent loads. -->

---

### [2:00] Define Tools with Disambiguated Descriptions

<!-- Walk through tools.py: show the four tools (get_customer, lookup_order, process_refund, escalate_to_human). Call out the two similar tools — process_refund vs escalate_to_human — and read aloud the description language that steers Claude to the correct one. -->

---

### [5:00] Agentic Loop Driven by stop_reason

<!-- Show the while loop. Step through one iteration: response.stop_reason == "tool_use" — append tool_result blocks, continue. Next iteration: stop_reason == "end_turn" — break and print the final text. Emphasize that we do NOT hardcode a turn cap; the model decides when it's done. -->

---

### [8:00] Structured Error Envelopes and Retry Logic

<!-- Trigger a transient error (simulated timeout). Show the error envelope: { errorCategory: "transient", isRetryable: true, message: "..." }. The agent retries. Then trigger a validation error — isRetryable: false — and show the agent explaining the problem to the user rather than looping. -->

---

### [11:00] PostToolUse Hook: Threshold Enforcement and Escalation

<!-- Walk through the hook that inspects process_refund inputs. A $50 refund passes through. A $2,000 refund is blocked: the hook returns a synthetic tool_result that redirects the agent to call escalate_to_human with context. Show the final response that tells the customer their case was escalated. -->

---

### [13:30] Multi-Concern Decomposition

<!-- Send a single user message that mixes two issues (e.g., "refund my last order AND update my shipping address"). Show the model calling multiple tools in sequence, then synthesizing a unified response. -->

---

### [14:30] Cleanup and Wrap

<!-- Deactivate the venv, remove .venv. Recap the three exam-aligned takeaways: stop_reason control flow, structured error envelopes, and hook-driven escalation. -->
