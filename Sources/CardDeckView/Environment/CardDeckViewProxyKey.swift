import SwiftUI

private struct CardDeckViewProxyKey: EnvironmentKey {
    static let defaultValue: (any CardDeckViewProxyProtocol)? = nil
}

extension EnvironmentValues {
    var cardDeckViewProxy: (any CardDeckViewProxyProtocol)? {
        get { self[CardDeckViewProxyKey.self] }
        set { self[CardDeckViewProxyKey.self] = newValue }
    }
}
