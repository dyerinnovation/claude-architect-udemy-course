---
theme: default
title: "Lecture 3.11: Agent SDK Hooks: PostToolUse and Tool Call Interception"
info: |
  Claude Certified Architect – Foundations
  Section 3: Domain 1 — Agentic Architecture & Orchestration (27%)
highlighter: shiki
transition: fade-out
mdc: true
---

<style>
@import './style.css';
</style>

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 1 — TITLE
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-cover-accent"></div>

<div style="height: 100%; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center;">
  <div class="di-course-label">Claude Certified Architect – Foundations</div>
  <div class="di-cover-title">Agent SDK Hooks:<br><span style="color: #3CAF50;">PostToolUse</span> and Tool Call Interception</div>
  <div class="di-cover-subtitle">Lecture 3.11 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
In the previous lecture, we established that programmatic enforcement must happen in code — not in the prompt.

But where exactly does that code run in an agentic system?

The Claude Agent SDK gives you two specific interception points: hooks that run after a tool executes, and hooks that run before a tool executes. These are the architectural mechanisms that make deterministic enforcement possible in agentic systems.

This lecture covers both — what they do, when to use each one, and the code patterns that implement them.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — Two Hook Points in the Agentic Loop
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Two Hook Points in the Agentic Loop</div>

<v-click>
<div style="display: flex; align-items: stretch; gap: 1.5rem; margin-top: 0.75rem;">

  <!-- Flow diagram -->
  <div style="flex: 0 0 44%; display: flex; flex-direction: column; align-items: center; gap: 0.2rem;">
    <div class="di-flow-box" style="width: 100%;">Claude emits tool_use block</div>
    <div class="di-arrow">↓</div>
    <v-click at="2">
    <div class="di-flow-tool" style="width: 100%; background: #E3A008;">PreToolUse Hook<br><span style="font-size: 0.75rem; font-weight: 400;">inspect / block / modify call</span></div>
    <div class="di-arrow">↓</div>
    </v-click>
    <div class="di-flow-box" style="width: 100%; background: #0D7377;">Tool executes</div>
    <div class="di-arrow">↓</div>
    <v-click at="3">
    <div class="di-flow-stop" style="width: 100%; background: #1B8A5A;">PostToolUse Hook<br><span style="font-size: 0.75rem; font-weight: 400;">inspect / normalize / enrich result</span></div>
    <div class="di-arrow">↓</div>
    </v-click>
    <div class="di-flow-box" style="width: 100%;">Result returned to Claude</div>
  </div>

  <!-- Explanation -->
  <div style="flex: 1; font-size: 0.92rem; color: #111928; line-height: 1.65;">
    <p>The Agent SDK wraps the tool execution step with two programmable interception points.</p>
    <v-click at="2">
    <div class="di-step-card" style="margin-top: 0.5rem; border-left-color: #E3A008;">
      <span class="di-step-num" style="color: #E3A008;">PreToolUse</span> Runs before the tool executes. Use to validate the call, enforce limits, or block unauthorized actions entirely.
    </div>
    </v-click>
    <v-click at="3">
    <div class="di-step-card" style="margin-top: 0.5rem; border-left-color: #1B8A5A;">
      <span class="di-step-num" style="color: #1B8A5A;">PostToolUse</span> Runs after the tool executes but before the result is returned to Claude. Use to normalize, enrich, or validate the output.
    </div>
    </v-click>
    <v-click at="4">
    <p style="margin-top: 0.6rem; font-size: 0.88rem; color: #1A3A4A;">Both hooks are <strong>synchronous interception points</strong> — they can stop the flow, modify data, or let it pass through.</p>
    </v-click>
  </div>

</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The Agent SDK provides two programmable hook points that wrap the tool execution step.

[click] The PreToolUse hook runs before the tool executes. Claude has decided to call a tool and emitted a tool_use block. Your hook intercepts the call before it reaches the actual function. You can validate the inputs, check authorization, enforce limits, or block the call entirely.

[click] The PostToolUse hook runs after the tool executes but before the result is returned to Claude. The tool has finished. You can inspect, normalize, enrich, or transform the output before Claude sees it.

[click] Both hooks are synchronous interception points. They can halt the flow with an error, modify the data in transit, or let it pass through unchanged. They give you deterministic control at exactly the right moments in the loop.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — PostToolUse: Normalizing Tool Results
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">PostToolUse Hook — Normalizing Tool Results</div>

<v-click>

```python {all|4-7|10-19|22-26|all}
from claude_agent_sdk import AgentLoop, PostToolUseHook

# PostToolUse hook: normalize timestamps before Claude sees the result
class TimestampNormalizationHook(PostToolUseHook):

    def on_tool_result(self, tool_name: str, result: dict) -> dict:
        """Intercept result; return the (possibly modified) result."""

        # Normalize Unix timestamps to ISO 8601 across all result fields
        normalized = {}
        for key, value in result.items():
            if key.endswith("_at") or key.endswith("_date") or key == "timestamp":
                if isinstance(value, (int, float)):
                    # Unix epoch → ISO 8601
                    normalized[key] = datetime.utcfromtimestamp(value).isoformat() + "Z"
                else:
                    normalized[key] = value
            else:
                normalized[key] = value
        return normalized


# Register the hook with the agent loop
agent = AgentLoop(
    tools=[get_order, get_customer, process_refund],
    hooks=[TimestampNormalizationHook()]
)
```

</v-click>

<v-click>
<div style="display: flex; gap: 0.75rem; margin-top: 0.4rem; font-size: 0.82rem; color: #1A3A4A;">
  <div style="flex: 1; background: white; padding: 0.4rem 0.6rem; border-radius: 4px; border-left: 2px solid #3CAF50;">
    <strong style="color: #1B8A5A;">Why this matters:</strong> Claude reasons about dates in natural language. Unix timestamps like <code>1711929600</code> are ambiguous. ISO 8601 (<code>2024-04-01T00:00:00Z</code>) is unambiguous.
  </div>
  <div style="flex: 1; background: white; padding: 0.4rem 0.6rem; border-radius: 4px; border-left: 2px solid #0D7377;">
    <strong style="color: #0D7377;">Hook scope:</strong> this normalization happens for every tool — no changes needed in individual tool functions
  </div>
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the PostToolUse hook in practice.

The hook intercepts every tool result before Claude sees it. It iterates over the result dictionary looking for timestamp fields — anything ending in _at, _date, or called "timestamp." If the value is a Unix integer, it converts it to ISO 8601 before returning it.

[click] Why does this matter? Claude reasons about dates in natural language. A Unix timestamp like 1711929600 is a raw integer — Claude might interpret it as a count, a price, or miscompute relative dates. ISO 8601 format — 2024-04-01T00:00:00Z — is unambiguous. Claude handles it correctly.

[click] The architectural benefit: this normalization is centralized in the hook. Every tool in the system benefits automatically. You don't need to change individual tool functions. Consistency is guaranteed across the entire pipeline.

This is the PostToolUse pattern: take the raw output from the tool, clean or enrich it in the hook, return the improved version to Claude.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — PreToolUse: Blocking Unauthorized Calls
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">PreToolUse Hook — Blocking Unauthorized Tool Calls</div>

<v-click>

```python {all|4-8|11-21|24-29|all}
from claude_agent_sdk import AgentLoop, PreToolUseHook, BlockToolCall

class RefundGuardHook(PreToolUseHook):

    def __init__(self, max_refund_amount: float):
        self.max_refund_amount = max_refund_amount

    def on_tool_call(self, tool_name: str, tool_input: dict) -> None:
        """Raise BlockToolCall to prevent execution; return None to allow."""

        if tool_name == "process_refund":
            amount = tool_input.get("amount", 0)

            # Hard financial limit — deterministic enforcement
            if amount > self.max_refund_amount:
                raise BlockToolCall(
                    f"Refund of ${amount:.2f} exceeds the ${self.max_refund_amount:.2f} "
                    f"auto-approval limit. Escalate to supervisor."
                )

            # Authorization: verify user owns the order
            order_id = tool_input.get("order_id")
            user_id = tool_input.get("user_id")
            if not db.order_belongs_to_user(order_id, user_id):
                raise BlockToolCall("Unauthorized: order does not belong to requesting user.")

# Register the guard hook
agent = AgentLoop(
    tools=[get_order, process_refund],
    hooks=[RefundGuardHook(max_refund_amount=500.00)]
)
```

</v-click>

<v-click>
<div style="background: white; padding: 0.4rem 0.75rem; border-radius: 4px; border-left: 2px solid #E53E3E; font-size: 0.82rem; margin-top: 0.4rem;">
  <strong style="color: #E53E3E;">Key:</strong> <code>BlockToolCall</code> stops execution before the tool function runs. The error message becomes the tool result Claude sees — it can explain the situation to the user.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Now the PreToolUse hook.

The RefundGuardHook intercepts every call to the process_refund tool before it executes. It checks two things.

First, the financial limit: if the refund amount exceeds the configured maximum, it raises BlockToolCall with an explanation. The tool never runs.

[click] Second, authorization: it verifies that the order belongs to the requesting user — checked against the database, not inferred from context.

[click] When BlockToolCall is raised, the error message becomes the tool result that Claude sees in its context. Claude reads "Refund exceeds auto-approval limit. Escalate to supervisor." — and it can convey that to the customer intelligently.

This is the architectural pattern: the hook is the enforcement layer. The tool function itself can focus purely on its logic. The guard runs before execution — always, unconditionally.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — Hook Use Cases at a Glance
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">Hook Use Cases at a Glance</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.8rem; margin-top: 0.75rem;">

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-top: 3px solid #E3A008; border-radius: 6px; padding: 0.65rem 0.85rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #E3A008; margin-bottom: 0.3rem;">PreToolUse — Validation</div>
    Check inputs before execution. Validate formats, required fields, data types. Return a clear error if the call is malformed.
  </div>
  </v-click>

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-top: 3px solid #E53E3E; border-radius: 6px; padding: 0.65rem 0.85rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.3rem;">PreToolUse — Authorization</div>
    Verify the calling user is allowed to invoke this tool with these inputs. Block unauthorized calls before any side effects occur.
  </div>
  </v-click>

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-top: 3px solid #E53E3E; border-radius: 6px; padding: 0.65rem 0.85rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #E53E3E; margin-bottom: 0.3rem;">PreToolUse — Limit Enforcement</div>
    Financial thresholds, rate limits, quota checks. If the call exceeds a limit, block it with an explanatory error — before execution.
  </div>
  </v-click>

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-top: 3px solid #1B8A5A; border-radius: 6px; padding: 0.65rem 0.85rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">PostToolUse — Normalization</div>
    Convert formats (Unix → ISO 8601), normalize units, standardize field names. Claude receives clean, consistent data.
  </div>
  </v-click>

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-top: 3px solid #1B8A5A; border-radius: 6px; padding: 0.65rem 0.85rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">PostToolUse — Enrichment</div>
    Add derived fields, resolve IDs to human-readable names, append metadata. Reduces the reasoning burden on Claude.
  </div>
  </v-click>

  <v-click>
  <div style="background: white; border: 1px solid #c8e6d0; border-top: 3px solid #1B8A5A; border-radius: 6px; padding: 0.65rem 0.85rem; font-size: 0.9rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.3rem;">PostToolUse — Audit Logging</div>
    Log every tool result for observability. Capture inputs, outputs, timestamps, and user context before the result enters Claude's context.
  </div>
  </v-click>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Here's the full map of hook use cases.

[click] PreToolUse for validation: check that the inputs are well-formed before the tool runs.

[click] PreToolUse for authorization: verify the user is allowed to invoke this tool with these specific inputs.

[click] PreToolUse for limit enforcement: financial thresholds, rate limits, quota checks — block before execution if any limit is exceeded.

[click] PostToolUse for normalization: convert formats, standardize fields, clean up data before Claude reasons on it.

[click] PostToolUse for enrichment: add derived fields, resolve IDs to readable names, append metadata that reduces Claude's reasoning burden.

[click] PostToolUse for audit logging: capture every tool invocation — inputs, outputs, timestamp, user context — for observability and compliance.

PreToolUse is your enforcement layer. PostToolUse is your data quality layer. Together, they give you deterministic control over both directions of every tool interaction.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">Hooks vs Tool Logic vs Prompt Instructions</div>

<div class="di-exam-body">
  The exam will present scenarios where a candidate needs to enforce a constraint or normalize data in an agentic pipeline. Three mechanisms are offered: add logic to the tool function, use a prompt instruction, or use a hook. Know when each is correct.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Trap Answers</div>
  <ul style="margin: 0; padding-left: 1.2rem; font-size: 0.9rem;">
    <li>Using a prompt instruction to enforce a financial limit — probabilistic, not guaranteed</li>
    <li>Adding normalization logic to every individual tool function — not centralized, breaks DRY principle</li>
    <li>Putting authorization checks inside the tool function — too late if the tool has side effects before the check</li>
  </ul>
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Hook Rule</div>
  <strong>PreToolUse</strong> = enforcement before execution (limits, authorization, validation)<br>
  <strong>PostToolUse</strong> = data quality after execution (normalization, enrichment, logging)<br>
  Hooks provide centralized, deterministic guarantees — neither prompts nor individual tool functions can.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam will present a scenario — a financial limit to enforce, timestamps to normalize — and give you three options: use a prompt instruction, add logic to the individual tool function, or use a hook.

[click] The trap answers are: prompt instructions for financial limits (probabilistic), adding normalization to every tool function (not centralized), and putting authorization inside the tool function after side effects have already started.

[click] The hook rule: PreToolUse for enforcement before execution — limits, authorization, validation. PostToolUse for data quality after execution — normalization, enrichment, logging.

Hooks are centralized and deterministic. That's what neither prompts nor individual tool functions can provide. When the exam asks about enforcing constraints or normalizing data across all tools consistently, hooks are the answer.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">Agent SDK Hooks — What to Know Cold</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>PreToolUse hook</strong> runs before tool execution — intercept, validate, authorize, or block the call</li></v-click>
  <v-click><li><strong>PostToolUse hook</strong> runs after tool execution — normalize, enrich, or log the result before Claude sees it</li></v-click>
  <v-click><li>Classic PostToolUse use case: converting Unix timestamps to ISO 8601 for consistent date reasoning</li></v-click>
  <v-click><li>Classic PreToolUse use case: blocking refunds over a financial threshold before the tool executes</li></v-click>
  <v-click><li>Hooks = <strong>centralized, deterministic guarantees</strong> — one hook applies to every matching tool call across the pipeline</li></v-click>
  <v-click><li>Hooks are the implementation mechanism for programmatic enforcement — not prompts, not individual tool functions</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
What you need to know cold from this lecture:

PreToolUse hook runs before tool execution. Use it to intercept, validate, authorize, or block.

PostToolUse hook runs after tool execution. Use it to normalize, enrich, or log before Claude sees the result.

The canonical PostToolUse use case: Unix timestamps to ISO 8601.

The canonical PreToolUse use case: blocking refunds over a financial limit.

Hooks are centralized and deterministic. One hook applies to every matching tool call across the entire pipeline.

And the architectural connection: hooks are the implementation mechanism for programmatic enforcement. When the previous lecture said "enforce in code, not in the prompt" — this is where that code lives.
-->
