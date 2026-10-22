import Foundation

// Generates `Operations+Payload.generated.swift` — one `payload()` extension per
// operation whose success body is a JSON envelope — by scanning the OpenAPI
// generator's `Types+Operations.swift`. Machine-formatted input; a brace-depth
// line scanner is enough. Usage:
//   swift Scripts/generate-facade.swift <Types+Operations.swift> > out.swift

func fatal(_ message: String) -> Never {
    FileHandle.standardError.write(Data("generate-facade: \(message)\n".utf8))
    exit(1)
}

guard CommandLine.arguments.count == 2 else {
    fatal("usage: generate-facade.swift <Types+Operations.swift>")
}
let sourcePath = CommandLine.arguments[1]
guard let source = try? String(contentsOfFile: sourcePath, encoding: .utf8) else {
    fatal("cannot read \(sourcePath)")
}

// MARK: - Brace-depth tree of `public enum`/`public struct` nodes

final class Node {
    let kind: Kind
    let name: String
    var children: [Node] = []
    /// Direct `public var <name>: <Type>` members (name, full type text, trailing-`?` flag).
    var vars: [(name: String, type: String, optional: Bool)] = []
    /// Direct `case <name>` members; payload = associated-value type when the
    /// case carries one (`case json(T)`).
    var cases: [(name: String, payload: String?)] = []
    /// Direct `public typealias <name> = <Type>` members.
    var typealiases: [String: String] = [:]
    /// Value of `public static let id: Swift.String = "…"`, when present.
    var operationID: String? = nil

    enum Kind { case `enum`, `struct` }

    /// Brace depth at which this node's body lives; popped when a `}` brings the
    /// scan below it.
    var bodyDepth = 0

    init(kind: Kind, name: String) {
        self.kind = kind
        self.name = name
    }

    func child(_ name: String) -> Node? { children.first { $0.name == name } }
    func `var`(_ name: String) -> (name: String, type: String, optional: Bool)? {
        vars.first { $0.name == name }
    }
}

let declPattern = try! NSRegularExpression(pattern: #"^(?:@frozen )?public (enum|struct) (\w+)[^\{]*\{"#)
let varPattern = try! NSRegularExpression(pattern: #"^public var (\w+): (.+)$"#)
let casePattern = try! NSRegularExpression(pattern: #"^case (\w+)\((.+)\)$|^case (\w+)$"#)
let aliasPattern = try! NSRegularExpression(pattern: #"^public typealias (\w+) = (.+)$"#)
let idPattern = try! NSRegularExpression(pattern: #"^public static let id: Swift\.String = "(\w+)"$"#)

let root = Node(kind: .enum, name: "<root>")
var stack: [Node] = [root]
var depth = 0

for rawLine in source.components(separatedBy: "\n") {
    let line = rawLine.trimmingCharacters(in: .whitespaces)
    if line.isEmpty || line.hasPrefix("///") || line.hasPrefix("//") { continue }
    let range = NSRange(line.startIndex..., in: line)
    func captures(_ pattern: NSRegularExpression) -> [String]? {
        guard let m = pattern.firstMatch(in: line, range: range) else { return nil }
        return (1..<m.numberOfRanges).map {
            m.range(at: $0).location == NSNotFound ? "" : String(line[Range(m.range(at: $0), in: line)!])
        }
    }
    if let c = captures(declPattern) {
        let node = Node(kind: c[0] == "enum" ? .enum : .struct, name: c[1])
        node.bodyDepth = depth + 1
        stack.last!.children.append(node)
        stack.append(node)
    } else if let c = captures(varPattern) {
        stack.last!.vars.append((c[0], c[1], c[1].hasSuffix("?")))
    } else if let c = captures(aliasPattern) {
        stack.last!.typealiases[c[0]] = c[1]
    } else if let c = captures(idPattern) {
        stack.last!.operationID = c[0]
    } else if let c = captures(casePattern) {
        let name = c[0].isEmpty ? c[2] : c[0]
        let payload = c[0].isEmpty ? nil : c[1]
        stack.last!.cases.append((name, payload))
    }
    // Raw brace count is safe: `{`/`}` appear only in `///` comments (skipped)
    // and in code structure.
    depth += line.filter { $0 == "{" }.count - line.filter { $0 == "}" }.count
    while stack.count > 1, stack.last!.bodyDepth > depth { stack.removeLast() }
}

guard let operations = root.child("Operations"), operations.kind == .enum else {
    fatal("no `public enum Operations` found in \(sourcePath)")
}

// MARK: - Per-operation analysis

let successCases = ["ok": ("Ok", "200"), "created": ("Created", "201")]
let errorCases = [
    "badRequest": ("BadRequest", 400),
    "unauthorized": ("Unauthorized", 401),
    "internalServerError": ("InternalServerError", 500),
]
let allowedCases = Set(successCases.keys).union(errorCases.keys).union(["undocumented"])

var skipped: [(op: String, reason: String)] = []
var blocks: [String] = []

for op in operations.children where op.kind == .enum {
    let opName = op.name
    guard let opID = op.operationID else {
        fatal("\(opName): no `static let id`")
    }

    guard let output = op.child("Output"), output.kind == .enum else {
        fatal("\(opName): no Output enum")
    }
    for outputCase in output.cases where !allowedCases.contains(outputCase.name) {
        fatal("\(opName): unexpected Output case `\(outputCase.name)`")
    }
    let successes = output.cases.filter { successCases[$0.name] != nil }
    guard successes.count == 1, let (successStruct, successStatus) = successes.first.flatMap({ successCases[$0.name] }) else {
        fatal("\(opName): expected exactly one success case (ok/created), found \(successes.map(\.name))")
    }

    guard let okStruct = output.child(successStruct),
          let body = okStruct.child("Body"), body.kind == .enum else {
        fatal("\(opName): no \(successStruct).Body")
    }
    guard let jsonCase = body.cases.first(where: { $0.name == "json" }), let jsonType = jsonCase.payload else {
        skipped.append((opID, "no JSON body"))
        continue
    }
    let expectedPayloadType = "Operations.\(opName).Output.\(successStruct).Body.JsonPayload"
    guard jsonType == expectedPayloadType else {
        fatal("\(opName): json body type `\(jsonType)` is not the nested JsonPayload")
    }
    guard let envelope = body.child("JsonPayload") else {
        fatal("\(opName): no JsonPayload type")
    }
    guard envelope.kind == .struct else {
        skipped.append((opID, "oneOf envelope"))
        continue
    }

    let allowedKeys: Set<String> = ["parameters", "result", "errors", "error", "meta", "pagination"]
    for v in envelope.vars where !allowedKeys.contains(v.name) {
        fatal("\(opName): unknown envelope key `\(v.name)`")
    }
    guard let payloadVar = envelope.var("parameters") ?? envelope.var("result") else {
        fatal("\(opName): envelope has neither `parameters` nor `result`")
    }
    let errorVar = envelope.var("errors") ?? envelope.var("error")
    let metaVar = envelope.var("meta") ?? envelope.var("pagination")

    // Nested errors dialect (GetPriceList): `errors` inside `ParametersPayload`.
    var nestedCheck: String? = nil
    if let nested = envelope.child("ParametersPayload"), nested.kind == .struct,
       let nestedErrors = nested.var("errors"), nestedErrors.type.contains("Components.Schemas.Errors") {
        nestedCheck = "try Salon1cError.check(body.parameters\(payloadVar.optional ? "?" : "").errors, operation: Operations.\(opName).id)"
    }

    var returnType = payloadVar.type
    if returnType.hasSuffix("?") { returnType.removeLast() }
    var returnExpr = "body.\(payloadVar.name)"
    if let metaVar {
        returnType = "Paged<\(returnType), \(metaVar.type)>"
        returnExpr = "Paged(items: \(returnExpr), meta: body.\(metaVar.name))"
    }

    var lines: [String] = []
    lines.append("extension Operations.\(opName).Output {")
    lines.append("    /// `\(payloadVar.name)` of a \(successStatus) response.")
    lines.append("    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,")
    lines.append("    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.")
    lines.append("    public func payload() throws -> \(returnType) {")
    lines.append("        switch self {")
    for outputCase in output.cases {
        switch outputCase.name {
        case let name where successCases[name] != nil:
            lines.append("        case .\(name)(let response):")
            lines.append("            let body = try response.body.json")
            if let errorVar {
                lines.append("            try Salon1cError.check(body.\(errorVar.name), operation: Operations.\(opName).id)")
            }
            if let nestedCheck {
                lines.append("            \(nestedCheck)")
            }
            if payloadVar.optional {
                lines.append("            guard let payload = body.\(payloadVar.name) else {")
                lines.append("                throw Salon1cError.missingPayload(operation: Operations.\(opName).id)")
                lines.append("            }")
                if metaVar != nil {
                    lines.append("            return Paged(items: payload, meta: body.\(metaVar!.name))")
                } else {
                    lines.append("            return payload")
                }
            } else {
                lines.append("            return \(returnExpr)")
            }
        case let name where errorCases[name] != nil:
            let status = errorCases[name]!.1
            lines.append("        case .\(name)(let response):")
            lines.append("            throw Salon1cError(status: \(status), body: try response.body.json, operation: Operations.\(opName).id)")
        case "undocumented":
            lines.append("        case .undocumented(let statusCode, _):")
            lines.append("            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.\(opName).id)")
        default:
            break // unreachable — validated above
        }
    }
    lines.append("        }")
    lines.append("    }")
    lines.append("}")
    blocks.append(lines.joined(separator: "\n"))
}

// MARK: - Emit

var out: [String] = []
out.append("// GENERATED FILE — do not edit.")
out.append("// Regenerate: Scripts/generate-facade.sh")
out.append("// Source: the generated Types+Operations.swift of the current openapi.yaml.")
out.append("//")
out.append("// Operations without a `payload()` — skipped:")
for s in skipped {
    out.append("//   - \(s.op): \(s.reason)")
}
print(out.joined(separator: "\n"))
print("")
print(blocks.joined(separator: "\n\n"))
