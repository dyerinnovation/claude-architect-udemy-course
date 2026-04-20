<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'

const items = [
  ['Explain the agentic loop', 'Understand exactly how it works \u2014 and precisely what breaks it.'],
  ['Design reliable tool interfaces', 'Tools Claude selects correctly, with errors that guide recovery.'],
  ['Configure Claude Code for a team', 'Not just personal use \u2014 multi-developer, CI/CD, custom rules.'],
  ['Dissect every sample question', 'All 12 official questions, with distractor analysis on each.'],
]
</script>

<template>
  <Frame>
    <Eyebrow>Welcome &middot; 01</Eyebrow>
    <SlideTitle>By the end of this course.</SlideTitle>

    <div class="outcomes__grid">
      <v-clicks>
        <div v-for="([h, body], i) in items" :key="h" class="outcomes__card">
          <div class="outcomes__num">0{{ i + 1 }}</div>
          <div class="outcomes__heading">{{ h }}</div>
          <div class="outcomes__body">{{ body }}</div>
        </div>
      </v-clicks>
    </div>
  </Frame>
</template>

<style scoped>
.outcomes__grid {
  margin-top: 72px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
}
.outcomes__card {
  background: var(--paper-0);
  border: 1px solid var(--paper-200);
  border-radius: 16px;
  padding: 40px 44px;
  display: flex;
  flex-direction: column;
  gap: 18px;
  min-height: 240px;
}
.outcomes__num {
  font-family: var(--font-mono);
  font-size: 24px;
  font-weight: 500;
  color: var(--sprout-600);
  letter-spacing: 0.05em;
}
.outcomes__heading {
  font-family: var(--font-display);
  font-size: 40px;
  font-weight: 500;
  color: var(--forest-800);
  line-height: 1.1;
  letter-spacing: -0.01em;
}
.outcomes__body {
  font-family: var(--font-body);
  font-size: 24px;
  line-height: 1.45;
  color: var(--forest-500);
}
</style>
