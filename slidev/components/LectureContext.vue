<!--
  LectureContext — "How this lecture fits in" slide.

  Sits as the SECOND slide in every lecture deck (between cover and
  "what you'll learn"). Shows the lecture's positioning via 3 numbered
  tiles.

  Two reveal modes:

  - DEFAULT (initial-blank=false): tile 1 is visible from slide entry;
    tiles 2 and 3 reveal on click 1 and click 2. The script's SLIDE 2
    narration has 2 [click] markers → 3 narration sub-chunks. Matches
    every Section 2-7 lecture's existing audit output (Wave 1 / Phase B).

  - OPT-IN (initial-blank=true): the slide enters BLANK (no tiles); each
    click reveals one tile in turn — click 1 → tile 1, click 2 → tile 2,
    click 3 → tile 3. The script's SLIDE 2 narration has 3 [click] markers
    → 4 narration sub-chunks (intro + one per tile). Adopted for
    lecture 2.2 round-1 per user feedback "we need 1 more frame before c0
    that starts without any of the steps showing."

  Required: `tiles` array of exactly 3 objects with `label` + `detail` fields.
-->
<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'

defineProps({
  eyebrow: { type: String, default: 'How this lecture fits in' },
  title: { type: String, default: "Here's how this lecture fits into the course" },
  tiles: {
    type: Array,
    required: true,
    validator: (a) => Array.isArray(a) && a.length === 3,
  },
  // tiles: [{ label: String, detail: String }] x3
  initialBlank: { type: Boolean, default: false },
  footerLabel: { type: String, default: '' },
  footerNum: { type: [Number, String], default: 1 },
  footerTotal: { type: [Number, String], default: 1 },
  hideFooter: { type: Boolean, default: false },
})
</script>

<template>
  <Frame>
    <Eyebrow v-if="eyebrow">
      {{ eyebrow }}
    </Eyebrow>
    <SlideTitle>{{ title }}</SlideTitle>

    <ul class="lcx__list">
      <template v-if="initialBlank">
        <!-- All three tiles inside v-clicks so the slide enters blank.
             Click counts: 3 reveals total (one per tile). -->
        <v-clicks>
          <li class="lcx__row">
            <div class="lcx__num">01</div>
            <div class="lcx__text">
              <div class="lcx__label">{{ tiles[0].label }}</div>
              <div v-if="tiles[0].detail" class="lcx__detail">{{ tiles[0].detail }}</div>
            </div>
          </li>
          <li class="lcx__row">
            <div class="lcx__num">02</div>
            <div class="lcx__text">
              <div class="lcx__label">{{ tiles[1].label }}</div>
              <div v-if="tiles[1].detail" class="lcx__detail">{{ tiles[1].detail }}</div>
            </div>
          </li>
          <li class="lcx__row">
            <div class="lcx__num">03</div>
            <div class="lcx__text">
              <div class="lcx__label">{{ tiles[2].label }}</div>
              <div v-if="tiles[2].detail" class="lcx__detail">{{ tiles[2].detail }}</div>
            </div>
          </li>
        </v-clicks>
      </template>
      <template v-else>
        <!-- Tile 1 always visible; tiles 2 and 3 inside v-clicks.
             Click counts: 2 reveals total. Backwards-compat default. -->
        <li class="lcx__row">
          <div class="lcx__num">01</div>
          <div class="lcx__text">
            <div class="lcx__label">{{ tiles[0].label }}</div>
            <div v-if="tiles[0].detail" class="lcx__detail">{{ tiles[0].detail }}</div>
          </div>
        </li>
        <v-clicks>
          <li class="lcx__row">
            <div class="lcx__num">02</div>
            <div class="lcx__text">
              <div class="lcx__label">{{ tiles[1].label }}</div>
              <div v-if="tiles[1].detail" class="lcx__detail">{{ tiles[1].detail }}</div>
            </div>
          </li>
          <li class="lcx__row">
            <div class="lcx__num">03</div>
            <div class="lcx__text">
              <div class="lcx__label">{{ tiles[2].label }}</div>
              <div v-if="tiles[2].detail" class="lcx__detail">{{ tiles[2].detail }}</div>
            </div>
          </li>
        </v-clicks>
      </template>
    </ul>

    <SlideFooter v-if="!hideFooter" :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.lcx__list {
  list-style: none;
  margin: 56px 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 14px;
  flex: 1;
  min-height: 0;
}
.lcx__row {
  display: grid;
  grid-template-columns: 72px 1fr;
  align-items: start;
  gap: 24px;
  padding: 20px 28px;
  background: var(--paper-0);
  border: 1px solid var(--paper-200);
  border-left: 6px solid var(--sprout-500);
  border-radius: 14px;
}
.lcx__num {
  font-family: var(--font-mono);
  font-size: 24px;
  font-weight: 600;
  color: var(--sprout-600);
  letter-spacing: 0.05em;
  padding-top: 4px;
}
.lcx__label {
  font-family: var(--font-display);
  font-size: 34px;
  font-weight: 500;
  color: var(--forest-800);
  line-height: 1.18;
  letter-spacing: -0.01em;
}
.lcx__detail {
  font-family: var(--font-body);
  font-size: 24px;
  line-height: 1.45;
  color: var(--forest-500);
  margin-top: 8px;
}
</style>
