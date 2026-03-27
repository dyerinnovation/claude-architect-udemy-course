# Scenario Lab: Team Workflow Configuration

## Overview

In this lab, you will configure Claude Code for a team development workflow. You will create project-level configuration files, define scoped rules for specific file patterns, build a custom slash command for code review, integrate MCP servers, and create a skill that enforces team conventions. This lab teaches how to scale Claude's capabilities to support a whole development team with consistent, auditable behavior.

**Key Architecture Pattern:** Configuration management, scoped rules, custom commands, skill-based automation, MCP integration.

---

## Learning Objectives

By completing this lab, you will demonstrate the ability to:

1. **Create a project-level CLAUDE.md** that establishes testing conventions and context for the entire team
2. **Define scoped .claude/rules/ files** with glob patterns to apply rules only to test files
3. **Build a custom /review slash command** that performs structured code review based on team standards
4. **Implement a skill with context** that uses fork and allowed-tools restrictions
5. **Integrate MCP servers** to extend Claude Code with external capabilities
6. **Design team workflows** that are repeatable, auditable, and scale across contributors

**Exam Connections:** Domain 3 (Configuration & Team Workflows)

---

## Prerequisites

### Tools & APIs
- **Claude Code** CLI installed (latest version)
- **Git** repository (local or GitHub)
- **Node.js/npm** or **Python 3.8+** (for test framework examples)
- **MCP SDK** (for custom MCP server; optional)

### Knowledge
- Basic understanding of Claude Code configuration from course Module 3
- Familiarity with glob patterns and file structure conventions
- Understanding of code review best practices

### Setup
```bash
# Install Claude Code (if not already installed)
# Follow: https://claude.com/claude-code

# Create a new project directory
mkdir team-workflow-demo
cd team-workflow-demo

# Initialize git
git init

# Set API key
export CLAUDE_API_KEY="your-key-here"
```

---

## Step-by-Step Instructions

### Step 1: Create Project-Level CLAUDE.md

Create a file `/CLAUDE.md` at the project root that defines testing conventions and team context.

**File: `/CLAUDE.md`**

```markdown
# Team Development Workflow Configuration

This document configures Claude Code for team collaboration on this project.

## Project Overview

- **Language:** TypeScript/JavaScript
- **Framework:** React + Node.js
- **Test Framework:** Vitest + React Testing Library
- **Code Style:** ESLint + Prettier (configured in .eslintrc.js and .prettierrc)

## Testing Conventions

### All tests must follow these standards:

#### 1. Test File Location
- Test files must be colocated with source files
- Naming convention: `<component-name>.test.tsx` (React components) or `<module-name>.test.ts` (utilities)
- Do NOT create separate `/tests` directories; keep tests next to implementation

#### 2. Test Structure
Every test file must include:
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
// followed by imports under test

describe('ComponentName or FunctionName', () => {
  // Setup
  beforeEach(() => {
    // Clear mocks, initialize state
  });

  // Tests
  it('should [expected behavior]', () => {
    // Arrange
    // Act
    // Assert
  });

  // Cleanup
  afterEach(() => {
    // Cleanup
  });
});
```

#### 3. Test Naming
- Use descriptive names: "should validate email format" not "test1"
- Each `it()` block tests ONE behavior
- Avoid negatives: "should return error when password is too short" not "shouldn't accept short password"

#### 4. Coverage Expectations
- Functions: >=80% code coverage
- Components: >=75% coverage (UI interactions are harder to test)
- Critical paths: 100% coverage required

#### 5. Mock Strategy
- Mock external APIs (fetch, database, third-party libraries)
- Mock at the service layer, not the UI layer
- Use `vi.mock()` for module-level mocks
- Use `vi.spyOn()` for instance methods

#### 6. Async Testing
- Use `async/await` in test functions
- For promises: `expect(promise).resolves.toEqual(...)` or `rejects.toThrow(...)`
- Use `waitFor()` for async state updates in React components

### Example Test File

**File: `src/components/LoginForm.test.tsx`**

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should render email and password inputs', () => {
    render(<LoginForm />);
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
  });

  it('should show validation error for invalid email', async () => {
    render(<LoginForm />);
    const emailInput = screen.getByLabelText(/email/i);

    fireEvent.change(emailInput, { target: { value: 'not-an-email' } });
    fireEvent.click(screen.getByRole('button', { name: /submit/i }));

    await waitFor(() => {
      expect(screen.getByText(/invalid email/i)).toBeInTheDocument();
    });
  });

  it('should submit form with valid credentials', async () => {
    const mockOnSubmit = vi.fn();
    render(<LoginForm onSubmit={mockOnSubmit} />);

    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'test@example.com' }
    });
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: 'password123' }
    });
    fireEvent.click(screen.getByRole('button', { name: /submit/i }));

    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123'
      });
    });
  });
});
```

## Code Review Standards

When using the `/review` command, Claude will:

1. Check for adherence to testing conventions above
2. Identify security issues (hardcoded secrets, unsafe DOM operations)
3. Verify proper error handling
4. Suggest performance optimizations
5. Ensure code style consistency with Prettier

Priority levels:
- **CRITICAL:** Security risk, test failures, undefined behavior
- **HIGH:** Missing tests, poor performance, breaking changes
- **MEDIUM:** Code style, naming clarity
- **LOW:** Documentation, refactoring suggestions

## Tools Configuration

The following tools are available for team use:

- `git-operations`: Commit, push, create branches
- `file-operations`: Read, write, search within project
- `code-generation`: Generate tests, components, utilities
- `node-execution`: Run npm scripts (tests, builds, linting)

## Team Workflows

### Workflow 1: Writing a New Feature
1. Create feature branch: `git checkout -b feature/description`
2. Create component/module file
3. **Immediately** create a test file alongside the implementation
4. Run `/review` on the test file for review
5. Implement feature to pass tests
6. Run `/review` on implementation
7. Commit with clear message
8. Push and create PR

### Workflow 2: Fixing a Bug
1. Create bug branch: `git checkout -b fix/description`
2. Write a test that reproduces the bug (should fail initially)
3. Fix the implementation
4. Verify test passes
5. Run `/review` for any regressions
6. Commit, push, create PR

### Workflow 3: Code Review Session
1. Run `/review <file-path>` to analyze code against team standards
2. Claude will generate a report with findings
3. Address critical and high-priority issues
4. Re-run `/review` to verify fixes

## Customization

Team leads can modify this file to:
- Add project-specific conventions
- Update tool availability
- Adjust coverage thresholds
- Change code review criteria

---

**Last Updated:** 2024-03-26
**Team Lead:** [Your Name]
```

**Task:** Read the CLAUDE.md file and identify:
1. What test naming convention is required? ("should [expected behavior]")
2. What is the minimum code coverage for functions? (80%)
3. What tool is used for mocking? (vi.mock() or vi.spyOn())

---

### Step 2: Create Scoped Rules for Test Files

Create a `.claude/rules/` directory with rule files that apply only to test files.

**File: `.claude/rules/test-standards.md`**

```markdown
# Test File Standards (Applies to: **/*.test.ts, **/*.test.tsx)

## This rule file applies ONLY to files matching: **/*.test.ts or **/*.test.tsx

You are reviewing test code. Use the following standards:

### Required Structure
Every test file MUST have:
- [x] Import statement: `import { describe, it, expect } from 'vitest';`
- [x] At least one `describe()` block
- [x] At least one `it()` block per function/component tested
- [x] Descriptive test names (e.g., "should return true when input is valid")

### Test Quality Checklist
- [ ] Each test has exactly ONE assertion OR multiple related assertions (Arrange-Act-Assert pattern)
- [ ] Async tests use `async/await` or `waitFor()`
- [ ] Mocks are cleared between tests (`beforeEach()`)
- [ ] No hardcoded data; use fixtures or factories
- [ ] Edge cases are tested (empty inputs, null values, error states)
- [ ] UI tests query by accessible selectors (role, label, test-id, NOT class/id)

### Red Flags (Report as Critical)
- ❌ Test file with NO test blocks
- ❌ Test that spans 50+ lines (too broad)
- ❌ Queries by CSS class: `screen.getByClassName()`
- ❌ Hardcoded sleeps: `await new Promise(r => setTimeout(r, 1000))`
- ❌ No cleanup in `afterEach()`

### Missing Coverage
- Check for 100% coverage of happy path
- Check for at least one error case test
- Flag if common edge cases are untested

### Example Review Comment
```
ISSUE [MEDIUM]: Test name is vague
Location: LoginForm.test.tsx:15
Current: it('should work', () => {...})
Suggested: it('should validate email format and show error message', () => {...})
Reason: Descriptive names make test intent clear
```

## Notes for Claude Code

When reviewing test files:
1. Run `npm test -- <file>` to verify tests pass
2. Check test coverage with `npm test -- --coverage <file>`
3. If imports fail, suggest running `npm install`
4. For async tests, verify they complete (don't use done() callback with modern Vitest)
```

**File: `.claude/rules/implementation-standards.md`**

```markdown
# Implementation File Standards (Applies to: src/**/*.ts, src/**/*.tsx)

## This rule file applies ONLY to source files (NOT tests)

You are reviewing implementation code. Use the following standards:

### Code Quality
- [ ] No console.log() statements (use logger service)
- [ ] No hardcoded API URLs (use environment variables)
- [ ] No secrets in code (API keys, tokens, credentials)
- [ ] Error handling present: try/catch or .catch() for async code
- [ ] Types are explicit (TypeScript): no `any` types

### Security Issues (Report as Critical)
- ❌ Hardcoded credentials or API keys
- ❌ Direct innerHTML/dangerouslySetInnerHTML on user input
- ❌ Missing input validation
- ❌ Unescaped SQL or NoSQL queries
- ❌ Missing authentication checks

### Performance (Report as High)
- [ ] No unnecessary re-renders in React (check useCallback, useMemo usage)
- [ ] No N+1 queries (batch API calls)
- [ ] No large objects in state that don't need to be reactive
- [ ] Images have explicit width/height or aspect ratio

### Style & Consistency
- Verify Prettier formatting: `npx prettier --check <file>`
- Verify ESLint: `npx eslint <file>`
- Follow project naming conventions

---

When reviewing implementation:
1. Always cross-reference with corresponding test file
2. If tests exist, ensure implementation satisfies all test cases
3. Flag if implementation exists but NO test file exists (MEDIUM priority)
```

**Task:** Create these two rule files in `.claude/rules/` and verify they exist:
```bash
mkdir -p .claude/rules
# Create the two files with the content above
ls -la .claude/rules/
```

---

### Step 3: Build a Custom /review Slash Command

Create a skill that implements the `/review` slash command for structured code review.

**File: `.claude/skills/code-review.md`**

```markdown
# /review Command Skill

This skill implements a comprehensive code review command.

## Invocation

```
/review <file-path>
```

Examples:
- `/review src/components/Button.tsx`
- `/review src/utils/validation.test.ts`
- `/review src/api/user-service.ts`

## Behavior

When invoked, Claude will:

1. **Load the file** and read its full contents
2. **Detect file type** (test vs. implementation)
3. **Apply appropriate rules** from `.claude/rules/`
4. **Execute checks:**
   - Run `npx eslint <file>` to catch linting errors
   - Run `npx prettier --check <file>` to check formatting
   - If test file: run `npm test -- <file>` to verify tests pass
   - If test file: run `npm test -- --coverage <file>` to check coverage
5. **Generate structured report** with findings

## Output Format

The `/review` command outputs a structured report:

```
# Code Review Report: <filename>

## Overview
- File Type: [Test / Implementation]
- Language: [TypeScript / JavaScript]
- Lines of Code: [count]
- Complexity: [Low / Medium / High]

## Automated Checks
- [✓/✗] ESLint: [N issues found / All clear]
- [✓/✗] Prettier: [Needs formatting / Formatted correctly]
- [✓/✗] Tests: [All pass / Failures: ...]
- [✓/✗] Coverage: [X% / Target: Y%]

## Standards Compliance

### Critical Issues
[List all critical findings that must be fixed]

### High Priority
[List high-priority findings]

### Medium Priority
[List medium-priority findings]

### Low Priority
[List low-priority findings]

## Recommendations

[Specific, actionable suggestions for improvement]

## Next Steps
1. [Action 1]
2. [Action 2]
3. [Action 3]

---
Reviewed at: [timestamp]
Reviewer: Claude Code Review Agent
```

## Implementation Notes

This skill requires:
- **fork: true** — Can execute shell commands (eslint, prettier, npm test)
- **allowed-tools:** ["node-execution", "file-operations", "git-operations"]
- **context:** Loads project's CLAUDE.md and .claude/rules/ files

## Example Review Session

**Command:**
```
/review src/components/LoginForm.test.tsx
```

**Output:**
```
# Code Review Report: src/components/LoginForm.test.tsx

## Overview
- File Type: Test
- Language: TypeScript
- Lines of Code: 87
- Complexity: Medium

## Automated Checks
- [✓] ESLint: All clear
- [✓] Prettier: Formatted correctly
- [✓] Tests: All pass (5/5)
- [✓] Coverage: 92% (Target: >=75%)

## Standards Compliance

### Critical Issues
None

### High Priority
None

### Medium Priority
1. **Test method: "should work" is vague**
   - Location: Line 34
   - Issue: Test name doesn't describe what is being tested
   - Suggestion: "should validate email and show error message"

### Low Priority
1. **Missing edge case: empty password**
   - Consider adding test for empty password field
   - Reference: CLAUDE.md - Edge cases must be tested

## Recommendations

1. Rename test on line 34 to be more descriptive
2. Consider adding test for empty password scenario
3. Add test for successful form submission with network error

## Next Steps
1. Update test name on line 34
2. Add edge case test
3. Re-run `/review` to verify improvements

---
Reviewed at: 2024-03-26T14:30:00Z
Reviewer: Claude Code Review Agent
```
```

**Task:** Design the command invocation syntax. Should `/review` accept multiple files at once? What about `/review --strict` for higher standards?

---

### Step 4: Implement a Skill with Context and Restrictions

Create a skill that generates test boilerplate with enforced conventions.

**File: `.claude/skills/generate-test.md`**

```markdown
# /generate-test Command Skill

This skill generates test files following team conventions.

## Invocation

```
/generate-test <source-file-path> [--minimal]
```

Examples:
- `/generate-test src/components/Button.tsx`
- `/generate-test src/utils/validation.ts --minimal`

## Behavior

When invoked, Claude will:

1. **Read the source file** to understand the component/function interface
2. **Analyze the CLAUDE.md** testing conventions
3. **Generate a test file** colocated with the source (e.g., `Button.tsx` → `Button.test.tsx`)
4. **Include:**
   - Standard imports (vitest, testing-library for React)
   - Describe block with component/function name
   - Happy path test
   - Error/edge case tests
   - Mock setup if needed
5. **Write the file** to disk

## Context

This skill has access to:
- **CLAUDE.md** — Team testing standards
- **.claude/rules/test-standards.md** — Test quality rules
- **package.json** — Project dependencies and test script

## Allowed Tools

This skill is restricted to:
- `file-operations` — Read source files, write test files
- `code-generation` — Generate test code
- NOT allowed: `git-operations`, `node-execution`

## Restrictions

- **fork: false** — Does NOT execute shell commands (safe to run)
- **read-only:** false — Can create files
- **write-only:** Restricted to `*.test.ts`, `*.test.tsx` files

## Example: Generate Test for Button Component

**Command:**
```
/generate-test src/components/Button.tsx
```

**Source File: src/components/Button.tsx**
```typescript
interface ButtonProps {
  label: string;
  onClick?: () => void;
  disabled?: boolean;
  variant?: 'primary' | 'secondary';
}

export function Button({
  label,
  onClick,
  disabled = false,
  variant = 'primary'
}: ButtonProps) {
  return (
    <button
      className={`btn btn-${variant}`}
      onClick={onClick}
      disabled={disabled}
    >
      {label}
    </button>
  );
}
```

**Generated File: src/components/Button.test.tsx**
```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should render button with label', () => {
    render(<Button label="Click me" />);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('should call onClick handler when clicked', () => {
    const mockClick = vi.fn();
    render(<Button label="Click me" onClick={mockClick} />);

    fireEvent.click(screen.getByRole('button', { name: /click me/i }));
    expect(mockClick).toHaveBeenCalledOnce();
  });

  it('should be disabled when disabled prop is true', () => {
    render(<Button label="Click me" disabled={true} />);
    expect(screen.getByRole('button', { name: /click me/i })).toBeDisabled();
  });

  it('should apply variant class based on variant prop', () => {
    const { container } = render(<Button label="Click me" variant="secondary" />);
    expect(container.querySelector('.btn-secondary')).toBeInTheDocument();
  });

  it('should apply primary variant by default', () => {
    const { container } = render(<Button label="Click me" />);
    expect(container.querySelector('.btn-primary')).toBeInTheDocument();
  });

  it('should not call onClick when disabled', () => {
    const mockClick = vi.fn();
    render(<Button label="Click me" onClick={mockClick} disabled={true} />);

    fireEvent.click(screen.getByRole('button', { name: /click me/i }));
    expect(mockClick).not.toHaveBeenCalled();
  });
});
```

**Report:**
```
Generated: src/components/Button.test.tsx

✓ Test file follows team conventions
✓ Covers all props (label, onClick, disabled, variant)
✓ Tests happy path and edge cases
✓ Uses proper mocking (vi.fn())
✓ 80% code coverage expected

Next: Run `/review src/components/Button.test.tsx` to validate
```

## Variations

### Minimal Mode
```
/generate-test src/utils/math.ts --minimal
```
Generates only happy path test without edge cases (faster, for simple utilities).

### With Fixtures
```
/generate-test src/api/user-service.ts --with-fixtures
```
Generates test with mock data fixtures for complex objects.
```

**Task:** What would you add to the "allowed-tools" list if you wanted the skill to also run the generated tests? (Answer: Add `"node-execution"` to run `npm test`.)

---

### Step 5: Configure MCP Server Integration

Create configuration for integrating an MCP server (Mock example: GitHub integration).

**File: `.claude/mcp-config.json`**

```json
{
  "name": "Team Workflow MCP Configuration",
  "version": "1.0",
  "description": "MCP servers for team collaboration",
  "servers": [
    {
      "name": "github-integration",
      "type": "stdio",
      "command": "node",
      "args": ["./mcp-servers/github-server.js"],
      "enabled": true,
      "description": "GitHub PR and issue integration",
      "tools": [
        {
          "name": "create_pr",
          "description": "Create a pull request on GitHub",
          "inputSchema": {
            "type": "object",
            "properties": {
              "title": { "type": "string" },
              "description": { "type": "string" },
              "base_branch": { "type": "string" },
              "head_branch": { "type": "string" }
            },
            "required": ["title", "base_branch", "head_branch"]
          }
        },
        {
          "name": "list_pr_reviews",
          "description": "List pending pull request reviews",
          "inputSchema": {
            "type": "object",
            "properties": {
              "status": { "type": "string", "enum": ["open", "draft", "merged"] }
            }
          }
        }
      ]
    },
    {
      "name": "slack-notifications",
      "type": "stdio",
      "command": "node",
      "args": ["./mcp-servers/slack-server.js"],
      "enabled": false,
      "description": "Slack notifications for code reviews and deployments",
      "tools": [
        {
          "name": "send_message",
          "description": "Send a message to a Slack channel",
          "inputSchema": {
            "type": "object",
            "properties": {
              "channel": { "type": "string" },
              "message": { "type": "string" }
            },
            "required": ["channel", "message"]
          }
        }
      ]
    }
  ],
  "authentication": {
    "github": {
      "token_env": "GITHUB_TOKEN",
      "scopes": ["repo:read", "repo:write"]
    },
    "slack": {
      "token_env": "SLACK_BOT_TOKEN",
      "scopes": ["chat:write", "users:read"]
    }
  },
  "team_context": {
    "github_org": "your-org",
    "github_repo": "your-repo",
    "slack_workspace": "your-workspace",
    "default_channel": "engineering"
  }
}
```

**File: `mcp-servers/github-server.js` (Stub)**

```javascript
/**
 * MCP Server: GitHub Integration
 *
 * Provides tools for interacting with GitHub (PRs, issues, reviews).
 * This is a stub implementation for the lab.
 */

const http = require('http');

class GitHubMCPServer {
  constructor() {
    this.tools = {
      'create_pr': this.createPR.bind(this),
      'list_pr_reviews': this.listPRReviews.bind(this)
    };
  }

  async createPR(input) {
    console.log('Creating PR:', input);
    // In a real implementation, this would call GitHub API
    // using input.title, input.description, etc.
    return {
      pr_url: 'https://github.com/your-org/your-repo/pull/123',
      pr_number: 123,
      status: 'created'
    };
  }

  async listPRReviews(input) {
    console.log('Listing PR reviews with status:', input.status);
    // In a real implementation, this would query GitHub API
    return {
      reviews: [
        {
          pr_number: 120,
          title: 'Add authentication',
          reviewer_count: 2,
          status: 'pending_review'
        }
      ],
      total: 1
    };
  }

  async handleRequest(request) {
    const { tool, input } = JSON.parse(request);
    if (this.tools[tool]) {
      const result = await this.tools[tool](input);
      return result;
    }
    throw new Error(`Unknown tool: ${tool}`);
  }
}

const server = new GitHubMCPServer();
console.log('GitHub MCP Server started');

// In a real implementation, this would use stdio transport
process.stdin.on('data', async (data) => {
  try {
    const result = await server.handleRequest(data.toString());
    process.stdout.write(JSON.stringify(result));
  } catch (error) {
    process.stdout.write(JSON.stringify({ error: error.message }));
  }
});
```

**Task:** In the MCP config, what authentication information is required to enable the Slack integration? (Answer: `SLACK_BOT_TOKEN` environment variable with chat:write and users:read scopes.)

---

### Step 6: Create Team Workflow Documentation

Create a comprehensive guide for team members to use these configurations.

**File: `WORKFLOW.md`**

```markdown
# Team Development Workflow Guide

This guide explains how to use Claude Code with this project's configured tools and skills.

## Quick Start

1. **Install Claude Code** (if not already done)
   ```bash
   # Follow: https://claude.com/claude-code
   ```

2. **Set environment variables**
   ```bash
   export CLAUDE_API_KEY="your-api-key"
   export GITHUB_TOKEN="your-github-token"  # Optional, for MCP
   ```

3. **Verify setup**
   ```bash
   claude --version
   cd /path/to/this/project
   ```

## Available Commands

### 1. Code Review Command

Review any file against team standards:

```bash
claude /review src/components/Button.tsx
```

**When to use:**
- After writing a new component
- Before creating a PR
- To check for regressions in legacy code

**Output:** Structured report with critical, high, medium, and low priority findings.

### 2. Generate Test Command

Auto-generate test boilerplate:

```bash
claude /generate-test src/components/Button.tsx
```

**When to use:**
- Creating a new component (generate test first!)
- Writing utility functions

**Output:** Complete test file following team conventions, ready for you to fill in specific assertions.

### 3. Team Standards

Always follow **CLAUDE.md** in the project root:
- Test file naming: `*.test.ts` or `*.test.tsx`
- Test structure: describe/it blocks with Arrange-Act-Assert
- Coverage targets: 80% for functions, 75% for components

## Workflow: Creating a New Feature

### Step 1: Create Feature Branch
```bash
git checkout -b feature/user-authentication
```

### Step 2: Create Test First (TDD)
```bash
claude /generate-test src/pages/LoginPage.tsx --minimal
# Edit the generated test to define the behavior you want
```

### Step 3: Implement Feature
Write code to make tests pass.

### Step 4: Review Your Code
```bash
claude /review src/pages/LoginPage.tsx
claude /review src/pages/LoginPage.test.tsx
```

Address all CRITICAL and HIGH priority issues.

### Step 5: Run Full Test Suite
```bash
npm test
npm run lint
```

### Step 6: Commit and Push
```bash
git add .
git commit -m "feat: Add user authentication with login form

- Add LoginPage component with email/password validation
- Implement user session management
- Add comprehensive test coverage (92%)
- Reviewed via /review command"

git push origin feature/user-authentication
```

### Step 7: Create Pull Request
Use GitHub CLI or web UI. Reference the commit message and `/review` findings.

## Workflow: Code Review Session

Assigned to review someone else's code?

### For Each Changed File:
```bash
claude /review <file>
```

Check the report for:
1. **CRITICAL issues** — Must be fixed before merge
2. **HIGH issues** — Should be fixed
3. **MEDIUM issues** — Nice to fix
4. **LOW issues** — Consider for next refactor

### Comment on PR with Findings:
```
## Code Review Summary

✓ File 1: 2 MEDIUM issues (naming clarity)
✓ File 2: 1 HIGH issue (missing error handling)
✗ File 3: 1 CRITICAL issue (hardcoded API key)

See individual comments for details.
```

## Troubleshooting

### Issue: `claude: command not found`
```bash
# Check installation
claude --version

# Install if needed
curl https://claude.com/install | bash
```

### Issue: `ESLint errors not detected in /review`
```bash
# Ensure ESLint is installed
npm install --save-dev eslint @typescript-eslint/eslint-plugin

# Run manually to test
npx eslint src/components/Button.tsx
```

### Issue: `/generate-test creates incorrect test`
The skill reads your component's interface. If the test is wrong:
1. Edit the test manually
2. Run `/review <test-file>` to validate
3. Report issues in team Slack channel

### Issue: MCP Server Not Connecting
```bash
# Check that env variables are set
echo $GITHUB_TOKEN

# Manually start the MCP server
node mcp-servers/github-server.js

# Check logs in Claude Code
claude --debug
```

## Best Practices

1. **Always generate tests first** — Even if you don't use all of them
2. **Run `/review` before commit** — Catch issues early
3. **Fix CRITICAL issues immediately** — Don't let them accumulate
4. **Update CLAUDE.md when standards change** — Keep team in sync
5. **Use descriptive commit messages** — Reference `/review` findings if applicable

## Team Resources

- **CLAUDE.md** — Team testing and code standards
- **.claude/rules/** — Specific rules for test vs. implementation files
- **.claude/skills/** — Custom commands (review, generate-test)
- **.claude/mcp-config.json** — External integrations (GitHub, Slack)

---

For questions, reach out to the engineering lead or post in #engineering Slack channel.
```

**Task:** Add a troubleshooting section for when a test file fails to generate. What are common reasons? (Potential answers: Component has complex props, uses generics, imports aren't resolvable.)

---

## Expected Outcomes & Success Criteria

### Successful Setup
1. **CLAUDE.md exists** with testing conventions documented
2. **.claude/rules/ directory** with at least 2 rule files (test-standards.md, implementation-standards.md)
3. **Custom /review command** can be invoked and generates structured reports
4. **/generate-test skill** creates valid, executable test files
5. **MCP config** is present and specifies at least 1 enabled server
6. **WORKFLOW.md** provides clear team guidance

### Test Pass Criteria
- Run `/review src/components/Button.test.tsx` → Output includes coverage %, eslint results, test execution results
- Run `/generate-test src/utils/math.ts` → Creates `math.test.ts` with at least 3 tests
- All generated test files pass `npm test`
- No unintended files are modified (skill respects restrictions)

### Team Adoption
- All team members can:
  - [ ] Run `/review` on their own code
  - [ ] Generate test boilerplate with `/generate-test`
  - [ ] Understand CLAUDE.md conventions
  - [ ] Identify critical issues before PR

---

## Common Mistakes to Avoid

1. **Overly strict rules:** If .claude/rules/ are too strict, team will ignore them
2. **Not updating CLAUDE.md:** Conventions drift as team grows; keep documentation current
3. **Skill with wrong permissions:** If /generate-test has fork: true, it might execute arbitrary code
4. **MCP server not tested:** Configure in mcp-config.json but never verify it works
5. **No examples in WORKFLOW.md:** Vague instructions → team confusion
6. **Forgetting to set env vars:** MCP servers fail silently without GITHUB_TOKEN or SLACK_BOT_TOKEN
7. **Rules only in .claude/rules:** Team needs to know about them; link from CLAUDE.md

---

## Connection to Exam Concepts

**Domain 3: Configuration & Team Workflows**
- **Task 3.1:** Configure project-level Claude context
  - CLAUDE.md establishes team standards and conventions
- **Task 3.2:** Create custom slash commands and skills
  - /review command and /generate-test skill demonstrate customization
- **Task 3.3:** Manage tool access and restrictions
  - Skills use fork, allowed-tools, and write-only restrictions
- **Task 3.4:** Integrate external systems (MCP)
  - MCP server configuration for GitHub and Slack

**Relevant Course Module:** Module 3 (Configuration, Customization, Team Scaling)

---

## Estimated Time to Complete

- **Step 1 (CLAUDE.md):** 15 minutes
- **Step 2 (Scoped rules):** 10 minutes
- **Step 3 (/review command):** 15 minutes
- **Step 4 (/generate-test skill):** 15 minutes
- **Step 5 (MCP config):** 10 minutes
- **Step 6 (Team docs):** 10 minutes
- **Testing & verification:** 15 minutes
- **Total:** 90 minutes (1.5 hours)

**Suggested Checkpoint:** After Step 1, verify CLAUDE.md is readable and team understands conventions.

---

## Additional Challenges (Optional)

1. **Create a /lint skill** that automatically fixes prettier and eslint errors
2. **Build a /commit skill** that generates conventional commit messages from changed files
3. **Implement a /estimate skill** that uses `/review` to estimate effort for a code change
4. **Add a /coverage skill** that tracks test coverage over time
5. **Create a /audit skill** that checks for security issues (hardcoded secrets, unsafe patterns)
6. **Implement custom rules** for your specific tech stack (Angular, Vue, Svelte, etc.)
7. **Build a /migrate skill** that refactors code to match new team standards
