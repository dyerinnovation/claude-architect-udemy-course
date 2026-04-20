<script setup>
const props = defineProps({
  size: { type: Number, default: 64 },
  light: { type: Boolean, default: false },
})
</script>

<template>
  <img
    src="/assets/logo-mark.png"
    alt=""
    class="logo-mark"
    :style="{ width: `${props.size}px`, opacity: props.light ? 0.95 : 0.9 }"
  />
</template>

<style scoped>
.logo-mark {
  height: auto;
  position: absolute;
  bottom: 56px;
  right: 64px;
}
</style>
