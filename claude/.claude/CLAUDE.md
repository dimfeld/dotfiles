## General Rules

- When writing responses to the user, reviewing code, generating documentation, or otherwise writing text for humans to read, use ASD-STE100 Simplified Technical English.

## Source Control

- A lot of my projects use the `jj` source control system. To commit, use `jj commit -m "..."`. There is no need to add files with `jj`; they are tracked automatically.

- Every time you finish a user request, or one or more items on your TODO list that involved changing files, make a commit. Use `jj` if it is enabled in the repository.

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

## Removing Files

My `rm` command is aliased to `rm -i`. This means that you need to use `rm -f` to remove files.
