import Testing

extension Tag {
    /// Talks to the real 1С API. Needs `SALON1C_API_KEY` + `SALON1C_SALON_ID`, and the
    /// host is geo-restricted — expect to need a VPN. Command-line escape hatch:
    /// `swift test --skip "Live API"`.
    @Tag static var live: Self

    /// Pins a claim `openapi.yaml` makes about the API. A failure means either the
    /// document is wrong or the service changed — see the `SpecOwnership` article.
    @Tag static var specContract: Self

    /// Changes server-side state — creates a client record, books a visit, pays.
    /// Needs `SALON1C_ALLOW_MUTATING_LIVE_TESTS=1` **on top of** the credentials, so
    /// that pointing an apikey at this suite is never enough on its own.
    @Tag static var mutating: Self

    /// Asks the API what it actually sends, rather than asserting what we believe. These
    /// tests *record* — attachments and warnings — and fail only when the client breaks.
    /// They are how `WorkingWithSalon1c` gets written once credentials exist.
    @Tag static var exploration: Self

    /// Pins a bug that shipped. Deleting one of these needs a reason.
    @Tag static var regression: Self

    /// Exercises `payload()` — the generated envelope-unwrapping facade — and
    /// `Salon1cError`. `Operations+Payload.generated.swift` is derived; these
    /// tests are its contract.
    @Tag static var facade: Self
}
