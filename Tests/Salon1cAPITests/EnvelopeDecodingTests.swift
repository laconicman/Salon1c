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
}
