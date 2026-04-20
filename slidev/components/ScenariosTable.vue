<script setup>
const rows = [
  { n: 1, name: 'Customer Support Resolution Agent', domains: 'Domain 1 · Domain 5', strip: 'var(--sprout-500, #5bb42e)' },
  { n: 2, name: 'Code Generation with Claude Code',  domains: 'Domain 3',            strip: 'var(--teal-500, #1f8e88)' },
  { n: 3, name: 'Multi-Agent Research System',       domains: 'Domain 1 · Domain 5', strip: 'var(--sprout-500, #5bb42e)' },
  { n: 4, name: 'Developer Productivity with Claude',domains: 'Domain 2',            strip: '#7aca4c' },
  { n: 5, name: 'Claude Code for CI/CD',             domains: 'Domain 3 · Domain 4', strip: 'var(--teal-500, #1f8e88)' },
  { n: 6, name: 'Structured Data Extraction',        domains: 'Domain 4',            strip: 'var(--teal-500, #1f8e88)' },
]
</script>

<template>
  <div class="st-frame">
    <div class="eyebrow">
      The six scenarios &middot; 04
    </div>
    <h1 class="slide-title">
      The six, at a glance.
    </h1>

    <div class="st-table">
      <div class="st-header">
        <div>#</div>
        <div>Scenario</div>
        <div>Primary domains</div>
      </div>
      <div
        v-for="r in rows"
        :key="r.n"
        class="st-row"
        :style="{ borderLeft: `6px solid ${r.strip}` }"
      >
        <div class="st-num">
          0{{ r.n }}
        </div>
        <div class="st-name">
          {{ r.name }}
        </div>
        <div class="st-domains">
          {{ r.domains }}
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.st-frame {
  width: 1920px;
  height: 1080px;
  padding: 110px 120px 96px;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  background: var(--paper-50, #fafcfa);
  color: var(--forest-800, #1f3a36);
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
}
.eyebrow {
  font-size: 22px;
  font-weight: 600;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--teal-500, #1f8e88);
  margin-bottom: 48px;
}
.slide-title {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-weight: 500;
  font-size: 76px;
  line-height: 1.08;
  letter-spacing: -0.02em;
  margin: 0;
  color: var(--forest-800, #1f3a36);
}
.st-table {
  margin-top: 64px;
  background: var(--paper-0, #ffffff);
  border: 1px solid var(--paper-200, #e8ede9);
  border-radius: 16px;
  overflow: hidden;
}
.st-header {
  display: grid;
  grid-template-columns: 100px 1fr 380px;
  background: var(--mint-100, #e5f5e7);
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 20px;
  font-weight: 700;
  color: var(--teal-600, #14706d);
  letter-spacing: 0.12em;
  text-transform: uppercase;
  padding: 20px 40px;
  box-sizing: border-box;
}
.st-row {
  display: grid;
  grid-template-columns: 100px 1fr 380px;
  align-items: center;
  padding: 26px 40px;
  border-top: 1px solid var(--paper-200, #e8ede9);
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  box-sizing: border-box;
}
.st-num {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 26px;
  color: var(--forest-500, #427065);
  font-weight: 500;
}
.st-name {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 30px;
  font-weight: 500;
  color: var(--forest-800, #1f3a36);
  letter-spacing: -0.01em;
}
.st-domains {
  font-size: 22px;
  color: var(--forest-500, #427065);
  font-weight: 500;
}
</style>
