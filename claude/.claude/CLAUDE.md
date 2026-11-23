## General Rules

- When writing responses to the user, reviewing code, generating documentation, or otherwise writing text for humans to read, use ASD-STE100 Simplified Technical English.
- If you use `proofshot` or other tools, always check if the dev server is running first before you tell proofshot to
  run it, or deliberately choose a non-default port. Otherwise this interferes with the existing server and messes things up. Proofshot is also very bad at properly shutting down the
  dev servers that it starts.

## Source Control

- A lot of my projects use the `jj` source control system. To commit, use `jj commit -m "..."`. There is no need to add files with `jj`; they are tracked automatically.

- Every time you finish a user request, or one or more items on your TODO list that involved changing tracked files, make a commit. Use `jj` if it is enabled in the repository. 

- Don't add comments about generated with Claude or Co-Authored-By Claude when writing commit messages

- Common `jj` commands:
  - `jj status` - Show current status of the repository
  - `jj commit -m "message"` - Create a commit with the specified message (you do not need to "add" files first)
  - `jj git push` - Push changes to the remote Git repository

  Committing with `jj` creates a new empty commit on top. This is normal and does not need to be handled specially.

  When referencing specific files in jj commands, you need to escape brackets [ and ] with backslashes e.g. \\[ and \\].

- When using absolute paths, make sure to write `dimfeld` as the user name not `dimfield`

- When you encounter test failures, you must not `git stash` and then run again to see if they were pre-existing.

- Occasionally a `jj` command will fail to "acquire lock for index file". In this case do not try to delete the lock file, just try again and it should work.

- when creating a PR, use `jj diff non-test --stat -f BASE_REV` to get changed line counts for the PR. `non-test` is a
  special fileset I have defined.

- We have a jj revset `stack_base` which resolves to the commit that is the base of the current branch, whether stacked
  or on trunk. You can use this like `jj diff -f stack_base` or similar when you want to just get changes on the current branch.

## Linear Issues

When I ask you to create a Linear issue:

- Set the issue state to "Todo", unless I ask for a different state. Do not leave it in "Backlog" or "Triage".
- Always find and apply the correct metadata before you create the issue. Look up the available values in Linear first; do not guess.
  - **Team**: Use the team that owns the related work.
  - **Project**: Find the project that matches the work. Look at the existing projects and at similar recent issues. If no project clearly matches, pick the best match. Do not ask me.
  - **Labels**: Apply the labels that match the type and area of the work.
  - **Parent issue / milestone / cycle**: Apply these when the issue is clearly part of a larger issue, milestone, or the current cycle.
  - **Priority**: Set it if I state it or if the context makes it clear.
- After you create the issue, tell me which team, project, and other metadata you chose, so that I can change them if I do not agree.

## Removing Files

My `rm` command is aliased to `rm -i`. This means that you need to use `rm -f` to remove files.

