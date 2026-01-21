---
description: Generate a PR review guide
allowed-tools: Bash(git log:*), Bash(git show:*), Bash(git diff:*), Bash(jj status:*), Bash(jj bookmark:*), Bash(jj commit:*), Bash(jj git push:*), Bash(jj log:*), Bash(jj diff:*), Bash(gh pr:*), Bash(tr:*)
argument-hide: [extra context]
---

This branch contains a pull request that has been implemented by another engineer. I now need to review those changes.

Here is the list of files changed:

!`jj diff -f 'heads(::@ & ::main)' -s | grep '^[MA]' | nl`

Group this list into chunks (by functional area if possible) and use parallel subagents to analyse the diffs, reading the files and also using `jj diff -f 'heads(::@ & ::main)' <filename>` for each
one to get the diff. Make sure that every file is assigned to a chunk; we don't want to miss any files. Ignore any
comments starting with AI: or AI_COMMENT_START; those are pending review comments I added.

Make sure to go into detail about each file that has major changes related to the task and what changes are in those files. You can group files together if needed, but the report should be detailed enough that I should get a good idea of what changed without needing to look at the file myself.

Once you have the diffs, generate a guide to help me walk through the pull request, grouping the files into functional areas and noting which are major parts of the change and which are perfunctory changes such as just adding a new member to an object whose type was updated or renaming functions and fields. The guide should be able to walk me step by step through reviewing the changes.

Generate your report using markdown with section headers.

$ARGUMENTS

1. Once you have this guide generated, also write it to `review-guide.md`. 
2. Then go through the guide you just wrote and perform your own review of the changes and add any comments to `review-guide.md`.
3. Finally, look through the codebase to see what might have been missed or that doesn't follow best practices or existing patterns. Write any additional comments to `review-guide.md`.
