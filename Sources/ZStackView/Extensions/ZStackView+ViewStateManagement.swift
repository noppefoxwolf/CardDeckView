import SwiftUI

// MARK: - View State Management
extension ZStackView {
    
    /// Computed property returning indices of views in the upper area
    var upperAreaViewIndices: [Int] {
        viewStates.enumerated().compactMap { index, state in
            state.isInUpperArea ? index : nil
        }
    }
    
    /// Computed property returning indices of views in the lower area
    var lowerAreaViewIndices: [Int] {
        viewStates.enumerated().compactMap { index, state in
            !state.isInUpperArea ? index : nil
        }
    }
    
    /// Initializes view states for all subviews
    func initializeViewStates(count: Int) {
        if viewStates.count != count {
            viewStates = (0..<count).map { index in
                ViewState(zIndex: Double(count - 1 - index))
            }
        }
    }
    
    /// Gets the z-index for a view at the given index
    func getZIndex(for index: Int) -> Double {
        viewStates.indices.contains(index) ? viewStates[index].zIndex : Double(index)
    }
    
    /// Checks if a view is in the upper area
    func isInUpperArea(index: Int) -> Bool {
        viewStates.indices.contains(index) && viewStates[index].isInUpperArea
    }
}
