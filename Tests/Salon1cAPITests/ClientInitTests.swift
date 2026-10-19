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

    @Test("an apikey-only credential stays anonymous — userToken stays nil")
    func anonymousCredentials() {
        let credentials = Credentials(apiKey: "k")
        #expect(credentials.userToken == nil)
    }
}
