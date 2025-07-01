import SwiftUI

// MARK: - Drag Gesture Handling
extension CardDeckView {

    /// Creates the global drag gesture for the CardDeckView
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
        
        // Calculate velocity from predicted end location
        let velocity = value.predictedEndTranslation.height - value.translation.height
        let velocityMagnitude = abs(velocity)
        
        // Enhanced velocity thresholds for more responsive gestures
        let fastSwipeThreshold: CGFloat = 100
        let mediumSwipeThreshold: CGFloat = 30
        
        // Determine if we should change areas based on enhanced criteria
        let shouldChangeArea = determineShouldChangeArea(
            index: index,
            currentY: currentY,
            velocity: velocity,
            translation: value.translation.height,
            predictedEnd: value.predictedEndTranslation.height,
            isUpperArea: isUpperArea,
            geometry: geometry
        )
        
        // Calculate animation duration based on velocity
        let duration = calculateAnimationDuration(
            velocity: velocityMagnitude,
            shouldChangeArea: shouldChangeArea
        )
        
        // Use smooth easing animation without spring
        withAnimation(.easeOut(duration: duration)) {
            state.endDragging(shouldChangeArea: shouldChangeArea)
        }
    }
    
    /// Determines if the view should change areas based on enhanced criteria
    private func determineShouldChangeArea(
        index: Int,
        currentY: CGFloat,
        velocity: CGFloat,
        translation: CGFloat,
        predictedEnd: CGFloat,
        isUpperArea: Bool,
        geometry: GeometryProxy
    ) -> Bool {
        let velocityThreshold: CGFloat = 30
        let distanceThreshold = geometry.size.height * 0.15 // 15% of screen height
        
        // Check velocity-based decision first (for quick swipes)
        if abs(velocity) > velocityThreshold {
            return isUpperArea ? velocity > 0 : velocity < 0
        }
        
        // Check if predicted end position suggests area change
        let predictedY = (isUpperArea ? -geometry.size.height / 2 : geometry.size.height / 2) + predictedEnd
        let crossesCenter = isUpperArea ? predictedY > 0 : predictedY < 0
        
        // Check if translation distance is significant
        let significantDistance = abs(translation) > distanceThreshold
        
        return crossesCenter && significantDistance
    }
    
    /// Calculates animation duration based on velocity
    private func calculateAnimationDuration(
        velocity: CGFloat,
        shouldChangeArea: Bool
    ) -> Double {
        if shouldChangeArea {
            // Fast swipe - quick animation
            if velocity > 200 {
                return 0.25
            }
            // Medium swipe - moderate animation
            else if velocity > 50 {
                return 0.35
            }
            // Slow drag - smooth animation
            else {
                return 0.45
            }
        } else {
            // Return to original position - always quick
            return 0.2
        }
    }

}
