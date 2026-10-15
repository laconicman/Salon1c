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

    @Test("getVisits decodes the shared visit structure with status", .tags(.specContract))
    func visitsEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.visitsResponseJSON)
        let body = try await client.getVisits(path: .init(salonId: "test-salon")).ok.body.json
        let visit = try #require(body.parameters?.first)
        #expect(visit.status == "Finished")
        #expect(visit.actualStartDate == "2019-10-15T14:00:00")
        let service = try #require(visit.services?.first)
        #expect(service.service?.title == "Воздушно-вихревой массаж")
        #expect(service.staff?.title == "Ипритова Инга Юрьевна")
        #expect(visit.client?.phones?.first == "+7 (999) 8452010")
    }

    @Test("getFinishedVisits shares the visit structure", .tags(.specContract))
    func finishedVisitsEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.visitsResponseJSON)
        let body = try await client.getFinishedVisits(path: .init(salonId: "test-salon")).ok.body.json
        #expect(body.parameters?.first?.id == "2aa25425-e4f9-11e9-89ab-2c4d546557dd")
    }

    @Test("getDebtVisits decodes the PascalCase payload", .tags(.specContract))
    func debtVisitsEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.debtVisitsResponseJSON)
        let body = try await client.getDebtVisits(path: .init(salonId: "test-salon")).ok.body.json
        let visit = try #require(body.parameters?.first)
        #expect(visit.id == "e162eaea-ad88-11e7-8672-2c4d546557dd")
        #expect(visit.customer?.name == "Одношевич Евгений")
        #expect(visit.organization?.taxationSystem == "Общая система налогообложения")
        let service = try #require(visit.services?.first)
        #expect(service.name == "Стрижка мужская")
        #expect(service.sum == 500)
        #expect(visit.fiscalCheck == nil)
    }

    @Test("payVisit answers the shared Result envelope", .tags(.specContract))
    func payVisitEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.resultEnvelopeJSON)
        let body = try await client.payVisit(
            path: .init(salonId: "test-salon"),
            body: .json(.init(
                recordId: "2dc57d45-d41f-11e7-893b-2c4d546557dd",
                paymentList: [.init(_type: "card", amount: 1000), .init(_type: "deposit", amount: 1000, id: "ea18da46-98cf-11e9-89a3-2c4d546557dd")],
                transactionId: "2134"
            ))
        ).ok.body.json
        #expect(body.parameters?.result == true)
    }

    @Test("getClientInfo decodes the client card", .tags(.specContract))
    func clientCardEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.clientCardResponseJSON)
        let body = try await client.getClientInfo(path: .init(salonId: "test-salon")).ok.body.json
        let card = try #require(body.parameters)
        #expect(card.fullName == "Коренина Анна")
        #expect(card.sex == nil)
        #expect(card.email?.count == 2)
        #expect(card.recordsToRate?.first?.staff?.name == "Ипритова Инга Юрьевна")
        #expect(card.cards?.first?.cardType == "barcode")
        #expect(card.promocodes == [])
        #expect(card.status == "constant")
    }

    @Test("createClient answers 201, not 200", .tags(.specContract))
    func createClientCreated() async throws {
        let client = try Client.stubbed(status: .created, json: Fixture.clientCreatedResponseJSON)
        let output = try await client.createClient(
            path: .init(salonId: "test-salon"),
            body: .json(.init(salonId: "test-salon", name: "Василий", phone: 79211234567))
        )
        let body = try output.created.body.json
        #expect(body.parameters?.name == "Василий")
        #expect(body.errors?.code == 0)
    }

    @Test("createClient surfaces the documented 400 as an output case", .tags(.specContract))
    func createClientBadRequest() async throws {
        let client = try Client.stubbed(status: .badRequest, json: Fixture.badRequestResponseJSON)
        let output = try await client.createClient(
            path: .init(salonId: "test-salon"),
            body: .json(.init(salonId: "test-salon", phone: 79211234567))
        )
        guard case .badRequest(let badRequest) = output else {
            Issue.record("expected .badRequest, got \(output)")
            return
        }
        #expect(try badRequest.body.json.errors?.code == 1001)
    }

    @Test("searchClients decodes Parameters + Meta", .tags(.specContract))
    func clientsWithMeta() async throws {
        let client = try Client.stubbed(json: Fixture.clientsResponseJSON)
        let body = try await client.searchClients(
            path: .init(salonId: "test-salon"),
            body: .json(.init(
                salonId: "test-salon",
                orderByDirection: .desc,
                filters: [.init(_type: "phone", value: .case1("77777777777"))]
            ))
        ).ok.body.json
        #expect(body.parameters?.first?.surname == "Петров")
        #expect(body.parameters?.first?.statusId == 2)
        #expect(body.meta?.itemsCount == 10)
        #expect(body.meta?.pagesCount == 2)
    }

    @Test("getClientAccounts decodes deposit entries, history_exist as bool", .tags(.specContract))
    func clientAccountsEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.clientAccountsResponseJSON)
        let body = try await client.getClientAccounts(path: .init(salonId: "test-salon")).ok.body.json
        let entry = try #require(body.parameters?.first)
        #expect(entry.deposit?.depositType == "deposit")
        #expect(entry.deposit?.historyExist == true)
        #expect(entry.balance == 1700)
        #expect(body.parameters?.last?.deposit?.depositType == "bonus")
    }

    @Test("updateClientProfile decodes Result + data_client", .tags(.specContract))
    func clientProfileUpdateEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.clientProfileUpdateResponseJSON)
        let body = try await client.updateClientProfile(
            path: .init(salonId: "test-salon"),
            body: .json(.init(lastName: "Андреева", sex: 2))
        ).ok.body.json
        #expect(body.parameters?.result == true)
        #expect(body.parameters?.dataClient?.sex == "Женский")
        #expect(body.parameters?.dataClient?.email == ["Andreeva1975@mail.ru"])
        #expect(body.errors == nil)
    }

    @Test("refillDeposit answers the shared Result envelope", .tags(.specContract))
    func refillDepositEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.resultEnvelopeJSON)
        let body = try await client.refillDeposit(
            path: .init(salonId: "test-salon"),
            body: .json(.init(transactionId: "0fd124eb-f5f4-4ad3-be91-813eeb9761ae", cost: 1000, depositId: "123124eb-f5f4-4ad3-be91-123eeb976123"))
        ).ok.body.json
        #expect(body.parameters?.result == true)
    }

    @Test("getClientVisitHistory decodes name-keyed services", .tags(.specContract))
    func clientVisitHistoryEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.clientVisitsResponseJSON)
        let body = try await client.getClientVisitHistory(path: .init(salonId: "test-salon")).ok.body.json
        let visit = try #require(body.parameters?.first)
        #expect(visit.status == "arrived")
        #expect(visit.services?.first?.service?.name == "Гидромассаж")
        #expect(visit.services?.first?.staff?.name == "Ипритова Инга Юрьевна")
        #expect(visit.sumTotal == 6600)
    }

    @Test("getClientTickets decodes the verbatim-misspelled key and frozen fields", .tags(.specContract))
    func ticketsEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.ticketsResponseJSON)
        let body = try await client.getClientTickets(path: .init(salonId: "test-salon")).ok.body.json
        let ticket = try #require(body.parameters?.first)
        #expect(ticket.ticketId == "745f78b9-b1ec-497b-b42e-961a9d9b610a")
        #expect(ticket._type == "package")
        #expect(ticket.count == 6)
        #expect(ticket.avialableActions == [])
        #expect(ticket.typeActivation?._type == "at_sale")
        #expect(ticket.serviceList?.first?.title == "Услуга 3")
        #expect(ticket.availableClubs?.first?.title == "Салон 1")
        #expect(ticket.balanceFrozen == 0)
    }

    @Test("getClientTicket answers a single-object Parameters", .tags(.specContract))
    func ticketEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.ticketResponseJSON)
        let body = try await client.getClientTicket(
            path: .init(salonId: "test-salon"),
            query: .init(id: "bgsf102e6ba569gh20ac3hsad231ed80121")
        ).ok.body.json
        #expect(body.parameters?.ticketId == "745f78b9-b1ec-497b-b42e-961a9d9b610a")
        #expect(body.parameters?.availableClubs?.count == 2)
    }

    @Test("getSalons decodes work_time and contact_information", .tags(.specContract))
    func salonsEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.salonsResponseJSON)
        let body = try await client.getSalons(path: .init(salonId: "test-salon")).ok.body.json
        let salon = try #require(body.parameters?.first)
        #expect(salon.title == "OOO \"Салон красоты\"")
        #expect(salon.workTime?.first?.day == 1)
        #expect(salon.workTime?.first?.end == "22:00")
        #expect(salon.contactInformation?.address == "г.Москва")
    }

    @Test("getRecordsList decodes the Records structure with Meta", .tags(.specContract))
    func recordsListEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.recordsListResponseJSON)
        let body = try await client.getRecordsList(path: .init(salonId: "test-salon")).ok.body.json
        let record = try #require(body.parameters?.first)
        #expect(record.status == "confirmed")
        #expect(record.client?.displayName == "Соновен Савелий Васильевич")
        #expect(record.staffs?.first?.specialization?.title == "Врач стоматолог")
        #expect(record.services?.first?.costPerUnit == 500)
        #expect(record.createdUser?.title == "Администратор")
        #expect(body.meta?.pageSize == 5)
    }

    @Test("updateRecord answers the same array, no Meta", .tags(.specContract))
    func updateRecordEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.recordsListResponseJSON.replacingOccurrences(
            of: ",\n        \"Meta\": {\n            \"items_count\": 10,\n            \"pages_count\": 2,\n            \"page_current\": 1,\n            \"page_size\": 5\n        }",
            with: ""
        ))
        let body = try await client.updateRecord(
            path: .init(salonId: "test-salon"),
            body: .json(.init(salonId: "test-salon", id: "7c802c46-a899-4da1-b87c-eb2d68254f0f", status: "ended"))
        ).ok.body.json
        #expect(body.parameters?.first?.id == "7c802c46-a899-4da1-b87c-eb2d68254f0f")
    }

    @Test("getServices decodes category object and staff array", .tags(.specContract))
    func servicesListEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.servicesListResponseJSON)
        let body = try await client.getServices(path: .init(salonId: "test-salon")).ok.body.json
        let service = try #require(body.parameters?.first)
        #expect(service.category?.title == "Хирургия")
        #expect(service.staff?.first?.seanceLength == 60)
        #expect(service.active == true)
        #expect(body.meta?.itemsCount == 10)
    }

    @Test("rateVisit answers the singular-Error envelope", .tags(.specContract))
    func rateVisitEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.rateVisitResponseJSON)
        let body = try await client.rateVisit(
            path: .init(salonId: "test-salon"),
            body: .json(.init(recordId: "3daa8097-ff6a-11e7-b770-0050568b5c8d", staffId: "222d3814-49f4-11e7-b491-0050568b5c8d", rating: 5, comment: "Отличное обслуживание"))
        ).ok.body.json
        #expect(body.parameters?.result == true)
        #expect(body.error == nil)
    }

    @Test("getComments decodes Pagination, tolerates missing staff", .tags(.specContract))
    func commentsEnvelope() async throws {
        let client = try Client.stubbed(json: Fixture.commentsResponseJSON)
        let body = try await client.getComments(path: .init(salonId: "test-salon")).ok.body.json
        #expect(body.parameters?.count == 2)
        #expect(body.parameters?.first?.staff?.name == "Новикова Анна")
        #expect(body.parameters?.last?.staff == nil)
        #expect(body.parameters?.first?.client?.name == "Анна Каренина")
        #expect(body.pagination?.itemsCount == 22)
        #expect(body.pagination?.pageSize == 10)
    }
}
