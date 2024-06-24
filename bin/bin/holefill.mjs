#!/usr/bin/env bun

// Adapted from https://github.com/VictorTaelin/AI-scripts

import process from "process";
import fs from 'fs/promises';
import path from 'path';
import { parseArgs } from "util";

const system = `You are a concise expert programming assistant.`;

const prompt_prefix = `
<instructions>
You are a HOLE FILLER. You are provided with a file containing holes, formatted
as '{{FILL_HERE}}'. Your TASK is to provide a string to replace this hole
with, inside a <completion/> XML tag, including context-aware indentation, if
needed. All completions MUST be accurate, well-written and correct. They must not
include the code surrounding the hole. Use the <thinking> tag to think about or describe the changes
if you need to.
</instructions>

<example>

<query>
function sum_evens(lim) {
  var sum = 0;
  for (var i = 0; i < lim; ++i) {
    {{FILL_HERE}}
  }
  return sum;
}
</query>
<completion>if (i % 2 === 0) {
      sum += i;
    }</completion>
</example>

<example>
<query>
def sum_list(lst):
  total = 0
  for x in lst:
  {{FILL_HERE}}
  return total

print sum_list([1, 2, 3])
</query>
<completion>  total += x</completion>
</example>

<example>
<query>
// data Tree a = Node (Tree a) (Tree a) | Leaf a

// sum :: Tree Int -> Int
// sum (Node lft rgt) = sum lft + sum rgt
// sum (Leaf val)     = val

// convert to TypeScript:
{{FILL_HERE}}
</query>
<completion>type Tree<T>
  = {$:"Node", lft: Tree<T>, rgt: Tree<T>}
  | {$:"Leaf", val: T};

function sum(tree: Tree<number>): number {
  switch (tree.$) {
    case "Node":
      return sum(tree.lft) + sum(tree.rgt);
    case "Leaf":
      return tree.val;
  }
}</completion>
</example>

<example>
<query>The 2nd {{FILL_HERE}} is Saturn.</query>
<completion>gas giant</completion>
</example>

<example>
<query>
function hypothenuse(a, b) {
  return Math.sqrt({{FILL_HERE}}b ** 2);
}
</query>
<completion>a ** 2 + </completion>
</example>

<formatting>
- Answer ONLY with the <completion/> block. Do NOT include anything outside it and do not include any comments inside it.
</formatting>
`;

const CHRONICLE_URL = process.env.CHRONICLE_URL || `http://localhost:9782/chat/completions`;

async function ask(message) {
  const response = await fetch(CHRONICLE_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: model,
      max_tokens: 2048,
      temperature: 0.5,
      messages: [
        {
          role: 'system',
          content: system,
        },
        {
          role: 'user',
          content: prompt_prefix + message,
        },
        {
          role: 'assistant',
          content: '<completion>',
        }
      ],
    })
  });
  const data = await response.json();
  const result = data.choices[0].message.content;
  return '<completion>' + result;
}

const { values } = parseArgs({
  options: {
    file: {
      type: 'string',
    },
    mini: {
      type: 'string',
    },
    model: {
      type: 'string',
      default: "anthropic/claude-3-5-sonnet-20240620"
    },
    'mini-cursor': {
      type: 'string',
      default: '',
    },
    cursor: {
      type: 'string',
      default: '',
    },
  },
  strict: true,
});

const { file, mini, model, cursor, 'mini-cursor': mini_cursor } = values;

let cursor_line;
let cursor_col;
if(cursor) {
  [cursor_line, cursor_col] = cursor.split(':');

  cursor_col ??= 0;
}

let mini_cursor_line;
if(mini && mini_cursor) {
  mini_cursor_line = mini_cursor.split(':')[0];
}

if (!file) {
  console.error("Usage: holefill <file> [<shortened_file>] [<model_name>]");
  console.error("");
  console.error("This will replace all {{HOLES}} in <file>, using GPT-4 / Claude-3.");
  console.error("A shortened file can be used to omit irrelevant parts.");
  process.exit();
}

let file_code = await fs.readFile(file, 'utf-8');
let mini_code = mini ? await fs.readFile(mini, 'utf-8') : file_code;

// await fs.writeFile(mini, mini_code, 'utf-8');

let holes = mini_code.match(/{{\w+}}/g) || [];

const SIMPLE_HOLE = '@@';

if (holes.length === 0 && mini_code.includes(SIMPLE_HOLE) && (mini_code.match(/@@/g) || []).length == 1) {
  holes = SIMPLE_HOLE;
} else {
  holes = SIMPLE_HOLE;

  let mini_lines = mini_code.split("\n");
  let file_lines = file_code.split("\n");

  cursor_col = cursor_col || 0;
  cursor_line = cursor_line || (file_lines.length - 1);
  mini_cursor_line = mini_cursor_line || (mini_lines.length - 1);

  mini_lines[mini_cursor_line] = mini_lines[mini_cursor_line].slice(0, cursor_col)
    + SIMPLE_HOLE
    + mini_lines[mini_cursor_line].slice(cursor_col);
  file_lines[cursor_line] = file_lines[cursor_line].slice(0, cursor_col)
    + SIMPLE_HOLE
    + file_lines[cursor_line].slice(cursor_col);

  mini_code = mini_lines.join("\n");
  file_code = file_lines.join("\n");
}

// Imports context files when //./path_to_file// is present.
let regex = /\/\/\.\/(.*?)\/\//g;
let match;
while ((match = regex.exec(mini_code)) !== null) {
  let import_path = path.resolve(path.dirname(file), match[1]);
  if (await fs.stat(import_path).then(() => true).catch(() => false)) {
    let import_text = await fs.readFile(import_path, 'utf-8');
    console.error("import_file:", match[0]);
    mini_code = mini_code.replace(match[0], '\n' + import_text);
  }
}

console.error("holes_found:", holes);
console.error("model:", model);

if (holes === SIMPLE_HOLE) {
    console.error(`next_filled: ${SIMPLE_HOLE}`);
    let prompt = "<query>\n" + mini_code.replace(SIMPLE_HOLE, "{{FILL_HERE}}") + "\n</query>";
    let answer = await ask(prompt);
    let match = answer.match(/<completion>([\s\S]*?)<\/completion>/);
    if (match) {
      file_code = file_code.replace(SIMPLE_HOLE, match[1]);
    } else {
      console.error("Error: Could not find <completion> tags in the AI's response.");
      console.error(answer);
      process.exit(1);
    }
} else {
  for (let hole of holes) {
    console.error("next_filled: " + hole + "...");
    let prompt = "<query>\n" + mini_code + "\n</query>";
    let answer = await ask(prompt);
    let match = answer.match(/<completion>([\s\S]*?)<\/completion>/);
    if (match) {
      file_code = file_code.replace(hole, match[1]);
      mini_code = mini_code.replace(hole, match[1]);
    } else {
      console.error("Error: Could not find <completion> tags in the AI's response for hole: " + hole);
      process.exit(1);
    }
  }
}

console.log(file_code);
