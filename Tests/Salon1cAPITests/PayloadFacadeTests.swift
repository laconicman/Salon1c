import Foundation
import HTTPTypes
import Testing
@testable import Salon1cAPI

/// The generated `payload()` facade: one chained call folds the envelope's three
/// error channels into `Salon1cError`. Same fixtures as `EnvelopeDecodingTests` —
/// where that suite asserts the shape arrives, this one asserts the unwrap.
@Suite("Payload facade")
struct PayloadFacadeTests {
    @Test("getSalons unwraps the PascalCase envelope", .tags(.facade, .specContract))
    func salonsPascalCase() async throws {
        let client = try Client.stubbed(json: Fixture.salonsResponseJSON)
        let salons = try await client.getSalons(path: .init(salonId: "test-salon")).payload()
        #expect(salons.count == 1)
        #expect(salons.first?.title == "OOO \"Салон красоты\"")
    }

    @Test("getAuthTypes unwraps the lowercase envelope", .tags(.facade, .specContract))
    func authTypesLowercase() async throws {
        let client = try Client.stubbed(json: Fixture.authTypesResponseJSON)
        let types = try await client.getAuthTypes(path: .init(salonId: "test-salon")).payload()
        #expect(types.count == 3)
        #expect(types.first?.title == "СМС")
    }

    @Test("searchClients returns Paged — parameters + Meta", .tags(.facade, .specContract))
    func searchClientsPaged() async throws {
        let client = try Client.stubbed(json: Fixture.clientsResponseJSON)
        let page = try await client.searchClients(
            path: .init(salonId: "test-salon"),
            body: .json(.init(
                orderByDirection: .desc,
                filters: [.init(_type: "phone", value: .case1("77777777777"))]
            ))
        ).payload()
        #expect(page.items.first?.surname == "Петров")
        #expect(page.meta.itemsCount == 10)
        #expect(page.meta.pagesCount == 2)
    }

    @Test("getComments returns Paged — parameters + Pagination (TD-5)", .tags(.facade, .specContract))
    func commentsPaged() async throws {
        let client = try Client.stubbed(json: Fixture.commentsResponseJSON)
        let page = try await client.getComments(path: .init(salonId: "test-salon")).payload()
        #expect(page.items.count == 2)
        #expect(page.items.first?.client?.name == "Анна Каренина")
        #expect(page.meta?.itemsCount == 22)
    }

    @Test("rateVisit unwraps the singular-Error envelope", .tags(.facade, .specContract))
    func rateVisitSingularError() async throws {
        let client = try Client.stubbed(json: Fixture.rateVisitResponseJSON)
        let payload = try await client.rateVisit(
            path: .init(salonId: "test-salon"),
            body: .json(.init(recordId: "3daa8097-ff6a-11e7-b770-0050568b5c8d", staffId: "222d3814-49f4-11e7-b491-0050568b5c8d", rating: 5, comment: "Отличное обслуживание"))
        ).payload()
        #expect(payload.result == true)
    }

    @Test("checkUserToken unwraps the bare Result shape", .tags(.facade, .specContract))
    func checkUserTokenBareResult() async throws {
        let client = try Client.stubbed(json: Fixture.usertokenValidityResponseJSON)
        let valid = try await client.checkUserToken(path: .init(salonId: "test-salon")).payload()
        #expect(valid == true)
    }

    @Test("getPriceList throws .refused on errors nested inside parameters", .tags(.facade))
    func priceListNestedRefusal() async throws {
        let client = try Client.stubbed(json: #"""
        {
            "parameters": {
                "price_client": [],
                "errors": {"code": 1050, "message": "Не найден объект"}
            },
            "errors": {"code": 0, "message": ""}
        }
        """#)
        await #expect(throws: Salon1cError.refused(code: 1050, message: "Не найден объект", operation: "getPriceList")) {
            try await client.getPriceList(path: .init(salonId: "test-salon")).payload()
        }
    }

    @Test("top-level errors.code ≠ 0 in a 200 throws .refused", .tags(.facade))
    func topLevelRefusal() async throws {
        let client = try Client.stubbed(json: #"""
        {
            "Parameters": [],
            "Errors": {"code": 1050, "message": "Не найден объект"}
        }
        """#)
        await #expect(throws: Salon1cError.refused(code: 1050, message: "Не найден объект", operation: "getSalons")) {
            try await client.getSalons(path: .init(salonId: "test-salon")).payload()
        }
    }

    @Test("a 200 envelope with neither payload nor error throws .missingPayload", .tags(.facade))
    func missingPayload() async throws {
        // `getAuthTypes` — `parameters` is optional there, so the envelope
        // decodes and the guard in `payload()` decides. (`getSalons` marks
        // `Parameters` required; an absent key fails decoding earlier.)
        let client = try Client.stubbed(json: #"{"errors": {"code": 0, "message": ""}}"#)
        await #expect(throws: Salon1cError.missingPayload(operation: "getAuthTypes")) {
            try await client.getAuthTypes(path: .init(salonId: "test-salon")).payload()
        }
    }

    @Test("createClient unwraps the 201 envelope", .tags(.facade, .specContract))
    func createClientCreated() async throws {
        let client = try Client.stubbed(status: .created, json: Fixture.clientCreatedResponseJSON)
        let created = try await client.createClient(
            path: .init(salonId: "test-salon"),
            body: .json(.init(name: "Василий", phone: 79211234567))
        ).payload()
        #expect(created.name == "Василий")
    }

    @Test("a documented 400 throws .status with the typed body's code", .tags(.facade))
    func badRequestStatus() async throws {
        let client = try Client.stubbed(status: .badRequest, json: #"""
        {"Errors": {"code": 1050, "message": "Не найден объект"}}
        """#)
        await #expect(throws: Salon1cError.status(400, code: 1050, message: "Не найден объект", operation: "createClient")) {
            try await client.createClient(
                path: .init(salonId: "test-salon"),
                body: .json(.init(phone: 79211234567))
            ).payload()
        }
    }

    @Test("a documented 401 throws .status — the body is a bare string", .tags(.facade))
    func unauthorizedStatus() async throws {
        let client = try Client.stubbed(status: .unauthorized, json: "\"bad apikey\"")
        await #expect(throws: Salon1cError.status(401, code: nil, message: "bad apikey", operation: "getSalons")) {
            try await client.getSalons(path: .init(salonId: "test-salon")).payload()
        }
    }

    @Test("an undocumented status throws .undocumentedStatus", .tags(.facade))
    func undocumentedStatus() async throws {
        let client = try Client.stubbed(status: .init(code: 418), json: "{}")
        await #expect(throws: Salon1cError.undocumentedStatus(418, operation: "getSalons")) {
            try await client.getSalons(path: .init(salonId: "test-salon")).payload()
        }
    }

    @Test("errorDescription names the operation on every case", .tags(.facade))
    func errorDescriptions() throws {
        let cases: [Salon1cError] = [
            .refused(code: 1050, message: "Не найден объект", operation: "getSalons"),
            .status(400, code: 1050, message: "Не найден объект", operation: "createClient"),
            .undocumentedStatus(418, operation: "getSalons"),
            .missingPayload(operation: "getComments"),
        ]
        for error in cases {
            let description = try #require(error.errorDescription)
            #expect(description.contains(error.operation))
        }
    }
}
