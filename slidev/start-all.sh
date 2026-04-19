#!/bin/bash
# Launch all Slidev presentations for Claude Certified Architect course
# Usage: ./start-all.sh [section]
#   ./start-all.sh        → launch all sections
#   ./start-all.sh 1      → launch section 1 only (ports 3030-3035)
#   ./start-all.sh 2      → launch section 2 only (ports 3040-3050)
#   ./start-all.sh 3      → launch section 3 only (ports 3050-3063)

SECTION=${1:-"all"}

check_port() {
  lsof -i :$1 -t > /dev/null 2>&1
}

launch() {
  local file=$1
  local port=$2
  if check_port $port; then
    echo "  ⚠ Port $port in use — skipping $file"
  else
    npx slidev "$file" --port $port &
    echo "  ✓ $file → http://localhost:$port"
  fi
}

echo ""
echo "Claude Certified Architect – Foundations"
echo "Slidev Presentation Launcher"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$SECTION" == "all" || "$SECTION" == "1" ]]; then
  echo ""
  echo "Section 1: Course Introduction & Exam Strategy"
  launch "lecture-1.1.md" 3030
  launch "lecture-1.2.md" 3031
  launch "lecture-1.3.md" 3032
  launch "lecture-1.4.md" 3033
  launch "lecture-1.5.md" 3034
  launch "lecture-1.6.md" 3035
fi

if [[ "$SECTION" == "all" || "$SECTION" == "2" ]]; then
  echo ""
  echo "Section 2: Claude API Fundamentals Bootcamp"
  launch "lecture-2.1.md"  3040
  launch "lecture-2.2.md"  3041
  launch "lecture-2.3.md"  3042
  launch "lecture-2.4.md"  3043
  launch "lecture-2.5.md"  3044
  launch "lecture-2.6.md"  3045
  launch "lecture-2.7.md"  3046
  launch "lecture-2.8.md"  3047
  launch "lecture-2.9.md"  3048
  launch "lecture-2.10.md" 3049
  launch "lecture-2.11.md" 3050
fi

if [[ "$SECTION" == "all" || "$SECTION" == "3" ]]; then
  echo ""
  echo "Section 3: Domain 1 — Agentic Architecture & Orchestration"
  launch "lecture-3.1.md"  3050
  launch "lecture-3.2.md"  3051
  launch "lecture-3.3.md"  3052
  launch "lecture-3.4.md"  3053
  launch "lecture-3.5.md"  3054
  launch "lecture-3.6.md"  3055
  launch "lecture-3.7.md"  3056
  launch "lecture-3.8.md"  3057
  launch "lecture-3.9.md"  3058
  launch "lecture-3.10.md" 3059
  launch "lecture-3.11.md" 3060
  launch "lecture-3.12.md" 3061
  launch "lecture-3.13.md" 3062
  launch "lecture-3.14.md" 3063
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Press Ctrl+C to stop all servers"
echo ""
wait
