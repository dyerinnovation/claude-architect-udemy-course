<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'picked',
    validator: (v) => ['neutral', 'picked'].includes(v),
  },
})

const scenarios = [
  { n: 1, name: 'Customer Support Resolution Agent', domains: '1 · 5' },
  { n: 2, name: 'Code Generation with Claude Code', domains: '3' },
  { n: 3, name: 'Multi-Agent Research System', domains: '1 · 5' },
  { n: 4, name: 'Developer Productivity with Claude', domains: '2' },
  { n: 5, name: 'Claude Code for CI/CD', domains: '3 · 4' },
  { n: 6, name: 'Structured Data Extraction', domains: '4' },
]
const picks = [true, false, true, true, false, true]

const showPicks = computed(() => props.variant === 'picked')
const neutral = computed(() => !showPicks.value)

function cardStyle(i) {
  const on = showPicks.value ? picks[i] : true
  if (neutral.value) {
    return {
      background: 'var(--paper-0, #ffffff)',
      border: '2px solid var(--paper-200, #e8ede9)',
      opacity: 1,
    }
  }
  return {
    background: on ? 'var(--sprout-50, #f2fbec)' : 'var(--paper-100, #f4f7f4)',
    border: `2px solid ${on ? 'var(--sprout-500, #5bb42e)' : 'var(--paper-200, #e8ede9)'}`,
    opacity: on ? 1 : 0.45,
  }
}
function scenarioLabelColor(i) {
  const on = showPicks.value ? picks[i] : true
  if (neutral.value) return 'var(--teal-500, #1f8e88)'
  return on ? 'var(--sprout-600, #449122)' : 'var(--paper-500, #7a8a7d)'
}
function nameColor(i) {
  const on = showPicks.value ? picks[i] : true
  if (neutral.value) return 'var(--forest-800, #1f3a36)'
  return on ? 'var(--forest-800, #1f3a36)' : 'var(--forest-500, #427065)'
}
function domainColor(i) {
  const on = showPicks.value ? picks[i] : true
  if (neutral.value) return 'var(--forest-500, #427065)'
  return on ? 'var(--teal-600, #14706d)' : 'var(--paper-500, #7a8a7d)'
}
function badgeVisible(i) {
  return showPicks.value && picks[i]
}
</script>

<template>
  <div class="spf-frame">
    <div class="eyebrow">
      Exam format &middot; 02
    </div>
    <h1 class="slide-title">
      <template v-if="showPicks">
        Four of these six will appear on your exam.
      </template>
      <template v-else>
        Six scenarios. Every exam draws from these.
      </template>
    </h1>

    <div class="subhead">
      <template v-if="showPicks">
        You don't choose which four — Anthropic does. So you prepare for all six.
      </template>
      <template v-else>
        Know every one. You won't know which four are on your test until you open it.
      </template>
    </div>

    <div class="grid">
      <div
        v-for="(s, i) in scenarios"
        :key="s.n"
        class="card"
        :style="cardStyle(i)"
      >
        <div
          class="card-scenario"
          :style="{ color: scenarioLabelColor(i) }"
        >
          Scenario 0{{ s.n }}
        </div>
        <div
          class="card-name"
          :style="{ color: nameColor(i) }"
        >
          {{ s.name }}
        </div>
        <div
          class="card-domain"
          :style="{ color: domainColor(i) }"
        >
          Domain {{ s.domains }}
        </div>
        <div
          v-if="badgeVisible(i)"
          class="on-exam-badge"
        >
          On exam
        </div>
      </div>
    </div>

    <div class="footnote">
      <template v-if="showPicks">
        (Illustrative only — the actual four are chosen by Anthropic, per candidate.)
      </template>
      <template v-else>
        All six are in play. Next: a look at what a single exam draw might look like.
      </template>
    </div>
  </div>
</template>

<style scoped>
.spf-frame {
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
  max-width: 1600px;
  color: var(--forest-800, #1f3a36);
}
.subhead {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-style: italic;
  font-size: 30px;
  color: var(--forest-500, #427065);
  margin-top: 24px;
}
.grid {
  margin-top: 64px;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 28px;
}
.card {
  border-radius: 16px;
  padding: 32px 36px;
  min-height: 200px;
  display: flex;
  flex-direction: column;
  position: relative;
  transition: all 200ms ease;
}
.card-scenario {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 24px;
  font-weight: 500;
  margin-bottom: 14px;
}
.card-name {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 30px;
  line-height: 1.15;
  font-weight: 500;
  letter-spacing: -0.01em;
}
.card-domain {
  margin-top: auto;
  padding-top: 20px;
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 20px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  font-weight: 600;
}
.on-exam-badge {
  position: absolute;
  top: -14px;
  right: 20px;
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: var(--paper-0, #ffffff);
  background: var(--sprout-500, #5bb42e);
  padding: 6px 12px;
  border-radius: 999px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  box-shadow: 0 4px 10px rgba(91, 180, 46, 0.3);
}
.footnote {
  margin-top: 36px;
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 22px;
  color: var(--forest-500, #427065);
  text-align: center;
  font-style: italic;
}
</style>
