# Exam Guide Reference: Official Structure

Quick reference to the official Anthropic Claude Certified Architect exam structure.

---

## The Five Domains (with weights)

### Domain 1: Agentic Architecture & Orchestration (27%)
**Focus:** Multi-agent systems, tool integration, workflow design

**Key Areas:**
- Agentic patterns (sequential, parallel, hierarchical)
- Tool-use loops and stop_reason handling
- Multi-agent communication and state management
- Workflow orchestration and error recovery
- Agent composition and decomposition
- Task delegation between agents

**Sample Task Statement:**
"Design a multi-agent system where agents can call each other's tools. How do you handle failures in one agent affecting downstream agents?"

---

### Domain 2: Tool Design & MCP Integration (18%)
**Focus:** MCP protocol, tool composition, error handling

**Key Areas:**
- MCP tool definition and schema design
- Tool input validation and error responses
- Tool composition and chaining
- MCP resources for data sharing
- Tool-specific error categorization
- Designing tools for reliability

**Sample Task Statement:**
"Design an MCP tool that must fail gracefully when a backend service is down. What error response should it return?"

---

### Domain 3: Claude Code Configuration & Workflows (20%)
**Focus:** Setup, configuration, automation

**Key Areas:**
- .claude/config.yaml structure and options
- Workflow definition and scheduling
- Environment variable management
- .claude/rules/ hierarchy and glob patterns
- @import for rule composition
- Claude Code project organization

**Sample Task Statement:**
"How would you organize .claude/rules/ for a project with different constraints for authentication code vs database code?"

---

### Domain 4: Prompt Engineering & Structured Output (20%)
**Focus:** System prompts, output formats, reliability

**Key Areas:**
- System prompt design for consistency
- JSON schema for structured outputs
- Validation and error recovery
- Deterministic prompting techniques
- Handling ambiguity and edge cases
- Output format enforcement

**Sample Task Statement:**
"Design a prompt that classifies customer requests into exactly 5 categories with 99% accuracy. How do you enforce the category constraint?"

---

### Domain 5: Context Management & Reliability (15%)
**Focus:** Token budgeting, context windows, resilience

**Key Areas:**
- Context window management
- Token budgeting and allocation
- Conversation truncation vs summarization
- State management in long-running agents
- Fallback and retry strategies
- Information prioritization

**Sample Task Statement:**
"You have a 10-turn conversation and context is approaching the limit. How do you decide what to keep vs summarize?"

---

## The Six Scenarios (exam cases)

All scenarios have 6-8 task statements each. Below is the structure.

### Scenario 1: Healthcare Patient Data Retrieval System
**Context:** Multi-source patient data integration with compliance requirements

**Domains Tested:** 1 (Agentic), 2 (Tools), 5 (Reliability)

**Likely Concepts:**
- Error recovery in healthcare workflows
- Tool composition for data aggregation
- HIPAA-compliant system design
- Reliability patterns for critical systems

**Example Task:**
"Design agents for retrieving data from Hospital A, Lab B, and Pharmacy C. How do you ensure results are consistent if one source fails?"

---

### Scenario 2: E-Commerce Multi-Platform Inventory Management
**Context:** Syncing inventory across multiple platforms (Amazon, eBay, Shopify)

**Domains Tested:** 1 (Agentic), 2 (Tools), 3 (Code Config)

**Likely Concepts:**
- Orchestrating agents for different platforms
- Conflict resolution in distributed systems
- Batch vs sync API decisions
- Async workflows and scheduling

**Example Task:**
"Two agents report conflicting inventory counts. How do you design the system to detect and resolve this?"

---

### Scenario 3: Financial Risk Assessment Engine
**Context:** Real-time financial decision system with compliance

**Domains Tested:** 1 (Agentic), 4 (Prompt Engineering), 5 (Reliability)

**Likely Concepts:**
- Deterministic financial prompting
- Structured output for risk scores
- Escalation logic for risky transactions
- Audit logging and compliance

**Example Task:**
"Design a prompt that assigns risk scores consistently. How do you prevent Claude from changing the scoring criteria?"

---

### Scenario 4: Customer Support Chatbot with Escalation
**Context:** AI-powered support with smart escalation to humans

**Domains Tested:** 1 (Agentic), 3 (Code Config), 4 (Prompt Engineering)

**Likely Concepts:**
- Escalation decision flowcharts
- Context routing via .claude/rules/
- Distinguishing frustration from escalation need
- Long-conversation context management

**Example Task:**
"Customer is frustrated but resolvable. How do you design the system to help without unnecessarily escalating?"

---

### Scenario 5: Marketing Analytics Multi-Agent Workflow
**Context:** Automated analytics pipeline with multiple data sources

**Domains Tested:** 2 (Tools), 3 (Code Config), 4 (Prompt Engineering)

**Likely Concepts:**
- MCP tool design for data pipelines
- Batch processing with Claude Code
- Error handling for partial failures
- Structured analytics output

**Example Task:**
"Design MCP tools that aggregate data from 3 sources. What happens if source 2 is unavailable?"

---

### Scenario 6: Content Moderation with Human Review
**Context:** AI moderation with escalation for uncertain cases

**Domains Tested:** 1 (Agentic), 4 (Prompt Engineering), 5 (Reliability)

**Likely Concepts:**
- Confidence thresholds and escalation
- Deterministic classification
- Fallback strategies for edge cases
- Human-in-the-loop workflows

**Example Task:**
"How do you design the system so ambiguous content is escalated, not guessed on?"

---

## Task Statement Types

The exam includes these types of questions:

### Type A: Design & Architecture
```
"Design a system that..."
"How would you structure..."
"Describe an architecture for..."
```
→ Requires: System thinking, pattern knowledge, trade-off analysis

### Type B: Error Handling & Edge Cases
```
"What happens if..."
"How do you handle the case where..."
"Design recovery for..."
```
→ Requires: Anticipating failures, reliability patterns

### Type C: Tool & Workflow Design
```
"Design an MCP tool that..."
"How would you configure..."
"What error response should..."
```
→ Requires: Technical tool knowledge, error categorization

### Type D: Decision Making
```
"When should you use..."
"How do you decide between..."
"What's the trade-off..."
```
→ Requires: Judgment, understanding contexts

### Type E: Prompt & Output Design
```
"Design a prompt for..."
"How would you enforce..."
"Structure this output to..."
```
→ Requires: Prompting expertise, validation logic

---

## How the Exam Is Structured

**Format:** Multiple choice and scenario-based questions

**Question Count:** 50-60 questions total

**Time Limit:** 90 minutes

**Passing Score:** ~70% (specific cutoff not publicly disclosed)

**Question Distribution:**
- Domain 1: ~13-14 questions (27%)
- Domain 2: ~9-10 questions (18%)
- Domain 3: ~10-12 questions (20%)
- Domain 4: ~10-12 questions (20%)
- Domain 5: ~7-9 questions (15%)

**Scenario Distribution:**
- Each scenario has 6-8 questions
- Scenarios are mixed throughout (not grouped)
- You see scenario context, then answer 1-2 questions about it

---

## Study Tips Based on Exam Structure

### Master These for Domain 1 (27%)
- The agentic loop: request → response → stop_reason decision → action
- Multi-agent orchestration patterns
- Tool-use error recovery

### Master These for Domain 3 & 4 (40% combined)
- System prompt design for consistency
- Structured output validation
- .claude/config.yaml essentials
- Rule hierarchy and glob patterns

### Master These for Domain 2 & 5 (33% combined)
- MCP error response fields
- Context window strategy
- Tool design principles

---

## What You Should Have Before the Exam

**Official Resources:**
- Anthropic Certified Architect Exam Guide (PDF)
- Claude API documentation
- MCP specification
- Best practices guides

**Prepared Materials (use the cheat sheets in this folder):**
- Domain weights and priorities
- Scenario-to-domain mapping
- stop_reason flowchart
- Escalation decision tree
- 20 must-know concepts

**Practice:**
- 6 scenarios (thoroughly)
- Practice exam questions (available on exam platform)
- Sample task statements

---

## The Official Exam Domains (Exact Wording)

These are the official domain names from Anthropic:

1. **Agentic Architecture & Orchestration** - Design, build, and manage multi-agent systems
2. **Tool Design & MCP Integration** - Create and integrate tools using MCP protocol
3. **Claude Code Configuration & Workflows** - Set up and manage Claude Code projects
4. **Prompt Engineering & Structured Output** - Design prompts and enforce output formats
5. **Context Management & Reliability** - Manage token budgets and system resilience

---

## Last Reminder

**Exam Focus:** How to USE Claude, not how Claude works

**Exam Values:** Practical architectural thinking, reliability, smart design decisions

**Your Goal:** Score 70%+ (means ~35-42 correct out of 50-60 questions)

**Your Edge:** Understanding the domains, mastering the scenarios, knowing when to apply which pattern
