---
theme: default
title: "Lecture 3.11: Agent SDK Hooks — PostToolUse and Tool Call Interception"
info: |
  Claude Certified Architect – Foundations
  Section 3 — Agentic Architecture & Orchestration (Domain 1, 27%)
highlighter: shiki
transition: fade-out
mdc: true
canvasWidth: 1920
aspectRatio: 16/9
---

<style>
@import './design-system.css';
</style>

<script setup>
const flowContent = 'Claude emits tool_use block → [PreToolUse hook: inspect / block / modify] → Tool executes → [PostToolUse hook: inspect / normalize / enrich] → Result returned to Claude.'

const useCases = [
  { label: 'PreToolUse — Validation', detail: 'Check inputs before execution. Validate formats, required fields, data types.' },
  { label: 'PreToolUse — Authorization', detail: 'Verify the user is allowed to invoke this tool with these inputs. Block unauthorized calls before any side effect.' },
  { label: 'PreToolUse — Limit Enforcement', detail: 'Financial thresholds, rate limits, quota checks. Block with an explanatory error before execution.' },
  { label: 'PostToolUse — Normalization', detail: 'Convert formats (Unix → ISO 8601), normalize units, standardize field names.' },
  { label: 'PostToolUse — Enrichment', detail: 'Add derived fields, resolve IDs to readable names, append metadata.' },
  { label: 'PostToolUse — Audit Logging', detail: 'Log every tool invocation — inputs, outputs, timestamps, user context.' },
]

const takeaways = [
  { label: 'PreToolUse runs before execution', detail: 'Intercept, validate, authorize, or block the call before the tool side effect.' },
  { label: 'PostToolUse runs after execution', detail: 'Normalize, enrich, or log the result before Claude sees it.' },
  { label: 'Classic PostToolUse: Unix → ISO 8601', detail: 'Converting timestamps so Claude reasons about dates unambiguously across every tool.' },
  { label: 'Classic PreToolUse: refund threshold block', detail: 'Block any refund above the financial limit before the tool executes.' },
  { label: 'Hooks are centralized, deterministic guarantees', detail: 'One hook applies to every matching tool call — no per-tool drift.' },
  { label: 'Hooks are the mechanism for programmatic enforcement', detail: 'They are HOW you implement the deterministic guarantees from Lecture 3.10.' },
]

const mechanics = [
  { label: 'PreToolUse', detail: 'Runs before the tool executes. Validate, enforce limits, or block unauthorized actions entirely.' },
  { label: 'PostToolUse', detail: 'Runs after the tool executes, before the result is returned to Claude. Normalize, enrich, or validate the output.' },
  { label: 'Key property', detail: 'Both are synchronous interception points — stop the flow, modify data, or pass through.' },
]

const postCode = `class TimestampNormalizationHook(PostToolUseHook):
    """Convert any Unix timestamps in tool results to ISO 8601."""

    def on_tool_result(self, tool_name: str, result: dict) -> dict:
        for key, value in list(result.items()):
            if key.endswith("_at") and isinstance(value, (int, float)):
                result[key] = datetime.fromtimestamp(
                    value, tz=timezone.utc
                ).isoformat()
        return result


# Register the hook with the agent loop so it applies to every tool.
agent = AgentLoop(
    model="claude-opus-4-7",
    tools=ALL_TOOLS,
    hooks=[TimestampNormalizationHook()],
)`

const preCode = `class RefundGuardHook(PreToolUseHook):
    """Block refunds above the auto-approval limit before execution."""

    max_refund_cents = 50_000  # $500

    def on_tool_call(self, tool_name: str, tool_input: dict, user):
        if tool_name != "process_refund":
            return  # pass through

        # Authorization gate
        order = db.orders.get(tool_input["order_id"])
        if order.customer_id != user.id:
            raise BlockToolCall(
                errorCategory="authorization",
                isRetryable=False,
                description=f"Order {order.id} not owned by user {user.id}.",
            )

        # Financial limit gate
        if tool_input["amount_cents"] > self.max_refund_cents:
            raise BlockToolCall(
                errorCategory="limit_exceeded",
                isRetryable=False,
                description=(
                    f"Refund of \${tool_input['amount_cents']/100:.2f} "
                    f"exceeds auto-approval limit of $500. "
                    f"Escalate to human agent."
                ),
            )`
</script>

<Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
  <div style="position:absolute; inset:0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);"></div>
  <div style="position:relative; z-index:1; padding:110px 120px 96px; width:100%; height:100%; display:flex; flex-direction:column; justify-content:space-between;">
    <div style="display:flex; align-items:center; gap:24px;">
      <img src="/assets/logo-mark.png" alt="" style="width:72px; height:auto;" />
      <div style="font-family: var(--font-body); font-size:26px; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color: var(--mint-200);">Dyer Innovation</div>
    </div>
    <div>
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.11 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Agent SDK <span style="color: var(--sprout-500);">Hooks</span></h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">PostToolUse and tool call interception.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Implements 3.10</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Deterministic guarantees</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.11 — Agent SDK Hooks: PostToolUse and Tool Call Interception. In the previous lecture we drew the line between programmatic enforcement and prompt-based guidance. Hooks are the specific mechanism the Agent SDK gives you to implement the programmatic side of that line. They're also exam-tested in their own right. By the end of this lecture you will know when to reach for PreToolUse, when to reach for PostToolUse, and how each delivers a centralized, deterministic guarantee that an individual tool function cannot.
-->

---

<TwoColSlide
  variant="compare"
  title="Two Hook Points in the Agentic Loop"
  eyebrow="Where hooks run"
  leftLabel="Flow"
  rightLabel="Mechanics"
  :footerNum="2"
  :footerTotal="8"
>
  <template #left>
    <p>{{ flowContent }}</p>
    <p><strong>PreToolUse</strong> sits between Claude's tool_use block and the tool function. <strong>PostToolUse</strong> sits between the tool function's return and the result Claude sees.</p>
  </template>
  <template #right>
    <ul>
      <li v-for="(m, i) in mechanics" :key="i"><strong>{{ m.label }}.</strong> {{ m.detail }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Here's where hooks fit in the agentic loop. Claude emits a tool_use block. Before the tool function runs, PreToolUse hooks get a chance to inspect the call, enforce limits, or block the execution entirely. The tool function then runs. Before the result is returned to Claude, PostToolUse hooks get a chance to normalize the data, enrich it, or validate it. Both are synchronous interception points — you can stop the flow, modify the data, or pass through unchanged. That's the structural picture. PreToolUse is for enforcement before side effects. PostToolUse is for data quality after execution. They are NOT the same hook in different coats — each has a specific job, and the exam will test which job belongs where.
-->

---

<CodeBlockSlide
  eyebrow="PostToolUse"
  title="Normalizing Tool Results"
  lang="python"
  :code="postCode"
  annotation="Claude reasons about dates in natural language; Unix 1711929600 is ambiguous, ISO 8601 is unambiguous. Register once — normalization applies to every tool, no per-tool changes."
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Here's a canonical PostToolUse example: converting Unix timestamps to ISO 8601. The hook class overrides on_tool_result. For every tool that returns, it scans for fields ending in _at — a common naming convention for timestamps — and if the value is a number, it converts it to ISO 8601. The hook is registered once with the agent loop, and it applies to every tool call. Why it matters: Claude reasons about dates in natural language. The integer 1,711,929,600 is ambiguous — Claude might say "late March," but it can also miscount. ISO 8601 is unambiguous: 2024-04-01T00:00:00Z. Hook scope is centralized: you don't modify every tool function. One hook, one registration, applies globally.
-->

---

<CodeBlockSlide
  eyebrow="PreToolUse"
  title="Blocking Unauthorized Tool Calls"
  lang="python"
  :code="preCode"
  annotation="BlockToolCall stops execution before the tool runs. The structured error becomes the tool_result Claude sees — it can explain the situation to the user."
  :footerNum="4"
  :footerTotal="8"
/>

<!--
And here's a canonical PreToolUse example: the RefundGuardHook. Two gates. First, authorization: the hook checks that the authenticated user actually owns the order the refund is being issued against. If not, it raises BlockToolCall with a structured error — errorCategory, isRetryable, description. Second, financial limit: if the refund amount exceeds $500, the hook raises BlockToolCall with errorCategory limit_exceeded. The critical property: BlockToolCall stops execution BEFORE the tool function runs. No partial refund. No side effect. The structured error becomes the tool_result Claude sees, which means Claude can explain the situation to the user — "I can't process refunds over $500 without a human's approval" — instead of silently failing. This is exactly the programmatic enforcement from Lecture 3.10, implemented cleanly as a hook.
-->

---

<BulletReveal
  eyebrow="Use cases"
  title="Hook Use Cases at a Glance"
  :bullets="useCases"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Six common hook use cases. PreToolUse validation: check inputs before execution — formats, required fields, data types. PreToolUse authorization: verify the user is allowed to invoke this tool with these inputs, and block unauthorized calls before any side effect. PreToolUse limit enforcement: financial thresholds, rate limits, quota checks — all blocked with an explanatory error before execution. PostToolUse normalization: Unix to ISO 8601, unit conversion, field-name standardization. PostToolUse enrichment: resolving IDs to readable names, adding derived fields, appending metadata. PostToolUse audit logging: log every tool invocation with inputs, outputs, timestamps, and user context. The pattern: PreToolUse is for enforcement before execution. PostToolUse is for data quality after execution. Hold that dividing line in your head.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Hooks vs Tool Logic vs Prompt Instructions</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <CalloutBox variant="dont" title="Trap answers">
      <p>Using a prompt instruction to enforce a financial limit — probabilistic, not guaranteed.</p>
      <p>Adding normalization logic inside every individual tool function — decentralized, breaks DRY, drifts over time.</p>
      <p>Putting authorization checks inside the tool function — too late if the tool has side effects before the check.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Hook rule">
      <p><strong>PreToolUse</strong> = enforcement before execution (limits, authorization, validation).</p>
      <p><strong>PostToolUse</strong> = data quality after execution (normalization, enrichment, logging).</p>
      <p>Hooks give centralized, deterministic guarantees — one registration, every matching tool call.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Domain 1 · Hook traps" :num="6" :total="8" />
</Frame>

<!--
Three traps the exam reliably tests. First: using a prompt instruction to enforce a financial limit. Probabilistic. Wrong. Hooks or tool-level code are the right answer. Second: adding normalization logic to every individual tool function. Works the first time, drifts over time, breaks DRY — a PostToolUse hook is centralized and consistent. Third: putting authorization checks inside the tool function rather than in a PreToolUse hook. If the tool does any work before the check, the check is too late — side effects may already have happened. The hook rule: PreToolUse is for enforcement before execution; PostToolUse is for data quality after execution; hooks are centralized and deterministic. One registration applies to every matching tool call — and that centralization is what turns a best-effort guideline into an actual guarantee.
-->

---

<BulletReveal
  eyebrow="Takeaways"
  title="Agent SDK Hooks — What to Know Cold"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six takeaways to carry forward. One — PreToolUse runs before tool execution: intercept, validate, authorize, or block the call. Two — PostToolUse runs after tool execution: normalize, enrich, or log before Claude sees the result. Three — the classic PostToolUse example is converting Unix timestamps to ISO 8601 so Claude can reason about dates consistently. Four — the classic PreToolUse example is blocking a refund above the financial threshold before the tool executes. Five — hooks are centralized, deterministic guarantees: one hook registration applies to every matching tool call. And six — hooks are THE implementation mechanism for programmatic enforcement. When Lecture 3.10 said "enforce in code, not in the prompt," this is the code. In Lecture 3.12 we shift from runtime interception to task structure: how to decompose complex requests into sub-tasks, and when to choose a fixed chain versus a dynamic loop.
-->
