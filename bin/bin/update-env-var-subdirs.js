#!/usr/bin/env node

const fs = require("node:fs/promises");
const path = require("node:path");

function parseArg(rawArg) {
  const eqIndex = rawArg.indexOf("=");
  if (eqIndex <= 0) {
    throw new Error("Argument must be in VAR=value format.");
  }

  const key = rawArg.slice(0, eqIndex);
  const value = rawArg.slice(eqIndex + 1);

  if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(key)) {
    throw new Error(`Invalid variable name: "${key}"`);
  }

  return { key, value };
}

function updateEnvContent(content, key, value) {
  const lines = content.split(/\r?\n/);
  const matcher = new RegExp(`^\\s*(?:export\\s+)?${key}\\s*=`);
  let replaced = false;
  const output = [];

  for (const line of lines) {
    if (matcher.test(line)) {
      if (!replaced) {
        output.push(`${key}=${value}`);
        replaced = true;
      }
      continue;
    }
    output.push(line);
  }

  if (!replaced) {
    output.push(`${key}=${value}`);
  }

  return output.join("\n");
}

async function fileExists(filePath) {
  try {
    const stat = await fs.stat(filePath);
    return stat.isFile();
  } catch {
    return false;
  }
}

async function main() {
  const rawArg = process.argv[2];
  if (!rawArg) {
    console.error("Usage: node update-env-var.js VAR=value");
    process.exit(1);
  }

  const { key, value } = parseArg(rawArg);
  const cwd = process.cwd();
  const entries = await fs.readdir(cwd, { withFileTypes: true });

  let updated = 0;
  for (const entry of entries) {
    if (!entry.isDirectory()) continue;

    const envPath = path.join(cwd, entry.name, ".env");
    if (!(await fileExists(envPath))) continue;

    const original = await fs.readFile(envPath, "utf8");
    const next = updateEnvContent(original, key, value);

    if (next !== original) {
      await fs.writeFile(envPath, next, "utf8");
      updated += 1;
      console.log(`Updated ${path.relative(cwd, envPath)}`);
    }
  }

  console.log(`Done. Updated ${updated} .env file(s).`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
