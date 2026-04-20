<script setup>
import Frame from './Frame.vue'
import Eyebrow from './Eyebrow.vue'
import SlideTitle from './SlideTitle.vue'

const good = [
  'Solution architects designing production applications with Claude',
  '6+ months hands-on with Claude APIs, Agent SDK, Claude Code & MCP',
  'You\u2019ve built agentic apps: subagent delegation, tool integration, lifecycle hooks',
  'You configure Claude Code for teams: CLAUDE.md, Skills, MCP servers, plan mode',
  'You design MCP tool & resource interfaces and engineer structured output',
]
const harder = [
  'You\u2019ve never called an LLM API \u2014 start with Anthropic\u2019s quickstart first',
  'You\u2019re looking for ML theory, training internals or model architecture (out of scope)',
  'Zero exposure to Claude Code, Agent SDK or MCP \u2014 build a small project first, then come back',
]
</script>

<template>
  <Frame>
    <Eyebrow>Welcome &middot; 01</Eyebrow>
    <SlideTitle>Who this course is for.</SlideTitle>

    <div class="whofor__intro">
      Anthropic&rsquo;s Target Candidate is a
      <strong>solution architect who designs and implements production applications with Claude</strong>
      &mdash; typically with 6+ months of hands-on experience across the Agent SDK, Claude Code, the Claude API and MCP.
    </div>

    <div class="whofor__grid">
      <div>
        <div class="whofor__header whofor__header--good">
          <span class="whofor__chip whofor__chip--good">&check;</span>
          Good fit
        </div>
        <ul class="whofor__list">
          <v-clicks>
            <li v-for="t in good" :key="t" class="whofor__item whofor__item--good">{{ t }}</li>
          </v-clicks>
        </ul>
      </div>

      <div>
        <div class="whofor__header whofor__header--warn">
          <span class="whofor__chip whofor__chip--warn">!</span>
          Not yet
        </div>
        <ul class="whofor__list">
          <v-clicks>
            <li v-for="t in harder" :key="t" class="whofor__item whofor__item--muted">{{ t }}</li>
          </v-clicks>
        </ul>
      </div>
    </div>
  </Frame>
</template>

<style scoped>
.whofor__intro {
  font-family: var(--font-body);
  font-size: 26px;
  color: var(--forest-500);
  line-height: 1.45;
  margin-top: 14px;
  max-width: 1500px;
}
.whofor__intro strong {
  color: var(--forest-800);
  font-weight: 600;
}
.whofor__grid {
  margin-top: 52px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 64px;
}
.whofor__header {
  font-family: var(--font-body);
  font-size: 24px;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 14px;
}
.whofor__header--good { color: var(--sprout-600); }
.whofor__header--warn { color: var(--warn); }
.whofor__chip {
  width: 36px;
  height: 36px;
  border-radius: 18px;
  color: white;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
}
.whofor__chip--good {
  background: var(--sprout-500);
  font-size: 20px;
}
.whofor__chip--warn {
  background: var(--warn);
  font-size: 22px;
}
.whofor__list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.whofor__item {
  font-family: var(--font-body);
  font-size: 28px;
  line-height: 1.4;
  padding: 16px 0;
  border-bottom: 1px solid var(--paper-200);
}
.whofor__item--good { color: var(--forest-800); }
.whofor__item--muted { color: var(--forest-500); }
</style>
