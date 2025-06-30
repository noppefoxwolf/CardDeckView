import Testing
import SwiftUI
@testable import ZStackView

@Test("ZStackViewState initialization")
func testInitialization() {
    let state = ZStackViewState()
    
    #expect(state.viewStates.isEmpty)
    #expect(state.draggedViewIndex == nil)
    #expect(state.upperAreaViewIndices.isEmpty)
    #expect(state.lowerAreaViewIndices.isEmpty)
}

@Test("Initialize view states")
func testInitializeViewStates() {
    let state = ZStackViewState()
    
    state.initializeViewStates(count: 3)
    
    #expect(state.viewStates.count == 3)
    #expect(state.viewStates[0].zIndex == 2.0)
    #expect(state.viewStates[1].zIndex == 1.0)
    #expect(state.viewStates[2].zIndex == 0.0)
    
    for viewState in state.viewStates {
        #expect(!viewState.isInUpperArea)
        #expect(viewState.dragOffset == .zero)
        #expect(!viewState.isDragging)
    }
}

@Test("Initialize view states with same count doesn't reinitialize")
func testInitializeViewStatesIdempotent() {
    let state = ZStackViewState()
    
    state.initializeViewStates(count: 2)
    let originalStates = state.viewStates
    
    state.initializeViewStates(count: 2)
    
    #expect(state.viewStates.count == 2)
    #expect(state.viewStates[0].zIndex == originalStates[0].zIndex)
    #expect(state.viewStates[1].zIndex == originalStates[1].zIndex)
}

@Test("Get z-index for valid and invalid indices")
func testGetZIndex() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 3)
    
    #expect(state.getZIndex(for: 0) == 2.0)
    #expect(state.getZIndex(for: 1) == 1.0)
    #expect(state.getZIndex(for: 2) == 0.0)
    #expect(state.getZIndex(for: 5) == 5.0) // fallback for invalid index
}

@Test("Check if view is in upper area")
func testIsInUpperArea() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 2)
    
    #expect(!state.isInUpperArea(index: 0))
    #expect(!state.isInUpperArea(index: 1))
    #expect(!state.isInUpperArea(index: 5)) // invalid index returns false
}

@Test("Get drag offset")
func testGetDragOffset() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 2)
    
    #expect(state.getDragOffset(for: 0) == .zero)
    #expect(state.getDragOffset(for: 1) == .zero)
    #expect(state.getDragOffset(for: 5) == .zero) // invalid index returns zero
}

@Test("Check if view is dragging")
func testIsDragging() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 2)
    
    #expect(!state.isDragging(index: 0))
    #expect(!state.isDragging(index: 1))
    #expect(!state.isDragging(index: 5)) // invalid index returns false
}

@Test("Start dragging")
func testStartDragging() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 3)
    
    state.startDragging(viewIndex: 1)
    
    #expect(state.draggedViewIndex == 1)
    #expect(state.isDragging(index: 1))
    #expect(!state.isDragging(index: 0))
    #expect(!state.isDragging(index: 2))
}

@Test("Start dragging with invalid index")
func testStartDraggingInvalidIndex() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 2)
    
    state.startDragging(viewIndex: 5)
    
    #expect(state.draggedViewIndex == nil)
}

@Test("Update drag offset")
func testUpdateDragOffset() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 2)
    
    state.startDragging(viewIndex: 1)
    let testOffset = CGSize(width: 10, height: 20)
    state.updateDragOffset(testOffset)
    
    #expect(state.getDragOffset(for: 1) == testOffset)
    #expect(state.getDragOffset(for: 0) == .zero)
}

@Test("Update drag offset without dragging")
func testUpdateDragOffsetNoDragging() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 2)
    
    let testOffset = CGSize(width: 10, height: 20)
    state.updateDragOffset(testOffset)
    
    #expect(state.getDragOffset(for: 0) == .zero)
    #expect(state.getDragOffset(for: 1) == .zero)
}

@Test("End dragging without changing area")
func testEndDraggingNoChange() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 2)
    
    state.startDragging(viewIndex: 1)
    state.updateDragOffset(CGSize(width: 0, height: 50))
    
    let wasInUpperArea = state.isInUpperArea(index: 1)
    state.endDragging(shouldChangeArea: false)
    
    #expect(state.draggedViewIndex == nil)
    #expect(!state.isDragging(index: 1))
    #expect(state.getDragOffset(for: 1) == .zero)
    #expect(state.isInUpperArea(index: 1) == wasInUpperArea)
}

@Test("End dragging with area change")
func testEndDraggingWithChange() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 2)
    
    state.startDragging(viewIndex: 1)
    let wasInUpperArea = state.isInUpperArea(index: 1)
    
    state.endDragging(shouldChangeArea: true)
    
    #expect(state.draggedViewIndex == nil)
    #expect(!state.isDragging(index: 1))
    #expect(state.getDragOffset(for: 1) == .zero)
    #expect(state.isInUpperArea(index: 1) == !wasInUpperArea)
}

@Test("Upper and lower area view indices")
func testAreaViewIndices() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 4)
    
    // Initially all views are in lower area
    #expect(state.upperAreaViewIndices.isEmpty)
    #expect(state.lowerAreaViewIndices == [0, 1, 2, 3])
    
    // Move some views to upper area
    state.startDragging(viewIndex: 1)
    state.endDragging(shouldChangeArea: true)
    
    state.startDragging(viewIndex: 3)
    state.endDragging(shouldChangeArea: true)
    
    #expect(state.upperAreaViewIndices.sorted() == [1, 3])
    #expect(state.lowerAreaViewIndices.sorted() == [0, 2])
}

@Test("Get target view indices")
func testGetTargetViewIndices() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 3)
    
    // Move one view to upper area
    state.startDragging(viewIndex: 1)
    state.endDragging(shouldChangeArea: true)
    
    let upwardDrag = state.getTargetViewIndices(for: 10.0) // positive = upward
    let downwardDrag = state.getTargetViewIndices(for: -10.0) // negative = downward
    
    #expect(upwardDrag == [1]) // upper area indices
    #expect(downwardDrag.sorted() == [0, 2]) // lower area indices
}

@Test("Find nearest view index")
func testFindNearestViewIndex() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 4)
    
    // Move views 1 and 3 to upper area
    state.startDragging(viewIndex: 1)
    state.endDragging(shouldChangeArea: true)
    state.startDragging(viewIndex: 3)
    state.endDragging(shouldChangeArea: true)
    
    let upperIndices = [1, 3]
    let lowerIndices = [0, 2]
    
    // For upper area views, should return max index
    #expect(state.findNearestViewIndex(to: .zero, in: upperIndices) == 3)
    
    // For lower area views, should return min index
    #expect(state.findNearestViewIndex(to: .zero, in: lowerIndices) == 0)
    
    // Empty array should return nil
    #expect(state.findNearestViewIndex(to: .zero, in: []) == nil)
}

@Test("Should change area logic")
func testShouldChangeArea() {
    let state = ZStackViewState()
    state.initializeViewStates(count: 2)
    
    // Test upper area view
    state.startDragging(viewIndex: 0)
    state.endDragging(shouldChangeArea: true) // Move to upper area
    
    // Upper area view should change area when dragged down (positive Y) or high velocity
    #expect(state.shouldChangeArea(index: 0, currentY: 10, velocity: 0))
    #expect(state.shouldChangeArea(index: 0, currentY: -10, velocity: 60))
    #expect(!state.shouldChangeArea(index: 0, currentY: -10, velocity: 10))
    
    // Test lower area view (index 1 is still in lower area)
    #expect(state.shouldChangeArea(index: 1, currentY: -10, velocity: 0))
    #expect(state.shouldChangeArea(index: 1, currentY: 10, velocity: -60))
    #expect(!state.shouldChangeArea(index: 1, currentY: 10, velocity: -10))
    
    // Invalid index should return false
    #expect(!state.shouldChangeArea(index: 5, currentY: 100, velocity: 100))
}