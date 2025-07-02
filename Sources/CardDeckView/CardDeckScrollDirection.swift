import Foundation

/// Defines the scroll direction for disabling gestures in CardDeckView
public struct CardDeckScrollDirection: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Upward swipe gesture (swiping up)
    public static let up = CardDeckScrollDirection(rawValue: 1 << 0)
    
    /// Downward swipe gesture (swiping down)
    public static let down = CardDeckScrollDirection(rawValue: 1 << 1)
    
    /// Vertical scrolling (both up and down)
    public static let vertical: CardDeckScrollDirection = [.up, .down]
    
    /// All gesture directions (same as vertical for this implementation)
    public static let all: CardDeckScrollDirection = [.up, .down]
}