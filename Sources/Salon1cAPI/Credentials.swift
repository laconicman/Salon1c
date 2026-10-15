import Foundation

/// The two header credentials the API expects.
///
/// `apiKey` rides on every request; `userToken` rides only on client-scoped operations and
/// only once a client has authorized through the `auth` group — `nil` means "this client is
/// anonymous", which is a legitimate state, not an error.
public struct Credentials: Sendable {
    /// The salon API key, sent as the `apikey` header.
    public let apiKey: String
    /// The client user token, sent as the `usertoken` header when present.
    public let userToken: String?

    public init(apiKey: String, userToken: String? = nil) {
        self.apiKey = apiKey
        self.userToken = userToken
    }
}

public extension Credentials {
    /// Reads `SALON1C_API_KEY` (required) and `SALON1C_USER_TOKEN` (optional) from the
    /// environment. `nil` when the API key is unset **or blank**, so callers and tests can
    /// decide what that means. In Xcode, set them under Edit Scheme → Run → Environment.
    ///
    /// Blank counts as unset because the live suites gate on a resolved non-nil. With a
    /// plain `map`, `SALON1C_API_KEY=""` produced a credential, switched the suites on, and
    /// failed them all as 401s instead of skipping — an empty variable is how a CI runner
    /// says "no key", not "this key".
    ///
    /// Keep the environment out of version control; this is a debugging convenience, not a
    /// credential store.
    static var environment: Self? {
        let env = ProcessInfo.processInfo.environment
        func nonempty(_ key: String) -> String? {
            env[key]
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .flatMap { $0.isEmpty ? nil : $0 }
        }
        guard let apiKey = nonempty("SALON1C_API_KEY") else { return nil }
        return Self(apiKey: apiKey, userToken: nonempty("SALON1C_USER_TOKEN"))
    }
}
