<script setup>
import { computed } from 'vue'

const props = defineProps({
  eyebrow: { type: String, default: '' },
  number: { type: String, required: true },
  unit: { type: String, default: '' },
  caption: { type: String, default: '' },
  detail: { type: String, default: '' },
  bg: { type: String, default: 'var(--paper-50)' },
  accent: { type: String, default: 'var(--sprout-500)' },
})

const dark = computed(() => props.bg === 'var(--forest-900)' || props.bg === '#152925')
</script>

<template>
  <div
    class="big-number-frame"
    :style="{
      background: bg,
      color: dark ? 'var(--mint-100)' : 'var(--forest-800)',
    }"
  >
    <div
      v-if="eyebrow"
      class="eyebrow"
      :style="{ color: dark ? 'var(--sprout-500)' : 'var(--teal-500)' }"
    >
      {{ eyebrow }}
    </div>
    <div class="hero-row">
      <div
        class="hero-number"
        :style="{ color: accent }"
      >
        {{ number }}<span
          v-if="unit"
          class="hero-unit"
          :style="{ color: dark ? 'var(--mint-200)' : 'var(--forest-500)' }"
        >{{ unit }}</span>
      </div>
      <div class="caption-col">
        <div
          class="caption"
          :style="{ color: dark ? 'var(--paper-0)' : 'var(--forest-800)' }"
        >
          {{ caption }}
        </div>
        <div
          v-if="detail"
          class="detail"
          :style="{ color: dark ? 'var(--mint-200)' : 'var(--forest-500)' }"
        >
          {{ detail }}
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.big-number-frame {
  width: 1920px;
  height: 1080px;
  padding: 110px 120px 96px;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
}
.eyebrow {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 22px;
  font-weight: 600;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  margin-bottom: 48px;
}
.hero-row {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 80px;
}
.hero-number {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-weight: 500;
  font-size: 260px;
  line-height: 0.88;
  letter-spacing: -0.04em;
}
.hero-unit {
  font-size: 120px;
  font-weight: 400;
}
.caption-col {
  flex: 1;
  max-width: 700px;
}
.caption {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-weight: 500;
  font-size: 52px;
  line-height: 1.12;
  letter-spacing: -0.015em;
}
.detail {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 26px;
  line-height: 1.5;
  margin-top: 28px;
}
</style>
