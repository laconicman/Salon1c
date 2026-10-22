import Foundation
import HTTPTypes
import Testing
@testable import Salon1cAPI

/// The `Client+init` conveniences and the generated `Servers` base URL — the pieces of
/// surface that exist before the first operation lands.
@Suite("Client construction")
struct ClientInitTests {
    @Test("the declared server is the documented cloud host", .tags(.specContract))
    func declaredServerURL() throws {
        #expect(try Servers.Server1.url().absoluteString == "http://cloud.salon1c.ru/api/")
    }

    @Test("client builds over a stub transport with default server")
    func buildsWithDefaults() throws {
        _ = try Client(credentials: .init(apiKey: "k"), middlewares: [], transport: StubTransport(json: "{}"))
    }

    @Test("the convenience init keeps the auth chain over a supplied transport")
    func convenienceInitKeepsAuthChain() async throws {
        let recorder = RequestRecorder()
        let client = try Client(
            credentials: .init(apiKey: "k", userToken: "u"),
            transport: RecordingTransport(recorder: recorder, json: Fixture.authTypesResponseJSON)
        )
        _ = try await client.getAuthTypes(path: .init(salonId: "s"))
        let request = try #require(await recorder.request)
        #expect(request.headerFields[.salonAPIKey] == "k")
        #expect(request.headerFields[.salonUserToken] == "u")
    }

    @Test("an apikey-only credential stays anonymous — userToken stays nil")
    func anonymousCredentials() {
        let credentials = Credentials(apiKey: "k")
        #expect(credentials.userToken == nil)
    }
}
