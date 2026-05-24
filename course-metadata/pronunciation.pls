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

</lexicon>
