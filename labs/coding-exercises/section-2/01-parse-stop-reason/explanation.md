## Why this matters

The Claude agentic control loop lives or dies on `stop_reason`. `tool_use`
means Claude is asking your code to run a tool and feed the result back in
the next message. Every other `stop_reason` value means the turn is over and
you should return the final response to the user.

## The trap

A common wrong answer: checking `response["content"][0]["type"]` for a
`tool_use` block and branching on that. This works most of the time, but
`stop_reason` is the **canonical** signal — it's the field Anthropic's API
guarantees will be set correctly. Branching off content-block types mixes two
concerns (what Claude said vs. why Claude stopped) and will eventually bite
you when the shape of `content` changes.

Rule of thumb: **the control loop branches on `stop_reason`. Full stop.**

## The solution, line by line

```python
def next_action(response: dict) -> str:
    if response.get("stop_reason") == "tool_use":
        return "continue"
    return "done"
```

- `response.get("stop_reason")` returns `None` if the field is missing, so a
  malformed response defaults to `"done"` — exit gracefully rather than
  crashing the loop.
- `"tool_use"` is the only value that keeps the loop running. Every other
  value — `"end_turn"`, `"max_tokens"`, `"stop_sequence"`, `None`, anything
  unexpected — returns the final response to the user.
- Default to safety: the function biases toward exiting the loop when the
  signal is ambiguous. That's the right tradeoff — a premature exit is
  easier to debug than an infinite loop.

## Exam relevance

**Scenarios 1 and 3** both test variations of this. Typical distractors:

- "Inspect `response.content[0].type` for `'tool_use'`" — plausible but wrong
  for the reason above.
- "Check `response.usage.output_tokens > 0`" — nonsense, but tests whether
  you understand what `usage` is actually for.
- "Loop if `response.role == 'tool'`" — `role` is `'assistant'` on every
  response; tests whether you know the message shape.

If you saw the wrong answer and said "oh that looks right," you just learned
the core trap of this exam: **almost-right is the whole trap**.
