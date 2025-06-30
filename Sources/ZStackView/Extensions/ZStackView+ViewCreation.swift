import SwiftUI

// MARK: - View Creation
extension ZStackView {

  /// Creates the main layout with all subviews
  func createMainLayout(geometry: GeometryProxy, subviews: SubviewsCollection) -> some View {
    ZStack {
      Color.clear

      ForEach(subviews.indices, id: \.self) { index in
        createPositionedView(
          subview: subviews[index],
          index: index,
          geometry: geometry
        )
      }
    }
    .contentShape(Rectangle())
    .gesture(createGlobalDragGesture(geometry: geometry))
    .onAppear {
      initializeViewStates(count: subviews.count)
    }
    .onChange(of: state.lowerAreaViewIndices) { _, _ in
      updateFrontmostLowerAreaTag(subviews: subviews)
    }
  }

  /// Creates a positioned view with proper styling and interactions
  private func createPositionedView(
    subview: Subview,
    index: Int,
    geometry: GeometryProxy
  ) -> some View {
    let isUpperArea = state.isInUpperArea(index: index)

    return createStyledView(subview: subview, index: index, geometry: geometry)
      .position(
        x: geometry.size.width / 2,
        y: calculateYPosition(isUpperArea: isUpperArea, geometry: geometry)
      )
  }

  /// Creates a styled view with frame, offset, and z-index
  private func createStyledView(
    subview: Subview,
    index: Int,
    geometry: GeometryProxy
  ) -> some View {
    subview
      .frame(width: geometry.size.width, height: geometry.size.height)
      .offset(state.getDragOffset(for: index))
      .zIndex(state.getZIndex(for: index))
      .allowsHitTesting(!state.isDragging(index: index))
  }

  /// Calculates the Y position for a view based on its area
  private func calculateYPosition(isUpperArea: Bool, geometry: GeometryProxy) -> CGFloat {
    isUpperArea ? -geometry.size.height / 2 : geometry.size.height / 2
  }

}
