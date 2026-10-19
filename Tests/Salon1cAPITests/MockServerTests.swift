import Foundation
import Testing
@testable import Salon1cAPI

/// Exercises the generated client end-to-end against **Apiary's mock of the vendor's
/// own Blueprint** — `http://private-anon-5309c9fb20-salon1c.apiary-mock.com`.
///
/// This is not the real API: the mock replays the documented example bodies. But those
/// examples are the contract the spec was written from, so a green run here proves
/// real `URLSession` transport, URL shapes, header injection, JSON-in-query
/// serialization and decoding — everything except values the doc doesn't show.
/// It already caught one spec bug (v2 trailing slashes, see `terminalPathShape`).
///
/// Needs `SALON1C_MOCK_TESTS=1` (network only, no credentials). Override the host with
/// `SALON1C_MOCK_URL` for a private Apiary project — the `/api` prefix must stay.
@Suite(
    "Apiary mock",
    .tags(.live),
    .enabled(if: LiveEnvironment.mockEnabled, "Set SALON1C_MOCK_TESTS=1 to run"),
    .timeLimit(.minutes(1)),
    .serialized
)
struct MockServerTests {
    @Test("getAuthTypes answers the lowercase envelope over real HTTP")
    func authTypes() async throws {
        let client = try LiveEnvironment.mockClient()
        let body = try await client.getAuthTypes(
            path: .init(salonId: "mock-salon")
        ).ok.body.json
        #expect(body.parameters?.isEmpty == false)
        #expect(body.errors?.code == 0)
    }

    @Test("getSalons answers the PascalCase envelope over real HTTP")
    func salons() async throws {
        let client = try LiveEnvironment.mockClient()
        let body = try await client.getSalons(
            path: .init(salonId: "mock-salon")
        ).ok.body.json
        #expect(body.parameters.first?.title != nil)
    }

    @Test("getPriceList answers errors nested inside parameters — the TD-5 shape", .tags(.regression))
    func priceListNestedErrors() async throws {
        // The strangest dialect claim, verified against the vendor's own mock: the
        // error object lives *inside* parameters, beside navigation. The vendor
        // OpenAPI types `errors` at top level instead — patch P9 keeps both shapes
        // decodable; the mock still serves the nested one.
        let client = try LiveEnvironment.mockClient()
        let body = try await client.getPriceList(
            path: .init(salonId: "mock-salon"),
            query: .init(_type: "product")
        ).ok.body.json
        #expect(body.parameters?.errors?.code == 0)
        #expect(body.parameters?.priceClient?.first?.price != nil)
    }

    @Test("getCartCost accepts the JSON-in-query cart parameter")
    func cartCostJSONQuery() async throws {
        let client = try LiveEnvironment.mockClient()
        let body = try await client.getCartCost(
            path: .init(salonId: "mock-salon"),
            query: .init(cart: [.init(purchaseId: "c85e4472-cc8f-11e8-8973-2c4d546557dd", count: 1)])
        ).ok.body.json
        #expect(body.parameters?.cart?.first?.purchase != nil)
    }

    @Test("getPublicOffer returns the text/html body case")
    func publicOfferHTML() async throws {
        let client = try LiveEnvironment.mockClient()
        let output = try await client.getPublicOffer(path: .init(salonId: "mock-salon"))
        let html = try await output.ok.body.html
        _ = try await String(collecting: html, upTo: 1024 * 64)
    }

    @Test("getTerminalStaff answers on the v2 path with trailing slash")
    func terminalStaff() async throws {
        let client = try LiveEnvironment.mockClient()
        let body = try await client.getTerminalStaff(
            query: .init(datetime: "20170820T0000")
        ).ok.body.json
        #expect(body.parameters?.first?.employeeName != nil)
    }

    @Test("authorizeTerminal answers the hybrid UserToken envelope")
    func terminalAuth() async throws {
        let client = try LiveEnvironment.mockClient()
        let body = try await client.authorizeTerminal(
            body: .json(.init(phone: "+79882843957", name: "Иванов Иван"))
        ).ok.body.json
        #expect(body.parameters?.userToken != nil)
    }

    @Test("getTerminalCartCost answers fiscalization fields")
    func terminalCartCost() async throws {
        let client = try LiveEnvironment.mockClient()
        let body = try await client.getTerminalCartCost(
            query: .init(cart: [.init(
                purchaseId: "e21cf6d4-5a57-11e7-82e7-0050568b5c8d",
                staffId: "e6c1b1fa-0571-11e7-a42a-0050568b5c8d"
            )])
        ).ok.body.json
        #expect(body.parameters?.cart?.first?.paymentObject == "service")
    }
}
