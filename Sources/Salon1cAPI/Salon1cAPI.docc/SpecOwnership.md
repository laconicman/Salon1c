# Owning the Specification

`openapi.yaml` is **generated output**: the vendor's OpenAPI document, vendored
verbatim, plus a declared patch layer. This is the `YooMoneyAPIClient` model —
the difference is that our upstream didn't exist when the project started.

## History in two sentences

The project began on a false premise: «the vendor publishes no OpenAPI», so
`openapi.yaml` was hand-authored from the Apiary Blueprint (53 operations,
7 PRs). In 2026-10 the vendor's own `api_salon1c.yaml` (OpenAPI 3.1, 62
operations, редакция 3.0) surfaced — newer than the Blueprint, carrying the
operations the Blueprint lacks. The premise died; the document moved upstream.

## The pipeline

```
Upstream/salon1c-openapi/api_salon1c.yaml   ← vendor file, verbatim
        + apply-patches.sh + patches/       ← this repo's declared corrections
        = Sources/Salon1cAPI/openapi.yaml   ← generated; regenerating is cheap
```

Run `Upstream/salon1c-openapi/apply-patches.sh` after refreshing upstream.
The script is the patch register — each change is a commented `# Pn` block.
Upstream never gets edited in place; the output file never gets edited at all.

## The patch register (what we correct and why)

**Vendor defects** (malformed or self-contradictory in the vendor document):

- `P4` `PUT work_schedule` 200 response had `content.schema` with no media type.
- `P8` Five operations reference `{salon_id}` in the path but never declare the
  parameter (`PUT client`, `PUT records`, `PUT sale`, `GET|PUT work_schedule`).
- `P10` `record_array`, `payment_list`, `cart` body properties $ref'd the
  *item* schema where the description says «Массив…» — wrapped as arrays.
- `P13` `oneOf: [$ref, type:"null"]` on `services.category_id` is valid 3.1 but
  the generator drops the whole property — collapsed to an optional `$ref`
  (Codable decodes wire `null` to nil the same way).
- `P14` Three copy-paste bugs: `deposit.id`, `deposit.title`, `order_list[].id`
  all `$ref` `#/components/schemas/Errors` — an error object where an id or
  title belongs.
- `P15` `delivery_list[].id` declared `$ref: ID` — the wire sends `null` for
  pickup; typed `[string, null]`.
- `P16` `auth_types` items required `method`; the vendor's own example omits it.
- `P19` `certificates.total/balance` declared `string`, vendor example sends
  numbers — a `string` could never carry the documented payload.
- `P20` `PUT client` request schema drops `phone` while its own example sends
  `phone: 79211234567` — added as `number`, matching `createClient`.
- `P22` `searchClients.order_by_direction` enumerates only `DESC` (lifted from
  the example) while its description reads «`ASC` или `DESC`» — both declared.
- `P23` `Filter.value` was `array` of untyped items while its description
  allows «как строкой, так и массивом строк» — `oneOf` string | [string].
- `P24` `Ticket` lacked six keys the vendor's own tickets/ticket examples
  carry (`total_frozen`, `balance_frozen`, `min_frozen_count`,
  `total_guest_visit`, `balance_guest_visit`, `freeze_list`) — declared
  optional with the examples' types; `freeze_list`'s item shape is
  undocumented.
- `P26` `record_rating.comment` declared `number` in *both* documents while
  both examples send a string — the example wins, as with `P19`.

**Project choices** (correct upstream, different here):

- `P1` `operationId` curation — vendor ids are raw slugs (`auth_types`) and
  collide across v1/v2 (`book_services`, `book_staff` twice each). All 62 get
  curated Swift-friendly names by path+method.
- `P2` JSON-in-query parameters retyped from `type: string` to
  `content: application/json` + component schemas (`P2b`) — typed `cart`,
  `filters`, `service_ids`, `record_array`, `payment_list` v2, etc.
- `P3` `usertoken` optional — `AuthMiddleware` injects it from credentials.
- `P5` vendor tags object error responses `text/plain` — retagged
  `application/json` so they decode.
- `P6` global `security` AND-combined `basicAuth` + `apiKey` — OR'ed.
- `P7` schemas `cart`/`Cart` collide under idiomatic naming — renamed the
  request-line-item schema (wire keys unchanged).

**Dialect preservation** (the `.apib` knows something the YAML forgot):

- `P9` `price_list` nests `errors` inside `parameters` in the Blueprint + mock;
  the vendor flattens it. Both locations decode now.
- `P11` auth's «code sent» variant emits `Error`/`ErrorMessage` (singular) on
  the wire per the Blueprint example — added as optional props.
- `P18` services items: vendor says `category_id`, the Blueprint example sends
  `category` — both declared optional.
- `P17` authorize's `oneOf` branches needed discriminating requireds
  (`sent_SMS` / `UserToken`) — all-optional case1 swallowed case2 payloads.
- `P21` the Blueprint declares `salon_id` (required) in the request bodies of
  `createClient`, `updateClientById`, `searchClients` and `updateRecord`; the
  vendor schemas omit it while the vendor examples still send it — declared
  optional, the path parameter stays authoritative.
- `P25` v1 `cart_cost`: the Blueprint field table documents `user_token` in
  the response (the anonymous-cart handle, returned when no `usertoken`
  header); the vendor YAML never mentions it — declared optional.

## Envelope dialect map

Unchanged by adoption — the vendor document preserves the dialects
(PascalCase/lowercase/singular/mixed pagination), and patches restore the
ones it forgot:

| Shape | Example | Used by |
|---|---|---|
| `{parameters, errors}` | cart_cost | Shop, terminal v2, record_cost, auth_types |
| `{Parameters, Errors, Meta}` | salons | salons, clients list, services |
| `{Parameters, Error}` | record_rating | ratings (singular key) |
| `{Request_id, Parameters, Error, ErrorMessage}` | auth | auth group |
| `{Result}` / `{Parameters: {Result}}` | validity_usertoken, delete_sale | token check, deletes |
| `errors` inside `parameters` | price_list | shop price list (P9 keeps both) |

## What ownership obligates

1. **Patches are the contract.** A shape correction lives in `apply-patches.sh`
   with a rationale comment — never in `api_salon1c.yaml`, never in Swift.
2. **Conflicts stay visible.** Vendor-vs-Blueprint disagreements get a patch +
   a TechDebt entry; declared-vs-example contradictions inside the vendor
   document get the same. Documented behaviour is the contract until the wire
   disagrees (TD-1).
3. **The live suite is the arbiter.** Offline tests prove we decode the
   documents' claims; `Apiary mock` proves them over HTTP; only the dormant
   `Live API` suite proves the claims themselves.

## Regenerating and validating

```
Upstream/salon1c-openapi/apply-patches.sh   # regenerate openapi.yaml
swift build                                # plugin regenerates types+client
swift test                                 # offline suite
SALON1C_MOCK_TESTS=1 swift test            # + Apiary mock over HTTP
```
