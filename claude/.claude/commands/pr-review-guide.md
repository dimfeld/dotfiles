---
description: Generate a PR review guide
allowed-tools: Bash(git log:*), Bash(git show:*), Bash(git diff:*), Bash(jj status:*), Bash(jj bookmark:*), Bash(jj log:*), Bash(jj diff:*), Bash(gh pr:*), Bash(tr:*)
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

Generate your report using markdown with section headers. Do not commit it.

$ARGUMENTS

1. Once you have this guide generated, also write it to `review-guide.md`. 
2. Create a corresponding review-guide.json file that groups the files appropriately, using the format below.
3. Then go through the guide you just wrote and perform a thorough review of the changes and add any comments to `review-guide.md`. Take as much time as needed to properly review the changes.
4. Finally, look through the codebase to see what might have been missed, unnecessarily duplicated code, or code that doesn't follow best practices or existing patterns. Write any additional comments to `review-guide.md`.

## Sample Issues to Flag:

### Code Correctness (HIGH PRIORITY)
- Logic errors or incorrect algorithms
- Race conditions or concurrency issues
- Incorrect error handling or missing error cases
- Off-by-one errors, boundary condition failures
- Null pointer exceptions or undefined access
- Resource leaks (files, connections, memory)
- Incorrect type usage or unsafe type assertions
- Catching errors and just printing a log message (which will likely not be seen in production). Errors should be bubbled up, especially unexpected errors.

### Security Vulnerabilities (HIGH PRIORITY)
- Path traversal vulnerabilities (filesystem only. Object stores like S3 are not vulnerable to this)
- SQL injection or command injection risks
- Unsafe deserialization
- Missing input validation or sanitization
- Hardcoded secrets, API keys, or passwords
- Unsafe file operations or permissions
- Cross-site scripting (XSS) opportunities

### Project Violations (MEDIUM PRIORITY)
- Deviation from established patterns without justification
- Inconsistent code style or formatting
- Improper imports or dependency usage
- Wrong file organization or module structure
- Missing required documentation or comments where mandated

### Performance Issues (MEDIUM PRIORITY)
- Inefficient algorithms (O(n²) where O(n) is possible)
- Unnecessary file I/O or network calls
- Memory waste or unbounded growth
- Blocking operations on the main thread
- Missing caching where it would significantly help

### Testing Problems (HIGH PRIORITY)
- Tests that don't test the actual implementation
- Missing tests for error conditions and edge cases
- Tests that pass but don't verify correct behavior
- Flaky or non-deterministic tests
- Tests with insufficient coverage of critical paths
- Integration tests missing for complex workflows

## Don't be too Pedantic

Although you should be thorough in your review, you should not be too picky.

- Do not mention code formatting issues--we have autoformatters for that.
- When a function is wrapped in middleware, you can assume that the middleware is doing its job. For example, if the
middleware already verifies the presence of an organization and user, the handler function inside the middleware does not need to check its presence again.



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

