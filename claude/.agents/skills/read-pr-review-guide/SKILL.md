---
name: read-pr-review-guide
description: Read a PR review guide and review the code. Use when `review-guide.md` already exists and Codex should follow that guide, inspect the referenced changes, and append findings without overwriting prior notes.
allowed-tools: Bash(git log:*), Bash(git show:*), Bash(git diff:*), Bash(jj status:*), Bash(jj bookmark:*), Bash(jj log:*), Bash(jj diff:*), Bash(gh pr:*), Bash(tr:*)
argument-hint: [extra context]
---

Read review-guide.json and thoroughly review the files and changes mentioned in the file. Once done, read review-guide.md and add your review findings to it, with each finding in the section for the relevant file group. Preserve all existing content and review notes in the review guide. The file will contain review notes from another reviewer and we do not want to lose those.

Note that review-guide.md is gitignored, so you should not expect it to show up in VCS.

## Review priorities

Correctness, security, and test quality come first. Project-convention and performance issues come second. In addition to the usual categories, flag these:

- Errors that are caught and only logged. Nobody reads those logs in production, so unexpected errors must propagate.
- Path traversal on the local filesystem. Object-store keys (such as S3) are not vulnerable to it, so do not flag them.
- Tests that pass without verifying the behavior they claim to cover, and missing tests for error paths and edge cases.
- Deviation from established codebase patterns without a stated reason.

Report the issues that a careful senior reviewer would raise, not nits. Do not report formatting; autoformatters handle it. When a function is wrapped in middleware, assume that the middleware does its job. For example, if the middleware already verifies the presence of an organization and user, the handler inside it does not need to check again.
