# tool_choice Quick Reference

## The Three Options

### 1. `"auto"` (Default)
```json
{
  "tool_choice": "auto"
}
```

**Behavior:** Model decides whether to use a tool or return text

**When to Use:**
- Open-ended analysis or discussion
- When tool use is optional
- Customer asking for information, not action
- Exploratory queries

**Example:**
```json
{
  "messages": [{"role": "user", "content": "What tools could I use to check inventory?"}],
  "tools": [...],
  "tool_choice": "auto"
}
```
→ Model returns text explanation (no tool required)

---

### 2. `"any"` or `"required"`
```json
{
  "tool_choice": "any"
}
```

**Behavior:** Model MUST call a tool (picks any available)

**When to Use:**
- Action is mandatory (e.g., "check the system NOW")
- Preventing fallback to text when tool exists
- Enforcing determinism in critical operations
- Tool use is non-negotiable

**Example:**
```json
{
  "messages": [{"role": "user", "content": "Process this payment immediately"}],
  "tools": [{"name": "process_payment"}, {"name": "create_backup"}],
  "tool_choice": "any"
}
```
→ Model MUST call one of the tools (never returns text)

---

### 3. `{"type": "tool", "name": "X"}`
```json
{
  "tool_choice": {"type": "tool", "name": "process_payment"}
}
```

**Behavior:** Model MUST call the specific named tool

**When to Use:**
- Only one tool is valid for the task
- Safety-critical operations (payment, deletion, escalation)
- Forcing a specific workflow
- No ambiguity allowed

**Example:**
```json
{
  "messages": [{"role": "user", "content": "Cancel my subscription"}],
  "tools": [
    {"name": "cancel_subscription"},
    {"name": "pause_subscription"}
  ],
  "tool_choice": {"type": "tool", "name": "cancel_subscription"}
}
```
→ Model calls ONLY cancel_subscription, never pause_subscription

---

## Decision Tree

```
Does the model have a CHOICE about taking action?
    ├─ YES → "auto"
    │   (e.g., "What could we do?" "Tell me about this")
    │
    ├─ NO: Must take some action
    │   ├─ Action is critical/safety-sensitive
    │   │   └─ Specific tool required? → {"type": "tool", "name": "X"}
    │   │   └─ Any tool OK? → "any"
    │   │
    │   └─ Action is flexible
    │       └─ "any"
```

---

## Real-World Scenarios

### Scenario A: User asks for help
```
User: "How do I check my account balance?"
tool_choice: "auto"
```
→ Model explains how (text), doesn't run tool

### Scenario B: User demands action
```
User: "Check my balance now"
tool_choice: "any"  // or specific tool
```
→ Model must call a tool

### Scenario C: Financial transaction
```
User: "Transfer $500 to savings"
tool_choice: {"type": "tool", "name": "transfer_funds"}
```
→ Only transfer_funds allowed (not check_balance)

### Scenario D: Escalation required
```
User: "I'm furious and need to speak to someone"
tool_choice: {"type": "tool", "name": "escalate_to_human"}
```
→ Forces escalation (no text handling)

---

## Common Mistakes

❌ Using `"any"` when `"auto"` is appropriate
- Wastes tool calls on optional actions
- Breaks natural conversation flow

❌ Using `{"type": "tool", "name": "X"}` too liberally
- Can force invalid operations
- Should only use for critical decisions

❌ Not specifying tool_choice
- Defaults to "auto"
- May not enforce action when needed

---

## Key Insight

**Tool choice is about control and determinism.**

- `"auto"` = trust the model
- `"any"` = action is mandatory
- `{"type": "tool", "name": "X"}` = THIS action is mandatory
