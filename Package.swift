// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Salon1cAPI",
    // iOS 17 / macOS 14: `Observation` is unconditional for SwiftUI consumers, and every
    // `@available` guard the package used to carry disappears. Same floor as the sibling
    // YandexDeliveryExpressAPI; see the DocC `Design` article.
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v10), .visionOS(.v1)],
    products: [.library(name: "Salon1cAPI", targets: ["Salon1cAPI"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.13.0"),
        // 1.13.0 is the floor, not a coincidence: `Converter.setQueryItemAsJSON` — which the
        // generator emits for `in: query` + `content: application/json` parameters, and this
        // API uses for its JSON-in-query-string parameters — landed in runtime 1.13.0
        // (apple/swift-openapi-generator#853, fixed by #956). 1.12.x would compile the
        // generated client into missing-member errors.
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.13.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.1"),
        .package(url: "https://github.com/laconicman/OSLogLoggingMiddleware", from: "1.0.0"),
        // Renders the DocC catalog, including the direction articles. Deliberately **not**
        // listed in any target's `plugins:` — it is a *command* plugin, invoked as
        // `swift package generate-documentation`. Attaching it to the library target would be
        // wrong, so do not "fix" the unused-dependency warning that way.
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "Salon1cAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "OSLogLoggingMiddleware", package: "OSLogLoggingMiddleware")
            ],
            // `.defaultIsolation(nil)` spells the policy explicitly: nonisolated
            // module default. `.defaultIsolation(MainActor.self)` (the app dialect)
            // would actor-isolate the *generated* client's conformances and
            // @Sendable closures into uncompilability — upstream
            // apple/swift-openapi-generator#796/#823, whose sanctioned workaround
            // is exactly this setting. `YandexDeliveryExpressAPI` carries the same
            // default; `Design` → Concurrency records the reasoning.
            swiftSettings: [.defaultIsolation(nil)],
            // The generator is a *plugin*, never a `dependencies:` entry. It finds
            // `openapi.yaml` and `openapi-generator-config.yaml` by scanning the target's
            // files, so those two must stay in the target's sources — not excluded, and not
            // declared as resources (which would copy the YAML into every consuming app).
            // SwiftPM may report them as unhandled; that is expected.
            plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
        ),
        .testTarget(
            name: "Salon1cAPITests",
            dependencies: ["Salon1cAPI"]
        )
    ]
)
