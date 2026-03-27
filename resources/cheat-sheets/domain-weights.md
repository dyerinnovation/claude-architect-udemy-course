# Claude Certified Architect Exam: Domain Weights

## Exam Weight Distribution

| Domain | Percentage | Priority | Focus Areas |
|--------|-----------|----------|------------|
| **Domain 1: Agentic Architecture & Orchestration** | **27%** | **HIGHEST** | Multi-agent patterns, tool integration, workflow design, agentic loops |
| **Domain 3: Claude Code Configuration & Workflows** | **20%** | HIGH | .claude/config.yaml, environment setup, workflow management |
| **Domain 4: Prompt Engineering & Structured Output** | **20%** | HIGH | System prompts, structured outputs, JSON schemas, instruction design |
| **Domain 2: Tool Design & MCP Integration** | **18%** | MEDIUM-HIGH | MCP protocol, tool composition, error handling, tool_choice |
| **Domain 5: Context Management & Reliability** | **15%** | MEDIUM | Token budgeting, context windows, reliability patterns |

## Study Strategy

### Week 1-2: Domain 1 (27%)
- Master agentic architecture fundamentals
- Understand tool-use loops and stop_reason handling
- Study multi-agent orchestration patterns
- **This is the make-or-break domain**

### Week 2-3: Domains 3 & 4 (40% combined)
- Claude Code configuration and workflows
- Prompt engineering best practices
- Structured output schemas

### Week 3-4: Domains 2 & 5 (33% combined)
- MCP integration and tool design
- Context management and reliability

## Key Insight

**Domain 1 accounts for over 1/4 of the exam.** Ensure you can:
- Trace through agentic loops with tool calling
- Identify when to use stop_reason vs text content
- Design multi-agent systems that fail gracefully
- Apply the right tool_choice for different scenarios
