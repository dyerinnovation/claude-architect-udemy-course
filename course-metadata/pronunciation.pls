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

</lexicon>
