# Quiz: Section 1 — Exam Mechanics & Strategy

**Scope**: Lecture 1.1 — the exam's five domains and their weights, the six scenarios and the six-pick-four rule, scoring (720/1000, no-penalty guessing), study paths A/B/C, and how to read the official exam guide.

**Format**: 10 questions — ~6 multiple choice, ~2 true/false, ~2 multi-select. Every distractor is deliberately "almost-right" per the 1.1 framing: plausible in another context, wrong here. Each question ends with an Explanation that covers why the correct answer is correct AND why each distractor fails.

---

## Q1 (multiple choice) — Overview · All scenarios

**Stem:**
Your friend tells you "I just need 72% to pass, so I'll aim for a raw score of 720/1000 correct out of 1000." What's wrong with that plan?

A) Nothing — 720/1000 raw correct is exactly what the exam requires.
B) The passing score is 800/1000, not 720.
C) 720/1000 is a scaled score, not a raw count — you can't infer the number of questions you need correct from it.
D) The 720 applies only to Domain 1; other domains are scored separately.

**Correct Answer:** C

### Explanation
The 720 is a scaled score on a 100–1000 range, not a count of correct answers. Anthropic doesn't publish the raw-to-scaled mapping, so the practical takeaway is: aim for *consistent* 900+ on practice before booking — that's the only signal you can trust. (A) is the common beginner trap. (B) is a plausible-but-wrong threshold that sounds like a standard cert cutoff. (D) would be true on a domain-gated exam, but this one aggregates across all domains.

---

## Q2 (multiple choice) — Overview · All scenarios

**Stem:**
The exam presents six scenarios and you answer questions from four of them. Which statement about the four-scenario selection is correct?

A) You pick which four, so focus study on your strongest four and skip the rest.
B) Anthropic picks which four, so prepare all six equally well.
C) All six count, but only the four with the highest score are applied.
D) Scenarios are randomized per candidate; some candidates see more than four.

**Correct Answer:** B

### Explanation
The six-pick-four structure is Anthropic's selection, not yours. The strategic move is to prepare for all six — whichever four appear, you're ready. (A) is the most dangerous "almost-right" trap; candidates who believe they pick rationalize skipping a domain. (C) sounds like a friendly best-of-N scoring rule but isn't how the exam works. (D) confuses six-pick-four with question randomization.

---

## Q3 (multiple choice) — Overview · All scenarios

**Stem:**
You're down to the final 30 seconds on exam day and have three questions left unanswered. What's the right move?

A) Leave them blank — a wrong answer hurts more than an empty one.
B) Fill in all three with any guess — wrong and blank both score zero, so a guess strictly dominates blank.
C) Skip the hardest two and only guess on the easiest one.
D) Flag all three for review and submit — the review flag adjusts scoring.

**Correct Answer:** B

### Explanation
There is no penalty for wrong answers — wrong and blank both score zero. A random one-in-four guess gives you a 25% shot at points, which strictly beats zero. (A) is the classic standardized-test instinct from exams that *do* penalize wrong answers — wrong context, wrong answer. (C) leaves free points on the table. (D) invents a "review flag" mechanic that doesn't exist.

---

## Q4 (multiple choice) — Overview · Scenarios 1, 3

**Stem:**
You have exactly five days before the exam and can only study one domain deeply. Which domain has the highest exam-weight ROI per study hour?

A) Domain 1 — Agentic Architecture & Orchestration (27%)
B) Domain 3 — Claude Code Configuration (20%)
C) Domain 4 — Prompt Engineering (20%)
D) Domain 5 — Context Management & Reliability (15%)

**Correct Answer:** A

### Explanation
Domain 1 is 27% — by far the biggest single lever — and it's tested across two scenarios (1 and 3), so it can drive roughly half your exam in practice. (B) and (C) are each 20% and tempting if you have Claude Code / prompt engineering experience already, but even mastery of one 20% domain is smaller than one 27% domain. (D) is legitimately high-value-per-hour but the absolute ceiling is lower at 15%; it's not the right *single* pick when the question is exam-weight ROI.

---

## Q5 (multiple choice) — Overview

**Stem:**
A fellow candidate argues Domain 2 (Tool Design & MCP) deserves the most study time because tool design is "the hardest topic conceptually." What's the best exam-prep counter?

A) Agree — conceptual difficulty correlates with exam weight.
B) Disagree — study time should track exam weight, and Domain 2 is 18%, smaller than Domains 1, 3, and 4.
C) Agree — Domain 2's error-response structure is worth 30% of the exam alone.
D) Disagree — Domain 2 doesn't appear on the exam at all; it's covered implicitly by Domain 1.

**Correct Answer:** B

### Explanation
Exam weight, not perceived difficulty, should govern study allocation. Domain 2 is 18% — smaller than Domain 1 (27%) and tied-for-second Domains 3 and 4 (20% each). (A) confuses difficulty with weight. (C) invents a weight figure. (D) is outright wrong — Domain 2 is a full tested domain. Note: Domain 2 *is* worth solid study time despite being 18% — this question is about *relative* allocation.

---

## Q6 (true/false) — Overview · All scenarios

**Stem:**
**True or False:** Because scaled scoring compresses raw performance, a single practice-exam score of 720 is a reliable signal that you're ready to book the real thing.

A) True
B) False

**Correct Answer:** B (False)

### Explanation
One passing run isn't the bar — *consistency* at 900+ is. Scaled scoring means a lucky 720 on practice can be a 650 on the real exam if the scenario mix is unfavorable. The whole point of the practice loop (take → review → retake) is to converge to a stable score *above* the cliff. The trap in this question is that 720 is the published pass line, so it *feels* like the right signal. It isn't.

---

## Q7 (multiple choice) — Overview · Scenarios 1, 3

**Stem:**
Which pair of scenarios maps most heavily to Domain 1 (Agentic Architecture, 27%)?

A) Scenario 2 (Code Generation) and Scenario 5 (Claude Code CI/CD)
B) Scenario 1 (Customer Support) and Scenario 3 (Multi-Agent Research)
C) Scenario 4 (Developer Productivity) and Scenario 6 (Structured Extraction)
D) All six scenarios weigh Domain 1 equally.

**Correct Answer:** B

### Explanation
Scenarios 1 and 3 are the Domain 1 heavyweights — customer support agents and multi-agent research systems both stress the control loop, subagent coordination, and escalation. (A) are Claude-Code-centric scenarios, which lean on Domain 3. (C) is the Domain 2 + Domain 4 pair. (D) is the comforting-but-wrong generalization — scenarios are deliberately weighted toward specific domains, and knowing which is which is a study lever.

---

## Q8 (multi-select) — Overview · All scenarios

**Stem:**
Select ALL of the following that are true about the Claude Certified Architect exam. (Choose two.)

A) Each question is multiple choice with one correct answer and three plausible distractors.
B) Wrong answers subtract points from your score.
C) The exam tests judgment — wrong answers are almost-right in a different context.
D) Domain 5 is not tested because it's a supporting concept, not a domain.

**Correct Answers:** A, C

### Explanation
(A) is the exam's format — 4 options, one correct, three distractors designed to be "almost-right." (C) is the 1.1 thesis restated: judgment over trivia. (B) is false — wrong answers score zero, not negative, so you always guess. (D) is false — Domain 5 is 15% of the exam, the smallest weighting but still tested. Note: multi-select questions like this one appear on the real exam — read carefully to see how many you must pick.

---

## Q9 (multiple choice) — Overview · All scenarios

**Stem:**
A candidate with eighteen months of Claude Code and Agent SDK experience asks which study path from Lecture 1.1 they should follow. Which answer best matches the 1.1 guidance?

A) Path A — watch every lecture end-to-end because certification exams always reward exhaustive review.
B) Path B — skim the API Bootcamp as refresher, work lectures/guides/demos end-to-end, then enter the practice loop.
C) Path C — skip directly to booking the exam; with that much experience, practice is wasted time.
D) No path — create a custom plan based only on your own weak areas.

**Correct Answer:** B

### Explanation
Path B is explicitly for candidates with "decent hands-on experience" — skim bootcamp, work the rest, run the practice loop until 900+. (A) is Path A, meant for students *new* to the Claude API — unnecessary for an experienced practitioner. (C) is the overconfidence trap — even experienced builders need the practice loop for the exam's specific framing. (D) conflates having experience with not needing structure; Path C already is the custom-for-experienced path, and it still requires the practice loop.

---

## Q10 (true/false) — Overview · All scenarios

**Stem:**
**True or False:** "Almost-right is the whole trap of this exam" means the exam's distractors are designed to be technically correct in a different context — so recognizing the exact scenario the question is framing in is often the difference between the right answer and a plausible wrong one.

A) True
B) False

**Correct Answer:** A (True)

### Explanation
This is the 1.1 thesis and the single most important mental frame for the exam. Distractors aren't nonsense — they're solutions that would work in *another* Claude system or *another* scenario. The skill being tested is matching the *specific* constraints of the scenario in front of you to the right architectural move. If you walk out of this course remembering only one thing, remember this.
