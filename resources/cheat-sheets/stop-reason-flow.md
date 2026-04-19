# stop_reason Loop Control Flow

## The Agentic Loop: The Core Concept

```
┌──────────────────────────────┐
│ 1. Send request + tools      │
│    to Claude                 │
└──────────────┬───────────────┘
               │
        ┌──────▼──────────┐
        │ 2. Receive       │
        │    response      │
        └──────┬───────────┘
               │
    ┌──────────▼──────────────┐
    │ 3. Check stop_reason     │
    └───┬──────────────────┬───┘
        │                  │
   "tool_use"         "end_turn"
        │                  │
   ┌────▼────┐        ┌────▼────┐
   │ 4a. Execute│      │ 4b. Done │
   │    tool(s) │      │    Stop  │
   └────┬────┘        └──────────┘
        │
   ┌────▼──────────────┐
   │ 5. Send results   │
   │    back to Claude │
   └────┬───────────────┘
        │
        └──────────────────────┐
                               │
                    (loop back to step 1)
```

---

## The Decision at Step 3: Inspecting stop_reason

### Option A: stop_reason = "tool_use"
```json
{
  "stop_reason": "tool_use",
  "content": [
    {
      "type": "tool_use",
      "id": "call_12345",
      "name": "search_documents",
      "input": {"query": "Claude MCP"}
    }
  ]
}
```

**What to do:**
1. Extract tool_use block
2. Execute the tool
3. Capture result
4. Send result back to Claude (in new message, role: user, content: tool_result)
5. **Loop back to step 1** — send new request with tool results

---

### Option B: stop_reason = "end_turn"
```json
{
  "stop_reason": "end_turn",
  "content": [
    {
      "type": "text",
      "text": "Based on the documents, MCP is a protocol for..."
    }
  ]
}
```

**What to do:**
1. Extract text response
2. Return to user
3. **STOP** — conversation finished

---

## Practical Loop Example

### Iteration 1: Tool-use
```
Request:
{
  "model": "claude-sonnet-4-6",
  "messages": [{"role": "user", "content": "What is MCP?"}],
  "tools": [{"name": "search_documents", ...}]
}

Response:
{
  "stop_reason": "tool_use",
  "content": [{
    "type": "tool_use",
    "name": "search_documents",
    "input": {"query": "MCP protocol"}
  }]
}

Action: Execute search → find results
```

### Iteration 2: Send Results
```
Request:
{
  "model": "claude-sonnet-4-6",
  "messages": [
    {"role": "user", "content": "What is MCP?"},
    {"role": "assistant", "content": [{"type": "tool_use", "name": "search_documents", ...}]},
    {"role": "user", "content": [{"type": "tool_result", "tool_use_id": "...", "content": "[MCP docs found]"}]}
  ],
  "tools": [...]
}

Response:
{
  "stop_reason": "end_turn",
  "content": [{"type": "text", "text": "MCP is a protocol for..."}]
}

Action: Return text to user; STOP
```

---

## Anti-Patterns (Things NOT to Do)

### ❌ Anti-Pattern 1: Parsing Text Content
```python
# WRONG
response = claude_api.messages.create(...)
if "tool" in response.content[0].text:
    # Try to parse text as tool call
    parse_tool_from_text()
```

**Why it's wrong:**
- Tool calls are structured in `tool_use` blocks
- Never try to parse tools from text
- Text and tools are separate

**Correct way:**
```python
# RIGHT
for block in response.content:
    if block.type == "tool_use":
        execute_tool(block)
    elif block.type == "text":
        return_to_user(block.text)
```

---

### ❌ Anti-Pattern 2: Capping Iterations Arbitrarily
```python
# WRONG
iterations = 0
while True:
    response = call_claude()
    iterations += 1
    if iterations > 5:  # Just quit after 5
        return "Gave up"
```

**Why it's wrong:**
- Legitimate workflows may need more than 5 iterations
- Should loop until `stop_reason = "end_turn"`
- Iteration cap loses valid results

**Correct way:**
```python
# RIGHT
while True:
    response = call_claude()
    if response.stop_reason == "end_turn":
        return response.content[0].text
    elif response.stop_reason == "tool_use":
        # Execute tools, loop continues
        execute_tools()
```

---

### ❌ Anti-Pattern 3: Checking Text Content for "Done"
```python
# WRONG
response = call_claude()
if "done" in response.content[0].text:
    stop_looping()
else:
    continue_looping()
```

**Why it's wrong:**
- Text content is unreliable signal
- Model might say "done" but still have tool_use
- `stop_reason` is the actual signal

**Correct way:**
```python
# RIGHT
response = call_claude()
if response.stop_reason == "end_turn":
    stop_looping()
elif response.stop_reason == "tool_use":
    continue_looping()
```

---

## stop_reason Values Reference

| Value | Meaning | Action |
|-------|---------|--------|
| `"tool_use"` | Model called a tool | Execute tool, loop |
| `"end_turn"` | Model finished | Stop, return result |
| `"max_tokens"` | Hit token limit | Can continue with new request |
| `"stop_sequence"` | Hit custom stop sequence | Stop (rare) |

---

## Loop Termination Conditions

**The loop CONTINUES when:**
- `stop_reason == "tool_use"` (more work to do)

**The loop STOPS when:**
- `stop_reason == "end_turn"` (natural finish)
- `stop_reason == "max_tokens"` (optional: can continue or stop)
- Error occurs (fallback)
- User cancels

**DO NOT stop on:**
- Iteration count
- Text content analysis
- Sentiment/confidence guess

---

## Pseudocode Template

```python
def agentic_loop(user_query, tools):
    messages = [{"role": "user", "content": user_query}]

    while True:
        # Step 1: Send to Claude
        response = claude_api.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=2048,
            messages=messages,
            tools=tools
        )

        # Step 2: Check stop_reason
        if response.stop_reason == "end_turn":
            # We're done
            return extract_text(response.content)

        elif response.stop_reason == "tool_use":
            # Execute tools
            assistant_message = {"role": "assistant", "content": response.content}
            messages.append(assistant_message)

            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    result = execute_tool(block.name, block.input)
                    tool_results.append({
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": result
                    })

            # Step 3: Send results back
            messages.append({
                "role": "user",
                "content": tool_results
            })
            # Loop continues...

        else:
            # Handle other stop reasons
            break

    return None
```

---

## Key Insight

**The loop is controlled by `stop_reason`, not by guessing, text parsing, or iteration caps.**

- Check `stop_reason` at each iteration
- `"tool_use"` → execute + loop
- `"end_turn"` → return to user + stop
- Never parse tools from text
- Never cap iterations arbitrarily
