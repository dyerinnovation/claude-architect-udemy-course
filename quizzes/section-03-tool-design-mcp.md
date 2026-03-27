# Quiz: Tool Design and MCP (Domain 2)

## Question 1
**What are the three tool_choice options, and when should each be used?**

- A) auto (default, Claude decides), any (Claude must call a tool), forced (Claude chooses and must call a specific tool)
- B) random (unpredictable), manual (user chooses), auto (Claude chooses)
- C) strict (only tools allowed), loose (tools optional), any (tool required)
- D) primary (main tool), secondary (backup tool), none (no tools allowed)

**Correct Answer**: A

**Explanation**: The three tool_choice options are: (1) "auto" - Claude decides whether to call a tool or respond naturally; (2) "any" - Claude must call a tool, but you don't specify which; (3) "forced" - Claude is constrained to call a specific tool you designate. Use "auto" for general flexibility, "any" when you need a tool call to happen but the choice is Claude's, and "forced" when a specific tool is required (e.g., forcing structured output through a specific schema). These control the agent's autonomy at execution time.

**Domain**: Domain 2 - Tool Design and MCP

---

## Question 2
**What are the required fields in a properly structured MCP error response?**

- A) Just an error message string
- B) errorCategory (string), isRetryable (boolean), and description (string)
- C) errorCode (number), timestamp (ISO string), and errorMessage (string)
- D) exception (object), stackTrace (array), and context (object)

**Correct Answer**: B

**Explanation**: MCP error responses must include three key fields: errorCategory (categorizes the type of error, e.g., "InvalidRequest", "AuthenticationFailed"), isRetryable (boolean indicating whether retrying might succeed), and description (human-readable explanation). This structure allows the agent to understand not just that an error occurred, but why and what to do about it. Tools missing these fields may confuse the agent or cause recovery strategies to fail.

**Domain**: Domain 2 - Tool Design and MCP

---

## Question 3
**Should MCP tool definitions be stored in .mcp.json (project scope) or ~/.claude.json (user scope)?**

- A) Always use ~/.claude.json for consistency across projects
- B) Always use .mcp.json for security
- C) Use .mcp.json for project-specific tools shared via version control; use ~/.claude.json for user personal tools
- D) The two files are interchangeable and serve identical purposes

**Correct Answer**: C

**Explanation**: Project-scoped MCP tools belong in .mcp.json at the project root and are version-controlled with the project—they're shared with all team members. User-scoped tools belong in ~/.claude.json in the user's home directory—they're personal to that user and not shared. This distinction ensures team tools are consistent and discoverable while protecting personal workflows from being overwritten.

**Domain**: Domain 2 - Tool Design and MCP

---

## Question 4
**When should you use Grep versus Glob for tool definitions?**

- A) Grep for searching patterns in file contents; Glob for pattern matching filenames
- B) Glob for case-insensitive searches; Grep for case-sensitive searches
- C) Grep when you need a tool that returns all matches; Glob when you only need the first match
- D) They are synonymous; use either one interchangeably

**Correct Answer**: A

**Explanation**: Glob is for matching filenames against patterns (e.g., "*.md", "src/**/*.ts")—it's about selecting which files to operate on. Grep is for searching within file contents—it's about finding patterns or text inside those files. Using Grep as a tool when you should use Glob (or vice versa) results in the wrong kind of search and confuses the agent about what data it's working with.

**Domain**: Domain 2 - Tool Design and MCP

---

## Question 5
**What is the optimal number of tools to assign to a single agent?**

- A) 1-2 tools for focused specialists
- B) 4-5 tools for balanced capability
- C) 8-10 tools for comprehensive coverage
- D) As many as needed; there is no practical limit

**Correct Answer**: B

**Explanation**: Four to five tools provides a good balance. With fewer tools, the agent's capabilities are too constrained. With more tools, the agent faces decision paralysis and token overhead from processing tool descriptions. Research and practice show that 4-5 well-designed, complementary tools give agents strong capability without diluting focus. This also keeps the token cost of tool definitions reasonable.

**Domain**: Domain 2 - Tool Design and MCP

---

## Question 6
**What is the difference between MCP Resources and MCP Tools?**

- A) Resources are static data; Tools are functions that perform actions
- B) Resources are for reading files; Tools are for all other operations
- C) Resources are deprecated; Tools are the modern approach
- D) They serve the same purpose; "resource" and "tool" are just different names

**Correct Answer**: A

**Explanation**: MCP Resources represent static data or information accessible to the agent (files, API responses, cached data)—the agent can read them but not modify them through the resource interface. MCP Tools represent actions or functions the agent can invoke (running commands, making API calls, modifying data). This distinction helps organize capabilities: use Resources when the agent needs reference material, use Tools when it needs to act.

**Domain**: Domain 2 - Tool Design and MCP

---

## Question 7
**What are the best practices for writing tool descriptions?**

- A) Brief, single-word descriptions like "Read", "Write", "Calculate"
- B) Clear, concise descriptions that explain what the tool does, when to use it, and what parameters mean
- C) Comprehensive descriptions with full technical documentation embedded
- D) Descriptions are optional; the tool name is sufficient

**Correct Answer**: B

**Explanation**: Tool descriptions should be clear and concise, explaining the tool's purpose and usage without being verbose. A good description tells the agent: (1) what the tool does, (2) when to use it (vs. similar tools), (3) what each parameter means. This level of detail helps Claude choose the right tool and use it correctly. Too brief and the agent is confused; too long and you waste tokens.

**Domain**: Domain 2 - Tool Design and MCP

---

## Question 8
**When a tool returns an empty result, how should you distinguish between "valid empty result" (tool worked, no data exists) versus "access failure" (tool couldn't execute)?**

- A) Distinguish using HTTP status codes; 200 means success, 4xx/5xx means failure
- B) Distinguish using a success field; always include explicit status indication in the response
- C) If the result is empty, it's always a failure
- D) If the result is empty, it's always success

**Correct Answer**: B

**Explanation**: Always include an explicit status field in tool responses to distinguish success from failure. A search that found no results is valid (return empty with success=true), while a permission error is a failure (return with success=false and error details). Without this distinction, the agent cannot differentiate between "searched and found nothing" versus "couldn't execute the search," leading to incorrect reasoning.

**Domain**: Domain 2 - Tool Design and MCP
