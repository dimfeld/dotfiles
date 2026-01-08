---
description: Fix Merge Conflicts
argument-hint: [extra context]
---

The current repo status is:

!`jj status`

Examine the conflicts and make a todo list of conflicts to fix. 

For each conflict, examine each side and the commits lower in the commit tree that modified the lines to get the context for each one.  Unless there's an obvious merge, these conflicts were likely caused by rebasing this branch on top of another (likely main), and so the conflicting changes from the other branch are probably on "main" somewhere. 

If it is not clear to you how a conflict should be resolved, stop and ask me what to do, and I will try to provide guidance or resolve it myself. 

$ARGUMENTS
