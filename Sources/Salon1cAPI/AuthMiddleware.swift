import OpenAPIRuntime
import Foundation
import HTTPTypes

/// A client middleware that injects the API's two credential headers.
///
/// `apikey` is sent on every request; `usertoken` only when the credentials carry one —
/// it is issued by the `auth` operations and an anonymous client legitimately has none.
/// The header names are literal lowercase on the wire; `HTTPField.Name` normalizes case,
/// so the spelling here is documentation, not behaviour.
package struct AuthMiddleware { // This might want to be `public` someday.
    private let apiKey: String
    private let userToken: String?

    /// Creates a new middleware.
    /// - Parameters:
    ///   - apiKey: The value for the `apikey` header field.
    ///   - userToken: The value for the `usertoken` header field, when the client has one.
    package init(apiKey: String, userToken: String? = nil) {
        self.apiKey = apiKey
        self.userToken = userToken
    }
}

extension HTTPField.Name {
    /// The salon API key header — literal `apikey` on the wire.
    static let salonAPIKey = HTTPField.Name("apikey")!
    /// The client user-token header — literal `usertoken` on the wire.
    static let salonUserToken = HTTPField.Name("usertoken")!
}

extension AuthMiddleware: ClientMiddleware {
    package func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        // Sets the credential fields, and nothing else. `Content-Type` in particular
        // is the generator's to set, per operation, from the document.
        request.headerFields[.salonAPIKey] = apiKey
        request.headerFields[.salonUserToken] = userToken
        return try await next(request, body, baseURL)
    }
}
