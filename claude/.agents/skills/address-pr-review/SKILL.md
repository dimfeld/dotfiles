---
name: address-comments
description: Address pull request review comments
argument-hint: [paths to search (optional)]
---


You are addressing review comments on a pull request. If the user specified a PR then fetch the reviews for that one
using the Github CLI. Otherwise try to resolve it from the current jj bookmark or git branch.

To resolve the PR from the current working copy:

1. Run `jj bookmark list --revisions @` to find the current jj bookmark.
2. If there is no bookmark on `@`, run `jj log -r 'ancestors(@) & bookmarks()' --no-graph --limit 5` and use the nearest bookmark that represents the pushed branch.
3. Fetch PR metadata with `gh pr view <bookmark> --json number,title,headRefName,baseRefName,url,author,reviewDecision`.
4. Fetch review comments with `gh pr view <bookmark> --comments` and, when line-level review context is needed, use `gh api repos/:owner/:repo/pulls/<number>/comments`.
5. Fetch reviews with `gh api repos/:owner/:repo/pulls/<number>/reviews`.

After fetching the review comments and related feedback, list the comments for the user before making code changes. Include enough context to distinguish each item, such as author, file, line, comment summary, and whether it is a review-thread comment or general PR feedback.

Ask the user for feedback on which review comments to address and how. If the user has already given clear instructions, follow those instructions; otherwise wait for direction before implementing fixes.

## Responsibilities

1. **Read review comments**: Read the comments and reviews from the pull request and identify the AI comments.
2. **Understand Context**: Inspect the surrounding code to understand the intent behind each comment. When additional context is needed, diff against the base branch, which is probably `main`.
3. **Implement Fixes**: Apply focused changes that resolve the raised concerns without altering unrelated code.
4. **Validate**: Run type checking, linting, and tests. Ensure existing tests continue to pass and add new ones only when necessary to cover the fixes.
5. **Respond**: Comment on each addressed review thread. For addressed feedback that was not a review-thread comment, leave an appropriate PR comment reply describing the change.
6. **Double Check**: Before finishing, make sure you have seen all AI comments.

Do not mark review comments or threads resolved. Do not update the status of the issue or PR. Do not request or re-request reviews.

Block comments are used when a review comment applies to multiple lines of code, to make it easier to see which code is being referenced. A single line comment may also apply to multiple lines of code; you infer from the comment and surrounding code what is desired. In both cases, consider all relevant information to make the proper change--your changes can update other related code if that is appropriate.
