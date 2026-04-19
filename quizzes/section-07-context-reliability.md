# Quiz: Context and Reliability (Domain 5)

## Question 1
**What is the "lost in the middle" effect, and how does it impact agentic systems?**

- A) The model forgets information when the context window grows beyond 100K tokens
- B) Critical information placed in the middle of a long context is less attended to than information at the beginning or end
- C) The model cannot process tokens after the midpoint of the context window
- D) The effect is only relevant for very short contexts; it doesn't matter for large systems

**Correct Answer**: B

**Explanation**: The "lost in the middle" effect describes a phenomenon where the model's attention weakens for information in the middle of a long context. Critical information at the beginning or end is more reliably retained than equally important information buried in the middle. For agentic systems, this means you should place crucial context (task specification, key constraints, recent results) at the beginning or use explicit markers to highlight important information rather than letting it get lost in the middle of a large document.

**Domain**: Domain 5 - Context and Reliability

---

## Question 2
**What information must a structured error response from a subagent contain?**

- A) Just the error message
- B) Error type, whether it's retryable, and detailed description
- C) Current state, error details, suggested recovery action, and remaining work
- D) Stack trace and error code

**Correct Answer**: C

**Explanation**: A comprehensive error response from a subagent should include: (1) current state—what was completed before the error, (2) error details—what went wrong and why, (3) suggested recovery action—what to do next, (4) remaining work—what still needs to be done. This structure allows the parent agent to make intelligent decisions about recovery, escalation, or alternative approaches rather than just receiving a failure message.

**Domain**: Domain 5 - Context and Reliability

---

## Question 3
**When should escalation happen immediately, without attempting recovery?**

- A) For any error; try escalating before anything else
- B) When a customer explicitly requests human involvement
- C) Only for errors that occur repeatedly despite retry attempts
- D) Escalation should never be immediate; always attempt recovery first

**Correct Answer**: B

**Explanation**: Escalation should be immediate when a customer explicitly requests human involvement—this is not an error condition to troubleshoot but a request that must be honored. Other errors may warrant retry or alternative approaches, but customer requests bypass the technical troubleshooting process. Respecting explicit user requests is a critical reliability principle.

**Domain**: Domain 5 - Context and Reliability

---

## Question 4
**What is the purpose of stratified random sampling in evaluating agentic system reliability?**

- A) To make testing go faster by sampling only the easiest cases
- B) To ensure representative testing across different input categories (strata) rather than biased sampling
- C) To guarantee 100% test coverage
- D) Stratified sampling is outdated; modern systems should use uniform random sampling only

**Correct Answer**: B

**Explanation**: Stratified random sampling divides test data into groups (strata)—e.g., easy cases, medium cases, hard cases; or common inputs, edge cases, rare cases—then samples randomly from each stratum. This ensures you don't accidentally oversample easy cases and miss hard cases (or vice versa), giving you a representative view of system reliability. Uniform random sampling can lead to biased coverage where some important categories are underrepresented.

**Domain**: Domain 5 - Context and Reliability

---

## Question 5
**When your agentic system receives conflicting information from multiple sources, what should it do?**

- A) Choose the source that seems most authoritative and ignore the others
- B) Average or synthesize the sources without noting the conflict
- C) Annotate the conflict explicitly and present both/all perspectives rather than choosing
- D) Escalate as a failure; conflicting sources indicate a system problem

**Correct Answer**: C

**Explanation**: Conflicting sources should be explicitly annotated and presented to the user or next agent. Making an arbitrary choice between sources (even if well-reasoned) risks propagating incorrect information. Documenting the conflict ("Source A says X, Source B says Y") preserves transparency and allows humans to make the final judgment. This approach maintains reliability through honesty about uncertainty rather than hiding conflicts.

**Domain**: Domain 5 - Context and Reliability

---

## Question 6
**What is the "persistent case facts block" pattern, and how does it improve reliability?**

- A) It's a memory technique for agents to remember all previous cases
- B) It's a stored summary of key facts about the case that gets included in every prompt to prevent losing critical context
- C) It's a database that stores all historical case data indefinitely
- D) It's not a recognized pattern in agentic system design

**Correct Answer**: B

**Explanation**: The persistent case facts block is a summary of key facts (names, dates, amounts, constraints, decisions made) that stays included in the system prompt or context for the entire case. As agents work on the case, this block prevents losing critical information to context window constraints or across agent handoffs. It acts as a safety net, ensuring crucial facts are always available rather than getting lost as context grows.

**Domain**: Domain 5 - Context and Reliability

---

## Question 7
**What are the signs that an agentic system is experiencing context degradation?**

- A) The system is running slowly
- B) Repeated errors, inconsistent reasoning, agents forgetting earlier decisions or context, contradictory outputs
- C) The system uses more tokens than expected
- D) Context degradation cannot be detected; it's a theoretical concern only

**Correct Answer**: B

**Explanation**: Signs of context degradation include: (1) agents behaving inconsistently or making contradictory decisions across turns, (2) agents forgetting facts or constraints established earlier, (3) repeated errors despite fixing root causes (suggesting context got corrupted), (4) reasoning quality declining over long sessions. These indicate that critical context is being lost or distorted as the system operates. Monitoring for these patterns helps identify reliability issues before they become critical failures.

**Domain**: Domain 5 - Context and Reliability

---

## Question 8
**How should a tool distinguish between "access failure" (the tool couldn't execute) and "valid empty result" (the tool executed but found nothing)?**

- A) Use HTTP status codes; 200 means empty result, 4xx means access failure
- B) Include an explicit success/error field; empty data with success=true means nothing found; error details with success=false means the tool failed
- C) Empty results always indicate failure
- D) There's no meaningful distinction; treat all empty results the same

**Correct Answer**: B

**Explanation**: Always include an explicit status field in tool responses. An empty result with success=true indicates the tool executed correctly but returned no data (valid outcome). An error response with success=false indicates the tool couldn't execute (invalid permission, network error, etc.). Without this distinction, the agent cannot reason correctly about what happened—it can't tell whether to retry, escalate, or proceed knowing legitimately no data exists.

**Domain**: Domain 5 - Context and Reliability
