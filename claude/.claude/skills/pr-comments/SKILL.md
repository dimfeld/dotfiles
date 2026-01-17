---
name: pr-review-from-comments
description: Converts "AI" comments in local files into Github PR review comments
---

Find the current jj branch name using: `jj log -r 'latest(heads(ancestors(@) & bookmarks()), 1)' --limit 1 --no-graph -T local_bookmarks | tr -d '*'`

Then use `gh pr list --head <branch-name>` to get the number of the PR.

Use `jj status` to see what files have changes in them.


```
interface Comment {
  file: string;
  startLine?: number;
  line: number
  text: string;
}

interface Input {
  pr: number;
  status?: 'comment' | 'requestChanges' | 'approve';
  body: string;
  comments: Comment[];
}
```

Find all files that have "AI:" comments or AI_COMMENT_START and AI_COMMENT_END comment blocks in them. Extract the comments into an array of Comment structures.

When calculating line numbers, account for the actual line numbers without the comments. It may help to run `jj diff
--color-words` on the files to get the original line numbers.

After you've done that, display the comments and ask if the user wants to modify them or if they want to set a particular status value. If there's a review body they want to provide.

Generate a type of type input, save it as JSON to a temporary file, and pass it to scripts/create_review.ts.

```bash
GITHUB_TOKEN=$(gh auth token) bun scripts/create_review.ts <tempfile>
```
