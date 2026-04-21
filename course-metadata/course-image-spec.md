# Course Image Spec — Claude Certified Architect Foundations

**Udemy requirements:** 750×422 px, JPEG / PNG / GIF, **no text on the image**.

## Concept

A minimal, schematic representation of the agentic loop: a small set of nodes connected by labeled directional edges, with one branch tagged for `tool_use` and another for `end_turn`. The feel is an engineering whiteboard or a clean technical diagram — architectural, not decorative. Deliberately avoids the AI-image clichés: no glowing brains, no neural mesh swirls, no robot hands, no cityscapes.

## Composition

- **Focal point:** the coordinator node, positioned on the left-third vertical line, roughly 55% up from the bottom. Slightly heavier weight than the surrounding nodes.
- **Secondary elements:** three to four satellite nodes (tools / subagents) arrayed to the right, connected by thin directional lines with small arrowheads. One branch curves back to the coordinator (the `tool_use` loop); one branch terminates at a small open circle on the right-third line (the `end_turn` exit).
- **Leading lines:** the edges form a loose counter-clockwise loop that draws the eye from the coordinator → right-side nodes → back around. The `end_turn` arrow breaks the loop and exits right, creating forward motion toward where the Udemy title text will be rendered by the platform overlay.
- **Negative space:** generous. Roughly 45–55% of the canvas is flat background. No clutter, no background textures, no decorative particles.

## Color palette

Muted, technical, desaturated — consistent with dyer-capital.com.

| Role | Hex | Notes |
|---|---|---|
| Primary (nodes, key lines) | `#1F3A5F` | Deep muted navy |
| Accent (the `tool_use` branch, one focal edge) | `#C98A3B` | Burnished amber — one use only, for the branch that teaches the eye |
| Supporting — background | `#F2EFE8` | Warm off-white, paper/blueprint feel |
| Supporting — mid-tone edges | `#8A9AAC` | Dusted slate blue-grey |
| Supporting — subtle grid / secondary nodes | `#D9D3C5` | Low-contrast sand, for gridlines and de-emphasized shapes |

No neon. No rainbow gradients. At most two colors carry visual weight; the rest recede.

## Style references

- **Flat minimal schematic** — à la Stripe's product illustrations and Linear's iconography: precise line weights, no drop shadows, no gratuitous depth.
- **Technical blueprint / node graph** — in the spirit of architectural wiring diagrams or a clean directed-graph figure from a systems paper. Think Excalidraw done professionally, not marketing-slide polish.
- **Isometric low-to-mid complexity, optional** — if a slight isometric tilt is used, keep it subtle (≤15°) and consistent across all shapes. Flat is the safer default.

## Generation prompt (for image model)

> Minimal flat schematic illustration of an agentic loop: one coordinator node on the left connected by thin directional arrows to three or four smaller satellite nodes on the right, with one looping arrow curving back to the coordinator and one terminal arrow exiting to the right into a small open circle. Clean technical blueprint aesthetic, Stripe-illustration / Linear-icon style, precise uniform line weights, no drop shadows, no depth tricks, generous negative space, rule-of-thirds composition with the coordinator at the left-third intersection. Color palette: deep muted navy (#1F3A5F) for primary nodes and key lines, a single burnished amber accent (#C98A3B) on the loopback branch only, warm off-white background (#F2EFE8), dusted slate grey-blue (#8A9AAC) for secondary edges, low-contrast sand (#D9D3C5) for any gridlines. Horizontal 750×422 composition. Professional, understated, engineering-grade. **Negative prompt: no text, no words, no letters, no numbers, no faces, no human figures, no brains, no cityscapes, no neural mesh, no glowing particles, no robot hands, no circuit boards, no rainbow gradients, no neon, no 3D rendering, no photorealism, no stock-AI imagery.**
