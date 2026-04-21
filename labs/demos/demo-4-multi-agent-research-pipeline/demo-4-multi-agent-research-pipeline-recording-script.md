# Demo 4: Multi-Agent Research Pipeline — Recording Script

**Duration:** ~8–10 min | **Section:** 11 | **Demo:** 4
**Record:** OBS full screen, terminal + editor side-by-side
**Working dir:** `labs/demos/demo-4-multi-agent-research-pipeline/demo-4-multi-agent-research-pipeline-infrastructure-build-scripts/`

---

### [0:00] Opening — Why single-context research agents fall over

**Narration:** Welcome to Demo 4 — the Multi-Agent Research Pipeline. This is the demo behind Exam Scenario 3, and it hits two of the biggest-weighted domains on the exam: Domain 1, Agentic Architecture at 27 percent, and Domain 5, Context Management and Reliability at 15 percent. The setup is simple — I hand one Claude agent a broad research question: "How do modern LLM agent memory architectures compare?" Watch what happens. It search-snippets its way through ten URLs, the context fills up, and by the time it writes the report it is synthesizing sources that are buried in the middle of its window. The claims get vague. Provenance evaporates. That is the failure mode we are about to fix.

**On-screen:**
- Left pane: single-agent run log scrolling — `[search_web] → [search_web] → [search_web] → ...` context token count climbing past 80k.
- Right pane: final report output with highlighted phrase "sources suggest" (no attribution).

---

### [0:45] Hub-and-spoke architecture overview

**Narration:** The fix is hub-and-spoke. Instead of one long-context agent, we use a coordinator — the hub — whose only job is to decompose, dispatch, and aggregate. It spawns three subagents — the spokes — each with a focused sub-question and, critically, its own isolated context window. The subagents never see each other's messages. They each return a structured handoff to the coordinator, which aggregates them into a provenance-annotated final report. This is the orchestrator-workers pattern straight out of Anthropic's "Building Effective Agents" post, and it is the canonical answer to any Scenario 3 question on the exam.

**On-screen:**
- Display the ASCII architecture diagram from `infrastructure-build-scripts/README.md` — coordinator at top, three subagent boxes beneath, arrows labeled "decompose → dispatch → handoff → aggregate."

---

### [1:45] Coordinator decomposes the research question

**Narration:** Here is the coordinator's decomposition step. I pass it the question, and its system prompt tells it to produce three focused, non-overlapping sub-questions — one per subagent. Notice the decomposition prompt explicitly forbids sub-questions that would require reading the same sources, because overlapping sub-questions are how you waste parallelism and leak context assumptions. The coordinator returns a JSON list of three sub-questions. That list is the dispatch plan.

**On-screen:**
- Open `research_pipeline.py` and scroll to `coordinator_decompose()`.
- Highlight the decomposition system prompt.
- In terminal, run `python research_pipeline.py --question "..."` — paused at the decomposition output — show the three sub-questions printed.

---

### [2:45] Task-spawning three parallel subagents

**Narration:** Now the coordinator dispatches. In production on the Claude Agent SDK you would emit three `Task` tool calls in a single assistant response — that is the SDK-native primitive for parallel isolated-context subagents. For demo reproducibility we use a `ThreadPoolExecutor` with three parallel Messages-API calls, which is functionally equivalent and clearly labeled in the code comments. The key architectural property is the same: three subagents, dispatched in parallel, each with its own messages list. I resume the run. Three subagents light up simultaneously.

**On-screen:**
- Highlight `spawn_subagents_parallel()` in the code — point at the `# PRODUCTION: Task tool. DEMO: ThreadPoolExecutor.` comment.
- Terminal: three `[subagent-1] starting...`, `[subagent-2] starting...`, `[subagent-3] starting...` lines appearing within the same second.

---

### [4:00] Isolated context — three private messages lists

**Narration:** This is the part people miss on the exam. Each subagent has its own messages list. The `subagent-1` conversation is a completely separate Python list from `subagent-2` and `subagent-3`. Nothing one subagent learns can leak into another's context. Why does that matter? Because if you let context bleed across spokes you reintroduce exactly the long-context degradation the hub-and-spoke pattern was supposed to fix. Look at the three log streams side-by-side — they are disjoint. No shared state. That isolation is what makes each subagent's window manageable.

**On-screen:**
- Split terminal into three panes (tmux or OBS scene).
- Each pane tails a subagent's log: `subagent-1.log`, `subagent-2.log`, `subagent-3.log`.
- Visual cue: highlight that none of the three mentions what the other two are researching.

---

### [5:15] Structured handoff schema

**Narration:** Every subagent returns the same shape — `subagent_handoff.json`. It has a `subagent_id`, a `coverage` field describing what the subagent actually managed to cover, and a `claims` array. Each claim has a `text`, a `source_url`, and a `confidence` score. That schema is what makes provenance possible downstream. Without it, the coordinator would be guessing which claim came from which source. With it, every claim in the final report carries its origin like a tag.

**On-screen:**
- Open `schemas/subagent_handoff.json` in the editor.
- Switch to terminal: `cat ./research-output/handoff-subagent-1.json | jq` — show a real handoff with 4–5 claims.

---

### [6:15] Coordinator aggregation with claim-source provenance

**Narration:** The coordinator collects all three handoffs and aggregates. This is the provenance step — Domain 5 territory. Every claim in the final report is written with an inline marker: the subagent id that produced it and the source URL. Nothing gets summarized away. If you want to audit where a statement came from, you follow the tag back to the source. The final report also validates against `final_report.json` — so downstream consumers can parse it programmatically without regex-hacking citations out of prose.

**On-screen:**
- Open `schemas/final_report.json`.
- Terminal: `cat ./research-output/report-*.json | jq '.claims[0]'` — show `{ text, subagent_id, source_url, confidence }`.
- Scroll through the human-readable summary printed to stdout — every bullet ends with `[subagent-2, https://...]`.

---

### [7:30] Conflicting-source handling

**Narration:** Now the interesting failure mode. What if two subagents return contradictory claims about the same fact? The naive move is to silently pick the higher-confidence one — which is exactly how hallucinations get laundered into final reports. The correct move, and the one the exam wants you to design, is to flag the conflict. In this pipeline the aggregator runs a pairwise similarity check across claims — when two claims reference the same entity but disagree, it emits a `conflicts` entry in the final report listing both claims with their sources and confidences, and it defers resolution to the human reader. The pipeline never silently chooses.

**On-screen:**
- Terminal: `python research_pipeline.py --question "$(sed -n '3p' sample-questions.txt)"` — a question designed to trip conflicts.
- Output shows `"conflicts": [ {...} ]` section in the report.
- Highlight `detect_conflicts()` in code.

---

### [8:30] Recap + exam framing

**Narration:** Let's wrap. You just watched four exam-anchor patterns fire in one pipeline. Task-decomposition — the coordinator split one broad question into three focused ones. Parallel subagent spawning — three Task calls from a single coordinator step, each with an isolated context window. Explicit context passing — each subagent got its sub-question in its opening prompt, not via inheritance. Claim-source provenance — every fact in the final report maps back to a subagent and a URL, and conflicts are flagged rather than swallowed. On exam day, when you see a Scenario 3 question — multi-agent research, coordinator misbehaving, context leaking, provenance missing — the answer is almost always going to be one of these four moves. That is Domain 1 at 27 percent and Domain 5 at 15 percent working together. See you in Demo 5.

**On-screen:**
- Full-screen recap card with four bullets:
  - Task decomposition
  - Parallel Task-tool dispatch
  - Context isolation per subagent
  - Claim-source provenance + conflict flags
- End card: "Domain 1 (27%) + Domain 5 (15%) — Exam Scenario 3."
