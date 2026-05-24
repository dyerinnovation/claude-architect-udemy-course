<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'
import { ref, computed, onMounted, watch } from 'vue'
import { useResizeObserver } from '@vueuse/core'
import { useNav } from '@slidev/client'

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
      // Round-5 fix: recurse via RAF so the loop continues until content fits
      // OR floor is hit. The single-shot version only shrank one step per
      // call — when chunk 4 of SLIDE 6 (Response Object) overflowed by 2+
      // steps' worth, only one step fired and content kept clipping.
      requestAnimationFrame(checkOverflow)
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

// Determine which chunk is "active" (most recently revealed) for highlighting.
// In Slidev v51, useNav() exposes `clicks` as a ComputedRef<number> (NOT
// `currentClicks` — that name doesn't exist on the v51 nav object).
// Chunk 0 is visible at click 0; chunk i reveals at click i. Cap at the last
// chunk index so we don't overshoot once all chunks are revealed.
const nav = useNav()
const activeChunkIdx = computed(() => {
  const cc = nav.clicks?.value ?? 0
  return Math.min(cc, Math.max(0, props.codeChunks.length - 1))
})

// Click-aware auto-shrink: ResizeObserver only fires on parent size changes,
// but click reveals grow scrollHeight without changing clientHeight — so the
// observer NEVER fires on click navigation. Without this watch, content
// revealed past the panel goes undetected and gets clipped. Re-running
// checkOverflow on every click change catches the overflow as it happens.
// (Round-3 fix: SLIDE 6 usage block was clipping at click 4 before this.)
watch(() => nav.clicks?.value, () => {
  // wait for the DOM to update with the newly-revealed chunk, then re-check
  requestAnimationFrame(checkOverflow)
})
</script>

<template>
  <Frame>
    <Eyebrow v-if="eyebrow">
      {{ eyebrow }}
    </Eyebrow>
    <SlideTitle>{{ title }}</SlideTitle>

    <div class="cbs">
      <div class="cbs__lang">
        {{ lang }}
      </div>
      <div class="cbs__panel">
        <pre ref="preRef" class="cbs__pre" :style="{ fontSize: fontSize + 'px' }"><code v-if="codeChunks.length > 0"><span class="cbs__chunk" :class="{ 'cbs__chunk--active': activeChunkIdx === 0 }" v-text="codeChunks[0]" /><v-clicks><span v-for="(chunk, i) in codeChunks.slice(1)" :key="i" class="cbs__chunk" :class="{ 'cbs__chunk--active': activeChunkIdx === i + 1 }" v-text="chunk" /></v-clicks></code><code v-else-if="code" v-text="code" /><code v-else><slot /></code></pre>
      </div>
    </div>

    <SlideFooter v-if="!hideFooter" :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.cbs {
  /* Round-6: margin-top tightened 24->8px so the SlideTitle sits closer to
     the code panel. Combined with the panel padding reduction below, this
     reclaims ~36px of vertical room for code — enough to fit SLIDE 6's
     usage block at full font size without auto-shrink. */
  margin-top: 8px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  flex: 1;
  min-height: 0;
}
.cbs__panel {
  background: var(--mint-100);
  border: 1px solid var(--mint-300);
  border-radius: 16px;
  padding: 14px 32px 18px;
  overflow: hidden;
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
}
.cbs__lang {
  /* Round-5: badge moved OUT of .cbs__panel into .cbs so the panel can
     be 100% code real estate. Reclaims ~26px of vertical room inside the
     panel + ~24px from the padding reduction = ~50px more code area. */
  align-self: flex-end;
  font-family: var(--font-mono);
  font-size: 14px;
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
/* Active chunk highlight: the chunk being narrated right now pops with a
   mint background tint + sprout-green left border. Previously revealed
   chunks stay visible but un-highlighted. */
.cbs__pre .cbs__chunk--active {
  background: var(--mint-200);
  border-left: 4px solid var(--sprout-500);
  padding-left: 12px;
  margin-left: -16px;  /* pull back so the highlight extends INTO the gutter */
  border-radius: 0 6px 6px 0;
}
</style>
