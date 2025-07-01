import SwiftUI

/// Represents the state of a view in the ZStackView
struct ViewState: Sendable, Equatable {
    var isInUpperArea: Bool = false
    var dragOffset: CGSize = .zero
    var isDragging: Bool = false
    var zIndex: Double
}
