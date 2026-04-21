#!/bin/bash
# Slidev launcher for the Claude Certified Architect course.
#
# Usage:
#   ./start-all.sh <lecture>       → launch ONE deck on its mapped port
#                                     e.g. ./start-all.sh 3.5
#                                          ./start-all.sh lecture-3.5
#                                          ./start-all.sh lecture-3.5.md
#   ./start-all.sh --all            → launch ALL decks simultaneously
#                                     (requires a machine that can spin up
#                                      that many Vite servers; mostly for CI)
#   ./start-all.sh --list           → print the full port map and exit
#   ./start-all.sh                  → show help + port map
#
# Default is one-at-a-time because 87 simultaneous dev servers will smoke
# most laptops. Use `npm run dev:X.Y` if you prefer package.json scripts.
#
# Port map (see also feedback/claude-architect-course-feedback-*.md):
#   Section 1 lecture 1.1       → 3030
#   Section 2 lectures 2.1-2.11 → 3040-3050
#   Section 3 lectures 3.1-3.14 → 3060-3073
#   Section 4 lectures 4.1-4.14 → 3080-3093
#   Section 5 lectures 5.1-5.15 → 3100-3114
#   Section 6 lectures 6.1-6.15 → 3120-3134
#   Section 7 lectures 7.1-7.17 → 3140-3156
#
# Implementation note: this script targets macOS's system bash (3.2.57), so
# it uses indexed arrays of "key:value" strings instead of `declare -A`
# associative arrays (which require bash 4+).

set -euo pipefail

cd "$(dirname "$0")"

# Indexed array of "lecture:port" pairs. Parse with ${entry%%:*} / ${entry##*:}.
PORTS=(
  "1.1:3030"
  "2.1:3040"  "2.2:3041"  "2.3:3042"  "2.4:3043"  "2.5:3044"
  "2.6:3045"  "2.7:3046"  "2.8:3047"  "2.9:3048"  "2.10:3049" "2.11:3050"
  "3.1:3060"  "3.2:3061"  "3.3:3062"  "3.4:3063"  "3.5:3064"
  "3.6:3065"  "3.7:3066"  "3.8:3067"  "3.9:3068"  "3.10:3069"
  "3.11:3070" "3.12:3071" "3.13:3072" "3.14:3073"
  "4.1:3080"  "4.2:3081"  "4.3:3082"  "4.4:3083"  "4.5:3084"
  "4.6:3085"  "4.7:3086"  "4.8:3087"  "4.9:3088"  "4.10:3089"
  "4.11:3090" "4.12:3091" "4.13:3092" "4.14:3093"
  "5.1:3100"  "5.2:3101"  "5.3:3102"  "5.4:3103"  "5.5:3104"
  "5.6:3105"  "5.7:3106"  "5.8:3107"  "5.9:3108"  "5.10:3109"
  "5.11:3110" "5.12:3111" "5.13:3112" "5.14:3113" "5.15:3114"
  "6.1:3120"  "6.2:3121"  "6.3:3122"  "6.4:3123"  "6.5:3124"
  "6.6:3125"  "6.7:3126"  "6.8:3127"  "6.9:3128"  "6.10:3129"
  "6.11:3130" "6.12:3131" "6.13:3132" "6.14:3133" "6.15:3134"
  "7.1:3140"  "7.2:3141"  "7.3:3142"  "7.4:3143"  "7.5:3144"
  "7.6:3145"  "7.7:3146"  "7.8:3147"  "7.9:3148"  "7.10:3149"
  "7.11:3150" "7.12:3151" "7.13:3152" "7.14:3153" "7.15:3154"
  "7.16:3155" "7.17:3156"
)

# Indexed array of "major:title" pairs for section banners.
SECTION_TITLES=(
  "1:Section 1: Course Introduction"
  "2:Section 2: Claude API Fundamentals Bootcamp"
  "3:Section 3: Domain 1 - Agentic Architecture & Orchestration"
  "4:Section 4: Domain 2 - Tool Design & MCP Integration"
  "5:Section 5: Domain 3 - Claude Code Configuration & Workflows"
  "6:Section 6: Domain 4 - Prompt Engineering & Structured Output"
  "7:Section 7: Domain 5 - Context Management & Reliability"
)

# Look up the port for a given lecture key (e.g. "3.5" -> "3064").
# Prints empty string if the key is not in PORTS.
port_for() {
  local needle="$1"
  local entry
  for entry in "${PORTS[@]}"; do
    if [[ "${entry%%:*}" == "$needle" ]]; then
      echo "${entry##*:}"
      return 0
    fi
  done
  return 0
}

# Look up the section banner title for a given major number (e.g. "3").
title_for() {
  local needle="$1"
  local entry
  for entry in "${SECTION_TITLES[@]}"; do
    if [[ "${entry%%:*}" == "$needle" ]]; then
      echo "${entry#*:}"
      return 0
    fi
  done
  return 0
}

# Sorted lecture keys by (major, minor) so banners group correctly.
# Uses command substitution instead of mapfile (bash 4+).
KEYS=()
while IFS= read -r line; do
  KEYS+=("$line")
done < <(
  for entry in "${PORTS[@]}"; do
    echo "${entry%%:*}"
  done |
  awk -F. '{ printf "%d.%02d %s\n", $1, $2, $0 }' |
  sort |
  awk '{ print $2 }'
)

print_port_map() {
  local current_major=""
  echo ""
  echo "Claude Certified Architect - Foundations"
  echo "Slidev port map"
  echo "========================================"
  for key in "${KEYS[@]}"; do
    local major="${key%%.*}"
    if [[ "$major" != "$current_major" ]]; then
      current_major="$major"
      echo ""
      echo "$(title_for "$major")"
    fi
    printf "  [Section %s] lecture-%-5s -> http://localhost:%s\n" \
      "$major" "$key" "$(port_for "$key")"
  done
  echo ""
}

normalize_key() {
  # Accepts "3.5", "lecture-3.5", or "lecture-3.5.md" -> "3.5".
  local raw="$1"
  raw="${raw##*/}"
  raw="${raw#lecture-}"
  raw="${raw%.md}"
  echo "$raw"
}

check_port() {
  lsof -i ":$1" -t >/dev/null 2>&1
}

launch_one() {
  local key="$1"
  local port
  port="$(port_for "$key")"
  if [[ -z "$port" ]]; then
    echo "  X No port mapping for lecture-$key" >&2
    return 1
  fi
  local file="lecture-$key.md"
  if [[ ! -f "$file" ]]; then
    echo "  X Missing deck file: $file" >&2
    return 1
  fi
  if check_port "$port"; then
    echo "  ! Port $port already in use - skipping $file"
    return 0
  fi
  echo "  * $file -> http://localhost:$port"
  npx slidev "$file" --port "$port" &
}

launch_all() {
  local current_major=""
  echo ""
  echo "Claude Certified Architect - Foundations"
  echo "Launching ALL ${#PORTS[@]} decks. Ctrl+C stops them all."
  echo "========================================"
  for key in "${KEYS[@]}"; do
    local major="${key%%.*}"
    if [[ "$major" != "$current_major" ]]; then
      current_major="$major"
      echo ""
      echo "[$(title_for "$major")]"
    fi
    launch_one "$key"
  done
  echo ""
  echo "========================================"
  echo "All servers backgrounded. Ctrl+C to stop."
  wait
}

case "${1:-}" in
  "")
    print_port_map
    echo "Usage:"
    echo "  ./start-all.sh <lecture>   # e.g. ./start-all.sh 3.5"
    echo "  ./start-all.sh --all       # launch every deck (heavy)"
    echo "  ./start-all.sh --list      # print this port map"
    exit 0
    ;;
  --list|-l)
    print_port_map
    ;;
  --all|-a)
    launch_all
    ;;
  -h|--help)
    print_port_map
    echo "Usage:"
    echo "  ./start-all.sh <lecture>   # e.g. ./start-all.sh 3.5"
    echo "  ./start-all.sh --all       # launch every deck (heavy)"
    echo "  ./start-all.sh --list      # print this port map"
    ;;
  *)
    key=$(normalize_key "$1")
    echo ""
    echo "Launching lecture-$key"
    echo "========================================"
    launch_one "$key"
    wait
    ;;
esac
