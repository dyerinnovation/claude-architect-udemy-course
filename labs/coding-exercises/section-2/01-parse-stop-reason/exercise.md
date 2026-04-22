---
id: s2-01-parse-stop-reason
title: "Parse stop_reason and Branch the Loop"
section: 2
lecture_ref: "2.1"
language: python
difficulty: easy
learning_objective: "Given a Claude API response dict, return 'continue' if stop_reason is 'tool_use', else 'done'."
exam_scenarios: [1, 3]
related_lectures: ["2.1", "3.1"]
estimated_minutes: 5
hints:
  - "stop_reason is a top-level field on the response dict — not inside content."
  - "Only 'tool_use' means the loop continues. Every other value ends it."
  - "Don't branch on response.content[0].type — the canonical signal is stop_reason."
  - "Use dict.get() so a missing stop_reason doesn't crash your function."
---

## Problem

In Claude's agentic control loop, every API response carries a `stop_reason`
field that tells your code whether to keep looping (because Claude wants a tool
call) or exit (because Claude is done). Getting this branch wrong is the single
most common way to break a production agent — it either terminates early or
loops forever.

A Claude API response looks like this:

```python
{
  "id": "msg_01XFDU...",
  "type": "message",
  "content": [...],
  "stop_reason": "tool_use",   # or "end_turn", "max_tokens", "stop_sequence"
  "usage": {"input_tokens": 42, "output_tokens": 31}
}
```

Write a function `next_action(response: dict) -> str` that returns:

- `"continue"` if `stop_reason` is `"tool_use"` (your agent needs to run a tool and loop back)
- `"done"` for every other value of `stop_reason` (the turn is over)

If `stop_reason` is missing entirely, return `"done"`.

### Example 1

Input:
```python
{"stop_reason": "end_turn", "content": [{"type": "text", "text": "Hello"}]}
```

Expected output: `"done"`

### Example 2

Input:
```python
{"stop_reason": "tool_use", "content": [{"type": "tool_use", "name": "get_weather"}]}
```

Expected output: `"continue"`

### Example 3

Input:
```python
{"content": []}  # no stop_reason field at all
```

Expected output: `"done"`
