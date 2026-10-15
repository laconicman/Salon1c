# Salon1cAPI

A Swift client for the [1С:SPA-Салон API, редакция 3.0](https://salon1c.docs.apiary.io/),
generated with [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator)
and exposed as-is, so every request the API accepts is expressible.

Requests go over [`URLSession`](https://developer.apple.com/documentation/foundation/urlsession)
via [Swift OpenAPI URLSession Transport](https://github.com/apple/swift-openapi-urlsession).

> **Unofficial.** 1С publishes neither a Swift SDK nor an OpenAPI document for this API.
> `openapi.yaml` here was written by hand from the vendor's API Blueprint reference
> (`Upstream/salon1c/salon1c.apib`), which makes it this package's greatest asset and its
> largest liability. See [Owning the Specification](Sources/Salon1cAPI/Salon1cAPI.docc/SpecOwnership.md).
> Unaffiliated with 1С.

> **Status: in development** — the specification has not been exercised against the live
> API yet. See [Tech Debt](Sources/Salon1cAPI/Salon1cAPI.docc/TechDebt.md) before relying
> on a schema.

## Documentation

The rendered DocC catalog is authoritative for architecture and direction; when it and this
README disagree, believe the catalog. Build it with
`swift package generate-documentation --target Salon1cAPI`, or read the sources:

| Article | What it answers |
|---|---|
| [Design](Sources/Salon1cAPI/Salon1cAPI.docc/Design.md) | Every load-bearing decision, with the alternative that was rejected |
| [Owning the Specification](Sources/Salon1cAPI/Salon1cAPI.docc/SpecOwnership.md) | Why `openapi.yaml` is hand-written, and what that obligates |
| [Working with the 1С API](Sources/Salon1cAPI/Salon1cAPI.docc/WorkingWithSalon1c.md) | What the API actually does — documented quirks first, dated wire observations as they arrive |
| [Tech Debt](Sources/Salon1cAPI/Salon1cAPI.docc/TechDebt.md) | Every compromise carried, what it costs, and what would retire it |
| [Roadmap](Sources/Salon1cAPI/Salon1cAPI.docc/Roadmap.md) | Planned work in priority order |

## Installation

```swift
.package(url: "https://github.com/laconicman/Salon1c", from: "0.1.0")
```

Requires Swift 6.2 or newer, and iOS 17 / macOS 14 / tvOS 17 / watchOS 10 / visionOS 1.

## Coverage

53 operations in 10 groups — the full documented API, both `/hs/api/v1/` and `/hs/api/v2/`:

| Group | Operations |
|---|---|
| `auth` | auth variants, authorize, usertoken validity, digital-signature auth, phone confirmation, client token |
| `booking` | services/staff/dates/times for booking, record/move/cancel, cost calculation |
| `visits` | finished and current visit lists |
| `visit-payment` | debt visits, pay a visit |
| `clients` | client cards, deposit/bonus accounts, history, service packages |
| `salons` | salon information |
| `services` | records list/edit, service catalogue |
| `ratings` | set visit rating, read comments |
| `shop` | price list, cart cost, payment, orders, deliveries, filters |
| `terminal` | self-service terminal (v2): staff, services, client lookup, auth, cart, payment |

## Usage

```swift
import Foundation
import Salon1cAPI

let client = try Client(credentials: .init(apiKey: "<apikey>", userToken: "<usertoken>"))

let response = try await client.getAuthTypes(path: .init(salonId: "<salon-guid>"))
switch response {
case .ok(let ok):
    for variant in try ok.body.json.parameters {
        print(variant.type, variant.title)
    }
case .badRequest(let bad):
    print(bad.body.json.errors.message ?? "bad request")
case .undocumented(let statusCode, _):
    // The document is wrong. Please open an issue — see Owning the Specification.
    print("undocumented status \(statusCode)")
}
```

### Two envelopes, both deliberate

The API wraps every reply in `{parameters, errors}` — **lowercase on most operations,
PascalCase (`Parameters`/`Errors`/`Meta`) on the client-record family**. Both are wired
exactly as documented; a non-zero `errors.code` is a domain refusal (catalogue 1000–1114)
inside HTTP 200, and today it surfaces as data — an unwrap convenience is on the roadmap.

### Two credential headers

Every request carries `apikey`; client-scoped operations also carry `usertoken`.
`Credentials(apiKey:userToken:)` keeps them together; `usertoken` is `nil` until a client
has authorized (see the `auth` group).

## Generated code

`Client.swift` and `Types.swift` are produced by the generator **build plugin** on every
build and are never committed. Editing `openapi.yaml` is the whole regeneration workflow —
the reviewable diff is the diff of the document itself.

```console
% swift build
```

Fix specification problems *in the document*, not in Swift — see
[Owning the Specification](Sources/Salon1cAPI/Salon1cAPI.docc/SpecOwnership.md).

## Testing

```console
% swift test --skip "Live API"   # no network, no credentials — the default
```

The offline suites cover envelope decoding against verbatim doc examples, JSON-in-query
serialization, the auth middleware and path shapes. `LiveClientTests` talks to the real API
and self-skips without `SALON1C_API_KEY` + `SALON1C_SALON_ID` — dormant until credentials
exist; the host is geo-restricted and may need a VPN.

## License

Apache 2.0 — see [LICENSE](LICENSE). Unofficial and unaffiliated with 1С.
