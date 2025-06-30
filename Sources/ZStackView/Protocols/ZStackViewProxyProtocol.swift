import SwiftUI

@MainActor
protocol ZStackViewProxyProtocol: Sendable {
    func setFrontmostLowerAreaTagHandler(_ handler: @escaping (AnyHashable?) -> Void)
    func updateFrontmostLowerAreaTag(_ tag: AnyHashable?)
}
