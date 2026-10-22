import Foundation

/// The folded error channel of the `payload()` facade.
///
/// Rule 6 keeps three error channels distinct: the generated `Output` enum
/// carries documented non-2xx statuses **as data** (`.badRequest`,
/// `.unauthorized`, `.internalServerError`, `.undocumented`), transport and
/// decoding failures are thrown `ClientError`s, and `errors.code != 0` inside a
/// 2xx envelope is a domain refusal that also arrives as data. `payload()` —
/// opt-in, generated — folds the first and third of those channels into this
/// error, one case each, so a caller that wants the terse call site can still
/// tell a domain refusal (`.refused`) from a transport-level status
/// (`.status`, `.undocumentedStatus`).
public enum Salon1cError: Error, Equatable, Sendable {
    /// `errors.code != 0` inside a 2xx envelope — the server understood the
    /// request and refused it.
    case refused(code: Int, message: String?, operation: String)
    /// A documented non-2xx status (400/401/500 are declared on 60 of 62
    /// operations). `code`/`message` come from the typed body when it carries an
    /// `Errors` block; the 401 body is a bare string → `message` only.
    case status(Int, code: Int?, message: String?, operation: String)
    /// A status the document does not declare.
    case undocumentedStatus(Int, operation: String)
    /// A 2xx envelope with no error and no payload — a protocol violation,
    /// surfaced as an error, not an Optional.
    case missingPayload(operation: String)
}

extension Salon1cError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .refused(let code, let message, let operation):
            "\(operation): refused\(Self.detail(code: code, message: message))"
        case .status(let status, let code, let message, let operation):
            "\(operation): HTTP \(status)\(Self.detail(code: code, message: message))"
        case .undocumentedStatus(let status, let operation):
            "\(operation): undocumented HTTP status \(status)"
        case .missingPayload(let operation):
            "\(operation): 2xx envelope carried neither payload nor error"
        }
    }

    /// ` — code 1050 — Не найден объект`, or empty when neither part exists.
    private static func detail(code: Int?, message: String?) -> String {
        let parts = [code.map { "code \($0)" }, message].compactMap { $0 }
        return parts.isEmpty ? "" : " — \(parts.joined(separator: " — "))"
    }
}

extension Salon1cError {
    /// Server error code when either channel carried one (catalogue 1000–1114,
    /// TD-3).
    public var code: Int? {
        switch self {
        case .refused(let code, _, _): code
        case .status(_, let code, _, _): code
        case .undocumentedStatus, .missingPayload: nil
        }
    }

    /// The `operationId` whose `payload()` call threw.
    public var operation: String {
        switch self {
        case .refused(_, _, let operation),
             .status(_, _, _, let operation),
             .undocumentedStatus(_, let operation),
             .missingPayload(let operation):
            operation
        }
    }
}

// Used by the generated facade; internal.
extension Salon1cError {
    /// `.refused` when `code` is present and non-zero; nil/absent/0 is success
    /// (the vendor's examples send code 0, message "").
    static func check(_ errors: Components.Schemas.Errors?, operation: String) throws {
        guard let code = errors?.code, code != 0 else { return }
        throw Salon1cError.refused(code: Int(code), message: errors?.message, operation: operation)
    }

    init(status: Int, body: Components.Schemas.BadRequest, operation: String) {
        self = .status(
            status,
            code: body.errors?.code.map(Int.init),
            message: body.errors?.message,
            operation: operation
        )
    }

    init(status: Int, body: Components.Schemas.InternalServerError, operation: String) {
        self = .status(
            status,
            code: body.errors?.code.map(Int.init),
            message: body.errors?.message,
            operation: operation
        )
    }

    /// 401 `AuthorizationError` — a bare JSON string.
    init(status: Int, body: String, operation: String) {
        self = .status(status, code: nil, message: body, operation: operation)
    }
}
