# Scenario Lab: CI Code Review Prompt Engineering

## Overview

In this lab, you will engineer and iteratively improve prompts for automated code review in CI/CD pipelines. You will write explicit criteria defining which issues to flag vs. skip, create targeted few-shot examples for ambiguous code patterns, define severity levels with concrete code examples, and design a multi-pass review strategy that combines per-file analysis with integration-level concerns. This lab teaches the discipline of prompt engineering for production code analysis.

**Key Architecture Pattern:** Explicit criteria, few-shot prompting, severity definitions, multi-pass analysis, iterative refinement.

---

## Learning Objectives

By completing this lab, you will demonstrate the ability to:

1. **Write explicit code review criteria** that clearly distinguish between issues to flag (bugs, security risks) vs. non-issues (style preferences, opinion-based feedback)
2. **Design targeted few-shot examples** for ambiguous patterns (e.g., when is duplicate code a problem?)
3. **Define severity levels** with concrete code examples for each level (critical, high, medium, low)
4. **Build multi-pass review strategies** that first analyze individual files, then analyze interactions between files
5. **Iterate and refine prompts** using test cases and feedback loops
6. **Measure prompt quality** using precision/recall on known issues

**Exam Connections:** Domain 4 (Prompt Engineering & Outputs)

---

## Prerequisites

### Tools & APIs
- **Claude API**
- **Python 3.8+** for test harness
- **Sample code repositories** (real or synthetic)
- **Code samples** representing various issue types

### Knowledge
- Familiarity with code review best practices
- Understanding of prompt design principles (Module 4)
- Ability to recognize common code patterns and issues

### Setup
```bash
pip install anthropic

export CLAUDE_API_KEY="your-key-here"
```

---

## Step-by-Step Instructions

### Step 1: Write Explicit Review Criteria

Define what SHOULD be flagged and what SHOULD NOT be flagged.

**File: `review_criteria.md`**

```markdown
# Code Review Criteria for Automated CI

## Issues to Flag (Action Items)

The code review should identify and flag these categories:

### 1. Security Issues (CRITICAL severity)
- **Hardcoded credentials** (API keys, passwords, tokens in code)
- **SQL injection risks** (unparameterized queries, string concatenation)
- **Unsafe deserialization** (unsafe pickle usage, eval, exec)
- **Insecure dependencies** (known vulnerable package versions)
- **Sensitive data exposure** (logging passwords, PII in error messages)
- **Missing authentication/authorization** (unprotected endpoints)
- **Insecure cryptography** (weak algorithms, bad random generation)

### 2. Correctness Issues (HIGH severity)
- **Uninitialized variables** (using vars before assignment)
- **Missing error handling** (no try/catch for risky operations)
- **Logic errors** (off-by-one bugs, wrong operators, dead code)
- **Race conditions** (concurrent access without synchronization)
- **Resource leaks** (files/connections not closed)
- **Type errors** (ignoring type safety, unsafe casts)
- **Null pointer dereferences** (dereferencing without null check)

### 3. Reliability Issues (HIGH severity)
- **Untested code** (no unit tests for new logic)
- **Incomplete test coverage** (<80% for functions, <75% for components)
- **Missing edge case tests** (error paths, boundary conditions)
- **Flaky tests** (tests that fail intermittently)
- **Missing logging** (no way to debug production issues)
- **Poor error messages** (user can't understand what went wrong)

### 4. Performance Issues (MEDIUM severity)
- **O(n²) algorithms** where O(n log n) is available
- **N+1 query problems** (querying in loops)
- **Inefficient data structures** (using lists instead of sets for lookups)
- **Unnecessary copying** (inefficient string/object operations)
- **Blocking operations in event loops** (synchronous I/O in async code)

### 5. Maintainability Issues (MEDIUM severity)
- **Duplicate code** (same logic appears 3+ times)
- **Long functions** (>100 lines of non-trivial logic)
- **Complex conditionals** (deeply nested if/else, cyclomatic complexity >10)
- **Poor naming** (single-letter vars except loop counters, ambiguous names)
- **Magic numbers/strings** (hardcoded values without explanation)
- **Missing documentation** (public APIs/complex logic without comments)

---

## Issues to NOT Flag (Filter Out)

The code review should ignore these categories:

### 1. Style Preferences (Even if Different from Codebase)
- **Line length** (unless >200 chars)
- **Brace style** (K&R vs. Allman vs. 1TBS)
- **Variable naming conventions** (camelCase vs. snake_case differences)
- **Whitespace/indentation** (handled by formatters)
- **Comment style** (unless comments are misleading)
- **Import ordering** (unless they're not using the established order)

### 2. Opinion-Based Feedback
- "This could be written more elegantly"
- "This pattern is less idiomatic"
- "I would use a different library"
- "This design is suboptimal" (without specifics)

### 3. Refactoring Suggestions (Unless Related to Above)
- "This could be extracted to a function" (unless it's repeated code)
- "This could use a design pattern" (unless it prevents a bug)
- "We should use this newer API" (unless the old one is deprecated)

### 4. Non-Code Issues
- **Commit message format** (unless enforced by CI)
- **File organization** (unless it's in the wrong folder)
- **Documentation file updates** (outside scope of code review)

---

## Severity Levels

### CRITICAL (Must Fix Before Merge)
- Any security vulnerability
- Any correctness issue that causes crashes or data loss
- Missing authentication on protected endpoints
- Hardcoded credentials

**Example:** Hardcoded AWS key in code

### HIGH (Should Fix Before Merge)
- Missing error handling
- Race conditions
- Resource leaks
- Missing test coverage on critical path
- Broken existing tests

**Example:** Unhandled exception in async operation

### MEDIUM (Fix in Next Iteration)
- Performance issues that affect user experience
- Code duplication (3+ occurrences)
- Complex conditionals that need refactoring
- Incomplete documentation of public APIs

**Example:** N+1 query in user profile endpoint

### LOW (Nice to Have)
- Naming clarity improvements
- Non-critical performance optimizations
- Minor documentation additions
- Consistency improvements

**Example:** Variable name could be clearer (doesn't affect correctness)

---

## Exclusion Rules

Do NOT flag issues in:
- **Test files** (*.test.ts, *.test.js, spec.ts, etc.)
  - Exception: Untested production code should be flagged
- **Auto-generated files** (*.generated.ts, dist/**, etc.)
- **Configuration files** (*.config.js, .env.example, etc.)
  - Exception: Hardcoded credentials in .env
- **Third-party dependencies** (node_modules/**, vendor/**, etc.)
- **Deprecated code marked with @deprecated** (unless removing the code)

---

## Review Scope

### For Each File, Analyze:
1. Security vulnerabilities
2. Correctness issues
3. Missing test coverage (for new code)
4. Performance problems
5. Maintainability issues

### DO NOT Analyze:
- Style issues (unless >200 chars)
- Comment/documentation preferences
- Library choices
- Overall architecture (that's for design review)

---

## Example: What to Flag vs. What to Skip

### Example 1: Hardcoded Config

```typescript
const API_URL = 'https://api.example.com';
const API_KEY = 'sk_live_123456789abcdef';
```

**Action:** FLAG as CRITICAL (hardcoded credentials)
**Reason:** Security vulnerability; credentials should be in env vars

---

### Example 2: Variable Naming

```typescript
const u = user.getData();
const p = u.profile;
```

**Action:** SKIP (don't flag)
**Reason:** Style preference; not a correctness issue. Linting handles this.

---

### Example 3: Missing Error Handling

```typescript
async function fetchUser(id: string) {
  const response = await fetch(`/api/user/${id}`);
  return response.json();
}
```

**Action:** FLAG as HIGH
**Reason:** No error handling for network failures or invalid JSON

---

### Example 4: N+1 Query

```typescript
// In a loop - inefficient
const users = db.query('SELECT * FROM users LIMIT 10');
for (const user of users) {
  const posts = db.query(`SELECT * FROM posts WHERE user_id = ?`, [user.id]);
  // Process posts
}
```

**Action:** FLAG as MEDIUM (performance)
**Reason:** 1 query + 10 queries = 11 total. Should batch or use JOIN.

---

### Example 5: Code Duplication

```typescript
// Appears in 3 places
function processData(data: any[]) {
  return data
    .filter(item => item.active)
    .map(item => ({ ...item, processed: true }))
    .sort((a, b) => a.id - b.id);
}
```

**Action:** FLAG as MEDIUM
**Reason:** If logic is duplicated 3+ times, should extract to shared utility

---

## Example 6: Safe Pattern (Should Skip)

```typescript
const userService = {
  getUserById(id: string) {
    return users.find(u => u.id === id);
  }
};
```

**Action:** SKIP
**Reason:** No issues here. Code is safe, tested (presumably), and correct.

```

**Task:** Review the criteria. What severity would you assign to "missing unit tests for a public API function"? (Answer: HIGH — untested code is a reliability risk.)

---

### Step 2: Create Few-Shot Examples for Ambiguous Patterns

Create example code snippets with expected review outcomes for patterns that are hard to judge.

**File: `few_shot_examples.py`**

```python
"""
Few-shot examples for code review.

These examples teach Claude how to review code in ambiguous cases:
- When is code duplication a problem?
- When should we flag complexity?
- When is a loop inefficient?
"""

REVIEW_EXAMPLES = [
    {
        "title": "When to flag duplicate code",
        "code": """
// Utility.ts
function processUserData(user: any) {
  return user.data
    .filter(item => item.active)
    .map(item => ({ ...item, timestamp: new Date().toISOString() }))
    .sort((a, b) => a.id - b.id);
}

// ProductService.ts
function processProductData(product: any) {
  return product.data
    .filter(item => item.active)
    .map(item => ({ ...item, timestamp: new Date().toISOString() }))
    .sort((a, b) => a.id - b.id);
}

// OrderService.ts
function processOrderData(order: any) {
  return order.data
    .filter(item => item.active)
    .map(item => ({ ...item, timestamp: new Date().toISOString() }))
    .sort((a, b) => a.id - b.id);
}
        """,
        "expected_finding": {
            "severity": "MEDIUM",
            "rule": "duplicate_code",
            "title": "Duplicate code appears in 3 locations",
            "message": "The data processing logic appears identically in processUserData, processProductData, and processOrderData. Extract to a shared utility function.",
            "suggestion": "Create: function processActiveData(data) { ... } and use in all three places"
        },
        "explanation": "3+ identical code blocks are a maintainability risk"
    },
    {
        "title": "When duplicate code is OK (different contexts)",
        "code": """
// In UserController.ts
function validateEmail(email: string): boolean {
  const regex = /^[^@]+@[^@]+\\.[^@]+$/;
  return regex.test(email);
}

// In NotificationService.ts
function validateEmail(email: string): boolean {
  const regex = /^[^@]+@[^@]+\\.[^@]+$/;
  return regex.test(email);
}
        """,
        "expected_finding": None,  # Don't flag this
        "explanation": "These are NOT duplicate code; they're in different modules/packages. Shared utility would create unwanted coupling."
    },
    {
        "title": "N+1 query performance issue",
        "code": """
async function getActiveUsers() {
  const users = await db.query('SELECT id, name FROM users WHERE active = true');

  // Problem: 1 query + N queries in loop = N+1
  for (const user of users) {
    const permissions = await db.query(
      'SELECT * FROM user_permissions WHERE user_id = ?',
      [user.id]
    );
    user.permissions = permissions;
  }

  return users;
}
        """,
        "expected_finding": {
            "severity": "MEDIUM",
            "rule": "performance_n_plus_one",
            "title": "N+1 query detected",
            "message": f"This code runs 1 + users.length database queries. Should batch into 2 queries.",
            "suggestion": "Use a JOIN or batch query: SELECT users.*, permissions.* FROM users LEFT JOIN permissions..."
        },
        "explanation": "N+1 queries are common performance bugs in loops"
    },
    {
        "title": "When looping is fine (data transformation)",
        "code": """
function formatUsers(users: User[]): FormattedUser[] {
  return users.map(user => ({
    id: user.id,
    displayName: `${user.firstName} ${user.lastName}`,
    email: user.email.toLowerCase(),
    joinedDaysAgo: Math.floor((Date.now() - user.createdAt) / (1000 * 60 * 60 * 24))
  }));
}
        """,
        "expected_finding": None,  # Don't flag
        "explanation": "Looping over data in memory for transformation is fine; only flag if looping with I/O (DB, API calls)"
    },
    {
        "title": "Missing error handling (HIGH severity)",
        "code": """
async function fetchUserProfile(userId: string) {
  const response = await fetch(`/api/users/${userId}`);
  const data = await response.json();
  return data;
}
        """,
        "expected_finding": {
            "severity": "HIGH",
            "rule": "missing_error_handling",
            "title": "Missing error handling for async operation",
            "message": "Unhandled errors will crash the application. Network requests can fail; JSON parsing can fail.",
            "suggestion": """
async function fetchUserProfile(userId: string) {
  try {
    const response = await fetch(`/api/users/${userId}`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    return data;
  } catch (error) {
    logger.error('Failed to fetch user profile', { userId, error });
    throw error;
  }
}
            """
        },
        "explanation": "Unhandled async errors cause crashes"
    },
    {
        "title": "Safe async code (error handling present)",
        "code": """
async function fetchUserProfile(userId: string): Promise<UserProfile | null> {
  try {
    const response = await fetch(`/api/users/${userId}`);
    if (!response.ok) {
      logger.warn('User fetch failed', { status: response.status });
      return null;
    }
    return await response.json();
  } catch (error) {
    logger.error('Profile fetch error', { userId, error });
    return null;
  }
}
        """,
        "expected_finding": None,  # Don't flag
        "explanation": "Error handling is present; safely returns null on failure"
    }
]

def get_few_shot_prompt() -> str:
    """Generate few-shot prompt with examples."""
    prompt = "## Code Review Examples\n\n"
    prompt += "Here are examples of code patterns and whether they should be flagged:\n\n"

    for example in REVIEW_EXAMPLES:
        prompt += f"### {example['title']}\n\n"
        prompt += f"**Code:**\n```typescript\n{example['code']}\n```\n\n"

        if example['expected_finding']:
            finding = example['expected_finding']
            prompt += f"**Review Finding:**\n"
            prompt += f"- **Severity:** {finding['severity']}\n"
            prompt += f"- **Rule:** {finding['rule']}\n"
            prompt += f"- **Title:** {finding['title']}\n"
            prompt += f"- **Message:** {finding['message']}\n"
            if 'suggestion' in finding:
                prompt += f"- **Suggestion:** {finding['suggestion']}\n"
        else:
            prompt += f"**Review Finding:** None - this code is acceptable\n"

        prompt += f"**Explanation:** {example['explanation']}\n\n"

    return prompt
```

**Task:** Add a sixth example for "when a long function should be flagged vs. when it's OK". (Answer: Flag if function does multiple unrelated things; OK if it's a single complex algorithm that's hard to split.)

---

### Step 3: Define Severity Levels with Code Examples

Create a reference document showing severity definitions with actual code examples.

**File: `severity_definitions.md`**

```markdown
# Code Review Severity Levels

## CRITICAL: Must Fix Before Merge

Issues that prevent code from working correctly or introduce security vulnerabilities.

### 1. Hardcoded Credentials

```python
# CRITICAL: Hardcoded API key
api_key = "sk_live_abc123def456"
response = requests.get("https://api.example.com/data", headers={"Authorization": f"Bearer {api_key}"})
```

**Fix:**
```python
import os
api_key = os.environ.get("API_KEY")  # Load from env var
if not api_key:
    raise ValueError("API_KEY environment variable is not set")
response = requests.get("https://api.example.com/data", headers={"Authorization": f"Bearer {api_key}"})
```

### 2. SQL Injection

```python
# CRITICAL: SQL injection vulnerability
query = f"SELECT * FROM users WHERE email = '{email}'"
cursor.execute(query)
```

**Fix:**
```python
# Use parameterized query
query = "SELECT * FROM users WHERE email = %s"
cursor.execute(query, (email,))
```

### 3. Missing Authentication on Protected Route

```typescript
// CRITICAL: No authentication check
app.get('/api/admin/users', (req, res) => {
  const users = db.query('SELECT * FROM users');
  res.json(users);
});
```

**Fix:**
```typescript
app.get('/api/admin/users', requireAuth, requireAdmin, (req, res) => {
  const users = db.query('SELECT * FROM users');
  res.json(users);
});
```

---

## HIGH: Should Fix Before Merge

Issues that cause crashes, data loss, or significantly broken functionality.

### 1. Unhandled Exception

```javascript
// HIGH: Network request with no error handling
async function getUser(id) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();  // Can throw if network fails
}
```

**Fix:**
```javascript
async function getUser(id) {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    logger.error('Failed to fetch user', { id, error });
    throw error;  // Re-throw or return fallback
  }
}
```

### 2. Resource Not Closed

```python
# HIGH: File not closed (resource leak)
def read_config():
    file = open('config.json')
    return json.load(file)
    # File is never closed
```

**Fix:**
```python
def read_config():
    with open('config.json') as file:
        return json.load(file)
    # File automatically closed
```

### 3. Race Condition

```python
# HIGH: Race condition in concurrent code
counter = 0

def increment():
    global counter
    counter += 1  # Not atomic; race condition if called from multiple threads
```

**Fix:**
```python
import threading

counter = 0
lock = threading.Lock()

def increment():
    global counter
    with lock:
        counter += 1
```

### 4. Missing Test Coverage on Critical Path

```typescript
// HIGH: No tests for authentication logic
export function validateToken(token: string): boolean {
  try {
    const decoded = jwt.verify(token, SECRET);
    return !!decoded;
  } catch {
    return false;
  }
}
```

**Expectation:** This function MUST have unit tests covering:
- Valid token (should return true)
- Expired token (should return false)
- Invalid token (should return false)
- Malformed token (should return false)

---

## MEDIUM: Fix in Next Iteration

Issues that affect performance, maintainability, or should be improved.

### 1. Code Duplication (3+ occurrences)

```typescript
// MEDIUM: Same validation logic in 3 places

// In UserService.ts
if (!email || !email.includes('@')) {
  throw new Error('Invalid email');
}

// In RegistrationController.ts
if (!email || !email.includes('@')) {
  throw new Error('Invalid email');
}

// In AdminPanel.ts
if (!email || !email.includes('@')) {
  throw new Error('Invalid email');
}
```

**Fix:**
```typescript
// Create shared utility
function validateEmail(email: string): void {
  if (!email || !email.includes('@')) {
    throw new Error('Invalid email');
  }
}

// Use everywhere
validateEmail(userEmail);
validateEmail(registrationEmail);
validateEmail(adminEmail);
```

### 2. N+1 Query Problem

```python
# MEDIUM: Inefficient query pattern
users = User.query.filter(User.active == True).limit(10).all()
for user in users:
    # This query runs 10 times (N+1 problem)
    permissions = Permission.query.filter(Permission.user_id == user.id).all()
    user.permissions = permissions
```

**Fix:**
```python
# Use JOIN or batch query
users = db.session.query(User).join(Permission).filter(
    User.active == True
).limit(10).all()

# Or use eager loading:
users = User.query.options(
    joinedload(User.permissions)
).filter(User.active == True).limit(10).all()
```

### 3. Complex Nested Conditionals

```typescript
// MEDIUM: Complex logic that's hard to follow
function processOrder(order: Order) {
  if (order.items.length > 0) {
    if (order.customer.isActive) {
      if (order.total > 100) {
        if (order.customer.hasDiscount) {
          // 4 levels of nesting - hard to follow
          order.total *= 0.9;
        }
      }
    }
  }
}
```

**Fix:**
```typescript
function processOrder(order: Order) {
  if (order.items.length === 0) return;
  if (!order.customer.isActive) return;
  if (order.total <= 100) return;
  if (!order.customer.hasDiscount) return;

  // All conditions passed; now process
  order.total *= 0.9;
}
```

---

## LOW: Nice to Have

Improvements that don't affect correctness or performance.

### 1. Unclear Variable Naming

```python
# LOW: Single-letter variable name (in non-loop context)
d = datetime.now()
u = fetch_user(user_id)
h = {'name': u.name, 'email': u.email}
```

**Fix:**
```python
current_time = datetime.now()
user = fetch_user(user_id)
user_header = {'name': user.name, 'email': user.email}
```

### 2. Magic Number Without Explanation

```python
# LOW: Magic number
if age > 18:
    eligible = True

# LOW: Magic string
if status == 'completed':
    send_notification()
```

**Fix:**
```python
LEGAL_AGE = 18
if age > LEGAL_AGE:
    eligible = True

ORDER_STATUS_COMPLETED = 'completed'
if status == ORDER_STATUS_COMPLETED:
    send_notification()
```

### 3. Missing Docstring

```python
# LOW: Public function without docs
def calculate_user_score(activities, engagement):
    return len(activities) * 0.5 + engagement * 0.3
```

**Fix:**
```python
def calculate_user_score(activities: List[Activity], engagement: float) -> float:
    """
    Calculate a user's engagement score.

    Args:
        activities: List of user activities
        engagement: Engagement metric (0-1)

    Returns:
        Score (higher = more engaged)
    """
    return len(activities) * 0.5 + engagement * 0.3
```

---

## Summary Table

| Severity | Action | Examples |
|----------|--------|----------|
| **CRITICAL** | Block merge | Hardcoded creds, SQL injection, missing auth |
| **HIGH** | Fix before merge | Unhandled errors, resource leaks, race conditions |
| **MEDIUM** | Fix next iteration | Duplication, N+1 queries, complex logic |
| **LOW** | Nice to have | Naming clarity, magic numbers, docstrings |
```

---

### Step 4: Design Multi-Pass Review Strategy

Create a strategy that combines per-file and integration-level analysis.

**File: `multi_pass_reviewer.py`**

```python
"""
Multi-pass code review strategy:
1. Pass 1: Analyze each file independently
2. Pass 2: Analyze interactions between files
3. Pass 3: Synthesis and prioritization
"""

from anthropic import Anthropic
import json
from typing import List, Dict

client = Anthropic()

class MultiPassCodeReviewer:
    """Performs multi-pass code review."""

    def __init__(self):
        self.pass1_results = {}  # Per-file findings
        self.pass2_results = {}  # Integration findings
        self.final_report = {}

    def pass1_individual_file_analysis(self, files: Dict[str, str]) -> Dict[str, List[Dict]]:
        """
        Pass 1: Analyze each file independently for issues.

        Args:
            files: Dict of {filename: code_content}

        Returns:
            Dict of {filename: [findings]}
        """

        print("PASS 1: Individual File Analysis\n" + "="*50)

        results = {}

        for filename, code in files.items():
            print(f"\nAnalyzing {filename}...")

            prompt = f"""You are an expert code reviewer.

{get_review_criteria_prompt()}

{get_few_shot_prompt()}

## Review This File

**File:** {filename}

**Code:**
```
{code}
```

Analyze this file for issues in these categories:
1. Security issues
2. Correctness issues
3. Missing test coverage
4. Performance problems
5. Maintainability issues

For each finding, provide:
- severity (CRITICAL, HIGH, MEDIUM, LOW)
- rule (identifier)
- title
- message
- suggestion

Return as JSON array."""

            response = client.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=2000,
                messages=[{"role": "user", "content": prompt}]
            )

            # Parse response
            try:
                response_text = response.content[0].text
                # Extract JSON
                json_start = response_text.find('[')
                json_end = response_text.rfind(']') + 1
                json_str = response_text[json_start:json_end]
                findings = json.loads(json_str)
            except:
                findings = []

            results[filename] = findings
            print(f"  Found {len(findings)} issues")

        self.pass1_results = results
        return results

    def pass2_integration_analysis(self, files: Dict[str, str]) -> Dict[str, List[Dict]]:
        """
        Pass 2: Analyze interactions between files.

        Focuses on:
        - Inconsistent behavior across files
        - Shared state/data issues
        - API contract violations
        - Circular dependencies
        """

        print("\n\nPASS 2: Integration Analysis\n" + "="*50)

        filenames = list(files.keys())
        if len(filenames) < 2:
            print("Only 1 file; skipping integration analysis")
            return {}

        prompt = f"""You are an expert code reviewer analyzing file interactions.

## Context: Files to Analyze

{json.dumps({f: files[f][:500] for f in filenames}, indent=2)}

## Questions to Check

1. **Data Consistency:** Do files handle the same data differently?
   - Example: File A validates email as x@y.z, File B as different pattern

2. **API Contracts:** Do files respect each other's interfaces?
   - Example: File A expects error object, File B returns string

3. **State Management:** Are there race conditions or state conflicts?
   - Example: Both files modify shared state without coordination

4. **Dependencies:** Are there circular dependencies or tight coupling?
   - Example: File A imports File B imports File A

5. **Logging/Debugging:** Is instrumentation consistent?
   - Example: Some files log errors, others silently fail

For each issue found, provide:
- severity
- rule
- title
- files_affected
- message
- suggestion

Return as JSON array."""

        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=2000,
            messages=[{"role": "user", "content": prompt}]
        )

        try:
            response_text = response.content[0].text
            json_start = response_text.find('[')
            json_end = response_text.rfind(']') + 1
            json_str = response_text[json_start:json_end]
            findings = json.loads(json_str)
        except:
            findings = []

        self.pass2_results = findings
        return findings

    def pass3_synthesis(self) -> Dict:
        """
        Pass 3: Synthesize findings and prioritize.

        Combines Pass 1 and Pass 2 results into a final report.
        """

        print("\n\nPASS 3: Synthesis & Prioritization\n" + "="*50)

        # Flatten all findings
        all_findings = []

        # Add file-specific findings
        for filename, findings in self.pass1_results.items():
            for finding in findings:
                finding['source'] = 'file-analysis'
                finding['file'] = filename
                all_findings.append(finding)

        # Add integration findings
        for finding in self.pass2_results:
            finding['source'] = 'integration-analysis'
            all_findings.append(finding)

        # Sort by severity
        severity_order = {'CRITICAL': 0, 'HIGH': 1, 'MEDIUM': 2, 'LOW': 3}
        all_findings.sort(key=lambda f: severity_order.get(f.get('severity', 'LOW'), 99))

        # Generate summary
        summary = {
            'total_findings': len(all_findings),
            'critical': len([f for f in all_findings if f.get('severity') == 'CRITICAL']),
            'high': len([f for f in all_findings if f.get('severity') == 'HIGH']),
            'medium': len([f for f in all_findings if f.get('severity') == 'MEDIUM']),
            'low': len([f for f in all_findings if f.get('severity') == 'LOW']),
            'review_passed': len([f for f in all_findings if f.get('severity') in ['CRITICAL', 'HIGH']]) == 0
        }

        self.final_report = {
            'summary': summary,
            'findings': all_findings
        }

        return self.final_report

    def generate_report(self) -> str:
        """Generate human-readable report."""

        report = []
        report.append("CODE REVIEW REPORT")
        report.append("=" * 70)

        summary = self.final_report.get('summary', {})
        report.append(f"\nSummary:")
        report.append(f"  Total Issues: {summary.get('total_findings', 0)}")
        report.append(f"    Critical: {summary.get('critical', 0)}")
        report.append(f"    High: {summary.get('high', 0)}")
        report.append(f"    Medium: {summary.get('medium', 0)}")
        report.append(f"    Low: {summary.get('low', 0)}")

        if summary.get('review_passed'):
            report.append(f"\n✓ REVIEW PASSED")
        else:
            report.append(f"\n✗ REVIEW FAILED - Fix critical/high issues")

        findings = self.final_report.get('findings', [])
        if findings:
            report.append(f"\nFindings:\n")
            for finding in findings:
                report.append(f"  [{finding.get('severity')}] {finding.get('title')}")
                report.append(f"    File: {finding.get('file', 'N/A')}")
                report.append(f"    {finding.get('message')}")
                if finding.get('suggestion'):
                    report.append(f"    → {finding.get('suggestion')}")
                report.append("")

        return "\n".join(report)

def run_multi_pass_review(files: Dict[str, str]) -> Dict:
    """Run complete multi-pass review."""

    reviewer = MultiPassCodeReviewer()

    # Pass 1
    reviewer.pass1_individual_file_analysis(files)

    # Pass 2
    reviewer.pass2_integration_analysis(files)

    # Pass 3
    reviewer.pass3_synthesis()

    # Report
    report_text = reviewer.generate_report()
    print("\n" + report_text)

    return reviewer.final_report
```

**Task:** In the multi-pass strategy, why is it important to analyze files individually before analyzing their interactions? (Answer: Individual analysis finds file-level issues; integration analysis finds interaction bugs that wouldn't appear in isolation.)

---

### Step 5: Test and Refine the Prompts

Create test cases to measure prompt quality.

**File: `test_prompts.py`**

```python
"""
Test suite for code review prompts.

Measures:
- Precision: Do we flag the right issues?
- Recall: Do we catch all issues?
- False positives: Do we flag things we shouldn't?
"""

import json
from multi_pass_reviewer import run_multi_pass_review

class CodeReviewTestCase:
    """A test case for code review."""

    def __init__(self, name: str, code: str, expected_findings: list):
        self.name = name
        self.code = code
        self.expected_findings = expected_findings  # List of rule IDs we expect

TEST_CASES = [
    CodeReviewTestCase(
        name="Hardcoded credentials",
        code="""
def connect_to_db():
    PASSWORD = "super_secret_123"
    connection = psycopg2.connect(
        user="admin",
        password=PASSWORD,
        host="localhost"
    )
    return connection
        """,
        expected_findings=["hardcoded_credentials"]
    ),
    CodeReviewTestCase(
        name="Missing error handling",
        code="""
async def fetch_user(user_id):
    response = await fetch(f"/api/users/{user_id}")
    return await response.json()
        """,
        expected_findings=["missing_error_handling"]
    ),
    CodeReviewTestCase(
        name="Code duplication",
        code="""
def validate_email_1(email):
    return "@" in email and "." in email.split("@")[1]

def validate_email_2(email):
    return "@" in email and "." in email.split("@")[1]

def validate_email_3(email):
    return "@" in email and "." in email.split("@")[1]
        """,
        expected_findings=["duplicate_code"]
    ),
    CodeReviewTestCase(
        name="Clean code (no issues)",
        code="""
def format_user(user):
    return {
        "id": user.id,
        "name": f"{user.first_name} {user.last_name}",
        "email": user.email.lower()
    }
        """,
        expected_findings=[]
    )
]

def test_prompts():
    """Test code review prompts."""

    precision_scores = []
    recall_scores = []

    for test_case in TEST_CASES:
        print(f"\nTesting: {test_case.name}")
        print("-" * 50)

        # Run review
        result = run_multi_pass_review({"test.py": test_case.code})

        # Extract found rules
        found_rules = set()
        for finding in result.get('findings', []):
            found_rules.add(finding.get('rule'))

        expected_rules = set(test_case.expected_findings)

        # Calculate metrics
        true_positives = len(found_rules & expected_rules)
        false_positives = len(found_rules - expected_rules)
        false_negatives = len(expected_rules - found_rules)

        if len(found_rules) > 0:
            precision = true_positives / len(found_rules)
        else:
            precision = 1.0 if false_negatives == 0 else 0.0

        if len(expected_rules) > 0:
            recall = true_positives / len(expected_rules)
        else:
            recall = 1.0 if false_positives == 0 else 0.0

        print(f"Expected rules: {expected_rules}")
        print(f"Found rules: {found_rules}")
        print(f"Precision: {precision:.1%}")
        print(f"Recall: {recall:.1%}")

        if false_positives > 0:
            print(f"⚠️  False positives: {found_rules - expected_rules}")
        if false_negatives > 0:
            print(f"⚠️  Missed issues: {expected_rules - found_rules}")

        precision_scores.append(precision)
        recall_scores.append(recall)

    # Overall metrics
    print(f"\n\nOVERALL METRICS")
    print("=" * 50)
    avg_precision = sum(precision_scores) / len(precision_scores)
    avg_recall = sum(recall_scores) / len(recall_scores)
    print(f"Average Precision: {avg_precision:.1%}")
    print(f"Average Recall: {avg_recall:.1%}")
    print(f"F1 Score: {2 * (avg_precision * avg_recall) / (avg_precision + avg_recall) if (avg_precision + avg_recall) > 0 else 0:.1%}")

if __name__ == "__main__":
    test_prompts()
```

---

## Expected Outcomes & Success Criteria

### Successful Prompt Engineering
1. **Explicit criteria:** Clear rules for what to flag vs. skip
2. **Few-shot examples:** Model learns ambiguous patterns through examples
3. **Severity levels:** Each severity has 2-3 concrete code examples
4. **Multi-pass strategy:** Individual analysis → integration analysis → synthesis
5. **Test suite:** Measurable precision/recall metrics

### Test Pass Criteria
- Hardcoded credentials detected (100% precision)
- Missing error handling caught (>80% recall)
- Code duplication identified when 3+ occurrences
- Clean code marked as having no issues
- False positive rate <10%
- Precision >90% for CRITICAL/HIGH issues

### Sample Report
```
CODE REVIEW REPORT
======================================================================

Summary:
  Total Issues: 5
    Critical: 1
    High: 1
    Medium: 2
    Low: 1

✗ REVIEW FAILED - Fix critical/high issues

Findings:

  [CRITICAL] Hardcoded API credentials
    File: src/config.ts
    Hardcoded API key in code exposes security vulnerability
    → Move API_KEY to environment variable

  [HIGH] Missing error handling
    File: src/user-service.ts
    Async function has no try/catch or error handling
    → Wrap fetch call in try/catch; log errors

  [MEDIUM] Code duplication
    File: src/validators.ts
    Email validation logic appears 3 times
    → Extract to shared validateEmail() function

  [MEDIUM] N+1 query pattern
    File: src/user-repository.ts
    Database query in loop - runs 1 + users.length queries
    → Use JOIN or batch query

  [LOW] Missing JSDoc
    File: src/utils.ts
    Public function calculateScore lacks documentation
    → Add JSDoc comments explaining parameters and return value
```

---

## Common Mistakes to Avoid

1. **Prompt too vague:** "Review for issues" catches nothing; needs explicit criteria
2. **No few-shot examples:** Model struggles with ambiguous patterns
3. **Too many findings:** Report noise; flag only actionable issues
4. **Style feedback as correctness:** Confuses developers when flagging preference
5. **No severity levels:** Can't prioritize; developers ignore all feedback
6. **Single-pass analysis:** Miss integration bugs that don't show in individual files
7. **False positive feedback loop:** Team stops trusting CI reviews
8. **No test suite:** Prompt quality degrades over time unnoticed

---

## Connection to Exam Concepts

**Domain 4: Prompt Engineering & Outputs**
- **Task 4.1:** Design prompts for code analysis
  - Explicit criteria and few-shot examples teach the model
- **Task 4.2:** Evaluate prompt quality
  - Test suite measures precision/recall
- **Task 4.3:** Iterate and refine prompts
  - Multi-pass strategy captures nuanced issues

**Relevant Course Module:** Module 4 (Prompt Engineering, Iterative Refinement)

---

## Estimated Time to Complete

- **Step 1 (Explicit criteria):** 20 minutes
- **Step 2 (Few-shot examples):** 25 minutes
- **Step 3 (Severity definitions):** 20 minutes
- **Step 4 (Multi-pass strategy):** 25 minutes
- **Step 5 (Testing & refinement):** 20 minutes
- **Iteration based on test results:** 20 minutes
- **Total:** 130 minutes (2.2 hours)

**Suggested Checkpoint:** After Step 2, test few-shot examples on a sample code file to verify the model learns the patterns correctly.

---

## Additional Challenges (Optional)

1. **Add confidence scores:** Have Claude rate confidence in each finding (0-100%)
2. **Implement rule weighting:** Different teams may prioritize different rules
3. **Build a learning feedback system:** When developers disagree with findings, use that to improve prompts
4. **Add language-specific rules:** Different rules for Python vs. TypeScript vs. Go
5. **Implement custom rule plugins:** Let teams add organization-specific checks
6. **Build comparative analysis:** Show how issue density compares to historical data
7. **Add test coverage analysis:** Flag files with coverage below threshold
8. **Implement complexity metrics:** Flag functions with high cyclomatic complexity
