#!/usr/bin/env bun
/// <reference types="bun-types" />
import { $ } from 'bun';
import path from 'node:path';
import { packageUp } from 'package-up';
import { chdir } from 'process';
import { parseArgs } from 'util';
import * as changeCase from 'change-case';

let { values, positionals } = await parseArgs({
  options: {
    packages: {
      type: 'string',
      multiple: true,
      short: 'p',
    },
    upstream: {
      type: 'string',
      multiple: true,
      short: 'u',
    },
    downstream: {
      type: 'string',
      short: 'd',
      multiple: true,
    },
    both: {
      type: 'string',
      short: 'b',
      multiple: true,
    },
    grep: {
      type: 'string',
      short: 'g',
      multiple: true,
    },
    'grep-package': {
      type: 'string',
      short: 'G',
      multiple: true,
    },
    expand: {
      type: 'boolean',
      short: 'e',
    },
    'no-compress': {
      type: 'boolean',
    },
    help: {
      type: 'boolean',
      short: 'h',
    },
  },
  allowPositionals: true,
  allowNegative: true,
});

if (values.help) {
  console.log('usage: repomix-package.ts <packages>');
  console.log();
  console.log('Options:');
  console.log('  -p, --packages <packages>   Include the contents of these packages');
  console.log('  -u, --upstream <packages>   Include this packages and its dependencies');
  console.log('  -d, --downstream <packages> Include this package and its dependents');
  console.log(
    '  -b, --both <packages>       Include the package and its upstream and downstream dependencies'
  );
  console.log('  -g, --grep <patterns>       Include files that match this pattern');
  console.log(
    '  -G, --grep-package <pkg>    Include all packages with a file that matches ths pattern'
  );
  console.log(
    '  -e, --expand                Expand search terms to include snake case, camel case, etc.'
  );
  console.log('  --no-compress              Tell repomix to compress the output');
  console.log('  -h, --help                  Show this help message and exit');
  process.exit(0);
}

const gitRoot = (await $`git rev-parse --show-toplevel`.text()).trim();
chdir(gitRoot);

async function getDeps(packages: string[] | undefined, mode: 'upstream' | 'downstream' | 'only') {
  if (!packages?.length) {
    return [];
  }

  let args = packages.flatMap((pkg) => {
    let filter: string;
    if (mode === 'upstream') {
      filter = `${pkg}...`;
    } else if (mode === 'downstream') {
      filter = `...${pkg}`;
    } else {
      filter = pkg;
    }
    return ['-F', filter];
  });

  // console.log('running turbo ls', args);
  let proc = Bun.spawn(['turbo', 'ls', '--output', 'json', ...args]);
  let output = await new Response(proc.stdout).json();
  // console.log(args, output);

  return output.packages.items.map((p) => p.path);
}

function expandPattern(pattern: string) {
  return [changeCase.snakeCase(pattern), changeCase.camelCase(pattern)];
}

async function grepFor(patterns: string[] | undefined, mode: 'file' | 'package') {
  if (!patterns?.length) {
    return [];
  }

  if (values.expand) {
    patterns = patterns.flatMap(expandPattern);
  }

  let args = patterns.flatMap((pattern) => ['-e', pattern]);
  let proc = Bun.spawn(['rg', '-i', '--files-with-matches', ...args]);
  let results = await new Response(proc.stdout).text();

  let files = results
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean);

  if (mode === 'file') {
    return files;
  }

  let packagePaths = await Promise.all(
    files.map((file) =>
      packageUp({
        cwd: path.dirname(file),
      })
    )
  );

  let packageDirs = new Set(
    packagePaths
      .map((p) => {
        if (!p) {
          return;
        }

        let dir = path.dirname(p);
        let relDir = path.relative(gitRoot, dir);
        if (relDir === '') {
          return;
        }

        return relDir;
      })
      .filter((p) => p != null)
  );

  return [...packageDirs];
}

let upstream = [...(values.upstream ?? []), ...(values.both ?? [])];
let downstream = [...(values.downstream ?? []), ...(values.both ?? [])];

if (!upstream.length && !downstream.length && !values.packages?.length && !values.grep?.length) {
  console.log('no packages or grep strings specified');
  process.exit(0);
}

let pathsSet = new Set(
  (
    await Promise.all([
      getDeps(upstream, 'upstream'),
      getDeps(downstream, 'downstream'),
      getDeps(values.packages, 'only'),
      grepFor(values.grep, 'file'),
      grepFor(values['grep-package'], 'package'),
    ])
  ).flat()
);

let allPaths = Array.from(pathsSet).join(',');
console.log(allPaths);
// console.log('repomix', allPaths, ...positionals);
await Bun.spawn(['repomix', '--ignore', '*.sql', '--include', allPaths, ...positionals], {
  stdout: 'inherit',
  stderr: 'inherit',
}).exited;
