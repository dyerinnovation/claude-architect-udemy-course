#!/bin/bash
# Slidev launcher for the Claude Certified Architect course.
#
# Usage:
#   ./start-all.sh <section>       → launch ONE deck on its mapped port
#                                     e.g. ./start-all.sh 3
#                                          ./start-all.sh section-3
#                                          ./start-all.sh section-3.md
#                                          ./start-all.sh s3
#   ./start-all.sh --all            → launch ALL decks simultaneously
#                                     (7 Vite servers; most laptops handle this)
#   ./start-all.sh --list           → print the full port map and exit
#   ./start-all.sh                  → show help + port map
#
# Default is one-at-a-time. Use `npm run dev:N` if you prefer package.json
# scripts.
#
# Port map:
#   Section 1 → 3030
#   Section 2 → 3040
#   Section 3 → 3050
#   Section 4 → 3060
#   Section 5 → 3070
#   Section 6 → 3080
#   Section 7 → 3090
#
# Implementation note: this script targets macOS's system bash (3.2.57), so
# it uses indexed arrays of "key:value" strings instead of `declare -A`
# associative arrays (which require bash 4+).

set -euo pipefail

cd "$(dirname "$0")"

# Indexed array of "section:port" pairs. Parse with ${entry%%:*} / ${entry##*:}.
PORTS=(
  "1:3030"
  "2:3040"
  "3:3050"
  "4:3060"
  "5:3070"
  "6:3080"
  "7:3090"
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

# Look up the port for a given section key (e.g. "3" -> "3050").
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

# Sorted section keys so banners print in order.
# Uses command substitution instead of mapfile (bash 4+).
KEYS=()
while IFS= read -r line; do
  KEYS+=("$line")
done < <(
  for entry in "${PORTS[@]}"; do
    echo "${entry%%:*}"
  done | sort -n
)

print_port_map() {
  echo ""
  echo "Claude Certified Architect - Foundations"
  echo "Slidev port map"
  echo "========================================"
  for key in "${KEYS[@]}"; do
    echo ""
    echo "$(title_for "$key")"
    printf "  [Section %s] section-%-1s -> http://localhost:%s\n" \
      "$key" "$key" "$(port_for "$key")"
  done
  echo ""
}

normalize_key() {
  # Accepts "3", "s3", "section-3", or "section-3.md" -> "3".
  local raw="$1"
  raw="${raw##*/}"
  raw="${raw#section-}"
  raw="${raw#s}"
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
    echo "  X No port mapping for section-$key" >&2
    return 1
  fi
  local file="section-$key.md"
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
  echo ""
  echo "Claude Certified Architect - Foundations"
  echo "Launching ALL ${#PORTS[@]} decks. Ctrl+C stops them all."
  echo "========================================"
  for key in "${KEYS[@]}"; do
    echo ""
    echo "[$(title_for "$key")]"
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
    echo "  ./start-all.sh <section>   # e.g. ./start-all.sh 3"
    echo "  ./start-all.sh --all       # launch every deck"
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
    echo "  ./start-all.sh <section>   # e.g. ./start-all.sh 3"
    echo "  ./start-all.sh --all       # launch every deck"
    echo "  ./start-all.sh --list      # print this port map"
    ;;
  *)
    key=$(normalize_key "$1")
    echo ""
    echo "Launching section-$key"
    echo "========================================"
    launch_one "$key"
    wait
    ;;
esac
