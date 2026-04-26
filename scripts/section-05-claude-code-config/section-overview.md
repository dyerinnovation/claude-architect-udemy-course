# Section 4: Domain 3 — Claude Code Configuration & Workflows (20%)

## Overview
- **Domain**: Domain 3: Claude Code Configuration & Workflows
- **Exam Weight**: 20%
- **Lecture Count**: 15 lectures
- **Estimated Duration**: ~2.5 hours

## Learning Objectives

By the end of this section, students will be able to:
- Configure the CLAUDE.md hierarchy (user, project, directory) and decide what should and shouldn't be checked into version control.
- Implement modular configuration with `@import`, `.claude/rules/` topic files, and YAML frontmatter glob patterns for path-specific rules.
- Author project- and user-scoped slash commands, skills, and SKILL.md frontmatter (`context: fork`, `allowed-tools`, `argument-hint`) that isolate execution and limit blast radius.
- Distinguish plan mode from direct execution and apply iterative refinement techniques (examples, TDD, interview pattern) to multi-step workflows.
- Integrate Claude Code into CI/CD using `-p`, `--output-format json`, and `--json-schema`, and manage long sessions with `/memory` and `/compact`.

## Lectures

| # | Title | Duration | Status |
|---|-------|----------|--------|
| 4.1 | The CLAUDE.md Configuration Hierarchy (user / project / directory) | ~8 min | Todo |
| 4.2 | What Gets Shared via Version Control and What Doesn't | ~8 min | Todo |
| 4.3 | The `@import` Syntax for Modular CLAUDE.md | ~8 min | Todo |
| 4.4 | `.claude/rules/` — Topic-Specific Rule Files | ~8 min | Todo |
| 4.5 | Path-Specific Rules with YAML Frontmatter Glob Patterns | ~8 min | Todo |
| 4.6 | Custom Slash Commands: `.claude/commands/` vs `~/.claude/commands/` | ~8 min | Todo |
| 4.7 | Skills in `.claude/skills/`: SKILL.md Frontmatter Deep Dive | ~8 min | Todo |
| 4.8 | `context: fork` — Isolating Skill Execution | ~8 min | Todo |
| 4.9 | `allowed-tools` and `argument-hint` Frontmatter Options | ~8 min | Todo |
| 4.10 | Plan Mode vs Direct Execution — Decision Framework | ~8 min | Todo |
| 4.11 | The Explore Subagent for Verbose Discovery Phases | ~8 min | Todo |
| 4.12 | Iterative Refinement Techniques (examples, TDD, interview pattern) | ~8 min | Todo |
| 4.13 | CI/CD Integration: `-p` Flag, `--output-format json`, `--json-schema` | ~8 min | Todo |
| 4.14 | Session Context Isolation for Independent Code Review | ~8 min | Todo |
| 4.15 | The `/memory` and `/compact` Commands | ~8 min | Todo |

## Quiz

Section quiz: `quizzes/section-04-claude-code-config.md` (10 questions)
