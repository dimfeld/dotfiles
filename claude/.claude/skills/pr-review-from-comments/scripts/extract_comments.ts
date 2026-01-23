#!/usr/bin/env bun

interface DiffLine {
  originalLine: number | null;
  updatedLine: number | null;
  content: string;
}

interface ExtractedComment {
  file: string;
  type: "single" | "block_start" | "block_end";
  commentText: string;
  updatedLineNumber: number;
  originalLineNumber: number | null;
  adjacentOriginalLine: string | null;
  adjacentOriginalLineNumber: number | null;
}

async function runCommand(args: string[]): Promise<string> {
  const proc = Bun.spawn(args, { stdout: "pipe", stderr: "pipe" });
  const output = await new Response(proc.stdout).text();
  const exitCode = await proc.exited;
  if (exitCode !== 0) {
    const stderr = await new Response(proc.stderr).text();
    throw new Error(`Command failed: ${args.join(" ")}\n${stderr}`);
  }
  return output;
}

async function getModifiedFiles(): Promise<string[]> {
  const output = await runCommand(["jj", "status"]);
  const files: string[] = [];
  for (const line of output.split("\n")) {
    const match = line.match(/^[MA]\s+(.+)$/);
    if (match && match[1]) {
      files.push(match[1]);
    }
  }
  return files;
}

async function parseDiff(file: string): Promise<DiffLine[]> {
  const output = await runCommand(["jj", "diff", "--color-words", file]);
  const lines: DiffLine[] = [];

  for (const line of output.split("\n")) {
    // jj diff --color-words format:
    // First column is original line number, second is updated line number, followed by colon
    // Format: "   123    456: content" or "        456: content" (new line) or "   123     : content" (deleted)
    const match = line.match(/^\s*(\d+)?\s+(\d+)?:\s?(.*)$/);
    if (match) {
      lines.push({
        originalLine: match[1] ? parseInt(match[1], 10) : null,
        updatedLine: match[2] ? parseInt(match[2], 10) : null,
        content: match[3] || "",
      });
    }
  }

  return lines;
}

function findCommentPattern(content: string): { type: "single" | "block_start" | "block_end"; text: string } | null {
  // Look for AI_COMMENT_END first (before AI_COMMENT_START to avoid partial match)
  if (content.includes("AI_COMMENT_END")) {
    return { type: "block_end", text: "AI_COMMENT_END" };
  }

  // Look for AI_COMMENT_START with optional text after it
  const blockStartMatch = content.match(/AI_COMMENT_START\s*(.*)/);
  if (blockStartMatch) {
    return { type: "block_start", text: blockStartMatch[1]?.trim() || "" };
  }

  // Look for AI: with text after it
  const singleMatch = content.match(/\bAI:\s*(.*)/);
  if (singleMatch) {
    return { type: "single", text: singleMatch[1]?.trim() || "" };
  }

  return null;
}

async function extractCommentsFromFile(file: string): Promise<ExtractedComment[]> {
  const diffLines = await parseDiff(file);
  const comments: ExtractedComment[] = [];

  for (let i = 0; i < diffLines.length; i++) {
    const line = diffLines[i]!;
    if (line.updatedLine === null) continue; // Skip deleted lines

    const commentMatch = findCommentPattern(line.content);
    if (!commentMatch) {
      continue;
    }

    if (commentMatch.type === "block_start") {
      // Collect all consecutive added lines as part of the block_start comment
      const commentLines: string[] = [commentMatch.text || ""];
      let j = i + 1;

      // Skip additional added lines that are part of the comment
      while (j < diffLines.length) {
        const nextLine = diffLines[j]!;
        if (nextLine.updatedLine === null) {
          // Deleted line, skip
          j++;
          continue;
        }
        if (nextLine.originalLine !== null) {
          // Found original line, this is the adjacent line
          break;
        }
        // Check if this added line ends the block (AI_COMMENT_END or another AI pattern)
        const nextMatch = findCommentPattern(nextLine.content);
        if (nextMatch) {
          break; // Stop before this line - it will be processed separately
        }
        // Add this line to the comment
        commentLines.push(nextLine.content);
        j++;
      }

      // Find the adjacent original line
      let adjacentLine: string | null = null;
      let adjacentLineNum: number | null = null;
      for (let k = j; k < diffLines.length; k++) {
        const diffLine = diffLines[k]!;
        if (diffLine.originalLine !== null) {
          adjacentLine = diffLine.content;
          adjacentLineNum = diffLine.originalLine;
          break;
        }
      }

      comments.push({
        file,
        type: "block_start",
        commentText: commentLines.join("\n").trim() || "AI_COMMENT_START",
        updatedLineNumber: line.updatedLine,
        originalLineNumber: line.originalLine,
        adjacentOriginalLine: adjacentLine,
        adjacentOriginalLineNumber: adjacentLineNum,
      });

      // Skip the lines we consumed
      i = j - 1;
    } else if (commentMatch.type === "block_end") {
      // Find the previous original line before this comment
      let adjacentLine: string | null = null;
      let adjacentLineNum: number | null = null;
      for (let j = i - 1; j >= 0; j--) {
        const diffLine = diffLines[j]!;
        if (diffLine.originalLine !== null) {
          adjacentLine = diffLine.content;
          adjacentLineNum = diffLine.originalLine;
          break;
        }
      }

      comments.push({
        file,
        type: "block_end",
        commentText: "AI_COMMENT_END",
        updatedLineNumber: line.updatedLine,
        originalLineNumber: line.originalLine,
        adjacentOriginalLine: adjacentLine,
        adjacentOriginalLineNumber: adjacentLineNum,
      });
    } else if (commentMatch.type === "single") {
      // Collect all consecutive added lines as part of the comment
      const commentLines: string[] = [commentMatch.text];
      let j = i + 1;

      // Check if this is an added line (no original line number)
      // If so, look for more added lines that continue the comment
      if (line.originalLine === null) {
        while (j < diffLines.length) {
          const nextLine = diffLines[j]!;
          if (nextLine.updatedLine === null) {
            // Deleted line, skip
            j++;
            continue;
          }
          if (nextLine.originalLine !== null) {
            // Found original line, this is the adjacent line
            break;
          }
          // Check if this is another AI pattern
          const nextMatch = findCommentPattern(nextLine.content);
          if (nextMatch) {
            break; // Stop before this line - it will be processed separately
          }
          // Add this line to the comment
          commentLines.push(nextLine.content);
          j++;
        }
      }

      // Find the adjacent original line
      let adjacentLine: string | null = null;
      let adjacentLineNum: number | null = null;
      for (let k = j; k < diffLines.length; k++) {
        const diffLine = diffLines[k]!;
        if (diffLine.originalLine !== null) {
          adjacentLine = diffLine.content;
          adjacentLineNum = diffLine.originalLine;
          break;
        }
      }

      comments.push({
        file,
        type: "single",
        commentText: commentLines.join("\n").trim(),
        updatedLineNumber: line.updatedLine,
        originalLineNumber: line.originalLine,
        adjacentOriginalLine: adjacentLine,
        adjacentOriginalLineNumber: adjacentLineNum,
      });

      // Skip the lines we consumed
      if (line.originalLine === null) {
        i = j - 1;
      }
    }
  }

  return comments;
}

async function main() {
  const files = await getModifiedFiles();

  if (files.length === 0) {
    console.log("No modified files found.");
    return;
  }

  console.log("Modified files:", files);
  console.log("");

  const allComments: ExtractedComment[] = [];

  for (const file of files) {
    try {
      const comments = await extractCommentsFromFile(file);
      allComments.push(...comments);
    } catch (err) {
      console.error(`Error processing ${file}:`, (err as Error).message);
    }
  }

  if (allComments.length === 0) {
    console.log("No AI comments found.");
    return;
  }

  console.log("Extracted AI Comments:");
  console.log("=".repeat(60));

  for (const comment of allComments) {
    console.log(`\nFile: ${comment.file}`);
    console.log(`Type: ${comment.type}`);
    console.log(`Comment Line in Edited File: ${comment.updatedLineNumber}`);
    console.log(`Comment Text: ${comment.commentText}`);
    if (comment.adjacentOriginalLineNumber !== null) {
      console.log(`Adjacent Original Line ${comment.adjacentOriginalLineNumber}: ${comment.adjacentOriginalLine}`);
    } else {
      console.log(`Adjacent Original Line: (none found)`);
    }
    console.log("-".repeat(40));
  }
}

main().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
