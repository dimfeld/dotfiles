---
name: gh-fix-failing-pr-checks
description: Investigates and fixes failing GitHub pull request checks by querying the GitHub API through the gh CLI, inspecting workflow runs and logs, making code changes, and verifying the likely fix locally. Use when the user asks to fix failing CI on a PR, investigate red GitHub checks, repair a broken pull request build, or review a PR with optional guidance about how the fixes should be approached.
---

# GH Fix Failing PR Checks

Resolve a pull request to its current head commit, enumerate the failing checks from GitHub, inspect the relevant logs, and then fix the code in the local workspace. Treat any user-provided context as a constraint or hint, not as a substitute for verifying the actual failure mode.

## Quick Start

1. Confirm the target PR.
2. Run `scripts/get_failing_pr_checks.py <pr-number-or-url>` to get the failing checks for the PR head SHA.
3. For each failing check, inspect the run details with `gh run view <run-id>` or `gh run view <run-id> --log-failed`.
4. Apply the fix in the workspace, using the user's context if provided.
5. Run the narrowest local verification that credibly matches the failure.
6. Summarize what was failing, what changed, and any remaining failures you could not reproduce or fix.

## Workflow

### 1. Resolve the PR

Accept any of these inputs:

- PR number like `1234`
- Full GitHub PR URL
- Current branch, if the user clearly states the local checkout already matches the PR

Prefer the explicit PR number or URL. Use the helper script first because it resolves the PR to the head commit and returns both modern check runs and legacy status contexts.

### 2. Inspect failing checks

Run:

```bash
scripts/get_failing_pr_checks.py 1234
```

The script returns JSON with:

- PR metadata
- Head SHA
- Failing `check-runs`
- Failing status `contexts`

Use that output to decide what to inspect next:

- If a failing entry has a `details_url`, open that run with `gh run view <run-id>` when a run id is available.
- If the failure is from a workflow job, prefer `gh run view <run-id> --log-failed`.
- If the failure is a status context rather than a check run, inspect the linked target URL or determine which local command likely produced it.

If the script shows no failing checks, say that clearly and stop unless the user wants broader investigation.

### 3. Use user context correctly

Users may provide guidance such as:

- "This is probably a flaky Playwright test."
- "Prefer fixing lint issues first."
- "Do not change the API shape."
- "I suspect the recent auth refactor caused this."

Use that context to prioritize where to look and which fixes are acceptable. Do not assume the hint is correct without checking the failing logs and local code.

### 4. Fix the actual cause

Work from the concrete failure back to the code:

- Read the relevant files fully before editing them.
- If the failure points to formatting, linting, or typing, run the narrow project command that matches the failure.
- If the failure is test-only, reproduce it with the relevant package-level or file-level test command.
- If multiple checks fail, fix them in dependency order when possible. Start with type errors or build failures that can cascade into downstream test failures.

Avoid broad speculative edits. Each change should correspond to an identified failure mode.

### 5. Verify locally

Run the smallest set of local checks that materially supports the fix:

- The specific test file or package test command for test failures
- The package `check` command for TypeScript or build failures
- The relevant lint or format command for lint failures

If the GitHub failure depends on infrastructure you cannot reproduce locally, state that and verify the nearest meaningful substitute.

### 6. Report the result

In the final response, include:

- Which checks were failing
- What you changed
- What you ran locally
- What remains failing or unverified

## References

- Read `references/gh-api-patterns.md` when you need the exact `gh api` endpoints and field meanings behind the helper script.

## Resources

### scripts/

- `scripts/get_failing_pr_checks.py`: Resolve a PR and print failing checks from the GitHub API.
