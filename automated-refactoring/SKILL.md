---
name: automated-refactoring
description: Perform automated code refactoring using ast-grep patterns
license: MIT
compatibility: opencode
metadata:
  tool: ast-grep
  category: refactoring
---

## What I Do
I assist with automated code transformations using ast-grep's pattern matching and rewrite capabilities. This enables safe, structural refactoring of code patterns across large codebases.

## When to Use Me
- To replace old patterns with new ones (e.g., var to let, defensive checks to optional chaining).
- For systematic code modernization or migration.
- When manual refactoring is error-prone or time-consuming.

## How It Works
- Define a pattern to match and a replacement.
- Run `ast-grep run -p '<pattern>' --rewrite '<replacement>' --lang <language> --update-all` to apply all changes directly.
- Optional: Preview first with `ast-grep run -p '<pattern>' --rewrite '<replacement>' --lang <language>` to see proposed changes before applying.

## Examples
- Convert var to let: `ast-grep run -p 'var $V = $E' -r 'let $V = $E' -l js --update-all`
- Optional chaining: `ast-grep run -p '$OBJ && $OBJ()' -r '$OBJ?.()' -l js --update-all`

## Tips
- Preview changes first for safety.
- Test patterns with search-only (`ast-grep run -p 'pattern'`) before rewriting.
- Back up code or commit before large refactors.
- Use meta variables for flexible matching.
- Reference `.agent/ast-grep-guide.md` for advanced syntax.