---
name: data-oriented
description: >
  Write data-oriented code — data sheet, batch transforms, tables and IDs.
  Use when the user says data-oriented, DOD, SoA, or /data-oriented, or
  writes a game loop, particles, simulation, renderer, or physics.
---

# Data-oriented

Programs transform data. Types fall out of the loop.

## Persistence

ACTIVE EVERY RESPONSE. Still active if unsure. Off only: "stop data-oriented"
/ "normal mode".

## Process

Do not write types until 1–4 each have a concrete answer. Then write only
that code.

1. **Data sheet** — every record the change touches: how many (typical, max,
   cap), bytes, how often, access (scan / lookup / insert / delete), which
   fields the hot loop touches together, lifetime, producer → consumer.
   Existing tables in this codebase that already hold this data → use them.
2. **Inner loop** — the transform the CPU should run: bytes in, bytes out,
   count. Name it after the bytes (`integrate_velocities`, `cull_visible`).
3. **Layout** — homogeneous arrays. AoS when the loop uses most fields; SoA
   when it uses one or two of many; hot fields together, cold elsewhere.
   Done when a reader can say which array each field lives in.
4. **Caps** — a number for `MAX_*`. Allocate outside the transform. Free with
   swap-remove, arena reset, or generational handles.

## Rules

- The unit of work is a batch. `n = 1` still calls the batch API.
- An entity is an integer. Its fields live in tables keyed by that id.
- Presence is a table. Scan the smaller table; partition, then stream.
- Same data, same code. Unlike records live in another array, not under a
  base type.
- A stage writes a table the next stage reads.
- Cost is cache lines, branches, allocations, and pointer chases. A chase is
  allowed when the data requires it.
- Different data is a different problem.

## Output

Code first. One line per table if the sheet is not obvious from the code:
`pos n≤4096 stride=12B scan=1/frame`.
Arrays until the sheet names more tables than you can keep as arrays.

## Boundaries

Few-and-cold records (CRUD, UI, one-off config) stay ordinary code. Extra
tables, IDs, or SoA for small cold data are the bug.

User wants objects → write the objects, one line naming the table form.

Ponytail (if active) picks the lazy solution; this skill picks the layout.

On every coding turn: sheet, loop, layout, caps, then the code.
