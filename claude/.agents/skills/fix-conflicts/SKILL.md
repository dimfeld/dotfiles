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

When you use `jj squash` as part of this process, do not give it any arguments since the squash message will overwrite
the original commit message.
