<script setup>
import { computed } from 'vue'
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'

const props = defineProps({
  eyebrow: { type: String, default: '' },
  title: { type: String, required: true },
  steps: {
    type: Array,
    required: true,
    validator: (arr) => Array.isArray(arr) && arr.length <= 5,
  },
  footerLabel: { type: String, default: '' },
  footerNum: { type: [Number, String], default: 1 },
  footerTotal: { type: [Number, String], default: 1 },
})

const list = computed(() => props.steps.slice(0, 5))

function numberFor(step, i) {
  return step.number ?? String(i + 1).padStart(2, '0')
}
</script>

<template>
  <Frame>
    <Eyebrow v-if="eyebrow">
      {{ eyebrow }}
    </Eyebrow>
    <SlideTitle>{{ title }}</SlideTitle>

    <div class="ss">
      <v-clicks>
        <div
          v-for="(step, i) in list"
          :key="i"
          class="ss__row"
        >
          <div class="ss__numwrap">
            <div class="ss__num">{{ numberFor(step, i) }}</div>
            <div v-if="i < list.length - 1" class="ss__connector" />
          </div>
          <div class="ss__card">
            <div class="ss__title">{{ step.title }}</div>
            <div class="ss__body">{{ step.body }}</div>
          </div>
        </div>
      </v-clicks>
    </div>

    <SlideFooter :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.ss {
  margin-top: 56px;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 18px;
  min-height: 0;
}
.ss__row {
  display: grid;
  grid-template-columns: 96px 1fr;
  align-items: stretch;
  gap: 24px;
}
.ss__numwrap {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.ss__num {
  width: 80px;
  height: 80px;
  border-radius: 999px;
  background: var(--sprout-500);
  color: var(--paper-0);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--font-mono);
  font-size: 28px;
  font-weight: 600;
  letter-spacing: 0.02em;
  box-shadow: var(--shadow-sm);
  flex-shrink: 0;
}
.ss__connector {
  flex: 1;
  width: 3px;
  background: var(--sprout-200);
  margin-top: 6px;
  border-radius: 999px;
}
.ss__card {
  background: var(--paper-0);
  border: 1px solid var(--paper-200);
  border-radius: 14px;
  padding: 22px 28px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.ss__title {
  font-family: var(--font-display);
  font-size: 34px;
  font-weight: 500;
  color: var(--forest-800);
  line-height: 1.15;
  letter-spacing: -0.01em;
}
.ss__body {
  font-family: var(--font-body);
  font-size: 22px;
  line-height: 1.45;
  color: var(--forest-500);
}
</style>
