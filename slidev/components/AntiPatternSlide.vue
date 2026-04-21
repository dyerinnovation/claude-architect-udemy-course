<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'

defineProps({
  eyebrow: { type: String, default: '' },
  title: { type: String, required: true },
  badExample: { type: String, required: true },
  whyItFails: { type: String, default: '' },
  fixExample: { type: String, required: true },
  lang: { type: String, default: 'ts' },
  footerLabel: { type: String, default: '' },
  footerNum: { type: [Number, String], default: 1 },
  footerTotal: { type: [Number, String], default: 1 },
})
</script>

<template>
  <Frame>
    <Eyebrow v-if="eyebrow">
      {{ eyebrow }}
    </Eyebrow>
    <SlideTitle>{{ title }}</SlideTitle>

    <div class="aps">
      <section class="aps__col aps__col--bad">
        <header class="aps__header aps__header--bad">
          <span class="aps__glyph aps__glyph--bad">&times;</span>
          <span class="aps__label">Don't</span>
        </header>
        <pre class="aps__pre aps__pre--bad"><code :class="`language-${lang}`">{{ badExample }}</code></pre>
        <div v-if="whyItFails" class="aps__why">
          <span class="aps__why-label">Why it fails</span>
          <span class="aps__why-text">{{ whyItFails }}</span>
        </div>
      </section>

      <section class="aps__col aps__col--good">
        <header class="aps__header aps__header--good">
          <span class="aps__glyph aps__glyph--good">&#10003;</span>
          <span class="aps__label">Do</span>
        </header>
        <pre class="aps__pre aps__pre--good"><code :class="`language-${lang}`">{{ fixExample }}</code></pre>
      </section>
    </div>

    <SlideFooter :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.aps {
  margin-top: 48px;
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 28px;
  min-height: 0;
}
.aps__col {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 0;
  border-radius: 18px;
  padding: 24px 24px 26px;
  border: 1px solid transparent;
}
.aps__col--bad {
  background: var(--clay-50);
  border-color: var(--clay-200);
}
.aps__col--good {
  background: var(--sprout-50);
  border-color: var(--sprout-300);
}
.aps__header {
  display: flex;
  align-items: center;
  gap: 14px;
}
.aps__glyph {
  width: 36px;
  height: 36px;
  border-radius: 999px;
  color: var(--paper-0);
  font-weight: 700;
  font-size: 22px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
  font-family: var(--font-body);
}
.aps__glyph--bad {
  background: var(--clay-500);
}
.aps__glyph--good {
  background: var(--sprout-600);
}
.aps__label {
  font-family: var(--font-body);
  font-size: 24px;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}
.aps__header--bad .aps__label { color: var(--clay-500); }
.aps__header--good .aps__label { color: var(--sprout-700); }

.aps__pre {
  margin: 0;
  padding: 20px 22px;
  background: var(--forest-900);
  color: var(--mint-100);
  border-radius: 12px;
  font-family: var(--font-mono);
  font-size: 18px;
  line-height: 1.55;
  white-space: pre;
  overflow: auto;
  flex: 1;
  min-height: 0;
}
.aps__pre :deep(code) {
  background: transparent;
  border: 0;
  padding: 0;
  color: inherit;
  font-family: inherit;
  font-size: inherit;
  line-height: inherit;
}

.aps__why {
  background: var(--paper-0);
  border: 1px solid var(--clay-200);
  border-left: 5px solid var(--clay-500);
  border-radius: 10px;
  padding: 14px 18px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.aps__why-label {
  font-family: var(--font-body);
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--clay-500);
}
.aps__why-text {
  font-family: var(--font-display);
  font-style: italic;
  font-size: 22px;
  line-height: 1.4;
  color: var(--forest-500);
}
</style>
