<script setup>
import { computed } from 'vue'
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'
import SlideFooter from './SlideFooter.vue'

const props = defineProps({
  eyebrow: { type: String, default: '' },
  title: { type: String, required: true },
  leftLabel: { type: String, required: true },
  rightLabel: { type: String, required: true },
  variant: {
    type: String,
    default: 'compare',
    validator: (v) => ['compare', 'antipattern-fix'].includes(v),
  },
  footerLabel: { type: String, default: '' },
  footerNum: { type: [Number, String], default: 1 },
  footerTotal: { type: [Number, String], default: 1 },
})

const palette = computed(() => {
  if (props.variant === 'antipattern-fix') {
    return {
      leftAccent: 'var(--clay-500)',
      leftBg: 'var(--clay-50)',
      leftBorder: 'var(--clay-200)',
      rightAccent: 'var(--sprout-600)',
      rightBg: 'var(--sprout-50)',
      rightBorder: 'var(--sprout-300)',
    }
  }
  return {
    leftAccent: 'var(--teal-600)',
    leftBg: 'var(--teal-50)',
    leftBorder: 'var(--teal-200)',
    rightAccent: 'var(--sprout-600)',
    rightBg: 'var(--sprout-50)',
    rightBorder: 'var(--sprout-300)',
  }
})
</script>

<template>
  <Frame>
    <Eyebrow v-if="eyebrow">
      {{ eyebrow }}
    </Eyebrow>
    <SlideTitle>{{ title }}</SlideTitle>

    <div class="tc">
      <section
        class="tc__col"
        :style="{ background: palette.leftBg, borderColor: palette.leftBorder }"
      >
        <div class="tc__label" :style="{ color: palette.leftAccent }">
          <span class="tc__dot" :style="{ background: palette.leftAccent }" />
          {{ leftLabel }}
        </div>
        <div class="tc__body">
          <slot name="left" />
        </div>
      </section>

      <section
        class="tc__col"
        :style="{ background: palette.rightBg, borderColor: palette.rightBorder }"
      >
        <div class="tc__label" :style="{ color: palette.rightAccent }">
          <span class="tc__dot" :style="{ background: palette.rightAccent }" />
          {{ rightLabel }}
        </div>
        <div class="tc__body">
          <slot name="right" />
        </div>
      </section>
    </div>

    <SlideFooter :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.tc {
  margin-top: 56px;
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  min-height: 0;
}
.tc__col {
  border: 1px solid transparent;
  border-radius: 20px;
  padding: 36px 40px;
  display: flex;
  flex-direction: column;
  gap: 22px;
  min-width: 0;
}
.tc__label {
  display: flex;
  align-items: center;
  gap: 12px;
  font-family: var(--font-body);
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}
.tc__dot {
  display: inline-block;
  width: 12px;
  height: 12px;
  border-radius: 999px;
}
.tc__body {
  font-family: var(--font-body);
  font-size: 24px;
  line-height: 1.5;
  color: var(--forest-800);
  flex: 1;
  min-width: 0;
}
.tc__body :deep(p) {
  margin: 0 0 14px;
  max-width: none;
}
.tc__body :deep(ul) {
  padding-left: 24px;
  margin: 0;
}
.tc__body :deep(li) {
  margin-bottom: 10px;
}
.tc__body :deep(code),
.tc__body :deep(pre) {
  font-family: var(--font-mono);
  font-size: 20px;
}
.tc__body :deep(pre) {
  background: var(--forest-900);
  color: var(--mint-100);
  padding: 18px 22px;
  border-radius: 12px;
  line-height: 1.5;
}
</style>
