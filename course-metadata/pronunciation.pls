<?xml version="1.0" encoding="UTF-8"?>
<!--
  Pronunciation overrides for the Claude Certified Architect (CCA) course.

  Uses <alias> rules (literal text substitution). eleven_multilingual_v2
  silently IGNORES <phoneme> rules — do NOT switch this file to phoneme. See
  the renderer playbook section "ElevenLabs pronunciation rule types —
  alias vs phoneme model support".

  These entries are MERGED with the universal tech-term template at
  udemy-course-builder/.claude/skills/udemy-lecture-video-renderer/pronunciation.template.pls
  by tts_render.py at render time. Course entries win on grapheme conflict.

  The merged dictionary is uploaded once to ElevenLabs and cached at
  course-metadata/tts-config.json. The cache is invalidated automatically
  when either PLS file changes.

  To add a new pronunciation override:
    1. Add a <lexeme> entry below with the spoken-English alias text
    2. Re-run any lecture render — the skill auto-detects the PLS change
       and re-uploads the merged dictionary
-->

<lexicon version="1.0" xmlns="http://www.w3.org/2005/01/pronunciation-lexicon" xml:lang="en-US">

  <!-- Anthropic + Claude model family — required for every CCA lecture -->
  <lexeme><grapheme>Anthropic</grapheme><alias>an-THROP-ick</alias></lexeme>
  <lexeme><grapheme>Claude</grapheme><alias>clawed</alias></lexeme>
  <lexeme><grapheme>Sonnet</grapheme><alias>sahn it</alias></lexeme>
  <lexeme><grapheme>Opus</grapheme><alias>OH-pus</alias></lexeme>
  <lexeme><grapheme>Haiku</grapheme><alias>HIGH-koo</alias></lexeme>

  <!-- Certification + course-specific acronyms (phonetic English spelling) -->
  <lexeme><grapheme>MCP</grapheme><alias>em see pee</alias></lexeme>
  <lexeme><grapheme>CCA</grapheme><alias>see see ay</alias></lexeme>
  <lexeme><grapheme>CCA-F</grapheme><alias>see see ay eff</alias></lexeme>

  <!-- API / APIs aliasing — round-3 (2026-05-25).

       Round-2 hypothesis was WRONG: I thought the comma form A,P,I was
       misbinding. I escalated to "letter A, letter P, letter I" — which
       ElevenLabs applied verbatim, so the user heard "letter ay, letter
       pee, letter eye" on every API mention. ROLLED BACK.

       Actual round-2 root cause was a PLS-application failure: the dict on
       ElevenLabs wasn't binding API for that specific render (stale upload,
       version mismatch, or merge-cache miss). The comma alias `A, P, I`
       itself is correct and has been since round-5.

       Going-forward rule: when API (or any letter-acronym) regresses, FIRST
       verify the PLS uploaded + the cached dict ID is current. Do NOT
       escalate the alias text — verbose forms get vocalized literally.

       Plural-of-letter-acronym gotcha: `<alias>A, P, I, s</alias>` reads
       as four separate utterances with an awkward standalone "ess" at the
       end. Use the word "eyes" instead so the plural ess blends naturally
       into the natural plural sound ("ay, pee, eyes"). -->
  <lexeme><grapheme>API</grapheme><alias>A, P, I</alias></lexeme>
  <lexeme><grapheme>APIs</grapheme><alias>A, P, eyes</alias></lexeme>

  <!-- Claude API field names — strip underscores so TTS reads naturally -->
  <lexeme><grapheme>stop_reason</grapheme><alias>stop reason</alias></lexeme>
  <lexeme><grapheme>stop_sequence</grapheme><alias>stop sequence</alias></lexeme>
  <lexeme><grapheme>max_tokens</grapheme><alias>max tokens</alias></lexeme>
  <lexeme><grapheme>tool_use</grapheme><alias>tool use</alias></lexeme>
  <lexeme><grapheme>tool_result</grapheme><alias>tool result</alias></lexeme>
  <lexeme><grapheme>end_turn</grapheme><alias>end turn</alias></lexeme>

  <!-- 2-letter common-word identifiers — force letter-reading mode -->
  <lexeme><grapheme>id</grapheme><alias>I. D.</alias></lexeme>

  <!-- W1-A additions for lectures 2.2-2.4 -->
  <lexeme><grapheme>conversation_history</grapheme><alias>conversation history</alias></lexeme>
  <lexeme><grapheme>top_p</grapheme><alias>top P</alias></lexeme>
  <lexeme><grapheme>top_k</grapheme><alias>top K</alias></lexeme>
  <lexeme><grapheme>stop_sequences</grapheme><alias>stop sequences</alias></lexeme>

  <!-- W1-C additions for lectures 2.8-2.11 -->
  <!-- Lecture 2.9 (Multimodal) -->
  <lexeme><grapheme>media_type</grapheme><alias>media type</alias></lexeme>
  <lexeme><grapheme>image_data</grapheme><alias>image data</alias></lexeme>
  <lexeme><grapheme>image_file</grapheme><alias>image file</alias></lexeme>
  <lexeme><grapheme>base64</grapheme><alias>base sixty-four</alias></lexeme>
  <!-- Lecture 2.10 (Tool Use Fundamentals) -->
  <lexeme><grapheme>input_schema</grapheme><alias>input schema</alias></lexeme>
  <lexeme><grapheme>get_current_weather</grapheme><alias>get current weather</alias></lexeme>
  <lexeme><grapheme>get_weather_tool</grapheme><alias>get weather tool</alias></lexeme>
  <lexeme><grapheme>tool_use_block</grapheme><alias>tool use block</alias></lexeme>
  <lexeme><grapheme>tool_use_id</grapheme><alias>tool use I. D.</alias></lexeme>
  <lexeme><grapheme>snake_case</grapheme><alias>snake case</alias></lexeme>
  <!-- Lecture 2.11 (Tool Use Loop) -->
  <lexeme><grapheme>execute_tool</grapheme><alias>execute tool</alias></lexeme>
  <lexeme><grapheme>tool_use_blocks</grapheme><alias>tool use blocks</alias></lexeme>
  <lexeme><grapheme>tool_results</grapheme><alias>tool results</alias></lexeme>
  <lexeme><grapheme>run_agent</grapheme><alias>run agent</alias></lexeme>
  <lexeme><grapheme>user_message</grapheme><alias>user message</alias></lexeme>
  <lexeme><grapheme>get_weather</grapheme><alias>get weather</alias></lexeme>
  <lexeme><grapheme>get_forecast</grapheme><alias>get forecast</alias></lexeme>
  <lexeme><grapheme>get_5day_forecast</grapheme><alias>get five day forecast</alias></lexeme>

  <!-- W1-B additions for lectures 2.5-2.7 -->
  <!-- (stop_sequences and input_schema already covered above by W1-A/W1-C) -->

  <!-- Lecture 2.6 (Response Streaming) — SSE event names + streaming identifiers -->
  <lexeme><grapheme>message_start</grapheme><alias>message start</alias></lexeme>
  <lexeme><grapheme>message_delta</grapheme><alias>message delta</alias></lexeme>
  <lexeme><grapheme>message_stop</grapheme><alias>message stop</alias></lexeme>
  <lexeme><grapheme>content_block_start</grapheme><alias>content block start</alias></lexeme>
  <lexeme><grapheme>content_block_delta</grapheme><alias>content block delta</alias></lexeme>
  <lexeme><grapheme>content_block_stop</grapheme><alias>content block stop</alias></lexeme>
  <lexeme><grapheme>text_delta</grapheme><alias>text delta</alias></lexeme>
  <lexeme><grapheme>text_stream</grapheme><alias>text stream</alias></lexeme>
  <lexeme><grapheme>input_json_delta</grapheme><alias>input json delta</alias></lexeme>
  <lexeme><grapheme>partial_json</grapheme><alias>partial json</alias></lexeme>
  <lexeme><grapheme>event_type</grapheme><alias>event type</alias></lexeme>
  <lexeme><grapheme>final_message</grapheme><alias>final message</alias></lexeme>
  <lexeme><grapheme>get_final_message</grapheme><alias>get final message</alias></lexeme>
  <lexeme><grapheme>input_tokens</grapheme><alias>input tokens</alias></lexeme>

  <!-- Lecture 2.7 (Structured Output) -->
  <lexeme><grapheme>tool_choice</grapheme><alias>tool choice</alias></lexeme>
  <lexeme><grapheme>response_format</grapheme><alias>response format</alias></lexeme>
  <lexeme><grapheme>json_object</grapheme><alias>json object</alias></lexeme>
  <lexeme><grapheme>extract_order</grapheme><alias>extract order</alias></lexeme>
  <lexeme><grapheme>extraction_tool</grapheme><alias>extraction tool</alias></lexeme>
  <lexeme><grapheme>order_id</grapheme><alias>order I. D.</alias></lexeme>
  <lexeme><grapheme>order_data</grapheme><alias>order data</alias></lexeme>
  <lexeme><grapheme>customer_name</grapheme><alias>customer name</alias></lexeme>
  <lexeme><grapheme>total_amount</grapheme><alias>total amount</alias></lexeme>
  <lexeme><grapheme>raw_json</grapheme><alias>raw json</alias></lexeme>
  <lexeme><grapheme>structured_data</grapheme><alias>structured data</alias></lexeme>

  <!-- W2-A additions for lectures 3.1-3.4 -->
  <lexeme><grapheme>execute_tools</grapheme><alias>execute tools</alias></lexeme>
  <lexeme><grapheme>initial_prompt</grapheme><alias>initial prompt</alias></lexeme>
  <lexeme><grapheme>is_error</grapheme><alias>is error</alias></lexeme>
  <lexeme><grapheme>allowedTools</grapheme><alias>allowed tools</alias></lexeme>

  <!-- W2-C additions for lectures 3.10-3.14 -->
  <!-- Lecture 3.10 (Programmatic Enforcement vs Prompt-Based Guidance) -->
  <lexeme><grapheme>limit_exceeded</grapheme><alias>limit exceeded</alias></lexeme>
  <lexeme><grapheme>process_refund</grapheme><alias>process refund</alias></lexeme>
  <!-- Lecture 3.11 (Agent SDK Hooks — PostToolUse / PreToolUse) -->
  <lexeme><grapheme>PostToolUse</grapheme><alias>post tool use</alias></lexeme>
  <lexeme><grapheme>PreToolUse</grapheme><alias>pre tool use</alias></lexeme>
  <lexeme><grapheme>PostToolUseHook</grapheme><alias>post tool use hook</alias></lexeme>
  <lexeme><grapheme>PreToolUseHook</grapheme><alias>pre tool use hook</alias></lexeme>
  <lexeme><grapheme>on_tool_result</grapheme><alias>on tool result</alias></lexeme>
  <lexeme><grapheme>on_tool_call</grapheme><alias>on tool call</alias></lexeme>
  <lexeme><grapheme>BlockToolCall</grapheme><alias>block tool call</alias></lexeme>
  <lexeme><grapheme>RefundGuardHook</grapheme><alias>refund guard hook</alias></lexeme>
  <lexeme><grapheme>TimestampNormalizationHook</grapheme><alias>timestamp normalization hook</alias></lexeme>
  <lexeme><grapheme>AgentLoop</grapheme><alias>agent loop</alias></lexeme>
  <lexeme><grapheme>errorCategory</grapheme><alias>error category</alias></lexeme>
  <lexeme><grapheme>isRetryable</grapheme><alias>is retryable</alias></lexeme>
  <!-- Lecture 3.12 (Task Decomposition) -->
  <lexeme><grapheme>max_steps</grapheme><alias>max steps</alias></lexeme>
  <!-- Lecture 3.13 (Session Management) -->
  <lexeme><grapheme>fork_session</grapheme><alias>fork session</alias></lexeme>
  <lexeme><grapheme>build_session_summary</grapheme><alias>build session summary</alias></lexeme>
  <lexeme><grapheme>start_fresh_with_summary</grapheme><alias>start fresh with summary</alias></lexeme>
  <!-- Lecture 3.14 (Structured Handoff Summaries) -->
  <lexeme><grapheme>HandoffSummary</grapheme><alias>handoff summary</alias></lexeme>
  <lexeme><grapheme>generate_handoff_summary</grapheme><alias>generate handoff summary</alias></lexeme>
  <lexeme><grapheme>actions_tried</grapheme><alias>actions tried</alias></lexeme>
  <lexeme><grapheme>verified_actions</grapheme><alias>verified actions</alias></lexeme>
  <lexeme><grapheme>session_state</grapheme><alias>session state</alias></lexeme>
  <lexeme><grapheme>escalation_reason</grapheme><alias>escalation reason</alias></lexeme>

  <!-- W2-B additions for lectures 3.5-3.9 -->
  <!-- Subagent tool names recurring across 3.5-3.9 (allowedTools, is_error already covered by W2-A) -->
  <lexeme><grapheme>read_file</grapheme><alias>read file</alias></lexeme>
  <lexeme><grapheme>read_url</grapheme><alias>read U. R. L.</alias></lexeme>
  <lexeme><grapheme>run_tests</grapheme><alias>run tests</alias></lexeme>
  <lexeme><grapheme>search_documents</grapheme><alias>search documents</alias></lexeme>
  <lexeme><grapheme>web_search</grapheme><alias>web search</alias></lexeme>
  <lexeme><grapheme>write_file</grapheme><alias>write file</alias></lexeme>
  <!-- Lecture 3.9 (Explicit Context Passing) — claim payload helpers -->
  <lexeme><grapheme>build_claim_payload</grapheme><alias>build claim payload</alias></lexeme>
  <lexeme><grapheme>synthesize_with_context</grapheme><alias>synthesize with context</alias></lexeme>

  <!-- W2-E additions for lectures 4.8-4.14 -->
  <!-- Lecture 4.8 (Tool Distribution). web_search + process_refund already covered above. -->
  <lexeme><grapheme>load_document</grapheme><alias>load document</alias></lexeme>
  <lexeme><grapheme>verify_fact</grapheme><alias>verify fact</alias></lexeme>
  <!-- Lecture 4.9 (tool_choice — auto/any/forced). tool_choice already covered above. -->
  <lexeme><grapheme>extract_invoice</grapheme><alias>extract invoice</alias></lexeme>
  <lexeme><grapheme>extract_receipt</grapheme><alias>extract receipt</alias></lexeme>
  <lexeme><grapheme>extract_po</grapheme><alias>extract P. O.</alias></lexeme>
  <lexeme><grapheme>extract_metadata</grapheme><alias>extract metadata</alias></lexeme>
  <lexeme><grapheme>extract_v1</grapheme><alias>extract V. one</alias></lexeme>
  <!-- Lecture 4.10 (MCP server scope) and 4.11 (env-var expansion) — filename references stay as plain English in narration; ${VAR} pattern already spelled phonetically. -->
  <!-- Lecture 4.12 (resources vs tools) -->
  <lexeme><grapheme>search_jira_issue</grapheme><alias>search jira issue</alias></lexeme>
  <lexeme><grapheme>search_all_docs</grapheme><alias>search all docs</alias></lexeme>
  <lexeme><grapheme>list_issues</grapheme><alias>list issues</alias></lexeme>
  <lexeme><grapheme>get_doc</grapheme><alias>get doc</alias></lexeme>
  <!-- Lecture 4.13/4.14 (built-ins + incremental) — Grep/Glob/Read/Edit/Write are plain English, no PLS needed. -->

  <!-- W2-D additions for lectures 4.1-4.7 -->
  <!-- Lecture 4.1 / 4.2 / 4.3 / 4.4 — recurring customer-support + analyze-document tool names -->
  <!-- (process_refund already covered by W2-C at line ~119; errorCategory + isRetryable at lines ~131-132.) -->
  <lexeme><grapheme>get_customer</grapheme><alias>get customer</alias></lexeme>
  <lexeme><grapheme>lookup_order</grapheme><alias>lookup order</alias></lexeme>
  <lexeme><grapheme>lookup_entity</grapheme><alias>lookup entity</alias></lexeme>
  <lexeme><grapheme>escalate_to_human</grapheme><alias>escalate to human</alias></lexeme>
  <lexeme><grapheme>customer_id</grapheme><alias>customer I. D.</alias></lexeme>
  <!-- Lecture 4.3 (Diagnosing Selection Failures) — analyze_* family + extract -->
  <lexeme><grapheme>extract_web_results</grapheme><alias>extract web results</alias></lexeme>
  <!-- Lecture 4.4 (Splitting vs Consolidating) — three-tool split + cosmetic-duplicate cluster -->
  <lexeme><grapheme>extract_data_points</grapheme><alias>extract data points</alias></lexeme>
  <lexeme><grapheme>summarize_content</grapheme><alias>summarize content</alias></lexeme>
  <lexeme><grapheme>verify_claim_against_source</grapheme><alias>verify claim against source</alias></lexeme>
  <lexeme><grapheme>summarize_doc</grapheme><alias>summarize doc</alias></lexeme>
  <lexeme><grapheme>document_summary</grapheme><alias>document summary</alias></lexeme>
  <lexeme><grapheme>summary_from_document</grapheme><alias>summary from document</alias></lexeme>
  <!-- Lecture 4.5 / 4.6 (MCP Error Response Design) — camelCase error-response fields -->
  <!-- (errorCategory + isRetryable handled above; isError is W2-D-specific.) -->
  <lexeme><grapheme>isError</grapheme><alias>is error</alias></lexeme>
  <!-- Lecture 4.7 (Local Recovery vs Propagation) — failure_type / attempted_query / partial_results stay in narration as plain English; no PLS needed. -->

</lexicon>
