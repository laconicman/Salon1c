import Foundation
import Testing
@testable import Salon1cAPI

/// The read-only half of live validation — the only thing that checks a hand-authored
/// specification against the API it describes.
///
/// Offline suites prove the client decodes what `openapi.yaml` *claims*; these prove the
/// claim. They need `SALON1C_API_KEY` + `SALON1C_SALON_ID`, plus `SALON1C_USER_TOKEN` for
/// client-scoped operations — and the documented host `cloud.salon1c.ru` has not answered
/// from this network since work began, so expect to need a VPN for them to run at all
/// (see `TechDebt` → TD-1).
///
/// Nothing here changes server-side state; the lifecycle that does lives in
/// ``LiveMutatingTests`` behind a second switch.
@Suite(
    "Live API",
    .tags(.live),
    .enabled(if: LiveEnvironment.salon != nil, "Set SALON1C_API_KEY + SALON1C_SALON_ID to run"),
    .timeLimit(.minutes(1)),
    .serialized
)
struct LiveClientTests {
    private func liveClient() throws -> (client: Client, salonId: String) {
        let salon = try #require(LiveEnvironment.salon)
        return (try Client(credentials: salon.credentials), salon.salonId)
    }

    @Test("getAuthTypes answers the lowercase envelope on a live host")
    func authTypesLive() async throws {
        let (client, salonId) = try liveClient()
        let body = try await client.getAuthTypes(path: .init(salonId: salonId)).ok.body.json
        #expect(body.parameters?.isEmpty == false)
        #expect(body.errors?.code == 0)
    }

    @Test("getSalons answers the PascalCase envelope with Meta")
    func salonsLive() async throws {
        let (client, salonId) = try liveClient()
        let body = try await client.getSalons(path: .init(salonId: salonId)).ok.body.json
        #expect(body.errors == nil || body.errors?.code == 0)
    }

    @Test("getProductGroups answers a bare array in parameters")
    func productGroupsLive() async throws {
        let (client, salonId) = try liveClient()
        let body = try await client.getProductGroups(path: .init(salonId: salonId)).ok.body.json
        #expect(body.parameters != nil)
        #expect(body.errors?.code == 0)
    }

    @Test("getPriceList keeps errors inside parameters on the wire", .tags(.regression))
    func priceListLive() async throws {
        // The nested-errors shape is TD-5's strangest claim — this is the only suite
        // that can falsify it.
        let (client, salonId) = try liveClient()
        let body = try await client.getPriceList(
            path: .init(salonId: salonId),
            query: .init(pageCount: "5", pageNumber: "1")
        ).ok.body.json
        #expect(body.parameters?.errors?.code == 0)
        #expect(body.parameters?.priceClient != nil)
    }

    @Test("getDeliveryOptions lists pickup and courier services")
    func deliveryListLive() async throws {
        let (client, salonId) = try liveClient()
        let body = try await client.getDeliveryOptions(path: .init(salonId: salonId)).ok.body.json
        #expect(body.parameters?.isEmpty == false)
        // Pickup carries `id: null` — the nullable-id claim, checked live.
        #expect(body.parameters?.contains { $0.code == "pickup" } == true)
    }

    @Test(
        "getOrders needs and uses usertoken",
        .enabled(if: LiveEnvironment.salon?.credentials.userToken != nil, "Set SALON1C_USER_TOKEN to run")
    )
    func ordersLive() async throws {
        let (client, salonId) = try liveClient()
        let body = try await client.getOrders(
            path: .init(salonId: salonId),
            query: .init(pageCount: "5")
        ).ok.body.json
        #expect(body.parameters?.navigation != nil)
        #expect(body.errors?.code == 0)
    }
}

@Suite(
    "Live API (mutating)",
    .tags(.live, .mutating),
    .enabled(
        if: LiveEnvironment.salon != nil && LiveEnvironment.mutatingAllowed,
        "Set SALON1C_ALLOW_MUTATING_LIVE_TESTS=1 on top of the credentials to run"
    ),
    .timeLimit(.minutes(1)),
    .serialized
)
struct LiveMutatingTests {
    /// Creates a real client record in the target salon — deliberately named so a human
    /// can find and remove it. Needs `SALON1C_TEST_PHONE` for a phone the SMS path could
    /// reach; without it the suite stays dark even when armed.
    @Test(
        "createClient writes a findable test record",
        .enabled(
            if: LiveEnvironment.variable("SALON1C_TEST_PHONE") != nil,
            "Set SALON1C_TEST_PHONE to run"
        )
    )
    func createClientLive() async throws {
        let salon = try #require(LiveEnvironment.salon)
        let client = try Client(credentials: salon.credentials)
        let phoneString = try #require(LiveEnvironment.variable("SALON1C_TEST_PHONE"))
        // `ClientCreateRequest.phone` is the documented *numeric* variant (TD-6) —
        // digits only, e.g. "79001001010".
        let phone = try #require(
            Double(phoneString),
            "SALON1C_TEST_PHONE must be digits only — the spec's numeric phone variant"
        )
        let output = try await client.createClient(
            path: .init(salonId: salon.salonId),
            body: .json(.init(
                salonId: salon.salonId,
                name: "SALON1CAPI-LIVE-TEST",
                phone: phone
            ))
        )
        let created = try output.created.body.json
        #expect(created.parameters?.id != nil)
    }
}
