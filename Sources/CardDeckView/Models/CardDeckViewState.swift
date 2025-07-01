import Combine
import SwiftUI

/// Observable state manager for CardDeckView that handles card states and drag interactions
@Observable
final class CardDeckViewState {

    // MARK: - Properties

    private(set) var viewStates: [ViewState] = []
    private(set) var draggedViewIndex: Int? = nil

    // MARK: - Computed Properties

    private var _cachedUpperAreaIndices: [Int] = []
    private var _cachedLowerAreaIndices: [Int] = []
    private var _cacheIsValid: Bool = false
    
    /// Indices of views currently in the upper area
    var upperAreaViewIndices: [Int] {
        if !_cacheIsValid {
            updateAreaIndicesCache()
        }
        return _cachedUpperAreaIndices
    }

    /// Indices of views currently in the lower area
    var lowerAreaViewIndices: [Int] {
        if !_cacheIsValid {
            updateAreaIndicesCache()
        }
        return _cachedLowerAreaIndices
    }
    
    private func updateAreaIndicesCache() {
        _cachedUpperAreaIndices.removeAll(keepingCapacity: true)
        _cachedLowerAreaIndices.removeAll(keepingCapacity: true)
        
        for (index, state) in viewStates.enumerated() {
            if state.isInUpperArea {
                _cachedUpperAreaIndices.append(index)
            } else {
                _cachedLowerAreaIndices.append(index)
            }
        }
        _cacheIsValid = true
    }
    
    private func invalidateCache() {
        _cacheIsValid = false
    }

    // MARK: - Initialization

    init() {}

    // MARK: - View State Management

    /// Initializes view states for the given number of views
    func initializeViewStates(count: Int) {
        if viewStates.count != count {
            viewStates.reserveCapacity(count)
            viewStates = (0..<count)
                .map { index in
                    ViewState(zIndex: Double(count - 1 - index))
                }
            invalidateCache()
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
            viewStates.indices.contains(index)
        else { return }
        
        let constrainedOffset: CGSize
        if viewStates[index].isInUpperArea {
            // Upper area views: constrain y-movement to 0 or greater (prevent upward movement beyond top)
            constrainedOffset = CGSize(
                width: offset.width,
                height: max(0, offset.height)
            )
        } else {
            // Lower area views can move freely
            constrainedOffset = offset
        }
        
        viewStates[index].dragOffset = constrainedOffset
    }

    /// Ends dragging and optionally moves the view to a different area
    func endDragging(shouldChangeArea: Bool = false) {
        guard let index = draggedViewIndex,
            viewStates.indices.contains(index)
        else { return }

        if shouldChangeArea {
            viewStates[index].isInUpperArea.toggle()
            invalidateCache()
        }

        viewStates[index].dragOffset = .zero
        viewStates[index].isDragging = false
        draggedViewIndex = nil
    }

    /// Finds the nearest view index to start dragging from a given location
    func findNearestViewIndex(to location: CGPoint, in viewIndices: [Int]) -> Int? {
        guard !viewIndices.isEmpty else { return nil }

        let isUpperAreaViews = viewIndices.allSatisfy { viewStates[$0].isInUpperArea }

        return isUpperAreaViews ? viewIndices.max() : viewIndices.min()
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

        return isUpperArea
            ? (currentY > 0 || velocity > velocityThreshold)
            : (currentY < 0 || velocity < -velocityThreshold)
    }

    // MARK: - Tag Management Support

    /// Moves a view from upper area to lower area
    func moveViewFromUpperToLowerArea(index: Int) {
        guard viewStates.indices.contains(index) else { return }
        if viewStates[index].isInUpperArea {
            viewStates[index].isInUpperArea = false
            invalidateCache()
        }
    }

    /// Sets the area state for a specific view
    func setViewArea(index: Int, isInUpperArea: Bool) {
        guard viewStates.indices.contains(index) else { return }
        if viewStates[index].isInUpperArea != isInUpperArea {
            viewStates[index].isInUpperArea = isInUpperArea
            invalidateCache()
        }
    }
}
