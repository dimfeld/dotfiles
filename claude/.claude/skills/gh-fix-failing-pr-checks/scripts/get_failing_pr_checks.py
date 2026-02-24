#!/usr/bin/env python3
"""Resolve a pull request and print failing GitHub checks as JSON."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from typing import Any


FAILED_CONCLUSIONS = {
    "failure",
}
FAILED_STATUS_STATES = {"error", "failure"}
PR_URL_RE = re.compile(r"github\.com/[^/]+/[^/]+/pull/(\d+)")


def run_gh(args: list[str]) -> Any:
    result = subprocess.run(
        ["gh", *args],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Resolve a PR and list failing checks for its head commit."
    )
    parser.add_argument("pr", help="PR number or GitHub pull request URL")
    return parser.parse_args()


def extract_pr_number(value: str) -> str:
    if value.isdigit():
        return value

    match = PR_URL_RE.search(value)
    if match:
        return match.group(1)

    raise SystemExit(f"Unsupported PR value: {value}")


def resolve_pr(pr: str) -> dict[str, Any]:
    pr_number = extract_pr_number(pr)
    data = run_gh(
        [
            "pr",
            "view",
            pr_number,
            "--json",
            "number,title,url,headRefOid,headRepository,headRepositoryOwner",
        ]
    )

    owner = data["headRepositoryOwner"]["login"]
    repo = data["headRepository"]["name"]
    sha = data["headRefOid"]

    return {
        "number": data["number"],
        "title": data["title"],
        "url": data["url"],
        "owner": owner,
        "repo": repo,
        "sha": sha,
    }


def get_check_runs(owner: str, repo: str, sha: str) -> list[dict[str, Any]]:
    data = run_gh(["api", f"repos/{owner}/{repo}/commits/{sha}/check-runs"])
    failing: list[dict[str, Any]] = []

    for check_run in data.get("check_runs", []):
        conclusion = check_run.get("conclusion")
        if conclusion not in FAILED_CONCLUSIONS:
            continue

        failing.append(
            {
                "name": check_run.get("name"),
                "status": check_run.get("status"),
                "conclusion": conclusion,
                "details_url": check_run.get("details_url"),
                "html_url": check_run.get("html_url"),
                "started_at": check_run.get("started_at"),
                "completed_at": check_run.get("completed_at"),
                "app": (check_run.get("app") or {}).get("name"),
            }
        )

    return failing


def get_status_contexts(owner: str, repo: str, sha: str) -> list[dict[str, Any]]:
    data = run_gh(["api", f"repos/{owner}/{repo}/commits/{sha}/status"])
    failing: list[dict[str, Any]] = []

    for status in data.get("statuses", []):
        state = status.get("state")
        if state not in FAILED_STATUS_STATES:
            continue

        failing.append(
            {
                "context": status.get("context"),
                "state": state,
                "description": status.get("description"),
                "target_url": status.get("target_url"),
                "updated_at": status.get("updated_at"),
            }
        )

    return failing


def main() -> int:
    args = parse_args()
    pr = resolve_pr(args.pr)
    check_runs = get_check_runs(pr["owner"], pr["repo"], pr["sha"])
    status_contexts = get_status_contexts(pr["owner"], pr["repo"], pr["sha"])

    print(
        json.dumps(
            {
                "pr": {
                    "number": pr["number"],
                    "title": pr["title"],
                    "url": pr["url"],
                },
                "head": {
                    "owner": pr["owner"],
                    "repo": pr["repo"],
                    "sha": pr["sha"],
                },
                "failing_check_runs": check_runs,
                "failing_status_contexts": status_contexts,
            },
            indent=2,
            sort_keys=True,
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
