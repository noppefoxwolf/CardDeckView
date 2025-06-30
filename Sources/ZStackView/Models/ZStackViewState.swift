import SwiftUI
import Combine

/// Observable state manager for ZStackView that handles view states and drag interactions
@Observable
final class ZStackViewState {
    
    // MARK: - Properties
    
    private(set) var viewStates: [ViewState] = []
    private(set) var draggedViewIndex: Int? = nil
    
    // MARK: - Computed Properties
    
    /// Indices of views currently in the upper area
    var upperAreaViewIndices: [Int] {
        viewStates.enumerated().compactMap { index, state in
            state.isInUpperArea ? index : nil
        }
    }
    
    /// Indices of views currently in the lower area
    var lowerAreaViewIndices: [Int] {
        viewStates.enumerated().compactMap { index, state in
            !state.isInUpperArea ? index : nil
        }
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - View State Management
    
    /// Initializes view states for the given number of views
    func initializeViewStates(count: Int) {
        if viewStates.count != count {
            viewStates = (0..<count).map { index in
                ViewState(zIndex: Double(count - 1 - index))
            }
        }
    }
    
    /// Gets the z-index for a view at the given index
    func getZIndex(for index: Int) -> Double {
        guard viewStates.indices.contains(index) else { return Double(index) }
        return viewStates[index].zIndex
    }
    
    /// Checks if a view is in the upper area
    func isInUpperArea(index: Int) -> Bool {
        guard viewStates.indices.contains(index) else { return false }
        return viewStates[index].isInUpperArea
    }
    
    /// Gets the drag offset for a view at the given index
    func getDragOffset(for index: Int) -> CGSize {
        guard viewStates.indices.contains(index) else { return .zero }
        return viewStates[index].dragOffset
    }
    
    /// Checks if a view is currently being dragged
    func isDragging(index: Int) -> Bool {
        guard viewStates.indices.contains(index) else { return false }
        return viewStates[index].isDragging
    }
    
    // MARK: - Drag Management
    
    /// Starts dragging a view at the specified index
    func startDragging(viewIndex: Int) {
        guard viewStates.indices.contains(viewIndex) else { return }
        draggedViewIndex = viewIndex
        viewStates[viewIndex].isDragging = true
    }
    
    /// Updates the drag offset for the currently dragged view
    func updateDragOffset(_ offset: CGSize) {
        guard let index = draggedViewIndex,
              viewStates.indices.contains(index) else { return }
        viewStates[index].dragOffset = offset
    }
    
    /// Ends dragging and optionally moves the view to a different area
    func endDragging(shouldChangeArea: Bool = false) {
        guard let index = draggedViewIndex,
              viewStates.indices.contains(index) else { return }
        
        if shouldChangeArea {
            viewStates[index].isInUpperArea.toggle()
        }
        
        viewStates[index].dragOffset = .zero
        viewStates[index].isDragging = false
        draggedViewIndex = nil
    }
    
    /// Finds the nearest view index to start dragging from a given location
    func findNearestViewIndex(to location: CGPoint, in viewIndices: [Int]) -> Int? {
        guard !viewIndices.isEmpty else { return nil }
        
        let isUpperAreaViews = viewIndices.allSatisfy { viewStates[$0].isInUpperArea }
        
        return isUpperAreaViews ?
            viewIndices.max() :
            viewIndices.min()
    }
    
    
    /// Calculates if a view should change areas based on position and velocity
    func shouldChangeArea(
        index: Int,
        currentY: CGFloat,
        velocity: CGFloat,
        velocityThreshold: CGFloat = 50
    ) -> Bool {
        guard viewStates.indices.contains(index) else { return false }
        
        let isUpperArea = viewStates[index].isInUpperArea
        
        return isUpperArea ?
            (currentY > 0 || velocity > velocityThreshold) :
            (currentY < 0 || velocity < -velocityThreshold)
    }
    
    // MARK: - Tag Management Support
    
    /// Moves a view from upper area to lower area
    func moveViewFromUpperToLowerArea(index: Int) {
        guard viewStates.indices.contains(index) else { return }
        viewStates[index].isInUpperArea = false
    }
    
    /// Sets the area state for a specific view
    func setViewArea(index: Int, isInUpperArea: Bool) {
        guard viewStates.indices.contains(index) else { return }
        viewStates[index].isInUpperArea = isInUpperArea
    }
}