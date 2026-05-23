<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'
import { ref, onMounted } from 'vue'
import { useResizeObserver } from '@vueuse/core'

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
  // [click] marker convention).
  codeChunks: { type: Array, default: () => [] },
  footerLabel: { type: String, default: '' },
  footerNum: { type: [Number, String], default: 1 },
  footerTotal: { type: [Number, String], default: 1 },
  hideFooter: { type: Boolean, default: false },
})

// Auto-shrink for vertical overflow: step font-size down from 24px → 18px
// (max 4pt drop). If we hit the floor and still overflow, log a warning so
// the slide-QA pass can split the code across multiple chunks/slides.
const preRef = ref(null)
const fontSize = ref(24)

const FONT_STEPS = [24, 22, 20, 18]
let currentStepIdx = 0

function checkOverflow() {
  if (!preRef.value) return
  const el = preRef.value
  if (el.scrollHeight > el.clientHeight + 2) {
    if (currentStepIdx < FONT_STEPS.length - 1) {
      currentStepIdx += 1
      fontSize.value = FONT_STEPS[currentStepIdx]
    } else {
      // At 18px floor and still overflowing — log for slide-QA pass
      console.warn(
        `[CodeBlockSlide] Code overflow at floor font (18px) on slide titled "${props.title}". ` +
        `Consider splitting the code into more chunks or across two slides.`
      )
    }
  }
}

onMounted(() => {
  if (preRef.value) {
    useResizeObserver(preRef.value, checkOverflow)
    // Run an initial check after first paint
    requestAnimationFrame(checkOverflow)
  }
})
</script>

<template>
  <Frame>
    <Eyebrow v-if="eyebrow">
      {{ eyebrow }}
    </Eyebrow>
    <SlideTitle>{{ title }}</SlideTitle>

    <div class="cbs">
      <div class="cbs__panel">
        <div class="cbs__lang">
          {{ lang }}
        </div>
        <pre ref="preRef" class="cbs__pre" :style="{ fontSize: fontSize + 'px' }"><code v-if="codeChunks.length > 0"><span class="cbs__chunk" v-text="codeChunks[0]" /><v-clicks><span v-for="(chunk, i) in codeChunks.slice(1)" :key="i" class="cbs__chunk" v-text="chunk" /></v-clicks></code><code v-else-if="code" v-text="code" /><code v-else><slot /></code></pre>
      </div>
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
.cbs__panel {
  background: var(--mint-100);
  border: 1px solid var(--mint-300);
  border-radius: 16px;
  padding: 36px 40px 40px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 0;
}
.cbs__lang {
  align-self: flex-end;
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
  line-height: 1.55;
  white-space: pre;
  overflow: auto;
  flex: 1;
  min-height: 0;
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
</style>
