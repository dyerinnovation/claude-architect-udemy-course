# Scenario Lab: Structured Data Extraction Pipeline

## Overview

In this lab, you will build a robust data extraction system that processes diverse document types and extracts structured information using Claude's vision capabilities and tool-use patterns. You will design extraction tools with comprehensive JSON schemas, implement validation-retry loops with error feedback, use few-shot examples for varied document structures, and batch process multiple documents using the Message Batches API with failure handling.

**Key Architecture Pattern:** Extraction tools, JSON schema with validation, few-shot learning, batch processing with failure recovery.

---

## Learning Objectives

By completing this lab, you will demonstrate the ability to:

1. **Define extraction tools** with detailed JSON schemas (required, optional, nullable fields)
2. **Implement tool_choice: "any"** to handle unknown document types gracefully
3. **Build validation-retry loops** that give the model error feedback and allow corrections
4. **Design few-shot examples** that demonstrate extraction for varied document structures
5. **Batch process documents** using the Anthropic Batches API
6. **Handle batch failures** by tracking issues via custom_id and retrying selectively
7. **Build resilient pipelines** that don't lose data if individual documents fail

**Exam Connections:** Domain 4 (Prompt Engineering & Outputs), Domain 5 (System Design & Scaling)

---

## Prerequisites

### Tools & APIs
- **Claude API** with vision and batches support
- **Python 3.8+** with Anthropic SDK and Pydantic
- **Image/PDF documents** for testing (sample invoices, receipts, contracts)
- **JSON schema** understanding

### Knowledge
- Familiarity with Claude's vision capabilities (Module 4)
- Understanding of tool-use patterns and validation
- Batching API basics

### Setup
```bash
pip install anthropic pydantic pillow PyPDF2

export CLAUDE_API_KEY="your-key-here"
```

---

## Step-by-Step Instructions

### Step 1: Design Extraction Tool Schemas

Create comprehensive JSON schemas for extracting different data types.

**File: `tools.py`**

```python
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from enum import Enum
import json

# ============================================================================
# Schema: General Invoice/Receipt Extraction
# ============================================================================

class LineItem(BaseModel):
    """A single line item from an invoice or receipt."""
    description: str = Field(
        ...,
        description="Item description (required)"
    )
    quantity: Optional[float] = Field(
        None,
        description="Quantity (optional, numeric)"
    )
    unit_price: Optional[float] = Field(
        None,
        description="Price per unit (optional, numeric)"
    )
    total_price: Optional[float] = Field(
        None,
        description="Total for this line (optional, numeric)"
    )
    sku: Optional[str] = Field(
        None,
        description="Stock-keeping unit or product code (optional)"
    )

class InvoiceData(BaseModel):
    """Extracted structured data from an invoice or receipt."""

    # Required fields
    invoice_number: Optional[str] = Field(
        None,
        description="Invoice or receipt number (optional but important)"
    )
    invoice_date: Optional[str] = Field(
        None,
        description="Invoice date in ISO format YYYY-MM-DD (optional)"
    )

    # Vendor information
    vendor_name: Optional[str] = Field(
        None,
        description="Vendor/seller name (optional)"
    )
    vendor_address: Optional[str] = Field(
        None,
        description="Vendor address (optional)"
    )
    vendor_phone: Optional[str] = Field(
        None,
        description="Vendor phone or email (optional)"
    )

    # Customer information
    customer_name: Optional[str] = Field(
        None,
        description="Customer/buyer name (optional)"
    )
    customer_address: Optional[str] = Field(
        None,
        description="Customer address (optional)"
    )

    # Amounts
    subtotal: Optional[float] = Field(
        None,
        description="Subtotal before tax (optional, numeric)"
    )
    tax_amount: Optional[float] = Field(
        None,
        description="Tax amount (optional, numeric)"
    )
    total_amount: Optional[float] = Field(
        None,
        description="Total amount due (optional, numeric)"
    )
    currency: Optional[str] = Field(
        None,
        description="Currency code (e.g., USD, EUR) (optional)"
    )

    # Line items
    line_items: Optional[List[LineItem]] = Field(
        None,
        description="Line items from the invoice (optional list)"
    )

    # Additional fields
    payment_terms: Optional[str] = Field(
        None,
        description="Payment terms (e.g., Net 30) (optional)"
    )
    due_date: Optional[str] = Field(
        None,
        description="Due date in ISO format (optional)"
    )

    # Confidence
    extraction_confidence: str = Field(
        default="medium",
        description="Confidence level: high, medium, or low"
    )
    extraction_notes: Optional[str] = Field(
        None,
        description="Any notes or ambiguities during extraction (optional)"
    )

class ExtractionResponse(BaseModel):
    """Response from extraction tool."""
    data: InvoiceData
    errors: List[str] = Field(
        default_factory=list,
        description="Validation errors (empty if valid)"
    )

# ============================================================================
# Tool Definitions for Claude
# ============================================================================

EXTRACTION_TOOLS = [
    {
        "name": "extract_invoice_data",
        "description": "Extract structured data from an invoice, receipt, or similar document. "
                      "Use this tool for any financial/transaction document. "
                      "Returns optional fields when data is not visible or uncertain.",
        "input_schema": {
            "type": "object",
            "properties": {
                "invoice_number": {
                    "type": ["string", "null"],
                    "description": "Invoice or receipt number"
                },
                "invoice_date": {
                    "type": ["string", "null"],
                    "description": "Invoice date (YYYY-MM-DD format)"
                },
                "vendor_name": {
                    "type": ["string", "null"],
                    "description": "Vendor/seller name"
                },
                "vendor_address": {
                    "type": ["string", "null"],
                    "description": "Vendor address"
                },
                "vendor_phone": {
                    "type": ["string", "null"],
                    "description": "Vendor phone or email"
                },
                "customer_name": {
                    "type": ["string", "null"],
                    "description": "Customer/buyer name"
                },
                "customer_address": {
                    "type": ["string", "null"],
                    "description": "Customer address"
                },
                "subtotal": {
                    "type": ["number", "null"],
                    "description": "Subtotal before tax"
                },
                "tax_amount": {
                    "type": ["number", "null"],
                    "description": "Tax amount"
                },
                "total_amount": {
                    "type": ["number", "null"],
                    "description": "Total amount due"
                },
                "currency": {
                    "type": ["string", "null"],
                    "description": "Currency code (USD, EUR, etc)"
                },
                "line_items": {
                    "type": ["array", "null"],
                    "items": {
                        "type": "object",
                        "properties": {
                            "description": {"type": "string"},
                            "quantity": {"type": ["number", "null"]},
                            "unit_price": {"type": ["number", "null"]},
                            "total_price": {"type": ["number", "null"]},
                            "sku": {"type": ["string", "null"]}
                        }
                    },
                    "description": "Line items from the document"
                },
                "payment_terms": {
                    "type": ["string", "null"],
                    "description": "Payment terms (Net 30, etc)"
                },
                "due_date": {
                    "type": ["string", "null"],
                    "description": "Due date (YYYY-MM-DD format)"
                },
                "extraction_confidence": {
                    "type": "string",
                    "enum": ["high", "medium", "low"],
                    "description": "Your confidence in the extraction"
                },
                "extraction_notes": {
                    "type": ["string", "null"],
                    "description": "Any notes about ambiguities or difficulties"
                }
            },
            "required": ["extraction_confidence"]
        }
    }
]

def validate_extraction(data: dict) -> tuple[bool, list[str]]:
    """
    Validate extracted data.

    Returns: (is_valid, list_of_errors)
    """
    errors = []

    # Validate numeric fields
    numeric_fields = ['subtotal', 'tax_amount', 'total_amount']
    for field in numeric_fields:
        if field in data and data[field] is not None:
            try:
                val = float(data[field])
                if val < 0:
                    errors.append(f"{field} cannot be negative: {val}")
            except (ValueError, TypeError):
                errors.append(f"{field} must be numeric: {data[field]}")

    # Validate date format
    date_fields = ['invoice_date', 'due_date']
    for field in date_fields:
        if field in data and data[field] is not None:
            if not _is_valid_iso_date(data[field]):
                errors.append(f"{field} must be in YYYY-MM-DD format: {data[field]}")

    # Validate line items
    if 'line_items' in data and data['line_items']:
        for i, item in enumerate(data['line_items']):
            if 'description' not in item or not item['description']:
                errors.append(f"line_items[{i}].description is required")

    # Validate totals consistency (if all present)
    if all(k in data and data[k] is not None for k in ['subtotal', 'tax_amount', 'total_amount']):
        expected_total = float(data['subtotal']) + float(data['tax_amount'])
        actual_total = float(data['total_amount'])
        if abs(expected_total - actual_total) > 0.01:  # Allow 1 cent rounding error
            errors.append(
                f"Total mismatch: subtotal ({data['subtotal']}) "
                f"+ tax ({data['tax_amount']}) != total ({data['total_amount']})"
            )

    return len(errors) == 0, errors

def _is_valid_iso_date(date_str: str) -> bool:
    """Check if string is valid YYYY-MM-DD format."""
    import re
    return bool(re.match(r'^\d{4}-\d{2}-\d{2}$', date_str))
```

**Task:** Review the schema. What fields are required vs. optional? (Answer: Only `extraction_confidence` is required; all other fields are optional with null allowed.)

---

### Step 2: Implement Few-Shot Examples

Create example extractions to guide the model on varied document structures.

**File: `few_shot_examples.py`**

```python
"""
Few-shot examples for document extraction.

These examples teach the model how to:
1. Handle different document formats
2. Deal with ambiguous or incomplete information
3. Estimate confidence levels
"""

EXTRACTION_EXAMPLES = [
    {
        "type": "standard_invoice",
        "description": "Clean, well-formatted invoice with all data clearly visible",
        "document_content": """
        INVOICE

        Invoice #: INV-2024-00523
        Date: March 15, 2024

        Bill From:
        Acme Corporation
        123 Business Ave
        Springfield, IL 62701
        (217) 555-0123

        Bill To:
        John Smith
        456 Customer Lane
        Chicago, IL 60601

        Items:
        Widget A    Qty: 5    @$29.99 each    $149.95
        Service B   Qty: 1    @$199.99 each   $199.99

        Subtotal:  $349.94
        Tax (8%):  $27.99
        Total:     $377.93

        Due Date: April 15, 2024
        Terms: Net 30
        """,
        "expected_extraction": {
            "invoice_number": "INV-2024-00523",
            "invoice_date": "2024-03-15",
            "vendor_name": "Acme Corporation",
            "vendor_address": "123 Business Ave, Springfield, IL 62701",
            "vendor_phone": "(217) 555-0123",
            "customer_name": "John Smith",
            "customer_address": "456 Customer Lane, Chicago, IL 60601",
            "subtotal": 349.94,
            "tax_amount": 27.99,
            "total_amount": 377.93,
            "currency": "USD",
            "line_items": [
                {"description": "Widget A", "quantity": 5, "unit_price": 29.99, "total_price": 149.95},
                {"description": "Service B", "quantity": 1, "unit_price": 199.99, "total_price": 199.99}
            ],
            "due_date": "2024-04-15",
            "payment_terms": "Net 30",
            "extraction_confidence": "high"
        }
    },
    {
        "type": "partial_receipt",
        "description": "Receipt with some data missing or unclear",
        "document_content": """
        ===== RECEIPT =====
        Store: Corner Mart
        Date: 3/20/24
        Time: 2:45 PM

        Coffee             $4.50
        Sandwich           $8.75
        [illegible item]   $?.??

        Subtotal:    $13.25
        Tax:         $1.06
        Total:       $14.31

        Thank you!
        """,
        "expected_extraction": {
            "vendor_name": "Corner Mart",
            "invoice_date": "2024-03-20",
            "subtotal": 13.25,
            "tax_amount": 1.06,
            "total_amount": 14.31,
            "currency": "USD",
            "line_items": [
                {"description": "Coffee", "total_price": 4.50},
                {"description": "Sandwich", "total_price": 8.75}
            ],
            "extraction_confidence": "medium",
            "extraction_notes": "One line item is illegible; item count may be incomplete"
        }
    },
    {
        "type": "complex_multi_item",
        "description": "Invoice with many line items and complex structure",
        "document_content": """
        PROFESSIONAL SERVICES INVOICE

        Invoice #: PS-2024-001847
        Date: March 1, 2024

        From: Software Solutions LLC
        To: ABC Corporation, Accounts Payable

        Description                          Hours    Rate        Amount
        ============================================================
        System Analysis & Design               40    $150.00    $6,000.00
        Development - Backend                 80    $150.00   $12,000.00
        Development - Frontend                60    $120.00    $7,200.00
        Quality Assurance Testing              20    $100.00    $2,000.00
        Project Management                     15    $120.00    $1,800.00
        ============================================================
        Subtotal:                                                $29,000.00
        Tax (6.5%):                                              $1,885.00
        Total Due:                                              $30,885.00

        Due: April 1, 2024
        Terms: Net 30
        """,
        "expected_extraction": {
            "invoice_number": "PS-2024-001847",
            "invoice_date": "2024-03-01",
            "vendor_name": "Software Solutions LLC",
            "customer_name": "ABC Corporation, Accounts Payable",
            "subtotal": 29000.00,
            "tax_amount": 1885.00,
            "total_amount": 30885.00,
            "currency": "USD",
            "line_items": [
                {"description": "System Analysis & Design", "quantity": 40, "unit_price": 150.00, "total_price": 6000.00},
                {"description": "Development - Backend", "quantity": 80, "unit_price": 150.00, "total_price": 12000.00},
                {"description": "Development - Frontend", "quantity": 60, "unit_price": 120.00, "total_price": 7200.00},
                {"description": "Quality Assurance Testing", "quantity": 20, "unit_price": 100.00, "total_price": 2000.00},
                {"description": "Project Management", "quantity": 15, "unit_price": 120.00, "total_price": 1800.00}
            ],
            "due_date": "2024-04-01",
            "payment_terms": "Net 30",
            "extraction_confidence": "high"
        }
    }
]

def get_few_shot_prompt() -> str:
    """Generate a few-shot prompt with examples."""
    prompt = "## Examples of Invoice Extraction\n\n"

    for i, example in enumerate(EXTRACTION_EXAMPLES, 1):
        prompt += f"### Example {i}: {example['description']}\n\n"
        prompt += f"**Document:**\n```\n{example['document_content']}\n```\n\n"
        prompt += f"**Extracted Data:**\n```json\n"
        prompt += json.dumps(example['expected_extraction'], indent=2)
        prompt += f"\n```\n\n"

    return prompt
```

**Task:** Looking at the three examples, what confidence level would you assign to a document where 80% of fields are visible? (Answer: "medium" — some data is clear, but significant information is missing.)

---

### Step 3: Build Validation-Retry Loop

Create a system that validates extractions and retries with feedback.

**File: `extraction_loop.py`**

```python
from anthropic import Anthropic
import json
from typing import Optional

client = Anthropic()

class ExtractionValidator:
    """Validates extracted data and provides error feedback."""

    def __init__(self, max_retries: int = 2):
        self.max_retries = max_retries

    def validate_and_extract(
        self,
        document_text: str,
        document_image: Optional[str] = None,
        retry_count: int = 0
    ) -> tuple[dict, bool]:
        """
        Extract data from document with validation and retry.

        Args:
            document_text: Text content of document
            document_image: Base64-encoded image (optional)
            retry_count: Current retry iteration

        Returns:
            (extracted_data, success)
        """

        # Build message content
        message_content = []

        if document_image:
            message_content.append({
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": document_image
                }
            })

        message_content.append({
            "type": "text",
            "text": self._build_extraction_prompt(document_text, retry_count)
        })

        # Call Claude with tool
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1500,
            tools=EXTRACTION_TOOLS,
            messages=[
                {"role": "user", "content": message_content}
            ]
        )

        # Extract tool call
        tool_call = None
        for block in response.content:
            if hasattr(block, 'type') and block.type == 'tool_use':
                tool_call = block
                break

        if not tool_call:
            return {}, False

        # Validate extraction
        extracted_data = tool_call.input
        is_valid, errors = validate_extraction(extracted_data)

        if is_valid:
            return extracted_data, True

        # If invalid and retries remaining, retry with error feedback
        if retry_count < self.max_retries:
            print(f"  Validation errors (retry {retry_count + 1}/{self.max_retries}): {errors}")
            # Retry with error feedback
            return self.validate_and_extract_with_feedback(
                document_text,
                document_image,
                extracted_data,
                errors,
                retry_count + 1
            )

        # Max retries exceeded
        print(f"  Max retries exceeded. Returning best effort extraction.")
        return extracted_data, False

    def validate_and_extract_with_feedback(
        self,
        document_text: str,
        document_image: Optional[str],
        previous_extraction: dict,
        errors: list[str],
        retry_count: int
    ) -> tuple[dict, bool]:
        """
        Retry extraction with error feedback to the model.
        """

        error_message = "\n".join([f"- {e}" for e in errors])
        feedback_prompt = f"""
Your previous extraction had the following validation errors:

{error_message}

Please re-examine the document and provide a corrected extraction.
Focus on fixing the errors above.
"""

        message_content = []

        if document_image:
            message_content.append({
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": document_image
                }
            })

        message_content.append({
            "type": "text",
            "text": f"{self._build_extraction_prompt(document_text, retry_count)}\n\n{feedback_prompt}"
        })

        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1500,
            tools=EXTRACTION_TOOLS,
            messages=[
                {"role": "user", "content": message_content}
            ]
        )

        # Extract tool call
        tool_call = None
        for block in response.content:
            if hasattr(block, 'type') and block.type == 'tool_use':
                tool_call = block
                break

        if not tool_call:
            return previous_extraction, False

        extracted_data = tool_call.input
        is_valid, errors = validate_extraction(extracted_data)

        if is_valid or retry_count >= self.max_retries:
            return extracted_data, is_valid

        # Continue retrying
        return self.validate_and_extract_with_feedback(
            document_text,
            document_image,
            extracted_data,
            errors,
            retry_count + 1
        )

    def _build_extraction_prompt(self, document_text: str, retry_count: int) -> str:
        """Build the extraction prompt with few-shot examples."""

        few_shot = get_few_shot_prompt()

        base_prompt = f"""
You are an expert document analysis AI. Your task is to extract structured data from documents.

{few_shot}

## Current Document

Please extract data from the following document. Return your extraction using the extract_invoice_data tool.

**Document Content:**
```
{document_text}
```

Instructions:
1. Extract all visible information accurately
2. Use null/None for fields that are not present
3. Set extraction_confidence to high/medium/low based on data completeness
4. Provide extraction_notes if there are any ambiguities
5. Return your findings via the extract_invoice_data tool
"""

        if retry_count > 0:
            base_prompt += f"\n[This is retry attempt {retry_count} - please focus on accuracy]"

        return base_prompt
```

**Task:** In the validation-retry loop, when should the system give up and return the best-effort extraction? (Answer: After max_retries attempts, or when validation succeeds.)

---

### Step 4: Batch Processing with Failure Handling

Implement batch processing using the Anthropic Batches API.

**File: `batch_processor.py`**

```python
import json
import time
from anthropic import Anthropic
from typing import List, Dict
import uuid

client = Anthropic()

class BatchExtractionProcessor:
    """Process multiple documents using the Batches API."""

    def __init__(self, batch_size: int = 100):
        self.batch_size = batch_size
        self.failed_documents = {}
        self.successful_documents = {}

    def create_batch_requests(self, documents: List[Dict]) -> List[Dict]:
        """
        Convert documents to batch API requests.

        Each document should have:
        - custom_id: unique identifier
        - document_text: text content
        - document_image: optional base64 image
        """

        requests = []

        for doc in documents:
            custom_id = doc.get('custom_id', str(uuid.uuid4()))

            # Build message content
            message_content = []

            if doc.get('document_image'):
                message_content.append({
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/jpeg",
                        "data": doc['document_image']
                    }
                })

            message_content.append({
                "type": "text",
                "text": get_few_shot_prompt() + f"\n\nExtract data from:\n```\n{doc['document_text']}\n```"
            })

            # Create request
            request = {
                "custom_id": custom_id,
                "params": {
                    "model": "claude-sonnet-4-6",
                    "max_tokens": 1500,
                    "tools": EXTRACTION_TOOLS,
                    "messages": [
                        {"role": "user", "content": message_content}
                    ]
                }
            }

            requests.append(request)

        return requests

    def submit_batch(self, requests: List[Dict]) -> str:
        """
        Submit a batch of extraction requests.

        Returns: batch_id
        """

        print(f"Submitting batch with {len(requests)} requests...")

        batch = client.beta.messages.batches.create(
            requests=requests
        )

        print(f"Batch submitted with ID: {batch.id}")
        return batch.id

    def wait_for_batch(self, batch_id: str, max_wait_seconds: int = 300) -> Dict:
        """
        Wait for batch to complete.

        Returns: Batch status object
        """

        start_time = time.time()

        while True:
            batch = client.beta.messages.batches.retrieve(batch_id)

            print(f"Batch {batch_id} status: {batch.processing_status}")
            print(f"  Succeeded: {batch.request_counts.succeeded}")
            print(f"  Errored: {batch.request_counts.errored}")
            print(f"  Expired: {batch.request_counts.expired}")

            if batch.processing_status == "completed":
                return batch

            if time.time() - start_time > max_wait_seconds:
                print(f"Batch timeout after {max_wait_seconds}s")
                raise TimeoutError(f"Batch {batch_id} did not complete in time")

            time.sleep(5)

    def process_batch_results(self, batch_id: str) -> Dict:
        """
        Process results from a completed batch.

        Returns: {successful: [...], failed: [...]}
        """

        successful = []
        failed = []

        # Retrieve all results
        results = client.beta.messages.batches.results(batch_id)

        for result in results:
            custom_id = result.custom_id

            if result.result.type == "succeeded":
                # Extract tool call from response
                tool_call = None
                for block in result.result.message.content:
                    if hasattr(block, 'type') and block.type == 'tool_use':
                        tool_call = block
                        break

                if tool_call:
                    extracted_data = tool_call.input

                    # Validate
                    is_valid, errors = validate_extraction(extracted_data)

                    successful.append({
                        "custom_id": custom_id,
                        "data": extracted_data,
                        "valid": is_valid,
                        "errors": errors
                    })
                else:
                    failed.append({
                        "custom_id": custom_id,
                        "reason": "No tool call in response"
                    })

            elif result.result.type == "errored":
                failed.append({
                    "custom_id": custom_id,
                    "reason": result.result.error.message
                })

            elif result.result.type == "expired":
                failed.append({
                    "custom_id": custom_id,
                    "reason": "Request expired before processing"
                })

        self.successful_documents[batch_id] = successful
        self.failed_documents[batch_id] = failed

        return {"successful": successful, "failed": failed}

    def retry_failed_documents(self, batch_id: str, original_documents: List[Dict]) -> str:
        """
        Retry documents that failed in the original batch.

        Returns: new_batch_id
        """

        failed_ids = {doc['custom_id'] for doc in self.failed_documents.get(batch_id, [])}

        retry_docs = [
            doc for doc in original_documents
            if doc.get('custom_id') in failed_ids
        ]

        print(f"Retrying {len(retry_docs)} failed documents...")

        requests = self.create_batch_requests(retry_docs)
        new_batch_id = self.submit_batch(requests)

        return new_batch_id

def run_full_batch_pipeline(documents: List[Dict], max_retries: int = 1):
    """
    Run complete batch processing pipeline with retry logic.

    Args:
        documents: List of document dicts with custom_id, document_text, etc.
        max_retries: Number of times to retry failed documents

    Returns:
        Final results summary
    """

    processor = BatchExtractionProcessor()

    all_successful = []
    all_failed = []

    batch_ids = []
    current_batch_id = None

    # Initial batch submission
    requests = processor.create_batch_requests(documents)
    current_batch_id = processor.submit_batch(requests)
    batch_ids.append(current_batch_id)

    # Wait and process
    batch = processor.wait_for_batch(current_batch_id)
    results = processor.process_batch_results(current_batch_id)

    all_successful.extend(results['successful'])
    all_failed.extend(results['failed'])

    print(f"\nInitial batch: {len(results['successful'])} succeeded, {len(results['failed'])} failed")

    # Retry loop
    retry_count = 0
    while all_failed and retry_count < max_retries:
        retry_count += 1
        print(f"\nRetry {retry_count}/{max_retries}...")

        new_batch_id = processor.retry_failed_documents(current_batch_id, documents)
        batch_ids.append(new_batch_id)

        # Wait and process
        batch = processor.wait_for_batch(new_batch_id)
        results = processor.process_batch_results(new_batch_id)

        # Move newly successful documents
        all_successful.extend(results['successful'])

        # Keep failed documents
        all_failed = results['failed']

        print(f"Retry batch: {len(results['successful'])} succeeded, {len(results['failed'])} failed")

    # Final summary
    summary = {
        "total_documents": len(documents),
        "successful": len(all_successful),
        "failed": len(all_failed),
        "success_rate": len(all_successful) / len(documents) if documents else 0,
        "batch_ids": batch_ids,
        "successful_extractions": all_successful,
        "failed_documents": all_failed
    }

    return summary
```

**Task:** In the retry logic, how many times will a document be attempted if max_retries=2? (Answer: Up to 3 times total — 1 initial attempt + 2 retries.)

---

### Step 5: Test with Sample Documents

Create test scenarios with sample documents.

**File: `test_extraction.py`**

```python
import json
import base64
from batch_processor import run_full_batch_pipeline

# Sample documents for testing
TEST_DOCUMENTS = [
    {
        "custom_id": "doc-001",
        "document_text": """
        INVOICE

        Invoice #: INV-2024-00523
        Date: March 15, 2024

        Bill From:
        Acme Corporation
        123 Business Ave
        Springfield, IL 62701

        Bill To:
        John Smith
        456 Customer Lane
        Chicago, IL 60601

        Items:
        Widget A    Qty: 5    @$29.99 each    $149.95
        Service B   Qty: 1    @$199.99 each   $199.99

        Subtotal:  $349.94
        Tax (8%):  $27.99
        Total:     $377.93

        Due Date: April 15, 2024
        """
    },
    {
        "custom_id": "doc-002",
        "document_text": """
        RECEIPT

        Store: Corner Market
        Date: 3/20/24

        Milk             $3.99
        Bread            $2.49
        Coffee           $8.50

        Subtotal:    $14.98
        Tax (7%):    $1.05
        Total:       $16.03
        """
    },
    {
        "custom_id": "doc-003",
        "document_text": """
        [Partially damaged/illegible document]

        INVOICE: [unclear]
        Date: 2024-02

        Customer: Jane Doe

        Services rendered:
        Professional consultation - $500
        [illegible line]

        TOTAL: $500-750 (estimate)
        """
    }
]

def test_batch_extraction():
    """Test batch extraction pipeline."""

    print("Starting batch extraction test...")
    print(f"Processing {len(TEST_DOCUMENTS)} documents\n")

    results = run_full_batch_pipeline(
        TEST_DOCUMENTS,
        max_retries=1
    )

    print("\n" + "="*70)
    print("FINAL RESULTS")
    print("="*70)
    print(f"Total Documents: {results['total_documents']}")
    print(f"Successful: {results['successful']}")
    print(f"Failed: {results['failed']}")
    print(f"Success Rate: {results['success_rate']:.1%}")

    # Print successful extractions
    print("\nSuccessful Extractions:")
    for doc in results['successful_extractions']:
        print(f"\n  Document {doc['custom_id']}:")
        print(f"    Valid: {doc['valid']}")
        if doc['errors']:
            print(f"    Errors: {doc['errors']}")
        if doc['data'].get('vendor_name'):
            print(f"    Vendor: {doc['data'].get('vendor_name')}")
        if doc['data'].get('total_amount'):
            print(f"    Total: ${doc['data'].get('total_amount')}")

    # Print failed documents
    if results['failed_documents']:
        print("\nFailed Documents:")
        for doc in results['failed_documents']:
            print(f"  Document {doc['custom_id']}: {doc['reason']}")

    return results

if __name__ == "__main__":
    test_batch_extraction()
```

---

## Expected Outcomes & Success Criteria

### Successful Extraction Pipeline
1. **Schema validation:** All extracted fields match JSON schema
2. **Few-shot learning:** Model accurately extracts varied document types
3. **Error feedback:** Validation errors are communicated; model corrects on retry
4. **Batch processing:** 20+ documents processed efficiently via Batches API
5. **Failure handling:** Failed documents are tracked and retried separately
6. **Custom ID tracking:** Each document's extraction can be traced back to source

### Test Pass Criteria
- All test documents extract without exceptions
- JSON output conforms to defined schema
- Validation catches errors (e.g., subtotal != total + tax)
- Retry loop successfully corrects at least one validation error
- Batch processing completes and tracks results by custom_id
- Failed documents are identifiable and can be retried

### Sample Output
```
Batch {batch_id} status: completed
  Succeeded: 18
  Errored: 2
  Expired: 0

Retry 1/1...
Batch {retry_batch_id} status: completed
  Succeeded: 2
  Errored: 0
  Expired: 0

FINAL RESULTS
===================
Total Documents: 20
Successful: 20
Failed: 0
Success Rate: 100.0%

Successful Extractions:
  Document doc-001:
    Valid: True
    Vendor: Acme Corporation
    Total: $377.93

  Document doc-002:
    Valid: True
    Vendor: Corner Market
    Total: $16.03

  Document doc-003:
    Valid: False
    Errors: ['extraction_confidence': document is too damaged, confidence = 'low']
```

---

## Common Mistakes to Avoid

1. **Overly required fields:** If all fields are required, extractions fail on partial documents
2. **No nullable support:** Don't allow null in schema → can't represent missing data
3. **Skipping validation:** Assuming Claude output is always correct → bugs in production
4. **No retry logic:** Single attempt fails if model makes errors → low quality
5. **Lost failed documents:** No tracking of which documents failed → re-process everything
6. **Manual batch polling:** Busy-waiting instead of exponential backoff → API rate limits
7. **No custom_id usage:** Can't trace extractions back to source documents
8. **Ignoring confidence scores:** Treating low-confidence extractions same as high → garbage data

---

## Connection to Exam Concepts

**Domain 4: Prompt Engineering & Outputs**
- **Task 4.1:** Design structured outputs with JSON schema
  - Comprehensive extraction schemas with required, optional, nullable fields
- **Task 4.2:** Use few-shot examples to improve output quality
  - Three example extractions demonstrating varied document types

**Domain 5: System Design & Scaling**
- **Task 5.1:** Process multiple requests efficiently
  - Batches API for processing 20+ documents at once
- **Task 5.2:** Handle failures and implement recovery
  - Retry logic for failed documents; custom_id tracking

**Relevant Course Modules:** Module 4 (Structured Outputs), Module 5 (Batch Processing & Scaling)

---

## Estimated Time to Complete

- **Step 1 (Schema design):** 20 minutes
- **Step 2 (Few-shot examples):** 15 minutes
- **Step 3 (Validation-retry loop):** 20 minutes
- **Step 4 (Batch processing):** 25 minutes
- **Step 5 (Testing):** 15 minutes
- **Testing & debugging:** 20 minutes
- **Total:** 115 minutes (1.9 hours)

**Suggested Checkpoint:** After Step 3, verify that single-document extraction works with retry logic before moving to batch processing.

---

## Additional Challenges (Optional)

1. **Add OCR preprocessing:** For image documents, use Claude's vision to extract text first
2. **Implement document classification:** Detect document type (invoice vs. receipt vs. contract) before extraction
3. **Build a confidence threshold system:** Reject extractions below confidence threshold; flag for human review
4. **Add custom extraction fields:** Allow users to define additional fields beyond standard invoice data
5. **Implement incremental batch processing:** Stream results as they complete instead of waiting for full batch
6. **Add data normalization:** Convert all dates to ISO format, currencies to standard codes, etc.
7. **Build a historical comparison:** Check if document looks like a duplicate of a previous extraction
8. **Implement cost tracking:** Calculate API cost per document and total batch cost
