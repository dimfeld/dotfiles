---
name: project-tracker
description: Maintain the personal projects.md tracker, review project status, record progress or external blockers, and find next actions and quick wins. Use when the user asks about this portfolio or reports progress or an unblock event for a listed project. Do not use for unrelated project planning.
---

# Project tracker

The tracker is `/Users/dimfeld/Documents/projects/projects.md`. Read it before each operation. It is an index for choosing work, not a replacement for project task lists. Write text for the user in ASD-STE100 Simplified Technical English.

## Select the scope

- **Full review:** Check every entry in the main list. This includes projects held only in chat. Preserve the status last supplied by the user unless new evidence or a user update supports a change. Scan the listed source paths, not every file in every repository. If the user also asks for new projects, inspect top-level directories and propose entries supported by evidence. Do not treat dependencies, external repositories, or alternate checkouts as separate personal projects without evidence.
- **One-project status:** Read its section and current source notes. Report what is known, what is unknown, and the next useful action. Update the entry if new evidence changes it. A question alone does not change user intent or priority.
- **Direct update:** Record the user's progress, wait condition, arrival, pause, or completion in the named section. Do not review unrelated projects. Update the work-selection list if the change affects it.
- **Choose work:** Use current intent, prerequisites, blockers, and available time. Check the relevant source notes before recommending a task. Give a main action and a short action when supported by evidence.

Resolve project aliases from the tracker and context. Ask only if two entries remain plausible or a required fact cannot be found. Preserve explicit user updates while checking independent source facts.

## Check evidence

For a repository, read applicable project instructions, then use focused reads of README, status or progress notes, verification notes, and current plans. Source-control status and recent history can show changes; they cannot prove intent, device assembly, acceptance, or daily use. Keep the review read-only within project repositories.

Use a project's plan system when it is relevant and available. If the project uses Tim, use the available `using-tim` skill to inspect plans. Do not start a plan, run builds, change code, start servers, or perform hardware tests as part of a tracker update.

For a project held only in chat, use the supplied conversation or an available authorized source. If the design chat is unavailable, retain the known checkpoint and mark the missing facts. Do not invent paths, dimensions, orders, or decisions. Add a project to the main list only when the user confirms they want to keep it. Remove archived projects from the list when requested; leave their files in place.

Distinguish these facts:

- **Status:** Idea, Planned, Active, Waiting, Paused, or Done. The user has reviewed the current list; do not add an Unknown or Unconfirmed status. Keep the last user-supplied status when source details are missing. Ask for a status when adding a project if it cannot be determined from the user request. Done for now can include daily use and deferred improvements; do not create current tasks for those improvements unless the user wants to resume them.
- **Evidence:** What exists or what a source records. State the source and limits. Code completion does not prove physical completion or acceptance.
- **Blocker:** A confirmed condition that prevents the next intended step. Missing information is not automatically a blocker or a reason to set Waiting.
- **Priority:** Preserve user choices. Label inferred priority as suggested. Keep at most three high-priority entries; do not silently replace a user priority to meet that limit. If user choices exceed it, note the conflict and ask which should take precedence.

Recent commits alone do not change Waiting or Paused to Active. Keep a user-reported external blocker until evidence or the user confirms it is removed. If sources conflict, record the conflict instead of choosing an unsupported state.

## Handle progress and blockers

Whenever the user says they did work or a project became unblocked:

1. Record the completed step or the removed blocker. Preserve other blockers.
2. Check the relevant source notes for what follows. If the user completed the proposed next action, replace it.
3. Select a concrete next action with a clear completion condition and known prerequisites. Label it proposed unless agreed or already recorded in a current plan.
4. Find a useful 10–15-minute task if one exists. State its result and prerequisites. Check that it is still open. Do not create busywork to fill this field.
5. Recheck the work-selection list and remove completed or obsolete quick wins.

An arrival may remove one blocker while another remains. Unblocked does not necessarily mean Active. If source notes are unavailable, record the user's update and identify the next fact to check; do not claim a verified next task.

For Waiting, record what must arrive or happen, what will confirm release, and an expected date or follow-up date only if known. Include a useful action that can proceed without the blocker when one exists. Do not infer delivery from an elapsed date. If all useful work is blocked, say so.

## Maintain the file

Keep Markdown sections for the main list. Keep project names and links stable. Use the fields already in the tracker: category, status, priority, evidence, blocker, information needed, source, last reviewed, next action, and quick wins. Add a brief progress checkpoint or wait detail when needed. Remove resolved information requests and obsolete actions; keep evidence needed to explain current state. Do not copy full task lists or grow a session log.

Use the current date in Pacific/Honolulu for entries actually checked or updated. Distinguish a user update from a source review if source notes were not checked. Keep status-review and source-review dates separate. Change the status-review date after reviewing all entries with the user, and change a full source-review date only after checking every entry. Record unavailable sources or missing facts under information needed; do not replace a project status with a confidence label or imply that missing sources were verified. Do not change dates on untouched entries.

Preserve the difference between confirmed next actions and proposals. Keep the top work-selection list consistent with project entries. Do not rank a blocked action as ready. A Waiting project can have a separate action that is ready. Keep suggested priority separate from the user-supplied status. Ask about priority only when it affects the work choice.

Save requested updates directly. This skill authorizes changes to the tracker only, not implementation work, external messages, purchases, or changes to connected task systems. Follow the user's source-control instructions when the tracker is in a repository; include only task files in a commit. If the tracker has no repository, report that limit instead of creating a repository across the projects directory.

After saving, reread the changed sections and check that links, statuses, blockers, dates, next actions, and the work-selection list agree. Report the changed status, the next action, and any useful quick win. For a full review, also report gaps that prevent a reliable work choice.
