# Quiz: Agentic Architecture (Domain 1)

## Question 1
**In a multi-turn agentic loop, what is the key difference between a stop_reason of "tool_use" and "end_turn"?**

- A) tool_use indicates the agent called a tool and expects to continue; end_turn indicates the agent has finished and should not continue
- B) tool_use is used only for synchronous calls; end_turn is for asynchronous calls
- C) tool_use means an error occurred; end_turn means success
- D) There is no functional difference; they are interchangeable terms

**Correct Answer**: A

**Explanation**: When stop_reason is "tool_use", the agent has called a tool and the control loop should continue—the tool result will be fed back to the agent. When stop_reason is "end_turn", the agent has completed its reasoning and should not continue the loop. Understanding this distinction is critical for implementing proper multi-turn control flow. Incorrect handling leads to either premature termination or infinite loops.

**Domain**: Domain 1 - Agentic Architecture

---

## Question 2
**When spawning a subagent to handle a specific task, what must the allowedTools parameter include?**

- A) All tools that the subagent might theoretically need, including tools it will never use
- B) A copy of the parent agent's entire tool list
- C) The "Task" tool to allow the subagent to accept its task specification
- D) At least three tools; single-tool subagents are not allowed

**Correct Answer**: C

**Explanation**: For a subagent to properly receive and understand its task, the allowedTools list must include the "Task" tool. This tool enables the subagent to formally accept the task parameters passed from the parent agent. Without "Task" in allowedTools, the subagent cannot properly initialize and may fail or behave unpredictably. This is a structural requirement of subagent spawning patterns.

**Domain**: Domain 1 - Agentic Architecture

---

## Question 3
**When should you enforce a constraint programmatically versus through the prompt?**

- A) Always use prompt enforcement for simplicity
- B) Always use programmatic enforcement for consistency
- C) Use programmatic enforcement for hard constraints (must not happen); use prompt enforcement for soft guidelines (should usually happen)
- D) Use prompt enforcement only when you know the model perfectly; programmatic only as a fallback

**Correct Answer**: C

**Explanation**: Hard constraints—boundaries that must never be crossed—should be enforced programmatically (e.g., through allowed_tools restrictions, tool_choice settings, or response parsing). Soft guidelines and preferences can be enforced through the prompt because Claude naturally tends to follow instructions. For example: "never use tool X" is programmatic (don't include X in allowed_tools), while "prefer brief responses" is prompt-based. This separation ensures critical constraints cannot be bypassed.

**Domain**: Domain 1 - Agentic Architecture

---

## Question 4
**When implementing parallel subagent execution, what should happen from the parent agent's perspective?**

- A) Each subagent sends a separate turn to the parent, and the parent processes them sequentially
- B) All subagents complete their work, and their results are combined into a single response to the parent
- C) The parent must spawn subagents in sequence, waiting for each to complete before spawning the next
- D) Parallel execution is not supported; subagents must be chained in series

**Correct Answer**: B

**Explanation**: True parallel subagent execution means spawning multiple subagents simultaneously (or near-simultaneously) and collecting all their results into a single, unified response back to the parent agent. This avoids multiple sequential turns and maintains a clean logical flow. From the parent's perspective, it receives one aggregated response containing all subagent outputs, not separate turns for each subagent.

**Domain**: Domain 1 - Agentic Architecture

---

## Question 5
**What is the primary risk of overly narrow task decomposition when breaking work into subagents?**

- A) Subagents will refuse to complete their narrow tasks
- B) Task decomposition creates redundant, overlapping subagents that duplicate work and lose context
- C) Narrow tasks reduce flexibility and increase coordination overhead; context gets fragmented across too many subagents
- D) Narrowly scoped tasks make the system run faster but less accurately

**Correct Answer**: C

**Explanation**: Decomposing a task into too many narrow subagents creates several problems: increased coordination complexity, context fragmentation (each subagent only understands its tiny slice), redundant work, and higher latency. A task should be decomposed into logically cohesive units that a single agent can competently handle, not into artificially narrow slivers. The goal is semantic decomposition, not just task granularity.

**Domain**: Domain 1 - Agentic Architecture

---

## Question 6
**When an agentic system completes a subtask and needs to move to the next phase, when should you "resume" the agent versus start with a "fresh" agent?**

- A) Always resume to preserve context and memory
- B) Always start fresh to ensure clean state
- C) Resume if the agent has relevant context from the previous phase; start fresh if the new phase requires different domain expertise or the history would be a distraction
- D) The choice has no practical impact; they produce equivalent results

**Correct Answer**: C

**Explanation**: Resuming an existing agent makes sense when it has valuable context from the previous phase (e.g., a code reviewer continuing after initial review). Starting fresh makes sense when the new phase requires different expertise (switching from code analysis to documentation writing) or when the prior history would clutter the context window with irrelevant information. The decision depends on whether prior context helps or hurts the agent's performance.

**Domain**: Domain 1 - Agentic Architecture

---

## Question 7
**What is the primary purpose of a PostToolUse hook in an agentic system?**

- A) To validate that the tool executed without errors
- B) To normalize heterogeneous tool outputs into a consistent format before feeding results back to the agent
- C) To add latency for rate limiting
- D) To prevent the agent from calling certain tools

**Correct Answer**: B

**Explanation**: A PostToolUse hook intercepts tool results and can transform them into a normalized, consistent format. This is essential when different tools return data in different structures (one returns JSON, another returns plain text, a third returns a nested object). The hook ensures the agent always receives predictable, well-structured data regardless of the underlying tool's output format, improving reliability and agent reasoning.

**Domain**: Domain 1 - Agentic Architecture

---

## Question 8
**When a parent agent spawns a subagent, what should the subagent inherit from the parent?**

- A) The entire conversation history so the subagent has full context
- B) The parent's system prompt and all configuration
- C) The task specification, system prompt, and tools—but not the conversation history (isolation)
- D) Nothing; subagents are completely independent entities

**Correct Answer**: C

**Explanation**: Subagents should be isolated from the parent's conversation history to keep their context focused and prevent distraction. However, they need the task specification (what they're supposed to do), system prompt or instructions, and the list of allowed tools. This isolation principle ensures each subagent has a clear, bounded scope and doesn't get confused by the parent's previous reasoning or context.

**Domain**: Domain 1 - Agentic Architecture

---

## Question 9
**What is the primary architectural value of the hub-and-spoke pattern in agentic systems?**

- A) It distributes work evenly across all subagents for load balancing
- B) It enables centralized observability, control, and coordination while keeping subagents focused and independent
- C) It allows subagents to communicate directly without the parent's involvement
- D) It reduces the number of API calls by batching requests

**Correct Answer**: B

**Explanation**: The hub-and-spoke pattern (one central coordinating agent with multiple specialized subagents) provides centralized oversight and control. The hub can see all subagent results, coordinate between them, make routing decisions, and observe the overall system behavior. Meanwhile, each spoke (subagent) remains focused on its specific domain. This is superior to peer-to-peer patterns where observability is lost and coordination is implicit.

**Domain**: Domain 1 - Agentic Architecture

---

## Question 10
**When handing off work between agents in a structured workflow, what are the essential elements that must be included in the handoff summary?**

- A) Just the final answer to avoid overwhelming the next agent
- B) Current state, key decisions made, remaining work, and any critical context needed by the next agent
- C) A complete replay of all tool calls and their results
- D) The handoff summary is optional; agents should restart analysis from scratch

**Correct Answer**: B

**Explanation**: An effective handoff summary documents the current state (what's been done), key decisions and reasoning (why choices were made), what remains (what the next agent needs to do), and critical context (facts, constraints, dependencies). This structure prevents duplicate work, maintains coherence across the hand-off, and gives the next agent a clear starting point. Omitting any of these elements risks losing important information or requiring the next agent to redo work.

**Domain**: Domain 1 - Agentic Architecture
