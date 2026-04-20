# Demo: Claude Code for a Team Dev Workflow

**Section**: 9 | **Duration**: ~15 min | **Demo**: 2

---

## Overview

This demo configures Claude Code for a multi-developer project: a project-level `CLAUDE.md`, path-scoped `.claude/rules/` files with YAML frontmatter glob patterns, a project-scoped skill with `context: fork` and `allowed-tools` restrictions, and an MCP server configured via `.mcp.json` with environment-variable expansion. You will also compare plan mode with direct execution on tasks of different complexity.

## Learning Objectives

By the end of this demo, you will be able to:

- Author a project-level `CLAUDE.md` that enforces universal coding and testing conventions across team members.
- Create `.claude/rules/` files whose YAML frontmatter `paths:` globs scope them to specific code areas.
- Build a project skill in `.claude/skills/` using `context: fork` and `allowed-tools` to isolate its execution.
- Configure an MCP server in `.mcp.json` with `${ENV_VAR}` expansion, and layer a personal server from `~/.claude.json`.
- Choose between plan mode and direct execution based on task complexity (single-file fix vs. multi-file migration vs. new feature).

## Claude Surfaces Used

- **Claude Code** — `CLAUDE.md` hierarchy (user / project / directory), `.claude/rules/` with frontmatter glob scoping, `.claude/skills/` with `context: fork`, plan mode vs direct execution, `/memory`, `/compact`.
- **MCP** — `.mcp.json` project config with env-var expansion; `~/.claude.json` user config for personal experimental servers.

## Domains Reinforced

| Domain | % | How this demo tests it |
|---|---|---|
| Domain 3: Claude Code Configuration & Workflows | 22% | `CLAUDE.md` hierarchy, `.claude/rules/` with path globs, project skills, plan-mode decisions. |
| Domain 2: Tool Design & MCP Integration | 20% | `.mcp.json` project scope + `~/.claude.json` user scope, env-var expansion for credentials. |

## Quick Start

### Deploy

```bash
cd demo-2-claude-code-team-workflow-infrastructure-build-scripts
# CLAUDE.md and .claude/ scaffolding live here; copy into a sample repo:
cp -R CLAUDE.md .claude /path/to/sample-repo/
cd /path/to/sample-repo
export GITHUB_TOKEN=...   # consumed by .mcp.json env expansion
claude
```

### Record

Follow `demo-2-claude-code-team-workflow-recording-script.md` for timestamped narration. `supplementary/` contains two secondary examples (`ci-cd-pipeline/`, `ci-code-review/`) that can be shown in the CI section if time allows.

### Cleanup

```bash
rm -rf /path/to/sample-repo/.claude /path/to/sample-repo/CLAUDE.md
unset GITHUB_TOKEN
```

## Additional Resources

- Anthropic Exam Guide, *Preparation Exercises* - Exercise 2.
- Anthropic Exam Guide, *Technologies and Concepts* - Claude Code section (CLAUDE.md hierarchy, `.claude/rules/`, `.claude/commands/`, `.claude/skills/` with frontmatter).
- Claude Code docs - CLAUDE.md, skills, MCP configuration.
- Supplementary examples: `supplementary/ci-cd-pipeline/` and `supplementary/ci-code-review/`.
