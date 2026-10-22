# Review Guidelines

Review-specific guidance. `CLAUDE.md` carries the standing rules and is ingested alongside
this file — nothing here restates it. These are the diff-level cues and the noise filters.

## Critical Areas

- `Sources/Salon1cAPI/openapi.yaml` is *generated output* — it must carry the header
  comment naming `Upstream/salon1c-openapi/apply-patches.sh` as its source, and its diff
  should only ever change via that script. Hand-edits to it, or edits to
  `Upstream/salon1c-openapi/api_salon1c.yaml` (the vendor file is verbatim upstream), are
  the defect this pipeline exists to prevent. New shape corrections belong in
  `apply-patches.sh` as commented `# Pn` blocks.
- Flag any change to envelope key casing (`parameters`/`errors` ↔ `Parameters`/`Errors`/
  `Meta`). The two dialects are deliberate per-operation fidelity — a "consistency" edit
  is a spec regression, not a fix.
- Flag a JSON-in-query parameter (`content: application/json` on `in: query` — e.g.
  `record_array`, `cart`, `service_ids`, `payment_list`, `filters`) rewritten to a plain
  `schema`/`string` parameter. The generator emits `setQueryItemAsJSON` for these, which
  needs `swift-openapi-runtime` ≥ 1.13.0 — see the pin comment in `Package.swift`.
- Flag any `security:` change. `apikey` is global; `usertoken` is added per-operation —
  where the .apib's prose *and* examples disagree about it, the choice is a `TD-n`, and a
  diff silently moving an operation between the two is suspect.
- Flag a path gaining or losing `{salon_id}` — v1 paths carry it, v2 deliberately do not.
- Flag "corrected" wire spellings (`visites`, `finished_visites`) in `paths:` — the API
  serves the misspelling; `operationId` is where the proper name lives.

## Conventions

- Reject hand-written Swift that reshapes or wraps a `Components.Schemas.*` type — the fix
  belongs in `apply-patches.sh` as a new patch entry.
- Reject committed generated code: a reappearing `Sources/GeneratedSources/` directory, or
  a committed `Client.swift` / `Types.swift`. The exception is
  `Sources/Salon1cAPI/Operations+Payload.generated.swift` — *our* derived artifact,
  committed by design; flag **hand edits** to it (any diff not produced by
  `Scripts/generate-facade.sh`), and flag a facade that drifts from `openapi.yaml`
  in the same PR — regeneration must be byte-identical, so a spec change without a
  regenerated facade (or a facade change without a spec change) is suspect.
- Flag a `Salon1cError` change that merges channels — `.refused` (domain refusal in a
  2xx envelope) and `.status`/`.undocumentedStatus` (transport-level status) must stay
  distinguishable.
- Flag a status flip of a `TD-n` entry in
  `Sources/Salon1cAPI/Salon1cAPI.docc/TechDebt.md` that does not name what discharged it.
- Flag a new `// TODO` in `Sources/` that carries no `TD-n` register number.
- Require a new live test to carry the `Live API` suite prefix and gate on
  `LiveEnvironment.salon` (`SALON1C_API_KEY` + `SALON1C_SALON_ID`); require
  `LiveEnvironment.mutatingAllowed` if it creates or mutates server state.
- Require a new test that touches any network host to gate on an env switch —
  `SALON1C_MOCK_TESTS=1` for the Apiary mock, credentials for the real host — so
  `swift test` stays hermetic.
- Flag `.defaultIsolation(MainActor.self)` on the library target as a regression — generated
  code cannot compile under it (apple/swift-openapi-generator#796/#823).

## Anti-patterns to Flag

- Reject any `@available` annotation in `Sources/` — the floor is iOS 17 / macOS 14.
- Reject middleware that sets `Content-Type` or synthesizes idempotency keys in
  `Sources/Salon1cAPI/AuthMiddleware.swift` — header names `apikey`/`usertoken` only.
- Reject `description` implemented via `"\(self)"` or `String(describing: self)` — infinite
  recursion (shipped once in the sibling as TD-2).

## Security

- Flag any code path that logs a `Credentials` value or the `apikey`/`usertoken` headers.
- Flag any change moving the `bodyLoggingConfiguration` default off `.never` — request and
  response bodies carry client names, phones, birthdays and payment amounts.

## Ignore

- Skip `Upstream/salon1c/salon1c.apib` — vendored verbatim; flag only a diff that lacks a
  matching `Upstream/salon1c/README.md` provenance update.
- Skip `Package.resolved` — this package does not commit one; flag its *appearance* instead.
- Skip byte-level churn inside existing fixtures in `Tests/Salon1cAPITests/Fixtures.swift`,
  but require provenance (doc section or capture date) on any new fixture.
