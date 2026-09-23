---
name: pr-review-guide
description: Generate a PR review guide. Use when a branch needs a detailed walkthrough for review and Codex should group the changed files, write `review-guide.md` and `review-guide.json`, then perform the review and add findings to the guide.
allowed-tools: Bash(git log:*), Bash(git show:*), Bash(git diff:*), Bash(jj status:*), Bash(jj bookmark:*), Bash(jj log:*), Bash(jj diff:*), Bash(gh pr:*), Bash(tr:*), Write(review-guide.md), Write(review-guide.json)
disable-model-invocation: true
argument-hint: [extra context]
---

This branch contains a pull request that has been implemented by another engineer. I now need to review those changes.

Here is the list of files changed:

!`jj diff -f 'heads(::@ & ::main)' -s | grep '^[MA]' | nl`

Group this list into chunks (by functional area if possible) and use parallel subagents to analyse the diffs, reading the files and also using `jj diff -f 'heads(::@ & ::main)' <filename>` for each
one to get the diff. Make sure that every file is assigned to a chunk; we don't want to miss any files. Ignore any
comments starting with AI: or AI_COMMENT_START; those are pending review comments I added.

Make sure to go into detail about each file that has major changes related to the task and what changes are in those files. You can group files together if needed, but the report should be detailed enough that I should get a good idea of what changed without needing to look at the file myself.

Once you have the diffs, generate a guide to help me walk through the pull request, grouping the files into functional areas and noting which are major parts of the change and which are perfunctory changes such as just adding a new member to an object whose type was updated or renaming functions and fields. The guide should be able to walk me step by step through reviewing the changes.

Each section in the guide must include the relevant diffs in a unified diff format code block. Use ` ```unified-diff ` blocks for these. Include all changed lines for the files in that section, so that I can read the diff inline without needing to look at the files separately.

Generate your report using markdown with section headers. Do not commit it.

1. Once you have this guide generated, also write it to `review-guide.md`. 
2. Create a corresponding review-guide.json file that groups the files appropriately, using the format below.
3. Then go through the guide you just wrote, review the changes, and add any comments to `review-guide.md`.
4. Finally, look through the codebase to see what might have been missed, unnecessarily duplicated code, or code that doesn't follow best practices or existing patterns. Write any additional comments to `review-guide.md`.

Place each review comment from steps 3 and 4 in the section for the relevant file group.

## Review priorities

Correctness, security, and test quality come first. Project-convention and performance issues come second. In addition to the usual categories, flag these:

- Errors that are caught and only logged. Nobody reads those logs in production, so unexpected errors must propagate.
- Path traversal on the local filesystem. Object-store keys (such as S3) are not vulnerable to it, so do not flag them.
- Tests that pass without verifying the behavior they claim to cover, and missing tests for error paths and edge cases.
- Deviation from established codebase patterns without a stated reason.

Report the issues that a careful senior reviewer would raise, not nits. Do not report formatting; autoformatters handle it. When a function is wrapped in middleware, assume that the middleware does its job. For example, if the middleware already verifies the presence of an organization and user, the handler inside it does not need to check again.

## review-guide.json example:

```json
{
  "title": "Document Import with Order Matching and Reconciliation",
  "groups": [
    {
      "name": "Document Import Core",
      "files": [
        { "path": "src/services/document-importer.ts" },
        { "path": "src/parsers/document-parser.ts" },
        { "path": "src/validators/document-validator.ts" },
        { "path": "tests/document-importer.test.ts" }
      ]
    },
    {
      "name": "Order Matching Logic",
      "files": [
        { "path": "src/services/order-matcher.ts" },
        { "path": "src/utils/fuzzy-match.ts" },
        { "path": "src/models/match-score.ts" },
        { "path": "tests/order-matcher.test.ts" },
      ]
    },
    {
      "name": "Difference Reconciliation",
      "files": [
        { "path": "src/services/reconciliation-engine.ts" },
        { "path": "src/models/reconciliation-result.ts" },
        { "path": "src/utils/field-comparator.ts" },
        { "path": "tests/reconciliation-engine.test.ts" }
      ]
    },
    {
      "name": "Database & Models",
      "files": [
        { "path": "migrations/004_add_import_history.sql" },
        { "path": "src/models/import-record.ts" },
        { "path": "src/models/order.ts" }
      ]
    },
    {
      "name": "API and UI Components",
      "files": [
        { "path": "src/api/import.ts" },
        { "path": "src/api/reconciliation.ts" },
        { "path": "src/components/DocumentUploader.svelte" },
        { "path": "src/components/OrderMatchReview.svelte" },
        { "path": "src/components/ReconciliationDiff.svelte" }
      ]
    }
  ]
}
```

Note that the review-guide files are gitignored, so you should not expect them to show up in VCS.
