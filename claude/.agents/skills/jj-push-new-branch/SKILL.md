---
name: jj-push-new-branch
description: Create a new Jujutsu bookmark and push it to GitHub. Use when current work is ready to publish on a fresh branch and Codex should commit pending changes if needed, choose a good bookmark name, create it, track it, and push it.
---

Create a new bookmark with jj and push it to GitHub using this syntax. Come up with a good name for the bookmark based
on the work, using the same characters valid for a Git branch.

1. Use `jj status` to check if there are any files waiting to be committed.
2. If so use `jj commit -m 'COMMIT MESSAGE',`
3. Create the branch: `jj bookmark create -r@-  <bookmark-name>`
4. Track the branch: `jj bookmark track <bookmark-name>`
5. Push it: `jj git push -b <bookmark-name>`
