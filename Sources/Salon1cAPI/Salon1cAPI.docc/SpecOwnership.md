# Owning the Specification

`openapi.yaml` is hand-authored by this repository. That choice, and what it obligates.

## Why a hand-authored document

The vendor publishes one machine-readable artifact: an **API Blueprint** (FORMAT: 1A)
at `salon1c.docs.apiary.io/api-description-document` — the same source the html docs
render from. No OpenAPI, Swagger, or Postman collection exists. A snapshot lives at
`Upstream/salon1c/salon1c.apib` (4092 lines, downloaded 2026-10) so every spec line
traces to a document this repo controls.

Options considered:

| Option | Rejected because |
|---|---|
| Vendor OpenAPI | Does not exist |
| Blueprint→OpenAPI translation tools | Apiary's `.apib` is prose-heavy: field tables in HTML, examples with broken JSON, three response dialects. Mechanical translation preserves none of the provenance notes that make the conflicts auditable |
| Hand-written client, no spec | Duplicates every path/body in Swift with no single source of truth |

The translation was done group-by-group (7 PRs), each with fixtures taken verbatim
from the Blueprint's examples and tests that decode them through the generated code.

## What ownership obligates

1. **Provenance.** Every operation's `description` ends with
   `Источник: salon1c.apib → Group … → operation`. A reader can diff the spec against
   the `.apib` and find the paragraph that justifies each shape.
2. **Conflicts stay visible.** When the document disagrees with itself, the spec picks
   the *declared* contract, notes the conflict inline (`TD-5`, `TD-6`, `TD-7`), and
   registers it in <doc:TechDebt>. The Blueprint's example beats its field table only
   where the table is obviously broken — and that decision is always documented at the
   site.
3. **Fix it in YAML.** A weird generated shape means the spec is wrong — edit
   `openapi.yaml`, never write a Swift workaround (the inverse of packages that vendor
   an untouchable upstream document).
4. **The live suite is the arbiter.** Offline tests prove the client decodes the
   *document's claims*. Only `Live API` tests — dormant until credentials exist —
   prove the claims. Every unverified modeling decision is a <doc:TechDebt> item whose
   Discharge line names what a live call must show.

## Envelope dialect map

The document's single largest inconsistency. Six shapes exist; `openapi.yaml` models
each one literally:

| Shape | Example | Used by |
|---|---|---|
| `{parameters, errors}` | cart_cost | Shop, terminal v2, record_cost, auth_types |
| `{Parameters, Errors, Meta}` | salons | salons, clients list, services |
| `{Parameters, Error}` | record_rating | ratings (singular key) |
| `{Request_id, Parameters, Error, ErrorMessage}` | auth | auth group |
| `{Result}` | validity_usertoken | token check |
| `errors` inside `parameters` | price_list | shop price list |

Plus three pagination spellings (`Meta`, `Pagination`, `navigation`) and `result` vs
`Result` flags. This is why nothing is normalized: any facade must answer "which
dialect?" per operation — the generated code already does.

## Regenerating and validating

```
swift build          # plugin regenerates Client.swift/Types.swift into .build/
swift test           # 72 tests: envelope decoding, request encoding, middleware
swift test --filter "Live API"   # needs SALON1C_* env, currently dormant (TD-1)
```

Generated sources live in `.build/plugins/outputs/…/GeneratedSources/` — never edited,
never committed.
