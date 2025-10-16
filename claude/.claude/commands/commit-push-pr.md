---
description: Commit changes, push to remote, and create a PR
allowed-tools: Bash(jj status:*), Bash(jj bookmark:*), Bash(jj commit:*), Bash(jj git push:*), Bash(jj log:*), Bash(jj diff:*), Bash(gh pr:*), Bash(tr:*)
argument-hint: [commit message context]
---

Please do the following:

## Step 1: Examine Repository State

First, understand the current state of the repository:

1a. Check the working copy status:
   ```bash
   jj status
   ```

1b. Check current commit and branch:
   ```bash
   jj log -r @ -n 1
   ```

1c. Get the current bookmark/branch name:
   ```bash
   jj log -r 'latest(heads(ancestors(@) & bookmarks()), 1)' --limit 1 --no-graph -T local_bookmarks | tr -d '*'
   ```
   - This command finds the bookmark associated with the current working copy's ancestors
   - Store this as `<branch-name>` for use in subsequent steps
   - If empty, you may need to create a bookmark first with `jj bookmark create <name>`

1e. View the commit history on the branch (replace `<branch-name>` with the actual branch):
   ```bash
   jj log -r 'main..<branch-name>' --summary
   ```

## Step 2: Review Changes

2a. Take a diff against the base branch using `jj diff -r <base-branch>..<branch-name>`. If not otherwise specified below, the base branch is `main`.

2b. Review the changes to understand what will be included in the PR.

## Step 3: Commit New Changes (if needed)

3a. If there are uncommitted changes in the working copy (not already committed to the branch), create a commit using `jj commit -m` with an appropriate commit message that:
   - Has a concise subject line describing the changes
   - Includes bullet points explaining what was added/changed
   - Does not include "Generated with Claude Code" or "Co-Authored-By" lines

3b. If all changes are already committed on the branch, proceed to step 4.

## Step 4: Push Changes

4. Push the changes using:
   ```bash
   jj bookmark track <branch-name>@origin && jj git push --branch <branch-name>
   ```

## Step 5: Create or Update Pull Request

5a. Check if a pull request already exists:
   ```bash
   gh pr list --head <branch-name>
   ```

5b. If a PR exists, use `gh pr edit` to update the title and body if they are out of date. If the PR does not
have a body you must add one using the guidelines below.

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
