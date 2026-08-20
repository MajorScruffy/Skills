---
name: functional-test-suite
description: >-
  Design and implement a mocked functional test suite for any invocable project surface (CLI, HTTP, workers, RPC). Discovers user-facing commands, spawns the real binary subprocess with shared session mocks, records external client calls, and asserts the full flow (exact mock interactions + complete user-visible results). Use when the user asks for functional tests, one test per command, mocked end-to-end tests, or @functional-test-suite.
disable-model-invocation: true
---

# Functional Test Suite

Build a **functional** test suite: real dispatch and orchestration through the project's normal entrypoint (subprocess or in-process server), with **every dependency outside the process** faked or stubbed.

Each test must assert the **entire flow**:

1. **Exact external interactions** — every mock client call, in order, with full parameter payloads (Mockito-style `verifyNoMoreInteractions`).
2. **Complete user-visible result** — full stdout/stderr (or HTTP status/body), exit code, and side-effect artifacts—not `contains` on a few fields.

Applies to any project where work is triggered by an **input/command** and produces **output** (CLI subcommands, HTTP route+method, queue consumers, RPC methods, etc.).

## Outcomes (required deliverables)

Commit all of the following unless the user opts out explicitly:

| Artifact | Path (default) | Purpose |
|----------|----------------|---------|
| Functional tests | `tests/functional/` or repo convention | One happy-path test per approved entrypoint |
| Interaction helpers | alongside tests (any language) | Build expected calls; assert exact ordered list |
| Command inventory | `tests/functional/COMMANDS.md` | Approved list of entrypoints |
| Mock boundary worksheet | `tests/functional/BOUNDARIES.md` | What is mocked, call log location, env vars |
| Harness contract | `tests/functional/HARNESS.md` | Shared env, ports, lifecycle, parallel run |

**Layout:** Propose a layout matching the repo; **default** is a dedicated `tests/functional/` tree separate from unit tests. Do not replace or dilute existing unit tests.

## Workflow

Copy and track:

```
- [ ] 1. Discover entrypoints and externals
- [ ] 2. Propose inventory + boundaries → user approval
- [ ] 3. Design harness (fakes, call log, per-test isolation)
- [ ] 4. Implement call recording on every fake/stub client
- [ ] 5. Implement one happy-path test per approved command (full flow assertions)
- [ ] 6. Extend checklist cases (flags, errors, auth) where warranted
- [ ] 7. Run suite in parallel; fix path/env races
```

### 1. Discover

Explore the codebase and docs:

- **Entrypoints:** CLI `main`/subcommands, HTTP routers, worker handlers, gRPC/GraphQL surfaces—at **user-facing** granularity (same level as CLI help or API docs).
- **Externals:** Network, remote DB, cloud SDKs, git, subprocesses to other tools, filesystem outside a test temp root, wall clock, RNG, env secrets.
- **Existing tests:** Reuse patterns (assert libraries, temp dirs) but keep functional tests in their own suite.

### 2. Propose → approve

Present **`COMMANDS.md` draft** as a table and **wait for explicit user approval** (and boundary draft sign-off) before bulk implementation—unless the user says to proceed without approval.

Inventory table:

| Surface | Identifier | Example input | Expected output (shape) | Expected externals |
|---------|------------|---------------|---------------------------|-------------------|
| CLI | `command subcommand` | `command sub --x 1` | exit 0, full stdout | `apiClient.fetch`, `db.insert` |
| HTTP | `POST /hooks` | JSON body fixture | 204, empty body | `webhook.verify`, `queue.publish` |

Rules:

- **≥1 functional test per approved row** (happy path).
- **Variants** (flags, pagination, auth modes): do **not** require separate top-level rows; cover important ones via table-driven cases or extra tests when the checklist below applies—not combinatorial explosion.

**Checklist** (add tests beyond happy path when relevant):

- Documented flags that change behavior (`--dry-run`, `--json`)
- Primary failure modes (invalid args, missing auth, not found)
- Permission / tenancy boundaries
- Idempotency or side-effect commands (second invoke behavior)

### 3. Mock boundary worksheet + call log

Draft **`BOUNDARIES.md`**: for each external, record wrapper trait/module, mock strategy, activation env, and whether calls are recorded.

**Default rule:** everything **outside the process under test** is external. In-process fakes and localhost test doubles are allowed. The subprocess must not reach real network, production credentials, or uncontrolled host paths.

**Call recording (required for recorded externals):**

- Every fake/stub method appends one structured record: service name, method name, input params (return values are not recorded).
- Log lives under the test workspace/fixture dir (e.g. `client_calls.jsonl` or equivalent).
- Recording is gated on a harness env var so unit tests and non-functional runs are unaffected.
- **Do not clear the log when a child subprocess starts** — truncate only when the test workspace is created, so parent + child processes share one ordered log.
- Normalize unstable values in recorded params (absolute paths → workspace-relative; platform-specific path prefixes; IDs/timestamps when needed).

**Harness pattern:**

- Each test gets an isolated temp workspace + fixture dir; subprocess receives env pointing at fakes.
- Reuse expensive infrastructure where safe; isolate mutable state per test.
- Document shared vs per-test lifecycle in **`HARNESS.md`**.

### 4. Implement tests

Per test, after the entrypoint completes (and after waiting for async/detached child work if applicable):

```
1. Assert exit code / HTTP status
2. Assert full user-visible output (stdout, stderr, response body)
3. Assert exact ordered interaction list (or assert zero interactions)
4. Assert full side-effect artifacts (files, DB rows, queue messages)
```

**Building expected interactions:**

- Derive expected params from the same production builders the code under test uses—not hand-copied partial strings.
- Run expected values through the same normalizer the call log uses before compare.
- For volatile fields (timestamps, pids, UUIDs): normalize to placeholders, or compare parsed structures field-by-field excluding volatile keys.

**Rules:**

- Invoke via **black-box entrypoint**: real argv, stdin, env, or HTTP request—same as users/operators.
- Interaction assertion must match **exactly** — count and order. Empty list = no externals touched.
- Assert **whole param payloads** (full request bodies, full command args)—not `contains` or single-field checks alone.
- Keep tests **deterministic**: mock clock/RNG; avoid bare `sleep`—use bounded waits for async child work only when the architecture requires it.

**Unmockerable dependency:** prefer a **thin wrapper** at the production seam (trait/interface/client module), mock the wrapper in tests, and inject via env or compile-time test config. Do not skip silently; if still blocked, mark `blocked` in `BOUNDARIES.md` with reason and required refactor.

## Anti-goals (do not)

- Hit production URLs, real cloud accounts, or shared dev databases
- Rely on wall-clock sleep/poll instead of controlling time or async mocks (except bounded waits for detached subprocesses)
- Assert only fragments of output when the full output is stable
- Assert only a subset of interaction params when the full payload is known
- Leave unexpected mock calls unverified—always use exact-list assertion
- Skip a command without a `blocked` row on the boundaries doc
- Clear interaction logs inside fake client init (breaks parent + child subprocess flows)
- Use global call-log state that breaks parallel unit tests

## Stack specifics

Read [reference.md](reference.md) when the implementation language is known for harness libraries and call-recording patterns.
