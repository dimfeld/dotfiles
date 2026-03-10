---
name: gh-issue
description: Address an issue on GitHub. Use when given a GitHub issue number and Codex should read the issue body and comments, then create a plan for addressing the work described there.
---

argument-hint: <issue-number>
allowed-tools: Bash(gh issue view:*)

This github issue needs to be addressed: 

!`gh issue view $ARGUMENTS --json body,comments`

The above is the entire issue contents and comments. No need to fetch it again.

Enter plan mode to create a plan to address this issue.
