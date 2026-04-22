# Coding Exercises

In-repo authoring format for Udemy native coding exercises. Each exercise is a
directory under `section-N/NN-<slug>/` with exactly five files:

```
section-2/01-parse-stop-reason/
├── exercise.md         # metadata + problem statement + hints
├── learner.py          # starter code (what the student sees when they open)
├── solution.py         # full correct solution
├── evaluation.py       # automated tests (imports from `learner`)
└── explanation.md      # instructor solution walk-through (shown after pass)
```

Students never see this repo. Exercises are deployed into Udemy's instructor
dashboard via the `udemy-coding-exercise-deployer` skill — Udemy hides the
solution and evaluation from students automatically.

## Why coding exercises, not labs

The older `labs/customer-support-agent/` style required students to clone a
repo, install Python, and manage API keys. Udemy's native coding exercises run
in an in-browser sandbox with automated tests. Students get instant feedback;
instructors walk through the solution on video after.

The sandbox has **no network, no external dependencies, no API keys**. So every
exercise in this course focuses on the *logic around Claude* — parsing
responses, writing tool schemas, branching on stop_reason, validating
structured output — using **mock API responses as fixtures**, not real calls.

See `.claude/rules/coding-exercises.md` for authoring heuristics.

## The 5 files

### `exercise.md`

Frontmatter + problem statement. Frontmatter fields:

| Field | Required | Purpose |
|---|---|---|
| `id` | yes | Unique — `s<section>-<NN>-<slug>` |
| `title` | yes | What the student sees in the curriculum panel |
| `section` | yes | 2-7 |
| `lecture_ref` | recommended | The lecture this exercise reinforces (e.g. `"2.1"`) |
| `language` | yes | `python` (Python only for this course) |
| `difficulty` | yes | `easy` / `medium` / `hard` |
| `learning_objective` | yes | One sentence, starts with a verb |
| `exam_scenarios` | recommended | List of 1-6 — which official exam scenarios this reinforces |
| `related_lectures` | optional | Cross-reference other lectures |
| `estimated_minutes` | yes | Realistic solve time — 5-10 is the sweet spot |
| `hints` | recommended | 2-4 progressive hints, shown on student request |

Body is markdown. Must include:
- A brief "why this matters" intro (1-2 sentences)
- The function signature the student is asked to implement
- At least **two examples** with explicit input + expected output

### `learner.py`

What the student sees when they open the exercise. Must include:

- The target function signature with type hints
- A docstring describing args + return value
- A `# TODO: implement` or a `pass` — enough scaffolding to orient, not enough
  to solve

**Rule:** `learner.py` should be solvable in 5-10 minutes by someone who
watched the related lecture. If it's harder, split the exercise.

### `solution.py`

The full correct implementation. Keep it short — if the solution is > 40 lines
the exercise is probably too complex. The solution should be the *obvious*
solution given the lecture content, not a clever one-liner.

### `evaluation.py`

`unittest`-based tests. Imports the target function from `learner`:

```python
from learner import next_action

class Test(unittest.TestCase):
    def test_happy_path(self):
        self.assertEqual(next_action({...}), "expected")
```

**Must use only the Python standard library.** No pytest, no external deps.

**Coverage rule:** tests should include at least:
- 1 happy-path case
- 1 edge case (missing field, None, empty dict)
- 1 "almost-right trap" case (the wrong-answer shape a lazy implementer would match)

### `explanation.md`

Shown to the student *after* they pass. Sections:

- **Why this matters** — the real-world consequence of getting it right
- **The trap** — the plausible-but-wrong answer
- **The solution, line by line** — walk through solution.py
- **Exam relevance** — which scenarios this maps to, what the distractors look like

## Dogfood test

Before committing any new exercise:

```bash
cd labs/coding-exercises/section-N/NN-<slug>
cp learner.py learner.py.bak
cp solution.py learner.py
python -m unittest evaluation.py
# expect: OK
mv learner.py.bak learner.py
```

Tests must pass when the learner file IS the solution file. This proves the
evaluation file is consistent with the solution. If tests fail, either the
evaluation or the solution is wrong.

## Seed exercise

`section-2/01-parse-stop-reason/` is the canonical template. Every new
exercise should be written by copying the seed's file structure and editing
in-place, then running the dogfood test.

## Authoring workflow

Use the `udemy-coding-exercise-authoring` skill. Invoke with a lecture
reference and a one-line concept:

> "Create a coding exercise for lecture 4.3 on tool error response contract"

The skill reads the target lecture's narration for context, designs the mock
fixture, writes all 5 files, and runs the dogfood test before reporting.

## Deploying to Udemy

Use the `udemy-coding-exercise-deployer` skill with the path to the exercise
directory. The skill drives the Udemy instructor dashboard via Playwright:
creates the exercise in the curriculum, pastes each file, populates hints +
problem statement + explanation, runs Udemy's test pass, and saves (unpublished
— publish manually after review).

## Current inventory

| Section | Exercises | Target |
|---|---|---|
| 2 | 1 (seed) | 4 |
| 3 | 0 | 5 |
| 4 | 0 | 4 |
| 5 | 0 | 2 |
| 6 | 0 | 4 |
| 7 | 0 | 3 |
| **Total** | **1** | **22** |
