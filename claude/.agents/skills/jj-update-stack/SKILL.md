---
name: jj-update-stack
description: Rebase and repair stacked branches in a Jujutsu (jj) repository after the current base branch has been updated. Use when the user says they are on an updated base branch and need to update, rebase, evolve, resolve conflicts in, validate, or adapt all child/stacked jj branches on top of it.
allowed-tools: Bash(jj status:*),Bash(jj log:*),Bash(jj diff:*),Bash(jj commit:*),Bash(jj rebase:*),Bash(jj edit:*),Bash(jj bookmark list)
---

# JJ Update Stack

## Overview

Use this workflow to update every branch stacked above the current jj commit after the base has changed. Treat each branch as a reviewable unit: rebase it, resolve conflicts, adapt its code to the new base, validate it, and commit before moving to the next branch.

## Ground Rules

- Start from the user's current checkout unless they explicitly identify another base.
- Use `jj` commands, not git commands, for stack operations.
- Never discard or rewrite user changes you did not create.
- Resolve conflicts by understanding both sides of the change; do not mechanically choose one side.
- After changing files for a branch, run focused validation and commit with `jj commit -m "..."` before continuing.
- If a command reports an index lock error, retry the same command once before escalating.
- If branch order, intended stack shape, or conflict semantics are unclear, inspect history first; ask only when the correct resolution cannot be inferred.

## Discover The Stack

1. Check repository state:

   ```bash
   jj status
   jj log -r '::@ | @::' --limit 80
   ```

2. Identify stacked descendants of the current base:

   ```bash
   jj log -r 'all:@::' --limit 80
   ```

3. Identify bookmarks and review branch names:

   ```bash
   jj bookmark list
   ```

4. Build an ordered todo list from nearest child to furthest descendant. If multiple children fork from the base, preserve existing topology and process one chain at a time.

## Rebase Each Branch

For each branch or bookmark in stack order:

1. Move to the branch head:

   ```bash
   jj edit <rev-or-bookmark>
   ```

2. Rebase the branch onto its updated parent. Use the narrowest operation that matches the stack shape:

   ```bash
   jj rebase -r <rev> -d <new-parent>
   ```

   For an entire descendant chain that should move together:

   ```bash
   jj rebase -s <stack-root> -d <new-parent>
   ```

3. Inspect the result:

   ```bash
   jj status
   jj log -r '<new-parent>::@' --limit 40
   jj diff
   ```

## Resolve Conflicts

When conflicts appear:

1. List conflicted files with `jj status`.
2. Read each conflicted file and nearby related code before editing.
3. Inspect both sides when needed:

   ```bash
   jj diff -r <parent>..<conflicted-rev>
   jj show <conflicted-rev>
   ```

4. Edit files to preserve the intended behavior from the branch while integrating base changes.
5. Run `jj status` until conflicts are gone.
6. Run focused tests or checks for the touched package before committing.

Do not continue to the next stacked branch with unresolved conflicts.

## Adapt To Base Changes

After a clean rebase, check whether the base update changed APIs, schema, generated types, permissions, tests, or UI behavior that the branch depends on.

Use code search for renamed symbols, changed imports, moved files, and updated service contracts. Prefer local package docs and existing patterns over inventing new integration code. If the repository has task-specific rules, follow them before editing.

## Validate Per Branch

Choose the smallest validation set that proves the branch still works:

- Run package-level tests for changed backend logic.
- Run type checks or lint checks when imports, types, Svelte components, or package boundaries changed.
- Use browser or end-to-end checks for UI behavior that cannot be validated by curl or unit tests.
- Re-run failing checks after fixes. Do not stash user changes to test a "clean" tree.

Record commands run and their outcomes for the final response.

## Commit And Continue

After each branch is rebased, adapted, and validated:

1. Review what changed:

   ```bash
   jj diff
   jj status
   ```

2. Commit the completed branch work:

   ```bash
   jj commit -m "Update <branch-name> for new base"
   ```

3. Move to the next descendant branch and repeat the workflow.

Do not push to git, the user will do that manually after the process is done.

## Final Report

Summarize:

- Which stack branches were rebased.
- Conflicts resolved and important adaptations made.
- Validation commands run and whether they passed.
- Any branch that still needs user input, with the exact file or decision blocking progress.
