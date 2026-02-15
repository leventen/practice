---
name: audit-claude-md
description: Audits all CLAUDE.md files for redundant instructions, verbose phrasing, and content better stored in memory. Use when the user wants to optimize their CLAUDE.md files.
user-invocable: true
---

# Audit CLAUDE.md Files

Scan every CLAUDE.md file across the workspace, analyze each for inefficiencies, and present actionable findings.

## Steps

### 1. Discover all CLAUDE.md files

Search these locations in parallel using Glob:

- `~/.claude/CLAUDE.md` (user-level)
- `$PROJECT_DIR/CLAUDE.md` (project root)
- `$PROJECT_DIR/**/CLAUDE.md` (nested)
- `~/.claude/projects/**/CLAUDE.md` (project memory)

Also check for `CLAUDE.local.md` variants in the same locations.

If no CLAUDE.md files are found, tell the user and stop.

### 2. Read and measure each file

Read every discovered file. Record its path and line count.

### 3. Analyze for issues

For each file, check for these three categories:

**A. Redundant instructions**
- Rules that restate Claude's default behavior (e.g., "write clean code", "follow best practices")
- Duplicate rules that appear in multiple CLAUDE.md files saying the same thing
- Instructions that overlap with what a hook or skill already enforces

**B. Verbose phrasing**
- Multi-sentence rules that could be one line
- Explanatory paragraphs where a terse directive suffices
- Repeated qualifiers or filler words ("please make sure to always", "it is important that you")

**C. Memory candidates**
- Project-specific facts (tech stack, directory layout, key file paths) that rarely change -- these belong in project memory (`~/.claude/projects/...`) rather than in a repo-committed CLAUDE.md
- Personal preferences (formatting style, tone) that apply across projects -- these belong in `~/.claude/CLAUDE.md`
- Contextual notes that are session-specific and don't belong in any CLAUDE.md

### 4. Present findings

Print a summary grouped by file. For each file show:

```
### <file path> (<line count> lines)

**Redundant** (<count>)
- "<quoted text>" -- <reason it's redundant>

**Verbose** (<count>)
- "<quoted text>" → suggested rewrite: "<shorter version>"

**Memory candidates** (<count>)
- "<quoted text>" → move to: <destination path>
```

Omit any category with zero findings. End with a one-line total: e.g., "Found 12 issues across 3 files."

### 5. Ask the user

Use AskUserQuestion to ask:
> "Would you like me to implement these improvements?"

Options:
- "Apply all" -- apply every suggestion
- "Cherry-pick" -- walk through findings one by one
- "Skip" -- no changes

If the user selects "Apply all", make all edits and show a diff summary. If "Cherry-pick", present each finding and ask keep/fix before editing.
