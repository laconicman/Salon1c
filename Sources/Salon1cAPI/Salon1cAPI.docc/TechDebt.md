# Tech Debt

The numbered register. Each entry names its Cost (what it costs us today) and
Discharge (what makes it go away). Code references items as `TD-n`; `openapi.yaml`
inline notes carry the same tags.

## TD-1 — Live wire behaviour unverified

`HOST: http://cloud.salon1c.ru/api/` — HTTP-only, with an `/api` base prefix the
paths never restate. The host has not answered a probe from this network since work
began (likely geo-restriction or VPN requirement). Every modeling decision traces to
the `.apib`, not to the wire.

**Cost:** the entire spec is an untested hypothesis until the `Live API` suite runs
green — dormant behind `SALON1C_API_KEY` + `SALON1C_SALON_ID` +
`SALON1C_USER_TOKEN`.
**Discharge:** first live run; reconcile any drift in `openapi.yaml`.

## TD-2 — Constructed fixtures unverified

Where the `.apib` gives no response example (salons, services, group_list
variations), fixtures were built from the field tables — marked "constructed" at
each site.

**Cost:** a table-field omission or wrong-required guess produces a fixture that
agrees with a wrong schema — self-sealing tests.
**Discharge:** replace each constructed fixture with a wire capture; the fixture
comments name which ones.

## TD-3 — Error-code catalog incomplete

The source's «Коды ошибок» table runs 1000–1114+ with literal `....` gaps — a
truncated catalog. `ApiError.code` stays an open `integer` rather than an enum.

**Cost:** no exhaustiveness checking on error codes; apps must range-match.
**Discharge:** a complete catalog (from the vendor or live probing) may still not
justify an enum — closed sets fight open servers; reconsider then.

## TD-4 — Body/query field duplication

`auth_request`, `auth_token`, and the v2 auth template fields into the URI *and*
the body. The spec keeps the documented body and ignores the query-side copies.

**Cost:** if the server actually reads the query positions, our requests lack them
with no compile-time hint.
**Discharge:** a live 400/`errors.code != 0` on these operations would settle which
channel the server reads.

## TD-5 — Six envelope dialects + three paginations

`{parameters,errors}` / `{Parameters,Errors,Meta}` / singular `Error` /
`Request_id`-hybrid / bare `Result` / `errors`-inside-`parameters`
(price_list) — plus `Meta` vs `Pagination` vs `navigation` and `result` vs
`Result`. The hybrid `authorize` op answers two different shapes under HTTP 200
(modeled `oneOf`, discriminated by required keys).

**Cost:** no shared envelope type exists; consumers handle whichever their
operation speaks. An unwrapping facade (Roadmap) must dispatch per-operation.
**Discharge:** never fully — it's the wire contract. A verified dialect table from
live calls would turn speculation into documentation.

## TD-6 — Declared-vs-example conflicts & preserved typos

Where the field table and the example disagree, the spec keeps the declared side
and says so inline:

- `phone` — `number` on `createClient`, `string` on `updateClient`.
- `amount` — `number` declared; v2 `payment` example sends `"136"` strings.
- `transaction_id` — `string` declared; `visit_payment` example sends bare number.
- `history_exist` — declared `string`, example `true`.
- `price` — `float` declared, `"1000"` strings in `price_list` example.
- `debt_visits.Staff` — declared object, example string.
- `services` — shared `Services` structure vs operation table (`category` vs
  `category_id`, `staff` object vs array).
- `payment_list` — v2 `cart_cost` calls it «объект», v2 `payment` example sends an
  array; spec keeps the array.
- Source typos preserved on the wire: `visites` (path), `avialable_actions`
  (key), `rsating` (example-only — modeled `rating`).

**Cost:** a type chosen on one side of the conflict is wrong if the wire favors
the other — decode failures will show as `ClientError`, not envelope errors.
**Discharge:** live captures per operation; flip the losing side if the wire
disagrees.

## TD-7 — Five date dialects, all strings

`iso8601` basic (`20240831T1500`), `dd.mm.yyyy` (birthdays, recording_dates),
`yyyy-mm-dd HH:MM` (deposit_detail), ISO-8601 extended (`2020-12-25T12:07:27`),
and free-text (`available_time`). Everything stays `String` — no `Date` decoding
that would guess the wrong format.

**Cost:** callers parse their own; no type-safety win the client could have
offered.
**Discharge:** a per-operation format table built from live traffic could justify
typed `Date` parsing on the subset that proves stable.

## TD-8 — `public_offer` is `text/html`

The only non-JSON operation; the source's own example is a `{}` placeholder.
Modeled as `type: string` so the raw HTML flows through — callers render or
scrape it themselves.

**Cost:** none structural; it's honest.
**Discharge:** none expected — a WebView is an app concern.
