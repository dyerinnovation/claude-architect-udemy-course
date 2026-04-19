# Quiz: Claude Code Configuration (Domain 3)

## Question 1
**Where do project-scoped slash commands live in Claude Code?**

- A) In ~/.claude/commands/ (user home directory)
- B) In .claude/commands/ at the project root
- C) In the .claude.json file at the project root
- D) In a global registry managed by Claude Code

**Correct Answer**: B

**Explanation**: Project-scoped slash commands are defined in .claude/commands/ directory at the project root. These commands are version-controlled and shared with all team members working on the project. User-scoped commands, by contrast, live in ~/.claude/commands/ in the user's home directory and are personal. This distinction allows teams to define project-specific workflows while individuals maintain personal productivity enhancements.

**Domain**: Domain 3 - Claude Code Configuration

---

## Question 2
**What is the purpose of the context: fork instruction in Claude Code?**

- A) To run commands in parallel branches
- B) To create a separate git branch
- C) To isolate verbose tool output and prevent it from cluttering the agent's context window
- D) To spawn a new Claude session

**Correct Answer**: C

**Explanation**: The "context: fork" instruction in Claude Code skill frontmatter tells Claude to run that block in a separate execution context. This is useful for operations that generate verbose output (like full test suites or large log files) that would consume many tokens if included in the main context. The results are processed, but the detailed output stays isolated, preserving tokens for the main task.

**Domain**: Domain 3 - Claude Code Configuration

---

## Question 3
**When should you use Plan mode versus direct execution in Claude Code?**

- A) Always use Plan mode; it's safer and more predictable
- B) Always use direct execution; Plan mode adds unnecessary delays
- C) Use Plan mode for complex, risky, or exploratory tasks; use direct execution for straightforward, well-understood tasks
- D) The choice depends on your mood and time availability

**Correct Answer**: C

**Explanation**: Plan mode asks Claude to outline its approach before executing, which is valuable for complex tasks (refactoring large codebases, destructive operations, multi-step workflows) where a misstep is costly. Direct execution is appropriate for straightforward tasks (renaming a file, running a single test, viewing code) where the path is clear and consequences are minimal. Plan mode adds latency but reduces risk; weigh accordingly.

**Domain**: Domain 3 - Claude Code Configuration

---

## Question 4
**How do Claude Code rules work, and where are they stored?**

- A) Rules are regex patterns stored in .claude/rules.txt
- B) Rules are YAML with frontmatter paths stored in .claude/rules/ directory files
- C) Rules are defined in .claude.json as a rules array
- D) Rules are managed through the Claude Code GUI and cannot be version-controlled

**Correct Answer**: B

**Explanation**: Rules in Claude Code are stored as separate files in the .claude/rules/ directory, each with YAML frontmatter that includes a path pattern (which files/paths the rule applies to) and the rule content. This structure allows granular, file-specific configuration—you can have different rules for different parts of your project. Rules are version-controlled and shared with the team.

**Domain**: Domain 3 - Claude Code Configuration

---

## Question 5
**What is the purpose of the -p flag when running Claude Code in CI/CD?**

- A) To enable parallel execution of multiple tasks
- B) To indicate project mode; required for non-interactive environments
- C) To set the project path explicitly
- D) To purge cache before running

**Correct Answer**: B

**Explanation**: The -p (or --project) flag is required when running Claude Code in CI/CD pipelines or other non-interactive environments. It tells Claude Code to operate in project mode, respecting .claude/ configuration files and understanding the project context. Without -p in a CI/CD environment, Claude Code may not properly load configuration or understand the project structure.

**Domain**: Domain 3 - Claude Code Configuration

---

## Question 6
**How does the CLAUDE.md hierarchy work in Claude Code?**

- A) Only one CLAUDE.md file exists; it's ignored if no rules are defined
- B) CLAUDE.md files at different levels (user, project, directory) are merged, with more specific levels overriding broader ones
- C) Each CLAUDE.md applies only to its directory; there is no inheritance
- D) CLAUDE.md files are not supported in modern Claude Code versions

**Correct Answer**: B

**Explanation**: Claude Code supports CLAUDE.md files at multiple levels: user-level (~/.CLAUDE.md), project-level (.CLAUDE.md at project root), and directory-level (CLAUDE.md in subdirectories). These are merged hierarchically, with more specific contexts overriding broader ones. This allows global conventions, project-specific standards, and directory-specific guidance to coexist without conflict.

**Domain**: Domain 3 - Claude Code Configuration

---

## Question 7
**What should and should not be shared via version control when using Claude Code?**

- A) Share .claude/rules/ and CLAUDE.md (team standards); don't share ~/.claude/ (personal configuration)
- B) Share everything in .claude/ directory; don't share any CLAUDE.md files
- C) Don't version control any Claude Code files; they're all personal
- D) Share all files; there is no distinction between personal and shared configuration

**Correct Answer**: A

**Explanation**: Version-control your project-scoped configuration (.claude/rules/, .claude/commands/, project CLAUDE.md) to ensure team consistency. Don't version-control user-scoped configuration (~/.claude/, personal CLAUDE.md, personal API keys). This keeps shared team standards in git while respecting individual developer workflows and protecting personal credentials.

**Domain**: Domain 3 - Claude Code Configuration

---

## Question 8
**What is the primary purpose of the /memory command in Claude Code?**

- A) To cache tool results for faster retrieval
- B) To store and retrieve conversation history across sessions
- C) To save important context or decisions for future reference within a session
- D) To optimize RAM usage during long-running tasks

**Correct Answer**: C

**Explanation**: The /memory command allows you to explicitly save important information (key decisions, context, findings) that you want to reference later in the same session. This is useful for long, complex sessions where you need to maintain continuity or refer back to earlier conclusions. It's not persistent across sessions (that would be conversation history) but rather a way to manage context within a session.

**Domain**: Domain 3 - Claude Code Configuration
