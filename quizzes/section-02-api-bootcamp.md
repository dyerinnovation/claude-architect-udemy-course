# Quiz: Section 2 — Claude API Fundamentals Bootcamp

**Scope**: Section 2 lectures 2.1–2.11. Messages API anatomy, system prompts, sampling parameters (temperature / top_p / top_k), prefilled assistant messages, stop sequences, streaming, structured output, XML tags, multimodal input, and the tool-use loop fundamentals.

**Format**: 10 questions — ~6 multiple choice, ~2 true/false, ~2 multi-select. Every distractor is "almost-right" — a technique that works in a different context but fails here. Each question ends with an Explanation covering why the correct answer is correct and why each distractor fails.

**Note**: Section 2 is API-level foundational content. Section 2 doesn't map to a specific exam domain — it's the hands-on API fluency the rest of the course depends on. Questions here mirror the kind of API-literacy test a scenario question assumes you already passed.

---

## Q1 (multiple choice) — API Fundamentals · Scenario 1

**Stem:**
A junior engineer on your team put the airline customer-support bot's persona instructions ("You are Sky Support, friendly but professional...") inside the first `user` message of every conversation. Three turns in, the bot starts answering like a generic assistant. What's the single-change fix?

A) Raise `max_tokens` so the persona instructions aren't truncated mid-conversation.
B) Move the persona instructions into the top-level `system` parameter.
C) Re-send the persona block as a new `user` message before every turn.
D) Lower `temperature` to 0.2 so Claude sticks to the persona.

**Correct Answer:** B

### Explanation
The `system` parameter is the persistent brief — it lives outside the `messages` array and applies to every turn. Persona drift happens when instructions are buried in one `user` message and then washed out by subsequent turns. (A) doesn't fix drift; `max_tokens` governs *output* length, not input retention. (C) works but is wasteful and brittle — you're paying tokens every turn to re-do what `system` does for free. (D) reduces variation but doesn't preserve persona; a low-temperature bot can still drift if its instructions aren't persistent.

---

## Q2 (multiple choice) — API Fundamentals · Scenario 6

**Stem:**
You're extracting structured JSON from 10,000 documents overnight and the pipeline keeps failing because a fraction of responses start with "Sure! Here's the JSON you asked for..." before the actual JSON. What's the most reliable fix?

A) Lower `temperature` to 0 so Claude stops adding preambles.
B) Add a stricter instruction in the system prompt: "Return only JSON. No preamble."
C) Prefill the assistant turn with `{` so Claude continues from that exact character.
D) Use `response_format: "json_object"` to strip preamble text automatically.

**Correct Answer:** C

### Explanation
Prefilling the assistant turn forces Claude to continue from the exact character you provide — Claude cannot add anything *before* the prefill. Starting the assistant turn with `{` guarantees JSON-only output from the first token. (A) reduces but doesn't eliminate preamble drift. (B) is the most tempting distractor — prompt instructions usually work, but "usually" fails at 10k-document scale. (D) confuses the concept — `json_object` ensures valid JSON syntax but doesn't prevent wrapping prose (and it certainly doesn't "strip" preamble).

---

## Q3 (multiple choice) — API Fundamentals · Scenario 6

**Stem:**
Your team needs a guarantee that every response matches a strict JSON schema (specific fields, specific types). Which technique gives the strongest schema-compliance guarantee?

A) Asking for JSON in the system prompt and validating after the fact.
B) Setting `response_format` to `json_object`.
C) Defining the schema as a tool and calling with `tool_choice: {"type": "tool", "name": "..."}`.
D) Lowering `temperature` to 0 so Claude's output becomes deterministic.

**Correct Answer:** C

### Explanation
Tool-use with a JSON Schema is the strongest schema-compliance pattern — the schema is enforced on Claude's output at the API level, not just parsed after. (A) is "usually works," which is not a guarantee. (B) ensures *valid JSON syntax* but doesn't enforce your *specific* field shape. (D) reduces variation within a strategy but doesn't add schema enforcement. Scenario 6 (Structured Data Extraction) asks this question in multiple forms — memorize: schema-compliance = tool-use with forced tool_choice.

---

## Q4 (multiple choice) — API Fundamentals · Scenario 1

**Stem:**
Your agent's loop reads `response.stop_reason` to decide whether to continue. One tool-use request comes back with `stop_reason == "stop_sequence"`. What does that tell you?

A) The agent invoked a tool and the loop should continue.
B) Claude finished its turn normally and the loop should end.
C) Claude generated one of the strings in your `stop_sequences` array and halted.
D) The API hit `max_tokens` before Claude finished generating.

**Correct Answer:** C

### Explanation
`stop_reason` is a structured enum: `"end_turn"` (natural completion), `"tool_use"` (tool invoked, loop continues), `"max_tokens"` (output cap hit), and `"stop_sequence"` (one of your custom stop strings matched). (A) would be `"tool_use"`. (B) would be `"end_turn"`. (D) would be `"max_tokens"`. These four values matter for every Domain 1 question — knowing the distinct meaning of each is the difference between a correct loop and a silently-broken one.

---

## Q5 (true/false) — API Fundamentals

**Stem:**
**True or False:** When you set `temperature = 0`, Claude's output becomes fully deterministic — identical prompts will always produce byte-identical responses.

A) True
B) False

**Correct Answer:** B (False)

### Explanation
`temperature = 0` makes Claude *nearly* deterministic by collapsing the sampling distribution to the highest-probability token at each step — but not fully deterministic. Residual nondeterminism can come from GPU-level numerical effects in the inference stack, batched-inference ordering, or model updates. The exam-safe framing: `temperature=0` is "highly repeatable," not "guaranteed identical." The distractor here is the very common developer shorthand that equates 0 with pure determinism.

---

## Q6 (multiple choice) — API Fundamentals · Scenarios 1, 5

**Stem:**
You're building a customer-facing chatbot UI and users complain it "feels slow" even though latency is fine. What's the right architectural response?

A) Raise `temperature` so responses feel more varied and less "slow."
B) Switch to a smaller model and accept the quality trade-off.
C) Use response streaming (SSE) so tokens render as they're generated instead of waiting for the full response.
D) Call the API from the frontend directly to skip a server hop.

**Correct Answer:** C

### Explanation
Streaming is the right lever for *perceived* latency — tokens arrive and render as they're generated, so users see output within ~100ms instead of waiting for the whole response. The absolute latency doesn't change; the perceived latency does. (A) has nothing to do with latency. (B) trades real quality for marginal latency gain. (D) is a security anti-pattern (API key exposure) and solves a different problem (network hops, not time-to-first-token).

---

## Q7 (multiple choice) — API Fundamentals · Scenario 6

**Stem:**
You have a prompt that bundles instructions, a reference document, and a user query all in one text blob. Claude occasionally confuses which part is which. Which single change reliably clarifies structure for Claude?

A) Move everything into the `system` prompt so it's all persistent.
B) Wrap each section in distinct XML tags like `<instructions>`, `<document>`, and `<query>`.
C) Lower `temperature` to 0 so Claude focuses on the literal text.
D) Add bullet points with bold headers to separate the sections.

**Correct Answer:** B

### Explanation
Claude was trained on enormous volumes of HTML/XML-like content, so it parses XML-delimited sections natively. Wrapping regions in distinct tags is the cheapest, most reliable structural fix. (A) doesn't solve structure — it just changes where the blob lives. (C) affects variation, not comprehension. (D) markdown headers help humans but are a weaker structural signal than XML tags for Claude — the kind of "almost-right" distractor the exam loves.

---

## Q8 (multi-select) — API Fundamentals

**Stem:**
Select ALL of the following that are true about the `top_p` and `top_k` sampling parameters. (Choose two.)

A) `top_k` limits sampling to the K highest-probability tokens at each step.
B) `top_p` (nucleus sampling) limits sampling to the smallest set of tokens whose cumulative probability meets P.
C) `top_p` and `top_k` replace `temperature` — you set one but not both.
D) `top_k = 1` is equivalent to greedy decoding with `temperature = 0`.

**Correct Answers:** A, B

### Explanation
(A) and (B) are textbook definitions of the two sampling parameters. (C) is false — `temperature` and `top_p`/`top_k` are complementary, and combining them is common practice (Anthropic's guidance: tune one *or* the other, but they can coexist). (D) is the tempting almost-right: `top_k = 1` does force the top token, but so does `temperature = 0` — they aren't *equivalent* semantically (one truncates, one sharpens the distribution), and the exam doesn't treat them as the same mechanism.

---

## Q9 (multiple choice) — API Fundamentals · Scenario 4

**Stem:**
A user sends a screenshot of an engineering diagram and asks Claude to describe it. Where does the image go in the Messages API?

A) In a separate `image` parameter alongside `messages`.
B) As a base64 string inside the `system` prompt.
C) Inside the `content` array of a `user` message as an `image`-type content block.
D) It doesn't — images require a different API endpoint.

**Correct Answer:** C

### Explanation
Images live inside the `content` array of a `user` message as a content block with `type: "image"`, alongside `type: "text"` blocks. The unified content-block model is how the Messages API handles multimodal input — same endpoint, same message structure. (A) invents a parameter that doesn't exist. (B) abuses `system` in a way that won't render as an image at all. (D) is the "I'll just use DALL·E's pattern" trap — wrong API model.

---

## Q10 (multiple choice) — API Fundamentals · Scenario 1

**Stem:**
Your agent calls a `lookup_order` tool, the API returns `stop_reason: "tool_use"`, and you run the tool locally. You now need to send the tool's result back to Claude so it can continue. Where does the `tool_result` block go?

A) Inside a `user`-role message's `content` array.
B) Inside an `assistant`-role message's `content` array.
C) In the top-level `tool_results` parameter alongside `messages`.
D) Inside the `system` parameter as a fresh standing brief.

**Correct Answer:** A

### Explanation
Tool results belong in `user`-role messages. From Claude's perspective, `user` messages represent information coming *from* the external environment — and a tool result is literally that. (B) is the classic anti-pattern — tool_result in an assistant message is structurally invalid. (C) invents a top-level parameter that doesn't exist. (D) would make the result appear as a permanent standing brief, which makes no sense for a single tool invocation. This is one of the five agentic-loop anti-patterns Lecture 3.3 lists — appears directly as a Domain 1 distractor.
