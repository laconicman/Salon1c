import Foundation
import HTTPTypes
import Testing
@testable import Salon1cAPI

/// What the generated client puts on the wire: path shapes, query serialization —
/// above all the JSON-string parameters the API calls «строка Json» — and request
/// bodies. `RecordingTransport` captures the assembled `HTTPRequest` downstream of
/// the middleware stack.
@Suite("Request encoding")
struct RequestEncodingTests {
    /// Query items of the captured request, parsed back out of `request.path`.
    private func queryItems(of request: HTTPRequest) throws -> [URLQueryItem] {
        let path = try #require(request.path)
        let components = try #require(URLComponents(string: path))
        return components.queryItems ?? []
    }

    @Test("v1 paths keep the {salon_id} segment and trailing slash", .tags(.specContract))
    func salonIdPathShape() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.bookableDatesResponseJSON)
        _ = try await client.getBookableDates(
            path: .init(salonId: "0d190fc8-1c01-11ef-b1bf-f02f7488d897"),
            query: .init(startDate: "20240805T0000", endDate: "20240905T0000")
        )
        let path = try #require(await recorder.request?.path)
        #expect(path.hasPrefix("/hs/api/v1/book_dates/0d190fc8-1c01-11ef-b1bf-f02f7488d897/?"))
    }

    @Test("service_ids serializes as a JSON string, not exploded form", .tags(.specContract))
    func serviceIdsJSONQuery() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.bookableServicesResponseJSON)
        _ = try await client.getBookableServices(
            path: .init(salonId: "test-salon"),
            query: .init(serviceIds: .init(servicesArray: ["140df5b4-5a58-11e7-82e7-0050568b5c8d"]))
        )
        let request = try #require(await recorder.request)
        let items = try queryItems(of: request)
        let value = try #require(items.first { $0.name == "service_ids" }?.value)
        // The whole JSON object rides as one query value — the wire shape the doc's
        // «Строка Json» describes. Decoded back, it must be the wrapper object.
        let data = try #require(value.data(using: .utf8))
        let object = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
        #expect(object == ["services_array": ["140df5b4-5a58-11e7-82e7-0050568b5c8d"]])
    }

    @Test("record_array serializes as a JSON array in the query", .tags(.specContract))
    func recordArrayJSONQuery() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.recordCostResponseJSON)
        _ = try await client.getRecordCost(
            path: .init(salonId: "test-salon"),
            query: .init(recordArray: [
                .init(datetime: "20240831T1500", serviceId: "9ca0fa6c-48ee-11ea-96bc-38d547b31ac0", staffId: "663290db-105c-41cc-97d4-ed5151065813")
            ])
        )
        let request = try #require(await recorder.request)
        let items = try queryItems(of: request)
        let value = try #require(items.first { $0.name == "record_array" }?.value)
        let data = try #require(value.data(using: .utf8))
        let array = try JSONSerialization.jsonObject(with: data) as? [[String: String]]
        #expect(array == [["datetime": "20240831T1500", "service_id": "9ca0fa6c-48ee-11ea-96bc-38d547b31ac0", "staff_id": "663290db-105c-41cc-97d4-ed5151065813"]])
    }

    @Test("bookVisit sends the flat Attributes body, not the envelope the doc's example shows", .tags(.specContract))
    func bookVisitBodyShape() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.resultEnvelopeJSON)
        _ = try await client.bookVisit(
            path: .init(salonId: "test-salon"),
            body: .json(.init(
                recordArray: [.init(datetime: "20240831T1500", serviceId: "svc-1", staffId: "staff-1")],
                name: "Иван",
                comment: "Тест"
            ))
        )
        let body = try #require(await recorder.requestBody)
        let object = try #require(JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any])
        let recordArray = try #require(object["record_array"] as? [[String: String]])
        #expect(recordArray == [["datetime": "20240831T1500", "service_id": "svc-1", "staff_id": "staff-1"]])
        #expect(object["name"] as? String == "Иван")
        #expect(object["Parameters"] == nil)
    }

    @Test("usertoken rides the header on client-scoped operations", .tags(.specContract))
    func userTokenHeaderOnBookedOps() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(
            recorder: recorder,
            userToken: "256D323401901DB2BD42405FA54509B0",
            json: Fixture.resultEnvelopeJSON
        )
        _ = try await client.cancelVisit(
            path: .init(salonId: "test-salon"),
            query: .init(recordId: "d4608b12-5a07-11e9-899e-2c4d546557dd")
        )
        let request = try #require(await recorder.request)
        #expect(request.headerFields[.init("usertoken")!] == "256D323401901DB2BD42405FA54509B0")
        #expect(request.headerFields[.init("apikey")!] == "test-apikey")
    }

    @Test("cart_cost rides cart and client as JSON strings in the query", .tags(.specContract))
    func cartCostJSONQuery() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.cartCostResponseJSON)
        _ = try await client.getCartCost(
            path: .init(salonId: "test-salon"),
            query: .init(
                cart: [.init(purchaseId: "a62afb1e-97b2-11e7-b142-0050568b93ed", count: 2)],
                client: .init(phone: "+79001001010", lastName: "Петров", name: "Пётр")
            )
        )
        let request = try #require(await recorder.request)
        let items = try queryItems(of: request)
        let cart = try #require(items.first { $0.name == "cart" }?.value)
        let cartData = try #require(cart.data(using: .utf8))
        let cartArray = try JSONSerialization.jsonObject(with: cartData) as? [[String: Any]]
        #expect(cartArray?.first?["purchase_id"] as? String == "a62afb1e-97b2-11e7-b142-0050568b93ed")
        #expect(cartArray?.first?["count"] as? Int == 2)
        let clientValue = try #require(items.first { $0.name == "client" }?.value)
        let clientData = try #require(clientValue.data(using: .utf8))
        let clientObject = try JSONSerialization.jsonObject(with: clientData) as? [String: String]
        #expect(clientObject?["phone"] == "+79001001010")
        #expect(clientObject?["last_name"] == "Петров")
    }

    @Test("v2 templated paths carry no salon_id and keep the literal trailing slash", .tags(.specContract))
    func terminalPathShape() async throws {
        // The .apib URI template `/hs/api/v2/book_staff/{?datetime}` leaves a literal
        // trailing slash — and the Apiary mock 404s the slash-less form. Wire evidence.
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.terminalStaffResponseJSON)
        _ = try await client.getTerminalStaff(query: .init(datetime: "20170820T0000"))
        let path = try #require(await recorder.request?.path)
        #expect(path.hasPrefix("/hs/api/v2/book_staff/?"))
        #expect(!path.contains("salon_id"))
    }
}
