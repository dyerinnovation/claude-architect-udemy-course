<script setup>
import { computed } from 'vue'

const props = defineProps({
  label: { type: String, default: '' },
  num: { type: [Number, String], default: 1 },
  total: { type: [Number, String], default: 1 },
  dark: { type: Boolean, default: false },
})

const color = computed(() => (props.dark ? 'rgba(229,245,231,0.55)' : 'var(--paper-500)'))
</script>

<template>
  <div class="slide-footer" :style="{ color }">
    <span>Dyer Innovation &middot; CCA-F</span>
    <span>{{ label }}</span>
    <span class="slide-footer__num">{{ num }} / {{ total }}</span>
  </div>
</template>

<style scoped>
.slide-footer {
  position: absolute;
  left: 120px;
  right: 120px;
  bottom: 48px;
  display: flex;
  justify-content: space-between;
  font-family: var(--font-body);
  font-size: 20px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  font-weight: 500;
}
.slide-footer__num {
  font-variant-numeric: tabular-nums;
}
</style>
