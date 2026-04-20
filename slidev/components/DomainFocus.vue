<script setup>
const props = defineProps({
  number: { type: String, required: true },
  name: { type: String, required: true },
  pct: { type: String, required: true },
  color: { type: String, required: true },
  topics: { type: Array, required: true },
  keyPoint: { type: String, default: '' },
  scenarios: { type: String, default: '' },
})

// Choose font sizes based on pct string length (matches slides.jsx)
const bigSize = props.pct.length > 2 ? '160px' : '240px'
const signSize = props.pct.length > 2 ? '72px' : '100px'
</script>

<template>
  <Frame>
    <Eyebrow>The five domains &middot; 03</Eyebrow>
    <div class="df-grid">
      <div class="df-left">
        <div class="df-dnum">
          Domain {{ number }}
        </div>
        <div
          class="df-big"
          :style="{ fontSize: bigSize, color: color }"
        >
          {{ pct }}<span
            class="df-big-sign"
            :style="{ fontSize: signSize }"
          >%</span>
        </div>
        <div class="df-name">
          {{ name }}
        </div>
      </div>

      <div class="df-right">
        <div class="df-heading">
          What's tested
        </div>
        <ul class="df-topics">
          <v-clicks>
            <li
              v-for="(t, i) in topics"
              :key="i"
              class="df-topic"
              :class="{ 'df-topic--last': i === topics.length - 1 }"
            >
              <span
                class="df-dash"
                :style="{ color: color }"
              >&mdash;</span>
              <span v-html="t" />
            </li>
          </v-clicks>
        </ul>

        <div
          v-if="keyPoint"
          class="df-keypoint"
        >
          <div class="df-keypoint-label">
            The concept that anchors this domain
          </div>
          <div
            class="df-keypoint-text"
            v-html="keyPoint"
          />
        </div>

        <div
          v-if="scenarios"
          class="df-scenarios"
        >
          <strong>Scenarios that test it:</strong> {{ scenarios }}
        </div>
      </div>
    </div>
  </Frame>
</template>

<style scoped>
.df-grid {
  display: grid;
  grid-template-columns: 520px 1fr;
  gap: 80px;
  flex: 1;
  align-items: start;
}
.df-dnum {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 34px;
  font-weight: 500;
  color: var(--forest-500);
  margin-bottom: 12px;
  letter-spacing: 0.02em;
}
.df-big {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-weight: 500;
  line-height: 0.9;
  letter-spacing: -0.04em;
  white-space: nowrap;
}
.df-big-sign {
  color: var(--forest-500);
}
.df-name {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 48px;
  font-weight: 500;
  color: var(--forest-800);
  margin-top: 24px;
  line-height: 1.1;
  letter-spacing: -0.015em;
  max-width: 480px;
}
.df-right {
  padding-top: 24px;
}
.df-heading {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 22px;
  font-weight: 600;
  color: var(--teal-500);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: 20px;
}
.df-topics {
  list-style: none;
  padding: 0;
  margin: 0;
}
.df-topic {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 26px;
  color: var(--forest-800);
  line-height: 1.45;
  padding: 14px 0;
  border-bottom: 1px solid var(--paper-200);
  display: flex;
  gap: 16px;
}
.df-topic--last {
  border-bottom: none;
}
.df-dash {
  font-weight: 700;
}
.df-keypoint {
  margin-top: 40px;
  padding: 28px 32px;
  background: var(--mint-100);
  border-radius: 14px;
}
.df-keypoint-label {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 18px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--teal-500);
  margin-bottom: 10px;
}
.df-keypoint-text {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 28px;
  color: var(--forest-800);
  line-height: 1.4;
  font-style: italic;
}
.df-keypoint-text :deep(code) {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-style: normal;
  background: var(--paper-100);
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.92em;
}
.df-scenarios {
  margin-top: 28px;
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 22px;
  color: var(--forest-500);
  letter-spacing: 0.04em;
}
.df-scenarios strong {
  color: var(--forest-800);
  font-weight: 600;
}
</style>
