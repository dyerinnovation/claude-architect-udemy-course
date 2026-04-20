# Demo: Claude Code for a Team Dev Workflow — Detailed Script

**Duration**: ~15 min | **Section**: 9 | **Demo**: 2

---

### [0:00] Introduction

- In this demo, we'll configure Claude Code for a team development workflow that scales consistent behavior across multiple contributors.
  - Layer a project-level `CLAUDE.md` with universal standards.
  - Scope `.claude/rules/` files with YAML frontmatter globs so API and test code each get their own rules.
  - Wire up a project skill with `context: fork` plus `allowed-tools`, and configure an MCP server with env-var expansion.
- This prepares you for Domain 3 (Claude Code configuration) and the MCP-configuration portion of Domain 2.

---

### [0:30] Deploy Demo Environment

<!-- Copy CLAUDE.md and .claude/ into a sample repo. Export GITHUB_TOKEN. Launch claude. Show the banner that confirms the project config was loaded. -->

---

### [2:00] Project-Level CLAUDE.md

<!-- Open CLAUDE.md. Highlight the standards block (testing conventions, style). Make a change in an arbitrary file and show Claude honoring the convention without being re-prompted. -->

---

### [4:30] Path-Scoped .claude/rules/ with Frontmatter Globs

<!-- Show two rule files: one with paths: ["src/api/**/*"], one with paths: ["**/*.test.*"]. Edit an API file — Claude loads the API rules. Edit a test file — Claude loads the testing rules. Verify the other rule set is NOT loaded. -->

---

### [7:00] Project Skill: context: fork and allowed-tools

<!-- Open .claude/skills/<skill>/SKILL.md. Show the frontmatter: context: fork, allowed-tools: [...]. Invoke the skill. Show that its subagent context is isolated — after the skill returns, the main conversation does not carry its intermediate tool calls. -->

---

### [9:30] MCP Server in .mcp.json with Env-Var Expansion

<!-- Show .mcp.json referencing ${GITHUB_TOKEN}. Restart claude so the server loads. Call a tool from the project server. Then open ~/.claude.json (user scope) and add a personal experimental server; show both are available in the same session. -->

---

### [12:00] Plan Mode vs Direct Execution

<!-- Three tasks: (1) single-file bug fix — direct execution; fast. (2) multi-file library migration — plan mode surfaces the migration plan for review first. (3) new feature with multiple valid approaches — plan mode lets the team pick an approach before writing code. -->

---

### [14:00] Optional: Supplementary CI Examples

<!-- If time allows, point at supplementary/ci-cd-pipeline/ and supplementary/ci-code-review/ as second-layer examples: using `claude -p --output-format json --json-schema` to drive CI-time code review. Do not live-demo. -->

---

### [14:30] Cleanup and Wrap

<!-- Remove CLAUDE.md and .claude/ from the sample repo. Recap the four knobs: hierarchy, path-scoped rules, skills with context/tools restrictions, MCP scope. -->
