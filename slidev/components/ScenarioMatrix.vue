<script setup>
// 0 = empty, 1 = secondary, 2 = primary
const matrix = [
  [2, 0, 0, 0, 2], // S1 Customer Support
  [0, 0, 2, 0, 0], // S2 Code Gen
  [2, 0, 0, 0, 1], // S3 Research System
  [0, 2, 0, 0, 0], // S4 Dev Productivity
  [0, 0, 2, 2, 0], // S5 CI/CD
  [0, 0, 0, 2, 0], // S6 Data Extraction
]
const scenarios = [
  'Customer Support',
  'Code Generation',
  'Research System',
  'Dev Productivity',
  'Claude Code CI/CD',
  'Data Extraction',
]
const domains = ['D1', 'D2', 'D3', 'D4', 'D5']

const fill = (v) => v === 2
  ? 'var(--sprout-500)'
  : v === 1
    ? 'var(--sprout-100)'
    : 'var(--paper-100)'
const border = (v) => v === 2
  ? 'var(--sprout-500)'
  : v === 1
    ? 'var(--sprout-200)'
    : 'var(--paper-200)'
</script>

<template>
  <Frame>
    <Eyebrow>The six scenarios &middot; 04</Eyebrow>
    <h1 class="slide-title">Which scenario tests which domain.</h1>

    <div class="sm-grid">
      <div class="sm-scenarios">
        <div
          v-for="(s, i) in scenarios"
          :key="i"
          class="sm-srow"
        >
          <span class="sm-stag">S{{ i + 1 }}</span>
          {{ s }}
        </div>
      </div>

      <div>
        <div class="sm-domrow">
          <div
            v-for="(d, i) in domains"
            :key="i"
            class="sm-dcell"
          >
            {{ d }}
          </div>
        </div>
        <div
          v-for="(row, ri) in matrix"
          :key="ri"
          class="sm-mrow"
        >
          <div
            v-for="(v, ci) in row"
            :key="ci"
            class="sm-mcell"
          >
            <div
              class="sm-dot"
              :style="{ background: fill(v), borderColor: border(v) }"
            />
          </div>
        </div>
      </div>
    </div>

    <div class="sm-legend">
      <div class="sm-leg">
        <div
          class="sm-swatch"
          style="background: var(--sprout-500); border-color: var(--sprout-500);"
        />
        <span>Primary coverage</span>
      </div>
      <div class="sm-leg">
        <div
          class="sm-swatch"
          style="background: var(--sprout-100); border-color: var(--sprout-200);"
        />
        <span>Secondary coverage</span>
      </div>
      <div class="sm-leg">
        <div
          class="sm-swatch"
          style="background: var(--paper-100); border-color: var(--paper-200);"
        />
        <span>Not tested</span>
      </div>
    </div>
  </Frame>
</template>

<style scoped>
.slide-title {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-weight: 500;
  font-size: 76px;
  line-height: 1.08;
  letter-spacing: -0.02em;
  margin: 0;
  color: var(--forest-800);
}
.sm-grid {
  margin-top: 48px;
  display: grid;
  grid-template-columns: 420px 1fr;
  gap: 48px;
}
.sm-scenarios {
  padding-top: 80px;
}
.sm-srow {
  height: 80px;
  display: flex;
  align-items: center;
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 28px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.01em;
  border-bottom: 1px solid var(--paper-200);
}
.sm-stag {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 20px;
  color: var(--forest-500);
  margin-right: 16px;
  font-weight: 500;
}
.sm-domrow {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 0;
}
.sm-dcell {
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 28px;
  font-weight: 500;
  color: var(--teal-500);
  letter-spacing: 0.04em;
}
.sm-mrow {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 0;
  height: 80px;
  border-bottom: 1px solid var(--paper-200);
}
.sm-mcell {
  display: flex;
  align-items: center;
  justify-content: center;
}
.sm-dot {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  border: 2px solid transparent;
}
.sm-legend {
  margin-top: 40px;
  display: flex;
  gap: 40px;
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 22px;
  color: var(--forest-500);
}
.sm-leg {
  display: flex;
  align-items: center;
  gap: 12px;
}
.sm-swatch {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: 2px solid transparent;
}
</style>
