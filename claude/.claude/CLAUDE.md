## Source Control

- A lot of my projects use the `jj` source control system. To commit, use `jj commit -m "..."`. There is no need to add files with `jj`; they are tracked automatically.

- Every time you finish one or more items on your TODO list that involved changing files, make a commit. Use `jj` if it is enabled in the repository.

- Don't add comments about generated with Claude or Co-Authored-By Claude when writing commit messages

- Common `jj` commands:
  - `jj status` - Show current status of the repository
  - `jj commit -m "message"` - Create a commit with the specified message
  - `jj git push` - Push changes to the remote Git repository

- When using absolute paths, make sure to write `dimfeld` as the user name not `dimfield`

## Removing Files

My `rm` command is aliased to `rm -i`. This means that you need to use `rm -f` to remove files.
