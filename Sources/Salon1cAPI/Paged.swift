/// A list payload together with its pagination block.
///
/// Returned by `payload()` on the four paged operations: `Meta` on three of
/// them, `Pagination` on `getComments` — same schema, different wire key
/// (TD-5).
public struct Paged<Items: Sendable, Meta: Sendable>: Sendable {
    public let items: Items
    public let meta: Meta

    public init(items: Items, meta: Meta) {
        self.items = items
        self.meta = meta
    }
}

extension Paged: Equatable where Items: Equatable, Meta: Equatable {}
