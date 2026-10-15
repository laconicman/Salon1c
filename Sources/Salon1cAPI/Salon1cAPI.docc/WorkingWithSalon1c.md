# Working with Salon1cAPI

The calls a real app makes, and the envelopes it will actually see.

## Credentials and construction

```swift
import Salon1cAPI

// Anonymous — apikey only
let anonymous = try Client(credentials: .init(apiKey: "<salon api key>"))

// Client-scoped — apikey + usertoken from an auth flow
let authed = try Client(
    credentials: .init(apiKey: "<salon api key>", userToken: "<usertoken>")
)
```

`usertoken` is obtained through the auth group (`authorize`/`authorizeByPhone` +
`authorizeByCode`) or — anonymously — by calling `getCartCost` without a token, which
returns a `user_token` in its response payload. Store it wherever your app keeps
secrets; ``Credentials`` itself is a plain `Sendable` struct.

For a self-hosted deployment, override the server:

```swift
let client = try Client(serverURL: mySalonURL, credentials: creds)
```

## Reading envelopes

Every `.ok` body has a `parameters`/`Parameters` payload and an `errors`/`Errors` —
check `code == 0`; non-zero means a domain error with HTTP 200:

```swift
let output = try await client.getCartCost(
    path: .init(salonId: salonId),
    query: .init(cart: [.init(purchaseId: productId, count: 2)])
)
let body = try output.ok.body.json

if let error = body.errors, error.code != 0 {
    throw SalonError(code: error.code, message: error.message)
}
let cart = body.parameters?.cart ?? []
```

Documented non-2xx statuses are separate output cases — `createClient` can answer
`.created` (201) or `.badRequest` (400); `switch` covers both.

## JSON-in-query parameters

Pass typed values; the client serializes:

```swift
// One query item: service_ids={"services_array":["…","…"]}
try await client.getBookableServices(
    path: .init(salonId: salonId),
    query: .init(serviceIds: .init(servicesArray: [id1, id2]))
)

// cart=[{"purchase_id":"…","count":2}] — staff_id required on v2 terminals
try await client.getTerminalCartCost(
    query: .init(cart: [.init(purchaseId: svcId, staffId: staffId)])
)
```

## Two error channels

| Channel | Shape | Example |
|---|---|---|
| Documented outcomes | `Output` enum cases | `.created`, `.badRequest`, `.undocumented` |
| Runtime failures | thrown `ClientError` | DNS, TLS, a body the schema rejects |

And the third, easy to forget: `errors.code != 0` inside a 200 envelope — a domain
error the transport never sees.

## Pagination has three spellings

`Meta` (clients/bookings), `Pagination` (comments), `navigation` (shop). The property
names differ per operation — check the generated type for the one you're calling.

## Terminal v2

`/hs/api/v2/` paths take no `salon_id`. `findClientByPhone` returns a `usertoken`
inside `client_data` for downstream calls; `authorizeTerminal` mints one from a phone +
optional name. Terminal cart items require `staff_id` (v1's is optional) and payment
adds `receipt_number`.

## Dates are strings — on purpose

The API speaks five date dialects (`iso8601` basic, `dd.mm.yyyy`, `yyyy-mm-dd HH:MM`,
ISO variants). The client keeps them `String` — parse with your own formatter, and
expect the doc's declared format to be aspirational (TD-7).
