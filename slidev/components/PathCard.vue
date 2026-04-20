<script setup>
import { computed } from 'vue'

const props = defineProps({
  pathKey: {
    type: String,
    required: true,
    validator: (v) => ['a', 'b', 'c'].includes(v),
  },
})

const SETUP_STEPS = [
  { key: 'bootcamp', label: 'API Bootcamp',    a: 'full', b: 'skim', c: 'skip' },
  { key: 'lectures', label: 'Course lectures', a: 'full', b: 'full', c: 'skip' },
  { key: 'guides',   label: 'Study guides',    a: 'full', b: 'full', c: 'full' },
  { key: 'demos',    label: 'Demos',           a: 'full', b: 'full', c: 'full' },
]

const LOOP_STEPS = [
  { key: 'exam',   n: 5, label: 'Practice exam',        detail: 'Take it under time pressure.' },
  { key: 'review', n: 6, label: 'Review weak sections', detail: 'Analyse every distractor.' },
  { key: 'retake', n: 7, label: 'Retake until 900+',    detail: 'Loop back to Practice exam.' },
]

const PATHS = {
  a: {
    tag: 'Path A',
    label: 'New to the Claude API',
    note: 'Start at the beginning. Watch every lecture, work every demo.',
    color: 'var(--teal-500)',
  },
  b: {
    tag: 'Path B',
    label: 'Decent experience with Claude & Claude Code',
    note: 'Skim the Bootcamp as a refresher, then work the rest end-to-end.',
    color: 'var(--sprout-600)',
  },
  c: {
    tag: 'Path C',
    label: 'Experienced · shorter on time',
    note: 'Skip the lectures. Straight to study guides, demos and the practice loop.',
    color: 'var(--warn)',
  },
}

const path = computed(() => PATHS[props.pathKey])
const stepStatus = (step) => step[props.pathKey]
</script>

<template>
  <Frame>
    <Eyebrow>Study strategy &middot; 05</Eyebrow>

    <h1 class="slide-title">
      <span
        class="pc-eyebrow"
        :style="{ color: path.color }"
      >{{ path.tag }}</span>
      {{ path.label }}.
    </h1>

    <div
      class="pc-note"
      :style="{ color: path.color }"
    >
      {{ path.note }}
    </div>

    <!-- Setup pipeline — steps 1-4 -->
    <div class="pc-setup">
      <div
        v-for="(step, idx) in SETUP_STEPS"
        :key="step.key"
        class="pc-step"
        :class="{
          'pc-step--skipped': stepStatus(step) === 'skip',
        }"
        :style="{
          borderLeftColor: stepStatus(step) === 'skip'
            ? 'rgba(31,58,54,0.10)'
            : path.color,
        }"
      >
        <div
          class="pc-step-num"
          :style="{
            color: stepStatus(step) === 'skip'
              ? 'var(--forest-500)'
              : path.color
          }"
        >
          {{ String(idx + 1).padStart(2, '0') }}
        </div>
        <div class="pc-step-label">
          {{ step.label }}
        </div>
        <div
          v-if="stepStatus(step) === 'skim'"
          class="pc-pill"
          :style="{ color: path.color, borderColor: path.color }"
        >
          Skim as refresher
        </div>
        <div
          v-if="stepStatus(step) === 'skip'"
          class="pc-skip"
        >
          Skip
        </div>
      </div>
    </div>

    <!-- Loop row — steps 5-7 -->
    <div
      class="pc-loop"
      :style="{ borderColor: path.color }"
    >
      <div
        class="pc-loop-tag"
        :style="{ background: path.color }"
      >
        The practice loop
      </div>

      <div class="pc-loop-grid">
        <template
          v-for="(step, i) in LOOP_STEPS"
          :key="step.key"
        >
          <div class="pc-loop-step">
            <div
              class="pc-loop-num"
              :style="{ color: path.color }"
            >
              0{{ step.n }}
            </div>
            <div class="pc-loop-label">
              {{ step.label }}
            </div>
            <div class="pc-loop-detail">
              {{ step.detail }}
            </div>
          </div>
          <div
            v-if="i < LOOP_STEPS.length - 1"
            class="pc-arrow"
            :style="{ color: path.color }"
          >
            &rarr;
          </div>
        </template>
      </div>

      <div class="pc-loop-foot">
        &#8635; Loop 05 &rarr; 06 &rarr; 07 &rarr; 05 until you consistently score
        <strong :style="{ color: path.color }">900+</strong>.
      </div>
    </div>

    <!-- Finish line -->
    <div class="pc-finish">
      Don't book the real exam until practice exams are comfortably at <strong>900+</strong>.
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
.pc-eyebrow {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 36px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  font-weight: 600;
  display: block;
  margin-bottom: 12px;
}
.pc-note {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-style: italic;
  font-size: 26px;
  line-height: 1.4;
  margin-top: 20px;
  margin-bottom: 36px;
}

/* Setup steps */
.pc-setup {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 28px;
}
.pc-step {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 16px 24px;
  background: #fff;
  border: 1px solid var(--paper-200);
  border-left: 6px solid transparent;
  border-radius: 12px;
  position: relative;
}
.pc-step--skipped {
  background: transparent;
  border-color: rgba(31, 58, 54, 0.10);
  opacity: 0.42;
}
.pc-step-num {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 20px;
  font-weight: 600;
  letter-spacing: 0.05em;
  min-width: 40px;
}
.pc-step-label {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 28px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.01em;
  line-height: 1.2;
  flex: 1;
}
.pc-step--skipped .pc-step-label {
  color: var(--forest-500);
  text-decoration: line-through;
}
.pc-pill {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  padding: 5px 12px;
  border: 1.5px solid transparent;
  border-radius: 999px;
}
.pc-skip {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 16px;
  font-weight: 600;
  color: var(--forest-500);
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

/* Loop block */
.pc-loop {
  position: relative;
  background: var(--mint-100);
  border-radius: 16px;
  padding: 24px 28px 28px;
  border: 2px solid transparent;
}
.pc-loop-tag {
  position: absolute;
  top: -14px;
  left: 24px;
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 16px;
  font-weight: 700;
  color: #fff;
  padding: 4px 12px;
  border-radius: 999px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}
.pc-loop-grid {
  display: grid;
  grid-template-columns: 1fr auto 1fr auto 1fr;
  align-items: stretch;
  gap: 0;
  margin-top: 6px;
}
.pc-loop-step {
  background: #fff;
  border-radius: 12px;
  padding: 18px 20px;
  border: 1px solid var(--paper-200);
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.pc-loop-num {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 18px;
  font-weight: 600;
  letter-spacing: 0.05em;
}
.pc-loop-label {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 26px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.01em;
  line-height: 1.15;
}
.pc-loop-detail {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 18px;
  color: var(--forest-500);
  line-height: 1.35;
}
.pc-arrow {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 12px;
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 36px;
  font-weight: 400;
}
.pc-loop-foot {
  margin-top: 14px;
  text-align: center;
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-style: italic;
  font-size: 20px;
  color: var(--forest-500);
  letter-spacing: 0.02em;
}
.pc-loop-foot strong {
  font-style: normal;
}

/* Finish-line strip */
.pc-finish {
  margin-top: 18px;
  padding: 12px 24px;
  background: var(--forest-800);
  color: var(--mint-100);
  border-radius: 10px;
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 20px;
  font-weight: 600;
  letter-spacing: 0.04em;
  text-align: center;
}
.pc-finish strong {
  color: var(--sprout-500);
}
</style>
