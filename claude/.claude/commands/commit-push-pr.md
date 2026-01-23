---
description: Commit changes, push to remote, and create a PR
allowed-tools: Bash(jj status:*), Bash(jj bookmark:*), Bash(jj commit:*), Bash(jj git push:*), Bash(jj log:*), Bash(jj diff:*), Bash(gh pr:*), Bash(tr:*)
argument-hint: [commit message context]
---

Please do the following:

## Step 1: Examine Repository State

First, understand the current state of the repository:

1a. Working copy status:

!`jj status`

1b. Current commit and branch:

!`jj log -r @ -n 1`

1c. The current bookmark/branch name is: !`jj log -r 'latest(heads(ancestors(@) & bookmarks()), 1)' --limit 1 --no-graph -T local_bookmarks | tr -d '*'`
 
   - Store this as `<branch-name>` for use in subsequent steps
   - If empty or "main" or another reserved value, you may need to create a bookmark first with `jj bookmark create <name>`

1d. The commit history on the branch:

!`jj log -r 'main::@' --summary`

## Step 2: Review Changes

If you have just generated a detailed summary of the branch, then skip this step and use the summary verbatim. Otherwise:

The files that will be included in the PR are:

!`jj diff -f main -s | grep '^[MA]' | nl`

Group this list into chunks (by functional area if possible) and use parallel subagents to analyse the diffs, reading the files and also using `jj diff -f main <filename>` for each
one to get the diff. Make sure that every file is assigned to a chunk; we don't want to miss any files.

Make sure to go into detail about each file that has major changes related to the task and what changes are in those files.

## Step 3: Commit New Changes (if needed)

3a. If there are uncommitted changes in the working copy (not already committed to the branch), create a commit using `jj commit -m` with an appropriate commit message that:
   - Has a concise subject line describing the changes
   - Includes bullet points explaining what was added/changed
   - Does not include "Generated with Claude Code" or "Co-Authored-By" lines

3b. If all changes are already committed on the branch, proceed to step 4.


## Step 4: Push Changes

4. Push the changes using:
   ```bash
   jj bookmark track <branch-name> --remote origin && jj git push --branch <branch-name>
   ```

## Step 5: Create or Update Pull Request

5a. Check if a pull request already exists:
   ```bash
   gh pr list --head <branch-name>
   ```

5b. If a PR exists, use `gh pr view` to read the existing PR, and then `gh pr edit` to update the title and body if they are out of date. If the PR does not
have a body you must add one using the guidelines below. If it does have a body, make sure to preserve any tags about
closing issues.

5c. Otherwise create a draft pull request using `gh pr create --draft --head <branch-name> --base main` with:
   - A clear title summarizing the change
   - A body that includes:
     - Summary section with bullet points
     - Changes section listing what was modified
     - Test plan section with checkboxes for manual testing steps
     - Mark automated tests as checked if they've passed
   - Note that commits marked "Finish batch tasks iteration" are just related to updating planning documents, not actual code changes

## Notes

- If a pull request already exists, update the PR instead of creating a new one
- Use the identified branch name from step 1 as `<branch-name>` throughout
- The branch may contain multiple commits - review the full history with `jj log` before creating the PR
- The base branch is main by default and in the above examples, but use a different branch if there are instructions below that indicate a different base branch.

$ARGUMENTS
