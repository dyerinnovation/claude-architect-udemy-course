---
theme: default
title: "Lecture 5.3: @import — Modular CLAUDE.md"
info: |
  Claude Certified Architect – Foundations
  Section 5 — Claude Code Configuration (Domain 3, 20%)
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
const splitBullets = [
  { label: 'Topic is maintained by a different team', detail: 'Testing standards owned by platform eng; API conventions owned by product' },
  { label: 'Only relevant to a subset of work', detail: 'Frontend package doesn\u2019t need database-migration rules' },
  { label: 'Changes often and noise-floods the main file', detail: 'High churn buried next to stable conventions' },
]

const importSyntax = `# CLAUDE.md

## Project conventions
...

@import ./docs/testing-standards.md
@import ./docs/api-conventions.md
@import ./docs/deployment.md
`

const importTreeExample = `# packages/api/CLAUDE.md
@import ../../docs/api-conventions.md
@import ../../docs/testing-standards.md

# packages/frontend/CLAUDE.md
@import ../../docs/react-standards.md
@import ../../docs/testing-standards.md

# packages/infra/CLAUDE.md
@import ../../docs/terraform-standards.md
@import ../../docs/deployment.md
`
</script>

<!-- SLIDE 1 — Cover -->

<Frame bg="var(--forest-900)" color="var(--mint-100)">
  <div style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
    <div style="font-family: var(--font-body); font-size: 26px; font-weight: 600; letter-spacing: 0.16em; text-transform: uppercase; color: var(--sprout-500); margin-bottom: 40px;">
      Domain 3 &middot; Lecture 5.3
    </div>
    <h1 style="font-family: var(--font-display); font-weight: 500; font-size: 108px; line-height: 1.02; letter-spacing: -0.025em; color: var(--paper-0); margin: 0; max-width: 1500px;">
      <span style="color: var(--sprout-500);">@import</span> — Modular CLAUDE.md
    </h1>
    <div style="font-family: var(--font-display); font-size: 44px; color: var(--mint-200); margin-top: 40px; font-weight: 400; max-width: 1200px; line-height: 1.3;">
      Each imported file is one concern. One line stops the monolith.
    </div>
  </div>
</Frame>

<!--
CLAUDE.md grows linearly with complexity. Every new convention gets appended. Every new team adds a section. Before long you've got a 400-line file that nobody reads and Claude skims. `@import` is how you stop that.
-->

---

<!-- SLIDE 2 — The problem -->

<BigQuote
  lead="The failure mode"
  quote="CLAUDE.md hit 400 lines. Nobody reads it. <em>Claude skims it.</em>"
  attribution="Every team eventually"
/>

<!--
"CLAUDE.md hit 400 lines. Nobody reads it. Claude skims it." That's the failure mode. Monolithic instructions files rot. New conventions get buried next to old ones. Teams stop reading because they can't find the thing they care about. Claude's attention gets spread across content that isn't relevant to the current task. The fix isn't "write a shorter CLAUDE.md" — the conventions are real. The fix is modularity.
-->

---

<!-- SLIDE 3 — The syntax -->

<CodeBlockSlide
  eyebrow="One line of syntax"
  title="@import in CLAUDE.md"
  lang="markdown"
  :code="importSyntax"
  annotation="Claude splices the imported file in verbatim at the @import line."
  footerLabel="Lecture 5.3 · @import"
  :footerNum="3"
  :footerTotal="9"
/>

<!--
The syntax is one line. Inside your CLAUDE.md you write `@import ./docs/testing-standards.md` — relative path to another markdown file. Claude loads that file inline at the location of the import, as if the content were spliced in verbatim. You can import from anywhere in the repo — a `docs/` folder, a shared standards directory, a sibling package, even a top-level standards directory that multiple packages reference. Each imported file is its own concern. Testing standards in one file. API conventions in another. Deployment rules in a third. Security practices in a fourth. The CLAUDE.md becomes a table of contents rather than a dumping ground — it says what applies here, and the imported files hold the detail.
-->

---

<!-- SLIDE 4 — When to split -->

<BulletReveal
  eyebrow="When to split"
  title="Three signals that earn modularity"
  :bullets="splitBullets"
  footerLabel="Lecture 5.3 · @import"
  :footerNum="4"
  :footerTotal="9"
/>

<!--
Split a section into its own imported file when the topic is maintained by a different team — your testing standards are owned by platform engineering, say, and your API conventions by the product team. Split when the content is only relevant to a subset of work — the frontend package doesn't need database migration rules. Split when the section changes often and noise-floods the main file with churn. Those three signals — different owner, different scope, high change rate — are when modularity pays for itself.
-->

---

<!-- SLIDE 5 — Import tree example -->

<CodeBlockSlide
  eyebrow="Monorepo pattern"
  title="Package CLAUDE.md with selective imports"
  lang="markdown"
  :code="importTreeExample"
  annotation="Each package maintainer picks the 2–3 standards files that actually apply."
  footerLabel="Lecture 5.3 · @import"
  :footerNum="5"
  :footerTotal="9"
/>

<!--
Here's the pattern in a monorepo. Each package has its own CLAUDE.md, and each one imports selectively. The API package imports `api-conventions.md` and `testing-standards.md`. The frontend package imports `react-standards.md` and `testing-standards.md`. The infra package imports `terraform-standards.md` and `deployment.md`. The maintainer of each package picks the 2–3 standards files that actually apply. The root CLAUDE.md stays high-level — architecture overview, build commands — and the package-level ones pull in what they need.
-->

---

<!-- SLIDE 6 — Alternative: .claude/rules/ -->

<Frame>
  <Eyebrow>Two modular patterns</Eyebrow>
  <SlideTitle>@import vs .claude/rules/ — same goal, different triggers.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Know the distinction">
      <p><code>@import</code> loads <strong>always</strong> — whenever the parent CLAUDE.md loads, the imported file comes with it.</p>
      <p><code>.claude/rules/</code> loads <strong>conditionally</strong> — based on path globs in YAML frontmatter. Covered in 5.4 and 5.5.</p>
      <p>Use <code>@import</code> when content should always be loaded for this package. Use rules when content should only load when specific file types are being edited.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.3 · @import" :num="6" :total="9" />
</Frame>

<!--
Here's a distinction you need. `@import` loads always — when Claude opens that CLAUDE.md, the imported file comes with it. `.claude/rules/` loads conditionally — based on path globs in YAML frontmatter, which we cover next in 5.4 and 5.5. Two patterns, two use cases. Use `@import` when the content should always be loaded for this package. Use `.claude/rules/` when the content should only load when specific file types are being edited. Same goal — modularity — different triggers.
-->

---

<!-- SLIDE 7 — Exam framing -->

<Frame>
  <Eyebrow>On the exam</Eyebrow>
  <SlideTitle>"Modular CLAUDE.md" = @import.</SlideTitle>
  <div style="margin-top: 48px; max-width: 1500px;">
    <CalloutBox variant="tip" title="Task 3.1 — the keyword match">
      <p>"Using <code>@import</code> to selectively include relevant standards files in each package's CLAUDE.md based on maintainer domain knowledge." Direct quote from the exam guide.</p>
      <p>Memorize the phrase <strong>per-package selective imports</strong>. If the question describes a monorepo with multiple packages each needing different subsets of standards, the answer is <code>@import</code> — not a monolithic root CLAUDE.md.</p>
    </CalloutBox>
  </div>
  <SlideFooter label="Lecture 5.3 · @import" :num="7" :total="9" />
</Frame>

<!--
On the exam, "modular CLAUDE.md" is the keyword that maps to `@import`. The skill the exam tests is "using @import to selectively include relevant standards files in each package's CLAUDE.md based on maintainer domain knowledge." That's a direct quote from Task 3.1. Memorize the phrase "per-package selective imports" — it's the pattern match for any question about splitting up a large CLAUDE.md without losing standards. If the question describes a monorepo with multiple packages each needing different subsets of standards, the answer is `@import`, not a monolithic root CLAUDE.md.
-->

---

<!-- SLIDE 8 — Anti-pattern -->

<AntiPatternSlide
  eyebrow="Anti-pattern"
  title="Don't import everything everywhere"
  badExample="# packages/frontend/CLAUDE.md
@import ../../docs/testing-standards.md
@import ../../docs/api-conventions.md
@import ../../docs/terraform-standards.md
@import ../../docs/rds-backup-policy.md
@import ../../docs/deployment.md
# ... 12 more"
  whyItFails="Twelve copies of the same monolith is worse than one monolith."
  fixExample="# packages/frontend/CLAUDE.md
@import ../../docs/react-standards.md
@import ../../docs/testing-standards.md
# Only the 2–3 files this package actually needs."
  lang="markdown"
  footerLabel="Lecture 5.3 · @import"
  :footerNum="8"
  :footerTotal="9"
/>

<!--
Bad: import every standards file into every CLAUDE.md. You've replaced one monolith with twelve copies of the same monolith. Good: each package imports only the 2–3 files its maintainer deemed relevant. The point of modularity isn't to stop using the content — it's to stop loading irrelevant content. A terraform file doesn't need React conventions. The frontend doesn't need the RDS backup policy. Import what applies.
-->

---

<!-- SLIDE 9 — Closing -->

<Frame bg="var(--mint-100)">
  <Eyebrow>Takeaways</Eyebrow>
  <SlideTitle>@import — one file per concern.</SlideTitle>
  <div style="margin-top: 48px; display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">01</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Always-loaded.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Splices in verbatim when the parent CLAUDE.md loads.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">02</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Split by concern.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Different owner, different scope, high change rate.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">03</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Import per package.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;">Each maintainer picks only the files that apply to their package.</div>
    </div>
    <div style="background: var(--paper-0); border-radius: 16px; padding: 32px 36px;">
      <div style="font-family: var(--font-mono); font-size: 22px; color: var(--sprout-600); font-weight: 600;">04</div>
      <div style="font-family: var(--font-display); font-size: 34px; color: var(--forest-800); font-weight: 500; margin-top: 10px;">Next &mdash; 5.4.</div>
      <div style="font-family: var(--font-body); font-size: 22px; color: var(--forest-500); margin-top: 8px; line-height: 1.45;"><code>.claude/rules/</code> — topic-specific rule files.</div>
    </div>
  </div>
</Frame>

<!--
`@import` is the universal-always pattern — one file per concern, loaded every time the parent CLAUDE.md loads. Split by concern, import per package. Keep the main CLAUDE.md a table of contents, not a monolith. Next lecture — 5.4 — we move to the conditional-load pattern: `.claude/rules/`. Same goal of modularity, different trigger — conditional instead of always. Then 5.5 puts the two together with path globs, and that's where Sample Question 6 lives.
-->
