import SwiftUI

extension ContainerValues {
    /// Extracts any hashable tag from the container values
    var anyHashableTag: AnyHashable? {
        // Check for common tag types
        if let stringTag = tag(for: String.self) {
            return AnyHashable(stringTag)
        }
        if let intTag = tag(for: Int.self) {
            return AnyHashable(intTag)
        }
        if let uuidTag = tag(for: UUID.self) {
            return AnyHashable(uuidTag)
        }
        
        // Add more common types as needed
        return nil
    }
}
