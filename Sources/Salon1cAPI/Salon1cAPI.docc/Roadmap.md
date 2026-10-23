# Roadmap

Planned work, in priority order. Nothing here ships until the item above it does —
the package was built in that order too.

## Shipped — vendor-spec adoption (`0.2.0`)

- **Vendor document is upstream** — `api_salon1c.yaml` + `apply-patches.sh`
  pipeline landed with all 62 operations and 26 declared patches (PR #15).
- **Fresh-vendor adoption check** — the next time 1С republishes the document,
  every `Pn` entry is a re-verification checklist (TD-9).

## Shipped — envelope-unwrapping facade (`0.3.0`)

- **`payload()` on every envelope `Output`** — 59 of 62 operations; `authorize`
  (oneOf envelope) and the two `text/html` operations are skipped (TD-10).
  Generated from the generated types by `Scripts/generate-facade.sh`, committed
  as `Operations+Payload.generated.swift`, deterministic.
- **`Salon1cError`** folds the envelope's error channels — `.refused`,
  `.status`, `.undocumentedStatus`, `.missingPayload` — without merging them;
  **`Paged`** carries `Meta`/`Pagination` alongside list payloads.

Pulled ahead of live access (owner decision, 2026-10-22): the consumer apps
start now, and a facade generated *from* the spec regenerates when the wire
corrects the spec — a handwritten one would not.

## Shipped — transport seam on the convenience init (`0.3.1`)

- **`Client.init` takes a `transport:`** — the convenience init forwards a caller's
  transport (a configured `URLSessionTransport` for a request timeout, a stub in
  tests) while keeping the auth + OSLog middleware chain; the sibling
  YandexDeliveryExpress 0.3.1 precedent.

## Shipped — dynamic-framework consumers link (`0.3.2`, `0.3.3`)

- **OSLogLoggingMiddleware ≥ 1.1.1** (0.3.2) — the transport-free upstream manifest.
- **`HTTPTypes` declared** (0.3.3) — `AuthMiddleware` and `Client+init` had imported it
  transitively, the same defect class one level up; 0.3.2's claim that a consumer could
  already build `Salon1cAPI` into a dynamic package framework was wrong — the
  `Salon1cApps` two-consumer build is what exposed it. 0.3.3 is the first tag at which
  that build links (`Salon1cApps` SA-8 discharges against it).

## Next — needs live access (TD-1)

Everything that requires the **real** host to answer: run the dormant `Live API`
suite (`.env` support added for lab-bound machines), replace constructed fixtures
with wire captures (TD-2), settle the declared-vs-example conflicts (TD-6) in
whichever direction the wire votes, and write the `WorkingWithSalon1c` claims down
to observed behaviour instead of documented behaviour. The Apiary mock — discovered
post-tag — already discharges the documented-example half of this; it caught the v2
trailing-slash bug.

The `Live API (mutating)` suite grows here too — `bookVisit`, `updateClient`,
`refillDeposit` — each behind `SALON1C_ALLOW_MUTATING_LIVE_TESTS=1` and written
only once a non-production salon is available to write to.

## Then — convenience layer, continued

- **Error-code constants.** Once the catalog is complete (TD-3), generated
  constants for the documented codes — not an enum, so unknown codes still
  surface.
- **Typed dates** for the operations whose format survives live verification
  (TD-7).

## Later — maybe

- **Refresh/rotation for `usertoken`** — the document is silent on token
  lifetime; `checkUserToken` exists for exactly this, and a middleware that
  re-auths on `1067` is cheap once the semantics are confirmed.
- **Watch/companion targets** — nothing blocks them today; no API surface needs
  more than `URLSession`.
