<script setup>
defineProps({
  color: { type: String, default: 'var(--teal-500)' },
})
</script>

<template>
  <div class="eyebrow" :style="{ color }">
    <slot />
  </div>
</template>

<style scoped>
.eyebrow {
  font-family: var(--font-body);
  font-size: 26px;
  font-weight: 600;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  margin-bottom: 36px;
}
</style>
