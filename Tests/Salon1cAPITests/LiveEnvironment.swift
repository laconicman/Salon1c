import Foundation
@testable import Salon1cAPI

/// Shared environment resolution for the network-touching suites.
///
/// Variables resolve in two places, process environment first:
/// 1. `ProcessInfo.processInfo.environment` — CI, `env VAR=… swift test`, Xcode scheme.
/// 2. A git-ignored `.env` file at the package root — for running the suites inside a
///    network where the host is reachable without exporting anything. The file is
///    `.gitignore`d; `.env.example` (committed) lists the supported names.
///
/// Nothing here is a credential store — `.env` exists so a lab-bound machine can run
/// the suites at all.
enum LiveEnvironment {
    private static let fileURL: URL = {
        // This file lives at <package>/Tests/Salon1cAPITests/ — the package root is
        // two directories up, which is where `.env` is expected regardless of the
        // working directory the test runner was launched from.
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(".env")
    }()

    private static let fileVariables: [String: String] = {
        guard let text = try? String(contentsOf: fileURL, encoding: .utf8) else { return [:] }
        var values: [String: String] = [:]
        for line in text.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#"),
                  let eq = trimmed.firstIndex(of: "=") else { continue }
            let key = trimmed[..<eq].trimmingCharacters(in: .whitespaces)
            let value = trimmed[trimmed.index(after: eq)...]
                .trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            if !key.isEmpty { values[key] = value }
        }
        return values
    }()

    /// A non-blank value for `key`, or `nil`. Blank counts as unset — an empty variable
    /// is how a CI runner says "no key", and every suite gates on non-nil.
    static func variable(_ key: String) -> String? {
        let raw = ProcessInfo.processInfo.environment[key] ?? fileVariables[key]
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.flatMap { $0.isEmpty ? nil : $0 }
    }

    /// `nil` unless `SALON1C_API_KEY` + `SALON1C_SALON_ID` resolve — the gate the real
    /// live suites share.
    static var salon: (credentials: Credentials, salonId: String)? {
        guard let apiKey = variable("SALON1C_API_KEY"),
              let salonId = variable("SALON1C_SALON_ID") else { return nil }
        return (
            Credentials(apiKey: apiKey, userToken: variable("SALON1C_USER_TOKEN")),
            salonId
        )
    }

    /// `SALON1C_BASE_URL` — a test lab or on-premises deployment the live suite should
    /// hit instead of the documented cloud host. `nil` means the spec's server.
    static var serverURL: URL? {
        variable("SALON1C_BASE_URL").flatMap(URL.init(string:))
    }

    /// Second switch for anything that writes server state.
    static var mutatingAllowed: Bool {
        variable("SALON1C_ALLOW_MUTATING_LIVE_TESTS") == "1"
    }

    /// `SALON1C_MOCK_TESTS=1` arms the Apiary-mock suite — it needs no credentials,
    /// only network. Off by default so `swift test` stays hermetic.
    static var mockEnabled: Bool {
        variable("SALON1C_MOCK_TESTS") == "1"
    }

    /// The Apiary mock of the vendor's own Blueprint — serves the documented example
    /// bodies for every operation. `SALON1C_MOCK_URL` overrides it (a private Apiary
    /// project's mock changes the host; the `/api` prefix must stay).
    static var mockBaseURL: URL {
        URL(
            string: variable("SALON1C_MOCK_URL")
                ?? "http://private-anon-5309c9fb20-salon1c.apiary-mock.com/api"
        )!
    }

    /// A client pointed at the mock — any credentials work, the mock validates nothing.
    static func mockClient() throws -> Client {
        try Client(
            serverURL: mockBaseURL,
            credentials: .init(apiKey: "mock", userToken: "mock")
        )
    }
}
