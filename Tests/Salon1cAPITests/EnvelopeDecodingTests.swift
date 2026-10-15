import Foundation
import Testing
@testable import Salon1cAPI

/// Decoding the API's documented examples verbatim, through `StubTransport`. Every test
/// pins a shape `openapi.yaml` claims; a failure means the document drifted from what the
/// package can decode — the upstream source changed, or the document was wrong.
@Suite("Envelope decoding")
struct EnvelopeDecodingTests {
    @Test("auth_types answers the lowercase envelope", .tags(.specContract))
    func authTypesLowercaseEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.authTypesResponseJSON)
        let body = try await client.getAuthTypes(path: .init(salonId: "test-salon")).ok.body.json
        #expect(body.parameters?.count == 3)
        #expect(body.parameters?.first?.title == "СМС")
        #expect(body.errors?.code == 0)
    }

    @Test("authorize decodes the «code sent» variant", .tags(.specContract))
    func authorizeCodeSentVariant() async throws {
        let client = try Client.stubbed(json: Fixture.authCodeSentResponseJSON)
        let output = try await client.authorize(
            path: .init(salonId: "test-salon"),
            body: .json(.init(login: "77731315"))
        )
        guard case .ok(let ok) = output, case .json(let payload) = ok.body else {
            Issue.record("expected .ok/.json, got \(output)")
            return
        }
        guard case .AuthCodeSentEnvelope(let envelope) = payload else {
            Issue.record("expected AuthCodeSentEnvelope, got \(payload)")
            return
        }
        #expect(envelope.parameters?.sentSMS == true)
        #expect(envelope.error == 0)
    }

    @Test("authorize decodes the «UserToken issued» variant", .tags(.specContract))
    func authorizeTokenVariant() async throws {
        let client = try Client.stubbed(json: Fixture.userTokenEnvelopeResponseJSON)
        let output = try await client.authorize(
            path: .init(salonId: "test-salon"),
            body: .json(.init(login: "77731315", confirmationCode: "9876"))
        )
        let payload = try output.ok.body.json
        guard case .UserTokenEnvelope(let envelope) = payload else {
            Issue.record("expected UserTokenEnvelope, got \(payload)")
            return
        }
        #expect(envelope.parameters.userToken == "9323751AAB5A5925142F352BBA7913B3")
        #expect(envelope.errors?.code == 0)
    }

    @Test("checkUserToken answers the bare Result shape", .tags(.specContract))
    func userTokenValidityBareResult() async throws {
        let client = try Client.stubbed(json: Fixture.usertokenValidityResponseJSON)
        let body = try await client.checkUserToken(path: .init(salonId: "test-salon")).ok.body.json
        #expect(body.result == true)
    }

    @Test("requestPhoneConfirmation answers the PascalCase envelope", .tags(.specContract))
    func phoneConfirmationPascalCaseEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.phoneConfirmationResponseJSON)
        let body = try await client.requestPhoneConfirmation(
            path: .init(salonId: "test-salon"),
            body: .json(.init(phone: "79876543210"))
        ).ok.body.json
        #expect(body.parameters?.outgoingId == "you_can_login_bot")
        #expect(body.parameters?.method == "outgoing_telegram")
        #expect(body.errors?.code == 0)
    }

    @Test("getClientToken shares the UserToken envelope", .tags(.specContract))
    func clientTokenEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.userTokenEnvelopeResponseJSON)
        let body = try await client.getClientToken(
            path: .init(salonId: "test-salon"),
            body: .json(.init(requestId: "27dd2f8e-32a4-11ee-b18f-f02f7488d897"))
        ).ok.body.json
        #expect(body.parameters.userToken == "9323751AAB5A5925142F352BBA7913B3")
    }

    @Test("getBookableServices answers a PascalCase array, Errors absent", .tags(.specContract))
    func bookableServicesEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.bookableServicesResponseJSON)
        let body = try await client.getBookableServices(path: .init(salonId: "test-salon")).ok.body.json
        let service = try #require(body.parameters?.first)
        #expect(service.title == "Мезотерапия")
        #expect(service.servicesAtSameTime?.count == 2)
        #expect(service.category?.title == "Косметология")
        #expect(body.errors == nil)
    }

    @Test("getBookableStaff decodes nested ratings, fractional rating", .tags(.specContract))
    func bookableStaffEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.bookableStaffResponseJSON)
        let body = try await client.getBookableStaff(path: .init(salonId: "test-salon")).ok.body.json
        let staff = try #require(body.parameters?.first)
        #expect(staff.name == "Новикова Анна")
        #expect(staff.specialization?.title == "Косметолог")
        #expect(staff.upcomingDates?.count == 3)
        #expect(staff.ratings?.count == 2)
        #expect(staff.ratings?.last?.rating == 4.5)
        #expect(staff.commentsCount == 3)
    }

    @Test("getBookableDates answers a bare ISO string array", .tags(.specContract))
    func bookableDatesEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.bookableDatesResponseJSON)
        let body = try await client.getBookableDates(
            path: .init(salonId: "test-salon"),
            query: .init(startDate: "20170820T0000", endDate: "20170831T0000")
        ).ok.body.json
        #expect(body.parameters?.count == 4)
        #expect(body.parameters?.first == "2017-08-20T00:00:00")
    }

    @Test("getBookableTimes decodes the slot structure", .tags(.specContract))
    func bookableTimesEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.bookableTimesResponseJSON)
        let body = try await client.getBookableTimes(path: .init(salonId: "test-salon")).ok.body.json
        let slot = try #require(body.parameters?.first)
        #expect(slot.time == "09:00")
        #expect(slot.seanceLength == 30)
        #expect(slot.datetime == "2017-08-24T09:00:00")
    }

    @Test("getRecordingDates keeps the dd.mm.yyyy date dialect as strings", .tags(.specContract))
    func recordingDatesEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.recordingDatesResponseJSON)
        let body = try await client.getRecordingDates(
            path: .init(salonId: "test-salon"),
            query: .init(startDate: "20240805T0000", endDate: "20240905T0000")
        ).ok.body.json
        let item = try #require(body.parameters?.first)
        #expect(item.id == "ef0fd170-3c83-465d-836b-51d72d208831")
        #expect(item.date?.first == "06.08.2024 11:00:00")
    }

    @Test("bookVisit decodes the fuller result; Errors decodes as null", .tags(.specContract))
    func bookVisitEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.bookVisitResponseJSON)
        let body = try await client.bookVisit(
            path: .init(salonId: "test-salon"),
            body: .json(.init(recordArray: [
                .init(datetime: "20240831T1500", serviceId: "9ca0fa6c-48ee-11ea-96bc-38d547b31ac0")
            ]))
        ).ok.body.json
        let result = try #require(body.parameters)
        #expect(result.result == true)
        #expect(result.status == "TemporarilyReservedNeedPayment")
        #expect(result.sum == 2300)
        #expect(result.mayBePayment?.first?.paymentAmount == 1300)
    }

    @Test("rescheduleVisit and cancelVisit share the Result envelope, Errors null", .tags(.specContract))
    func resultEnvelopeShared() async throws {
        let client = try Client.stubbed(json: Fixture.resultEnvelopeJSON)
        let rescheduled = try await client.rescheduleVisit(
            path: .init(salonId: "test-salon"),
            query: .init(recordId: "d4608b12-5a07-11e9-899e-2c4d546557dd", datetime: "20170820T1030")
        ).ok.body.json
        #expect(rescheduled.parameters?.result == true)
        #expect(rescheduled.errors == nil)

        let cancelled = try await client.cancelVisit(
            path: .init(salonId: "test-salon"),
            query: .init(recordId: "d4608b12-5a07-11e9-899e-2c4d546557dd")
        ).ok.body.json
        #expect(cancelled.parameters?.result == true)
    }

    @Test("getRecordCost answers the lowercase envelope with the cart payload", .tags(.specContract))
    func recordCostLowercaseEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.recordCostResponseJSON)
        let body = try await client.getRecordCost(
            path: .init(salonId: "test-salon"),
            query: .init(recordArray: [
                .init(datetime: "20240831T1500", serviceId: "9ca0fa6c-48ee-11ea-96bc-38d547b31ac0", staffId: "663290db-105c-41cc-97d4-ed5151065813")
            ], promocode: "Test")
        ).ok.body.json
        let payload = try #require(body.parameters)
        let position = try #require(payload.cart?.first)
        #expect(position.purchase?._type == "service")
        #expect(position.priceWithDiscount == 50)
        #expect(position.nds == 1)
        #expect(payload.totalAmount == 50)
        #expect(payload.mayBePayment?.first?._type == "deposit")
        #expect(payload.promotions?.first?.title == "50% промокод Test")
        #expect(payload.promocode == "Test")
        #expect(body.errors?.code == 0)
    }
}
