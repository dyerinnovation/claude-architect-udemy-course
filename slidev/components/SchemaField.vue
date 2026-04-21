<script setup>
defineProps({
  name: { type: String, required: true },
  type: { type: String, required: true },
  required: { type: Boolean, default: false },
  description: { type: String, default: '' },
  example: { type: String, default: '' },
})
</script>

<template>
  <div class="sf">
    <div class="sf__head">
      <span class="sf__name">{{ name }}</span>
      <span class="sf__type">{{ type }}</span>
      <span v-if="required" class="sf__badge">required</span>
      <span v-else class="sf__badge sf__badge--opt">optional</span>
    </div>
    <div v-if="description" class="sf__desc">
      {{ description }}
    </div>
    <div v-if="example" class="sf__example">
      <span class="sf__example-label">e.g.</span>
      <code>{{ example }}</code>
    </div>
  </div>
</template>

<style scoped>
.sf {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 18px 24px;
  background: var(--paper-0);
  border: 1px solid var(--paper-200);
  border-left: 4px solid var(--teal-500);
  border-radius: 12px;
}
.sf__head {
  display: flex;
  align-items: baseline;
  gap: 14px;
  flex-wrap: wrap;
}
.sf__name {
  font-family: var(--font-mono);
  font-size: 24px;
  font-weight: 600;
  color: var(--forest-800);
  letter-spacing: 0;
}
.sf__type {
  font-family: var(--font-mono);
  font-size: 20px;
  font-weight: 500;
  color: var(--teal-600);
  background: var(--teal-50);
  padding: 2px 10px;
  border-radius: 6px;
}
.sf__badge {
  font-family: var(--font-body);
  font-size: 20px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  padding: 3px 10px;
  border-radius: 999px;
  background: var(--sprout-100);
  color: var(--sprout-700);
}
.sf__badge--opt {
  background: var(--paper-100);
  color: var(--forest-500);
}
.sf__desc {
  font-family: var(--font-body);
  font-size: 24px;
  line-height: 1.5;
  color: var(--forest-500);
  margin-top: 4px;
}
.sf__example {
  font-family: var(--font-body);
  font-size: 24px;
  color: var(--forest-500);
  display: flex;
  align-items: center;
  gap: 10px;
}
.sf__example-label {
  font-family: var(--font-body);
  font-size: 20px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--forest-500);
}
.sf__example code {
  font-family: var(--font-mono);
  font-size: 24px;
  background: var(--bg-sunk);
  padding: 2px 8px;
  border-radius: 4px;
  border: 1px solid var(--paper-200);
  color: var(--forest-700);
}
</style>
