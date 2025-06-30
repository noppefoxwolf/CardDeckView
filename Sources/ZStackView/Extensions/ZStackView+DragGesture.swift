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
        if state.draggedViewIndex == nil {
            selectViewForDragging(dragValue: value)
        }

        updateDragOffset(value: value)
    }

    /// Handles drag gesture ending
    private func handleDragEnded(value: DragGesture.Value, geometry: GeometryProxy) {
        guard let index = state.draggedViewIndex else { return }

        let currentIsUpperArea = state.isInUpperArea(index: index)
        finalizeDragMovement(
            index: index,
            value: value,
            geometry: geometry,
            isUpperArea: currentIsUpperArea
        )
    }

    /// Selects which view should be dragged based on the drag location
    private func selectViewForDragging(dragValue: DragGesture.Value) {
        let targetViews =
            dragValue.translation.height > 0
            ? state.upperAreaViewIndices : state.lowerAreaViewIndices

        if let nearestIndex = state.findNearestViewIndex(
            to: dragValue.startLocation,
            in: targetViews
        ) {
            state.startDragging(viewIndex: nearestIndex)
        }
    }

    /// Updates the drag offset for the currently dragged view
    private func updateDragOffset(value: DragGesture.Value) {
        state.updateDragOffset(CGSize(width: 0, height: value.translation.height))
    }

    /// Finalizes the drag movement with animation
    private func finalizeDragMovement(
        index: Int,
        value: DragGesture.Value,
        geometry: GeometryProxy,
        isUpperArea: Bool
    ) {
        let currentY =
            (isUpperArea ? -geometry.size.height / 2 : geometry.size.height / 2)
            + value.translation.height
        let velocity = value.predictedEndTranslation.height - value.translation.height
        let velocityThreshold: CGFloat = 50

        let shouldChangeArea = state.shouldChangeArea(
            index: index,
            currentY: currentY,
            velocity: velocity,
            velocityThreshold: velocityThreshold
        )

        let duration = shouldChangeArea ? max(0.2, min(0.5, abs(velocity) / 1000)) : 0.2

        withAnimation(.easeOut(duration: duration)) {
            state.endDragging(shouldChangeArea: shouldChangeArea)
        }
    }

}
