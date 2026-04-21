---
theme: default
title: "Lecture 4.7: Local Recovery vs Propagating to Coordinator"
info: |
  Claude Certified Architect – Foundations
  Section 4 — Tool Design & MCP Integration (Domain 2, 18%)
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
const local_recovery_code = `# Inside the search subagent
for attempt in range(3):
    try:
        result = web_search(query)
        return result  # Success — coordinator never knew
    except TransientError as e:
        time.sleep(2 ** attempt)  # exponential backoff

# Exhausted retries — compose structured error for coordinator
return propagate_to_coordinator(
    failure_type="transient",
    attempted_query=query,
    partial_results=results_so_far,
    alternatives=["narrow the topic", "try different sources"],
)`

const propagation_code = `{
  "isError": true,
  "failure_type": "transient_timeout",
  "attempted_query": "effects of sleep deprivation on cognitive performance",
  "partial_results": [
    {"title": "Sleep and Memory Consolidation", "url": "..."},
    {"title": "Attention and Sleep Debt",    "url": "..."},
    {"title": "Decision-Making under Sleep Loss", "url": "..."}
  ],
  "alternatives": [
    "Narrow to 'short-term sleep deprivation'",
    "Try alternative source set: PubMed only"
  ]
}`

const antipattern_bad = `Propagate everything: coordinator context fills with noise, makes worse decisions.

Swallow everything: local try-catch, return empty, pretend success. Coordinator synthesizes a report with missing sections.`

const antipattern_fix = `Heal transient + validation locally.
Propagate structured business + permission with partial results.
The middle path is the only one that works.`
</script>

<div class="di-cover">
  <div class="di-cover__inner">
    <div class="di-cover__eyebrow">Domain 2 · Lecture 4.7</div>
    <h1 class="di-cover__title">Local Recovery vs<br/><span class="di-cover__accent">Propagating to Coordinator</span></h1>
    <div class="di-cover__subtitle">One rule. Partial results always travel with the error.</div>
  </div>
</div>

<style scoped>
.di-cover { position: absolute; inset: 0; background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%); color: var(--mint-100); }
.di-cover__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-cover__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px; }
.di-cover__title { font-family: var(--font-display); font-weight: 500; font-size: 104px; line-height: 1.05; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1600px; }
.di-cover__accent { color: var(--sprout-500); }
.di-cover__subtitle { font-family: var(--font-display); font-size: 40px; color: var(--mint-200); margin-top: 40px; font-weight: 400; }
</style>

<!--
Something broke in a subagent. Should the subagent handle it, or kick it up? That's the whole question of this lecture. Seven minutes. One decision rule. And the exam's favorite example — the web-search timeout from Scenario 3.
-->

---

<BigQuote quote="Should this subagent handle it, or kick it up?" />

<!--
"Should this subagent handle it, or kick it up?" Every error in a multi-agent system forces that decision. Get it right and you get fast, cheap recovery. Get it wrong in either direction and you either blow up the coordinator's context with every transient blip, or you swallow real failures that the coordinator needed to see.
-->

---

<ConceptHero
  leadLine="Default: heal where you can."
  concept="Subagents recover transient + validation locally."
  supportLine="Business + permission always propagate — the coordinator decides."
/>

<!--
Here's the rule. Default: heal where you can. Subagents recover transient and validation errors locally. Business and permission errors always propagate — the coordinator decides. That's the cut line. Map it back to the four categories from 4.6 and the rule falls out naturally. Transient and validation are things a subagent can retry or reformat without coordinator approval — they're mechanical recoveries. Business and permission are decisions above the subagent's pay grade — policy calls, auth decisions. The coordinator needs to see those to pick the next move.
-->

---

<CodeBlockSlide
  title="Retry with backoff inside the subagent"
  lang="python"
  :code="local_recovery_code"
  annotation="Transient blips absorbed locally. Sustained failures propagate with structured context."
/>

<!--
Here's what local recovery looks like inside a subagent. Pseudocode. You wrap the tool call in a retry loop with exponential backoff. Three attempts, doubling delay, cap at thirty seconds. On success, return the result — the coordinator never knew anything happened. On exhausted retries, you stop retrying and you start composing a structured error. Because now the coordinator does need to know. Local recovery isn't hiding the failure — it's absorbing the noise. Transient blips shouldn't reach the coordinator. Sustained failures absolutely should. That's the line.
-->

---

<CodeBlockSlide
  title="Structured error → coordinator"
  lang="json"
  :code="propagation_code"
  annotation="Four fields: failure_type, attempted_query, partial_results, alternatives. Sample Q8's correct answer, word-for-word."
/>

<!--
Here's the propagation pattern. Structured JSON going back to the coordinator. Four things in it. Failure type — what category of error, mapped to the categories from 4.6. Attempted query — what the subagent actually tried, so the coordinator knows what to retry differently. Partial results — whatever came back before the failure, because even partial data can feed downstream. And alternatives — suggested next moves the subagent can see from its position, like "consider narrowing the topic" or "try a different source set." That shape is the exact correct answer to Sample Question 8 from the exam guide. Memorize those four elements: failure type, attempted query, partial results, alternatives.
-->

---

<CalloutBox variant="tip" title="Always include what you got">

Even on failure, send the coordinator the partial data. If web-search found three articles before the fourth query timed out, those three go with the error. Difference between <em>"search unavailable"</em> — useless — and <em>actionable recovery context</em>.

</CalloutBox>

<!--
One thing worth its own slide — always include the partial results. Even on failure, send the coordinator what you managed to retrieve. If the web-search subagent found three articles before the fourth query timed out, those three articles go to the coordinator with the error. That's the difference between a generic "search unavailable" — useless — and actionable recovery context — "here's what I got, here's what I missed, here's why, here's what you could try instead." The coordinator can use that. It can re-invoke a narrowed search. It can proceed with partial findings if they're enough. It can decide this topic is too thin and escalate to the user. It can't do any of that on "search unavailable."
-->

---

<AntiPatternSlide
  title="Two ways to get this wrong"
  :badExample="antipattern_bad"
  whyItFails="Both ends of the spectrum fail for different reasons."
  :fixExample="antipattern_fix"
  lang="text"
/>

<!--
Two ways to get this wrong. On the left — propagate everything. Every transient blip, every 503, every brief timeout goes up to the coordinator. The coordinator's context fills with noise. It makes worse decisions because its window is full of noise. On the right — swallow everything. Local try-catch, return empty, pretend success. The coordinator never learns the search failed. It synthesizes a report with missing sections. Both are failures. The middle path — heal transient locally, propagate structured business and permission with partials — is the only one that works.
-->

---

<CalloutBox variant="tip" title="Sample Q8 echo">

Web-search subagent times out on a complex topic. Correct answer A:
<br/><br/>
<strong>"Return structured error context to the coordinator including the failure type, the attempted query, any partial results, and potential alternative approaches."</strong>
<br/><br/>
Distractors: generic "search unavailable", empty result marked as success, propagate-and-terminate. Each is one of the anti-patterns.

</CalloutBox>

<!--
Sample Question 8 from the exam guide. The web search subagent times out on a complex topic. The correct answer — A — is "return structured error context to the coordinator including the failure type, the attempted query, any partial results, and potential alternative approaches." That's the propagation pattern from slide 5, word for word. The distractors: generic "search unavailable," empty result marked as success, propagate to a top-level handler and terminate. Each distractor is one of the anti-patterns we just named. Scenario 3 relies on this exact pattern.
-->

---

<div class="di-close">
  <div class="di-close__inner">
    <div class="di-close__eyebrow">Next up</div>
    <h1 class="di-close__title">4.8 — <span class="di-close__accent">How Many Tools Per Agent?</span></h1>
    <div class="di-close__subtitle">Four to five. Eighteen breaks things.</div>
  </div>
</div>

<style scoped>
.di-close { position: absolute; inset: 0; background: var(--mint-100); color: var(--forest-800); }
.di-close__inner { padding: 110px 120px 96px; height: 100%; display: flex; flex-direction: column; justify-content: center; }
.di-close__eyebrow { font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase; color: var(--teal-500); margin-bottom: 36px; }
.di-close__title { font-family: var(--font-display); font-weight: 500; font-size: 96px; line-height: 1.05; letter-spacing: -0.02em; color: var(--forest-900); margin: 0; max-width: 1600px; }
.di-close__accent { color: var(--sprout-600); }
.di-close__subtitle { font-family: var(--font-display); font-size: 38px; color: var(--forest-500); margin-top: 32px; font-weight: 400; }
</style>

<!--
Next up, Lecture 4.8 — how many tools per agent. Four to five. Eighteen breaks things. See you there.
-->
