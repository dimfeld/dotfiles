#!/usr/bin/env bun

import { Octokit } from "@octokit/rest";
import { z } from "zod/v4";

const CommentSchema = z.object({
  file: z.string(),
  startLine: z.number().optional(),
  line: z.number(),
  text: z.string(),
});

const InputSchema = z.object({
  owner: z.string().optional(),
  repo: z.string().optional(),
  pr: z.number(),
  status: z.enum(["comment", "requestChanges", "approve"]).optional(),
  body: z.string(),
  comments: z.array(CommentSchema),
});

type Input = z.infer<typeof InputSchema>;

async function getGitRemoteInfo(): Promise<{ owner: string; repo: string }> {
  const proc = Bun.spawn(["git", "remote", "get-url", "origin"], {
    stdout: "pipe",
  });

  const output = await new Response(proc.stdout).text();
  const exitCode = await proc.exited;

  if (exitCode !== 0) {
    throw new Error("Failed to get git remote origin");
  }

  const remoteUrl = output.trim();

  // Parse HTTPS URL: https://github.com/owner/repo.git
  const httpsMatch = remoteUrl.match(
    /^https:\/\/github\.com\/([^/]+)\/(.+?)(\.git)?$/
  );
  if (httpsMatch && httpsMatch[1] && httpsMatch[2]) {
    return { owner: httpsMatch[1], repo: httpsMatch[2] };
  }

  // Parse SSH URL: git@github.com:owner/repo.git
  const sshMatch = remoteUrl.match(/^git@github\.com:([^/]+)\/(.+?)(\.git)?$/);
  if (sshMatch && sshMatch[1] && sshMatch[2]) {
    return { owner: sshMatch[1], repo: sshMatch[2] };
  }

  throw new Error(`Unable to parse GitHub owner/repo from remote URL: ${remoteUrl}`);
}

async function main() {
  const filePath = process.argv[2];
  if (!filePath) {
    console.error("Usage: create_review.ts <input-file.json>");
    process.exit(1);
  }

  const token = process.env.GITHUB_TOKEN;
  if (!token) {
    console.error("GITHUB_TOKEN environment variable is required");
    process.exit(1);
  }

  const fileContent = await Bun.file(filePath).text();
  const parseResult = InputSchema.safeParse(JSON.parse(fileContent));

  if (!parseResult.success) {
    console.error("Invalid input:", z.treeifyError(parseResult.error));
    process.exit(1);
  }

  const input = parseResult.data;

  // Get owner and repo from git remote if not provided
  let owner: string;
  let repo: string;

  if (!input.owner || !input.repo) {
    const gitInfo = await getGitRemoteInfo();
    owner = input.owner || gitInfo.owner;
    repo = input.repo || gitInfo.repo;
  } else {
    owner = input.owner;
    repo = input.repo;
  }

  const octokit = new Octokit({ auth: token });

  const eventMap = {
    comment: "COMMENT",
    requestChanges: "REQUEST_CHANGES",
    approve: "APPROVE",
  } as const;

  const event = input.status ? eventMap[input.status] : "COMMENT";

  const comments = input.comments.map((c) => ({
    path: c.file,
    start_line: c.startLine,
    line: c.line,
    body: c.text,
  }));

  const response = await octokit.pulls.createReview({
    owner,
    repo,
    pull_number: input.pr,
    body: input.body,
    event,
    comments,
  });

  console.log(`Review created: ${response.data.html_url}`);
}

main().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
