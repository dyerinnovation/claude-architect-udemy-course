<script setup>
const phases = [
  {
    tag: 'Phase 01 · Foundations',
    color: 'var(--teal-500)',
    bg: 'var(--mint-100)',
    sections: [
      { n: '01', name: 'Course & exam strategy', detail: 'Where you are right now.' },
      { n: '02', name: 'Claude API Bootcamp',    detail: 'Hands-on — the API that underpins everything.' },
    ],
  },
  {
    tag: 'Phase 02 · The five domains',
    color: 'var(--sprout-600)',
    bg: '#eaf4dd', /* source: #eaf4dd */
    sections: [
      { n: '03', name: 'Agentic Architecture & Orchestration',   detail: 'Domain 1 · 27%' },
      { n: '04', name: 'Claude Code Configuration & Workflows',  detail: 'Domain 3 · 20%' },
      { n: '05', name: 'Prompt Engineering & Structured Output', detail: 'Domain 4 · 20%' },
      { n: '06', name: 'Tool Design & MCP',                      detail: 'Domain 2 · 18%' },
      { n: '07', name: 'Context Management & Reliability',       detail: 'Domain 5 · 15%' },
    ],
  },
  {
    tag: 'Phase 03 · Exam readiness',
    color: 'var(--warn)',
    bg: 'var(--warn-bg)',
    sections: [
      { n: '08', name: 'Multi-Tool Agent + Escalation', detail: 'Demo · D1 · D2 · D5' },
      { n: '09', name: 'Claude Code for Team Workflow', detail: 'Demo · D3 · D2' },
      { n: '10', name: 'Structured Data Extraction',    detail: 'Demo · D4 · D5' },
      { n: '11', name: 'Multi-Agent Research Pipeline', detail: 'Demo · D1 · D2 · D5' },
    ],
  },
]

const gridCols = (count) => count <= 2 ? '1fr 1fr' : `repeat(${count}, 1fr)`

const tagHead = (tag) => tag.split(' · ')[0]
const tagTail = (tag) => tag.split(' · ')[1]
</script>

<template>
  <Frame>
    <Eyebrow>Course roadmap &middot; 06</Eyebrow>
    <h1 class="slide-title">Eleven sections. Three phases. One exam.</h1>

    <div class="cr-stack">
      <v-clicks>
        <div
          v-for="phase in phases"
          :key="phase.tag"
          class="cr-phase"
          :style="{
            background: phase.bg,
            borderLeftColor: phase.color,
          }"
        >
          <div class="cr-phase-head">
            <div
              class="cr-phase-tag"
              :style="{ color: phase.color }"
            >
              {{ tagHead(phase.tag) }}
            </div>
            <div class="cr-phase-name">
              {{ tagTail(phase.tag) }}
            </div>
          </div>
          <div
            class="cr-phase-sections"
            :style="{ gridTemplateColumns: gridCols(phase.sections.length) }"
          >
            <div
              v-for="s in phase.sections"
              :key="s.n"
              class="cr-card"
            >
              <div
                class="cr-card-num"
                :style="{ color: phase.color }"
              >
                &sect; {{ s.n }}
              </div>
              <div class="cr-card-name">
                {{ s.name }}
              </div>
              <div class="cr-card-detail">
                {{ s.detail }}
              </div>
            </div>
          </div>
        </div>
      </v-clicks>
    </div>

    <div class="cr-footnote">
      Sections 3 &ndash; 7 are ordered by exam weight, not exam-guide order.
      Phase 03 is the four preparation-exercise demos from the official exam guide &mdash; the "demos" referenced in every study path.
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
.cr-stack {
  display: flex;
  flex-direction: column;
  gap: 14px;
  flex: 1;
  margin-top: 40px;
}
.cr-phase {
  border-radius: 16px;
  padding: 18px 26px;
  border-left: 6px solid transparent;
  display: grid;
  grid-template-columns: 260px 1fr;
  align-items: start;
  gap: 28px;
}
.cr-phase-tag {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 20px;
  font-weight: 600;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  margin-bottom: 4px;
}
.cr-phase-name {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 24px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.01em;
  line-height: 1.15;
}
.cr-phase-sections {
  display: grid;
  gap: 10px;
}
.cr-card {
  background: #fff;
  border: 1px solid var(--paper-200);
  border-radius: 10px;
  padding: 10px 12px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}
.cr-card-num {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 20px;
  font-weight: 600;
  letter-spacing: 0.06em;
}
.cr-card-name {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 24px;
  font-weight: 500;
  color: var(--forest-800);
  line-height: 1.15;
  letter-spacing: -0.01em;
}
.cr-card-detail {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 20px;
  color: var(--forest-500);
  line-height: 1.3;
}
.cr-footnote {
  margin-top: 14px;
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-style: italic;
  font-size: 24px;
  color: var(--forest-500);
  line-height: 1.4;
  max-width: 1600px;
}
</style>
