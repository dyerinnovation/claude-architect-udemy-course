<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'tip',
    validator: (v) => ['do', 'dont', 'warn', 'tip'].includes(v),
  },
  title: { type: String, default: '' },
})

const VARIANTS = {
  do: {
    accent: 'var(--sprout-600)',
    bg: 'var(--sprout-50)',
    border: 'var(--sprout-300)',
    label: 'Do',
    glyph: '+',
  },
  dont: {
    accent: 'var(--clay-500)',
    bg: 'var(--clay-50)',
    border: 'var(--clay-200)',
    label: "Don't",
    glyph: '\u00D7',
  },
  warn: {
    accent: 'var(--warn)',
    bg: 'var(--warn-bg)',
    border: '#f0d39a',
    label: 'Warning',
    glyph: '!',
  },
  tip: {
    accent: 'var(--teal-600)',
    bg: 'var(--teal-50)',
    border: 'var(--teal-200)',
    label: 'Tip',
    glyph: '\u2190',
  },
}

const v = computed(() => VARIANTS[props.variant] || VARIANTS.tip)
</script>

<template>
  <div
    class="cb"
    :style="{
      background: v.bg,
      borderColor: v.border,
    }"
  >
    <div class="cb__rail" :style="{ background: v.accent }" />
    <div class="cb__body">
      <div class="cb__head">
        <span class="cb__glyph" :style="{ background: v.accent }">{{ v.glyph }}</span>
        <span class="cb__label" :style="{ color: v.accent }">{{ v.label }}</span>
        <span v-if="title" class="cb__title">{{ title }}</span>
      </div>
      <div class="cb__slot">
        <slot />
      </div>
    </div>
  </div>
</template>

<style scoped>
.cb {
  position: relative;
  display: flex;
  border: 1px solid transparent;
  border-radius: 16px;
  overflow: hidden;
  font-family: var(--font-body);
  box-shadow: var(--shadow-sm);
}
.cb__rail {
  width: 8px;
  flex-shrink: 0;
}
.cb__body {
  flex: 1;
  padding: 22px 28px 24px;
}
.cb__head {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 12px;
}
.cb__glyph {
  width: 32px;
  height: 32px;
  border-radius: 999px;
  color: var(--paper-0);
  font-family: var(--font-body);
  font-weight: 700;
  font-size: 20px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}
.cb__label {
  font-family: var(--font-body);
  font-size: 18px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}
.cb__title {
  font-family: var(--font-display);
  font-size: 30px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.01em;
  line-height: 1.15;
  margin-left: 4px;
}
.cb__slot {
  font-family: var(--font-body);
  font-size: 22px;
  line-height: 1.5;
  color: var(--forest-800);
}
.cb__slot :deep(p) {
  margin: 0 0 10px;
  max-width: none;
}
.cb__slot :deep(p:last-child) {
  margin-bottom: 0;
}
.cb__slot :deep(code) {
  font-family: var(--font-mono);
  font-size: 0.9em;
  background: var(--paper-0);
  border: 1px solid var(--paper-200);
  padding: 1px 6px;
  border-radius: 4px;
  color: var(--forest-700);
}
</style>
