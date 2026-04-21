---
theme: default
title: "Section 1: Course Introduction & Exam Strategy"
info: |
  Claude Certified Architect - Foundations
  Combined Section 1 deck (covers original 1.1-1.6)
canvasWidth: 1920
aspectRatio: 16/9
highlighter: shiki
transition: slide-left
mdc: true
---

<style>
@import './design-system.css';
</style>

<CoverSlide />

<!--
Welcome. If you're here, you're preparing for one of the most sought after AI certifications out there right now - The Claude Certified Architect Foundations Exam from Anthropic.
Working at a Anthropic Partner enabled me to take the exam early, pass and earn the Claude Early Adopter exam.
I created this course to be a one stop shop for preparing for the exam.
In this lecture, we'll walk you through the course & exam structure and how best to use this course based on your experience.
-->

---

<InstructorSlide />

<!--
But before we get started, let me introduce myself. I'm Jonathan Dyer -- a Senior AI Engineer working at an Anthropic Partner firm, where I architect and ship production Generative AI systems for enterprise clients across High Tech Supply Chains, Life Sciences and Creative Industries.
I hold several industry certifications, across AI/ML and the cloud so I've had my fair share of taking courses like these.
And my main mission here it to "Teach it Right" which means that hopefully not only do you pass the exam but also learn something you might not have otherwise.
-->

---

<AgendaSlide />

<!--
This first lecture is really six short lectures rolled together. It's the groundwork before we open Domain 1. We'll cover what this course is and who it's for. The exam format -- scoring, timing, the scenario rule. The five domains and their weights. The six scenarios and why they matter. Two concrete study plans depending on how much time you have. And finally, how to read the official Anthropic exam guide like a study blueprint rather than a reference document. Every piece here pays off later, so stick with me.
-->

---

<SectionBreak part="01" title="Welcome." blurb="What this course is, who it's for, and the lens you should wear into every domain." />

<!--
Let's start at the beginning -- a proper welcome, and the lens I want you wearing for the rest of this course.
-->

---

<BigQuote lead="Welcome · 01" quote="This exam tests <em>judgment</em> -- not memorisation, not syntax recall." attribution="The single most important thing to understand before you begin" />

<!--
Here's the single most important thing I can tell you before you open a single domain: this exam tests judgment. Not trivia. Not API parameter recall. Every question gives you a scenario and asks you to pick the best architectural decision. The wrong answers aren't obviously wrong -- they'd be correct in a different context. So your study goal isn't to memorize syntax. It's to understand the principles well enough to apply them to scenarios you've never seen before. Hold onto that.
-->

---

<WhoForSlide />

<!--
Quick check on fit, straight from Anthropic's official target-candidate description. This certification is aimed at solution architects who design and implement production applications with Claude -- not beginners, not theorists. The expected baseline is about six months of hands-on experience across four specific surfaces: the Claude Agent SDK, Claude Code, the Claude API, and Model Context Protocol. On the good-fit side: you've built agentic applications with subagent delegation, tool integration and lifecycle hooks. You've configured Claude Code for a team using CLAUDE.md, Skills, MCP server integrations and plan mode. You've designed MCP tool and resource interfaces and engineered prompts for structured output. If that sounds like the work you do, you are exactly who this exam and this course were built for. On the not-yet side: if you've never made an LLM API call, start with Anthropic's quickstart first -- come back once you've shipped something small. If you're hoping for ML theory, training internals or model architecture, that's explicitly out of scope for this exam. And if you have zero exposure to Claude Code, the Agent SDK or MCP, don't force it -- go build a small project using those surfaces, then return. This exam rewards judgment, and judgment only comes from reps.
-->

---

<OutcomesSlide />

<!--
Here's what you'll walk away with. You'll understand exactly how Claude's agentic loop works and precisely what breaks it. You'll be able to design tool interfaces that Claude reliably selects -- and write error responses that help the agent recover instead of getting stuck. You'll know how to configure Claude Code for a real team, not just solo use. And by the end, you'll have analyzed every one of the twelve official sample questions, including every distractor and why it fails. That last one is probably the single highest-ROI thing you'll do in this course.
-->

---

<SectionBreak part="02" title="Exam format." blurb="Scoring, question style, the six-pick-four scenario rule, and how to spend your time." />

<!--
Okay -- now the mechanics. Let's talk about what this exam actually looks like from the inside.
-->

---

<BigNumber eyebrow="Exam format · 02" number="720" unit=" / 1000" caption="The passing score. Scaled, not raw." detail="Roughly 72% -- rigorous, but reliably hittable with the right preparation. Aim above it, not at it." accent="var(--sprout-500)" />

<!--
Seven hundred and twenty. That's the number. Scaled scoring from 100 to 1000, and you need 720 to pass. That's roughly seventy-two percent, which is a rigorous threshold -- but one you can hit reliably with the right preparation. The 720 is not a raw correct count; it's an adjusted score, which is why I'm going to keep pushing you to understand concepts rather than scrape past the line.
-->

---

<ScoringBar />

<!--
Here's what scaled scoring actually looks like. Below 720 is a fail, full stop -- 719 is the same as 500. 720 to 800 is a comfortable pass, and that's where I want you aiming. 800 to 900 is a strong pass, meaning you have real command across all five domains. And above 900, honestly, you could teach this course. Don't aim for the cliff edge. Aim for comfortable -- because on exam day, one tough scenario can eat ten points fast, and you want room.
-->

---

<SixPickFour variant="neutral" />

<!--
Here's the content map. Every question on the exam is tied to one of six scenarios. Scenario 1 -- Customer Support Resolution Agent. Scenario 2 -- Code Generation with Claude Code. Scenario 3 -- Multi-Agent Research System. Scenario 4 -- Developer Productivity. Scenario 5 -- Claude Code for CI/CD. Scenario 6 -- Structured Data Extraction. You'll see them again in Part 4 of this lecture. For now, just know: these six are the vocabulary of the exam.
-->

---

<SixPickFour variant="picked" />

<!--
Here's the structural quirk that catches people off guard. The exam presents six scenarios, but you only answer questions from four of them. And -- critically -- you don't pick which four. Anthropic does. So the mental move is: prepare for all six, equally well enough that whichever four show up, you're ready. Don't walk in hoping your two weak scenarios won't appear. They will.
-->

---

<NoPenalty />

<!--
Two critical facts about scoring. First: there is no penalty for wrong answers. Wrong and blank both score zero. That means the only correct move on a question you're unsure about is to answer it anyway -- never leave anything blank. Even a blind guess is strictly better than leaving the field empty, because one-in-four beats zero. Build this into your habits now: on exam day, your final sweep is to confirm every single question has an answer.
-->

---

<SectionBreak part="03" title="Five domains." blurb="What each domain tests, and why the weights should shape your study plan -- not the other way around." />

<!--
Now we get into the content structure itself -- the five domains. This is the map of what you're actually being tested on.
-->

---

<DomainWeights />

<!--
Here are the five domains, ordered by weight. Domain 1 -- Agentic Architecture and Orchestration -- is twenty-seven percent of the exam, by far the biggest lever. Domains 3 and 4 -- Claude Code Configuration and Prompt Engineering -- are tied at twenty percent each. Domain 2 -- Tool Design and MCP -- is eighteen percent. And Domain 5 -- Context Management and Reliability -- is fifteen percent. These weights are not even. Your study time shouldn't be either. If you have five days, spend a full day on Domain 1. Don't split evenly.
-->

---

<script setup>
const d1Topics = [
  'The agentic control loop',
  'Subagent coordination & task decomposition',
  'Session management & state across turns',
  'Escalation to humans -- when and how',
]
</script>

<DomainFocus
  number="1"
  name="Agentic Architecture & Orchestration"
  pct="27"
  color="var(--sprout-500)"
  :topics="d1Topics"
  keyPoint="Everything in Domain 1 flows from <code>stop_reason</code>. Get <code>tool_use</code> vs <code>end_turn</code> wrong and the agent terminates early -- or loops forever."
  scenarios="Scenarios 1 & 3 -- could represent half your exam"
/>

<!--
Domain 1 is where the exam lives. Twenty-seven percent. It covers the control loop, subagent coordination, task decomposition, session management, and escalation. The concept that anchors this entire domain is stop_reason. Everything flows from understanding that tool_use means the loop continues and end_turn means it stops. Get this wrong and your agent either terminates prematurely or loops forever. If you have limited study time, start here. Scenarios 1 and 3 both lean hard on Domain 1, and between them they could represent half your exam.
-->

---

<script setup>
const d34Topics = [
  'Domain 3: CLAUDE.md hierarchy, .claude/ directory, skills, rules, commands, CI/CD, plan mode',
  'Domain 4: few-shot examples, structured output, tool_choice, Message Batches API, validation-retry, multi-instance review',
  'Together: 40% of your exam -- as big as Domain 1 on its own',
  'Both reward hands-on experience over theory',
]
</script>

<DomainFocus
  number="3 & 4"
  name="Claude Code Config + Prompt Engineering"
  pct="20+20"
  color="var(--teal-500)"
  :topics="d34Topics"
  keyPoint="If you have shipped real Claude Code workflows or prompt pipelines, much of this will feel like review. If not -- this is where to put your second-biggest study block."
  scenarios="Scenarios 2, 5, 6"
/>

<!--
Domains 3 and 4 are tied at twenty percent each -- together they're forty percent of your exam, which is as big as Domain 1. Domain 3 is Claude Code configuration: the CLAUDE.md hierarchy, the .claude directory, skills, slash commands, custom rules, CI/CD integration, plan mode. Domain 4 is prompt engineering and structured output: few-shot examples, enforcing structure with tool_choice, the Message Batches API, validation-retry patterns, multi-instance review architectures. Both of these reward hands-on experience. If you've actually built Claude Code workflows or prompt pipelines, a lot of this will feel like review.
-->

---

<script setup>
const d2Topics = [
  'Writing tool descriptions Claude selects correctly',
  'MCP server configuration: project vs user scope',
  'When to use MCP resources vs MCP tools',
  'Error response structure',
]
</script>

<DomainFocus
  number="2"
  name="Tool Design & MCP"
  pct="18"
  color="#7aca4c"
  :topics="d2Topics"
  keyPoint="Every tool error needs three fields: <strong>errorCategory</strong>, <strong>isRetryable</strong>, and a human-readable description. Miss one -- pick a distractor that looks almost right."
  scenarios="Scenario 4"
/>

<!--
Domain 2 -- Tool Design and MCP -- is eighteen percent. Tool descriptions that Claude actually picks correctly. MCP error response structure. MCP server configuration at project and user scope. The single most exam-critical thing in this domain is the error response structure: every tool error needs three fields -- errorCategory, isRetryable, and a human-readable description. Miss one of those and you'll pick a distractor that looks almost right but isn't. Almost-right is the whole trap of this exam.
-->

---

<script setup>
const d5Topics = [
  'Managing long context windows',
  'Escalating to human agents -- when and how',
  'Error propagation across multi-agent systems',
  'Handling conflicting information from multiple sources',
]
</script>

<DomainFocus
  number="5"
  name="Context Management & Reliability"
  pct="15"
  color="#3faca5"
  :topics="d5Topics"
  keyPoint="Lowest weight, higher value-per-hour than it looks. The escalation framework appears in two scenarios, and the 'lost in the middle' effect is a classic trap question."
  scenarios="Scenarios 1 & 3 -- do not skip it"
/>

<!--
Domain 5 is the smallest at fifteen percent -- but it has a higher value-per-study-hour than its weight suggests. It covers long context management, escalation decisions, cross-agent error propagation, and handling conflicting information. The escalation framework shows up in at least two of the six scenarios, and the 'lost in the middle' effect is a common trap question. So even if you're short on time, spend at least one study session here. Don't skip it because it's small.
-->

---

<SectionBreak part="04" title="Six scenarios." blurb="The frame every question is built on. You prepare for all six; Anthropic picks four." />

<!--
Now the other half of the content map -- the six scenarios. Every question on the exam is framed around one of these.
-->

---

<ScenariosTable />

<!--
Here are the six. Scenario 1, Customer Support Resolution Agent -- multi-turn, tools, human escalation. Scenario 2, Code Generation with Claude Code. Scenario 3, Multi-Agent Research System -- a coordinator spawning subagents. Scenario 4, Developer Productivity -- tool design for engineers. Scenario 5, Claude Code for CI/CD -- non-interactive pipelines. Scenario 6, Structured Data Extraction -- JSON schemas and batch APIs. Each scenario maps primarily to one or two domains. This is the vocabulary of every question you'll see.
-->

---

<ScenarioMatrix />

<!--
If you look at which scenarios test which domains, a pattern emerges. Scenarios 1 and 3 both hit Domain 1 hardest -- that's your twenty-seven-percent domain, tested twice. Scenarios 5 and 6 cover Domains 3 and 4, the tied twenty-percent domains. Scenarios 2 and 4 are more domain-specific -- Claude Code workflow and tool design respectively. If Domains 1, 3, and 4 are your strengths, you're well-positioned regardless of which four scenarios you draw.
-->

---

<SectionBreak part="05" title="Study strategy." blurb="Three paths through this course -- pick the one that matches where you are today." />

<!--
Okay -- time for the practical part. How do you actually work through this course? There's no single right answer because everyone starts from a different place. So I'm going to give you three paths. Pick the one that matches where you are today -- not where you wish you were. I'll walk you through all three.
-->

---

<PathCard pathKey="a" />

<!--
Path A is for folks new to the Claude API. You start at the top: the API Bootcamp is non-negotiable because it's the foundation everything else plugs into. From there, watch every course lecture, read every study guide, and work through every demo. Don't skim -- you're building fluency, not just reviewing. Once you're through the material, you enter the practice loop: take the practice exam, review the sections where you struggled, and re-take. Loop 5 -> 6 -> 7 -> 5 until you're consistently at nine hundred or above before you book the real thing.
-->

---

<PathCard pathKey="b" />

<!--
Path B is for those with decent hands-on experience across the Claude API, Claude Code and the Agent SDK. You can skim the API Bootcamp as a refresher rather than watching end-to-end. Everything downstream -- lectures, study guides, demos -- you work end-to-end because the exam tests judgment, not just familiarity. Then you hit the same practice loop: take the exam, review weak sections, re-take until you're at nine hundred. Same finish line, same discipline.
-->

---

<PathCard pathKey="c" />

<!--
Path C is for experienced practitioners shorter on time. You skip the Bootcamp and the lectures entirely, and jump straight to the study guides and demos -- they're the densest signal. Then straight into the practice loop: take the exam, use the result to identify your weakest sections, review only those, and re-take. Loop until nine hundred. A warning: it's tempting to book the real exam after one passing practice score. Don't. Consistency at nine hundred is the bar, not a single lucky run. Whichever path you're on, that's the discipline that separates the people who pass from the people who walk out wondering what happened.
-->

---

<SectionBreak part="06" title="Course roadmap." blurb="Eleven sections, three phases. Here's how they fit together -- and why the middle maps directly to the exam." />

<!--
Last piece of groundwork: a map of where you're going. Before we wrap up and open Domain 1, I want to orient you to the full course -- how the eleven sections are organized, why they're in the order they're in, and where you are in the journey right now.
-->

---

<CourseRoadmap />

<!--
Here's the shape of the whole course. Phase 1 is foundations -- Section 1, what you're in right now, sets the exam strategy. Section 2 is a hands-on Claude API bootcamp, because the exam expects a working understanding of the API underpinning everything else, so this builds that foundation. Phase 2 is the five exam domains -- Sections 3 through 7 -- and they map directly to the domains but ordered by weight, not by the order Anthropic lists them. You spend the most time where the exam spends the most points. Phase 3 is exam readiness, and these are the four preparation-exercise demos pulled straight from the official exam guide -- the "demos" I keep referring to in the study paths. Section 8 is a multi-tool agent with escalation logic, reinforcing Domains 1, 2 and 5. Section 9 is configuring Claude Code for a team workflow -- Domains 3 and 2. Section 10 is a structured data extraction pipeline -- Domains 4 and 5. And Section 11 is a multi-agent research pipeline -- Domains 1, 2 and 5. Across the four demos, every single domain gets hands-on reps. You don't just watch -- you build. That's where judgment comes from.
-->

---

<StudyGuidesRef />

<!--
Let me zoom in on the middle phase, because this is where the ordering matters most. Section 3 is Domain 1 at twenty-seven percent. Section 4 is Domain 3 at twenty. Section 5 is Domain 4, also twenty. Section 6 is Domain 2 at eighteen, and Section 7 is Domain 5 at fifteen. Notice I didn't order them one-two-three-four-five. I ordered them by weight, largest to smallest. The reason is simple: Domain 1 is almost twice the size of Domain 5, and watching Section 3 first gives you the agentic-loop mental model that every other domain plugs into. If you only get through the first three domain sections, you've already covered sixty-seven percent of the exam by weight. That's intentional. Alongside the lectures, I've included four scenario-specific study guides -- Customer Support, Code Generation, Multi-Agent Research, and Claude Code for CI/CD. Each one cross-references the relevant content from the official exam guide, so you can drill deeper on whichever scenarios you feel least confident about.
-->

---

<ClosingSlide />

<!--
Four things to carry with you into the next section. This exam tests judgment, not trivia -- every question is a scenario, every scenario rewards principled reasoning. Prepare for all six scenarios -- you don't pick the four that appear, Anthropic does. Hands-on experience is the best experience -- completing the four preparation exercises from the exam guide will teach you small nuances you might not catch otherwise, and my demos walk through each one step-by-step. And finally, Claude is the best study partner -- if you can, use Claude chat alongside this course to explain concepts, generate examples, and quiz you as you study. You're about to get live tutoring on the exact technologies the exam tests.
-->
