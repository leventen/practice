---
name: list-skills
description: Lists all installed Claude Code skills and hooks (project & global) with line counts, then offers to review any for improvement opportunities.
user-invocable: true
---

# List Skills

Enumerate every installed skill and hook across global and project scopes, display them with line counts, then let the user pick one to review.

## Steps

### 1. Discover files

Scan these locations for skills and hooks:

| Scope   | Path pattern                              |
|---------|-------------------------------------------|
| Global  | `~/.claude/skills/*/SKILL.md`             |
| Global  | `~/.claude/hooks/*.sh`                    |
| Global  | `~/.claude/stop-hook-git-check.sh` (legacy location) |
| Project | `.claude/skills/*/SKILL.md`               |
| Project | `.claude/hooks/*.sh`                      |

Use Glob to find all matching files. Run the global and project searches in parallel.

### 2. Count lines

For every file found, count its total lines using `wc -l` via Bash (batch all files in one command).

### 3. Display table

Print a markdown table to the user with these columns:

| # | Scope | Type | Name | Lines |
|---|-------|------|------|-------|

- **Scope**: `global` or `project`
- **Type**: `skill` or `hook`
- **Name**: directory name for skills, filename for hooks
- **Lines**: line count

Sort by scope (global first), then type (skills first), then name alphabetically.

### 4. Ask user which to review

Use AskUserQuestion to ask:
> "Which item would you like to review for improvement opportunities?"

Provide each item name as an option (up to 4; if more than 4, list the 4 largest by line count and let "Other" cover the rest).

### 5. Review the chosen item

Read the selected file and analyze it for:

- **Conciseness**: Can any section be shortened without losing meaning?
- **Clarity**: Are instructions ambiguous or hard to follow?
- **Overlapping scopes**: Does this duplicate logic found in another skill or hook?
- **Token efficiency**: Are there verbose patterns that inflate prompt token cost (e.g., redundant examples, excessive comments)?

Present findings as a short bulleted list and offer concrete one-line suggestions. Do NOT make changes unless the user asks.
