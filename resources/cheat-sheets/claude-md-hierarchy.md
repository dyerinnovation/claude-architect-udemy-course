# CLAUDE.md Hierarchy & .claude/ Organization

## The Three-Level Hierarchy

### Level 1: Shared Rules (Highest Priority)
**File:** `.claude/rules/shared.md` or root `CLAUDE.md`

**What:** Organization-wide, project-level instructions

**Applies To:** All Claude usage in the project

**Example:**
```markdown
# Shared Rules

- All code must pass linting with eslint
- Never delete production databases
- Security review required for user data access
```

**When Used:** Every session reads these first

---

### Level 2: Path-Specific Rules (Middle Priority)
**File:** `.claude/rules/<glob-pattern>.md`

**What:** Rules that apply only to specific file paths

**Examples:**
- `.claude/rules/src/auth/*.md` → Only for authentication code
- `.claude/rules/**/*.test.ts.md` → Only for test files
- `.claude/rules/database/*.md` → Only for database modules

**Applied By:** Glob pattern matching (left-to-right, first match wins)

**Example:**
```yaml
# .claude/rules/src/auth/*.md
- Require 2FA for all auth routes
- Log all authentication attempts
- Never hardcode secrets
```

**When Used:** When modifying matching files

---

### Level 3: Personal/Session Rules (Lowest Priority)
**File:** User's local `.claude/rules/personal.md`

**What:** Developer-specific preferences (overrides shared/path rules)

**Applies To:** Personal development workflow only

**Example:**
```markdown
# Personal Rules

- I prefer async/await over promises
- Use TypeScript strict mode
- My company uses Prettier with 120 char lines
```

**When Used:** Personal development, not in CI/shared repos

---

## Priority Order (Top to Bottom)

```
1. Most Specific Path Rule (.claude/rules/src/auth/oauth.md)
2. General Path Rules (.claude/rules/src/*.md)
3. Shared Rules (.claude/rules/shared.md)
4. Personal Rules (~/.claude/rules/personal.md)
```

**Conflict Resolution:** First matching rule wins (most specific takes precedence)

---

## Glob Pattern Syntax

```bash
*.test.ts          # All test files in current directory
src/**/*.test.ts   # All test files under src/
src/auth/*         # All files directly in auth directory
src/auth/**        # All files in auth and subdirectories
```

---

## @import Syntax

**Link rules between files to avoid duplication:**

```markdown
# .claude/rules/shared.md

## Core Standards
@import .claude/rules/security.md
@import .claude/rules/performance.md

## Testing
@import .claude/rules/testing.md
```

**Usage:**
- Keep shared.md clean by importing specialized rule sets
- Organize by concern (security, performance, testing)
- @import can appear anywhere in markdown

---

## /memory Command

**Store information across sessions:**

```
/memory add "Project uses Stripe API v3, keys in .env"
/memory list
/memory clear
```

**Difference from CLAUDE.md:**
- `.claude/` rules are for behavior/standards
- `/memory` is for facts about THIS project (APIs, passwords, etc.)
- Memory is session-specific; rules are persistent

---

## Practical Example: Full Project Setup

```
.claude/
├── rules/
│   ├── shared.md              # "All code must be TypeScript"
│   ├── src/
│   │   ├── auth/*.md          # "Require 2FA checks"
│   │   └── database/*.md      # "Log all queries"
│   ├── security.md            # Imported by shared.md
│   ├── performance.md         # Imported by shared.md
│   └── testing.md             # Imported by shared.md
└── config.yaml                # Claude Code configuration
```

---

## Key Points to Remember

| Aspect | Detail |
|--------|--------|
| **Location** | `.claude/rules/` in project root |
| **Scope** | Shared rules apply project-wide; path rules use glob matching |
| **Priority** | Most specific path rule > general rules > shared > personal |
| **Syntax** | Markdown; glob patterns; @import for linking |
| **Persistence** | Persistent across sessions (unlike /memory) |
| **Version Control** | Commit to repo for team alignment |

---

## Common Patterns

### Pattern 1: Security-Critical Rules
```markdown
# .claude/rules/database/*.md
- All queries require parameterization
- Never SELECT * in production
- Audit log required for DELETE/UPDATE
```

### Pattern 2: Testing Requirements
```markdown
# .claude/rules/**/*.test.ts.md
- Minimum 80% coverage required
- No .skip() allowed in main branch
- Mock external APIs
```

### Pattern 3: Code Style Path Rules
```markdown
# .claude/rules/src/ui/*.md
- Use React hooks only (no class components)
- Props must be typed with TypeScript
```
