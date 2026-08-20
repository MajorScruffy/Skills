---
name: custom-linting
description: Create custom lint rules and fix linting errors using ast-grep
license: MIT
compatibility: opencode
metadata:
  tool: ast-grep
  category: linting
---

## What I Do
I analyze linting errors from failed commits, determine fixes via ast-grep refactoring, and create new rules to prevent recurrence. Reads ast-grepconfig.yml for folder locations.

## When to Use Me
- When a commit fails due to linting errors (e.g., pre-commit hooks).
- To fix detected issues with automated refactoring.
- Create rules for new patterns that should be linted.

## How It Works
- Read ast-grepconfig.yml to find ruleDirs (e.g., /home/stef/Work/PriceLib/.ast-grep/rules).
- Analyze the lint error (e.g., pattern causing failure).
- Create a refactoring: `ast-grep run -p '<bad-pattern>' -r '<good-pattern>' --update-all` to fix.
- Create a new rule: `ast-grep new rule <name>` in the rule dir.
- Edit the rule YAML to match the bad pattern, add message/severity.
- Test: `ast-grep test` or `ast-grep scan --rule <new-rule>`.
- Commit the fixes and new rule.

## Examples
- Error: "console.log found" -> Refactor: `ast-grep run -p 'console.log($$$)' -r 'logger.info($$$)' --update-all`
  - New rule: `ast-grep new rule ban-console-log`, edit to flag `console.log($$$)` with message "Use logger instead".
- Error: Async in loop -> Refactor to extract async, create rule to detect.

## Tips
- Always check ast-grepconfig.yml for correct paths.
- Use `--update-all` for batch fixes after preview.
- Rules prevent future errors; test with `ast-grep scan`.
- For complex fixes, use YAML rules with fixes.
- Reference `.agent/ast-grep-guide.md` for patterns and rules.