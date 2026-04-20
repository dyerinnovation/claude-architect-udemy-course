# Course Content Conventions

## Lecture Scripts
- Scripts live in `scripts/section-XX-<topic>/` directories (sections 01–07 only; Sections 8–11 have no lecture scripts — see Demo Sections below)
- File naming: `X.Y-<lecture-title-kebab-case>.md`
- Each script includes `<!-- SLIDE: N -->` markers for slide generation
- Lectures should teach ONE concept each (5–15 minutes, sweet spot 7–10)
- Exception: `scripts/section-01-intro/1.1-welcome-and-what-youll-learn.md` is a combined ~15 min narrative covering all of Section 1 (no per-sub-lecture split)

## Quizzes
- Per-section quizzes: 10 questions each (Sections 1–7 only — demo sections don't have standalone quizzes)
- Formats: multiple choice, true/false, multi-select (Udemy-compatible)
- Quiz files live in `quizzes/section-XX-<topic>.md`
- The official Anthropic exam-guide questions are the only "practice exam" — no custom 40-question quiz is part of this course

## Demo Sections (Sections 8–11)
- Sections 8–11 are the four preparation-exercise demos from the official Anthropic exam guide
- No Slidev decks and no lecture scripts — content lives under `labs/demos/demo-N-<slug>/`
- Each demo directory contains three things (Udacity-format):
  - `README.md` — overview, learning objectives, Claude surfaces used, domains reinforced, quick start, additional resources
  - `demo-N-<slug>-recording-script.md` — timestamped `[0:00]`-style walkthrough script for OBS recording
  - `demo-N-<slug>-infrastructure-build-scripts/` — deploy/cleanup shell scripts + example code

## Labs (Sections 2–7)
- Hands-on labs referenced inline from lecture scripts live under `labs/<topic>/`
- Every lab directory must have a `README.md` with objectives and instructions

## Resources
- Cheat sheets go in `resources/cheat-sheets/`
- `resources/QUICK-START.txt` provides student orientation
- `resources/anthropic-exam-guide.md` is the canonical markdown conversion of the official exam guide PDF
