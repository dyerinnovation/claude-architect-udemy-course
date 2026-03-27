# MCP Error Response Required Fields Checklist

## Required Fields in Every Error Response

```json
{
  "errorCategory": "transient|validation|business|permission",
  "isRetryable": boolean,
  "description": "Human-readable explanation"
}
```

---

## Error Categories & Agent Behavior

| Category | Meaning | isRetryable | Agent Behavior | Example |
|----------|---------|-------------|---|---------|
| **transient** | Temporary, infrastructure issue | `true` | Retry with backoff | Database connection timeout |
| **validation** | Input malformed/invalid | `false` | Ask user to fix input | Invalid date format |
| **business** | Business logic violation | `false` | Escalate or handle gracefully | Insufficient funds |
| **permission** | Access denied | `false` | Escalate to human | User not authorized |

---

## Access Failure vs Valid Empty Result

### Access Failure (Error Response)
```json
{
  "errorCategory": "permission",
  "isRetryable": false,
  "description": "User john@example.com lacks read permission for account ID 789"
}
```
→ Agent knows it tried and FAILED

### Valid Empty Result (Success Response)
```json
{
  "result": []
}
```
→ Agent knows it SUCCEEDED (no records found)

**Key Distinction:**
- **Error** = "I couldn't execute this operation"
- **Empty result** = "I executed successfully, and the answer is empty"

---

## Decision Matrix for Error Category

```
Does the error depend on the REQUEST?
  ├─ YES → validation
  │   (e.g., "invalid email format" — user's fault)
  │
  ├─ NO: Does the error depend on the DATA?
  │   ├─ YES → business
  │   │   (e.g., "account has negative balance" — data state)
  │   │
  │   └─ NO: Is it a PERMISSION issue?
  │       ├─ YES → permission
  │       │   (e.g., "user not authorized")
  │       │
  │       └─ NO → transient
  │           (e.g., "network timeout")
```

---

## Common Error Response Examples

### Example 1: Invalid Tool Input (validation)
```json
{
  "errorCategory": "validation",
  "isRetryable": false,
  "description": "Customer ID must be a positive integer. Received: 'abc123'"
}
```

### Example 2: Business Rule Violation (business)
```json
{
  "errorCategory": "business",
  "isRetryable": false,
  "description": "Cannot refund order that shipped 180+ days ago. Order date: 2025-01-01"
}
```

### Example 3: Permission Denied (permission)
```json
{
  "errorCategory": "permission",
  "isRetryable": false,
  "description": "User lacks permission to access financial reports. Required: finance_admin role"
}
```

### Example 4: Temporary Outage (transient)
```json
{
  "errorCategory": "transient",
  "isRetryable": true,
  "description": "Payment gateway returned 503 Service Unavailable. Please retry in 30 seconds."
}
```

---

## Checklist for Tool Implementers

- [ ] Every error response includes `errorCategory`
- [ ] `errorCategory` is one of: transient, validation, business, permission
- [ ] Every error response includes `isRetryable` boolean
- [ ] `isRetryable` is `true` ONLY for transient errors
- [ ] `description` is human-readable (no error codes alone)
- [ ] Empty results return `{"result": []}` or `{"result": null}` (not errors)
- [ ] Error `description` explains WHY (context for agent)
- [ ] No mixing of error and result fields in same response

---

## What Agents Do With Each Category

### transient + isRetryable: true
```
→ Agent waits and retries (with exponential backoff)
→ User sees: "Temporarily unavailable, retrying..."
```

### validation + isRetryable: false
```
→ Agent asks user to correct input
→ User sees: "Please fix: email format invalid"
```

### business + isRetryable: false
```
→ Agent explains the constraint
→ User sees: "Cannot process: account requires $100 minimum"
```

### permission + isRetryable: false
```
→ Agent escalates to human
→ User sees: "Escalating to support team (no access)"
```

---

## Anti-Patterns to Avoid

❌ Returning success with error message in `description`
```json
{
  "result": "Error: File not found"  // WRONG
}
```

❌ Returning error for valid empty result
```json
{
  "errorCategory": "transient",
  "isRetryable": true,
  "description": "No records found"  // WRONG — should be empty result
}
```

❌ Missing `errorCategory` field
```json
{
  "error": "Something went wrong",
  "isRetryable": true  // WRONG — no category
}
```

❌ Setting `isRetryable: true` for non-transient errors
```json
{
  "errorCategory": "validation",
  "isRetryable": true,  // WRONG — user won't fix it by retrying
  "description": "Invalid date"
}
```
