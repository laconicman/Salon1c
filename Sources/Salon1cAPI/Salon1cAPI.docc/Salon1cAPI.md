# ``Salon1cAPI``

A type-safe, async/await client for the **1С:SPA-Салон** API (редакция 3.0), generated
from a hand-authored OpenAPI document with Apple's
[swift-openapi-generator](https://github.com/apple/swift-openapi-generator).

## Overview

The vendor publishes no OpenAPI document and no Swift SDK — only an API Blueprint at
[salon1c.docs.apiary.io](https://salon1c.docs.apiary.io/). The document in this package
was translated from that Blueprint by hand, which makes it the load-bearing artifact
here — see <doc:SpecOwnership>. All **53 documented operations** are covered.

The API serves three surfaces: a client app (auth, booking, visits, clients, ratings),
an online shop (prices, cart, orders), and a self-service terminal (`/hs/api/v2/`).
Two header credentials carry trust: `apikey` on every call, `usertoken` on
client-scoped ones — see ``Credentials``.

```swift
import Salon1cAPI

let client = try Client(credentials: .init(apiKey: "<salon api key>"))

let salons = try await client.getSalons(
    path: .init(salonId: "<salon id>")
)

switch salons {
case .ok(let ok):
    for salon in try ok.body.json.parameters ?? [] {
        print(salon.title ?? "-", salon.phone ?? "")
    }
case .undocumented(let status, _):
    print("undocumented status:", status)
}
```

### The envelope is the contract

Most operations answer an *envelope* — `{parameters, errors}` — even on success, and the
payload's capitalization differs per operation group (lowercase vs `Parameters`/`Errors`,
plus four hybrid shapes). The client exposes envelopes exactly as documented; nothing is
normalized away. Domain errors arrive with HTTP 200 inside `errors.code` — check it
yourself, or read <doc:TechDebt> → TD-5 for the dialect map.

### JSON inside the query string

Several operations take «строка Json» — a JSON document serialized into a *query
parameter* (`service_ids`, `cart`, `record_array`, `filters`). The specification models
them as `content: application/json` query parameters, so generated code accepts typed
values and serializes them as one query item — exactly what the server expects.

## Topics

### Project Direction

- <doc:Design>
- <doc:SpecOwnership>
- <doc:WorkingWithSalon1c>
- <doc:TechDebt>
- <doc:Roadmap>

### Getting Started

- ``Credentials``
