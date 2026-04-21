<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'

defineProps({
  eyebrow: { type: String, default: '' },
  title: { type: String, required: true },
  lang: { type: String, default: 'ts' },
  code: { type: String, required: true },
  annotation: { type: String, default: '' },
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

    <div class="cbs" :class="{ 'cbs--with-rail': !!annotation }">
      <div class="cbs__panel">
        <div class="cbs__lang">
          {{ lang }}
        </div>
        <pre class="cbs__pre"><code :class="`language-${lang}`">{{ code }}</code></pre>
      </div>
      <aside v-if="annotation" class="cbs__rail">
        <div class="cbs__rail-label">Annotation</div>
        <div class="cbs__rail-body">{{ annotation }}</div>
      </aside>
    </div>

    <SlideFooter :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.cbs {
  margin-top: 56px;
  display: grid;
  grid-template-columns: 1fr;
  gap: 28px;
  flex: 1;
  min-height: 0;
}
.cbs--with-rail {
  grid-template-columns: minmax(0, 1.6fr) minmax(360px, 1fr);
}
.cbs__panel {
  position: relative;
  background: var(--mint-100);
  border: 1px solid var(--mint-300);
  border-radius: 16px;
  padding: 36px 40px 40px;
  overflow: hidden;
}
.cbs__lang {
  position: absolute;
  top: 16px;
  right: 24px;
  font-family: var(--font-mono);
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--teal-600);
  background: var(--paper-0);
  padding: 4px 12px;
  border-radius: 999px;
  border: 1px solid var(--teal-200);
}
.cbs__pre {
  margin: 0;
  padding: 0;
  background: transparent;
  color: var(--forest-800);
  font-family: var(--font-mono);
  font-size: 20px;
  line-height: 1.55;
  white-space: pre;
  overflow: auto;
  max-height: 100%;
}
.cbs__pre :deep(code) {
  background: transparent;
  border: 0;
  padding: 0;
  color: inherit;
  font-family: inherit;
  font-size: inherit;
  line-height: inherit;
}

.cbs__rail {
  background: var(--paper-0);
  border: 1px solid var(--paper-200);
  border-left: 6px solid var(--sprout-500);
  border-radius: 16px;
  padding: 28px 28px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.cbs__rail-label {
  font-family: var(--font-body);
  font-size: 18px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--sprout-700);
}
.cbs__rail-body {
  font-family: var(--font-display);
  font-style: italic;
  font-size: 28px;
  line-height: 1.4;
  color: var(--forest-500);
}
</style>
