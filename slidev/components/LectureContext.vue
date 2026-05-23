<!--
  LectureContext — "How this lecture fits in" slide.

  Sits as the SECOND slide in every lecture deck (between cover and
  "what you'll learn"). Shows a breadcrumb (phase › lectureLabel), a
  large centered essence statement, and optional prev/next context rows
  that frame the lecture within the section/course flow.

  prev/next context rows reveal on click (2 clicks total) when both are
  provided. Single-row decks still work — the row simply doesn't render.
-->
<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'

defineProps({
  eyebrow: { type: String, default: 'How this lecture fits in' },
  phase: { type: String, required: true },
  lectureLabel: { type: String, required: true },
  prevContext: { type: String, default: '' },
  nextContext: { type: String, default: '' },
  essence: { type: String, required: true },
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
    <SlideTitle>How this lecture fits in</SlideTitle>

    <div class="lcx">
      <div class="lcx__breadcrumb">
        <span class="lcx__crumb">{{ phase }}</span>
        <span class="lcx__sep">&rsaquo;</span>
        <span class="lcx__crumb lcx__crumb--current">{{ lectureLabel }}</span>
      </div>

      <div class="lcx__essence">
        <span class="lcx__essence-text">&ldquo;{{ essence }}&rdquo;</span>
      </div>

      <div class="lcx__context">
        <v-clicks>
          <div v-if="prevContext" class="lcx__row lcx__row--prev">
            <span class="lcx__arrow">&larr;</span>
            <span class="lcx__row-text">{{ prevContext }}</span>
          </div>
          <div v-if="nextContext" class="lcx__row lcx__row--next">
            <span class="lcx__arrow">&rarr;</span>
            <span class="lcx__row-text">{{ nextContext }}</span>
          </div>
        </v-clicks>
      </div>
    </div>

    <SlideFooter v-if="!hideFooter" :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.lcx {
  margin-top: 48px;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 36px;
  min-height: 0;
}

.lcx__breadcrumb {
  display: flex;
  align-items: center;
  gap: 16px;
  font-family: var(--font-mono);
  font-size: 22px;
  color: var(--teal-600);
  letter-spacing: 0.04em;
}
.lcx__crumb {
  background: var(--mint-100);
  border: 1px solid var(--teal-200);
  border-radius: 999px;
  padding: 6px 16px;
}
.lcx__crumb--current {
  background: var(--paper-0);
  border-color: var(--sprout-500);
  color: var(--forest-800);
  font-weight: 600;
}
.lcx__sep {
  color: var(--teal-200);
  font-size: 26px;
  line-height: 1;
}

.lcx__essence {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px 48px;
  min-height: 0;
}
.lcx__essence-text {
  font-family: var(--font-display);
  font-style: italic;
  font-size: 52px;
  line-height: 1.2;
  color: var(--forest-800);
  text-align: center;
  text-wrap: balance;
  letter-spacing: -0.01em;
}

.lcx__context {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.lcx__row {
  display: flex;
  align-items: center;
  gap: 18px;
  background: var(--paper-0);
  border: 1px solid var(--paper-200);
  border-left: 6px solid var(--sprout-500);
  border-radius: 14px;
  padding: 18px 24px;
}
.lcx__arrow {
  font-family: var(--font-body);
  font-size: 26px;
  font-weight: 700;
  color: var(--sprout-600);
  line-height: 1;
}
.lcx__row-text {
  font-family: var(--font-body);
  font-size: 24px;
  line-height: 1.4;
  color: var(--forest-800);
}
</style>
