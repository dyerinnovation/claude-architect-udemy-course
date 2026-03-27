# Batch API vs Synchronous API Decision Table

## Quick Comparison

| Aspect | Batch API | Synchronous API |
|--------|-----------|-----------------|
| **Cost** | 50% savings | Full price |
| **Latency** | Up to 24 hours | Real-time (seconds) |
| **Latency SLA** | None (best-effort) | Yes (guaranteed) |
| **Multi-turn Tools** | ❌ No | ✓ Yes |
| **Tool Calling** | Single-turn only | Looping/iterative |
| **Request Size** | 100 requests/batch | Single request |
| **Use Case** | Non-urgent bulk | Blocking workflows |

---

## When to Use Batch API

### Characteristic 1: No Time Pressure
- Report generation (daily/weekly)
- Content moderation queue
- Data transformation jobs
- Overnight data processing

**Example:**
```
"Generate analytics report for Q1 2026"
→ Schedule in batch for 2 AM
→ Results ready by morning
```

### Characteristic 2: No Tool-Use Loop Required
- Simple classification tasks
- One-pass analysis
- No need to call tools and respond to results
- Everything needed in initial prompt

**Example:**
```
Request: "Classify these 500 emails by category"
→ No need to respond to results
→ Just batch classify
→ Perfect for batch API
```

### Characteristic 3: Cost Optimization is Priority
- Large volume of requests
- Bulk processing
- Can tolerate latency

**Example:**
```
Processing 10,000 customer feedback items
→ 50% cost savings = $500 saved
→ Wait time: 24 hours acceptable
→ Use batch API
```

### Characteristic 4: Deterministic (No Backoff)
- Same request set regardless of outcomes
- No conditional retry logic needed
- Fire-and-forget model works

---

## When to Use Synchronous API

### Characteristic 1: Blocking Workflow
- User waiting for response
- Time-sensitive operations
- Real-time required

**Example:**
```
Customer: "Check my balance"
→ Requires immediate response
→ Use synchronous API
```

### Characteristic 2: Multi-Turn Tool Calling
- Agent needs to inspect results and act
- Iterative problem-solving
- Tools call other tools

**Example:**
```
1. Call search_database
2. Inspect results
3. If empty, call retry_with_broader_search
4. Inspect again
5. Format results
→ Requires synchronous API (multi-turn)
```

### Characteristic 3: Conditional Logic
- Response depends on previous results
- Branching based on tool outcomes
- Dynamic flow

**Example:**
```
1. Try payment with Card A
   → Declined? → Try Card B
   → Declined? → Offer PayPal
→ Requires synchronous API (conditional)
```

---

## Decision Matrix

```
Is there a latency SLA?
  ├─ YES → Synchronous API
  │   (User is waiting; must be fast)
  │
  └─ NO: Need multi-turn tool calling?
      ├─ YES → Synchronous API
      │   (Agent needs to loop)
      │
      └─ NO: Cost sensitive?
          ├─ YES → Batch API
          │   (Save 50%, handle latency)
          │
          └─ NO: Volume high + one-shot?
              ├─ YES → Batch API
              │   (Bulk processing, fire-and-forget)
              │
              └─ NO → Synchronous API
                  (Default: real-time preferred)
```

---

## Real-World Examples

### Example 1: Pre-Merge Code Review
```
Scenario: Reviewing code before committing
Latency: Developer waiting at terminal
Tool Loop: May need to inspect code structure, ask follow-up questions
Decision: SYNCHRONOUS API
Reason: Blocking workflow, interactive tool use
```

### Example 2: Overnight Report Generation
```
Scenario: Generating daily analytics report
Latency: No rush; ready by 6 AM OK
Tool Loop: Simple template processing, no multi-turn
Decision: BATCH API
Reason: No SLA, deterministic, cost savings matter
```

### Example 3: Weekly Audit Processing
```
Scenario: Processing 1000 compliance documents
Latency: Results needed by Friday OK
Tool Loop: Single classification pass, no branches
Decision: BATCH API
Reason: Bulk volume, no real-time need, cost optimization
```

### Example 4: Customer Chat Session
```
Scenario: Customer asking support questions live
Latency: Must respond within seconds
Tool Loop: May need to look up account, check policies, etc.
Decision: SYNCHRONOUS API
Reason: User is waiting; interactive tool calling likely
```

### Example 5: Content Batch Tagging
```
Scenario: Tag 5000 blog posts by topic
Latency: Complete by next week
Tool Loop: None; just classification
Decision: BATCH API
Reason: High volume, no SLA, deterministic, save cost
```

---

## Cost Impact Example

**Scenario:** Processing 10,000 requests

```
Synchronous API:
  10,000 requests × $0.003 = $30

Batch API:
  10,000 requests × $0.0015 = $15

Savings: 50% = $15 saved
Wait time: Up to 24 hours acceptable
Decision: Use batch API
```

---

## Key Insight

**Batch API is not cheaper because it's worse.** It's cheaper because:
- No latency SLA overhead
- Better infrastructure scheduling
- Optimized for bulk processing

Use batch API when:
1. No time pressure
2. No multi-turn tool use needed
3. Cost matters
4. Deterministic request set

Use synchronous API when:
1. User/system waiting
2. Tool-use loops required
3. Conditional logic needed
4. Time-sensitive
