#!/usr/bin/env bun
/// <reference types="bun-types" />

/* Apply LLM whole-file blocks from copied LLM output.
 * This looks for blocks with filenames either in a comment at the start of the block
 * or on the last non-blank line before the block (as a markdown header or raw filename),
 * and writes the contents to the path given, relative to the Git root.
 **/

import { $ } from 'bun';
import clipboard from 'clipboardy';
import * as path from 'path';

async function processFile(content: string, writeToGitroot: boolean) {
  // Split content into lines
  const lines = content.split('\n');
  let state:
    | 'searching'
    | 'startCodeBlock'
    | 'skippingLanguageSpecifier'
    | 'trimmingLeadingLines'
    | 'trimmingPostCommentLines'
    | 'ignoring'
    | 'copying' = 'searching';
  let currentBlock = [];
  let filename = null;
  const filesToWrite = new Map();
  const writeRoot = writeToGitroot
    ? (await $`git rev-parse --show-toplevel`.text()).trim()
    : process.cwd();
  let preBlockLines = [];

  // Process line by line
  for (const line of lines) {
    if (state === 'searching' && !line.startsWith('```')) {
      preBlockLines.push(line);
      continue;
    }

    if (line.startsWith('```')) {
      if (state === 'searching') {
        state = 'startCodeBlock';
      } else {
        // Process completed block
        if (filename && state !== 'ignoring') {
          filesToWrite.set(filename, currentBlock);
        }
        state = 'searching';
        currentBlock = [];
        filename = null;
        preBlockLines = []; // Reset for the next code block
      }
      continue;
    }

    if (state === 'startCodeBlock') {
      // Check preBlockLines for filename
      const reversedLines = [...preBlockLines].reverse();
      const lastNonEmptyLine = reversedLines.find((l) => l.trim() !== '');
      if (lastNonEmptyLine) {
        // Check for markdown header (e.g., **`filename`**)
        const markdownMatch =
          lastNonEmptyLine.match(/\*\*`(.+?)`\*\*/) || lastNonEmptyLine.match(/^`(.+?)`$/);
        if (markdownMatch) {
          filename = markdownMatch[1].trim();
          state = 'skippingLanguageSpecifier';
          continue;
        }
        // Check for raw filename (e.g., src/some/file.js)
        else if (lastNonEmptyLine.trim().includes('/')) {
          filename = lastNonEmptyLine.trim();
          state = 'skippingLanguageSpecifier';
          continue;
        }
      }
      // Fallback to checking first line inside the code block
      if ((line.trim().startsWith('//') || line.trim().startsWith('#')) && line.includes('.')) {
        const commentMatch = line.match(/\/\/\s*(\S+)/);
        if (commentMatch) {
          filename = commentMatch[1].trim();
          state = 'trimmingPostCommentLines';
          continue;
        }
      }
      state = 'ignoring';
    }

    if (state === 'skippingLanguageSpecifier') {
      state = 'trimmingLeadingLines';
      continue; // Skip the language specifier line
    }

    if (state === 'trimmingLeadingLines' || state === 'trimmingPostCommentLines') {
      if (line.trim() === '') {
        continue; // Skip empty lines
      } else {
        state = 'copying';
        currentBlock.push(line);
      }
    }

    if (state === 'copying') {
      currentBlock.push(line);
    }
  }

  // Handle any remaining block
  if (filename && state !== 'ignoring' && currentBlock.length > 0) {
    filesToWrite.set(filename, currentBlock);
  }

  // Write files to disk
  for (const [filePath, content] of filesToWrite) {
    const fullPath = path.resolve(writeRoot, filePath);
    try {
      await Bun.write(fullPath, content.join('\n'));
      console.log(`Wrote ${content.length} lines to file: ${filePath}`);
    } catch (err) {
      console.error(`Failed to write ${filePath}: ${err}`);
    }
  }
}

const args = process.argv.slice(2);
const useStdin = args.includes('--stdin');
const writeToGitroot = args.includes('--gitroot');

const contents = useStdin ? await Bun.stdin.text() : await clipboard.read();

// Run the processing
processFile(contents, writeToGitroot).catch((err) => {
  console.error('Error processing input:', err);
  process.exit(1);
});
