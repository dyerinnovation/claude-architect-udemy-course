# Demo: Multi-Agent Research Pipeline — Detailed Script

**Duration**: ~15 min | **Section**: 11 | **Demo**: 4

---

### [0:00] Introduction

- In this demo, we'll build a multi-agent research pipeline where a coordinator delegates to specialized subagents in parallel and synthesizes their findings with full provenance.
  - Coordinator emits multiple `Task` calls in a single response to run subagents in parallel.
  - Each subagent returns structured findings with claim / evidence / source / date.
  - A simulated timeout exercises error propagation; conflicting sources exercise synthesis with attribution.
- This prepares you for Domain 1 (multi-agent orchestration), Domain 2 (Task-tool delegation), and Domain 5 (error propagation and provenance).

---

### [0:30] Deploy Demo Environment

<!-- pip install, export ANTHROPIC_API_KEY, run research_coordinator.py with a sample question. Show the coordinator agent definition with allowedTools including Task. -->

---

### [2:00] Coordinator Delegates with Explicit Context Passing

<!-- Show the coordinator prompt. Highlight that each subagent's prompt contains the specific sub-question AND the relevant context — we do NOT rely on automatic context inheritance. Explain why: subagents have isolated contexts by design. -->

---

### [4:30] Parallel Subagent Execution via Multiple Task Calls

<!-- Show a single coordinator response emitting two Task tool_use blocks (web-search, document-analysis). Time a sequential baseline vs the parallel run. Report the latency improvement. -->

---

### [7:00] Structured Findings with Provenance

<!-- Show a subagent output: { claim: "...", evidence: "excerpt...", source_url: "...", publication_date: "..." }. Then show the synthesis subagent preserving each claim's attribution in the final report rather than collapsing sources. -->

---

### [9:30] Error Propagation: Simulated Subagent Timeout

<!-- Force a timeout in one subagent. The coordinator receives a structured error context: failure_type, attempted_query, partial_results. The coordinator does NOT abort; it continues with partial results and emits a "coverage gaps" section in the final report. -->

---

### [12:00] Conflicting-Source Synthesis

<!-- Feed in two credible sources with different numbers for the same statistic. The synthesis output preserves BOTH values with attribution rather than picking one. The final report structures findings into "well-established" vs "contested." -->

---

### [14:00] Cleanup and Wrap

<!-- Deactivate venv, remove research-output. Recap: explicit context passing, parallel Task calls, provenance in synthesis, error propagation with coverage gaps, conflicting-source handling. -->
