# 20 Things You Must Know Cold for the Exam

**Rapid-fire reference for the 20 highest-probability concepts. Review the night before and the morning of.**

---

## The 20 Must-Know Concepts

1. **Agentic Loop Fundamentals**
   - stop_reason controls the loop: "tool_use" → execute + loop, "end_turn" → stop

2. **tool_choice Field**
   - "auto" = model chooses; "any" = model must call a tool; {"type":"tool","name":"X"} = must call specific tool

3. **Domain Weights**
   - Domain 1 (27%) > Domain 3 (20%) = Domain 4 (20%) > Domain 2 (18%) > Domain 5 (15%)

4. **Escalation Trigger: Policy Gap**
   - Escalate only when policy is silent, customer explicitly asks, or progress is blocked (NOT just frustration)

5. **Error Response Categories**
   - transient (isRetryable: true), validation/business/permission (isRetryable: false)

6. **MCP Tool Error Fields**
   - Every error needs: errorCategory, isRetryable, description (human-readable)

7. **Empty Result vs Error**
   - Empty result = success ({"result":[]}); error = operation failed (errorCategory + isRetryable)

8. **stop_reason Anti-Patterns**
   - Never parse tools from text, don't cap iterations, don't check text content for "done"

9. **Batch vs Sync Decision**
   - Batch: 50% savings, up to 24hr, no multi-turn tools; Sync: real-time, blocking workflows, iterative tool use

10. **CLAUDE.md Hierarchy**
    - Shared rules > path-specific rules (glob patterns) > personal rules; @import for linking

11. **Context Management Priority**
    - Token budget first, then prioritize high-value information, then manage conversation depth

12. **Intervention Hierarchy**
    - Level 1: explicit criteria (fix vague prompts); Level 4: architectural changes (fundamental design wrong)

13. **Structured Output Enforcement**
    - Use JSON schema in system prompt or tool requirement; programmatic validation for financial/compliance

14. **MCP Protocol Components**
    - Tools defined with input schema, error responses with category/retryable/description, resources for sharing

15. **Multi-Agent Orchestration**
    - Sequential (one agent, then next), parallel (all agents simultaneously), hierarchical (manager oversees)

16. **Confidentiality & Escalation**
    - Escalate permission denied; offer escalation to frustrated customers (don't force); explicit request = immediate escalation

17. **Built-in Tool Selection**
    - Glob: find files by name; Grep: search contents; Read: load known file; Write: new/full replace; Edit: targeted changes

18. **Conversation State in Multi-Agent**
    - Each agent has separate message history; pass context between agents via structured data/memory

19. **Context Window Strategy**
    - Reserve 20-30% for output, balance history vs system prompt, refresh conversation when approaching limit

20. **out-of-scope Topics**
    - Fine-tuning, API auth internals, MCP infrastructure, constitutional AI, embeddings, vision, streaming, prompt caching details

---

## Quick Drill Questions

**Q1:** You're designing a chatbot. When should you escalate?
**A:** When customer explicitly asks, policy is silent, or progress blocked—NOT on emotion/frustration

**Q2:** tool_choice = "any". What happens?
**A:** Model MUST call a tool (any available); never returns just text

**Q3:** MCP tool error. What fields are required?
**A:** errorCategory (transient/validation/business/permission), isRetryable (boolean), description (human-readable)

**Q4:** stop_reason = "tool_use". What's your next step?
**A:** Extract tool use block, execute tool, send results back to Claude in new message, loop again

**Q5:** When do you use Batch API?
**A:** No latency SLA, no multi-turn tool use, cost optimization priority, deterministic requests

**Q6:** What are the three levels of .claude/rules/ priority?
**A:** 1. Most specific path rule, 2. Shared rules, 3. Personal rules (path rules > shared > personal)

**Q7:** How do you distinguish empty result from error?
**A:** Empty = {"result":[]}, Success. Error = errorCategory + isRetryable, Failure

**Q8:** What's the key anti-pattern with stop_reason?
**A:** Don't parse tools from text, don't cap iterations, don't check text for "done"—use stop_reason field

**Q9:** Domain 1 is what percentage of the exam?
**A:** 27% (highest weight; make it your priority)

**Q10:** When do you use EDIT vs WRITE?
**A:** EDIT for targeted changes; WRITE for new files or complete replacement

---

## Cheat Codes

**Escalation:** Policy gap OR explicit request OR stuck (NOT emotion)

**Error Category Quick Pick:**
- Request problem? → validation
- Data state problem? → business
- No permission? → permission
- Infrastructure? → transient

**stop_reason:**
- "tool_use" → execute tool, loop
- "end_turn" → return to user, stop

**Tool Choice:**
- Model decides? → "auto"
- Must act? → "any"
- Specific action? → {"type":"tool","name":"X"}

**File Tool:**
- By name? → GLOB
- Content search? → GREP
- Read known file? → READ
- New file? → WRITE
- Modify existing? → EDIT

---

## Last-Minute Review

**Read these 3 sections the morning of the exam:**
1. Domain Weights (27% Domain 1)
2. Escalation Flowchart (know when NOT to escalate)
3. stop_reason Loop Control Flow (master the loop)

**You are most likely to see questions on:**
1. Agentic architecture (27%)
2. Prompt engineering & outputs (20%)
3. Claude Code config (20%)
4. Tool design & MCP (18%)
5. Context management (15%)

**Practice 3 skills:**
1. Tracing a stop_reason loop from start to finish
2. Deciding escalation on a customer scenario
3. Choosing the right file tool for a task
