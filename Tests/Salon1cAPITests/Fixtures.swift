import Foundation
import HTTPTypes
import OpenAPIRuntime
@testable import Salon1cAPI

// MARK: - Transports

/// Returns a canned response without a network. Enough for every decoding test.
struct StubTransport: ClientTransport {
    let status: HTTPResponse.Status
    let json: String

    init(status: HTTPResponse.Status = .ok, json: String) {
        self.status = status
        self.json = json
    }

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var response = HTTPResponse(status: status)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody(json))
    }
}

/// Captures what the middleware stack produced, then answers like `StubTransport`.
///
/// An `actor`, not a `nonisolated(unsafe) var`: the target is in Swift 6 language mode.
actor RequestRecorder {
    private(set) var request: HTTPRequest?
    private(set) var requestBody: String?

    func record(_ request: HTTPRequest, body: String?) {
        self.request = request
        self.requestBody = body
    }
}

struct RecordingTransport: ClientTransport {
    let recorder: RequestRecorder
    var status: HTTPResponse.Status = .ok
    var json: String = #"{"parameters":{},"errors":{"code":0,"message":""}}"#

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var text: String?
        if let body {
            text = try await String(collecting: body, upTo: .max)
        }
        await recorder.record(request, body: text)
        var response = HTTPResponse(status: status)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody(json))
    }
}

/// Fails the way a real network failure does, so the error that reaches the caller is a
/// `ClientError` carrying whatever context the runtime chose to attach.
struct FailingTransport: ClientTransport {
    struct Failure: Error {}

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        throw Failure()
    }
}

// MARK: - Clients under test

extension Client {
    /// A client wired to `StubTransport` through the **production** configuration, so a
    /// decoding test exercises the same converter setup a real call would.
    static func stubbed(status: HTTPResponse.Status = .ok, json: String) throws -> Client {
        Client(
            serverURL: try Servers.Server1.url(),
            transport: StubTransport(status: status, json: json)
        )
    }

    /// A client whose only middleware is `AuthMiddleware`, so the middleware suite sees
    /// exactly what it did and nothing else.
    static func recording(
        recorder: RequestRecorder,
        apiKey: String = "test-apikey",
        userToken: String? = nil,
        json: String = #"{"parameters":{},"errors":{"code":0,"message":""}}"#
    ) throws -> Client {
        Client(
            serverURL: try Servers.Server1.url(),
            transport: RecordingTransport(recorder: recorder, json: json),
            middlewares: [AuthMiddleware(apiKey: apiKey, userToken: userToken)]
        )
    }
}

// MARK: - Response fixtures
//
// Provenance, per fixture, decides what a failure means:
//
// - Every fixture below is **derived from `Upstream/salon1c/salon1c.apib`** — the vendor's
//   API Blueprint — copied verbatim including its inconsistencies, and each names the
//   section it came from. These prove the client decodes what the document *claims*;
//   only a live call proves the claim (TD-2). Replace each one with a wire capture as
//   evidence arrives, and say so here.
