---
description: Describe the changes in the branch.
allowed-tools: Bash(git log:*), Bash(git show:*), Bash(git diff:*), Bash(jj status:*), Bash(jj bookmark:*), Bash(jj commit:*), Bash(jj git push:*), Bash(jj log:*), Bash(jj diff:*), Bash(gh pr:*), Bash(tr:*)
---

This branch contains a pull request that has been implemented by another engineer. Describe the changes in it. 

List of files changed:

!`jj diff -f main -s | grep '^[MA]' | nl`

Group this list into chunks (by functional area if possible) and use parallel subagents to analyse the diffs, reading the files and also using `jj diff -f main <filename>` for each
one to get the diff. Make sure that every file is assigned to a chunk; we don't want to miss any files.

Make sure to go into detail about each file that has major changes related to the task and what changes are in those files. You can group files together if needed, but the report should be detailed enough that I should get a good idea of what changed without needing to look at the file myself.

You can omit files from the report if they only have minor changes such as adding a new member to an object whose type was updated or renaming functions and fields, but that is not really related to the task itself.

Generate your report using markdown with section headers.
