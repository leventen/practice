---
name: session-review
description: Reviews the current conversation transcript to extract learning opportunities, skill ideas, and improvement suggestions from tasks performed, errors encountered, and user feedback. Use when the user wants to reflect on the session or capture reusable patterns.
user-invocable: true
---

# Session Review

Analyze the current session transcript for actionable insights, then let the user decide what to persist.

## Steps

### 1. Locate and read the transcript

Read the session transcript. The path is available via the `transcript_path` field in hook input, but since this skill runs inside a conversation, use the Bash tool to find the most recent transcript:

```
ls -t ~/.claude/projects/*//*.jsonl | head -1
```

Read the file. It is JSONL (one JSON object per line). Key fields per line:
- `type`: `"user"`, `"assistant"`, or `"queue-operation"`
- `message.role`: `"user"` or `"assistant"`
- `message.content`: array of content blocks; each block has a `type` (`"text"`, `"tool_use"`, `"tool_result"`, `"thinking"`)
- For `tool_use` blocks: `name` (tool name), `input` (arguments)
- For `tool_result` blocks: `content` (result text), `is_error` (boolean)

Since transcripts can be large, use Bash with `wc -l` first. If over 500 lines, process in chunks of 200 lines using `sed -n 'START,ENDp'`.

### 2. Extract signals

Scan the transcript for five signal types:

**A. Errors and retries**
- `tool_result` blocks where `is_error` is true or content contains error/failure messages
- Sequences where the same tool was called multiple times on the same target (retry pattern)
- Note: what went wrong, how it was resolved (or wasn't)

**B. User corrections**
- User messages that redirect, correct, or clarify a previous action
- Phrases like "no", "that's wrong", "I meant", "not that", "instead", "actually"
- Note: what was misunderstood and what the correct behavior was

**C. Repeated patterns**
- Tool call sequences that appear 3+ times (e.g., Glob → Read → Edit)
- Similar prompts or tasks that share structure
- Note: the pattern and how many times it occurred

**D. Complex multi-step tasks**
- Sequences of 5+ tool calls to accomplish a single logical goal
- Note: what the goal was and the steps taken

**E. Knowledge discovered**
- Project facts learned during the session (file paths, conventions, architecture)
- Preferences expressed by the user (formatting, workflow, tool choices)
- Note: the fact and where it was learned

### 3. Classify opportunities

From the extracted signals, derive three types of opportunities:

| Type | Source signals | Output |
|------|---------------|--------|
| **Memory entry** | User corrections, knowledge discovered, preferences | A concise line to add to CLAUDE.md or project memory |
| **New skill idea** | Repeated patterns, complex multi-step tasks | Name, trigger description, and rough steps |
| **Existing skill/hook improvement** | Errors, retries, user corrections related to hook/skill behavior | Which skill/hook and what to change |

### 4. Present findings

Print findings grouped by type. Be concise -- one or two lines per item.

```
## Session Review

### Memory entries (<count>)
1. "<proposed memory line>" — source: <brief context>
2. ...

### Skill ideas (<count>)
1. **<skill-name>**: <one-line description> — triggered by: <pattern seen N times>
2. ...

### Improvements (<count>)
1. **<skill/hook name>**: <what to change> — reason: <brief context>
2. ...
```

Omit any section with zero findings. If nothing was found, say so and suggest the user invoke this after a longer or more varied session.

### 5. Ask the user

Use AskUserQuestion to ask:
> "Which findings would you like me to implement?"

Options:
- "All memory entries" — write all proposed lines to the appropriate CLAUDE.md / project memory
- "All skill ideas" — scaffold SKILL.md files for each proposed skill
- "Cherry-pick" — walk through each finding individually
- "Export only" — write findings to a markdown file without applying changes

If the user chooses an implementation option, execute it: write memory entries to the correct CLAUDE.md file, create skill stubs, or edit existing skills/hooks as appropriate. Commit the changes when done.
