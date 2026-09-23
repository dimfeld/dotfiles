---
name: continue-progress
description: Read current_progress.md and continue from there. Use when a project has a `current_progress.md` checkpoint and Codex should restore the saved context, resume the next steps, and keep the file updated while working.
disable-model-invocation: true
---

Read `current_progress.md` in the project root and continue the work from where it was left off. Restore its todo list if it has one, and start from the first item in its "Next Steps" section.

If the file doesn't exist, inform the user and ask what task they'd like to work on.

When continuing, acknowledge:
- What was previously accomplished
- What you're about to work on next
- Any important context you're carrying forward

Then proceed with the work without requiring additional confirmation unless there are ambiguities or decisions to be made. Update the file as you go too.
