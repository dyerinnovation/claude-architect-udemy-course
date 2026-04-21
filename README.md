# Claude Certified Architect – Foundations: Complete Certification Prep

**v1.0.0 — shipping.** The definitive Udemy course for passing the **Anthropic Claude Certified Architect – Foundations (CCA-F)** exam (v0.1, Feb 2025). Built by someone who took the exam, documented every question pattern, and reverse-engineered the exam's decision frameworks — not just someone who read the docs.

This course covers all 5 exam domains weighted by their actual exam importance, walks through all 6 exam scenarios, and teaches the judgment patterns the exam actually tests — not feature trivia.

## What's in the box (v1.0.0)

- **11 sections** covering all 5 exam domains plus four preparation-exercise demos
- **87 lecture scripts** in `scripts/` (Sections 1–7)
- **87 Slidev decks** in `slidev/lecture-X.Y.md` — one deck per lecture, built on a shared design system (`slidev/design-system.css`) and reusable Vue components in `slidev/components/`
- **7 per-section quizzes** (Sections 1–7, 10 Udemy-compatible questions each) in `quizzes/`
- **4 hands-on demos** (Sections 8–11) under `labs/demos/demo-{1..4}-*/` — each with a README, a timestamped recording script, and runnable deploy/cleanup scripts
- **Per-topic labs** under `labs/` referenced inline from lecture scripts
- **Cheat sheets and the official exam guide** under `resources/`

Total: roughly **18.5 hours** of instruction + demo walkthroughs.

## Target Audience

- **Solution architects** designing production AI systems with Claude
- **Senior engineers** building agentic applications (Agent SDK, MCP, Claude Code)
- **Technical leads** evaluating Claude for enterprise adoption
- **Anyone preparing** for the CCA-F certification exam

## Prerequisites

- Basic familiarity with LLM APIs (you've called Claude or GPT at least once)
- Some Python or TypeScript experience
- Willingness to build hands-on — this is not a slide-reading course

## Learning Objectives

By the end of this course, you will be able to:

1. **Design agentic architectures** using hub-and-spoke patterns, the `Task` tool, and programmatic enforcement — and know when NOT to over-engineer.
2. **Write effective tool descriptions** and configure MCP servers that Claude selects reliably.
3. **Configure Claude Code** for team workflows using the CLAUDE.md hierarchy, path-scoped rules, skills, and CI/CD integration.
4. **Engineer prompts** that produce structured, reliable output using `tool_use`, few-shot examples, and the Message Batches API.
5. **Manage context** across long sessions and multi-agent systems without losing critical information.
6. **Pass the CCA-F exam** by recognizing distractor patterns, applying the intervention hierarchy, and making the judgment calls the exam rewards.

## Course Structure

| Section | Domain / Topic | Exam weight | Decks | Duration |
|---|---|---|---|---|
| 1 | Course Intro & Exam Strategy | — | 1 | ~15 min |
| 2 | Claude API Fundamentals Bootcamp | — | 11 | ~90 min |
| 3 | Domain 1 — Agentic Architecture & Orchestration | **27%** | 14 | ~3 hr |
| 4 | Domain 2 — Tool Design & MCP Integration | 18% | 14 | ~2 hr |
| 5 | Domain 3 — Claude Code Configuration & Workflows | 20% | 15 | ~2.5 hr |
| 6 | Domain 4 — Prompt Engineering & Structured Output | 20% | 15 | ~2.5 hr |
| 7 | Domain 5 — Context Management & Reliability | 15% | 17 | ~2 hr |
| 8 | Demo 1 — Multi-Tool Agent with Escalation Logic | — | — | ~15 min |
| 9 | Demo 2 — Claude Code for a Team Dev Workflow | — | — | ~15 min |
| 10 | Demo 3 — Structured Data Extraction Pipeline | — | — | ~15 min |
| 11 | Demo 4 — Multi-Agent Research Pipeline | — | — | ~15 min |

The domain ordering above matches the course-outline (heaviest weight first). Filesystem folder names (e.g. `scripts/section-04-tool-design-mcp/`) preserve the original creation order — see `course-outline.md` for the mapping.

## Key Documents

- **[course-outline.md](course-outline.md)** — full section/lecture breakdown, scenario alignment, exam-weight reasoning
- **[study-guide.md](study-guide.md)** — comprehensive study material organized by domain
- **[resources/anthropic-exam-guide.md](resources/anthropic-exam-guide.md)** — canonical markdown conversion of the official exam guide PDF (the only official practice-question source)
- **[resources/cheat-sheets/](resources/cheat-sheets/)** — printable one-pagers referenced from the decks
- **[resources/QUICK-START.txt](resources/QUICK-START.txt)** — student orientation
- **[docs/](docs/)** — course-creation guides, naming conventions, monetization strategy

## Quick start (students)

1. Install the Claude Code CLI and a recent Node / Python toolchain:
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```
2. Clone this repo and install Slidev once (for the live decks):
   ```bash
   git clone <repo-url> claude-architect-udemy-course
   cd claude-architect-udemy-course/slidev
   npm install
   ```
3. Launch any single lecture deck on its mapped port:
   ```bash
   ./start-all.sh 3.5           # → http://localhost:3064
   # or
   npm run dev:3.5
   ```
4. Open the matching script in `scripts/section-03-agentic-architecture/3.5-...md` to read the narration alongside the slides.

Each demo under `labs/demos/demo-N-*/` has its own `README.md` with a 1-minute quick start.

### Downloadable Resources

- Domain weight cheat sheet
- Scenario-to-domain mapping table
- `tool_choice` options quick reference
- CLAUDE.md hierarchy diagram
- Error response required fields checklist
- Escalation decision flowchart
- Batch API vs synchronous API decision table
- `stop_reason` loop control flow diagram
- Built-in tool selection guide (Grep vs Glob vs Read vs Edit)

### Lab Prerequisites

- Anthropic API key with Claude access
- Node.js 18+ or Python 3.10+
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- Basic familiarity with JSON schema syntax

## Quick start (course author)

```bash
cd slidev
./start-all.sh --list          # print the port map
./start-all.sh 2.1             # launch one deck for review
./start-all.sh --all           # launch every deck (heavy)
```

Review workflow scratchpad lives under `feedback/` (gitignored). Each deck has a per-lecture file; flip `status: READY_TO_FIX` to dispatch a fix-agent. See `feedback/claude-architect-course-feedback-*.md` for the dashboard.

Port map:

| Section | Ports |
|---|---|
| 1 (lecture 1.1)   | 3030 |
| 2 (2.1–2.11)      | 3040–3050 |
| 3 (3.1–3.14)      | 3060–3073 |
| 4 (4.1–4.14)      | 3080–3093 |
| 5 (5.1–5.15)      | 3100–3114 |
| 6 (6.1–6.15)      | 3120–3134 |
| 7 (7.1–7.17)      | 3140–3156 |

## Exam Alignment

- Covers all 5 domains per the official Anthropic exam guide (v0.1, Feb 2025)
- Walks through all 6 exam scenarios with scenario-to-domain mapping
- The only official practice-question set is in `resources/anthropic-exam-guide.md` — we do not ship a separate custom 40-question exam
- Each section quiz explains WHY distractors are wrong, not just which answer is right

## What Makes This Course Different

- **Real exam experience**: The instructor took the exam and documented the question patterns, trap answers, and decision frameworks.
- **Scenario-first approach**: You learn concepts through the 6 exam scenarios, the same way the exam tests them.
- **Judgment over trivia**: The exam tests architectural judgment — this course teaches you how to think through tradeoffs, not memorize flags.
- **Hands-on demos**: Sections 8–11 are four working projects drawn straight from the official preparation exercises, with deploy/cleanup scripts in each demo folder.

## Credits

- Author: **Jonathan Dyer** / Dyer Innovation (dyer-capital.com/innovation)
- Slide engine: [Slidev](https://sli.dev/) with a custom Dyer Innovation design system
- License & exam content: Anthropic's Claude Certified Architect exam guide is © Anthropic; this course is an independent exam-prep product and is not affiliated with or endorsed by Anthropic.
