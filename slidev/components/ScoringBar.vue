<script setup>
// Positions along 100 -> 1000
const pct = (v) => ((v - 100) / 900) * 100

const b1 = pct(720)               // width: 0..720 (fail)
const b2 = pct(800) - pct(720)    // 720..800 (comfortable)
const b3 = pct(900) - pct(800)    // 800..900 (strong)
const b4 = 100 - pct(900)         // 900..1000 (mastery)
</script>

<template>
  <div class="sb-frame">
    <div class="eyebrow">Exam format &middot; 02</div>
    <h1 class="slide-title">Scaled scoring: 100 to 1000.</h1>

    <div class="sb-body">
      <div class="sb-bar-wrap">
        <!-- Bar segments (click-reveal) -->
        <div class="sb-bar">
          <v-clicks>
            <div
              class="seg seg-fail"
              :style="{ width: `${b1}%` }"
            />
            <div
              class="seg seg-pass"
              :style="{ width: `${b2}%` }"
            />
            <div
              class="seg seg-strong"
              :style="{ width: `${b3}%` }"
            />
            <div
              class="seg seg-mastery"
              :style="{ width: `${b4}%` }"
            />
          </v-clicks>
        </div>

        <!-- Tick labels -->
        <div class="sb-ticks">
          <div :style="{ flex: b1 }">
            100
          </div>
          <div
            class="tick-bold"
            :style="{ flex: b2 }"
          >
            720
          </div>
          <div
            class="tick-center"
            :style="{ flex: b3 }"
          >
            800
          </div>
          <div
            class="tick-right"
            :style="{ flex: b4 }"
          >
            1000
          </div>
        </div>

        <!-- Zone labels -->
        <div class="sb-zones">
          <v-clicks>
            <div :style="{ flex: b1 }">
              <div
                class="zone-label"
                style="color: var(--err, #c44a3c);"
              >
                Below passing
              </div>
              <div class="zone-body">
                Doesn't matter how close — 719 is a fail.
              </div>
            </div>
            <div :style="{ flex: b2 }">
              <div
                class="zone-label"
                style="color: var(--warn, #e29a2b);"
              >
                Comfortable pass
              </div>
              <div class="zone-body">
                Aim here — wiggle room on a tough scenario.
              </div>
            </div>
            <div :style="{ flex: b3 }">
              <div
                class="zone-label"
                style="color: var(--sprout-600, #449122);"
              >
                Strong pass
              </div>
              <div class="zone-body">
                Solid command across all 5 domains.
              </div>
            </div>
            <div :style="{ flex: b4 }">
              <div
                class="zone-label"
                style="color: var(--sprout-600, #449122);"
              >
                Mastery
              </div>
              <div class="zone-body">
                You could teach this course.
              </div>
            </div>
          </v-clicks>
        </div>
      </div>

      <div class="sb-tagline">
        Scaled scoring means your raw correct count is adjusted. Aim to understand — not to scrape past the line.
      </div>
    </div>
  </div>
</template>

<style scoped>
.sb-frame {
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
.sb-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  margin-top: 40px;
}
.sb-bar-wrap {
  position: relative;
  margin-top: 80px;
}
.sb-bar {
  height: 80px;
  border-radius: 12px;
  overflow: hidden;
  display: flex;
  box-shadow: 0 2px 4px rgba(31, 58, 54, 0.06);
  background: var(--paper-200, #e8ede9);
}
.seg-fail { background: var(--err, #c44a3c); opacity: 0.85; }
.seg-pass { background: var(--warn, #e29a2b); }
.seg-strong { background: var(--sprout-500, #5bb42e); }
.seg-mastery { background: var(--sprout-600, #449122); }

.sb-ticks {
  display: flex;
  margin-top: 18px;
  font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
  font-size: 22px;
  color: var(--forest-500, #427065);
}
.tick-bold {
  text-align: center;
  color: var(--forest-800, #1f3a36);
  font-weight: 600;
}
.tick-center { text-align: center; }
.tick-right { text-align: right; }

.sb-zones {
  display: flex;
  margin-top: 28px;
}
.zone-label {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 22px;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: 10px;
}
.zone-body {
  font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 24px;
  color: var(--forest-500, #427065);
  line-height: 1.4;
  padding-right: 20px;
}
.sb-tagline {
  margin-top: 72px;
  font-family: 'Newsreader', 'Iowan Old Style', Georgia, serif;
  font-style: italic;
  font-size: 32px;
  color: var(--forest-500, #427065);
  max-width: 1400px;
  line-height: 1.45;
}
</style>
