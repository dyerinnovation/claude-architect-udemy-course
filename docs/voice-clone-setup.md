# ElevenLabs Voice Clone Setup — Udemy Course Narration

## TLDR

This walkthrough gets you a cloned ElevenLabs voice wired into the course rendering pipeline, ready to narrate all 94 lecture scripts.  
**User time:** ~15 min recording + ~10 min UI + .env wiring.  
**End state:** `.env` populated, smoke test ready to run.

---

## Tier Decision (Read This First)

Free and Starter tiers add a watermark to generated audio **and strip commercial rights**. Neither is usable for a paid Udemy course.

| Tier | Price | Credits/mo | Lectures/mo (est.) | Commercial rights |
|---|---|---|---|---|
| Free | $0 | 10k | ~1 | No |
| Starter | $5 | 30k | ~3 | No |
| Creator | $22 | 121k | ~14 | Yes |
| **Pro** | **$99** | **500k** | **~55** | **Yes** |
| Scale | $330 | 2M | ~220 | Yes |

**Recommendation:** Subscribe to **Pro ($99/mo)** for 1–2 months.

- 94 lectures at ~5,000 credits/lecture ≈ 470k total credits
- Pro covers that in ~1 month; worst case 2 months = ~$160–$200 all-in
- **Downgrade immediately after all audio is rendered**

> Pricing reference: https://elevenlabs.io/pricing

---

## Hardware Checklist

Before recording, confirm you have:

- **USB condenser microphone** — Shure MV7, Blue Yeti, Rode NT-USB, or AT2020USB+ (any of these work well)
- **Pop filter** — reduces plosives on "p" and "b" sounds
- **Quiet room** — close windows, disable HVAC, shut laptop vents if possible
- **Silence check** — record 5 seconds of silence, listen back; any hum or hiss will degrade the clone

> **Warning:** Do NOT record on a phone mic, laptop built-in mic, or AirPods. The clone quality scales directly with mic quality. A poor sample produces a poor clone that cannot be improved without re-recording.

---

## Recording the Clone Sample

**Target:** 1–2 minutes of continuous speech. The sample below is ~280 words (~90 seconds at a comfortable narration pace).

Set your recorder to **44.1 kHz / 128 kbps minimum** (Audacity, GarageBand, or QuickTime all work). Save as:

```
~/Downloads/voice-clone-sample.mp3
```

**Read this script aloud — warm, confident, instructor tone:**

---

> Welcome to the Claude Certified Architect course. I'm Jonathan Dyer, and over the next several hours we're going to move from the fundamentals of the Anthropic API all the way through advanced topics like multi-agent orchestration, observability, and production-grade deployment.
>
> Let's start with the basics. Anthropic offers three model families: Claude Opus, Claude Sonnet, and Claude Haiku. Each sits at a different point on the capability-cost-speed curve, and choosing the right one for a given task is one of the first decisions you'll make as an architect.
>
> The SDK is available in Python and TypeScript. You'll authenticate with an API key, call the Messages endpoint, and get back a structured response that includes a stop reason — either "end_turn," "tool_use," or "max_tokens." Knowing which stop reason fired is how you branch your agent's logic.
>
> Tool use is the mechanism that lets Claude interact with the outside world. You define a JSON schema for each tool, pass it in the request, and Claude returns a structured tool call your application executes. Combine that with prompt caching and you have the foundation of an efficient agentic loop.
>
> The Model Context Protocol — MCP — takes this further. It's a standardized interface that lets Claude connect to external services, databases, and file systems through a defined client-server handshake.
>
> We'll also cover structured output, citation, retrieval, batch processing, and the CLI. By the end, you'll understand not just how to call the Claude API, but how to design systems around it — systems that are observable, maintainable, and ready for production.
>
> Let's get started.

---

Read at a natural teaching pace. Do not rush. One clean take is enough.

---

## Web UI Walkthrough

1. **Go to** https://elevenlabs.io — log in or create an account (use the Pro plan).
2. **Left sidebar** → click **Voices**.
3. **Click the `+` button** → select **Instant Voice Clone**.
4. **Upload** `~/Downloads/voice-clone-sample.mp3`.
5. **Name the voice:** `Jonathan Dyer — Narration`
6. **Tick the consent / IP-rights checkbox** (confirms you own the voice sample).
7. **Click Save**.
8. **Wait ~30 seconds** — ElevenLabs processes the sample. The voice card appears when ready.

---

## Retrieve the Voice ID

After the voice card appears:

1. **Click the voice card** to open it.
2. Look at the browser URL — it contains `/voice-lab/<voice_id>`.  
   **Copy the `<voice_id>` hash** (looks like `21m00Tcm4TlvDq8ikWAM`).

Alternatively, list all voices via API:

```bash
curl -X GET "https://api.elevenlabs.io/v1/voices" \
  -H "xi-api-key: $ELEVENLABS_API_KEY" \
  | python3 -m json.tool | grep -A2 "Jonathan"
```

---

## Create the API Key

1. **Top-right avatar** → **API Keys**.
2. **Click Create API Key** → name it `Udemy Course Builder`.
3. **Copy the key immediately** — it is shown **once only**.

> **Security rules:**
> - Never paste the full key into chat
> - Never commit it to git
> - Store only in `.env` (which is already gitignored)

---

## Wire Up `.env`

Open (or create) this file:

```
/Users/jonathandyer/Documents/dev/udemy-courses/udemy-course-builder/.claude/skills/udemy-lecture-video-renderer/.env
```

Paste in:

```env
ELEVENLABS_API_KEY=<paste your key here>
ELEVENLABS_VOICE_ID=<paste your voice_id here>
ELEVENLABS_PRONUNCIATION_DICT_ID=
ELEVENLABS_PRONUNCIATION_DICT_VERSION=
```

Leave the pronunciation dict fields **blank** — the smoke test populates them automatically when it installs the technical-term dictionary for Anthropic, SDK, MCP, etc.

The skill's `.gitignore` already excludes `.env`. No risk of accidentally committing credentials.

---

## Smoke-Test Handshake

When you're ready to test, tell Claude:

- The **voice name** you set (e.g., `Jonathan Dyer — Narration`)
- The **last 4 characters** of your voice_id (e.g., `ending in ...WAM`)
- Confirmation that `.env` is populated with both values

> **Do NOT paste the full API key or full voice_id into chat.** The last-4-chars convention is enough for Claude to verify the ID matches.

Claude will then run the smoke test, install the pronunciation dictionary, and render a short test clip for your approval before batch-rendering all 94 lectures.

---

## Troubleshooting

- **"Voice doesn't sound like me"** — re-record with more sentence variety, less room reverb, and a longer sample (aim for 90–120 seconds). The clone mirrors whatever it receives.
- **"Pronunciation is off for technical terms"** (Anthropic, SDK, MCP, Haiku) — expected. The smoke test installs a pronunciation dictionary that corrects these. Do not re-record for this reason.
- **"Instant Voice Clone option is locked / greyed out"** — you're on Free or Starter tier. Upgrade to Creator or Pro; the option unlocks immediately.
- **"API returns 401 Unauthorized"** — check for: leading/trailing spaces in the `.env` value, accidental quote characters around the key, or the wrong variable name (`ELEVENLABS_API_KEY` exactly, no typos).
- **"Credits exhausted mid-batch"** — Pro gives 500k/mo; if you're rendering everything in one go and hit the limit, wait for the monthly reset or temporarily upgrade to Scale for one month.
