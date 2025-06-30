import SwiftUI

private struct ZStackViewProxyKey: EnvironmentKey {
  static let defaultValue: (any ZStackViewProxyProtocol)? = nil
}

extension EnvironmentValues {
  var zStackViewProxy: (any ZStackViewProxyProtocol)? {
    get { self[ZStackViewProxyKey.self] }
    set { self[ZStackViewProxyKey.self] = newValue }
  }
}
