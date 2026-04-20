<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'

defineProps({
  lead: { type: String, default: '' },
  quote: { type: String, default: '' },
  attribution: { type: String, default: '' },
})
</script>

<template>
  <Frame bg="var(--paper-50)" color="var(--forest-800)">
    <Eyebrow v-if="lead">{{ lead }}</Eyebrow>
    <div class="big-quote__body">
      <div class="big-quote__text">
        <slot>
          <span v-html="quote" />
        </slot>
      </div>
      <div v-if="attribution" class="big-quote__attribution">{{ attribution }}</div>
    </div>
  </Frame>
</template>

<style scoped>
.big-quote__body {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.big-quote__text {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: 104px;
  line-height: 1.08;
  letter-spacing: -0.025em;
  color: var(--forest-900);
  max-width: 1500px;
}
.big-quote__text :deep(em) {
  font-style: italic;
}
.big-quote__attribution {
  margin-top: 56px;
  font-family: var(--font-body);
  font-size: 26px;
  color: var(--forest-500);
  letter-spacing: 0.06em;
  text-transform: uppercase;
  font-weight: 500;
}
</style>
