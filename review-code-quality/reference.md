# Thermo-Nuclear Review Reference

Use this file for large diffs, ambiguous changes, or when the main pass surfaces structural issues worth expanding.

## Clean-Room Decomposition Test

Apply this before method-level feedback.

### The test

For each meaningful flow the diff touches:

1. **Inline** — mentally flatten the flow: unwrap helpers, collapse indirection, and read it as one sequential story of what happens.
2. **Redesign** — from that inlined story, carve out modules and methods again using normal design practice:
   - one clear responsibility per unit
   - boundaries that match domain concepts, not file history
   - orchestration separated from business logic
   - minimal cross-cutting special cases
3. **Compare** — would a competent clean-room redesign land on the **same** methods, modules, layers, and ownership boundaries?

### How to interpret the answer

**No — push for top-level restructuring**

The current decomposition is probably accidental: incremental patches, copy-paste extraction, or diff-driven helpers. Do not settle for polishing the existing helpers. Propose the decomposition a fresh design would produce.

Common signals the answer is "no":

- Helpers named after when they were introduced, not what they do
- A method that is mostly glue between two unrelated concerns
- The same logical step split across several files with no domain reason
- Several helpers that would merge into one step in a clean redesign
- Orchestration scattered through leaf helpers instead of one obvious coordinator
- Boundaries that exist only because a previous PR needed a small hook

**Yes — keep feedback within the existing shape**

The flow's seams are likely right. Focus on regressions inside that structure: spaghetti branches, type slop, duplication, size, wrong layer — not re-decomposing for its own sake.

### What to compare

When running the test, compare at these levels (not just function size):

- **Method boundaries** — do cuts fall on natural steps, or on arbitrary line blocks?
- **Module ownership** — does each concept live where a reader would look for it?
- **Local architecture** — did a cohesive module become more coupled, stateful, or harder to scan?
- **Data flow** — does state pass through the minimum number of shapes and hops?
- **Orchestration vs logic** — is "what runs when" separated from "what each step means"?
- **Special cases** — would a clean design absorb them into the default path or isolate them in one place?
- **Missing model** — do repeated conditionals signal a helper or typed model that a clean redesign would introduce?

### Anti-patterns in reviewing

- Commenting on a helper's internals when the helper should not exist
- Suggesting a rename or micro-extract when the whole flow should be re-owned
- Treating each new method as a valid abstraction without asking why that cut exists
- Approving "one more small helper" when the clean-room test already says the flow wants fewer, different pieces

## Principle Details

### Code judo

- Do not stop at "this could be a bit cleaner."
- Start with the clean-room decomposition test; the code-judo move is often a different set of boundaries, not a tweak inside the current ones.
- Look for opportunities to reframe the change so that whole branches, helpers, modes, conditionals, or layers disappear entirely.
- Prefer the solution that makes the code feel inevitable in hindsight.

### No 1k sprawl

- Treat crossing 1000 lines as a strong code-quality smell by default.
- Prefer extracting helpers, subcomponents, modules, or local abstractions.
- If the diff crosses that threshold, explicitly ask whether the code should be decomposed first.
- Only waive this if there is a compelling structural reason and the resulting file is still clearly organized.

### No spaghetti growth

- Be highly suspicious of new ad-hoc conditionals, scattered special cases, or one-off branches inserted into unrelated flows.
- If a change adds "weird if statements in random places", treat that as a design problem.
- Prefer pushing the logic into a dedicated abstraction, helper, state machine, policy object, or separate module.
- Call out changes that make the surrounding code harder to reason about, even if they technically work.

### Design over "it works"

- If behavior can stay the same while the structure becomes meaningfully cleaner, push for the cleaner version.
- Strongly prefer simplifications that remove moving pieces altogether over refactors that merely spread the same complexity around.

### Direct over magic

- Treat brittle, ad-hoc, or "magic" behavior as a code-quality problem.
- Be skeptical of generic mechanisms that hide simple data-shape assumptions.
- Flag thin abstractions, identity wrappers, or pass-through helpers that add indirection without buying clarity.

### Clean boundaries

- Question unnecessary optionality, `unknown`, `any`, or cast-heavy code when a clearer type boundary could exist.
- Prefer explicit typed models or shared contracts over loosely-shaped ad-hoc objects.
- If a branch relies on silent fallback to paper over an unclear invariant, ask whether the boundary should be made explicit instead.

### Right layer, atomic flow

- Call out feature logic leaking into shared paths or implementation details leaking through APIs.
- Prefer existing canonical utilities/helpers over bespoke one-offs.
- Push code toward the right package, service, or module instead of normalizing architectural drift.
- If independent work is serialized for no good reason, ask whether the flow should run in parallel instead.
- If related updates can leave state half-applied, push for a more atomic structure.

## Remedy Patterns

When you identify a problem, prefer these restructuring moves:

- **Re-cut at natural seams** — inline the flow, then decompose it cleanly instead of adding another helper to the current shape.
- **Delete, don't polish** — remove whole layers of indirection, wrappers, or branches rather than improving them in place.
- **Reframe the model** — change ownership or state shape so conditionals disappear instead of getting centralized.
- **Move to the canonical home** — put logic in the module that owns the concept; reuse existing helpers instead of near-duplicates.
- **Clarify the contract** — make type boundaries explicit so control flow gets simpler.

Do not be satisfied with "maybe rename this" feedback when the real issue is structural.
Do not be satisfied with a merely cleaner version of the same messy idea if there is a plausible path to a much simpler idea.

## Comment Phrasing

- `if we inlined this flow and redesigned it cleanly, i don't think we'd end up with these same methods. can we re-cut at the natural seams first?`
- `this helper feels like incremental history, not a domain boundary. what would the flow look like if we decomposed it from scratch?`
- `this pushes the file past 1k lines. can we decompose this first?`
- `this adds another special-case branch into an already busy flow. can we move this behind its own abstraction?`
- `this works, but it makes the surrounding code more spaghetti. let's keep the behavior and restructure the implementation.`
- `this feels like feature logic leaking into a shared path. can we isolate it?`
- `this abstraction seems unnecessary. can we just keep the direct flow?`
- `why does this need a cast / optional here? can we make the boundary more explicit instead?`
- `this looks like a bespoke helper for something we already have elsewhere. can we reuse the canonical one?`
- `i think there's a code-judo move here that makes this much simpler. can we reframe this so these branches disappear?`
- `this refactor moves complexity around, but doesn't really delete it. is there a way to make the model itself simpler?`
