---
name: fix-conflicts
description: Fix merge conflicts. Use when the current repository has unresolved conflicts and Codex should inspect both sides, trace the surrounding history, resolve the files carefully, and ask for help only when the correct resolution is unclear.
allowed-tools: Bash(jj status:*),Bash(jj log:*),Bash(jj diff:*),Bash(jj show:*),Read,Grep
---

The current repo status is:

!`jj status`

Examine the conflicts and make a todo list of conflicts to fix. 

For each conflict, examine each side and the commits lower in the commit tree that modified the lines to get the context for each one.  Unless there's an obvious merge, these conflicts were likely caused by rebasing this branch on top of another (likely main), and so the conflicting changes from the other branch are probably on "main" somewhere. 

As you make edits, describe your reasoning. If it is not clear to you how a conflict should be resolved, stop and ask me what to do, and I will try to provide guidance or resolve it myself. 

## Modify-vs-delete conflicts

When jj reports "2-sided conflict including 1 deletion", be especially careful. The format is:

- `%%%%%%%` diff block = the side that **modified** the file (shows unchanged lines with ` ` prefix and changes with `+`/`-`)
- `+++++++` empty block = the side that **deleted** the file

The commit labels (`parents of rebased revision`, `rebased revision`, `rebase destination`) can be ambiguous. Do **not** assume the empty block is always "the other branch." Instead, reason from the PR/commit intent:

- If **our branch** is deleting the file (e.g. removing a tRPC module), then the `%%%%%%%` block is showing **main's modifications** and the empty `+++++++` is **our deletion**.
- In this case, simply deleting the file is wrong if main added meaningful changes. Instead, **apply the substance of main's changes to wherever our branch moved the code** (e.g. the service file that replaced the deleted tRPC procedure).

When a file deletion conflict involves migrated code, always check git history to see what the other side changed in that file, then apply those changes to the new location.

## jj squash

When you use `jj squash` as part of this process, do not give it any arguments since the squash message will overwrite
the original commit message.
