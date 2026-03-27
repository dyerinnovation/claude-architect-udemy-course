# Out-of-Scope Topics: What NOT to Study

Save your study time. These topics will NOT be on the Claude Certified Architect exam.

---

## Definitive Out-of-Scope List

### ❌ Fine-Tuning
- Fine-tuning models on custom data
- Training procedures
- LoRA, parameter-efficient fine-tuning
- Model customization techniques

**Why not tested:** Exam focuses on using Claude API, not training/customization.

---

### ❌ API Authentication & Credentials
- How to generate/manage API keys
- OAuth flows for user auth
- Authentication protocols
- Credential rotation strategies
- Secret management best practices

**Why not tested:** Authentication is external to Claude's responsibilities. You handle auth outside the API.

---

### ❌ MCP Infrastructure
- How MCP servers are built from scratch
- MCP registry internals
- Server lifecycle management
- MCP protocol implementation details
- Transport layer specifics

**Why not tested:** Exam assumes you use existing MCP tools; doesn't test building MCP from ground up.

---

### ❌ Claude Internals
- How Claude was trained
- Model architecture details
- Transformer internals
- Attention mechanisms
- Model size/parameters

**Why not tested:** Exam is about using Claude, not understanding how it works internally.

---

### ❌ Constitutional AI (CAI)
- Constitutional AI training methods
- Harmlessness training procedures
- How Claude learned to refuse
- Training data composition

**Why not tested:** CAI is part of Claude's training, not relevant to architectural decisions.

---

### ❌ Embeddings & Vector Databases
- Embedding models (text-embedding-3, etc.)
- Vector database setup (Pinecone, Weaviate, etc.)
- Cosine similarity calculations
- RAG (Retrieval-Augmented Generation) implementation details
- Semantic search

**Why not tested:** While context management matters, embeddings/vectors are advanced and out-of-scope.

---

### ❌ Computer Vision
- Claude's vision capabilities
- Image analysis features
- OCR (optical character recognition)
- Image-to-text functionality

**Why not tested:** Exam focuses on text-based architecture. Vision is a feature, not an architectural concern.

---

### ❌ Streaming
- Streaming API implementation
- Real-time token streaming
- Stream handling in client code
- Buffering strategies

**Why not tested:** Streaming is an optimization detail, not a core architectural pattern.

---

### ❌ Rate Limiting
- API rate limit calculations
- How Anthropic enforces limits
- Rate limit headers/response codes
- Backoff strategies

**Why not tested:** Rate limiting is operational; exam focuses on design, not infrastructure limits.

---

### ❌ Prompt Caching (Implementation Details)
- How Anthropic caches prompts
- Cache invalidation mechanics
- Cache storage infrastructure
- Technical implementation

**Note:** You should know WHAT prompt caching is and WHEN to use it, but not HOW it's implemented.

---

### ❌ Token Counting Details
- Exact tokenization algorithm
- How specific characters are counted
- Token tier boundaries
- Tiktoken internals

**Note:** You should understand token budgeting conceptually, but not exact token counts for every character.

---

## What IS In-Scope (Clarification)

### ✓ Context Management
- Token budgeting (reserve output, manage history)
- When to truncate vs summarize
- Context window strategy

### ✓ System Prompts & Structured Outputs
- Designing prompts for reliability
- JSON schema for structured outputs
- Validation strategies

### ✓ Tool Design & MCP
- When to use MCP tools
- Tool error response categories
- Tool composition patterns
- MCP protocol basics (enough to use it)

### ✓ Agentic Architecture
- Multi-agent patterns
- Tool-use loops
- stop_reason handling
- Workflow orchestration

### ✓ Claude Code & Workflows
- .claude/config.yaml setup
- Workflow definitions
- Environment configuration
- .claude/rules/ hierarchy

---

## Study Strategy

**Do NOT:**
- Read papers on Constitutional AI
- Study transformer architecture
- Learn to build MCP servers from scratch
- Deep-dive into how embeddings work
- Memorize API rate limits

**DO:**
- Master the 5 domains (Agentic, Tools, Code Config, Prompting, Context)
- Practice with real scenarios
- Study the 6 exam scenarios
- Review the exam guide
- Focus on architectural patterns

---

## Time-Saving Summary

If someone is teaching you about these topics for the exam, **stop them:**

| Topic | What to Skip |
|-------|--------------|
| Fine-tuning | All of it |
| Auth/Credentials | All of it |
| MCP infrastructure | Building servers |
| Claude internals | All of it |
| Constitutional AI | All of it |
| Embeddings | Most of it |
| Vision APIs | All of it |
| Streaming | Most of it |
| Rate limits | Specifics |
| Token counting | Exact formulas |
| Prompt caching | Implementation details |

---

## One Clarification: "The Exam Doesn't Test..."

You'll see this phrase often in study guides. Here's what it means:

**"The exam doesn't test fine-tuning"** = You won't be asked:
- "How do you fine-tune Claude?"
- "Write code to fine-tune a model"
- "What's a good fine-tuning dataset?"

**But you might be tested on:**
- "When should you NOT fine-tune and use prompting instead?"

---

## Key Insight

**The exam tests architectural thinking, not implementation details.**

It's not about:
- How does Claude work? (Internals)
- How do I set up authentication? (DevOps)
- How do I build a tool server? (Infrastructure)

It IS about:
- When should I use this tool? (Design)
- How do I structure this system? (Architecture)
- What's the right pattern for this scenario? (Judgment)

---

## Before You Start Studying

Ask yourself:
- "Will knowing this help me design better Claude systems?" → Study it
- "Is this about how Claude works internally?" → Skip it
- "Is this about infrastructure/auth/DevOps?" → Skip it
- "Is this about using Claude's APIs?" → Study it
