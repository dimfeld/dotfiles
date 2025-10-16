---
description: "Add cleanup plans"
argument-hint: [focus]
---

Examine the code in this repository and identify cleanup opportunities. Look for:

**Code Quality**
- Duplicated code that could be consolidated into shared utilities
- Dead code: unused functions, variables, imports, or entire files
- Inconsistent patterns: different approaches to the same problem across the codebase
- Magic numbers/strings that should be named constants
- Overly complex functions that could be simplified or split

**Technical Debt**
- TODO/FIXME comments that should be addressed
- Deprecated APIs or patterns still in use
- Workarounds that are no longer necessary
- Legacy code that doesn't follow current project conventions

**Type Safety & Error Handling**
- Uses of `any` type that could be properly typed
- Missing or inconsistent error handling
- Unsafe type assertions that could be replaced with type guards

**Architecture & Organization**
- Poor module boundaries or circular dependencies
- Files in incorrect locations based on project structure
- Tightly coupled code that should be decoupled
- Missing abstractions that would simplify multiple call sites

**Dependencies**
- Unused dependencies
- Duplicate packages serving the same purpose

**Testing**
- Important code paths lacking test coverage
- Flaky or poorly written tests
- Test utilities or setup code that could be shared

Focus on changes that provide meaningful improvements. Prioritize issues that:
1. Affect multiple parts of the codebase
2. Could cause bugs or maintenance burden
3. Make the code harder to understand

Use `rmplan add` to add plans for the cleanup tasks you find. Each plan should be focused on a single cohesive improvement.
