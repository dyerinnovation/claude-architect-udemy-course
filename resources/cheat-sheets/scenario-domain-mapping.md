# Scenario-to-Domain Mapping

Quick reference for which domains each exam scenario tests.

## Scenario 1: Healthcare Patient Data Retrieval
**Primary Domains:** 1 (Agentic), 2 (Tool Design), 5 (Reliability)

**Likely Task Statements:**
- Design a multi-agent system that retrieves patient data from multiple sources
- Implement error handling for medical records systems
- Ensure HIPAA-compliant tool calling
- Handle timeouts and retry logic in healthcare workflows

**Key Concepts to Review:**
- Tool composition and orchestration
- Error response categories (validation, permission, business)
- Reliability patterns for critical systems

---

## Scenario 2: E-Commerce Multi-Platform Inventory Management
**Primary Domains:** 1 (Agentic), 2 (Tool Design), 3 (Code Config)

**Likely Task Statements:**
- Design agents for syncing inventory across platforms
- Implement conflict resolution strategies
- Configure async workflows using Claude Code
- Handle rate limiting and service coordination

**Key Concepts to Review:**
- Agent communication patterns
- Tool_choice for mandatory operations
- Batch API vs synchronous decisions
- Workflow orchestration

---

## Scenario 3: Financial Risk Assessment
**Primary Domains:** 1 (Agentic), 4 (Prompt Engineering), 5 (Reliability)

**Likely Task Statements:**
- Design a system that performs financial calculations reliably
- Implement structured outputs for risk scoring
- Create deterministic prompts for compliance
- Design escalation flows for risky transactions

**Key Concepts to Review:**
- Structured output schemas
- Intervention hierarchy (skill gap vs safety)
- Token budgeting for complex calculations
- Escalation decision logic

---

## Scenario 4: Customer Support Chatbot with Escalation
**Primary Domains:** 1 (Agentic), 3 (Code Config), 4 (Prompt Engineering)

**Likely Task Statements:**
- Design escalation logic that distinguishes sentiment from true escalation
- Implement context routing based on Claude.md rules
- Design a stateful conversation system with context limits
- Handle ambiguous policy situations

**Key Concepts to Review:**
- Escalation flowchart (when NOT to escalate)
- Claude.md hierarchy and .claude/rules/
- Memory command and context management
- Prompt design for nuance (frustrated vs demanding escalation)

---

## Scenario 5: Marketing Analytics Multi-Agent Workflow
**Primary Domains:** 2 (Tool Design), 3 (Code Config), 4 (Prompt Engineering)

**Likely Task Statements:**
- Design MCP tools for analytics data aggregation
- Implement data pipeline using Claude Code workflows
- Create error handling for partial data failures
- Optimize token usage for large analytical reports

**Key Concepts to Review:**
- MCP protocol and tool error responses
- Batch API for non-urgent reporting
- Structured outputs for analytics dashboards
- Context management for large datasets

---

## Scenario 6: Content Moderation with Human Review
**Primary Domains:** 1 (Agentic), 4 (Prompt Engineering), 5 (Reliability)

**Likely Task Statements:**
- Design a moderation system that escalates ambiguous cases
- Implement deterministic classification with structured outputs
- Create fallback strategies for uncertain decisions
- Design human-in-the-loop workflows

**Key Concepts to Review:**
- Structured output schemas for classification
- Confidence thresholds and escalation triggers
- Error recovery patterns
- Human escalation vs operational errors

---

## Quick Reference Table

| Scenario | Domain 1 | Domain 2 | Domain 3 | Domain 4 | Domain 5 |
|----------|----------|----------|----------|----------|----------|
| Healthcare | ●●● | ●● | ● | ● | ●●● |
| E-Commerce | ●●● | ●● | ●● | ● | ● |
| Financial | ●● | ● | ● | ●●● | ●●● |
| Support | ●●● | ● | ●● | ●●● | ● |
| Analytics | ● | ●●● | ●●● | ●● | ● |
| Moderation | ●● | ● | ● | ●●● | ●● |

**Legend:** ● = tested | ●● = important | ●●● = critical
