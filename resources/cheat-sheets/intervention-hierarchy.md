# The Intervention Hierarchy: How to Fix Problems

When something isn't working as designed, which intervention do you choose? Use this hierarchy.

---

## The Four Levels

```
┌─────────────────────────────────────────────────┐
│ Level 4: Architectural Changes                  │
│ (Fundamental design is wrong; rebuild)          │
└────────────────────┬────────────────────────────┘
                     ▲
                     │
┌────────────────────┴────────────────────────────┐
│ Level 3: Programmatic Enforcement               │
│ (Add code, not instructions)                    │
└────────────────────┬────────────────────────────┘
                     ▲
                     │
┌────────────────────┴────────────────────────────┐
│ Level 2: Few-Shot Examples                      │
│ (Show the model how via examples)               │
└────────────────────┬────────────────────────────┘
                     ▲
                     │
┌────────────────────┴────────────────────────────┐
│ Level 1: Explicit Criteria                      │
│ (Replace vague language with specifics)         │
└─────────────────────────────────────────────────┘
```

**Key Rule:** Use the LOWEST level that solves the problem. Don't skip to Level 4 if Level 1 works.

---

## Level 1: Explicit Criteria

**When:** Instructions are vague; need clarity, not new behavior

**How:** Replace ambiguous language with concrete, measurable criteria

**Example 1: Classification Problem**
```
❌ VAGUE
"Classify this customer email as urgent, normal, or low-priority"

✓ EXPLICIT
"Classify as URGENT if:
  - Customer mentions lost money
  - Mentions legal action
  - Account locked for 24+ hours
  Otherwise classify as NORMAL unless purely informational (LOW)"
```

**Example 2: Decision Making**
```
❌ VAGUE
"Decide if we should refund the customer"

✓ EXPLICIT
"Approve refund if:
  - Purchase within 30 days AND customer requests it
  - Product defective (confirmed by support)
  Reject if:
  - Purchase >30 days ago (unless defect)
  - Customer changed mind (no defect)"
```

**When This Works:**
- Model is generally capable but needs guardrails
- Inconsistency is the issue (not inability)
- Simple decision tree exists

**When This Fails:**
- Model fundamentally can't do the task
- Task requires external state/tools
- Decision is too complex for prompting

---

## Level 2: Few-Shot Examples

**When:** Instructions are clear but execution is inconsistent

**How:** Show examples of good and bad outputs; let model learn by pattern

**Example 1: Sentiment Analysis**
```
Your task: Analyze sentiment of customer feedback.

Examples of POSITIVE:
- "Love this product! Works perfectly" → POSITIVE
- "Finally fixed my issue" → POSITIVE

Examples of NEGATIVE:
- "Broken after 2 weeks" → NEGATIVE
- "Worst purchase ever" → NEGATIVE

Examples of NEUTRAL:
- "It's a product" → NEUTRAL
- "Does what it says" → NEUTRAL

Now analyze: [INPUT]
```

**Example 2: Error Categorization**
```
Categorize each error as: transient, validation, or business.

Transient examples:
- "Database connection timeout" → transient
- "Service temporarily unavailable" → transient

Validation examples:
- "Email format invalid" → validation
- "Amount must be positive" → validation

Business examples:
- "Insufficient balance" → business
- "User not eligible for this tier" → business

Now categorize: [ERROR]
```

**When This Works:**
- Examples clarify ambiguity better than text
- Pattern recognition is stronger than rules
- Model can learn from contrast (good vs bad)

**When This Fails:**
- No clear pattern to learn
- Task requires code/logic, not pattern matching
- Behavioral issue (model doesn't follow rules at all)

---

## Level 3: Programmatic Enforcement

**When:** Prompting alone can't guarantee correctness (financial, compliance, safety-critical)

**How:** Add code-level validation, not instructions

**Example 1: Payment Processing (Compliance)**
```python
# Don't rely on prompt to prevent fraud
# Add code-level checks

def process_payment(amount, customer_id):
    # Explicit criteria as CODE
    if amount < 0:
        raise ValidationError("Amount must be positive")

    if not is_customer_verified(customer_id):
        raise PermissionError("Customer not verified")

    # Only after code checks pass
    result = call_claude(f"Process ${amount} for customer {customer_id}")

    # Validate output
    if result.get("action") not in ["approve", "decline"]:
        raise ValueError("Invalid Claude response")

    return result
```

**Example 2: Medical Data (Safety-Critical)**
```python
# Don't ask Claude to be careful with patient data
# Enforce it in code

def analyze_patient_data(patient_id, analysis_type):
    # Level 1: Explicit criteria in code
    if not is_hipaa_compliant_request(analysis_type):
        raise PermissionError("HIPAA violation detected")

    if not user_has_access(patient_id):
        raise PermissionError("Access denied")

    # Only then call Claude
    result = call_claude_with_rules(
        prompt=f"Analyze {analysis_type} for patient {patient_id}",
        rules="Output must not contain PII"
    )

    # Level 2: Validate output
    if contains_pii(result):
        raise ValueError("PII in response; request rejected")

    return result
```

**When This Works:**
- Behavior is deterministic (must/must-not rules)
- Code can validate reliably
- Mistakes are costly (financial, legal, safety)

**When This Fails:**
- Task is subjective or creative
- Rule set is too complex for code
- Flexibility is more important than strict control

---

## Level 4: Architectural Changes

**When:** Fundamental design is wrong; can't be fixed at prompt/code level

**How:** Redesign the system, change the workflow, or reconsider assumptions

**Example 1: Wrong Tool**
```
❌ LEVEL 1-3 ATTEMPT
Prompt Claude with:
"Use the search API to find exact matches for fuzzy queries"

Problem: Search API doesn't do fuzzy matching
Result: Claude tries and fails, no amount of prompting fixes it

✓ LEVEL 4 SOLUTION
Add a fuzzy matching library to the toolkit
OR use a different API that supports fuzzy matching
Redesign the architecture to include the right tool
```

**Example 2: Wrong Agent**
```
❌ LEVEL 1-3 ATTEMPT
Train one Claude agent to handle customer support AND moderation

Problem: Conflicting requirements (empathy vs objectivity)
Result: Prompting can't reconcile this

✓ LEVEL 4 SOLUTION
Split into two agents:
- Support agent (focused on helping customer)
- Moderation agent (focused on policy enforcement)
Route decisions between them
```

**Example 3: Wrong Model**
```
❌ LEVEL 1-3 ATTEMPT
Use Claude to execute complex financial calculations

Problem: Claude is not a calculator; rounding errors accumulate
Result: Prompting won't fix floating-point issues

✓ LEVEL 4 SOLUTION
Use a dedicated math library or database
Call Claude for reasoning, not calculation
Programmatic enforcement for numbers
```

**When This Works:**
- Problem persists despite multiple prompting attempts
- Requirements contradict each other
- Tool/model mismatch is fundamental
- System design is flawed at core level

---

## Decision Tree: Which Level to Use?

```
Identify the problem:
    │
    ├─ Model gives inconsistent outputs?
    │   ├─ Instructions are vague? → LEVEL 1
    │   └─ Instructions clear, pattern unclear? → LEVEL 2
    │
    ├─ Output is sometimes wrong (unacceptable)?
    │   ├─ Can you catch it with code? → LEVEL 3
    │   └─ Can't catch it in code? → LEVEL 2 + LEVEL 3
    │
    ├─ Problem persists despite better prompting?
    │   ├─ Can code validate the rule? → LEVEL 3
    │   └─ Fundamental design issue? → LEVEL 4
    │
    └─ All of the above failed?
        └─ LEVEL 4 (redesign required)
```

---

## Common Problem Types

| Problem | Root Cause | Solution |
|---------|-----------|----------|
| "Claude gives different answers to same question" | Vague criteria | Level 1 |
| "Claude inconsistently formats JSON" | Model learns patterns poorly | Level 2 |
| "Claude sometimes approves invalid payments" | No validation | Level 3 |
| "Claude is apologizing too much in support chats" | Can't fix with prompts alone | Level 1 + 2 |
| "Claude is wrong on financial calculations" | Wrong tool for job | Level 4 |

---

## Key Principles

### 1. Fix at the Lowest Level
Don't use Level 3 code enforcement if Level 1 explicit criteria solve it.

### 2. Combine Levels
Often you need **Level 1 + Level 3**: explicit criteria in prompt + programmatic validation in code.

### 3. Know When to Stop
If Level 3 and 2 fail repeatedly, don't keep adding rules. Level 4 is probably needed.

### 4. Skill Gap vs Safety Constraint
- **Skill gap** (Claude can't do the task) → Prompt fix
- **Safety constraint** (Output must never violate rule X) → Programmatic fix

---

## Real-World Example: Content Moderation

**Problem:** Claude sometimes approves harmful content

**Level 1 Attempt:** Better prompts
```
"Be careful when moderating content"
→ Doesn't help; still inconsistent
```

**Level 2 Attempt:** Few-shot examples
```
"Examples of harmful: [list 20 examples]"
→ Helps, but borderline cases still missed
```

**Level 3 Solution:** Code validation
```python
def moderate_content(text):
    # First: keyword filtering (explicit criteria)
    if contains_explicit_keywords(text):
        return "rejected"

    # Then: Claude analysis
    result = call_claude(f"Moderate: {text}")

    # Then: Code validation
    if not is_compliant(result):
        return "rejected"  # Don't trust Claude alone

    return result
```

**Level 4 Option:** If all else fails, use specialized API
```python
# If your domain is very specific (medical, legal)
# Consider a specialized moderation service
# that's better-designed for your needs
```

---

## Summary

**The Hierarchy:**
1. **Level 1:** Make instructions explicit and unambiguous
2. **Level 2:** Add examples to show patterns
3. **Level 3:** Add code-level validation for critical decisions
4. **Level 4:** Redesign if fundamental problem exists

**Best Practice:** Always start at Level 1. Only move up if it doesn't solve the problem.
