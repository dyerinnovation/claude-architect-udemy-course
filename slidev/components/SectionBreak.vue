<script setup>
import { computed } from 'vue'

const props = defineProps({
  part: { type: String, required: true },
  title: { type: String, default: '' },
  blurb: { type: String, default: '' },
  bg: { type: String, default: 'var(--mint-100)' },
})

// In the source JSX, a bg of forest-900 triggers dark variant.
const dark = computed(() => props.bg === 'var(--forest-900)' || props.bg === '#152925')
</script>

<template>
  <div class="section-break" :style="{ background: bg, color: dark ? 'var(--mint-100)' : 'var(--forest-800)' }">
    <div class="section-break__inner">
      <div class="section-break__eyebrow" :style="{ color: dark ? 'var(--sprout-500)' : 'var(--teal-500)' }">
        Part {{ part }}
      </div>
      <h1 class="section-break__title" :style="{ color: dark ? 'var(--paper-0)' : 'var(--forest-900)' }">
        <slot>{{ title }}</slot>
      </h1>
      <div
        v-if="blurb"
        class="section-break__blurb"
        :style="{ color: dark ? 'var(--mint-200)' : 'var(--forest-500)' }"
      >
        {{ blurb }}
      </div>
      <img
        src="/assets/logo-mark.png"
        alt=""
        class="section-break__logo"
        :style="{ opacity: dark ? 0.95 : 1 }"
      />
    </div>
  </div>
</template>

<style scoped>
.section-break {
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  font-family: var(--font-body);
  display: flex;
  position: relative;
}
.section-break__inner {
  padding: 110px 120px 96px;
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: relative;
}
.section-break__eyebrow {
  font-family: var(--font-mono);
  font-size: 30px;
  font-weight: 500;
  letter-spacing: 0.12em;
  margin-bottom: 40px;
  text-transform: uppercase;
}
.section-break__title {
  font-family: var(--font-display);
  font-weight: 500;
  font-size: 160px;
  line-height: 0.98;
  letter-spacing: -0.025em;
  margin: 0;
  max-width: 1500px;
}
.section-break__blurb {
  font-family: var(--font-display);
  font-style: italic;
  font-size: 40px;
  line-height: 1.4;
  margin-top: 48px;
  max-width: 1100px;
  font-weight: 400;
}
.section-break__logo {
  position: absolute;
  bottom: 80px;
  right: 96px;
  width: 88px;
  height: auto;
}
</style>
