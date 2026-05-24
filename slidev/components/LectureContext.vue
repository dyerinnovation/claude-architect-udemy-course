<!--
  LectureContext — "How this lecture fits in" slide.

  Sits as the SECOND slide in every lecture deck (between cover and
  "what you'll learn"). Shows the lecture's positioning via 3 numbered
  tiles: tile 1 is the foundational framing (visible from slide entry);
  tiles 2 and 3 reveal on click 1 and click 2, adding nuance and forward
  context.

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
