<script setup>
// EqBox helper folded inline below via template.
</script>

<template>
  <div class="np-frame">
    <div class="eyebrow">
      Exam format &middot; 02
    </div>
    <h1 class="slide-title">
      No penalty for wrong answers.
    </h1>

    <div class="np-body">
      <!-- Visual equation: wrong = blank = 0 -->
      <div class="eq-row">
        <div
          class="eq-box"
          :style="{ borderColor: 'var(--err, #c44a3c)' }"
        >
          <div
            class="eq-label"
            :style="{ color: 'var(--err, #c44a3c)' }"
          >
            Wrong
          </div>
          <div class="eq-value">
            0
          </div>
        </div>
        <div class="equals">
          =
        </div>
        <div
          class="eq-box"
          :style="{ borderColor: 'var(--forest-500, #427065)' }"
        >
          <div
            class="eq-label"
            :style="{ color: 'var(--forest-500, #427065)' }"
          >
            Blank
          </div>
          <div class="eq-value">
            0
          </div>
        </div>
      </div>

      <div class="np-statement">
        So on any question you're unsure about, there is exactly one correct move:<br>
        <em class="np-em">answer it anyway.</em>
      </div>

      <div class="np-rule">
        <strong class="np-rule-lead">Final sweep rule:</strong>&nbsp;never leave a question blank — guessing dominates skipping, every time.
      </div>
    </div>
  </div>
</template>

<style scoped>
.np-frame {
  width: 1920px;
  height: 1080px;
  padding: 110px 120px 96px;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  background: var(--paper-50, #fafcfa);
  color: var(--forest-800, #1f3a36);
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
}
.eyebrow {
  font-size: 22px;
  font-weight: 600;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--teal-500, #1f8e88);
  margin-bottom: 48px;
}
.slide-title {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-weight: 500;
  font-size: 76px;
  line-height: 1.08;
  letter-spacing: -0.02em;
  margin: 0;
  color: var(--forest-800, #1f3a36);
}
.np-body {
  margin-top: 88px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
}
.eq-row {
  display: flex;
  align-items: center;
  gap: 56px;
  margin-bottom: 64px;
}
.eq-box {
  width: 320px;
  padding: 36px 40px;
  background: #fff;
  border: 2px solid;
  border-radius: 18px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  box-sizing: border-box;
}
.eq-label {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 24px;
  font-weight: 600;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}
.eq-value {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 140px;
  font-weight: 500;
  color: var(--forest-800, #1f3a36);
  line-height: 1;
  letter-spacing: -0.03em;
}
.equals {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 96px;
  font-weight: 400;
  color: var(--forest-500, #427065);
  line-height: 1;
}
.np-statement {
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-size: 56px;
  font-weight: 500;
  color: var(--forest-800, #1f3a36);
  line-height: 1.15;
  letter-spacing: -0.015em;
  text-align: center;
  max-width: 1400px;
}
.np-em {
  color: var(--sprout-600, #449122);
  font-style: italic;
}
.np-rule {
  margin-top: 56px;
  padding: 20px 40px;
  background: var(--mint-100, #e5f5e7);
  border-radius: 12px;
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 24px;
  color: var(--forest-800, #1f3a36);
  letter-spacing: 0.04em;
}
.np-rule-lead {
  color: var(--teal-500, #1f8e88);
}
</style>
