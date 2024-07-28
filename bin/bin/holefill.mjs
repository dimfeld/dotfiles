#!/usr/bin/env bun

// Heavily modified from https://github.com/VictorTaelin/AI-scripts

import process from "process";
import fs from 'fs/promises';
import path from 'path';
import { parseArgs } from "util";

const system = `You are a concise expert programming assistant.`;

const templates = {
  hole_fill: {
    instruction: `You are a hole filler. You are provided with a file containing a hole, whose position
    is indicated with an <update/> XML tag. Your task is to provide a string to fill in the hole.
    This string should be inside a <completion/> XML tag, including context-aware indentation, if
    needed. If you see an <operation> tag, it will describe how to generate the completion. Otherwise the completion should be inferred solely from
    the surrounding content. All completions MUST be accurate, well-written and correct. They must not include the code surrounding the hole.`,
    examples: [
`<query>
function sum_evens(lim) {
  var sum = 0;
  for (var i = 0; i < lim; ++i) {
    <update/>
  }
  return sum;
}
</query>
<completion>if (i % 2 === 0) {
      sum += i;
    }</completion>`,

`<query>
def sum_list(lst):
  total = 0
  for x in lst:
  <update/>
  return total

print sum_list([1, 2, 3])
</query>
<completion>  total += x</completion>`,

`<query>
// data Tree a = Node (Tree a) (Tree a) | Leaf a

// sum :: Tree Int -> Int
// sum (Node lft rgt) = sum lft + sum rgt
// sum (Leaf val)     = val
<update/>
</query><operation>Convert the above to Typescript</operation>
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
}</completion>`,

`<query>The 2nd <update/> is Saturn.</query>
<completion>gas giant</completion>`,

`<query>
function hypothenuse(a, b) {
  return Math.sqrt(<update/>b ** 2);
}
</query>
<completion>a ** 2 + </completion>`,
    ]
  },
  update_region: {
    instruction: `You are provided with a file in a <query> tag, an <update> tag within the <query> containing code to update,
      and an <operation> tag describing how to update the code inside <update>. Your task is to perform the given operation on the updated code
      and return the result inside a <completion/> XML tag, including context-aware indentation, if needed. All completions MUST be accurate,
      well-written, and correct, and must not include code from outside the region.`,
    examples: [

`<query>
function sum_evens(lim) {
  var sum = 0;
  <update>for (var i = 0; i < lim; ++i) {
    sum += i;
  }</update>
  return sum;
}
</query><operation>Fix this code</operation>
<completion>for (var i = 0; i < lim; ++i) {
      if (i % 2 === 0) {
        sum += i;
      }
    }</completion>`,
`<query>
def count_vowels(string):
  count = 0
  for char in string:
<update>    if char in 'aeiou':
      count =+ 1</update>
  return count

def main():
  string = input()
  count = count_vowels(string)
  print(count)
</query><operation>Count consonants</operation>
<completion>    if char not in 'aeiou':
      count =+ 1</completion>`,

`<query>
function sum_list(lst) {
  total = 0
<update>  for x in lst:
    total += x</update>
  return total
}
</query><operation>Use a comprehension instead</operation>
<completion>  total = sum(x for x in lst)</completion>`,

`<query>
bool isPalindrome(string str) {
<update>  int left = 0;
  int right = str.length();
  while (left < right) {
    if (str[left] != str[right]) {
        return false;
    }
    left++;
    right--;
  }</update>

  return true;
}
</query><operation>Fix this code</operation>
<completion>  int left = 0;
  int right = str.length() - 1;
  while (left < right) {
    if (str[left] != str[right]) {
        return false;
    }
    left++;
    right--;
  }</completion>`
    ]
  }
};

function joinStr(string) {
  return string
    .split('\n')
    .map((line) => line.trim())
    .join(' ');
}

const prompt_prefix = (template) => `
<instructions>
  ${joinStr(template.instruction)}
  Use the <thinking> tag to think about or describe the changes if you need to.
</instructions>

${template.examples.map((example) => '<example>\n' + example + '\n</example>').join('\n\n')}

<formatting>
- Answer ONLY with the <completion/> block. Do NOT include anything outside it except the optional <thinking>.
- Any comments inside <completion/> must be written in the same programming language as the rest of the file.
</formatting>

`;

let CHRONICLE_URL = process.env.CHRONICLE_URL || `http://localhost:9782/chat/completions`;

async function ask(template, message) {
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
          content: prompt_prefix(template) + message,
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
    model: {
      type: 'string',
      default: "anthropic/claude-3-5-sonnet-20240620"
    },
    'chronicle-url': {
      type: 'string',
      default: process.env.CHRONICLE_URL || 'http://localhost:9782/chat/completions',
    },
    operation: {
      type: 'string',
    },
    cursor: {
      type: 'string',
      default: '',
    },
    'cursor-end': {
      type: 'string',
      default: ''
    }
  },
  strict: true,
});

const { file, model, cursor, 'cursor-end': cursor_end, operation } = values;
CHRONICLE_URL = values['chronicle-url'] || CHRONICLE_URL;

if (!file || !cursor) {
  console.error("Usage: holefill --file <file> [--model <model_name>]");
  console.error("");
  console.error("This will replace an <update/> tag in <file>, using GPT-4 / Claude-3.");
  process.exit(1);
}

let cursorLine;
let cursorCol;
if(cursor) {
  [cursorLine, cursorCol] = cursor.split(':').map(Number);
  cursorCol ??= 0;
}

let cursorEndLine;
let cursorEndCol;
if(cursor_end) {
  [cursorEndLine, cursorEndCol] = cursor_end.split(':').map(Number);
  cursorEndCol ??= 0;
} else {
  cursorEndLine = cursorLine;
  cursorEndCol = cursorCol;
}

// Make sure the cursors are in the right order.
if(cursorEndLine < cursorLine) {
  [cursorLine, cursorEndLine] = [cursorEndLine, cursorLine];
  [cursorCol, cursorEndCol] = [cursorEndCol, cursorCol];
} else if(cursorEndLine === cursorLine && cursorEndCol < cursorCol) {
  [cursorCol, cursorEndCol] = [cursorEndCol, cursorCol];
}


const updateRegion = cursor_end && cursor !== cursor_end;
const template = templates[updateRegion ? 'update_region' : 'hole_fill']

let fileCode = await fs.readFile(file, 'utf-8');
let fileLines = fileCode.split('\n');
let queryLines = [...fileLines];

if(updateRegion) {
  // Update the end line first so that in case both cursors are on the same line, the first tag won't mess up the
  // placement of the end tag.
  queryLines[cursorEndLine] = queryLines[cursorEndLine].slice(0, cursorEndCol)
    + '</update>'
    + queryLines[cursorEndLine].slice(cursorEndCol);

  queryLines[cursorLine] = queryLines[cursorLine].slice(0, cursorCol)
    + '<update>'
    + queryLines[cursorLine].slice(cursorCol);
} else {
  queryLines[cursorLine] = queryLines[cursorLine].slice(0, cursorCol)
    + '<update/>'
    + queryLines[cursorLine].slice(cursorCol);
}

let queryCode = queryLines.join('\n');

// Imports context files when //./path_to_file// is present.
let regex = /\/\/\.\/(.*?)\/\//g;
let importMatch;

while ((importMatch = regex.exec(queryCode)) !== null) {
  let importPath = path.resolve(path.dirname(file), importMatch[1]);
  if (await fs.stat(importPath).then(() => true).catch(() => false)) {
    let importText = await fs.readFile(importPath, 'utf-8');
    console.error("import_file:", importMatch[0]);
    queryCode = queryCode.replace(importMatch[0], '\n' + importText);
  }
}

console.error("model:", model);


let prompt = "<query>\n" + queryCode + "\n</query>";
if(operation) {
  prompt += `<operation>${operation}</operation>`
}

let answer = await ask(template, prompt);
let completionMatch = answer.match(/<completion>([\s\S]*?)<\/completion>/);
if (completionMatch) {
  let insertText = completionMatch[1];

  let beforeLines = queryLines.slice(0, cursorLine);
  let afterLines = queryLines.slice(cursorEndLine + 1);

  if(updateRegion) {
    let beginLine = queryLines[cursorLine].slice(0, cursorCol);
    let endLine = queryLines[cursorEndLine].slice(cursorEndCol);

    // insert_text may be multiple lines but that's ok, we can just have the newlines on a single line.
    let outputLine = beginLine + insertText + endLine;
    let output = [...beforeLines, outputLine, ...afterLines].join('\n');
    console.log(output)
  } else {
    let currentLine = queryLines[cursorLine];
    let outputLine = currentLine.slice(0, cursorCol) + insertText + currentLine.slice(cursorCol);
    let output = [...beforeLines, outputLine, ...afterLines].join('\n');
    console.log(output)
  }

} else {
  console.error("Error: Could not find <completion> tags in the AI's response.");
  console.error(answer);
  process.exit(1);
}
