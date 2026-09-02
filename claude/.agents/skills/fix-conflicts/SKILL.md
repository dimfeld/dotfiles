---
name: fix-conflicts
description: Fix merge conflicts. Use when the current repository has unresolved conflicts and Codex should inspect both sides, trace the surrounding history, resolve the files carefully, and ask for help only when the correct resolution is unclear.
allowed-tools: Bash(jj status:*),Bash(jj log:*),Bash(jj diff:*),Bash(jj show:*),Read,Grep
---

The current repo status is:

!`jj status`

Examine the conflicts and make a todo list of conflicts to fix. The conflicts propagate upward, so you MUST start resolution at the
oldest commit and work upward from there.

For each conflict, examine each side and the commits lower in the commit tree that modified the lines to get the context for each one.  Unless there's an obvious merge, these conflicts were likely caused by rebasing this branch on top of another (likely main), and so the conflicting changes from the other branch are probably on "main" somewhere. 

Before you make an edit, describe your reasoning to the user. If it is not clear to you how a conflict should be resolved, stop and ask me what to do, and I will try to provide guidance or resolve it myself. 

## Modify-vs-delete conflicts

When jj reports "2-sided conflict including 1 deletion", be especially careful. The format is:

- `%%%%%%%` diff block = the side that **modified** the file (shows unchanged lines with ` ` prefix and changes with `+`/`-`)
- `+++++++` empty block = the side that **deleted** the file

The commit labels (`parents of rebased revision`, `rebased revision`, `rebase destination`) can be ambiguous. Do **not** assume the empty block is always "the other branch." Instead, reason from the PR/commit intent:

There are two cases — both require you to **find where the code moved** rather than blindly keeping or discarding the file:

### Case 1: Our branch deleted the file, main modified it

- If **our branch** is deleting the file (e.g. removing a tRPC module and replacing it with service functions), then the `%%%%%%%` block shows **main's modifications** and the empty `+++++++` is **our deletion**.
- Simply deleting the file is wrong if main added meaningful changes. Instead, **apply the substance of main's changes to wherever our branch moved the code** (e.g. the service file that replaced the deleted tRPC procedure).

### Case 2: Main deleted the file, our branch modified it

- If **main** deleted or restructured the file (e.g. migrating tRPC procedures to service functions), and **our branch** added changes to it, then the `%%%%%%%` block shows **our modifications** and the empty `+++++++` is **main's deletion**.
- Simply recreating the file is wrong — main deleted it intentionally. Instead, **find the service functions or new files that main introduced as replacements, and apply our changes there**.
- Verify by checking whether the file actually exists in the current repo state (e.g. `ls` the directory, `grep` for function names in the package's `src/services/`). If the directory the conflicted file lives in doesn't otherwise exist, that's a strong signal main deleted/moved the whole thing.

### General rule for both cases

When a file deletion conflict involves migrated code, always:
1. Check the repo structure to understand what replaced the deleted file.
2. Read the conflicted diff to understand exactly what changes need to be applied.
3. Apply those changes to the new location rather than restoring the old file.

## jj squash

When you use `jj squash` as part of this process, do not give it any arguments since the squash message will overwrite
the original commit message. When squashing, be very careful to not squash two pre-existing commits together. Only squash if
the "working copy" commit as shown by `jj status` is the new commit with "no description set".

