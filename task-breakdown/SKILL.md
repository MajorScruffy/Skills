---
name: task-breakdown
description: >-
  Break a design into agent-ready implementation tasks with parallel waves,
  file ownership, and testable acceptance criteria. Writes docs/plans/<feature>/
  with design.md and tasks.md. Use when the user asks for a task breakdown,
  agent implementation plan, decompose a feature, or break a design into tasks
  before parallel agent work.
disable-model-invocation: true
---

# Task Breakdown

Turn a design into a task graph agents can implement independently — one task, one PR, one agent session.

## Hard rules

- **Vague input → `grill-me` first.** Do not invent architecture.
- **Planning only.** No code, branches, commits, PRs, or other agents.
- **Write-once snapshot.** Do not reconcile inside this skill. Agents maintain `design.md` during implementation. Humans redirect agents when plans drift — 
- **Explore the codebase first.** Read similar features, tests, module boundaries, and `AGENTS.md` so `Touches` and pattern references are accurate.
- **Write files directly** to `docs/plans/<feature-slug>/`. Human reviews and requests edits.

## Steps

1. Normalize input into `design.md` (format below).
2. Explore the codebase; inject findings into each task's Context and Implementation notes.
3. Put unresolved forks in Wave 0 as `[DECISION REQUIRED]` tasks.
4. Decompose interface-first: contracts, then parallel implementations, then integration tests.
5. Write `tasks.md` with a Mermaid graph and task blocks grouped by wave.

## design.md

```markdown
# [Feature name]

## Goal
[North star paragraph]

## Scope
- ...

## Non-goals
- ...

## Interfaces
[Types, API shapes, schemas, shared contracts]

## Constraints
- [AGENTS.md and repo conventions]

## Open questions
- [Unresolved forks → Wave 0 tasks]
```

Restructure pasted specs into these sections. Chat is not the north star.

## Decomposition

**Size:** Ideally, ~200–500 LOC per task, but not a hard rule. Split larger work before assignment.

**Waves:**

| Wave | Content |
|------|---------|
| 0 | `[DECISION REQUIRED]` tasks — human only |
| 1 | Schemas, types, traits, route stubs |
| 2+ | Implementations against frozen interfaces |
| Final | Integration tests — one concern per task |

**Parallelism:** Tasks in the same wave may run in parallel only when `Touches` lists are disjoint. Wave 1 defines contracts; later waves must not edit those signatures.

**Branches:** `feat/<short-slug>` off `main`.

**Tests:** Code tasks include unit tests in the same PR. Integration/E2E tests get dedicated final-wave tasks only.

## tasks.md

Open with a short summary and Mermaid dependency graph. Group task blocks under `## Wave N` headers.

```markdown
# [Feature name] — Task breakdown

## Summary
[N tasks, key parallel opportunities]

## Dependency graph

\`\`\`mermaid
graph TD
  T001[TASK-001: Types] --> T002
  T001 --> T003
  T002 --> T004
  T003 --> T004
\`\`\`

## Wave 1 — Contracts
[task blocks]

## Wave 2 — Implementation
[task blocks]
```

### Task block

Use `TASK-001` IDs with a descriptive title slug.

```markdown
### TASK-003: Add cancel HTTP handler

**Depends on:** TASK-001, TASK-002
**Branch:** `feat/order-cancel-handler`
**Touches:** `backend/src/orders/handlers/cancel.rs`, `backend/src/orders/routes.rs`

#### Goal
One sentence: what exists when this PR merges.

#### Context
- Read: `design.md` §Interfaces
- Follow: `backend/src/orders/handlers/create.rs`
- Do not start until TASK-001 is resolved (when applicable)

#### Implementation notes
Concrete steps — not "implement cancel".

#### Acceptance criteria
- [ ] [Specific verifiable behavior]
- [ ] Full unit test suite added for [module/feature]
- [ ] `[exact test command]` passes

#### Out of scope
- [Explicit exclusions]
```

Checkbox acceptance criteria only. Every code task requires a unit-test criterion and a runnable verify command.

### DECISION REQUIRED (Wave 0)

```markdown
### TASK-001: [DECISION REQUIRED] HTTP status for filled-order cancel

**Decision:** 409 Conflict or 422 Unprocessable?
**Options:**
1. 409 — state conflict
2. 422 — semantic validation failure

**Unblocks:** TASK-002, TASK-003

#### When resolved
1. Resolve via `grill-me` or chat; update `design.md`
2. Human instructs agents to update dependent tasks
3. Remove `[DECISION REQUIRED]` and fill in Implementation notes
```

Dependent tasks must say *Do not start until TASK-XXX is resolved.* 

## Revision

Preserve task IDs; add new IDs for new tasks rather than renumbering.
