---
name: code-pattern-search
description: Search for specific code patterns across a codebase using ast-grep
license: MIT
compatibility: opencode
metadata:
  tool: ast-grep
  category: code-analysis
---

## What I Do
I help search for exact or structural code patterns in your codebase using ast-grep (sg). This is useful for finding instances of specific syntax, anti-patterns, or code structures without relying on text search.

## When to Use Me
- When you need to find all occurrences of a specific code pattern (e.g., function calls, variable declarations).
- For structural searches that text grep can't handle (e.g., nested expressions).
- Before refactoring to assess the scope of changes.

## How It Works
- Use `ast-grep --pattern '<pattern>' --lang <language>` for basic searches.
- Patterns can include meta variables like `$VAR` for wildcards.
- Supports multiple languages (see ast-grep docs for full list).

## Examples
- Search for console.log calls: `ast-grep -p 'console.log($$$)' -l js`
- Find variable declarations: `ast-grep -p 'var $NAME = $VALUE' -l js`

## Tips
- Enclose patterns in single quotes to avoid shell interpretation.
- Reference `.agent/ast-grep-guide.md` for advanced syntax.