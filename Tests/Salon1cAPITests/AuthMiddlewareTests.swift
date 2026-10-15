import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import Salon1cAPI

/// `AuthMiddleware` is exercised directly — no operation needed — because the two header
/// names are its whole contract. The authorized request only ever reaches `next`, so the
/// assertions live inside it.
@Suite("Auth middleware")
struct AuthMiddlewareTests {
    private let baseURL = URL(string: "http://cloud.salon1c.ru/api")!
    private let request = HTTPRequest(
        method: .get,
        scheme: "http",
        authority: "cloud.salon1c.ru",
        path: "/hs/api/v1/salons/test-salon/"
    )

    @Test("apikey is set on every request")
    func apiKeyAlwaysSet() async throws {
        let middleware = AuthMiddleware(apiKey: "API-KEY")
        _ = try await middleware.intercept(
            request, body: nil, baseURL: baseURL, operationID: "test"
        ) { request, _, _ in
            #expect(request.headerFields[.salonAPIKey] == "API-KEY")
            return (HTTPResponse(status: .ok), nil)
        }
    }

    @Test("usertoken is set only when credentials carry one")
    func userTokenSetWhenPresent() async throws {
        let middleware = AuthMiddleware(apiKey: "API-KEY", userToken: "USER-TOKEN")
        _ = try await middleware.intercept(
            request, body: nil, baseURL: baseURL, operationID: "test"
        ) { request, _, _ in
            #expect(request.headerFields[.salonUserToken] == "USER-TOKEN")
            return (HTTPResponse(status: .ok), nil)
        }
    }

    @Test("usertoken is absent for an anonymous client")
    func userTokenAbsentWhenNil() async throws {
        let middleware = AuthMiddleware(apiKey: "API-KEY")
        _ = try await middleware.intercept(
            request, body: nil, baseURL: baseURL, operationID: "test"
        ) { request, _, _ in
            #expect(request.headerFields[.salonUserToken] == nil)
            return (HTTPResponse(status: .ok), nil)
        }
    }

    @Test("a downstream failure propagates unchanged")
    func downstreamErrorPropagates() async throws {
        struct Downstream: Error {}
        let middleware = AuthMiddleware(apiKey: "API-KEY", userToken: "USER-TOKEN")
        await #expect(throws: Downstream.self) {
            _ = try await middleware.intercept(
                request, body: nil, baseURL: baseURL, operationID: "test"
            ) { _, _, _ in
                throw Downstream()
            }
        }
    }
}
