<script setup>
// Cover slide — port of Cover() in slides.jsx (lines 130–191).
// Forest radial gradient background, logo + brand row at top,
// Section/Lecture eyebrow, hero title, subtitle, and bottom stats row.
//
// Defaults render the Section 1 / Lecture 1 welcome cover.
// Later decks pass `title` + `subtitle` + `eyebrow` to swap the hero.

defineProps({
  title: { type: String, default: '' },
  subtitle: { type: String, default: '' },
  eyebrow: { type: String, default: '' },
  stats: {
    type: Array,
    default: () => [
      '720 / 1000 to pass',
      '5 domains',
      '6 scenarios',
      '12 sample questions',
    ],
  },
})
</script>

<template>
  <Frame bg="var(--forest-900)" color="var(--mint-100)" :pad="false">
    <!-- radial gradient overlay -->
    <div class="cover__bg" />

    <div class="cover__inner">
      <!-- brand row -->
      <div class="cover__brand">
        <img src="/assets/logo-mark.png" alt="" class="cover__logo" />
        <div class="cover__brand-text">Dyer Innovation</div>
      </div>

      <!-- hero block -->
      <div>
        <div class="cover__section">{{ eyebrow || 'Section 1 · Lecture 1' }}</div>

        <h1 v-if="title" class="cover__title cover__title--custom">{{ title }}</h1>
        <h1 v-else class="cover__title">
          Claude Certified<br />Architect <span class="cover__sprout">Foundations</span>
        </h1>

        <div class="cover__subtitle">{{ subtitle || 'Course & Exam Introduction' }}</div>
      </div>

      <!-- bottom stats -->
      <div class="cover__stats">
        <template v-for="(stat, i) in stats" :key="i">
          <span>{{ stat }}</span>
          <span v-if="i < stats.length - 1" class="cover__dot">&middot;</span>
        </template>
      </div>
    </div>
  </Frame>
</template>

<style scoped>
.cover__bg {
  position: absolute;
  inset: 0;
  /* forest700 -> forest900 */
  background: radial-gradient(ellipse at 20% 80%, var(--forest-700) 0%, var(--forest-900) 60%);
}
.cover__inner {
  position: relative;
  z-index: 1;
  padding: 110px 120px 96px;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.cover__brand {
  display: flex;
  align-items: center;
  gap: 24px;
}
.cover__logo {
  width: 72px;
  height: auto;
}
.cover__brand-text {
  font-family: var(--font-body);
  font-size: 26px;
  font-weight: 500;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--mint-200);
}
.cover__section {
  font-family: var(--font-body);
  font-size: 26px;
  font-weight: 600;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--sprout-500);
  margin-bottom: 40px;
}
.cover__title {
  font-family: var(--font-display);
  font-weight: 500;
  font-size: 128px;
  line-height: 1.02;
  letter-spacing: -0.025em;
  color: var(--paper-0);
  margin: 0;
  max-width: 1500px;
}
.cover__title--custom {
  font-size: 104px;
  line-height: 1.05;
}
.cover__sprout {
  color: var(--sprout-500);
}
.cover__subtitle {
  font-family: var(--font-display);
  font-size: 44px;
  color: var(--mint-200);
  margin-top: 40px;
  font-weight: 400;
  max-width: 1200px;
  line-height: 1.3;
}
.cover__stats {
  display: flex;
  align-items: center;
  gap: 48px;
  font-family: var(--font-body);
  font-size: 26px;
  color: var(--mint-200);
  letter-spacing: 0.06em;
}
.cover__dot {
  opacity: 0.4;
}
</style>
