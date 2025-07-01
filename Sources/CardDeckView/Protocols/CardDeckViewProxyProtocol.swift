import SwiftUI

@MainActor
protocol CardDeckViewProxyProtocol: Sendable {
    associatedtype TagType: Hashable
    var tagType: TagType.Type { get }
    func setFrontmostLowerAreaTagHandler(_ handler: @escaping (TagType?) -> Void)
    func updateFrontmostLowerAreaTag(_ tag: TagType?)
    func extractTag(from subviews: SubviewsCollection, at index: Int?) -> TagType?
    func findViewIndex(with targetTag: TagType, in subviews: SubviewsCollection) -> Int?
}
