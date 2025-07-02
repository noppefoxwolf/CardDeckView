import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Drag Gesture Handling
extension CardDeckView {

    /// Creates the global drag gesture for the CardDeckView
    func createGlobalDragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if shouldHandleDragGesture(value: value) {
                    handleDragChanged(value: value)
                }
            }
            .onEnded { value in
                if shouldHandleDragGesture(value: value) {
                    handleDragEnded(value: value, geometry: geometry)
                }
            }
    }
    
    /// Determines if the drag gesture should be enabled based on disabled scroll directions
    var isDragGestureEnabled: Bool {
        // If no directions are disabled, allow all gestures
        guard !disabledScrollDirections.isEmpty else { return true }
        
        // Check if all directions are disabled
        if disabledScrollDirections.contains(.all) {
            return false
        }
        
        // If only specific directions are disabled, we need to check during the gesture
        // For now, enable the gesture and check within the handlers
        return true
    }
    
    /// Determines if the drag gesture should be handled based on disabled scroll directions
    private func shouldHandleDragGesture(value: DragGesture.Value) -> Bool {
        let translation = value.translation
        
        // If no directions are disabled, allow all gestures
        guard !disabledScrollDirections.isEmpty else { return true }
        
        // Check if all directions are disabled
        if disabledScrollDirections.contains(.all) {
            return false
        }
        
        // Check vertical gesture direction (up or down)
        let isUpwardGesture = translation.height < 0 // Negative translation means upward
        let isDownwardGesture = translation.height > 0 // Positive translation means downward
        
        if isUpwardGesture && disabledScrollDirections.contains(.up) {
            return false
        }
        
        if isDownwardGesture && disabledScrollDirections.contains(.down) {
            return false
        }
        
        return true
    }

    /// Handles drag gesture changes
    private func handleDragChanged(value: DragGesture.Value) {
        if state.draggedViewIndex == nil {
            selectViewForDragging(dragValue: value)
            // Provide light haptic feedback when drag starts
            #if canImport(UIKit)
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            #endif
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
        let _ = 100 // fastSwipeThreshold
        let _ = 30  // mediumSwipeThreshold
        
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
        
        // Provide haptic feedback based on action
        #if canImport(UIKit)
        if shouldChangeArea {
            // Medium impact for successful area change
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        } else {
            // Light impact for return to original position
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        #endif
        
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
            // Provide haptic feedback for fast swipe detection
            #if canImport(UIKit)
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            #endif
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
