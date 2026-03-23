#!/bin/bash
set -eo pipefail

# Creates isolated planning files for a single PRD track.
# Usage: ./scripts/start-prd-track.sh <track-slug> [parent-prd-issue-number]

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <track-slug> [parent-prd-issue-number]"
  exit 1
fi

TRACK_SLUG="$1"
PARENT_PRD="${2:-}"
TRACK_DIR="plans/tracks/$TRACK_SLUG"

mkdir -p "$TRACK_DIR"

if [ ! -f "$TRACK_DIR/prd.md" ]; then
  cat > "$TRACK_DIR/prd.md" <<'EOF'
# PRD: <feature>

- Parent Issue: #<number>
- Owner:
- Status: draft

## Problem

## Solution

## User Stories

## Out of Scope
EOF
fi

if [ ! -f "$TRACK_DIR/plan.md" ]; then
  cat > "$TRACK_DIR/plan.md" <<'EOF'
# Plan: <feature>

## Phase 1
- [ ]

## Phase 2
- [ ]
EOF
fi

if [ ! -f "$TRACK_DIR/progress.txt" ]; then
  cat > "$TRACK_DIR/progress.txt" <<'EOF'
# Progress Log

- YYYY-MM-DD HH:MM: initialized track
EOF
fi

if [ -n "$PARENT_PRD" ]; then
  sed -i.bak "s/#<number>/#$PARENT_PRD/" "$TRACK_DIR/prd.md" && rm -f "$TRACK_DIR/prd.md.bak"
fi

echo "Track ready: $TRACK_DIR"
echo ""
echo "Suggested commands:"
echo "  RALPH_CONTEXT_FILES='@$TRACK_DIR/prd.md @$TRACK_DIR/plan.md @$TRACK_DIR/progress.txt' bash scripts/ralph-loop.sh 10"
if [ -n "$PARENT_PRD" ]; then
  echo "  RALPH_PARENT_PRD=$PARENT_PRD bash scripts/sandbox-loop.sh 10"
fi
