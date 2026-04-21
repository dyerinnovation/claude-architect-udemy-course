<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'

defineProps({
  eyebrow: { type: String, default: '' },
  title: { type: String, required: true },
  columns: { type: Array, required: true },
  rows: { type: Array, required: true },
  footerLabel: { type: String, default: '' },
  footerNum: { type: [Number, String], default: 1 },
  footerTotal: { type: [Number, String], default: 1 },
})

function cellText(cell) {
  return typeof cell === 'string' ? cell : cell?.text ?? ''
}
function cellHighlight(cell) {
  if (typeof cell === 'string') return 'neutral'
  return cell?.highlight ?? 'neutral'
}
</script>

<template>
  <Frame>
    <Eyebrow v-if="eyebrow">
      {{ eyebrow }}
    </Eyebrow>
    <SlideTitle>{{ title }}</SlideTitle>

    <div class="ct">
      <div
        class="ct__grid"
        :style="{ gridTemplateColumns: `minmax(260px, 1fr) repeat(${columns.length}, minmax(0, 1fr))` }"
      >
        <div class="ct__head ct__head--row">&nbsp;</div>
        <div
          v-for="(c, i) in columns"
          :key="`h-${i}`"
          class="ct__head"
        >
          {{ c }}
        </div>

        <template v-for="(row, ri) in rows" :key="`r-${ri}`">
          <div v-click="ri + 1" class="ct__row-label">
            {{ row.label }}
          </div>
          <div
            v-for="(cell, ci) in row.cells"
            :key="`c-${ri}-${ci}`"
            v-click="ri + 1"
            class="ct__cell"
            :class="`ct__cell--${cellHighlight(cell)}`"
          >
            <span class="ct__dot" :class="`ct__dot--${cellHighlight(cell)}`" />
            <span class="ct__cell-text">{{ cellText(cell) }}</span>
          </div>
        </template>
      </div>
    </div>

    <SlideFooter :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.ct {
  margin-top: 56px;
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
}
.ct__grid {
  display: grid;
  gap: 2px;
  background: var(--paper-200);
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid var(--paper-200);
}
.ct__head {
  background: var(--forest-800);
  color: var(--mint-100);
  font-family: var(--font-body);
  font-size: 24px;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  padding: 18px 22px;
  display: flex;
  align-items: center;
}
.ct__head--row {
  background: var(--forest-900);
}
.ct__row-label {
  background: var(--paper-0);
  padding: 18px 22px;
  font-family: var(--font-display);
  font-size: 26px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.01em;
  display: flex;
  align-items: center;
  line-height: 1.2;
}
.ct__cell {
  background: var(--paper-0);
  padding: 18px 22px;
  font-family: var(--font-body);
  font-size: 24px;
  line-height: 1.4;
  color: var(--forest-800);
  display: flex;
  align-items: flex-start;
  gap: 12px;
}
.ct__cell--good {
  background: var(--sprout-50);
  color: var(--sprout-800);
}
.ct__cell--bad {
  background: var(--clay-50);
  color: var(--clay-700);
}
.ct__cell--neutral {
  background: var(--paper-0);
  color: var(--forest-800);
}
.ct__dot {
  width: 10px;
  height: 10px;
  border-radius: 999px;
  margin-top: 11px;
  flex-shrink: 0;
}
.ct__dot--good {
  background: var(--sprout-500);
}
.ct__dot--bad {
  background: var(--clay-500);
}
.ct__dot--neutral {
  background: var(--paper-400);
}
.ct__cell-text {
  flex: 1;
  min-width: 0;
}
</style>
