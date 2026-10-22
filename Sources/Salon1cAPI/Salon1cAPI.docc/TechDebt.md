# Tech Debt

The numbered register. Each entry names its Cost (what it costs us today) and
Discharge (what makes it go away). Code references items as `TD-n`; patches in
`Upstream/salon1c-openapi/apply-patches.sh` are `Pn`.

## TD-1 — Live wire behaviour unverified against the real host

`HOST: http://cloud.salon1c.ru/api/` — HTTP-only; the host has never answered a
probe from this network (likely geo-restriction or VPN requirement).
**Partially discharged 2026-10-15:** Apiary's built-in mock of the vendor's
Blueprint serves every documented example over real HTTP, and the `Apiary mock`
suite (`SALON1C_MOCK_TESTS=1`) exercises the generated client end-to-end —
it already falsified one assumption (v2 paths carry a literal trailing slash)
and confirmed the `/api` base prefix.

The vendor OpenAPI (62 ops) joined as upstream the same day — it is the
strongest *documentary* evidence yet, but it remains documentation, not wire.

**Cost:** modeling decisions that rest on undocumented detail remain
hypotheses; the `Live API` suite stays dormant behind `SALON1C_API_KEY` +
`SALON1C_SALON_ID` + `SALON1C_USER_TOKEN` (see `.env.example` — a git-ignored
`.env` at the package root feeds the suite on a network where the host
answers).
**Discharge:** the `Live API` suite green against the real host; reconcile
drift via the patch pipeline.

## TD-2 — Constructed fixtures unverified

Where neither document gives a response example, fixtures were built from the
field tables — marked «constructed» at each site. The vendor document's inline
`example:` blocks replaced several that the `.apib` lacked (certificates, sale,
payment_link; `work_schedule` remains constructed from the `WorkSchedule`
schema).

**Cost:** a table-field omission or wrong-required guess produces a fixture
that agrees with a wrong schema — self-sealing tests.
**Discharge:** replace each constructed fixture with a wire capture; the
fixture comments name which ones.

## TD-3 — Error-code catalog incomplete

The Blueprint's «Коды ошибок» table runs 1000–1114+ with literal `....` gaps —
a truncated catalog. `ApiError.code` stays an open `integer` rather than an
enum. The vendor document adds typed `Errors` schemas (code + message) on every
operation but no fuller code list.

**Cost:** no exhaustiveness checking on error codes; apps must range-match.
**Discharge:** a complete catalog (from the vendor or live probing) may still
not justify an enum — closed sets fight open servers; reconsider then.

## TD-4 — Body/query field duplication

`auth_request`, `auth_token`, and the v2 auth template fields into the URI
*and* the body. The spec keeps the documented body and ignores the query-side
copies.

**Cost:** if the server actually reads the query positions, our requests lack
them with no compile-time hint.
**Discharge:** a live 400/`errors.code != 0` on these operations would settle
which channel the server reads.

## TD-5 — Six envelope dialects + three paginations

`{parameters,errors}` / `{Parameters,Errors,Meta}` / singular `Error` /
`Request_id`-hybrid / bare `Result` / `errors`-inside-`parameters`
(price_list) — plus `Meta` vs `Pagination` vs `navigation` and `result` vs
`Result`. The vendor document preserves all of them except where noted
below — the dialects are not a Blueprint artifact, they are the wire.

Vendor-vs-Blueprint drift, kept decodable by patch:

- `price_list` flattens `errors` to the envelope top level; the Blueprint nests
  it inside `parameters`. `P9` declares both.
- `authorize`'s «code sent» variant: vendor uses `Parameters`/`Errors`; the
  Blueprint example emits `Request_id`/`Parameters`/`Error`/`ErrorMessage`.
  `P11` adds the singular keys as optional.
- `services` items: vendor `category_id`, Blueprint example `category`. `P18`
  declares both.

**Cost:** no shared envelope type exists; consumers handle whichever their
operation speaks. An unwrapping facade (Roadmap) must dispatch per-operation.
**Discharge:** never fully — it's the wire contract. A verified dialect table
from live calls would turn speculation into documentation.

## TD-6 — Declared-vs-example conflicts & preserved typos

Where a document's declaration and its own example disagree, the spec keeps the
declared side and says so inline — unless the declared side could never carry
the example (then the example wins, also declared). The vendor document
contributed fresh instances:

- `phone` — `number` on `createClient`; the Blueprint declares it `string` on
  `updateClientById`, and the vendor's `PUT client` schema omits it entirely
  while its own example sends `79211234567` — declared `number` (`P20`).
- `salon_id` in request bodies — required in the Blueprint for `createClient`,
  `updateClientById`, `searchClients`, `updateRecord`; the vendor schemas omit
  it while the vendor examples send it — declared optional (`P21`).
- `amount` — `number` declared; v2 `payment` example sends `"136"` strings.
- `transaction_id` — `string` declared; `visit_payment` example sends bare
  number.
- `history_exist` — declared `string` in the `.apib` (vendor says `boolean`),
  example `true`.
- `price` — `float` declared, `"1000"` strings in `price_list` example.
- `debt_visits.Staff` — declared object, example string.
- `record_rating.comment` — declared `number` in *both* documents; the
  Blueprint's example sends `"Отличное обслуживание"`. Example wins — patched
  to `string` (`P26`).
- `cart_cost.user_token` — documented in the Blueprint's v1 field table (the
  anonymous-cart handle), absent from the vendor YAML — declared optional
  (`P25`).
- `certificates.total`/`balance` — declared `string`, vendor's own example
  sends `5000`/`2000`. Example wins (`P19`) — a string cannot carry it.
- `services` — `category` vs `category_id` across documents (`P18` keeps both).
- Source typos preserved on the wire: `visites` (path), `avialable_actions`
  (key), `rsating` (example-only — modeled `rating`).

**Cost:** a type chosen on one side of the conflict is wrong if the wire
favors the other — decode failures show as `ClientError`, not envelope errors.
**Discharge:** live captures per operation; flip the losing side if the wire
disagrees.

## TD-7 — Five date dialects, all strings

`iso8601` basic (`20240831T1500`), `dd.mm.yyyy` (birthdays, recording_dates),
`yyyy-mm-dd HH:MM` (deposit_detail), ISO-8601 extended (`2020-12-25T12:07:27`),
and free-text (`available_time`). Everything stays `String` — no `Date`
decoding that would guess the wrong format.

**Cost:** callers parse their own; no type-safety win the client could have
offered.
**Discharge:** a per-operation format table built from live traffic could
justify typed `Date` parsing on the subset that proves stable.

## TD-8 — `public_offer` (and `privacy_policy`) are `text/html`

The only non-JSON operations; both return raw HTML (`type: string` bodies).
Callers render or scrape them themselves.

**Cost:** none structural; it's honest.
**Discharge:** none expected — a WebView is an app concern.

## TD-9 — Vendor document defects carried as patches

The vendor's OpenAPI 3.1 is richer than the Blueprint but not immaculate —
26 patches in `apply-patches.sh` correct it, most being genuine defects rather
than preferences. The mechanical ones worth re-checking when the vendor
republishes:

- malformed `PUT work_schedule` response (`P4`),
- five undeclared `{salon_id}` path parameters (`P8`),
- array-of-items modeled as bare item `$ref` (`record_array`, `payment_list`,
  `cart` — `P10`),
- `id`/`title` properties `$ref`'d to the `Errors` schema (`P14`),
- `delivery_list[].id` not nullable while the wire sends null (`P15`),
- `auth_types.method` over-required (`P16`),
- certificates `total`/`balance` declared `string` vs example numbers (`P19`),
- `PUT client` request schema missing `phone` its own example sends (`P20`),
- `order_by_direction` enum lifted from the example, missing `ASC` (`P22`),
- `Filter.value` an untyped array where its description allows a scalar
  string (`P23`),
- `Ticket` missing six keys the vendor's own examples carry (`P24`).

**Cost:** if a future vendor revision fixes a site we also patched, the patch
becomes a silent no-op or a stale conflict — each patch comment names what to
re-verify.
**Discharge:** upstream publishes a corrected revision; shrinking the patch
script on adoption.

## TD-10 — Three operations have no `payload()`

`authorize` (success body is a `oneOf` envelope — «code sent» vs «token issued»,
not a `JsonPayload` struct) and `getPublicOffer`/`getPrivacyPolicy` (`text/html`,
no JSON body) are skipped by the facade generator; its header comment names them.
`authorize` gets a hand-shaped outcome together with the auth flow; the HTML
operations need none — the caller wants the markup itself.

**Cost:** the facade's convenience does not reach `authorize`; callers `switch`
on its `Output` directly, which is the honest shape for a two-variant answer
anyway.
**Discharge:** a designed auth flow — `authorize` folds into it; the HTML
operations stay unwrapped permanently.
