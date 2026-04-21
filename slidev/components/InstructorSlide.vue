<script setup>
// Meet your instructor — port of Instructor() in slides.jsx (lines 196–299).
// 2-col grid: 460px portrait column + details column with headline,
// bio paragraph, certifications grid (2x4), and education list.

const certs = [
  'Claude Certified Architect — Foundations',
  'Claude Certified Architect — Early Adopter',
  'NVIDIA-Certified Associate: Generative AI LLMs',
  'NVIDIA-Certified Associate: AI Infrastructure & Operations',
  'AWS Certified Solutions Architect — Associate',
  'AWS Certified Machine Learning — Associate',
  'Databricks Certified Lakehouse Fundamentals',
  'Databricks Certified Data Engineer — Associate',
]

const education = [
  [
    'Carnegie Mellon University',
    'M.S. Mechanical Engineering · M.S. Engineering & Technology Innovation Mgmt · B.S. Mechanical Engineering',
  ],
  ['Udacity Nanodegrees', 'Deep Learning · Computer Vision · Data Engineering'],
  ['Udacity Author', 'Designing AWS Architecture for Workloads'],
]
</script>

<template>
  <Frame>
    <Eyebrow>Meet your instructor</Eyebrow>

    <div class="instructor__grid">
      <!-- Left: portrait + name card -->
      <div>
        <div class="instructor__portrait">
          <img src="/assets/instructor.jpg" alt="Jonathan Dyer" />
        </div>
        <div class="instructor__name">Jonathan Dyer, M.S.</div>
        <div class="instructor__role">Senior AI Engineer &middot; Anthropic Partner</div>
        <div class="instructor__loc">Los Angeles, California</div>
      </div>

      <!-- Right: headline + bio + certs + education -->
      <div class="instructor__right">
        <div class="instructor__headline">One mission: Teach it Right.</div>

        <div class="instructor__bio">
          Senior AI Engineer at an Anthropic Partner firm — architecting production
          Generative AI systems for enterprise clients across High Tech Supply Chains,
          Life Sciences and Creative Industries.
          <br />
          <strong>2024 BEYA Modern-Day Technology Leader. Udacity Author.</strong>
        </div>

        <div class="instructor__section-label instructor__section-label--sprout">
          Certifications
        </div>
        <div class="instructor__certs">
          <div v-for="c in certs" :key="c" class="instructor__cert">
            <span class="instructor__cert-dash">—</span>
            <span>{{ c }}</span>
          </div>
        </div>

        <div class="instructor__section-label instructor__section-label--teal">
          Education &amp; coursework
        </div>
        <div v-for="[h, b] in education" :key="h" class="instructor__edu">
          <div class="instructor__edu-h">{{ h }}</div>
          <div class="instructor__edu-b">{{ b }}</div>
        </div>
      </div>
    </div>
  </Frame>
</template>

<style scoped>
.instructor__grid {
  display: grid;
  grid-template-columns: 460px 1fr;
  gap: 48px;
  flex: 1;
  align-items: start;
}
.instructor__portrait {
  width: 460px;
  height: 460px;
  border-radius: 20px;
  background: var(--mint-100);
  border: 1px solid var(--paper-200);
  overflow: hidden;
  position: relative;
}
.instructor__portrait img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}
.instructor__name {
  font-family: var(--font-display);
  font-size: 56px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.02em;
  line-height: 1.05;
  margin-top: 32px;
}
.instructor__role {
  font-family: var(--font-body);
  font-size: 26px;
  color: var(--teal-600);
  margin-top: 12px;
  font-weight: 500;
  line-height: 1.35;
}
.instructor__loc {
  font-family: var(--font-body);
  font-size: 24px;
  color: var(--forest-500);
  margin-top: 8px;
  letter-spacing: 0.04em;
}
.instructor__right {
  padding-top: 8px;
}
.instructor__headline {
  font-family: var(--font-display);
  font-size: 56px;
  font-weight: 500;
  color: var(--forest-800);
  letter-spacing: -0.02em;
  line-height: 1.1;
  margin-bottom: 24px;
}
.instructor__bio {
  font-family: var(--font-body);
  font-size: 24px;
  color: var(--forest-500);
  line-height: 1.55;
  margin-bottom: 36px;
}
.instructor__bio strong {
  color: var(--forest-700);
  font-weight: 700;
}
.instructor__section-label {
  font-family: var(--font-body);
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  margin-bottom: 14px;
}
.instructor__section-label--sprout {
  color: var(--sprout-600);
}
.instructor__section-label--teal {
  color: var(--teal-500);
}
.instructor__certs {
  display: grid;
  grid-template-columns: 1fr 1fr;
  column-gap: 20px;
  row-gap: 6px;
  margin-bottom: 28px;
}
.instructor__cert {
  font-family: var(--font-body);
  font-size: 24px;
  color: var(--forest-800);
  padding: 8px 0;
  border-top: 1px solid var(--paper-200);
  line-height: 1.4;
  display: flex;
  gap: 10px;
}
.instructor__cert-dash {
  color: var(--sprout-500);
  font-weight: 700;
}
.instructor__edu {
  padding: 8px 0;
  border-top: 1px solid var(--paper-200);
}
.instructor__edu-h {
  font-family: var(--font-body);
  font-size: 24px;
  font-weight: 600;
  color: var(--forest-800);
  line-height: 1.3;
}
.instructor__edu-b {
  font-family: var(--font-body);
  font-size: 24px;
  color: var(--forest-500);
  line-height: 1.4;
  margin-top: 4px;
}
</style>
