<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideFooter from './SlideFooter.vue'

defineProps({
  eyebrow: { type: String, default: '' },
  leadLine: { type: String, default: '' },
  concept: {
    type: String,
    required: true,
    validator: (v) => v.length <= 40,
  },
  supportLine: { type: String, default: '' },
  accent: { type: String, default: 'var(--sprout-600)' },
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

    <div class="ch__wrap">
      <div v-if="leadLine" class="ch__lead">
        {{ leadLine }}
      </div>

      <div class="ch__concept" :style="{ color: accent }">
        {{ concept }}
      </div>

      <div v-if="supportLine" class="ch__support">
        {{ supportLine }}
      </div>
    </div>

    <SlideFooter :label="footerLabel" :num="footerNum" :total="footerTotal" />
  </Frame>
</template>

<style scoped>
.ch__wrap {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 40px;
  max-width: 1600px;
}
.ch__lead {
  font-family: var(--font-body);
  font-size: 32px;
  font-weight: 500;
  line-height: 1.35;
  color: var(--forest-500);
  letter-spacing: -0.005em;
  max-width: 1200px;
}
.ch__concept {
  font-family: var(--font-display);
  font-style: italic;
  font-weight: 500;
  font-size: 140px;
  line-height: 1.02;
  letter-spacing: -0.03em;
}
.ch__support {
  font-family: var(--font-display);
  font-size: 36px;
  font-weight: 400;
  color: var(--forest-500);
  line-height: 1.35;
  font-style: italic;
  letter-spacing: -0.01em;
  max-width: 1200px;
}
</style>
