# Practice Exam: Claude Certified Architect (40 Questions)

**Instructions**: This 40-question practice exam mirrors the structure and difficulty of the actual certification exam. It includes scenario-based questions weighted to match domain proportions: Domain 1 (27% - 11 questions), Domain 2 (25% - 10 questions), Domain 3 (22% - 9 questions), Domain 4 (20% - 8 questions), Domain 5 (12% - 2 questions).

Each question includes a scenario requiring judgment, not just trivia. For passing practice, aim for 29/40 (72.5%), matching the actual passing score ratio.

---

## Domain 1: Agentic Architecture (11 Questions)

### Question 1
**Scenario**: You're building a customer support system where an initial intake agent gathers customer information, then passes the case to a specialized resolution agent. The resolution agent needs specific customer facts (name, account number, issue summary) but shouldn't inherit the entire conversation history with all the back-and-forth diagnostic questions.

**What is the best approach for this handoff?**

- A) Pass the entire conversation history so the resolution agent has complete context
- B) Create a handoff summary containing current state, key facts, and remaining work; the resolution agent receives only this summary
- C) Have both agents work in the same conversation thread without a formal handoff
- D) Have the resolution agent start completely fresh and ask the customer to re-explain the issue

**Correct Answer**: B

**Explanation**: A structured handoff summary with current state, critical facts, and remaining work is the best approach. This gives the resolution agent what it needs without overwhelming it with diagnostic minutiae. Option A leads to context window waste; Option C confuses roles; Option D frustrates customers. The handoff pattern maintains coherence while keeping each agent's context focused.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 2
**Scenario**: You're implementing a hub-and-spoke agentic system with one coordinator agent and three specialist subagents (Code Review, Testing, Documentation). All three specialists need to complete their work in parallel before the coordinator can synthesize results. Currently, you're spawning them sequentially and waiting for each to finish.

**What's the best optimization?**

- A) Spawn all three subagents simultaneously, collect all their results, then return one unified response to the coordinator
- B) Continue sequential spawning; parallelism isn't worth the added complexity
- C) Create a fourth "Aggregation" subagent that coordinates the specialists
- D) Have subagents communicate directly with each other rather than through the coordinator

**Correct Answer**: A

**Explanation**: Spawning all three subagents simultaneously (true parallel execution) and collecting their results into one response maintains the hub-and-spoke pattern's clarity while improving efficiency. The coordinator sees one result containing all three specialist outputs, avoiding multiple sequential turns. Option B misses optimization; Option C adds unnecessary complexity; Option D loses centralized observability, which is the hub-and-spoke pattern's core value.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 3
**Scenario**: You're designing task decomposition for a system that analyzes legal documents. The task is: "Review contract for liability clauses, extract payment terms, check for non-compete restrictions, verify signature validity, and identify counterparty credentials."

**Which decomposition strategy is most appropriate?**

- A) Five subagents: one for each bullet point (highest granularity)
- B) Two subagents: one for all legal analysis, one for signature/credentials verification
- C) Three subagents: Legal Analysis, Signature Verification, Counterparty Review (semantic grouping)
- D) One agent for the entire contract; don't decompose

**Correct Answer**: C

**Explanation**: Option C groups related tasks semantically: Legal Analysis includes liability and payment terms (related document interpretation), Signature Verification is its own domain, and Counterparty Review is a distinct task. This avoids the pitfalls of Option A (too granular, excessive coordination overhead) and Option D (too broad, conflicting expertise). Option B creates poorly balanced groups. The goal is logically coherent units, not strict granularity.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 4
**Scenario**: Your agentic system encounters an error in a subagent: "Database connection timeout." The parent agent currently has no retry logic or recovery strategy.

**What should the parent agent do?**

- A) Immediately escalate to a human; the system has failed
- B) Programmatically implement retry logic with exponential backoff, then escalate if retries exhaust
- C) Use prompt-only instructions telling the subagent to "try again if you get an error"
- D) Ignore the error and proceed as if the operation succeeded

**Correct Answer**: B

**Explanation**: Option B implements a proper recovery strategy: programmatic retry logic (not prompt-based, which is unreliable) with exponential backoff to avoid overwhelming a recovering service. If retries exhaust, escalate. Option A over-escalates a recoverable error; Option C (prompt-only) is too soft for critical operations; Option D causes silent failures. Hard constraints (retry behavior) belong in code, not prompts.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 5
**Scenario**: You're building a code generation system where an initial agent writes code, then a review agent evaluates it. The review agent's job is to identify issues—not fix them. Currently, you're using the same agent instance for both roles by changing the prompt.

**What's a better architectural approach?**

- A) Keep using one agent instance; changing the prompt is sufficient
- B) Create two separate agent instances with different system prompts, tools, and allowed_tools
- C) Add a third agent that resolves conflicts between the code writer and reviewer
- D) Give the reviewer agent all the same tools as the writer, so it can fix issues itself

**Correct Answer**: B

**Explanation**: Separate agent instances with distinct prompts and allowed_tools create clear role separation and prevent role confusion. The reviewer doesn't need write/execute tools; the generator doesn't need critique tools. Option A works but risks the agent slipping between roles; Option C adds unjustified complexity; Option D defeats the review-separation benefit. Distinct instances enforce architectural intent.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 6
**Scenario**: In your multi-turn agentic system, you're implementing control logic to detect when an agent should stop looping. The agent just returned with stop_reason "tool_use".

**What should your control logic do?**

- A) Stop the loop; the agent is done
- B) Continue the loop; the agent called a tool and expects to see results
- C) Check the response message; if it contains text, stop; if it only has tool calls, continue
- D) Ask the user whether to continue

**Correct Answer**: B

**Explanation**: stop_reason "tool_use" is an explicit signal to continue: the agent called a tool and expects to see results in the next turn. Option A terminates prematurely. Option C is unreliable (the agent might have both text and tool calls). Option D adds unnecessary interactivity. The stop_reason field is the ground truth for control flow.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 7
**Scenario**: You're implementing a PostToolUse hook in your agentic system. A search tool sometimes returns results in JSON format, sometimes as plain text. The agent gets confused by inconsistent formats.

**What should the PostToolUse hook do?**

- A) Pass results through unchanged; the agent should adapt to different formats
- B) Normalize all results to a consistent format (e.g., always JSON) before the agent sees them
- C) Filter results to remove confusing formats
- D) Log format discrepancies but don't modify results

**Correct Answer**: B

**Explanation**: The PostToolUse hook's job is to normalize heterogeneous outputs into consistent format. Transform varying tool outputs (JSON, text, XML) into a unified format before the agent sees them. This eliminates confusion and improves reasoning. Option A passes the agent's problem to the agent; Option C loses information; Option D merely observes without solving the problem.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 8
**Scenario**: You're designing a subagent that needs to read files, but you've excluded the "Read" tool from its allowed_tools list because it's not needed for its specific task. However, the task description mentions "read the configuration file."

**What will happen?**

- A) The subagent will read the configuration file anyway; the system always provides what's needed
- B) The subagent will ask the parent to read the file for it
- C) The subagent will fail or report that it cannot read the file
- D) The subagent will hallucinate configuration contents instead

**Correct Answer**: C

**Explanation**: If a tool isn't in allowed_tools, the subagent cannot use it, period. There's no magical provision of needed tools. Option A assumes the system is psychic; Option B is plausible behavior but isn't guaranteed; Option D (hallucination) is a risk, especially if the agent tries to reason around the lack of a tool. This illustrates why allowed_tools must include all tools the subagent might need. Task and tools must be aligned.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 9
**Scenario**: Your hub-and-spoke system has a coordinator agent and five specialist subagents. You're trying to add a sixth specialist, but you're concerned about complexity. Observability is important to you.

**What does the hub-and-spoke pattern preserve that a direct peer-to-peer network among subagents would lose?**

- A) Speed; hub-and-spoke is faster
- B) Centralized observability and control; you see all results in one place
- C) Cost efficiency; fewer API calls
- D) Error recovery; hub-and-spoke never fails

**Correct Answer**: B

**Explanation**: The hub-and-spoke pattern's core value is centralized observability: all specialist results flow through the coordinator, giving you a single point to see everything, make decisions, and control flow. A peer-to-peer network where specialists communicate directly would lose this visibility and control. Option A (speed) is neutral or slightly worse. Option C (cost) is actually worse with hub-and-spoke. Option D is false; architecture doesn't prevent failures.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 10
**Scenario**: You're resuming work on a case that was previously handled by another agent. That agent made progress and included this summary: "Reviewed 15 of 20 documents. Found 3 issues. Remaining: 5 documents to review, and determine priority of issues."

**What critical information is missing from this handoff?**

- A) The agent's name/ID
- B) Key facts about the case (client name, deadlines, constraints) and the nature of the 3 issues found
- C) Timestamps of when work occurred
- D) The agent's confidence level in its own work

**Correct Answer**: B

**Explanation**: A handoff summary must include not just work status ("15 of 20 reviewed") but the substantive findings ("3 issues") WITH detail about what those issues are. It should also remind the resuming agent of key case facts (client, deadlines, constraints) even though they might have been in prior context. Option A is nice-to-have but not critical. Option C and D are useful but secondary to knowing what was actually found and what the case requires.

**Domain**: Domain 1 - Agentic Architecture

---

### Question 11
**Scenario**: You're deciding whether to "resume" an existing agent or "start fresh" with a new agent for a new phase of work. The first phase analyzed a codebase and identified 5 major refactoring opportunities. The second phase must prioritize these opportunities and create implementation roadmaps.

**Which approach and why?**

- A) Resume the existing agent; it has all the context from phase 1
- B) Start fresh with a new agent; the second phase requires different expertise
- C) Resume the agent but give it explicit instructions to ignore phase 1 context
- D) Run both agents in parallel and compare their outputs

**Correct Answer**: A

**Explanation**: Resume the existing agent because the phase 2 task (prioritizing opportunities from phase 1) depends directly on phase 1's findings. The prior context about identified opportunities is essential, not a distraction. Option B abandons valuable context. Option C wastes context without benefit. Option D adds unnecessary complexity. Clear resume: when new work depends on prior findings.

**Domain**: Domain 1 - Agentic Architecture

---

## Domain 2: Tool Design and MCP (10 Questions)

### Question 12
**Scenario**: You're designing MCP tools for a system that needs to search files by name, search file contents, read files, and write files. You're trying to decide how many distinct tools to create.

**What's the optimal tool count?**

- A) One tool called "FileOperations" that does everything
- B) Four separate tools: SearchByName, SearchContents, ReadFile, WriteFile
- C) Two tools: Search (combining name and content search) and Modify (read and write)
- D) As many as needed; tool count doesn't matter

**Correct Answer**: C

**Explanation**: C groups semantically: Search operations together, Modification operations together. This gives the agent clear mental models (when I need to find something, use Search; when I need to change something, use Modify) without the cognitive load of four distinct tools. Option A is too monolithic. Option B creates decision paralysis for simple searches. The optimal count (4-5 tools per agent) isn't reached here, but grouping is better than both extremes.

**Domain**: Domain 2 - Tool Design and MCP

---

### Question 13
**Scenario**: You're defining an MCP error response for a tool that couldn't authenticate with an external API. The tool should indicate that the error is probably temporary (service might come back online) and suggest retrying.

**What required fields must the error response include?**

- A) Just the error message: "Authentication failed"
- B) errorMessage and timestamp
- C) errorCategory (e.g., "AuthenticationFailed"), isRetryable (true), and description (detailed explanation)
- D) exception, stackTrace, and context

**Correct Answer**: C

**Explanation**: Structured MCP errors require: (1) errorCategory—what type of error (AuthenticationFailed, RateLimited, etc.); (2) isRetryable—can the agent retry or should it escalate (true for temporary auth issues); (3) description—what went wrong and why. This structure lets the agent respond intelligently (retry if isRetryable, escalate otherwise). Options A, B, D don't provide the right information for agent decision-making.

**Domain**: Domain 2 - Tool Design and MCP

---

### Question 14
**Scenario**: Your project needs a tool to validate email addresses. This is a project-specific requirement shared by all team members. Where should you define this tool?**

- A) In ~/.claude.json (user home directory)
- B) In .mcp.json at the project root
- C) In a custom file that only you maintain locally
- D) In a global registry

**Correct Answer**: B

**Explanation**: Project-scoped tools belong in .mcp.json at the project root, version-controlled and shared with all team members. Option A (.claude.json) is for personal, user-scoped tools that shouldn't be shared. Option C loses the benefits of version control and team sharing. Option D requires infrastructure you likely don't have. Project tools = .mcp.json.

**Domain**: Domain 2 - Tool Design and MCP

---

### Question 15
**Scenario**: You need to find all TypeScript files in src/ that contain the word "async". Should you use Glob or Grep?**

- A) Glob to find all files; Grep to search contents
- B) Grep to find and search
- C) Either; they're interchangeable
- D) Neither; you need a custom tool

**Correct Answer**: A

**Explanation**: Step 1: Glob (pattern: "src/**/*.ts") selects all TypeScript files. Step 2: Grep searches those files for "async". Option B uses Grep for file selection, which is backwards. The distinction: Glob picks which files to operate on; Grep searches within those files.

**Domain**: Domain 2 - Tool Design and MCP

---

### Question 16
**Scenario**: A tool that fetches weather data returns three possible response formats:
1. Success: {"temperature": 72, "condition": "sunny"}
2. Empty result: {} (no data available for the location)
3. Error: connection timeout

**How should the tool distinguish case 2 (empty/valid) from case 3 (error)?**

- A) Return an error in both cases; the agent will figure it out
- B) Include an explicit success field: {"success": true} for case 2, {"success": false, "error": "..."} for case 3
- C) Empty objects always mean error
- D) There's no meaningful distinction; treat them the same

**Correct Answer**: B

**Explanation**: Always include an explicit success field. Empty result with success=true is valid (agent should proceed knowing no data exists). Error response with success=false indicates the operation failed (agent should retry or escalate). Without this distinction, the agent can't reason about what happened. Option A forces the agent to guess. Options C and D conflate two different situations.

**Domain**: Domain 2 - Tool Design and MCP

---

### Question 17
**Scenario**: You're writing a description for a tool called "ExecuteSQL". The tool runs SQL queries against a database.

**Which description best practices are followed here?**
"Execute SQL queries. Returns result rows if successful."

- A) Perfect; clear and concise
- B) Good but missing: when to use ExecuteSQL versus other tools, what parameters mean
- C) Too verbose; descriptions should be one sentence
- D) Descriptions are optional; skip them to save tokens

**Correct Answer**: B

**Explanation**: Good descriptions explain (1) what the tool does, (2) when to use it (vs. similar tools like GraphQL), (3) parameter meanings. The given description covers #1 but not #2 or #3. Add: "Use for direct database access. Parameters: query (SQL string), timeout (seconds), readonly (bool to prevent writes)." Option A assumes the description is sufficient; Option C confuses brevity with clarity; Option D ignores that descriptions help the agent choose correct tools.

**Domain**: Domain 2 - Tool Design and MCP

---

### Question 18
**Scenario**: You're deciding on tool_choice settings for a system that must generate structured reports. The report format is complex and the agent often makes formatting mistakes.

**What should tool_choice be?**

- A) "auto" (let Claude decide whether to use a tool)
- B) "any" (Claude must call a tool, but picks which one)
- C) "forced" (Claude must call a specific Report tool with your schema)
- D) Leave it unset; default is fine

**Correct Answer**: C

**Explanation**: Use "forced" with a specific Report tool to guarantee Claude uses the structured schema you've defined. This prevents formatting mistakes by removing the choice. Option A risks Claude skipping the tool and responding in plain text. Option B is less strict than needed. Option D doesn't enforce the schema. When you need guaranteed structured output, "forced" is the right constraint.

**Domain**: Domain 2 - Tool Design and MCP

---

### Question 19
**Scenario**: You're designing MCP tools for a content analysis system. Your tool list is: ReadFile, SearchContents, AnalyzeSentiment, ExtractEntities, SummarizeText, DetectLanguage, ClassifyContent. That's 7 tools.

**What's the primary drawback?**

- A) 7 tools is fine; more tools always mean more capability
- B) Too many tools causes decision paralysis and increases token overhead from tool descriptions
- C) 7 tools is the maximum; you can't exceed this
- D) Multiple tools for overlapping tasks create redundancy

**Correct Answer**: B

**Explanation**: Seven tools exceeds the optimal 4-5 range. The agent faces decision paralysis choosing between AnalyzeSentiment and ExtractEntities for some tasks. Token overhead from describing all tools is wasted on marginal value. Option A is backwards. Option C has no hard limit. Option D is true but secondary to the core issue. Consider consolidating: ReadFile/Search, ContentAnalysis (sentiment + entities + classification), Summarize, DetectLanguage (3-4 tools).

**Domain**: Domain 2 - Tool Design and MCP

---

### Question 20
**Scenario**: You're reading MCP documentation about Resources vs. Tools. A resource is static file data your agent can read. A tool is a function the agent can invoke.

**When would Resources be more appropriate than Tools?**

- A) Resources and Tools are identical; choose based on naming preference
- B) When the agent needs to read reference materials or cached data it cannot modify
- C) When you want to prevent the agent from using information
- D) Resources are deprecated; always use Tools

**Correct Answer**: B

**Explanation**: Resources represent static reference data the agent reads but doesn't modify (project documentation, API specs, configuration samples). Tools represent actions (call an API, run a command, modify data). If your agent needs read-only access to reference material, Resources are cleaner than Tools that fake write-prevention. Option A conflates them. Option C is backwards. Option D is false.

**Domain**: Domain 2 - Tool Design and MCP

---

## Domain 3: Claude Code Configuration (9 Questions)

### Question 21
**Scenario**: Your team is setting up Claude Code for a project. You want to define a slash command `/docstring` that automatically generates docstrings for functions. Should this be shared with the whole team or personal to individual developers?**

- A) Personal to each developer in ~/.claude/commands/
- B) Shared with the team in .claude/commands/ at the project root
- C) Doesn't matter; it goes in both places
- D) Slash commands cannot be configured; they're built-in only

**Correct Answer**: B

**Explanation**: If the team agrees on a docstring standard, define the slash command in .claude/commands/ at the project root and version-control it. Everyone uses the same standard. Option A would lead to inconsistency. Option C wastes duplication. Option D is false; custom commands are configurable. Team standards go in the project; personal preferences go in ~/.claude/.

**Domain**: Domain 3 - Claude Code Configuration

---

### Question 22
**Scenario**: You're writing a Claude Code skill that runs tests, generates a report, and uploads the report to an artifact storage system. The test output is 50KB and very verbose. Adding the raw test output to the context would consume many tokens.

**Should you use context: fork, and where?**

- A) Don't use context: fork; include all output for completeness
- B) Use context: fork for the test execution step to isolate verbose output from the main context
- C) Use context: fork for all steps; it's always better
- D) context: fork doesn't exist; you're misremembering

**Correct Answer**: B

**Explanation**: Mark the test execution step with "context: fork" so its verbose output is isolated. The results (pass/fail, key metrics) still inform the skill, but the raw 50KB isn't included in the main context window. Option A wastes tokens. Option C over-applies fork; you want it for verbose steps, not all steps. Option D is false; fork is a real feature.

**Domain**: Domain 3 - Claude Code Configuration

---

### Question 23
**Scenario**: You're planning a task in Claude Code to refactor a large function and ensure it doesn't break existing tests. This is complex and high-risk.

**Should you use Plan mode or direct execution?**

- A) Plan mode; outline the approach before executing
- B) Direct execution; it's faster
- C) Plan mode but only for simple tasks
- D) It doesn't matter; they're equivalent

**Correct Answer**: A

**Explanation**: Use Plan mode for complex, risky tasks like refactoring. Claude outlines the strategy first, you review it, then it executes. This catches mistakes before they happen. Option B sacrifices safety for speed on a task that warrants care. Option C reverses the appropriate use. Option D ignores real differences in risk management.

**Domain**: Domain 3 - Claude Code Configuration

---

### Question 24
**Scenario**: Your project needs to enforce a rule: "Never use console.log in production code; use the logger module instead." You want this rule to apply only to src/ but not to tests/.

**How should you configure this in Claude Code?**

- A) Put the rule in CLAUDE.md at the project root (applies everywhere)
- B) Put a rule in .claude/rules/ with YAML frontmatter specifying path: "src/**/*.js"
- C) Tell Claude in your chat message each time
- D) Rules cannot be path-specific; they apply globally or not at all

**Correct Answer**: B

**Explanation**: Rules in .claude/rules/ with YAML frontmatter can specify paths. Define a rule with path: "src/**/*.js" to apply only to source code. Option A applies everywhere (including tests, where console.log might be okay). Option C requires manual repetition. Option D is false; rules are path-aware through frontmatter.

**Domain**: Domain 3 - Claude Code Configuration

---

### Question 25
**Scenario**: Your CI/CD pipeline is running Claude Code to validate code quality. The pipeline is non-interactive (no user prompts).

**What flag must you include?**

- A) -v (verbose mode for better logging)
- B) -p (project mode) for non-interactive environments
- C) --force (skip confirmations)
- D) None; Claude Code auto-detects CI/CD

**Correct Answer**: B

**Explanation**: The -p (or --project) flag is required for non-interactive environments like CI/CD. It tells Claude Code to respect .claude/ configuration and understand project context. Option A is for logging, not mode. Option C doesn't exist (or bypass confirmations improperly). Option D is false; you must explicitly declare project mode.

**Domain**: Domain 3 - Claude Code Configuration

---

### Question 26
**Scenario**: Your team has a ~/.CLAUDE.md file (user-level) with personal preferences, and a CLAUDE.md file at the project root with shared standards. A subdirectory also has its own CLAUDE.md.

**How are these merged?**

- A) All are merged; most specific level (subdirectory) overrides broader levels
- B) Only the project-root CLAUDE.md is used; others are ignored
- C) They conflict and cause errors; only one should exist
- D) CLAUDE.md files don't support hierarchy

**Correct Answer**: A

**Explanation**: CLAUDE.md supports hierarchical merging. User-level sets global defaults; project-level overrides those; directory-level overrides project. This allows layered configuration without conflict. Option B ignores user preferences. Option C is overly strict. Option D is false; hierarchy is a feature.

**Domain**: Domain 3 - Claude Code Configuration

---

### Question 27
**Scenario**: You've configured a slash command in .claude/commands/ that your team should use. You want to share it with the team via git.

**Will this work?**

- A) Yes, .claude/commands/ is committed to git and shared
- B) No, .claude/commands/ is in .gitignore and shouldn't be shared
- C) Only if you manually copy the files to team members
- D) Commands cannot be version-controlled

**Correct Answer**: A

**Explanation**: Yes, .claude/commands/ (project-scoped) should be version-controlled. Commands in ~/.claude/commands/ (user-scoped) are personal and typically in .gitignore. This structure ensures team standards spread while protecting personal workflows. Option B confuses scopes. Option C is unnecessary if using git. Option D is false.

**Domain**: Domain 3 - Claude Code Configuration

---

### Question 28
**Scenario**: You have a shared CLAUDE.md at the project root that includes API keys and internal documentation. A contractor starts working on the project and clones the repository.

**What's the security issue?**

- A) No issue; CLAUDE.md is internal documentation
- B) CLAUDE.md contains API keys and is committed to git, exposing credentials to anyone with repo access
- C) Contractors can't read CLAUDE.md
- D) API keys in CLAUDE.md are automatically encrypted

**Correct Answer**: B

**Explanation**: CLAUDE.md is typically committed to version control, so embedding API keys or secrets is a security risk. Move secrets to environment variables or .env (in .gitignore), and include only non-secret context in CLAUDE.md. Option A understates the risk. Option C is false. Option D is wishful thinking; keys aren't auto-encrypted.

**Domain**: Domain 3 - Claude Code Configuration

---

### Question 29
**Scenario**: You're using the /memory command in Claude Code to save an important decision: "After reviewing three approaches, we chose Approach B because it has lower latency and fits the 200ms SLA."

**When is this memory useful?**

- A) The memory persists across separate Claude Code sessions indefinitely
- B) The memory is useful for the current session to reference later, but doesn't persist across sessions
- C) The memory is immediately forgotten; /memory is a no-op
- D) The memory is shared with the entire team

**Correct Answer**: B

**Explanation**: /memory saves information for the current session so you can reference it later in the same session. It's not persistent across sessions (that's conversation history) and not shared (that's version control). Option A overstates persistence. Option C is false. Option D is not /memory's purpose. Use /memory for session-scoped context.

**Domain**: Domain 3 - Claude Code Configuration

---

## Domain 4: Prompt Engineering (8 Questions)

### Question 30
**Scenario**: You want to ensure an agent always returns structured data in a specific JSON format. You've defined a tool with the required schema.

**What tool_choice setting enforces this?**

- A) tool_choice: "auto" (Claude decides if it's useful)
- B) tool_choice: "any" (Claude must call a tool)
- C) tool_choice: "forced" set to the specific tool name
- D) No tool_choice setting; the schema alone enforces format

**Correct Answer**: C

**Explanation**: tool_choice: "forced" with the specific tool name guarantees Claude calls that tool and uses your schema. Option A risks Claude skipping the tool. Option B lets Claude choose which tool, possibly not yours. Option D is false; schema alone doesn't force usage. "Forced" is the enforcement mechanism.

**Domain**: Domain 4 - Prompt Engineering

---

### Question 31
**Scenario**: You're using the Batch API to process 10,000 documents for overnight analysis. Each document analysis takes about 100 tokens.

**Is Batch API the right choice?**

- A) Yes; Batch API is ideal for high-volume, non-time-sensitive work
- B) No; Batch API is too slow for any real task
- C) Only if each document takes more than 1,000 tokens
- D) Batch API is for testing; don't use in production

**Correct Answer**: A

**Explanation**: Batch API is perfect for this scenario: high volume (10,000 docs), non-time-sensitive (overnight analysis), significant cost savings. Option B misunderstands Batch's purpose (it's slow but efficient for batch work). Option C sets arbitrary token thresholds. Option D mischaracterizes Batch. For non-real-time bulk work, Batch saves money.

**Domain**: Domain 4 - Prompt Engineering

---

### Question 32
**Scenario**: Your system asks an agent to categorize customer issues into Support, Billing, or Feature Request. The agent occasionally misclassifies.

**What retry strategy is most likely to work?**

- A) "The categorization was wrong. Here's the correct answer. Try again."
- B) Provide the same question and ask the agent to categorize again (fresh attempt)
- C) Provide feedback ("Your choice was Billing, but the correct category is Support because [specific reason]") and ask the agent to recategorize
- D) Escalate without retrying; the agent's first answer is final

**Correct Answer**: C

**Explanation**: Retry-with-feedback works when the feedback is specific: explaining why the original choice was wrong and what the correct choice should be. Option A just tells the agent it was wrong; Option B (fresh attempt) might yield the same error. Option C gives the agent learning material. The key is whether the feedback addresses the misclassification's root cause. For simple categorization with clear feedback, this works.

**Domain**: Domain 4 - Prompt Engineering

---

### Question 33
**Scenario**: You're evaluating whether an AI system's security recommendations are sound. You could have Claude evaluate its own recommendations, or use a separate independent evaluation agent.

**When is independent evaluation worth the added cost?**

- A) Always; independence is always better
- B) For low-stakes recommendations like formatting suggestions
- C) For critical evaluations (security, compliance, legal) where bias matters
- D) Never; independent evaluation wastes tokens

**Correct Answer**: C

**Explanation**: Independent evaluation is worth the cost for critical decisions where self-bias is risky (security flaws, compliance violations, legal exposure). For lower-stakes evaluations (code style, formatting), self-review is acceptable. Option A overgeneralizes cost considerations. Option B has it backwards. Option D ignores that some domains demand independence.

**Domain**: Domain 4 - Prompt Engineering

---

### Question 34
**Scenario**: You're teaching Claude to extract structured data from messy customer emails. You provide 10 examples of emails with corresponding extracted data.

**What type of prompt engineering is this?**

- A) Zero-shot prompting (no examples)
- B) Few-shot prompting (examples show the pattern)
- C) Fine-tuning (permanently modifying Claude)
- D) This won't work; examples can't teach extraction

**Correct Answer**: B

**Explanation**: Few-shot prompting uses examples to show the model the pattern. 10 examples demonstrating "here's a messy email, here's the extracted data" teaches Claude the extraction pattern. Option A uses no examples. Option C is permanent model training, not applicable here. Option D is false; examples are powerful teachers, especially for uncommon patterns.

**Domain**: Domain 4 - Prompt Engineering

---

### Question 35
**Scenario**: Your schema for a tool includes a field "additionalNotes" marked as nullable. Without this nullable field, what risk would the model face?

- A) The system would run faster
- B) The model would be forced to make up notes even when uncertain
- C) The system would be more robust
- D) No difference; nullable fields are cosmetic

**Correct Answer**: B

**Explanation**: Without nullable, the model might hallucinate plausible-sounding but false notes rather than admit uncertainty. Nullable allows the model to return null/"I don't know" instead. This prevents confident fabrication. Option A is false (no performance gain). Option C is backwards (nullable helps robustness). Option D underestimates nullability's impact on preventing hallucination.

**Domain**: Domain 4 - Prompt Engineering

---

### Question 36
**Scenario**: You're using a multi-pass review pattern to improve code quality. Pass 1 generates code, Pass 2 reviews and critiques, Pass 3 makes improvements based on critiques.

**What's critical to avoid the "biased self-review" problem?**

- A) Use the same agent instance for all passes; it has context
- B) Frame Pass 2 as a distinct critique task, not "review your own code"; have it explicitly evaluate for flaws
- C) Skip Pass 2; go straight from generation to improvement
- D) Use the Batch API for all passes to ensure independence

**Correct Answer**: B

**Explanation**: Frame Pass 2 explicitly as "Identify flaws in this code" rather than "Review your own code" (which invites bias). Give Pass 2 a distinct role and task description. Option A maintains context but risks role confusion. Option C misses the benefit of structured critique. Option D uses Batch API incorrectly (it's async, not about independence). The framing matters.

**Domain**: Domain 4 - Prompt Engineering

---

### Question 37
**Scenario**: You're designing few-shot examples for a system that must detect sarcasm in social media comments. Sarcasm is context-dependent and non-obvious.

**What makes few-shot most valuable here?**

- A) Sarcasm is simple; it doesn't need examples
- B) Few-shot examples show patterns the model might not have in its training (how you define/detect sarcasm)
- C) Few-shot examples slow down inference; avoid them
- D) Few-shot examples only work for well-defined tasks

**Correct Answer**: B

**Explanation**: Sarcasm is uncommon in Claude's training relative to literal language, and it's domain-dependent (Twitter sarcasm ≠ corporate sarcasm). Few-shot examples showing your project's sarcasm patterns are highly valuable. Option A underestimates sarcasm's complexity. Option C is false; examples are worth the token cost. Option D is backwards; examples help with nuanced, context-dependent tasks.

**Domain**: Domain 4 - Prompt Engineering

---

## Domain 5: Context and Reliability (2 Questions)

### Question 38
**Scenario**: Your multi-turn agentic system has been working on a complex case for 20 turns. Suddenly, the agent forgets a key constraint that was established in turn 5. Later, it makes a decision that violates that constraint.

**What's the likely root cause?**

- A) The agent is broken; replace it
- B) The key constraint wasn't important
- C) Lost-in-the-middle effect: critical information in the middle of the context got less attention
- D) The agent is deliberately ignoring constraints

**Correct Answer**: C

**Explanation**: After 20 turns, the constraint from turn 5 is literally in the middle of the context. Research shows the model's attention weakens for middle information. Solution: place critical constraints at the beginning of the prompt or use explicit markers. Option A over-reacts. Option B is false if the constraint matters. Option D assumes malice where context architecture explains the issue.

**Domain**: Domain 5 - Context and Reliability

---

### Question 39
**Scenario**: Your system needs to handle cases where source A says "revenue is $500K" and source B says "revenue is $750K". You can't determine which is correct.

**What should the system do?**

- A) Choose the source with more authority and present only that figure
- B) Average them and present $625K as the true value
- C) Present both figures and explain they conflict, without claiming to know the truth
- D) Escalate as a system failure; conflicting sources mean the system is broken

**Correct Answer**: C

**Explanation**: Document the conflict explicitly: "Source A (annual report) says $500K; Source B (investor call) says $750K. These conflict and need human clarification." This preserves transparency and accountability. Option A hides the conflict. Option B fabricates a fake "true value." Option D over-escalates; conflict is information, not failure. Transparent uncertainty > false confidence.

**Domain**: Domain 5 - Context and Reliability

---

### Question 40
**Scenario**: You're designing a system to handle customer support cases that often require human judgment. An incoming case includes the message: "I need to speak to a human representative immediately."

**When should escalation happen?**

- A) After the agent attempts resolution and fails
- B) After the agent has tried three times to resolve the issue
- C) Immediately; the customer explicitly requested human involvement
- D) Never; always try agent resolution first

**Correct Answer**: C

**Explanation**: When a customer explicitly requests human involvement, honor that request immediately without requiring the agent to attempt resolution first. This is a reliability principle: respect user intent. Forcing the agent to attempt resolution violates customer autonomy. Option A delays a legitimate request. Option B ignores the explicit request. Option D prioritizes agent opportunity over customer preference.

**Domain**: Domain 5 - Context and Reliability

---

## Practice Exam Score Interpretation

**39-40 (97.5-100%)**: Excellent mastery. You're ready for the exam.

**36-38 (90-95%)**: Strong foundation with minor gaps. Review the domains where you missed questions.

**29-35 (72.5-87.5%)**: Passing range. You understand core concepts but should review Domain 1 and Domain 2 carefully.

**25-28 (62.5-70%)**: Below passing. Significant review needed, particularly on agentic architecture and tool design.

**Below 25 (62.5%)**: Substantial gaps. Return to course materials and work through section quizzes before retesting.

The exam emphasizes practical judgment and architectural reasoning over memorized facts. If you missed questions, focus on understanding the underlying principles rather than memorizing answers.
