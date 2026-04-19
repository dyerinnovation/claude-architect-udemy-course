# Quiz: Prompt Engineering (Domain 4)

## Question 1
**What does tool_choice: any guarantee about the model's behavior?**

- A) The model will call at least one tool; it MUST use a tool
- B) The model will call a tool if it's useful; tool use is optional
- C) The model can choose any tool from the allowed list without constraint
- D) The model will call a random tool from the available options

**Correct Answer**: A

**Explanation**: Setting tool_choice to "any" tells the model that it MUST call a tool—at least one tool call is guaranteed in the response. This is useful when you need to force structured output or ensure that a tool-based action happens (e.g., forcing the model to call a decision tool rather than reasoning about it). The model still chooses which tool and with what parameters; the constraint is only that a call must happen.

**Domain**: Domain 4 - Prompt Engineering

---

## Question 2
**When should you use the Batch API versus synchronous (real-time) API calls?**

- A) Always use Batch API for latency; synchronous is deprecated
- B) Always use synchronous; Batch API is only for testing
- C) Use Batch API for high-volume, non-time-sensitive work (cost savings, efficiency); use synchronous for real-time, interactive, or low-latency needs
- D) The two APIs have identical performance; choose based on personal preference

**Correct Answer**: C

**Explanation**: The Batch API processes requests asynchronously in bulk, offering significant cost savings and efficiency at the cost of latency (can take hours). Synchronous API calls are real-time with immediate responses but cost more per request. Choose Batch API for scenarios like overnight analysis, bulk data processing, or comprehensive quality reviews. Choose synchronous for interactive applications, real-time decisions, or when latency is critical.

**Domain**: Domain 4 - Prompt Engineering

---

## Question 3
**Tool use eliminates the risk of what types of errors, but NOT others?**

- A) Eliminates syntax errors; does NOT eliminate semantic errors
- B) Eliminates all errors if designed correctly
- C) Eliminates parsing errors; does NOT eliminate conceptual errors
- D) Eliminates reasoning errors; does NOT eliminate hallucination

**Correct Answer**: A

**Explanation**: Using tools with structured schemas prevents syntax errors—malformed JSON, incorrect field types, invalid formats—because the model must conform to the schema. However, tools do NOT prevent semantic errors—the model could call the right tool with syntactically correct parameters that are logically wrong (e.g., searching for the wrong query or with incorrect filters). Tool design is about format safety, not meaning validation.

**Domain**: Domain 4 - Prompt Engineering

---

## Question 4
**When is the retry-with-feedback pattern most effective, and when does it struggle?**

- A) Effective for all errors; works equally well regardless of error type
- B) Effective for recoverable errors (format, missing data); less effective for conceptual misunderstandings (wrong approach, misinterpretation)
- C) Effective only when feedback is extremely detailed
- D) Effective when retrying from scratch; ineffective when using context from the previous attempt

**Correct Answer**: B

**Explanation**: Retry-with-feedback works well for syntax and simple logical errors ("your JSON was invalid, here's what went wrong"). The model can correct itself based on the feedback. However, it struggles with deeper issues like misunderstanding the task, using the wrong approach, or fundamental misinterpretation—telling the model "that's wrong, try again" doesn't address the root misconception. For conceptual errors, a fresh perspective or reformulation of the task is more effective.

**Domain**: Domain 4 - Prompt Engineering

---

## Question 5
**When evaluating model output, should you use an independent review instance or self-review?**

- A) Always use self-review to save cost and tokens
- B) Always use independent review; self-review is inherently biased
- C) Use independent review for critical evaluations; self-review can work for minor quality checks
- D) The two approaches are equivalent; choose based on token budget

**Correct Answer**: C

**Explanation**: Independent review (using a separate agent or model instance to evaluate) is more reliable because it provides a fresh perspective without the bias of the original reasoning. However, independent review costs more tokens. For critical decisions (code security, compliance, legal matters), independent review is worth the cost. For minor quality checks or iterative improvements, self-review can be acceptable if you frame the evaluation as a distinct task rather than asking the model to approve its own work.

**Domain**: Domain 4 - Prompt Engineering

---

## Question 6
**For what types of tasks are few-shot examples most effective?**

- A) Complex reasoning tasks where the model needs to understand nuanced decision criteria
- B) Simple, well-known tasks where the model has extensive training data
- C) Tasks involving uncommon patterns, specific formatting, or domain-specific conventions
- D) Few-shot examples are equally effective for all task types

**Correct Answer**: C

**Explanation**: Few-shot examples are most valuable when teaching the model non-obvious patterns: specific output formats, domain-specific terminology, uncommon decision rules, or novel combinations. For well-established tasks (basic classification, standard formatting), the model likely has sufficient training examples. Few-shot examples help when you're asking the model to do something outside its standard training distribution.

**Domain**: Domain 4 - Prompt Engineering

---

## Question 7
**How do nullable fields in a tool schema help prevent hallucination?**

- A) Nullable fields have no effect on hallucination
- B) Nullable fields allow the model to omit uncertain or unknown values rather than fabricating them
- C) Nullable fields force the model to provide all fields, preventing incomplete responses
- D) Nullable fields are deprecated and should not be used

**Correct Answer**: B

**Explanation**: When a field is marked as nullable, the model can return null/None for that field instead of making up a value. This is powerful for preventing hallucination—when the model is uncertain about data, it can explicitly indicate "I don't know" (null) rather than confidently asserting a fabricated value. This turns the schema into a boundary: the model can only return real data or null, not invented data.

**Domain**: Domain 4 - Prompt Engineering

---

## Question 8
**What is the multi-pass review pattern, and when is it valuable?**

- A) Running the same task multiple times and averaging results
- B) First pass for generation, second pass for critique/improvement, then additional passes as needed
- C) Running a task in parallel on multiple machines for speed
- D) The multi-pass pattern is not a recognized best practice

**Correct Answer**: B

**Explanation**: The multi-pass review pattern involves multiple sequential passes: (1) generation pass—create initial output, (2) review pass—critique and identify issues, (3) improvement pass—refine based on critiques, with additional passes as needed. This is valuable for complex tasks where immediate perfection is unlikely but iterative refinement is effective. Each pass is explicitly framed as a distinct task to avoid the "evaluate your own work" problem. This pattern works well for code review, writing, design critique, and other creative/analytical tasks.

**Domain**: Domain 4 - Prompt Engineering
