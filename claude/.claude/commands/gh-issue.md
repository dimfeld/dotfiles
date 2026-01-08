---
description: Address an issue on github
argument-hint: <issue-number>
allowed-tools: Bash(gh issue view:*)
---

This github issue needs to be addressed: 

!`gh issue view $ARGUMENTS --json body,comments`

The above is the entire issue contents and comments. No need to fetch it again.

Enter plan mode to create a plan to address this issue.
