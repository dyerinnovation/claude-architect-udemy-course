<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'

const props = defineProps({
  eyebrow: { type: String, default: '' },
  title: { type: String, required: true },
  lang: { type: String, default: 'ts' },
  // `code` is intentionally optional (not required) — Slidev script-setup
  // blocks are scoped per-slide, so hoisted consts declared at the top of a
  // lecture markdown file are NOT visible in subsequent slides and :code="..."
  // can resolve to undefined. Accept undefined/empty here to avoid the Vue
  // type-warning, and let the default slot act as a fallback code body.
  code: { type: String, default: '' },
  // When provided, code reveals incrementally via slidev clicks:
  // chunk 0 is always visible; chunks 1..N reveal on click 1..N.
  // Use this for narration-aligned code reveals (see lecture-writer's
  // [click] marker convention). Annotation becomes always-visible when
  // codeChunks is used (no longer hidden behind its own click).
  codeChunks: { type: Array, default: () => [] },
  annotation: { type: String, default: '' },
  footerLabel: { type: String, default: '' },
  footerNum: { type: [Number, String], default: 1 },
  footerTotal: { type: [Number, String], default: 1 },
  hideFooter: { type: Boolean, default: false },
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
        <pre class="cbs__pre"><code v-if="codeChunks.length > 0"><span class="cbs__chunk" v-text="codeChunks[0]" /><v-clicks><span v-for="(chunk, i) in codeChunks.slice(1)" :key="i" class="cbs__chunk" v-text="chunk" /></v-clicks></code><code v-else-if="code" v-text="code" /><code v-else><slot /></code></pre>
      </div>
      <!-- Annotation: always visible when codeChunks is used (so it can guide the reveal sequence). Single-code slides keep the original click-reveal behavior. -->
      <template v-if="codeChunks.length > 0">
        <aside v-if="annotation" class="cbs__rail">
          <div class="cbs__rail-label">Annotation</div>
          <div class="cbs__rail-body">{{ annotation }}</div>
        </aside>
      </template>
      <v-click v-else>
        <aside v-if="annotation" class="cbs__rail">
          <div class="cbs__rail-label">Annotation</div>
          <div class="cbs__rail-body">{{ annotation }}</div>
        </aside>
      </v-click>
    </div>

    <SlideFooter v-if="!hideFooter" :label="footerLabel" :num="footerNum" :total="footerTotal" />
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
  font-size: 20px;
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
  font-size: 24px;
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

/* Click-reveal chunks: stack as blocks so collapsed reveals don't reserve layout space */
.cbs__pre .cbs__chunk {
  display: block;
}
/* Visible spacer between successive code chunks. Browsers collapse trailing
   whitespace inside display:block spans inside <pre>, so we add a margin
   instead of relying on \n at the chunk boundaries. */
.cbs__pre .cbs__chunk:not(:first-child) {
  margin-top: 0.8em;
}
/* Collapsed (un-revealed) chunks should not reserve layout space. */
.cbs__pre :deep(.slidev-vclick-hidden) {
  display: none;
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
  font-size: 20px;
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
