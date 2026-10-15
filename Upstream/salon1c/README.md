# Upstream — `salon1c.apib`

The vendor's only published API reference. 1С publishes **no OpenAPI document** for the
1С:SPA-Салон API — `openapi.yaml` in this package was written by hand against this file,
which makes it both the contract and the thing that may be wrong
(see `Sources/Salon1cAPI/Salon1cAPI.docc/SpecOwnership.md`).

| | |
|---|---|
| Rendered doc | <https://salon1c.docs.apiary.io/> (also linked from <https://salon1c.ru/api/>) |
| Source of this file | `curl -o salon1c.apib https://salon1c.docs.apiary.io/api-description-document` |
| Captured | 2026-10-15 |
| Format | API Blueprint `FORMAT: 1A`, 4,091 lines |
| Coverage | 53 operations: 47 on `/hs/api/v1/` + 6 on `/hs/api/v2/` |

## Re-check for changes

The document is unversioned. Re-download and `git diff` this file — that diff *is* the
changelog:

```console
% curl -so /tmp/salon1c.apib https://salon1c.docs.apiary.io/api-description-document
% diff -u Upstream/salon1c/salon1c.apib /tmp/salon1c.apib
```

## Known defects inside the document

These are properties of the source itself, kept verbatim; each is also a `TD-n` entry.

- **Two response dialects.** Most operations envelope replies as
  `{parameters, errors}` (lowercase); the Клиенты/Салоны/Услуги operations declared with
  `+ Attributes` envelope them as `{Parameters, Errors, Meta}` (PascalCase). JSON keys are
  case-sensitive — the two dialects are different wire shapes, not a typo to normalize.
- **Inconsistent examples within one operation.** v1 `auth` shows a 200 reply as
  `Request_id`/`Parameters`/`Error`/`ErrorMessage` in one example and
  `Parameters`/`Errors` in the next.
- **Parameter channel is ambiguous** where a URI template lists query parameters but the
  example sends a JSON body (`auth` v1).
- **Type conflicts.** `ClientCreate.phone` is declared `number`, shown as string
  elsewhere; `payment_list.amount` is declared `number`, sent as `"136"` in a v2 example.
- **Wire misspellings kept**: `visites`, `finished_visites` (paths), `salon_id` absent
  from v2 paths (deliberate).
- **HOST is `http://cloud.salon1c.ru/api/`** while paths start `/hs/api/…`; whether the
  combined base really carries `/api` — and whether HTTPS exists — is unverified (TD-1).
- **Error codes 1000–1114** live inside `errors.code` on HTTP 200; only Клиенты-group
  operations document 201/400 statuses.
