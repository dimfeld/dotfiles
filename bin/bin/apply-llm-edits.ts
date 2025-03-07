#!/usr/bin/env bun
/// <reference types="bun-types" />

/* Apply LLM whole-file blocks from copied LLM output.
 * This looks for blocks that start with a comment that looks like a filename,
 * and writes the contents to the path given in the comment, relative to the Git root.
 **/

import { $ } from 'bun';
import clipboard from 'clipboardy';
import * as path from 'path';

async function processFile(content: string) {
  // Split content into lines
  const lines = content.split('\n');
  let state: 'searching' | 'startCodeBlock' | 'trimmingPostCommentLines' | 'ignoring' | 'copying' =
    'searching';
  let currentBlock = [];
  let filename = null;
  const filesToWrite = new Map();
  const gitRoot = (await $`git rev-parse --show-toplevel`.text()).trim();

  // Process line by line
  for (const line of lines) {
    // Check for code block start/end
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
      }
      continue;
    }

    if (state === 'startCodeBlock') {
      // Check if first line is a filename comment
      if (
        currentBlock.length === 0 &&
        (line.trim().startsWith('//') || line.trim().startsWith('#')) &&
        line.includes('src/')
      ) {
        const commentMatch = line.match(/\/\/\s*(\S+)/);
        if (commentMatch) {
          filename = commentMatch[1].trim();
          state = 'trimmingPostCommentLines';
          continue; // Skip adding this line to content
        }
      }

      // We didn't find a filename comment, so ignore the rest of the block
      state = 'ignoring';
    }

    if (state === 'trimmingPostCommentLines') {
      // Skip empty lines after the first comment
      if (line.trim() === '') {
        continue;
      } else {
        state = 'copying';
      }
    }

    if (state === 'copying') {
      currentBlock.push(line);
    }
  }

  // Write files
  for (const [filePath, content] of filesToWrite) {
    const fullPath = path.resolve(gitRoot, filePath);
    try {
      await Bun.write(fullPath, content.join('\n'));
      console.log(`Wrote ${content.length} lines to file: ${filePath}`);
    } catch (err) {
      console.error(`Failed to write ${filePath}: ${err}`);
    }
  }
}

const args = process.argv.slice(2); // Skip node and script path
const useStdin = args.includes('--stdin');

const contents = useStdin ? await Bun.stdin.text() : await clipboard.read();

// Run the processing
processFile(contents).catch((err) => {
  console.error('Error processing stdin:', err);
  process.exit(1);
});
