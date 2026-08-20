# Functional Test Suite — Stack Reference

Read this file after `SKILL.md` when the repo language is known. Prefer existing repo dependencies over adding new ones. Choose the **simplest harness** that satisfies `BOUNDARIES.md`; escalate only when a fake cannot reach the subprocess.

**On failure:** print exit code, stdout, stderr (and response body for HTTP). Run one test via the command documented in `HARNESS.md`.

## Call recording (language-agnostic)

**Record shape** (adapt names to the repo):

```json
{ "service": "paymentClient", "method": "charge", "params": { "amount": 100, "currency": "USD" } }
```

**Fake/stub seam:**

```
on each external call:
  if harness_recording_enabled():
    append { service, method, params: inputs_only } to workspace call log
  return canned response
```

**Test assertion:**

```
actual = read_call_log(workspace)
assert actual == expected_ordered_list   // verifyNoMoreInteractions
```

**Lifecycle:**

| Event | Call log |
|-------|----------|
| Test workspace created | Truncate / create empty log |
| Subprocess / child init | Do **not** truncate |
| Parent + child share workspace | Both append; assert once at end |
| Async / detached child | Bounded wait until expected count or timeout |

**Normalization:** apply the same transforms when recording and when building expected values—path relativization, placeholder substitution for dates/UUIDs/pids, platform path prefix handling.

**Expected params:** reuse production request/payload builders; pass through the normalizer before compare.

## Rust (CLI / binary crates)

| Concern | Typical choice |
|---------|----------------|
| Subprocess | `assert_cmd::Command` or `std::process::Command` |
| Temp dirs | `tempfile::TempDir` per test |
| Call recording | Append JSONL from fake clients; read in test harness |
| HTTP mocks | `wiremock::MockServer` (session: one server, many mounts) |
| Git | `git2` against a bare repo fixture, or env `GIT_DIR` + init in `TestMain` |
| Session setup | `static OnceLock` + `#[test]` wrapper, or dedicated `tests/functional.rs` with `TestMain` |

```rust
// Pattern: session mock server, per-test temp workspace, subprocess CLI
static SERVER: OnceLock<MockServer> = OnceLock::new();

fn harness_env(tmp: &Path) -> Vec<(String, String)> {
    vec![
        ("MOCK_API_URL".into(), SERVER.get().unwrap().uri()),
        ("TEST_WORKSPACE".into(), tmp.display().to_string()),
    ]
}
```

```rust
// Fake client — record inputs only
fn record(service: &str, method: &str, params: Value) {
    if !std::env::var_os("TEST_WORKSPACE").is_some_and(|_| recording_enabled()) {
        return;
    }
    // append normalized line to {workspace}/client_calls.jsonl
}
```

Inject traits at seams when direct mocking is impractical; wire fakes via env or `cfg(test)` / integration-test features.

**Rust debuggability:** `assert_cmd` prints output on panic by default; on interaction mismatch print `actual` vs `expected`. Keep subprocess timeouts short with an explicit message naming the command.

## Go

- `os/exec` for subprocess; `testing.M` + `TestMain` for global mock listener.
- `httptest.Server` for session HTTP; `t.Setenv` (Go 1.17+) for per-test env.
- Call log: append JSON lines from fake `RoundTripper` or wrapper structs; read in test via `t.TempDir()`.
- `t.Parallel()` **off** for functional package by default.

## Node / TypeScript

- `child_process.spawn` with `env: { ...process.env, TEST_WORKSPACE }`.
- `msw` or `nock` for HTTP; start listener in `beforeAll`, reset handlers in `afterEach`.
- Call log: append from mock handlers or wrapper modules; assert ordered list in test teardown.
- Vitest/Jest: `fileParallelism: false` or dedicated project for functional tests.

## Python

- `subprocess.run` with `env=` merge; `pytest` session fixture for `HTTPServer` / `respx` mock.
- Call log: wrapper around `requests`/`httpx` client or `@patch` targets writes JSONL under `tmp_path`.
- `pytest -m functional --maxfail=1` with marker; `xdist` disabled for functional job.

## HTTP services (binary or `uvicorn`/`node` server)

Functional test still uses **subprocess** (start server in session fixture, or spawn via CLI `serve`):

| Surface | Identifier example |
|---------|-------------------|
| Route | `GET /health` |
| Route | `POST /api/v1/items` |

Use `reqwest` / `httpx` / `fetch` against `127.0.0.1` with mocks backing downstream deps the handler calls. Record downstream HTTP calls via mock server request history **or** wrapper client log—assert full ordered list plus full response status/body.

## Workers / consumers

Identifier = **subscription or handler name** (e.g. `consume.order.created`). Drive via CLI that processes one message, or test harness that invokes the same `main` entry with a fixture payload file on stdin/env. Record publishes/consumes on fake broker clients the same way as other externals.

## CI sketch

```yaml
# Example job name only — adapt to repo
functional-tests:
  steps:
    - run: cargo test --test functional -- --test-threads=1
    # Fail if COVERAGE.md lists todo without allowlist
```

Optional: script greps `COVERAGE.md` for `| todo |` or missing rows vs `COMMANDS.md`.
