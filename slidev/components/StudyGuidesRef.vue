<script setup>
const guides = [
  {
    title: 'Customer Support Resolution Agent',
    tag: 'Scenario 01',
    color: 'var(--sprout-500)',
    bg: '#eaf4dd', /* source: #eaf4dd */
  },
  {
    title: 'Code Generation with Claude Code',
    tag: 'Scenario 02',
    color: 'var(--teal-500)',
    bg: 'var(--mint-100)',
  },
  {
    title: 'Multi-Agent Research System',
    tag: 'Scenario 03',
    color: 'var(--teal-600)',
    bg: '#e1eeeb', /* source: #e1eeeb */
  },
  {
    title: 'Claude Code for CI/CD',
    tag: 'Scenario 05',
    color: 'var(--warn)',
    bg: 'var(--warn-bg)',
  },
]
</script>

<template>
  <Frame>
    <Eyebrow>Course roadmap &middot; 06</Eyebrow>
    <h1 class="slide-title">
      Four study guides.<br>
      Cross-referenced to the exam guide.
    </h1>

    <div class="sg-intro">
      Included in your course materials.
    </div>

    <div class="sg-grid">
      <div
        v-for="g in guides"
        :key="g.title"
        class="sg-card"
        :style="{
          background: g.bg,
          borderLeftColor: g.color,
        }"
      >
        <svg
          width="54"
          height="66"
          viewBox="0 0 54 66"
          class="sg-doc"
        >
          <path
            d="M4 2 L36 2 L50 16 L50 62 C50 63.1 49.1 64 48 64 L4 64 C2.9 64 2 63.1 2 62 L2 4 C2 2.9 2.9 2 4 2 Z"
            fill="#fff"
            :stroke="g.color"
            stroke-width="2.5"
          />
          <path
            d="M36 2 L36 16 L50 16"
            fill="none"
            :stroke="g.color"
            stroke-width="2.5"
          />
          <line
            x1="12"
            y1="30"
            x2="40"
            y2="30"
            :stroke="g.color"
            stroke-width="2"
            stroke-linecap="round"
            opacity="0.5"
          />
          <line
            x1="12"
            y1="40"
            x2="40"
            y2="40"
            :stroke="g.color"
            stroke-width="2"
            stroke-linecap="round"
            opacity="0.5"
          />
          <line
            x1="12"
            y1="50"
            x2="30"
            y2="50"
            :stroke="g.color"
            stroke-width="2"
            stroke-linecap="round"
            opacity="0.5"
          />
        </svg>

        <div
          class="sg-tag"
          :style="{ color: g.color }"
        >
          {{ g.tag }}
        </div>

        <div class="sg-title">
          {{ g.title }}
        </div>

        <div class="sg-footer">
          Study guide
        </div>
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
.sg-intro {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 26px;
  color: var(--forest-500);
  line-height: 1.45;
  margin-top: 12px;
  margin-bottom: 40px;
  max-width: 1600px;
}
.sg-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  flex: 1;
}
.sg-card {
  border-left: 6px solid transparent;
  border-radius: 14px;
  padding: 40px 28px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  min-height: 460px;
}
.sg-doc {
  flex-shrink: 0;
}
.sg-tag {
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}
.sg-title {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 48px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.01em;
  line-height: 1.15;
}
.sg-footer {
  margin-top: auto;
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 14px;
  color: var(--forest-500);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}
</style>
