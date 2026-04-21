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
    validator: (arr) => Array.isArray(arr) && arr.length >= 3 && arr.length <= 6,
  },
  footerLabel: { type: String, default: '' },
  footerNum: { type: [Number, String], default: 1 },
  footerTotal: { type: [Number, String], default: 1 },
})

const nodes = computed(() => props.steps.slice(0, 6))
</script>

<template>
  <Frame>
    <Eyebrow v-if="eyebrow">
      {{ eyebrow }}
    </Eyebrow>
    <SlideTitle>{{ title }}</SlideTitle>

    <div class="fd">
      <template v-for="(step, i) in nodes" :key="i">
        <div v-click="i + 1" class="fd__node">
          <div class="fd__num">{{ String(i + 1).padStart(2, '0') }}</div>
          <div class="fd__label">{{ step.label }}</div>
          <div v-if="step.sublabel" class="fd__sub">{{ step.sublabel }}</div>
        </div>
        <div
          v-if="i < nodes.length - 1"
          v-click="i + 1"
          class="fd__arrow"
          aria-hidden="true"
        >
          <svg viewBox="0 0 64 24" preserveAspectRatio="none">
            <line x1="0" y1="12" x2="54" y2="12" stroke="var(--sprout-500)" stroke-width="3" stroke-linecap="round" />
            <polygon points="54,4 64,12 54,20" fill="var(--sprout-500)" />
          </svg>
        </div>
      </template>
    </div>

    <SlideFooter :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.fd {
  margin-top: 64px;
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  min-height: 0;
}
.fd__node {
  flex: 1 1 0;
  min-width: 0;
  background: var(--mint-100);
  border: 2px solid var(--mint-300);
  border-radius: 18px;
  padding: 28px 24px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  color: var(--forest-800);
  min-height: 200px;
  justify-content: center;
}
.fd__num {
  font-family: var(--font-mono);
  font-size: 20px;
  font-weight: 600;
  color: var(--teal-600);
  letter-spacing: 0.08em;
}
.fd__label {
  font-family: var(--font-display);
  font-size: 32px;
  font-weight: 500;
  line-height: 1.15;
  color: var(--forest-800);
  letter-spacing: -0.01em;
}
.fd__sub {
  font-family: var(--font-body);
  font-size: 20px;
  line-height: 1.4;
  color: var(--forest-500);
}
.fd__arrow {
  flex: 0 0 64px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.fd__arrow svg {
  width: 64px;
  height: 24px;
  display: block;
}
</style>
