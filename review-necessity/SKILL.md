---
name: review-necessity
description: Strict simplicity review. Ensures every change is written in its simplest form — fewest concepts, clearest shape, same behavior. Use after completing any implementation task, before marking work done, when reviewing diffs for unnecessary complexity, or when the user asks for a necessity review.
disable-model-invocation: true
---

# Review Necessity

## Workflow

1. **Review** session changes using `git diff --cached` and `git diff`. Do not run `git add` or restage files.
2. **Fix** all blockers. Fixes must remain unstaged; include them via `git diff` when re-checking.

For every **changed or net-new** variable, parameter, function, and file, ask:

1. **Do we really need it?**
2. **Is there a simpler, more elegant way to do this?**

If a simpler form achieves the same outcome, that form is required. Prefer the shape a reader would expect on first read.

Scope: symbols and files **introduced or modified in the session diff** (`git diff --cached` plus any unstaged fixes from this pass). Do not nitpick unchanged pre-existing code unless the change makes it redundant.

## Exception: parameterized tests

Do **not** treat parameterized tests as blockers. Do not convert `#[test_case(...)]` (or equivalent) to `for` loops, or split them into duplicate `#[test]` functions solely because a loop could express the same cases. Parameterized tests are the simple pattern.

## Three Tests (in order)

1. **Simplest-form test** — Is this the least complex version that preserves behavior? Can it be collapsed, inlined, merged, or replaced with something already in the codebase?
2. **Existing-pattern test** — Does this codebase already express this more simply elsewhere?
3. **YAGNI test** — Does this solve a problem we have today, not one we might have?

If any test fails, rewrite to the simpler form before approving.
**Blocking.** Do not approve or mark work complete while any finding remains.

Presumptive blockers unless clearly justified:

- A changed/new symbol survives the deletion test
- A simpler equivalent exists in-repo or in the diff's local context
- A parameter, helper, file, or dependency exists only because of an avoidable design choice
- The same outcome is achievable with fewer concepts

If blockers remain, fix them or leave explicit actionable feedback. "Good enough" is not acceptable for this pass.

Each finding: **element → why it is not simplest → simpler form → why it is equivalent**.
