# Claude Certified Architect Exam: Downloadable Resources

Complete study materials and cheat sheets for the Claude Certified Architect exam. All files are formatted for printing and mobile viewing.

---

## Quick Start

**Before Your Exam:**
1. Read `20-things-to-know-cold.md` (memorize these)
2. Review `domain-weights.md` (know priorities)
3. Study `scenario-domain-mapping.md` (understand what you're tested on)

**Day Before Exam:**
- Review the 20 concepts again
- Review the escalation flowchart
- Review the stop_reason loop

**Exam Day:**
- Have your phone with cheat sheets ready
- Quick-reference during review time (if allowed)

---

## The Cheat Sheets

### Core Concept Sheets (Read First)

#### `domain-weights.md`
The exam domains and their weights. Domain 1 is 27% — make it your priority.

**Key Takeaway:** Study strategy based on domain percentages. Domain 1 > Domains 3 & 4 > Domain 2 & 5.

---

#### `20-things-to-know-cold.md`
The 20 highest-probability exam concepts. One-liner each.

**Key Takeaway:** Rapid-fire reference for the night before and morning of. Covers everything.

---

#### `exam-guide-reference.md`
Official exam structure from Anthropic. Domains, scenarios, task types, question count.

**Key Takeaway:** Understand how the exam is organized and what to expect.

---

### Decision-Making Sheets (Core Skills)

#### `stop-reason-flow.md`
The agentic loop. How Claude iterates with tools. Anti-patterns to avoid.

**Key Takeaway:** Master this. Domain 1 is 27% and most of it depends on understanding stop_reason.

---

#### `escalation-flowchart.md`
When to escalate. When NOT to escalate. The most-misunderstood topic.

**Key Takeaway:** Escalate on policy gap or explicit request. NOT on frustration.

---

#### `tool-choice-reference.md`
The three tool_choice options: "auto", "any", {"type":"tool","name":"X"}. When to use each.

**Key Takeaway:** Tool choice controls determinism. Pick based on whether model has a choice.

---

### Technical Reference Sheets

#### `error-response-checklist.md`
MCP error responses. Required fields: errorCategory, isRetryable, description.

**Key Takeaway:** Four categories (transient, validation, business, permission). Know when each applies.

---

#### `claude-md-hierarchy.md`
.claude/rules/ organization. Three levels. Glob patterns. @import. Priority order.

**Key Takeaway:** Shared rules > path-specific rules > personal. Path rules match left-to-right.

---

#### `batch-vs-sync-api.md`
Batch API (50% savings, 24hr) vs Synchronous (real-time). Decision table and examples.

**Key Takeaway:** Batch = non-urgent bulk. Sync = user waiting or tool-use loops.

---

#### `built-in-tools-guide.md`
Glob, Grep, Read, Write, Edit. When to use each. Selection decision tree.

**Key Takeaway:** Glob (files), Grep (content), Read (load), Write (new), Edit (modify).

---

### Framework & System Sheets

#### `scenario-domain-mapping.md`
All 6 exam scenarios with their primary domains and likely task statements.

**Key Takeaway:** Quick-reference for exam day. Know which domain each scenario tests.

---

#### `intervention-hierarchy.md`
Four levels: explicit criteria → examples → code enforcement → architectural redesign.

**Key Takeaway:** Fix at the lowest level. Level 1 before Level 2 before Level 3 before Level 4.

---

#### `out-of-scope-topics.md`
What NOT to study. Fine-tuning, auth, embeddings, vision, streaming, etc.

**Key Takeaway:** Save study time. Focus on the 5 domains, not infrastructure details.

---

## Study Plan by Week

### Week 1: Foundations
- Read `exam-guide-reference.md` (understand structure)
- Read `domain-weights.md` (understand priorities)
- Study `stop-reason-flow.md` (master the loop)
- Study `20-things-to-know-cold.md` (drill concepts)

**Time:** ~5 hours

---

### Week 2: Decision-Making
- Study `escalation-flowchart.md` (when to escalate)
- Study `tool-choice-reference.md` (determinism)
- Study `scenario-domain-mapping.md` (scenario preview)
- Practice first scenario

**Time:** ~5 hours

---

### Week 3: Deep Dives
- Study `error-response-checklist.md` (MCP errors)
- Study `claude-md-hierarchy.md` (.claude organization)
- Study `batch-vs-sync-api.md` (API decisions)
- Practice remaining scenarios

**Time:** ~5 hours

---

### Week 4: Polish & Practice
- Study `intervention-hierarchy.md` (fix strategies)
- Study `built-in-tools-guide.md` (file operations)
- Review `out-of-scope-topics.md` (confirm what NOT to study)
- Do practice exam

**Time:** ~5 hours

---

### Days Before Exam
- Memorize `20-things-to-know-cold.md`
- Review all domain summaries (1-2 pages each)
- Drill scenario decision points

---

## File Sizes & Printability

All files are optimized for printing (2 pages or less when printed).

| File | Size | Pages |
|------|------|-------|
| domain-weights.md | 1.7K | 1 |
| scenario-domain-mapping.md | 4.0K | 2 |
| tool-choice-reference.md | 3.5K | 2 |
| claude-md-hierarchy.md | 4.5K | 2 |
| error-response-checklist.md | 4.6K | 2 |
| escalation-flowchart.md | 6.6K | 3 |
| batch-vs-sync-api.md | 5.1K | 2 |
| stop-reason-flow.md | 7.4K | 3 |
| built-in-tools-guide.md | 6.3K | 3 |
| 20-things-to-know-cold.md | 5.5K | 2 |
| intervention-hierarchy.md | 11K | 4 |
| out-of-scope-topics.md | 5.8K | 2 |
| exam-guide-reference.md | 9.2K | 3 |

**Total:** 79.2K, ~32 pages (printable as study pack)

---

## How to Use These Materials

### Option 1: Comprehensive Study (4 weeks)
Follow the "Study Plan by Week" above. Read in order, practice scenarios.

### Option 2: Rapid Review (1 week)
- Day 1: Read domain-weights, 20-things, exam-guide
- Day 2: Study stop-reason, escalation, tool-choice
- Day 3: Study error-response, claude-md, batch-vs-sync
- Day 4: Study intervention-hierarchy, built-in-tools, scenario-mapping
- Day 5: Practice exam, drill weak areas
- Day 6-7: Memorize 20 concepts, sleep well

### Option 3: Quick Brush-Up (Before Exam)
- Print 20-things-to-know-cold.md
- Print domain-weights.md
- Print scenario-domain-mapping.md
- Review these morning of exam

---

## Tips for Test Day

### Before You Start
- Have cheat sheets visible (if allowed during review)
- Mentally review: domain weights, 20 concepts, scenarios

### During the Exam
- When you see a scenario, check `scenario-domain-mapping.md` first
- When deciding on a tool/API choice, use decision tables
- When unsure about escalation, check `escalation-flowchart.md`
- When designing error handling, use `error-response-checklist.md`

### Budget Your Time
- 90 minutes for 50-60 questions = ~1.5 minutes per question
- Scenario questions: ~3 minutes (longer context)
- Concept questions: ~1 minute each
- Review: 10 minutes at end

---

## Supplementary Resources

These cheat sheets complement the official materials:
- **Official:** Anthropic Certified Architect Exam Guide (PDF)
- **Official:** Claude API documentation
- **Official:** MCP specification
- **Official:** Best practices guides

**These cheat sheets are:** Study aids and quick references. Use them alongside official materials.

---

## Frequently Asked Questions

**Q: Can I use these during the exam?**
A: Exam rules vary. Check your exam platform. These are optimized for review if allowed, or pre-exam study.

**Q: Which one should I read first?**
A: Start with `domain-weights.md`, then `20-things-to-know-cold.md`, then `exam-guide-reference.md`.

**Q: I don't have time for all of them. Which are essential?**
A: Core essentials are:
1. domain-weights.md
2. 20-things-to-know-cold.md
3. stop-reason-flow.md
4. escalation-flowchart.md
5. scenario-domain-mapping.md

**Q: What if I'm weak on Domain X?**
A: Use `scenario-domain-mapping.md` to find scenarios that heavily test that domain. Focus there.

**Q: Are these updated with latest Claude API?**
A: These materials cover API and architecture patterns current as of March 2026. Always check official docs for latest.

---

## Credits & Context

These materials are created as downloadable study resources for the Claude Certified Architect Udemy course. They're based on:
- Official Anthropic Certified Architect Exam Guide
- Claude API documentation (March 2026)
- Exam scenario patterns
- Best practices from Claude architects

---

## Good Luck!

You've got this. Study smart, focus on Domain 1 (27%), master the 20 concepts, and practice the scenarios.

**Key to success:** Understanding WHEN to use each pattern, not memorizing syntax.

---

## Quick Reference Command

If you're studying on mobile, bookmark this file. Each cheat sheet is linked above and optimized for viewing on phone screens.
