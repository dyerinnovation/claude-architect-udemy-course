<script setup>
defineProps({
  color: { type: String, default: 'var(--forest-800)' },
  maxWidth: { type: [Number, String], default: 1500 },
})
</script>

<template>
  <h1 class="slide-title" :style="{ color, maxWidth: typeof maxWidth === 'number' ? `${maxWidth}px` : maxWidth }">
    <slot />
  </h1>
</template>

<style scoped>
.slide-title {
  font-family: var(--font-display);
  font-weight: 500;
  font-size: 76px;
  line-height: 1.08;
  letter-spacing: -0.02em;
  margin: 0;
  text-wrap: pretty;
}
</style>
