---
theme: default
title: "Lecture 3.13: Session Management — resume, fork_session, When to Start Fresh"
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
const decisions = [
  { label: 'Resume (--resume)', detail: "Continue from exactly where the session left off. Full history — tool calls, results, reasoning — available to Claude." },
  { label: 'Fork (fork_session)', detail: 'Duplicate the current context and start two independent branches from the same baseline. Explore divergent approaches without cross-contamination.' },
  { label: 'Start Fresh', detail: 'New session with no prior history. Inject a structured summary of what was learned. Use when prior raw context is stale or too expensive.' },
]

const resumeSteps = [
  { title: 'Interrupted task', body: 'Session cut off mid-execution — network failure, timeout, graceful pause. Context still accurate. Resume.' },
  { title: 'Multi-phase work', body: 'Phase 1 completed with stable results. Phase 2 builds directly on Phase 1 output. Resume and continue.' },
  { title: 'Tool result reuse', body: 'Claude already retrieved data that is still current. Resuming avoids redundant tool calls — saves latency and cost.' },
]

const forkBaseline = 'Same research findings, same document context, same task history → Branch A: approach 1 · Branch B: approach 2. Both branches evolve independently.'
const forkUses = [
  { label: 'A/B evaluation', detail: 'Generate two candidate outputs from the same context for human review or automated scoring. Forking prevents cross-contamination.' },
  { label: 'Hypothesis testing', detail: 'Explore two investigative paths from the same starting evidence. A dead-end in one branch leaves the other unaffected.' },
]

const freshSteps = [
  { title: 'Stale tool results', body: 'Session has tool outputs referencing live data that has changed. Carrying forward causes incorrect reasoning. Summarize what was LEARNED (conclusions), discard raw results.' },
  { title: 'Context window pressure', body: 'Session history is large and approaching limits. Use /compact for in-session reduction, or start fresh for a clean slate.' },
  { title: 'Phase boundary with different tools', body: 'Phase 2 needs a different tool set and system prompt. Start fresh and inject Phase 1 conclusions as structured input.' },
]

const takeaways = [
  { label: 'Resume when context is still valid', detail: 'Interrupted tasks, stable multi-phase work, reuse of still-current tool results.' },
  { label: 'Fork for divergent branches from a shared baseline', detail: 'A/B evaluation and hypothesis testing — both branches start from the same trusted context.' },
  { label: 'Start fresh when results are stale or window is full', detail: 'Inject a structured summary of conclusions; never carry raw stale tool outputs.' },
  { label: 'Stale tool results cause INCORRECT reasoning', detail: 'Not just inefficiency — Claude will make wrong decisions on data that has since changed.' },
  { label: '/compact reduces size without discarding accuracy', detail: 'In-session compaction is right when the history is large but still current.' },
  { label: 'Injected summaries carry conclusions, never raw history', detail: 'Validated facts and decisions only — no tool-result snapshots, no transcripts.' },
]

const freshCode = `def build_session_summary(prior_session_messages: list[dict]) -> str:
    """Extract validated conclusions from a completed session."""

    prompt = (
        "Review the conversation below and produce a structured summary "
        "containing ONLY:\\n"
        "  - Validated findings (facts confirmed by tool results)\\n"
        "  - Decisions made and their rationale\\n"
        "  - Open questions that remain\\n\\n"
        "Do NOT include raw tool outputs, timestamps, or step-by-step history.\\n\\n"
        f"<conversation>\\n{format_messages(prior_session_messages)}\\n</conversation>"
    )

    response = client.messages.create(
        model="claude-opus-4-7",
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


def start_fresh_with_summary(prior_summary: str, next_task_prompt: str):
    """Begin a new session with injected conclusions — no stale tool results."""

    return client.messages.create(
        model="claude-opus-4-7",
        system=PHASE_2_SYSTEM_PROMPT,
        messages=[{
            "role": "user",
            "content": (
                f"<prior_summary>\\n{prior_summary}\\n</prior_summary>\\n\\n"
                f"{next_task_prompt}"
            ),
        }],
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
      <div style="font-family: var(--font-body); font-size:26px; font-weight:600; letter-spacing:0.16em; text-transform:uppercase; color: var(--sprout-500); margin-bottom:40px;">Lecture 3.13 &middot; Domain 1</div>
      <h1 style="font-family: var(--font-display); font-weight:500; font-size:128px; line-height:1.02; letter-spacing:-0.025em; color: var(--paper-0); margin:0; max-width:1600px;">Session <span style="color: var(--sprout-500);">Management</span></h1>
      <div style="font-family: var(--font-display); font-size:44px; color: var(--mint-200); margin-top:40px; font-weight:400; max-width:1300px; line-height:1.3;">Resume, fork_session, and when to start fresh.</div>
    </div>
    <div style="display:flex; align-items:center; gap:48px; font-family: var(--font-body); font-size:26px; color: var(--mint-200); letter-spacing:0.06em;">
      <span>Domain 1 · 27%</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Path C — Agent Architect</span>
      <span style="opacity:0.4;">&middot;</span>
      <span>Context lifecycle</span>
    </div>
  </div>
</Frame>

<!--
Welcome to Lecture 3.13 — Session Management: resume, fork_session, and when to start fresh. A non-trivial agentic workflow almost always lives across more than one session. Sometimes a session gets interrupted. Sometimes you need two parallel branches from the same starting point. Sometimes the context you've accumulated is actively wrong and needs to be discarded. The Agent SDK gives you three primitives — resume, fork, and start-fresh-with-summary — and each has a specific situation where it is the right call. This lecture is about recognising the signals that pick which one.
-->

---

<BulletReveal
  eyebrow="Three decisions"
  title="The Three Session Management Decisions"
  :bullets="decisions"
  :footerNum="2"
  :footerTotal="8"
/>

<!--
Here are the three primitives at a glance. Resume, with the --resume flag, continues from exactly where the session left off — the full history, tool calls, results, and reasoning are all available to Claude. Fork, with fork_session, duplicates the current context and starts two independent branches from the same baseline — letting you explore divergent approaches without cross-contamination. Start fresh is a new session with no prior history, where you inject a structured summary of what was learned instead of carrying the raw history forward. That's the full menu. The rest of this lecture is about when each is appropriate.
-->

---

<StepSequence
  eyebrow="Resume path"
  title="When to Resume a Session"
  :steps="resumeSteps"
  footerLabel="Do NOT resume when tool results reference live data that has changed"
  :footerNum="3"
  :footerTotal="8"
/>

<!--
Three situations where resume is the right choice. First, an interrupted task: the session was cut off mid-execution because of a network failure, a timeout, or a graceful pause. The context is still accurate — nothing has changed. Resume. Second, multi-phase work: phase one completed with stable results, and phase two builds directly on phase one's output. Resume and continue. Third, tool result reuse: Claude already retrieved data that is still current. Resuming avoids redundant tool calls and saves latency and cost. The important contra-rule: do NOT resume when tool results reference live data that has since changed. Resuming in that case means Claude reasons on stale context — and that causes incorrect decisions, not just suboptimal ones. We'll come back to this on the next two slides.
-->

---

<TwoColSlide
  variant="compare"
  title="When to Fork a Session"
  eyebrow="Branch from a shared baseline"
  leftLabel="Shared baseline"
  rightLabel="Use cases"
  :footerNum="4"
  :footerTotal="8"
>
  <template #left>
    <p>{{ forkBaseline }}</p>
    <p>Forking is cheaper than running two independent sessions from scratch — the shared baseline is only established once.</p>
  </template>
  <template #right>
    <ul>
      <li v-for="(u, i) in forkUses" :key="i"><strong>{{ u.label }}.</strong> {{ u.detail }}</li>
    </ul>
  </template>
</TwoColSlide>

<!--
Fork is the right primitive when you need divergent branches from the same trusted starting point. Picture a research session that has established a solid baseline — the same research findings, the same document context, the same task history. You want branch A to pursue one approach and branch B to pursue another. Both need to evolve independently, without cross-contamination. Two classic use cases. A/B evaluation: generate two candidate outputs from the same context for human review or automated scoring — forking prevents one branch's output from influencing the other. Hypothesis testing: explore two investigative paths from the same starting evidence, so that a dead-end in one branch leaves the other unaffected. Key property: forking is cheaper than running two independent sessions from scratch, because the baseline doesn't have to be re-established twice.
-->

---

<StepSequence
  eyebrow="Fresh start path"
  title="When to Start Fresh with an Injected Summary"
  :steps="freshSteps"
  footerLabel="Summary = conclusions and validated facts only — never raw tool outputs"
  :footerNum="5"
  :footerTotal="8"
/>

<!--
Start-fresh is the right primitive in three situations. First, stale tool results: the session has tool outputs that reference live data — stock prices, inventory, user status — that has since changed. Carrying the old outputs forward causes Claude to reason on incorrect data. Start fresh. Summarize what was LEARNED — the conclusions — and discard the raw results. Second, context-window pressure: the session history is large and approaching limits. Use /compact for in-session reduction when the history is still current, or start fresh for a clean slate. Third, phase boundary with different tools: phase two needs a different tool set and a different system prompt than phase one. Don't pollute the new system prompt with the old history — start fresh and inject phase one's conclusions as structured input. In all three cases, the injected summary carries conclusions and validated facts — never raw tool outputs.
-->

---

<CodeBlockSlide
  eyebrow="Code pattern"
  title="The Fresh Start + Injected Summary Pattern"
  lang="python"
  :code="freshCode"
  annotation="The new session has accurate, current context — no stale tool results. The summary carries conclusions, not raw history."
  :footerNum="6"
  :footerTotal="8"
/>

<!--
Here's the pattern in code. build_session_summary takes the prior session's messages and produces a structured summary using a specific prompt: include validated findings, decisions, and open questions; exclude raw tool outputs, timestamps, and step-by-step history. That constraint is the whole point — you're extracting conclusions, not compressing the transcript. Then start_fresh_with_summary opens a brand-new session with the phase-two system prompt and injects the prior summary inside a clearly tagged block in the first user message. The new session now has accurate, current context — no stale tool results dragging it into wrong conclusions. This is the pattern that makes long-horizon multi-session work viable: conclusions carry forward, raw history does not.
-->

---

<Frame>
  <Eyebrow>⚡ Exam tip</Eyebrow>
  <SlideTitle>Matching the Scenario to the Session Strategy</SlideTitle>
  <div style="margin-top: 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; flex: 1; min-height: 0;">
    <CalloutBox variant="dont" title="Traps to watch for">
      <p>Resuming a session whose tool results reference live data that has since changed — causes <strong>incorrect</strong> reasoning, not just inefficiency.</p>
      <p>Using fork_session when you just need to restart — fork preserves history, it doesn't clean it.</p>
      <p>Starting fresh without injecting context — the new session has no knowledge of prior findings.</p>
    </CalloutBox>
    <CalloutBox variant="do" title="Decision signals">
      <p><strong>Resume:</strong> context still valid.</p>
      <p><strong>Fork:</strong> divergent branches from a shared baseline.</p>
      <p><strong>Start fresh:</strong> stale results OR context-window pressure → inject a structured summary.</p>
      <p><strong>/compact:</strong> context large but still valid — reduce without discarding.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Domain 1 · Session strategy" :num="7" :total="8" />
</Frame>

<!--
The exam-tested traps in this area. Trap one: resuming a session whose tool results reference live data that has since changed. This is worse than it sounds — Claude doesn't know the data is stale, so it reasons confidently on wrong context. That produces incorrect outputs, not just inefficient ones. Trap two: using fork_session when what you actually need is a restart. Fork preserves history; if that history is the problem, forking just duplicates it. Trap three: starting fresh without injecting a summary — the new session has zero knowledge of prior findings, so anything you learned is gone. The decision signals: resume when context is still valid; fork for divergent branches from a shared baseline; start fresh with an injected summary when results are stale or the window is under pressure; use /compact when the context is large but still valid.
-->

---

<BulletReveal
  eyebrow="Takeaways"
  title="Session Management — What to Remember"
  :bullets="takeaways"
  :footerNum="8"
  :footerTotal="8"
/>

<!--
Six takeaways. One — resume when context is still valid: interrupted tasks, stable multi-phase work. Two — fork when you need divergent branches from a shared baseline: A/B evaluation, hypothesis testing. Three — start fresh with an injected summary when tool results are stale or the context window is under pressure. Four — stale tool results cause INCORRECT reasoning, not just inefficiency; always start fresh and inject a summary in that case. Five — /compact reduces context size in-session when the history is still accurate. And six — the injected summary carries conclusions and validated facts; it never carries raw tool output. Lecture 3.14 closes this section with the final decision in the agentic loop: when you have to escalate to a human, how do you hand off structured context so the human isn't starting from scratch?
-->
