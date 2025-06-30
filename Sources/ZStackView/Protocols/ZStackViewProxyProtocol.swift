import SwiftUI

@MainActor
protocol ZStackViewProxyProtocol: Sendable {
    var tagType: Any.Type { get }
    func setFrontmostLowerAreaTagHandler<T: Hashable>(_ handler: @escaping (T?) -> Void)
    func updateFrontmostLowerAreaTag<T: Hashable>(_ tag: T?)
    func extractTag<T: Hashable>(from subviews: SubviewsCollection, at index: Int?, as type: T.Type) -> T?
    func findViewIndex<T: Hashable>(with targetTag: T, in subviews: SubviewsCollection) -> Int?
}
