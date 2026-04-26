# Claude Certified Architect — Udemy Course

Exam prep course for the Anthropic Claude Certified Architect certification. Contains lecture scripts, quizzes, labs, study guides, and resources.

## Project Context

- **Author:** Jonathan Dyer / Dyer Innovation
- **Course platform:** Udemy

## Plugin dependency: `dyerinnovation/udemy-course-builder`

Install this plugin first — it owns every skill that touches Udemy or generates course content. Local checkout: `~/Documents/dev/udemy-courses/udemy-course-builder/`.

**Registered skills (read each `SKILL.md` frontmatter before claiming a capability is missing):**

| Skill | Type | Purpose |
|---|---|---|
| `udemy-course-planner` | authoring | Section/lecture structure, learning objectives, folder scaffolding from `course-outline.md` |
| `udemy-lecture-writer` | authoring | Full narrated lecture scripts + slide content |
| `udemy-slide-creator` | authoring | Branded `.pptx` from lecture scripts (python-pptx) |
| `udemy-quiz-creator` | authoring | Section quizzes + practice exams |
| `udemy-coding-exercise-authoring` | authoring | 5-file Udemy native coding exercises |
| `slidev-runner` | dev tooling | Slidev v51 deck dev/build/scope-fix |
| `udemy-landing-populator` | **deployment (Playwright MCP)** | Pushes landing-page / intended-learners / messages into the Udemy instructor dashboard |
| `udemy-curriculum-populator` | **deployment (Playwright/Chrome MCP)** | Pushes sections + lecture stubs into `/manage/curriculum/` from planner output |
| `udemy-coding-exercise-deployer` | **deployment (Chrome MCP)** | Pushes a single coding exercise into an existing section |

### MANDATORY pre-work for any "is X possible?" question

Before proposing a new skill, claiming a capability is missing, or spawning a subagent to "build what's needed":

1. **List the plugin skills directory:** `ls ~/Documents/dev/udemy-courses/udemy-course-builder/.claude/skills/`
2. **Read `~/Documents/dev/udemy-courses/udemy-course-builder/plugin.json`** — the `skills` array is the registered set
3. **Read the `SKILL.md` frontmatter** of any skill whose name plausibly covers the request

The table above is a snapshot — the plugin itself is the source of truth. If a skill exists and you didn't audit it, you're guessing.

## Directory Structure

- `scripts/` — Lecture scripts organized by section (section-01 through section-07 only; Sections 8–11 have no scripts)
- `quizzes/` — Section quizzes
- `labs/` — Hands-on lab exercises
- `labs/demos/` — Four demo directories (`demo-1-*` … `demo-4-*`) that deliver Sections 8–11; each contains a `README.md` plus a `*-recording-script.md`
- `resources/` — Student downloadable resources and cheat sheets (includes `anthropic-exam-guide.md`, the only official practice-question source)
- `slides/` — Generated .pptx slide decks
- `slidev/` — Slidev source decks
- `assets/` — Diagrams and code samples
- `docs/` — Course creation guides and monetization strategy
- `course-outline.md` — Full section/lecture breakdown (11 sections)
- `study-guide.md` — Comprehensive study material (organized by domain)

## Rules

@.claude/rules/
