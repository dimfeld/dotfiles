#!/usr/bin/env bun
/**
 * Lists your Linear issues that moved into "In Review" at some point this week,
 * sorted by the time of that transition — even if the issue has since moved on
 * to another status.
 *
 * Auth: uses `linear auth token` (from the linear CLI) by default, or the
 * LINEAR_API_KEY env var if set.
 *
 * Usage:
 *   bun in-review-this-week.ts                # current calendar week (Monday start)
 *   bun in-review-this-week.ts --days 7       # trailing 7 days instead
 *   bun in-review-this-week.ts --state "QA"   # track a different target state
 */

const API_URL = 'https://api.linear.app/graphql';

interface HistoryNode {
  createdAt: string;
  toState: { name: string } | null;
}
interface IssueNode {
  identifier: string;
  title: string;
  state: { name: string };
  history: { nodes: HistoryNode[] };
}

function parseArgs(argv: string[]) {
  let days: number | null = null;
  let targetState = 'In Review';
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--days') days = Number(argv[++i]);
    else if (argv[i] === '--state') targetState = argv[++i];
  }
  return { days, targetState };
}

/** Start of the period to consider: Monday 00:00 local, or N days ago. */
function periodStart(days: number | null): Date {
  if (days != null) {
    const d = new Date();
    d.setDate(d.getDate() - days);
    return d;
  }
  const now = new Date();
  const day = now.getDay(); // 0 = Sunday
  const mondayOffset = (day + 6) % 7; // days since most recent Monday
  const monday = new Date(now);
  monday.setDate(now.getDate() - mondayOffset);
  monday.setHours(0, 0, 0, 0);
  return monday;
}

async function getToken(): Promise<string> {
  if (process.env.LINEAR_API_KEY) return process.env.LINEAR_API_KEY;
  const proc = Bun.spawn(['linear', 'auth', 'token'], { stdout: 'pipe', stderr: 'pipe' });
  const out = (await new Response(proc.stdout).text()).trim();
  if ((await proc.exited) !== 0 || !out) {
    throw new Error('Could not get a Linear token. Set LINEAR_API_KEY or run `linear auth login`.');
  }
  return out;
}

async function query<T>(token: string, q: string, variables: unknown): Promise<T> {
  const res = await fetch(API_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: token },
    body: JSON.stringify({ query: q, variables }),
  });
  const json = await res.json();
  if (json.errors) throw new Error(`Linear API error: ${JSON.stringify(json.errors)}`);
  return json.data as T;
}

const ISSUES_QUERY = `
  query($filter: IssueFilter!) {
    issues(filter: $filter, first: 100) {
      nodes {
        identifier
        title
        state { name }
        history(first: 100) { nodes { createdAt toState { name } } }
      }
    }
  }
`;

function fmt(date: Date): string {
  return date.toLocaleString(undefined, {
    weekday: 'short',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  });
}

async function main() {
  const { days, targetState } = parseArgs(process.argv.slice(2));
  const since = periodStart(days);
  const token = await getToken();

  const data = await query<{ issues: { nodes: IssueNode[] } }>(token, ISSUES_QUERY, {
    filter: {
      assignee: { isMe: { eq: true } },
      updatedAt: { gte: since.toISOString() },
    },
  });

  const rows = data.issues.nodes
    .map((issue) => {
      // Latest transition into the target state (an issue can bounce in and out).
      const times = issue.history.nodes
        .filter((h) => h.toState?.name === targetState)
        .map((h) => new Date(h.createdAt));
      const movedAt = times.length ? new Date(Math.max(...times.map((t) => t.getTime()))) : null;
      return { issue, movedAt };
    })
    .filter((r): r is { issue: IssueNode; movedAt: Date } => r.movedAt != null && r.movedAt >= since)
    .sort((a, b) => a.movedAt.getTime() - b.movedAt.getTime());

  if (!rows.length) {
    console.log(`No issues moved to "${targetState}" since ${fmt(since)}.`);
    return;
  }

  console.log(`Issues moved to "${targetState}" since ${fmt(since)} (sorted by that time):\n`);
  for (const { issue, movedAt } of rows) {
    console.log(`${fmt(movedAt)}  ${issue.identifier}  [${issue.state.name}]  ${issue.title}`);
  }
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : err);
  process.exit(1);
});
