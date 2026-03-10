#!/bin/bash
input=$(cat)

ESC=$'\033'
RESET="${ESC}[0m"
CYAN="${ESC}[36m"
GRAY="${ESC}[90m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
PURPLE="${ESC}[35m"

# Extract context usage
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Git branch
BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
fi

# PR info for current branch (cached per branch, refreshed every 60s)
PR_URL=""
PR_STATUS=""
PR_TITLE=""
if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
  CACHE_DIR="/tmp/claude-statusline-cache"
  mkdir -p "$CACHE_DIR"
  CACHE_FILE="$CACHE_DIR/$(echo "$BRANCH" | tr '/' '_')"

  if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt 60 ]; then
    PR_DATA=$(cat "$CACHE_FILE")
  else
    PR_DATA=$(timeout 3 gh pr view "$BRANCH" --json url,state,title,statusCheckRollup,comments \
      -q '{url: .url, state: .state, title: .title, checks: ([.statusCheckRollup[]? | select(.status == "COMPLETED" and .conclusion == "FAILURE")] | length), pending: ([.statusCheckRollup[]? | select(.status != "COMPLETED")] | length), total: ([.statusCheckRollup[]?] | length), lgtm: ([.comments[]? | select(.body | test("\\bLGTM\\b"; "i"))] | length)}' 2>/dev/null || echo "")
    echo "$PR_DATA" > "$CACHE_FILE"
  fi

  if [ -n "$PR_DATA" ]; then
    PR_URL=$(echo "$PR_DATA" | jq -r '.url // empty' 2>/dev/null)
    PR_TITLE=$(echo "$PR_DATA" | jq -r '.title // empty' 2>/dev/null)
    STATE=$(echo "$PR_DATA" | jq -r '.state // empty' 2>/dev/null)
    FAILED=$(echo "$PR_DATA" | jq -r '.checks // 0' 2>/dev/null)
    PENDING=$(echo "$PR_DATA" | jq -r '.pending // 0' 2>/dev/null)
    TOTAL=$(echo "$PR_DATA" | jq -r '.total // 0' 2>/dev/null)
    LGTM=$(echo "$PR_DATA" | jq -r '.lgtm // 0' 2>/dev/null)

    if [ "$STATE" = "MERGED" ]; then
      PR_STATUS=" ${PURPLE}MERGED${RESET}"
    elif [ "$STATE" = "CLOSED" ]; then
      PR_STATUS=" ${GRAY}CLOSED${RESET}"
    elif [ "$FAILED" -gt 0 ] 2>/dev/null; then
      PR_STATUS=" ${RED}${FAILED}/${TOTAL} failed${RESET}"
    elif [ "$PENDING" -gt 0 ] 2>/dev/null; then
      PR_STATUS=" ${YELLOW}${PENDING}/${TOTAL} pending${RESET}"
    elif [ "$TOTAL" -gt 0 ] 2>/dev/null; then
      PR_STATUS=" ${GREEN}${TOTAL}/${TOTAL} passed${RESET}"
    fi

    if [ "$STATE" = "OPEN" ] && [ "$LGTM" -gt 0 ] 2>/dev/null; then
      PR_STATUS="${PR_STATUS} ${GREEN}LGTM${RESET}"
    fi
  fi
fi

# Build output
if [ -n "$BRANCH" ]; then
  echo "${CYAN}${BRANCH}${RESET} ${GRAY}|${RESET} ctx ${PCT}%"
  if [ -n "$PR_URL" ]; then
    echo "${PR_URL}${PR_STATUS}"
    if [ -n "$PR_TITLE" ]; then
      echo "${GRAY}${PR_TITLE}${RESET}"
    fi
  fi
else
  echo "ctx ${PCT}%"
fi
