<script setup>
// Closing — port of Closing() in slides.jsx (lines 1840–1875).
// Four numbered takeaway cards on mint background.

const points = [
  [
    'This exam tests judgment.',
    'Not syntax recall. Every question is a scenario that asks you to choose the best architectural decision.',
  ],
  [
    'Prepare for all six scenarios.',
    'You don\u2019t pick the four that appear — Anthropic does.',
  ],
  [
    'Hands-on experience is the best experience.',
    'Completing the four exercises recommended in the exam guide will teach you small nuances you might not catch otherwise, along with the demos at the end of the course.',
  ],
  [
    'Claude is the best study partner.',
    'If possible, leverage Claude chat to explain concepts and provide examples as you study.',
  ],
]
</script>

<template>
  <Frame bg="var(--mint-100)">
    <Eyebrow>Takeaways</Eyebrow>
    <SlideTitle>Four things to carry into Section 2.</SlideTitle>

    <div class="closing__grid">
      <div
        v-for="([h, b], i) in points"
        :key="h"
        class="closing__card"
      >
        <div class="closing__num">{{ '0' + (i + 1) }}</div>
        <div class="closing__card-title">{{ h }}</div>
        <div class="closing__card-body">{{ b }}</div>
      </div>
    </div>
  </Frame>
</template>

<style scoped>
.closing__grid {
  margin-top: 72px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
}
.closing__card {
  background: var(--paper-0);
  border-radius: 16px;
  padding: 40px 44px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.closing__num {
  font-family: var(--font-mono);
  font-size: 22px;
  font-weight: 600;
  color: var(--sprout-600);
  letter-spacing: 0.08em;
}
.closing__card-title {
  font-family: var(--font-display);
  font-size: 38px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.015em;
  line-height: 1.15;
}
.closing__card-body {
  font-family: var(--font-body);
  font-size: 24px;
  color: var(--forest-500);
  line-height: 1.45;
}
</style>
