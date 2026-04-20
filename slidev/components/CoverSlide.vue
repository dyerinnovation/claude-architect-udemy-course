<script setup>
// Cover slide — port of Cover() in slides.jsx (lines 130–191).
// Forest radial gradient background, logo + brand row at top,
// Section/Lecture eyebrow, "Claude Certified Architect Foundations" hero,
// "Course & Exam Introduction" subtitle, and bottom stats row.
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
        <div class="cover__section">Section 1 &middot; Lecture 1</div>

        <h1 class="cover__title">
          Claude Certified<br />Architect <span class="cover__sprout">Foundations</span>
        </h1>

        <div class="cover__subtitle">Course &amp; Exam Introduction</div>
      </div>

      <!-- bottom stats -->
      <div class="cover__stats">
        <span>720 / 1000 to pass</span>
        <span class="cover__dot">&middot;</span>
        <span>5 domains</span>
        <span class="cover__dot">&middot;</span>
        <span>6 scenarios</span>
        <span class="cover__dot">&middot;</span>
        <span>12 sample questions</span>
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
