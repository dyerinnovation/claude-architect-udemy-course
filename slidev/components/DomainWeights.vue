<script setup>
const domains = [
  { n: 1, name: 'Agentic Architecture & Orchestration',      pct: 27, color: 'var(--sprout-500)' },
  { n: 3, name: 'Claude Code Configuration',                 pct: 20, color: 'var(--teal-500)' },
  { n: 4, name: 'Prompt Engineering & Structured Output',    pct: 20, color: 'var(--teal-500)' },
  { n: 2, name: 'Tool Design & MCP',                         pct: 18, color: 'var(--sprout-400)' /* source: #7aca4c */ },
  { n: 5, name: 'Context Management & Reliability',          pct: 15, color: 'var(--mint-400)'   /* source: #94d39d */ },
]
const max = 30
</script>

<template>
  <Frame>
    <Eyebrow>The five domains &middot; 03</Eyebrow>
    <h1 class="slide-title">Five domains, weighted unevenly.</h1>

    <div class="dw-rows">
      <div
        v-for="d in domains"
        :key="d.n"
        class="dw-row"
      >
        <div class="dw-label">
          D{{ d.n }}
        </div>
        <div class="dw-barwrap">
          <div class="dw-name">
            {{ d.name }}
          </div>
          <div class="dw-track">
            <div
              class="dw-fill"
              :style="{ width: `${(d.pct / max) * 100}%`, background: d.color }"
            />
          </div>
        </div>
        <div
          class="dw-pct"
          :style="{ color: d.color }"
        >
          {{ d.pct }}<span class="dw-pct-sign">%</span>
        </div>
      </div>
    </div>

    <div class="dw-tagline">
      Domains are <strong>not</strong> equally weighted. Study time should follow that curve, not fight it.
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
.dw-rows {
  margin-top: 72px;
  display: flex;
  flex-direction: column;
  gap: 26px;
}
.dw-row {
  display: grid;
  grid-template-columns: 100px 1fr 160px;
  align-items: center;
  gap: 32px;
}
.dw-label {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 38px;
  font-weight: 500;
  color: var(--forest-500);
  letter-spacing: 0.02em;
}
.dw-name {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 30px;
  font-weight: 500;
  color: var(--forest-800);
  margin-bottom: 10px;
  letter-spacing: -0.01em;
}
.dw-track {
  position: relative;
  height: 20px;
  background: var(--paper-200);
  border-radius: 10px;
  overflow: hidden;
}
.dw-fill {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  border-radius: 10px;
  transition: width 300ms ease;
}
.dw-pct {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 60px;
  font-weight: 500;
  text-align: right;
  letter-spacing: -0.02em;
  line-height: 1;
}
.dw-pct-sign {
  font-size: 32px;
  color: var(--forest-500);
}
.dw-tagline {
  margin-top: 56px;
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-style: italic;
  font-size: 30px;
  color: var(--forest-500);
  max-width: 1400px;
  line-height: 1.4;
}
.dw-tagline strong {
  color: var(--forest-800);
  font-style: normal;
  font-weight: 600;
}
</style>
