# Promo Video Script — Claude Certified Architect Foundations

Target runtime: **2:00–2:30**. Udemy promo video.

## Logline

This course preps you for the Anthropic Claude Certified Architect exam with scenario-based labs, a full-length practice exam, and the architectural patterns the test actually asks about — taught by someone who ships agentic systems for a living.

## Beat sheet

| Timecode | Beat | Purpose |
|---|---|---|
| 0:00–0:10 | **HOOK** — the exam problem | Frame the stakes: 720/1000 to pass, 4 of 6 scenarios shown at random, Domain 1 = 27% weight, no penalty for guessing but no room to coast. |
| 0:10–0:30 | **WHAT THIS COURSE IS** | 5 domains covered end-to-end, 40-question practice exam modeled on the official guide, 6 scenario labs, ~18.5 hours total. |
| 0:30–1:00 | **WHY THIS APPROACH** | Scenario-based. Practitioner-to-practitioner. Labs + domain quizzes + cheat sheets. Not a slide-reading course. |
| 1:00–1:45 | **A PEEK** | Walk through one concrete pattern on screen: the agentic loop driven by `stop_reason`, and why `"tool_use"` vs `"end_turn"` is the control flow — not text parsing, not an iteration cap. |
| 1:45–2:10 | **WHO IT'S FOR** | Solution architects and senior engineers building with Claude. Prereq: you've called the API at least once. |
| 2:10–2:25 | **CLOSE** | Soft CTA: enroll to prep for the exam. Logo frame. |

## Voiceover script (full)

**[0:00–0:10 — HOOK]**
The Anthropic Claude Certified Architect exam has a passing score of seven-twenty out of a thousand. You get four of six scenarios, chosen at random. Domain One alone is twenty-seven percent of your grade. There's no penalty for guessing — but there's no room to coast either.

**[0:10–0:30 — WHAT THIS COURSE IS]**
This course covers all five domains from the official exam guide. Six scenario labs. A forty-question practice exam modeled on the real thing. About eighteen and a half hours of instruction, built to match the weightings on the test.

**[0:30–1:00 — WHY THIS APPROACH]**
The exam doesn't test trivia. It tests judgment on scenarios — a support agent that skips a verification step, a research pipeline that fails on one subagent, a code review that drifts across files. So that's how this course is built. Labs you actually run. Quizzes per domain. Cheat sheets for the patterns you need cold.

**[1:00–1:45 — A PEEK]**
Here's one. The agentic loop is driven by `stop_reason`. If it's `tool_use`, you execute the tool, append the result, and loop. If it's `end_turn`, you stop. That's it. Parsing Claude's text to decide when to stop, or capping iterations as your primary exit — those are the wrong answers on the exam, and they're wrong in production too. The course walks through patterns like this for every domain, with working code.

**[1:45–2:10 — WHO IT'S FOR]**
This is for solution architects and senior engineers building production applications with Claude. You've called the API. You've read the docs. You want the patterns that hold up under scrutiny, and you want to pass the exam on the first attempt.

**[2:10–2:25 — CLOSE]**
Enroll when you're ready. I'll see you in the first lecture.

## Shot list / on-screen text

**[0:00–0:10 — HOOK]**
- Shot 1: instructor on camera, neutral background, direct address.
- Lower-third: `Jonathan Dyer — Dyer Innovation`
- On-screen text cards cut in sync with VO:
  - `Passing score: 720 / 1000`
  - `4 of 6 scenarios — at random`
  - `Domain 1 = 27%`

**[0:10–0:30 — WHAT THIS COURSE IS]**
- Shot: animated course outline — five domain bars sized to their weights (27 / 18 / 20 / 20 / 15).
- On-screen text: `5 Domains • 6 Scenario Labs • 40-Q Practice Exam • ~18.5 hrs`

**[0:30–1:00 — WHY THIS APPROACH]**
- Shot: screen recording of lab directories opening — `labs/customer-support-agent/`, `labs/ci-code-review/`, `labs/research-pipeline/`.
- Cut back to instructor on camera mid-beat.
- On-screen text: `Scenario-based. Not slide-based.`

**[1:00–1:45 — A PEEK]**
- Shot: code editor, clean dark theme, showing the agentic loop pseudocode:
  ```
  while True:
      resp = claude.messages.create(...)
      if resp.stop_reason == "tool_use":
          run_tool(resp); continue
      if resp.stop_reason == "end_turn":
          break
  ```
- Animated arrow overlay highlighting `stop_reason` branches.
- On-screen text: `stop_reason drives the loop — not text parsing, not iteration caps`

**[1:45–2:10 — WHO IT'S FOR]**
- Shot: instructor on camera.
- On-screen text cards:
  - `Solution Architects`
  - `Senior Engineers building with Claude`
  - `Prereq: you've called the Messages API`

**[2:10–2:25 — CLOSE]**
- Shot: course-logo frame, full bleed.
- On-screen text: `Claude Certified Architect — Foundations`
- Sub-line: `Enroll now on Udemy`
- Wordmark, bottom-right: `Dyer Innovation`

## Closing frame

`Claude Certified Architect — Foundations  ·  Enroll now on Udemy  ·  Dyer Innovation`
