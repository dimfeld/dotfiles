# GH API Patterns

Use these commands when the helper script is not enough or you need more detail.

## Resolve a PR to its head SHA

```bash
gh pr view 1234 --json number,title,url,headRefOid,headRepository,headRepositoryOwner
```

Useful fields:

- `headRefOid`: commit SHA used for checks
- `headRepository.name`: repo name
- `headRepositoryOwner.login`: owner

## List check runs for a commit

```bash
gh api repos/OWNER/REPO/commits/SHA/check-runs
```

Inspect these fields:

- `check_runs[].name`
- `check_runs[].status`
- `check_runs[].conclusion`
- `check_runs[].details_url`
- `check_runs[].html_url`
- `check_runs[].check_suite.id`

Treat these conclusions as failed for fixing workflows:

- `failure`
- `timed_out`
- `cancelled`
- `action_required`
- `startup_failure`
- `stale`

## List legacy status contexts for a commit

```bash
gh api repos/OWNER/REPO/commits/SHA/status
```

Inspect:

- `state`
- `statuses[].context`
- `statuses[].state`
- `statuses[].target_url`
- `statuses[].description`

Treat `error` and `failure` as failed contexts.

## Inspect workflow runs

If a failing check maps to a GitHub Actions run, use:

```bash
gh run view RUN_ID
gh run view RUN_ID --log-failed
```

If you only have a details URL, extract the run id from the URL when possible. If not possible, use the check name plus recent runs to identify the matching run.
