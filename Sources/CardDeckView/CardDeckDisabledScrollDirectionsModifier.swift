import SwiftUI

// MARK: - Environment Key

extension EnvironmentValues {
    @Entry var cardDeckDisabledScrollDirections: CardDeckScrollDirection = []
}

// MARK: - View Modifier

struct CardDeckDisabledScrollDirectionsModifier: ViewModifier {
    let disabledDirections: CardDeckScrollDirection
    
    func body(content: Content) -> some View {
        content
            .environment(\.cardDeckDisabledScrollDirections, disabledDirections)
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the disabled scroll directions for CardDeckView gestures
    /// - Parameter directions: The scroll directions to disable
    /// - Returns: A view with the disabled scroll directions set
    func cardDeckDisabledScrollDirections(_ directions: CardDeckScrollDirection) -> some View {
        modifier(CardDeckDisabledScrollDirectionsModifier(disabledDirections: directions))
    }
}