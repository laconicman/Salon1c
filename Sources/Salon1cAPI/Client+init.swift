import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import Foundation
import OSLogLoggingMiddleware

public extension Client {
    /// A client authenticated with the salon API key, logging through `OSLog`.
    ///
    /// - Parameters:
    ///   - serverURL: Defaults to the single server declared by the specification —
    ///     the documented `http://cloud.salon1c.ru/api`. Per-salon on-premises
    ///     deployments serve the same API under their own base URL; pass it here.
    ///   - credentials: The `apikey` (required) and `usertoken` (when a client has one).
    ///   - bodyLoggingConfiguration: Request and response bodies carry client names,
    ///     phone numbers, birthdays and payment amounts, so nothing is logged unless
    ///     you opt in.
    init(
        serverURL: URL? = nil,
        credentials: Credentials,
        bodyLoggingConfiguration: BodyLoggingPolicy = .never
    ) throws {
        try self.init(
            serverURL: serverURL,
            credentials: credentials,
            middlewares: [OSLogLoggingMiddleware(bodyLoggingConfiguration: bodyLoggingConfiguration)]
        )
    }

    /// A client authenticated with the salon API key, with the caller composing the rest
    /// of the middleware chain.
    ///
    /// - Parameters:
    ///   - serverURL: Defaults to the single server declared by the specification.
    ///   - credentials: The `apikey` (required) and `usertoken` (when a client has one).
    ///   - middlewares: The chain after authentication — an `OSLogLoggingMiddleware` for
    ///     the unified log, a wire-capture sink, whatever the caller composes. Each entry
    ///     receives the *authorized* request, headers included; a sink must not persist
    ///     them.
    ///   - transport: Defaults to `URLSessionTransport()` — a `URLSession` with the
    ///     platform's 60-second request timeout.
    init(
        serverURL: URL? = nil,
        credentials: Credentials,
        middlewares: [any ClientMiddleware],
        transport: any ClientTransport = URLSessionTransport()
    ) throws {
        self = Client(
            serverURL: try serverURL ?? Servers.Server1.url(),
            transport: transport,
            middlewares: [
                AuthMiddleware(apiKey: credentials.apiKey, userToken: credentials.userToken)
            ] + middlewares
        )
    }
}
