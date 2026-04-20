<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'

const items = [
  ['01', 'Welcome', 'What this course is, who it\u2019s for, what you\u2019ll take away.'],
  ['02', 'Exam format', 'Scoring, question style, the 6-pick-4 scenario rule, time budget.'],
  ['03', 'The five domains', 'What each domain covers and why the weights dictate your plan.'],
  ['04', 'The six scenarios', 'Why scenarios are the frame for every question on the exam.'],
  ['05', 'Study strategy', 'Three paths through the course \u2014 pick yours by experience level.'],
  ['06', 'Course roadmap', 'How the 10 sections fit together, and why sections 3\u20137 are weight-ordered.'],
]
</script>

<template>
  <Frame>
    <Eyebrow>In this lecture</Eyebrow>
    <SlideTitle>Six pieces of groundwork, before we open Domain 1.</SlideTitle>
    <div class="agenda__grid">
      <div v-for="[num, name, desc] in items" :key="num" class="agenda__item">
        <div class="agenda__num">{{ num }}</div>
        <div>
          <div class="agenda__name">{{ name }}</div>
          <div class="agenda__desc">{{ desc }}</div>
        </div>
      </div>
    </div>
  </Frame>
</template>

<style scoped>
.agenda__grid {
  margin-top: 80px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  column-gap: 80px;
  row-gap: 44px;
}
.agenda__item {
  display: grid;
  grid-template-columns: 110px 1fr;
  align-items: baseline;
  border-top: 1px solid var(--paper-200);
  padding-top: 24px;
}
.agenda__num {
  font-family: var(--font-mono);
  font-size: 30px;
  font-weight: 500;
  color: var(--sprout-600);
  letter-spacing: 0.05em;
}
.agenda__name {
  font-family: var(--font-display);
  font-size: 38px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.01em;
  line-height: 1.1;
}
.agenda__desc {
  font-family: var(--font-body);
  font-size: 24px;
  color: var(--forest-500);
  margin-top: 10px;
  line-height: 1.45;
  max-width: 560px;
}
</style>
