---
theme: default
title: "Lecture 3.13: Session Management: resume, fork_session, When to Start Fresh"
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
  <div class="di-cover-title">Session Management:<br><span style="color: #3CAF50;">resume</span>, <span style="color: #A8D5C2;">fork_session</span>,<br>When to Start Fresh</div>
  <div class="di-cover-subtitle">Lecture 3.13 · Domain 1 — Agentic Architecture & Orchestration (27%)</div>
</div>

<img src="/logo.png" class="di-logo-centered" />

<!--
An agentic session represents a conversation history — the accumulated context of everything Claude has seen and done.

Managing that session correctly is the difference between a system that builds on prior work efficiently and one that either wastes tokens on stale context or loses valuable context by starting over unnecessarily.

This lecture covers the three session management decisions you'll face: when to resume a session, when to fork it into divergent paths, and when the right move is to start fresh with an injected summary.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 2 — The Three Session Management Decisions
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">The Three Session Management Decisions</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Every time an agentic task is interrupted, completes a phase, or needs to explore multiple paths, you face one of three decisions:</p>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.55rem; margin-top: 0.6rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Resume (<code>--resume</code>)</span> Continue from exactly where the session left off. The full conversation history — all prior tool calls, results, and reasoning — is available to Claude.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">Fork (<code>fork_session</code>)</span> Duplicate the current session context and start two independent branches from the same baseline. Use to explore divergent approaches without contaminating either branch with the other's results.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">Start Fresh</span> Create a new session with no prior history. Inject a structured summary of what was learned in the prior session. Use when the prior session's raw context is stale or too expensive to carry forward.
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
There are three decisions you'll face when managing agentic sessions.

[click] Resume: continue from exactly where you left off. The full conversation history is intact — all prior tool calls, results, and reasoning are available to Claude. Use when the context is still valid and relevant.

[click] Fork: duplicate the current session and start two independent branches from the same baseline. Use when you need to explore divergent approaches — different algorithms, different strategies, different hypotheses — and you don't want the results of one branch to influence the other.

[click] Start fresh: create a new session with no prior history, but inject a structured summary of what was learned. Use when the prior session's raw context has gone stale — tool results that reference data that has since changed — or when carrying the full history forward would waste context window and tokens.

Each of these is the right choice in a specific scenario. The exam tests whether you can match the scenario to the right decision.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 3 — When to Resume
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">When to Resume a Session</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p><code class="di-code-inline">--resume</code> is the right choice when the prior session's context is <strong>still valid, relevant, and worth carrying forward</strong>.</p>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.45rem; margin-top: 0.6rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Interrupted task</span> The session was cut off mid-execution — network failure, timeout, or graceful pause for human review. Context is still accurate. Resume.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">Multi-phase work</span> Phase 1 completed and the results are stable. Phase 2 builds directly on Phase 1 output. Resume and continue — no need to re-establish context.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">Tool result reuse</span> Claude has already retrieved and processed data that is still current. Resuming avoids redundant tool calls — saving latency and cost.
  </div>
  </v-click>

  <v-click>
  <div style="background: #FFF0F0; border-left: 3px solid #E53E3E; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.25rem;">
    <strong>Do NOT resume when:</strong> tool results reference live data that has changed since the session ran. Claude will reason against stale context — this causes incorrect decisions, not just suboptimal ones.
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Resume is appropriate when the prior session's context is still valid and worth carrying forward.

[click] If a task was interrupted — by a network failure, a timeout, or a deliberate human review pause — the context is accurate. Resume from where you left off.

[click] If phase one of a multi-phase task completed and the results are stable, resuming for phase two avoids re-establishing all of that context.

[click] If Claude already retrieved data that is still current, resuming avoids redundant tool calls — saving both latency and cost.

[click] The key "do not resume" condition: if the session contains tool results that referenced live data that has since changed. A tool call from yesterday that fetched a customer's account balance is stale. If you resume, Claude may reason about that balance as if it's current. That's not just inefficient — it's incorrect. In that scenario, start fresh with an injected summary.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 4 — When to Fork a Session
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">When to Fork a Session</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p><code class="di-code-inline">fork_session</code> duplicates the current session state and creates two independent branches. Both branches start from the same baseline but evolve independently.</p>
</v-click>

<v-click>
<div style="display: flex; align-items: center; gap: 1rem; margin-top: 0.6rem;">
  <div style="flex: 1; background: white; border: 1px solid #c8e6d0; border-radius: 6px; padding: 0.6rem 0.8rem; font-size: 0.88rem;">
    <div style="font-weight: 700; color: #1B8A5A; margin-bottom: 0.25rem;">Shared baseline</div>
    Same research findings, same document context, same task history
  </div>
  <div style="font-size: 1.5rem; color: #0D7377;">→</div>
  <div style="flex: 1.8; display: flex; flex-direction: column; gap: 0.4rem;">
    <div style="background: #E8F5EB; border-left: 3px solid #3CAF50; border-radius: 4px; padding: 0.45rem 0.7rem; font-size: 0.88rem;"><strong>Branch A:</strong> Draft with approach 1</div>
    <div style="background: #E8F5EB; border-left: 3px solid #0D7377; border-radius: 4px; padding: 0.45rem 0.7rem; font-size: 0.88rem;"><strong>Branch B:</strong> Draft with approach 2</div>
  </div>
</div>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.45rem; margin-top: 0.6rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">A/B evaluation</span> Generate two candidate outputs from the same context — for human review or automated scoring. Fork prevents cross-contamination between branches.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">Hypothesis testing</span> Explore two distinct investigative paths from the same starting evidence. If one branch reaches a dead end, the other is unaffected.
  </div>
  </v-click>

  <v-click>
  <div style="background: #FFF8E6; border-left: 3px solid #E3A008; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.25rem;">
    <strong>Key property:</strong> forking is cheaper than running two fully independent sessions from scratch — the shared baseline context is not re-established twice.
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Fork creates two independent branches from a shared baseline.

[click] Both branches start with the same conversation history — the same research findings, the same document context, the same prior reasoning. But from the fork point forward, each branch evolves independently. What Branch A does does not appear in Branch B's context.

[click] The primary use case is A/B evaluation: generate two candidate outputs from the same starting context and then compare them — either by a human reviewer or an automated scoring pass.

[click] The second use case is hypothesis testing in investigation tasks. You have evidence pointing in two directions. Fork and pursue both. If one branch reaches a dead end, the other is unaffected.

[click] The efficiency advantage: forking is cheaper than running two independent sessions from scratch. The shared baseline doesn't need to be re-established twice. The cost savings scale with how much shared context exists before the fork point.
-->

---
layout: default
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 5 — When to Start Fresh
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-header">When to Start Fresh with an Injected Summary</div>

<div class="di-body" style="margin-top: 0.75rem;">

<v-click>
<p>Sometimes the prior session's raw context is a liability, not an asset. Starting fresh — with a structured summary injected into the new session — is the right move.</p>
</v-click>

<div style="display: flex; flex-direction: column; gap: 0.45rem; margin-top: 0.6rem;">

  <v-click>
  <div class="di-step-card">
    <span class="di-step-num">Stale tool results</span> The session contains tool outputs that referenced live data which has since changed. Carrying them forward causes incorrect reasoning. Summarize what was <em>learned</em> (conclusions), discard the raw results.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #0D7377;">
    <span class="di-step-num" style="color: #0D7377;">Context window pressure</span> The session history is large and approaching limits. Use <code class="di-code-inline">/compact</code> for in-session reduction, or start fresh with a synthesized summary for a clean slate.
  </div>
  </v-click>

  <v-click>
  <div class="di-step-card" style="border-left-color: #E3A008;">
    <span class="di-step-num" style="color: #E3A008;">Phase boundary with different tools</span> Phase 2 requires a different tool set and a different system prompt. Rather than continuing in the same session, start fresh and inject the phase 1 conclusions as structured input.
  </div>
  </v-click>

  <v-click>
  <div style="background: #E8F5EB; border-left: 3px solid #3CAF50; padding: 0.5rem 0.8rem; border-radius: 4px; font-size: 0.88rem; margin-top: 0.25rem;">
    <strong>The injected summary pattern:</strong> extract only the <em>conclusions and validated facts</em> from the prior session — not the raw tool outputs. The new session starts clean, with accurate structured context.
  </div>
  </v-click>

</div>

</div>

<img src="/logo.png" class="di-logo" />

<!--
Starting fresh is the right move when the prior session's raw context is a liability.

[click] The primary trigger: stale tool results. If the session contains tool outputs that referenced live data — account balances, inventory levels, API responses — and that data has since changed, carrying those results forward causes Claude to reason on incorrect information. The fix: extract what was learned (the conclusions, the validated facts) and discard the raw results. Start a new session and inject the summary.

[click] Context window pressure is another trigger. When a session history grows large, you can use the /compact command for in-session reduction. But for a true clean slate, starting fresh with a synthesized summary is cleaner and more predictable.

[click] Phase boundaries with different tool sets: if Phase 2 of a workflow needs a fundamentally different system prompt and tool configuration, it's cleaner to start a new session than to continue in the old one. Inject the Phase 1 conclusions as structured input.

[click] The key principle: the injected summary carries conclusions and validated facts — not raw tool outputs. It's a synthesis, not a history dump.
-->

---
layout: default
class: di-code-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 6 — The Injected Summary Pattern
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-code-header">The Fresh Start + Injected Summary Pattern</div>

<v-click>

```python {all|3-15|18-30|all}
# Step 1: Extract conclusions from the prior session
def build_session_summary(prior_session_messages: list) -> str:
    """Ask Claude to synthesize what was learned — not replay raw history."""
    summary_response = client.messages.create(
        model="claude-opus-4-7",
        messages=[
            *prior_session_messages,
            {"role": "user", "content":
                "Summarize: (1) what we established as fact, "
                "(2) what tools retrieved and their validated conclusions, "
                "(3) open questions that remain, "
                "(4) recommended next steps. "
                "Do NOT include raw tool output — only validated findings."}
        ]
    )
    return summary_response.content[0].text


# Step 2: Start a fresh session with the summary injected
def start_fresh_with_summary(summary: str, next_task: str) -> list:
    """New session — clean context, no stale tool results."""
    return client.messages.create(
        model="claude-opus-4-7",
        system="You are a research analyst continuing a prior investigation.",
        messages=[
            {"role": "user", "content":
                f"PRIOR INVESTIGATION SUMMARY:\n{summary}\n\n"
                f"CURRENT TASK:\n{next_task}"}
        ]
    )
```

</v-click>

<v-click>
<div style="background: white; padding: 0.4rem 0.75rem; border-radius: 4px; border-left: 2px solid #3CAF50; font-size: 0.82rem; margin-top: 0.4rem;">
  <strong style="color: #1B8A5A;">Result:</strong> the new session has accurate, current context — without any stale tool results from the prior session. The summary carries conclusions, not raw history.
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
Here's the fresh start with injected summary pattern in code.

Step one: extract conclusions from the prior session. Ask Claude to synthesize what was actually learned — validated facts, tool result conclusions, open questions, and next steps. Critically: instruct it not to include raw tool outputs, only validated findings.

[click] Step two: start a new session and inject that summary as structured input. The system prompt gives the new Claude instance its role. The first user message contains both the prior investigation summary and the current task.

[click] The result: the new session starts with accurate, current context. No stale tool results. No outdated API responses. Claude reasons on what was concluded — not on raw historical data that may no longer be true.

This pattern is the correct response to stale context. Summary in, history out.
-->

---
layout: default
class: di-exam-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 7 — Exam Tip
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-exam-banner">⚡ EXAM TIP</div>

<v-click>
<div class="di-exam-subtitle">Matching the Scenario to the Session Strategy</div>

<div class="di-exam-body">
  The exam will describe a session state and ask which management action is appropriate. Look for these signals in the scenario.
</div>
</v-click>

<v-click>
<div class="di-trap-box">
  <div class="di-trap-label">❌ Traps to Watch For</div>
  <ul style="margin: 0; padding-left: 1.2rem; font-size: 0.9rem;">
    <li>Resuming a session whose tool results reference live data that has since changed — this causes incorrect reasoning</li>
    <li>Using <code>fork_session</code> when you just need to restart — a fork preserves history; it doesn't clean it</li>
    <li>Starting fresh without injecting context — the new session has no knowledge of prior findings</li>
  </ul>
</div>
</v-click>

<v-click>
<div class="di-correct-box">
  <div class="di-correct-label">✓ The Decision Signals</div>
  <strong>Resume:</strong> context is still valid and accurate<br>
  <strong>Fork:</strong> need divergent branches from a shared baseline<br>
  <strong>Start fresh:</strong> stale tool results OR context window pressure → inject a structured summary of conclusions<br>
  <strong>/compact:</strong> context is getting large but still valid — reduce without discarding
</div>
</v-click>

<img src="/logo.png" class="di-logo" />

<!--
The exam will give you a session state description and ask what to do.

[click] Three traps to watch for.

Trap one: resuming a session with stale tool results. If the scenario mentions that the prior session ran yesterday and involves live data — account balances, inventory, pricing — resuming is wrong. Start fresh with an injected summary.

Trap two: using fork_session when you need a clean restart. Fork creates two branches from the current history. It doesn't clean the history. If the goal is to escape stale context, fork doesn't help.

Trap three: starting fresh without injecting context. The new session has no knowledge of what was found previously. Always inject a structured summary of conclusions.

[click] The decision signals: resume when context is valid. Fork when you need divergent branches from a shared baseline. Start fresh when tool results are stale or context window pressure is severe — and always inject a summary. Use /compact for in-session context reduction when history is large but still accurate.
-->

---
layout: default
class: di-takeaway-slide
---

<!-- ═══════════════════════════════════════════════════════════════════════════
     SLIDE 8 — Key Takeaways
     ═════════════════════════════════════════════════════════════════════════ -->

<div class="di-takeaway-title">Session Management — What to Remember</div>

<ul class="di-takeaway-list">
  <v-click><li><strong>Resume (<code style="color: #A8D5C2;">--resume</code>)</strong> when context is still valid — interrupted tasks, multi-phase work with stable prior results</li></v-click>
  <v-click><li><strong>Fork (<code style="color: #A8D5C2;">fork_session</code>)</strong> when you need divergent branches from a shared baseline — A/B evaluation, hypothesis testing</li></v-click>
  <v-click><li><strong>Start fresh</strong> when tool results are stale or context window is under pressure — always inject a structured summary of conclusions</li></v-click>
  <v-click><li>Stale tool results cause <em>incorrect</em> reasoning — not just inefficiency. Start fresh + inject summary.</li></v-click>
  <v-click><li><strong><code style="color: #A8D5C2;">/compact</code></strong> reduces context size in-session when history is large but still accurate</li></v-click>
  <v-click><li>The injected summary carries conclusions and validated facts — never raw tool output</li></v-click>
</ul>

<img src="/logo.png" class="di-logo" style="opacity: 0.75;" />

<!--
What to remember cold from this lecture:

Resume when context is still valid — interrupted tasks, stable multi-phase work.

Fork when you need divergent branches from a shared baseline — A/B drafting, hypothesis testing.

Start fresh when tool results are stale — always inject a structured summary of conclusions, not raw history.

Critical distinction: stale tool results cause incorrect reasoning, not just inefficiency. This is why resuming a session with stale data is dangerous.

Use /compact to reduce context size in-session when history is large but still accurate.

The injected summary carries conclusions and validated facts. Never dump raw tool output into the new session — it defeats the purpose of starting fresh.
-->
