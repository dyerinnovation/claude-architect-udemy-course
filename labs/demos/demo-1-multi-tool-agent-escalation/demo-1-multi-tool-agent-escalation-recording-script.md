# Demo 1 — Multi-Tool Agent with Escalation — Recording Script

- **Section:** 8 — Demo 1
- **Target duration:** 6–8 minutes
- **Format:** Udacity timestamped walkthrough (`[M:SS]`)

---

## Recording setup (before you hit record)

- Two panes visible: left = editor showing `agent.py`, right = terminal with `.venv` activated and `ANTHROPIC_API_KEY` exported.
- Terminal font at 16pt minimum — the tool-call transcript is the star of the show.
- Pre-run `python agent.py --scenario happy-path` once off-camera to confirm the API key works; clear the terminal before recording.

---

### [0:00] Opening

**Narration.** "Welcome to Demo 1. In the next seven minutes, we're going to build — and run — the customer-support agent from Preparation Exercise 1 of the exam guide. The goal is to make the agentic loop concrete: not a diagram, but actual control flow you can watch stream by in a terminal. We'll define four tools, run a happy-path request, then break the agent on purpose to see escalation fire."

**On-screen action.**
- Show the demo directory tree in the terminal: `ls labs/demos/demo-1-multi-tool-agent-escalation/`.
- Open `agent.py` in the editor pane.

---

### [0:30] Agent goal and the exam scenario

**Narration.** "This is Scenario 1 from the exam — Customer Support Resolution. Our agent handles refund requests end to end. It has to identify the customer, look up an order, and either process a refund or hand off to a human. The exam specifically wants you to test what happens when a request is ambiguous or out of policy — that's the edge case we'll trigger on purpose at minute four. Domain 1 is twenty-seven percent of the exam, so this pattern is the single highest-leverage thing you can practice."

**On-screen action.**
- Scroll to the top of `agent.py` and highlight the module docstring.
- Highlight the `SYSTEM_PROMPT` constant so viewers see the agent's charter.

---

### [1:00] Show the four tools

**Narration.** "Four tools. `lookup_order` finds an order by ID. `get_refund_policy` returns the business rules — importantly, refunds over five hundred dollars require human approval. `process_refund` issues the refund, but notice its description: 'Do NOT use for refunds over $500, or when the order cannot be found — use escalate_to_human instead.' That boundary language is Domain 2 test material. And `escalate_to_human` — this is the handoff. It returns a structured summary: customer, issue, what we already tried, and a recommended action. That's the context packet the human receives, straight from Domain 5."

**On-screen action.**
- Scroll to the `TOOLS` list in `agent.py`.
- Highlight each tool's `description` field in turn.
- Pause on the "Do NOT use for..." line in `process_refund` — this is the visual take-home.

---

### [2:00] Happy-path request

**Narration.** "Let's run the simple case first. The user says: 'I want to return order ORD-1001 — widget arrived broken.' Watch the loop. Turn one: the agent calls `lookup_order`, `stop_reason` is `tool_use`, so the loop continues. Turn two: it calls `get_refund_policy`, sees the order total is under $500, so policy allows it. Turn three: it calls `process_refund`. Turn four: `stop_reason` is `end_turn` — the loop exits, and the agent prints a confirmation message to the customer."

**On-screen action.**
- Run `python agent.py --scenario happy-path` in the right pane.
- Let the transcript stream. Each turn prints `turn=N stop_reason=...` — point at those lines.
- On the final turn, underline `stop_reason=end_turn` — "this is the exit condition."

---

### [3:00] Read the happy-path transcript

**Narration.** "Look at the shape of what just happened. Three tool calls, each one's `tool_result` appended back into `messages`. The agent built up context across turns without us managing it — we just looped until `stop_reason` stopped being `tool_use`. No hard-coded turn limit. No manual dispatch table. That's the exam's anchor concept, and the code that makes it work is the twelve-line `while True` loop at the bottom of `agent.py`."

**On-screen action.**
- Scroll `agent.py` to the `run_agent()` function.
- Highlight the `while True` loop and the `if response.stop_reason == "end_turn": break` line.

---

### [4:00] Edge-case request — the escalation trigger

**Narration.** "Now we break it on purpose. The user's new message: 'I need a twenty-four-hundred-dollar refund on an order from six months ago, but I don't remember the order ID.' Two problems. One, twenty-four hundred dollars is over the five-hundred-dollar policy threshold. Two, there's no order ID to look up. This is exactly the ambiguous-plus-out-of-policy scenario Exercise 1 step five asks you to test."

**On-screen action.**
- Clear the terminal.
- Show the `--scenario edge-case` user message — it's defined as a constant at the top of `agent.py`.
- Run `python agent.py --scenario edge-case`.

---

### [4:30] Escalation handoff

**Narration.** "Watch what the agent does. It calls `get_refund_policy` first — good, it's checking the rule. It sees the amount exceeds five hundred. It also sees no order ID was provided. Instead of guessing or calling `process_refund` and letting it fail, it calls `escalate_to_human` with a structured summary. Customer ID, issue description, attempted steps — including 'policy check: refund amount $2,400 exceeds $500 auto-approve threshold' — and a recommended action: 'verify customer identity and locate the order.' That's the handoff packet. A human picks up with full context. No re-interviewing the customer. That's the Domain 5 reliability pattern in one tool call."

**On-screen action.**
- Pause the transcript on the `escalate_to_human` tool call.
- Expand the `tool_use.input` JSON in the terminal — highlight each field of the handoff packet.
- Call out the `recommended_action` field specifically.

---

### [5:30] Recap and exam framing

**Narration.** "Three takeaways. One — the agentic loop is `while stop_reason == 'tool_use': continue`. That's it. If you see an exam question asking when the loop terminates, the answer is almost always `end_turn`. Two — tool descriptions steer selection. The 'Do NOT use for...' boundary on `process_refund` is what made the agent pick escalation instead. If you see a question about why an agent picked the wrong tool, look at description overlap. Three — escalation is a tool, not an error. It returns a structured handoff, and the human receives it with full context."

**On-screen action.**
- Show a split view of `process_refund`'s description and `escalate_to_human`'s description side by side.
- Highlight the `stop_reason` branch in the loop one more time.

---

### [6:30] Close and next demo preview

**Narration.** "That's Demo 1. You've now seen the agentic loop, tool boundary-setting, and structured escalation — the three anchors of Domain 1. Everything in this demo is in `agent.py`, under two hundred and fifty lines. Clone it, re-run it, break it in different ways. In Demo 2, we pivot from the Claude API to Claude Code — we'll configure `CLAUDE.md`, path-scoped rules, and an MCP server for a multi-developer team. See you there."

**On-screen action.**
- Run `bash cleanup-demo-1-multi-tool-agent-escalation.sh` to show the teardown.
- Fade to the course outro card.

---

## Troubleshooting cues for the presenter

- **If `ANTHROPIC_API_KEY` is missing**, the agent prints a friendly error and exits — don't ad-lib; point at the error as a teaching moment about fail-fast config.
- **If the agent picks `process_refund` on the edge case anyway** (rare, non-deterministic), note it on camera: "Sonnet 4.5 got it right the last three runs — this one slipped through. That's exactly why tool-description hardening is iterative. We'd tighten that `Do NOT use for...` clause and re-test." Then re-run once more.
- **If the tool-use loop doesn't exit**, it's almost always because `tool_result` wasn't appended back into `messages`. The code does this at line ~200 — point at it if needed.
