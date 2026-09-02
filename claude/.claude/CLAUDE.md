## General Rules

- When writing responses to the user, reviewing code, generating documentation, or otherwise writing text for humans to read, use ASD-STE100 Simplified Technical English.
- If you use `proofshot` or other tools, always check if the dev server is running first before you tell proofshot to
  run it, or deliberately choose a non-default port. Otherwise this interferes with the existing server and messes things up. Proofshot is also very bad at properly shutting down the
  dev servers that it starts.

## Source Control

- A lot of my projects use the `jj` source control system. To commit, use `jj commit -m "..."`. There is no need to add files with `jj`; they are tracked automatically.

- Every time you finish a user request, or one or more items on your TODO list that involved changing files, make a commit. Use `jj` if it is enabled in the repository.

- Don't add comments about generated with Claude or Co-Authored-By Claude when writing commit messages

- Common `jj` commands:
  - `jj status` - Show current status of the repository
  - `jj commit -m "message"` - Create a commit with the specified message (you do not need to "add" files first)
  - `jj git push` - Push changes to the remote Git repository

  Committing with `jj` creates a new empty commit on top. This is normal and does not need to be handled specially.

  When referencing specific files in jj commands, you need to escape brackets [ and ] with backslashes e.g. \\[ and \\].

- When using absolute paths, make sure to write `dimfeld` as the user name not `dimfield`

- When you encounter test failures, you must not `git stash` and then run again to see if they were pre-existing.

- Occasionally a `jj` command will fail to "acquire lock for index file". In this case do not try to delete the lock file, just try again and it should work.

- when creating a PR, use `jj diff non-test --stat -f BASE_REV` to get changed line counts for the PR. `non-test` is a
  special fileset I have defined.

- We have a jj revset `stack_base` which resolves to the commit that is the base of the current branch, whether stacked
  or on trunk. You can use this like `jj diff -f stack_base` or similar when you want to just get changes on the current branch.

## Removing Files

My `rm` command is aliased to `rm -i`. This means that you need to use `rm -f` to remove files.

# MSW — the kernel

Remember to follow the MSW deletion rule for all claims -- no exceptions.

## program — complete

```
contract ← the requested outcome + the smallest criteria that prove it

while ∃ claim c : deleting c leaves contract unmet ∨ unproven
      do c ; prove c

halt ; report
```

## definitions — no behavior lives here, only meaning

**contract** — the requested outcome and the smallest set of acceptance criteria that would prove it, stated before any work. The sole source of necessity; a ceiling as much as a floor. If the request is ambiguous: attended → ask; unattended → bind the smallest reading consistent with stated intent and record the assumption.

**claim** — anything petitioning to become work: a plan step, a change, a test, a reviewer's P1, a discovered edge case, your own instinct that one more pass would help. Everything enters as this type. Nothing enters as a verdict.

**deleting c leaves contract unmet ∨ unproven** — the only test. A claim passes solely by breaking the contract — reproducibly, within the task's actual inputs and environment. Severity is derived from the contract, never inherited from whoever raised the claim. *Useful*, *thorough*, and *possible* are not aliases for *necessary*. A claim that fails receives one line in the report — never a fix, an investigation, or a deferred follow-up.

**do ; prove** — the smallest reliable act that closes the gap, and evidence sized to the claim it settles. An unproven act keeps its claim alive; a proven one closes it — and re-proving a closed claim is itself an inadmissible claim.

**halt** — the fixed point: contract proven, no remaining claim passes. Not reviewer silence; not exhausted imagination. Halting before the fixed point and looping past it are the same bug, mirrored.

**report** — the outcome against the contract; the proof; rejected claims worth the user's attention, one line each. Nothing else.

## fuses — outside the program, for when its evaluator fails

```
rounds = 3            → halt anyway ; report open items, do not chase them
claim born in round n+1, visible in round n   → rejected
```

## No unauthoritative limits

Never invent a limit. A cap, threshold, quota, budget, timeout, retry or round count, file or line count, acceptance-criterion count, agent count, or similar constraint is admissible only when its exact value is:

- explicitly required by the requester;
- imposed by an applicable technical or platform contract;
- defined by authoritative project policy; or
- derived from measured evidence necessary to meet or prove the task contract.

State the authority or derivation whenever proposing or applying a limit. If no authority exists, omit the limit and use the MSW necessity test. Metrics may be reported as evidence, but they must not become gates, defaults, targets, or recommendations through agent intuition. Examples and representative proportions never become defaults. If a necessary limit is an unresolved owner choice, ask; do not manufacture a value.
