---
name: create-pr-review-from-comments
description: Converts "AI" comments in local files into Github PR review comments
allowedTools: Bash(bun ~/.claude/skills/pr-review-from-comments/scripts/:*)
---

Find the current jj branch name using: `jj log -r 'latest(heads(ancestors(@) & remote_bookmarks()), 1)' --limit 1 --no-graph -T bookmarks | tr -d '*' | sed 's/@origin$//'`

Then use `gh pr list --head <branch-name>` to get the number of the PR.

Run the extract_comments.ts script to find all AI comments in modified files:

```bash
bun ~/.claude/skills/pr-review-from-comments/scripts/extract_comments.ts
```

This script will output each comment with:
- File path
- Comment type (single, block_start, block_end)
- The comment line number in the edited file
- The comment text
- The adjacent original line number and content (the line the comment refers to)

Use the "Adjacent Original Line" number as the `line` field in the Comment structure. For block comments (AI_COMMENT_START/AI_COMMENT_END pairs), use the block_start's adjacent line as `startLine` and the block_end's adjacent line as `line`.

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

Once you have that, read the files and relevant surrounding lines to ensure you have the full context of each comment.

After extracting comments, display them and ask if the user wants to:
- set a particular status value
- modify the comments

Finally, separately ask for a review body (main message) to be included with the review.

Generate an object of type Input, save it as JSON to a temporary file, and pass it to scripts/create_review.ts.

```bash
GITHUB_TOKEN=$(gh auth token) bun ~/.claude/skills/pr-review-from-comments/scripts/create_review.ts <tempfile>
```
