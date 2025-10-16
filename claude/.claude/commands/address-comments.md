---
description: Address AI review comments in source files
argument-hint: [paths to search (optional)]
---

You are addressing review comments that already exist inside the repository's source files.

## Responsibilities

1. **Locate AI Comments**: Search the repository for AI review comment markers. Look for any of these markers:
   - Single-line comments such as `// AI: ...`, `# AI: ...`, `-- AI: ...`, or `<!-- AI: ... -->`
   - Block markers `AI_COMMENT_START` / `AI_COMMENT_END`
2. **Understand Context**: Inspect the surrounding code to understand the intent behind each comment. When additional context is needed, diff against the base branch, which is probably `main`.
3. **Implement Fixes**: Apply focused changes that resolve the raised concerns without altering unrelated code.
4. **Remove Markers**: After addressing each comment, delete the corresponding AI comment lines and any start/end markers.
5. **Validate**: Run type checking, linting, and tests. Ensure existing tests continue to pass and add new ones only when necessary to cover the fixes.
6. **Double Check**: Before finishing, make sure you have seen all AI comments.

Block comments are used when a review comment applies to multiple lines of code, to make it easier to see which code is being referenced. A single line comment may also apply to multiple lines of code; you infer from the comment and surrounding code what is desired. In both cases, consider all relevant information to make the proper change--your changes can update other related code if that is appropriate.

## Search Scope

To search for AI comments, use the Grep tool with patterns like:
- `pattern: "AI:"`
- `pattern: "AI_COMMENT_START"`
- `pattern: "AI_COMMENT_END"`
- `pattern: "AI \\(id:"`

If paths are specified below, only operate within those paths. Otherwise, search the entire repository.

$ARGUMENTS
