<script setup>
import { computed } from 'vue'
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'

const props = defineProps({
  eyebrow: { type: String, default: '' },
  title: { type: String, required: true },
  bullets: {
    type: Array,
    required: true,
    validator: (arr) => Array.isArray(arr) && arr.length <= 6,
  },
  footerLabel: { type: String, default: '' },
  footerNum: { type: [Number, String], default: 1 },
  footerTotal: { type: [Number, String], default: 1 },
})

const rows = computed(() => props.bullets.slice(0, 6))
</script>

<template>
  <Frame>
    <Eyebrow v-if="eyebrow">
      {{ eyebrow }}
    </Eyebrow>
    <SlideTitle>{{ title }}</SlideTitle>

    <ul class="br__list">
      <v-clicks>
        <li
          v-for="(b, i) in rows"
          :key="i"
          class="br__row"
        >
          <div class="br__num">{{ String(i + 1).padStart(2, '0') }}</div>
          <div class="br__text">
            <div class="br__label">{{ b.label }}</div>
            <div v-if="b.detail" class="br__detail">{{ b.detail }}</div>
          </div>
        </li>
      </v-clicks>
    </ul>

    <SlideFooter :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.br__list {
  list-style: none;
  margin: 56px 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 14px;
  flex: 1;
  min-height: 0;
}
.br__row {
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
.br__num {
  font-family: var(--font-mono);
  font-size: 24px;
  font-weight: 600;
  color: var(--sprout-600);
  letter-spacing: 0.05em;
  padding-top: 4px;
}
.br__label {
  font-family: var(--font-display);
  font-size: 34px;
  font-weight: 500;
  color: var(--forest-800);
  line-height: 1.18;
  letter-spacing: -0.01em;
}
.br__detail {
  font-family: var(--font-body);
  font-size: 24px;
  line-height: 1.45;
  color: var(--forest-500);
  margin-top: 8px;
}
</style>
