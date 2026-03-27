# Scenario Lab: Customer Support Resolution Agent

## Overview

In this lab, you will build a multi-tool coordinator agent that resolves customer support issues by combining multiple APIs and handling complex task dependencies. The agent will act as an intelligent customer support representative that can investigate orders, process refunds, and escalate cases to human agents when necessary.

**Key Architecture Pattern:** Coordinator agent with tool-use patterns, prerequisite blocking, and response normalization.

---

## Learning Objectives

By completing this lab, you will demonstrate the ability to:

1. **Design a multi-tool agent workflow** that coordinates between disparate systems (customer database, order system, payment processing)
2. **Implement prerequisite blocking logic** to enforce tool ordering (e.g., cannot refund before customer is identified)
3. **Build a PostToolUse hook** to normalize heterogeneous API responses into a unified format
4. **Handle tool output variations** including Unix timestamps, ISO 8601 dates, numeric status codes, and structured objects
5. **Design parallel investigation flows** where multiple tools run sequentially within a single agent response
6. **Test complex, multi-step customer scenarios** that require dynamic decision-making

**Exam Connections:** Domain 1 (Agent Design & Routing) — Tool use patterns, agent decision-making, response handling

---

## Prerequisites

### Tools & APIs
- **Claude API** with tools support (models: claude-3-5-sonnet or later)
- **Python 3.8+** with the Anthropic SDK
- **Mock APIs** or local simulation functions (no external services required)

### Knowledge
- Basic understanding of agent-tool patterns from course Module 2
- Familiarity with Claude's tool_use content blocks
- Understanding of response parsing and error handling

### Setup
```bash
# Install dependencies
pip install anthropic pydantic

# Set your API key
export CLAUDE_API_KEY="your-key-here"
```

---

## Step-by-Step Instructions

### Step 1: Define Tool Schemas

Create a file `tools.py` with tool definitions for the customer support domain.

**Scaffolding Code:**

```python
from anthropic import Anthropic
from typing import Any
import json
from datetime import datetime, timedelta
import random

client = Anthropic()

# Tool definitions
tools = [
    {
        "name": "get_customer",
        "description": "Retrieve customer information by ID. Returns customer record with contact info and account status.",
        "input_schema": {
            "type": "object",
            "properties": {
                "customer_id": {
                    "type": "string",
                    "description": "The unique customer identifier"
                }
            },
            "required": ["customer_id"]
        }
    },
    {
        "name": "lookup_order",
        "description": "Find an order by order ID. Returns order details including items, date, and status.",
        "input_schema": {
            "type": "object",
            "properties": {
                "order_id": {
                    "type": "string",
                    "description": "The order identifier"
                },
                "customer_id": {
                    "type": "string",
                    "description": "The customer ID for authorization"
                }
            },
            "required": ["order_id", "customer_id"]
        }
    },
    {
        "name": "process_refund",
        "description": "Process a refund for an order. Requires customer and order to be verified first.",
        "input_schema": {
            "type": "object",
            "properties": {
                "order_id": {
                    "type": "string",
                    "description": "The order to refund"
                },
                "customer_id": {
                    "type": "string",
                    "description": "The customer ID"
                },
                "reason": {
                    "type": "string",
                    "description": "Reason for refund"
                },
                "amount": {
                    "type": "number",
                    "description": "Refund amount (optional; defaults to full order)"
                }
            },
            "required": ["order_id", "customer_id", "reason"]
        }
    },
    {
        "name": "escalate_to_human",
        "description": "Escalate the case to a human agent. Use when resolution is uncertain or customer needs special handling.",
        "input_schema": {
            "type": "object",
            "properties": {
                "customer_id": {
                    "type": "string",
                    "description": "The customer ID"
                },
                "reason": {
                    "type": "string",
                    "description": "Why this case needs human review"
                },
                "context": {
                    "type": "string",
                    "description": "Context for the human agent"
                }
            },
            "required": ["customer_id", "reason"]
        }
    }
]

# Mock tool implementations
def get_customer(customer_id: str) -> dict:
    """Simulate customer lookup with Unix timestamp."""
    return {
        "customer_id": customer_id,
        "name": "Alice Johnson",
        "email": "alice@example.com",
        "phone": "+1-555-0123",
        "account_status": "active",
        "created_at": int((datetime.now() - timedelta(days=365)).timestamp()),  # Unix timestamp
        "loyalty_tier": "gold"
    }

def lookup_order(order_id: str, customer_id: str) -> dict:
    """Simulate order lookup with ISO 8601 timestamp."""
    return {
        "order_id": order_id,
        "customer_id": customer_id,
        "status": "delivered",
        "items": [
            {"sku": "WIDGET-001", "quantity": 2, "unit_price": 29.99},
            {"sku": "GADGET-042", "quantity": 1, "unit_price": 49.99}
        ],
        "subtotal": 109.97,
        "tax": 8.80,
        "shipping": 5.00,
        "total": 123.77,
        "order_date": "2024-03-10T14:30:00Z",  # ISO 8601
        "delivery_date": "2024-03-15T10:45:00Z",
        "tracking_number": "TRK987654321"
    }

def process_refund(order_id: str, customer_id: str, reason: str, amount: float = None) -> dict:
    """Simulate refund processing with numeric status code."""
    return {
        "refund_id": f"REF-{random.randint(100000, 999999)}",
        "order_id": order_id,
        "customer_id": customer_id,
        "amount": amount or 123.77,
        "reason": reason,
        "status_code": 200,  # Numeric status code
        "status_text": "approved",
        "processed_at": datetime.now().isoformat(),
        "expected_receipt": (datetime.now() + timedelta(days=3)).isoformat()
    }

def escalate_to_human(customer_id: str, reason: str, context: str = None) -> dict:
    """Simulate escalation ticket creation."""
    return {
        "ticket_id": f"TICKET-{random.randint(100000, 999999)}",
        "customer_id": customer_id,
        "priority": "medium",
        "assigned_to": "support_team",
        "status": "open",
        "created_at": datetime.now().isoformat(),
        "reason": reason,
        "notes": context or ""
    }
```

**Task:** Review this tool schema definition. Which tools have prerequisites? (Answer: process_refund depends on get_customer and lookup_order succeeding first.)

---

### Step 2: Implement Prerequisite Blocking

Create a validation layer that tracks which tools have been successfully called and blocks tools with unmet prerequisites.

**Scaffolding Code:**

```python
class ToolExecutionContext:
    """Tracks tool execution state to enforce prerequisites."""

    def __init__(self):
        self.executed_tools = set()
        self.tool_results = {}

    def can_execute(self, tool_name: str) -> tuple[bool, str]:
        """
        Check if a tool can be executed based on prerequisites.

        Returns (can_execute, reason)
        """
        prerequisites = {
            "process_refund": ["get_customer", "lookup_order"],
            "escalate_to_human": ["get_customer"],
            "lookup_order": ["get_customer"]
        }

        required = prerequisites.get(tool_name, [])
        missing = [t for t in required if t not in self.executed_tools]

        if missing:
            return False, f"Tool '{tool_name}' requires {missing} to be called first"
        return True, ""

    def mark_executed(self, tool_name: str, result: dict):
        """Record successful tool execution."""
        self.executed_tools.add(tool_name)
        self.tool_results[tool_name] = result

    def get_context_summary(self) -> str:
        """Provide agent with a summary of what's been discovered."""
        summary = "Current investigation state:\n"
        if "get_customer" in self.executed_tools:
            customer = self.tool_results["get_customer"]
            summary += f"- Customer: {customer['name']} ({customer['customer_id']})\n"
        if "lookup_order" in self.executed_tools:
            order = self.tool_results["lookup_order"]
            summary += f"- Order: {order['order_id']} (Status: {order['status']}, Total: ${order['total']})\n"
        return summary

# Usage in agent loop
exec_context = ToolExecutionContext()
```

**Task:** Modify the `can_execute` method to also check that get_customer succeeds (status='active') before allowing escalate_to_human. How would you access the customer status?

---

### Step 3: Build the PostToolUse Hook for Response Normalization

Create a hook that normalizes heterogeneous tool responses into a consistent format.

**Scaffolding Code:**

```python
class ResponseNormalizer:
    """Normalizes tool responses to handle timestamp and status variations."""

    @staticmethod
    def normalize_response(tool_name: str, raw_response: dict) -> dict:
        """
        Convert various timestamp and status formats to standard ISO 8601.
        """
        normalized = raw_response.copy()

        # Handle Unix timestamps (created_at, timestamp fields)
        if tool_name == "get_customer":
            if "created_at" in normalized and isinstance(normalized["created_at"], int):
                normalized["created_at"] = datetime.fromtimestamp(
                    normalized["created_at"]
                ).isoformat()

        # Handle numeric status codes (convert to text)
        if "status_code" in normalized:
            status_map = {
                200: "approved",
                201: "pending",
                400: "rejected",
                409: "conflict"
            }
            if isinstance(normalized["status_code"], int):
                normalized["status_text"] = status_map.get(
                    normalized["status_code"],
                    "unknown"
                )

        # Ensure all timestamps are ISO 8601
        timestamp_fields = [
            "order_date", "delivery_date", "processed_at",
            "expected_receipt", "created_at"
        ]
        for field in timestamp_fields:
            if field in normalized and normalized[field]:
                # If already ISO format, skip
                if isinstance(normalized[field], str) and "T" in normalized[field]:
                    continue
                # Convert if needed
                elif isinstance(normalized[field], (int, float)):
                    normalized[field] = datetime.fromtimestamp(
                        normalized[field]
                    ).isoformat()

        return normalized

def execute_tool_with_normalization(tool_name: str, tool_input: dict) -> dict:
    """Execute tool and normalize output."""

    # Validation: Check prerequisites
    can_execute, reason = exec_context.can_execute(tool_name)
    if not can_execute:
        return {"error": reason}

    # Execute tool
    tool_map = {
        "get_customer": get_customer,
        "lookup_order": lookup_order,
        "process_refund": process_refund,
        "escalate_to_human": escalate_to_human
    }

    if tool_name not in tool_map:
        return {"error": f"Unknown tool: {tool_name}"}

    try:
        raw_result = tool_map[tool_name](**tool_input)
        normalized = ResponseNormalizer.normalize_response(tool_name, raw_result)

        # Record execution
        exec_context.mark_executed(tool_name, normalized)

        return normalized
    except Exception as e:
        return {"error": str(e)}
```

**Task:** Add a new status code (500 = "error") to the status_map. Then test the normalizer by calling `execute_tool_with_normalization("get_customer", {"customer_id": "C123"})` and inspect the output to verify created_at is now ISO 8601.

---

### Step 4: Implement the Coordinator Agent

Build the main agent loop that accepts customer requests and orchestrates tool calls.

**Scaffolding Code:**

```python
def create_system_prompt() -> str:
    return """You are an expert customer support agent. Your role is to:

1. Listen to the customer's concern
2. Investigate by gathering customer info and order details
3. Determine the appropriate resolution (refund, reorder, escalation)
4. Execute the resolution or escalate to a human if needed

Key guidelines:
- Always start by identifying the customer (use get_customer)
- For order-related issues, look up the specific order (use lookup_order)
- Only process a refund after you've confirmed customer and order details
- Escalate to human if: customer is at risk of churn, dispute is complex, or you're unsure
- Be empathetic and proactive in offering solutions

Use the tools available to investigate and resolve issues systematically."""


def run_customer_support_agent(customer_request: str):
    """Main agent loop."""
    messages = [
        {"role": "user", "content": customer_request}
    ]

    print(f"\n{'='*60}")
    print(f"Customer Request: {customer_request}")
    print(f"{'='*60}\n")

    while True:
        # Call Claude with tools
        response = client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=2048,
            system=create_system_prompt(),
            tools=tools,
            messages=messages
        )

        print(f"Agent (stop_reason={response.stop_reason}):")

        # Process response content
        tool_calls = []
        text_content = []

        for block in response.content:
            if block.type == "text":
                print(f"  {block.text}")
                text_content.append(block.text)
            elif block.type == "tool_use":
                tool_calls.append(block)
                print(f"  [Tool: {block.name}] Input: {json.dumps(block.input, indent=2)}")

        # If stop_reason is "end_turn", agent is done
        if response.stop_reason == "end_turn" and not tool_calls:
            print(f"\n{'='*60}")
            print("Resolution Complete")
            print(f"{'='*60}\n")
            break

        # Execute tools and collect results
        if tool_calls:
            # Add assistant response to messages
            messages.append({"role": "assistant", "content": response.content})

            # Execute each tool
            tool_results = []
            for tool_use in tool_calls:
                print(f"\n  Executing {tool_use.name}...")
                result = execute_tool_with_normalization(
                    tool_use.name,
                    tool_use.input
                )
                print(f"  Result: {json.dumps(result, indent=2)}")

                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": tool_use.id,
                    "content": json.dumps(result)
                })

            # Add tool results to messages
            messages.append({"role": "user", "content": tool_results})
        else:
            # No tool calls and stop_reason != "tool_use"
            break
```

**Task:** What happens if a customer request mentions multiple order IDs? How would you modify the agent to handle that? (Hint: The agent could call lookup_order multiple times.)

---

### Step 5: Test Scenarios

Create comprehensive test scenarios that exercise the agent's capabilities.

**Scaffolding Code:**

```python
def run_tests():
    """Run test scenarios."""

    test_cases = [
        {
            "name": "Single Refund Request",
            "request": "Hi, I'm customer C123. I want to return order ORD-789. The widget was broken."
        },
        {
            "name": "Multi-Concern Investigation",
            "request": "Customer C456 here. Order ORD-101 arrived late and the gadget was damaged. What can you do?"
        },
        {
            "name": "Escalation Scenario",
            "request": "I'm C789. This is my third complaint about ORD-555. I've never been satisfied with your service."
        },
        {
            "name": "Preventive Resolution",
            "request": "Hi, C999 here. I just noticed ORD-222 was shipped to the wrong address. Can you help?"
        }
    ]

    for test in test_cases:
        print(f"\n\n{'#'*60}")
        print(f"TEST: {test['name']}")
        print(f"{'#'*60}\n")

        # Reset context for each test
        exec_context.__init__()

        run_customer_support_agent(test["request"])

        # Verify outcome
        print(f"Execution Summary:")
        print(f"  Tools called: {list(exec_context.executed_tools)}")
        print(f"  Refund processed: {'process_refund' in exec_context.executed_tools}")
        print(f"  Escalated: {'escalate_to_human' in exec_context.executed_tools}")

if __name__ == "__main__":
    run_tests()
```

---

## Expected Outcomes & Success Criteria

### Successful Agent Behavior
1. **Prerequisite Enforcement:** Agent cannot call process_refund without first calling get_customer and lookup_order
2. **Response Normalization:** All timestamps appear in ISO 8601 format in logs; status codes are converted to text descriptions
3. **Parallel Investigation:** For multi-concern requests, agent identifies all issues and investigates each
4. **Smart Resolution:**
   - Simple refunds are processed directly
   - Uncertain cases are escalated
   - Customer context (loyalty tier, account history) informs decisions
5. **Error Handling:** Agent gracefully handles tool failures and communicates issues to the customer

### Test Pass Criteria
- All 4 test scenarios run without exceptions
- No tool is called before its prerequisites
- Refund amounts match order totals
- Escalation tickets include proper context
- Agent messages are empathetic and clear

### Logs Show
```
[Tool: get_customer] Input: {"customer_id": "C123"}
Result: {"customer_id": "C123", "name": "Alice Johnson", ..., "created_at": "2023-03-10T..."}
[Tool: lookup_order] Input: {"order_id": "ORD-789", "customer_id": "C123"}
Result: {..., "order_date": "2024-03-10T14:30:00Z", ...}
[Tool: process_refund] Input: {"order_id": "ORD-789", "customer_id": "C123", "reason": "defective item"}
Result: {"refund_id": "REF-...", "amount": 123.77, "status_text": "approved", ...}
```

---

## Common Mistakes to Avoid

1. **Not enforcing prerequisites:** Allowing process_refund to run without customer verification → security risk
2. **Ignoring response format variations:** Assuming all dates are ISO 8601 when legacy APIs return Unix timestamps → parsing errors
3. **Tool bloat:** Adding too many separate tools instead of using tool inputs → agent confusion
4. **Poor error messages:** Saying "tool failed" instead of "customer account is suspended" → unhelpful to agent
5. **Escalation abuse:** Always escalating instead of making decisions → poor efficiency
6. **Not resetting context:** Running multiple test scenarios with shared state → cross-contamination

---

## Connection to Exam Concepts

**Domain 1: Agent Design & Routing**
- **Task 1.2:** Design a multi-tool agent that integrates disparate systems
  - This lab builds a coordinator agent that orchestrates multiple API integrations
- **Task 1.3:** Implement tool-use patterns and understand response handling
  - Demonstrates tool_use content blocks, input schemas, and response normalization
- **Task 1.5:** Handle errors and design agent workflows
  - Shows prerequisite validation and graceful error handling

**Relevant Course Module:** Module 2 (Tool Integration & Agent Loops)

---

## Estimated Time to Complete

- **Reading & setup:** 10 minutes
- **Steps 1-2 (Tool & validation setup):** 15 minutes
- **Step 3 (Response normalization):** 15 minutes
- **Step 4 (Agent loop):** 20 minutes
- **Step 5 (Testing & debugging):** 20 minutes
- **Total:** 80 minutes (1.5 hours)

**Suggested Checkpoint:** After Step 2, run a simple test to verify prerequisite blocking works.

---

## Additional Challenges (Optional)

1. **Add a rate-limiting tool** that tracks refund limits per customer per month
2. **Implement a feedback loop** where escalations return human decisions for the agent to communicate
3. **Add customer history context** (e.g., "This customer has 3 previous refunds") to influence escalation decisions
4. **Design a retry strategy** for transient tool failures (e.g., database timeouts)
5. **Build an audit log** that records all tool calls, inputs, and outputs for compliance
