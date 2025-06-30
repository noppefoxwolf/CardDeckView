import SwiftUI

// MARK: - View State Management
extension ZStackView {
    
    /// Computed property returning indices of views in the upper area
    var upperAreaViewIndices: [Int] {
        state.upperAreaViewIndices
    }
    
    /// Computed property returning indices of views in the lower area
    var lowerAreaViewIndices: [Int] {
        state.lowerAreaViewIndices
    }
    
    /// Initializes view states for all subviews
    func initializeViewStates(count: Int) {
        state.initializeViewStates(count: count)
    }
    
    /// Gets the z-index for a view at the given index
    func getZIndex(for index: Int) -> Double {
        state.getZIndex(for: index)
    }
    
    /// Checks if a view is in the upper area
    func isInUpperArea(index: Int) -> Bool {
        state.isInUpperArea(index: index)
    }
}
