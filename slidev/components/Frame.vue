<script setup>
defineProps({
  bg: { type: String, default: 'var(--paper-50)' },
  color: { type: String, default: 'var(--forest-800)' },
  pad: { type: Boolean, default: true },
})
</script>

<template>
  <div
    class="frame"
    :class="{ 'frame--pad': pad }"
    :style="{ background: bg, color }"
  >
    <slot />
  </div>
</template>

<style scoped>
.frame {
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  font-family: var(--font-body);
  display: flex;
  flex-direction: column;
  position: relative;
}
.frame--pad {
  padding: 110px 120px 96px;
}
</style>
