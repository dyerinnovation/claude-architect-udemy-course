<?xml version="1.0" encoding="UTF-8"?>
<!--
  Pronunciation overrides for the Claude Certified Architect (CCA) course.

  These entries are MERGED with the universal tech-term template at
  udemy-course-builder/.claude/skills/udemy-lecture-video-renderer/pronunciation.template.pls
  by tts_render.py at render time. Course entries win on grapheme conflict.

  The merged dictionary is uploaded once to ElevenLabs and cached at
  course-metadata/tts-config.json. The cache is invalidated automatically
  when either PLS file changes.

  To add a new pronunciation override:
    1. Add a <lexeme> entry below with IPA phonemes
    2. Re-run any lecture render — the skill auto-detects the PLS change
       and re-uploads the merged dictionary

  IPA reference: standard American English conventions.
-->

<lexicon version="1.0"
         xmlns="http://www.w3.org/2005/01/pronunciation-lexicon"
         alphabet="ipa"
         xml:lang="en-US">

  <!-- =====================================================================
       Anthropic + Claude model family — required for every CCA lecture
       ===================================================================== -->

  <!-- Anthropic: stress on second syllable — an-THROP-ic -->
  <lexeme>
    <grapheme>Anthropic</grapheme>
    <phoneme>ænˈθrɒpɪk</phoneme>
  </lexeme>

  <!-- Claude: single syllable, rhymes with "clawed" -->
  <lexeme>
    <grapheme>Claude</grapheme>
    <phoneme>klɔːd</phoneme>
  </lexeme>

  <!-- Sonnet: two syllables, SON-it -->
  <lexeme>
    <grapheme>Sonnet</grapheme>
    <phoneme>ˈsɒnɪt</phoneme>
  </lexeme>

  <!-- Opus: two syllables, OH-pus -->
  <lexeme>
    <grapheme>Opus</grapheme>
    <phoneme>ˈoʊpəs</phoneme>
  </lexeme>

  <!-- Haiku: two syllables, HY-koo -->
  <lexeme>
    <grapheme>Haiku</grapheme>
    <phoneme>ˈhaɪkuː</phoneme>
  </lexeme>

  <!-- =====================================================================
       Certification + course-specific acronyms
       ===================================================================== -->

  <!-- MCP: EM-SEE-PEE (Model Context Protocol) -->
  <lexeme>
    <grapheme>MCP</grapheme>
    <phoneme>ˌɛm siː ˈpiː</phoneme>
  </lexeme>

  <!-- CCA: SEE-SEE-AY (Claude Certified Architect) -->
  <lexeme>
    <grapheme>CCA</grapheme>
    <phoneme>ˌsiː siː ˈeɪ</phoneme>
  </lexeme>

  <!-- CCA-F: SEE-SEE-AY-EFF (CCA Foundations exam track) -->
  <lexeme>
    <grapheme>CCA-F</grapheme>
    <phoneme>ˌsiː siː eɪ ˈɛf</phoneme>
  </lexeme>

</lexicon>
