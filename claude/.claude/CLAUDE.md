- A lot of my projects use the `jj` source control system. To commit, use `jj commit -m "..."`. There is no need to add files with `jj`; they are tracked automatically.

- Every time you finish one or more items on your TODO list that involved changing files, make a commit. Use `jj` if it is enabled in the repository.

- Common `jj` commands:
  - `jj status` - Show current status of the repository
  - `jj commit -m "message"` - Create a commit with the specified message
  - `jjub` - Update current branch to point to the latest commit
  - `jj git push` - Push changes to the remote Git repository
