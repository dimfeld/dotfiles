---
description: Read a PR review guide and review the code
allowed-tools: Bash(git log:*), Bash(git show:*), Bash(git diff:*), Bash(jj status:*), Bash(jj bookmark:*), Bash(jj log:*), Bash(jj diff:*), Bash(gh pr:*), Bash(tr:*)
argument-hint: [extra context]
---

Read review-guide.md and thoroughly review the files and changes mentioned in the report. Once done, add
your findings to review-guide.md in a new "Second Pass Review" section while preserving all existing content. The file will contain review notes from another
reviewer and we do not want to lose those.

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

