# Coding Exercise Authoring Rules

Exercises live at `labs/coding-exercises/section-N/NN-<slug>/` and target
Udemy's native in-browser coding-exercise feature. Students never see this
repo — Udemy is the delivery surface. See `labs/coding-exercises/README.md`
for the full file-format spec.

## Core constraint

Udemy's coding-exercise sandbox has **no network, no external dependencies,
no API keys**. Every exercise in THIS course focuses on the logic around
Claude — parsing responses, writing tool schemas, branching on stop_reason,
validating structured output — using **mock API responses as Python dicts**,
never real API calls.

## Heuristics (apply to every exercise)

1. **Mock the API, don't call it.** API-shaped dicts live in the test file as
   fixtures. The student's function operates on dicts, not on `anthropic.Anthropic()`
   instances.

2. **One concept per exercise.** A `stop_reason` branch doesn't also test tool
   schema. Split when in doubt. If you find yourself writing a 3-paragraph
   problem statement, it's two exercises.

3. **5-10 minute solve time.** A student who watched the related lecture
   should be able to picture the solution within 90 seconds of reading the
   problem. If they can't, you've scoped it too broadly.

4. **High-value only — NOT one per lecture.** Target ~22 exercises across
   Sections 2-7. Every exercise must map to at least one official exam
   scenario via the `exam_scenarios:` frontmatter.

5. **Evaluation uses only the Python standard library.** `unittest` or plain
   `assert`. No pytest, no external deps.

6. **Learner file is meaningful but incomplete.** Function signature + type
   hints + docstring + a `# TODO` or `pass`. Not blank. Not the solution with
   one line stripped.

7. **Problem statement shows example input + expected output.** Concrete I/O
   beats abstract descriptions every time. Include at least two examples.

8. **Test coverage includes the "almost-right trap."** Every exercise has at
   least one test case that catches the plausible-but-wrong answer — the
   distractor pattern the exam itself uses.

## Dogfood test (mandatory before commit)

Every exercise must prove its solution passes its own evaluation:

```bash
cd labs/coding-exercises/section-N/NN-<slug>
cp learner.py learner.py.bak
cp solution.py learner.py
python -m unittest evaluation.py
# expect: OK
mv learner.py.bak learner.py
```

If this fails, either the solution or the evaluation is wrong. Fix before
committing.

## When to split, when to simplify

If the exercise keeps growing during authoring:

- **Solution > 40 lines** → split into two exercises
- **Problem statement > 3 paragraphs** → you're teaching, not testing. Move
  the teaching to the lecture; keep the exercise to the skill check.
- **More than 4 hints** → the concept is too big. Split.
- **Test file > 15 cases** → you're testing too many concepts. Split.

## Cross-references

- Format spec: `labs/coding-exercises/README.md`
- Seed exercise: `labs/coding-exercises/section-2/01-parse-stop-reason/`
- Authoring skill: `udemy-coding-exercise-authoring` (in `udemy-course-builder` repo)
- Deployment skill: `udemy-coding-exercise-deployer` (in `udemy-course-builder` repo)
