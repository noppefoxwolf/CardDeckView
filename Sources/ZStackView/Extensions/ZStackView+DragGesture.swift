import SwiftUI

// MARK: - Drag Gesture Handling
extension ZStackView {
    
    /// Creates the global drag gesture for the ZStackView
    func createGlobalDragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                handleDragChanged(value: value)
            }
            .onEnded { value in
                handleDragEnded(value: value, geometry: geometry)
            }
    }
    
    /// Handles drag gesture changes
    private func handleDragChanged(value: DragGesture.Value) {
        if draggedViewIndex == nil {
            selectViewForDragging(dragValue: value)
        }
        
        updateDragOffset(value: value)
    }
    
    /// Handles drag gesture ending
    private func handleDragEnded(value: DragGesture.Value, geometry: GeometryProxy) {
        guard let index = draggedViewIndex else { return }
        
        let currentIsUpperArea = isInUpperArea(index: index)
        finalizeDragMovement(
            index: index,
            value: value,
            geometry: geometry,
            isUpperArea: currentIsUpperArea
        )
        
        draggedViewIndex = nil
    }
    
    /// Selects which view should be dragged based on the drag location
    private func selectViewForDragging(dragValue: DragGesture.Value) {
        let targetViews = dragValue.translation.height > 0 ? upperAreaViewIndices : lowerAreaViewIndices
        
        if let nearestIndex = findNearestViewIndex(to: dragValue.startLocation, in: targetViews) {
            draggedViewIndex = nearestIndex
            viewStates[nearestIndex].isDragging = true
        }
    }
    
    /// Updates the drag offset for the currently dragged view
    private func updateDragOffset(value: DragGesture.Value) {
        if let index = draggedViewIndex {
            viewStates[index].dragOffset = CGSize(width: 0, height: value.translation.height)
        }
    }
    
    /// Finalizes the drag movement with animation
    private func finalizeDragMovement(
        index: Int,
        value: DragGesture.Value,
        geometry: GeometryProxy,
        isUpperArea: Bool
    ) {
        let currentY = (isUpperArea ? -geometry.size.height / 2 : geometry.size.height / 2) + value.translation.height
        let velocity = value.predictedEndTranslation.height - value.translation.height
        let velocityThreshold: CGFloat = 50
        
        let shouldChangeArea = isUpperArea ?
            (currentY > 0 || velocity > velocityThreshold) :
            (currentY < 0 || velocity < -velocityThreshold)
        
        let duration = shouldChangeArea ? max(0.2, min(0.5, abs(velocity) / 1000)) : 0.2
        
        withAnimation(.easeOut(duration: duration)) {
            if shouldChangeArea {
                viewStates[index].isInUpperArea = !isUpperArea
            }
            viewStates[index].dragOffset = .zero
            viewStates[index].isDragging = false
        }
    }
    
    /// Finds the nearest view to drag from the given location
    private func findNearestViewIndex(to location: CGPoint, in viewIndices: [Int]) -> Int? {
        guard !viewIndices.isEmpty else { return nil }
        
        let isUpperAreaViews = viewIndices.allSatisfy { viewStates[$0].isInUpperArea }
        
        return isUpperAreaViews ?
            viewIndices.max() :
            viewIndices.min()
    }
}