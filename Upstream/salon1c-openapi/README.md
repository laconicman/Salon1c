# Vendor OpenAPI — the upstream document

This directory holds the vendor-published API reference, verbatim:

| File | What it is |
|---|---|
| `api_salon1c.yaml` | The vendor's OpenAPI 3.1 document — 62 operations, named component schemas, typed error responses, both auth schemes (`apikey` cloud + `basicAuth` direct-to-base). Obtained from the vendor's documentation materials (редакция 3.0), provided 2026-10-15. |
| `API-1C-SPA-Salon-3.0.pdf` | The vendor's human-readable «API 1С:SPA-Салон, редакция 3.0» — the same revision the YAML serves. |
| `apply-patches.sh` | The auditable patch pipeline: `api_salon1c.yaml` → `Sources/Salon1cAPI/openapi.yaml`. |
| `patches/` | JSON-in-query parameter fragments and component schemas applied by the script. |

**Upstream means upstream.** `api_salon1c.yaml` is byte-identical to the
vendor's file. Every divergence this project needs — curated `operationId`s,
typed JSON-in-query parameters, the vendor's own spec defects — is declared as
a numbered patch (`# Pn —`) inside `apply-patches.sh`. Regenerate the working
document with:

```sh
Upstream/salon1c-openapi/apply-patches.sh
```

The companion Blueprint (`../salon1c/salon1c.apib`) remains vendored as a
**secondary source**: the Apiary mock replays it, and several wire shapes the
YAML declares differently (nested `errors` in `price_list`, the `category`
field name on services, `Error`/`ErrorMessage` on auth's code-sent variant) are
preserved as optional tolerance through patches P9/P11/P18.

## The two documents disagree — who wins

The vendor YAML is newer (62 vs 53 operations) and structurally richer, so it is
the default. The `.apib` wins only where the YAML is demonstrably self-
contradictory (declared `string` vs example number, `$ref` to an `Errors`
schema on an id field) — and even then the resolution is a patch entry, never a
silent edit of upstream or a Swift workaround.
