#!/usr/bin/env bash
# UserPromptSubmit hook: If 8+ tool calls in session, append one optimization hint.
# Skips if the prompt appears exploratory.
set -euo pipefail

INPUT=$(cat /dev/stdin)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Skip if no transcript available
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  exit 0
fi

# Skip if prompt is exploratory (questions, investigation, understanding)
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')
if echo "$PROMPT_LOWER" | grep -qiE '(^(what|how|why|where|when|who|which|explain|describe|show me|tell me|can you explain|walk me through|help me understand)|explore|investigate|look into|understand|learn about|curious|familiarize|overview|summarize|reading|research|\?)'; then
  exit 0
fi

# Count tool_use blocks in the transcript
TOOL_CALLS=$(grep -c '"tool_use"' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# Only hint if 8+ tool calls
if [[ "$TOOL_CALLS" -lt 8 ]]; then
  exit 0
fi

# Pick one hint based on tool call count to rotate through hints
HINTS=(
  "Consider saving this multi-step pattern as a reusable Claude Code skill via /skill so you can invoke it in one command next time."
  "If you keep referencing the same files or context, add a CLAUDE.md memory entry so future sessions start with that knowledge."
  "Batch independent tool calls into parallel invocations to cut round-trips and speed up repetitive workflows."
  "Extract repeated search-then-edit sequences into a single script or hook to reduce manual orchestration overhead."
  "Use a project-level CLAUDE.md to document conventions so Claude doesn't re-discover them each session."
  "If this task recurs, create a slash-command skill that encapsulates the steps into a single invocable workflow."
)

INDEX=$(( TOOL_CALLS % ${#HINTS[@]} ))
HINT="${HINTS[$INDEX]}"

# Output additional context
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Optimization hint: $HINT"
  }
}
EOF
