---
name: review-code-quality
description: Run an extremely strict maintainability review for abstraction quality, giant files, and spaghetti-condition growth. Use for a thermo-nuclear code quality review, thermonuclear review, deep code quality audit, or especially harsh maintainability review.
disable-model-invocation: true
---

# Thermo-Nuclear Code Quality Review

Audit the current branch's changes for maintainability. Preserve behavior, but prefer restructurings that **delete complexity** rather than rearrange it. Think at the **flow and module level first**, not individual methods.

## Clean-Room Decomposition Test

Before nitpicking helpers or local control flow, run this on each meaningful flow the diff touches:

1. Mentally **inline** the whole flow into one straight sequence of steps.
2. **Redesign the decomposition from scratch** — modules, ownership, orchestration vs business logic — using normal software design practice.
3. Ask: **Would we still end up with the same methods and boundaries?**

- **No** → the current shape is likely accidental history, not the problem's natural seams. Push for a top-level restructure, not patches to existing helpers.
- **Yes** → the decomposition is probably sound; limit feedback to regressions within that shape.

Do not approve incremental helper sprawl when a clean-room redesign would produce a different, simpler structure.

## Seven Principles

1. **Code judo** — Reframe until branches, helpers, modes, conditionals, or layers disappear. Prefer deleting complexity over polishing it. Use the clean-room test above to find the move.
2. **No 1k sprawl** — Do not let a PR push a file from under 1000 lines to over 1000 without strong justification. Decompose first.
3. **No spaghetti growth** — Treat ad-hoc conditionals and scattered special cases in unrelated flows as design problems, not nits.
4. **Design over "it works"** — Do not rubber-stamp working code that leaves the codebase messier. Prefer removing moving pieces over spreading complexity around.
5. **Direct over magic** — Flag brittle abstractions, thin wrappers, pass-through helpers, and generic mechanisms that hide simple structure.
6. **Clean boundaries** — Prefer explicit types and contracts over casts, `any`, `unknown`, unnecessary optionality, and silent fallbacks.
7. **Right layer, atomic flow** — Keep logic in the canonical module, reuse existing helpers, and fix avoidably sequential or half-applied updates.

## Review Procedure

Run this pass on every meaningful change:

1. **Run the clean-room decomposition test** on the affected flow(s) before reviewing individual methods.
2. **Scan for structural regression** — file size, coupling, scattered conditionals, feature logic in shared paths.
3. **Ask the code-judo question** — Is there a reframing that deletes whole branches or layers?
4. **Check boundaries** — types, module ownership, duplication of canonical helpers, orchestration shape.
5. **Propose the smallest high-impact restructuring** — flow-level first; not rename-only or method-level cosmetic feedback.

For large or ambiguous diffs, read [reference.md](reference.md) before finishing the review.

## Output

Prioritize findings in this order:

1. Wrong flow decomposition (clean-room test fails)
2. Structural regressions
3. Missed code-judo / simplification opportunities
4. Spaghetti / branching growth
5. Boundary, abstraction, and type-contract problems
6. File-size and decomposition concerns
7. Legibility and maintainability

Each finding: **problem → why it matters → concrete restructuring**.

Prefer a small number of high-conviction comments. Skip method-level nits when the flow decomposition itself is wrong. Do not flood the review with low-level notes when structural issues exist.

## Tone

Be direct and demanding about quality without being rude. Say clearly when code makes the codebase messier or misses an obvious simplification.

## Approval Bar

Do not approve merely because behavior seems correct. Presumptive blockers unless clearly justified:

- Clean-room test fails: a fresh decomposition would produce different, simpler boundaries
- Visible code-judo path not taken while incidental complexity remains
- File crosses 1000 lines without decomposition
- Ad-hoc branching or scattered feature checks tangling shared flows
- Unnecessary abstraction, wrapper, or cast-heavy contract obscuring the model
- Duplicated helper or logic placed outside its canonical layer
- Obvious decomposition skipped when it would materially improve maintainability

If blockers remain, leave explicit, actionable feedback and push for cleaner structure.

## Additional Resources

- Full checklist, flag catalog, remedy patterns, and comment phrasing: [reference.md](reference.md)
