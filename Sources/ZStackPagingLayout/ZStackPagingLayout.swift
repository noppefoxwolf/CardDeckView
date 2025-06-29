import SwiftUI

struct ViewState {
    var isInUpperArea: Bool = false
    var dragOffset: CGSize = .zero
    var isDragging: Bool = false
    var zIndex: Double
}

@available(iOS 18.0, macOS 15.0, *)
public struct ZStackPagingLayout<Content: View>: View {
    private let content: Content
    @State private var viewStates: [ViewState] = []
    @State private var draggedViewIndex: Int? = nil
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Group(subviews: content) { subviews in
                self.createLayout(geometry: geometry, subviews: subviews)
            }
        }
    }
    
    private func createLayout(geometry: GeometryProxy, subviews: SubviewsCollection) -> some View {
        ZStack {
            // Background areas
            Color.gray.opacity(0.2)
                .frame(width: geometry.size.width, height: geometry.size.height)
            
            // All views in the same ZStack to maintain global zIndex
            ForEach(subviews.indices, id: \.self) { index in
                createDraggableView(
                    subview: subviews[index],
                    index: index,
                    geometry: geometry,
                    isUpperArea: index < viewStates.count ? viewStates[index].isInUpperArea : false
                )
                .position(
                    x: geometry.size.width / 2,
                    y: (index < viewStates.count ? viewStates[index].isInUpperArea : false) ? 
                        -geometry.size.height / 2 : 
                        geometry.size.height / 2
                )
            }
        }
        .contentShape(Rectangle())
        .gesture(createGlobalDragGesture(geometry: geometry, subviewCount: subviews.count))
        .onAppear {
            self.initializeViewStates(count: subviews.count)
        }
    }
    
    
    private func createDraggableView(subview: Subview, index: Int, geometry: GeometryProxy, isUpperArea: Bool) -> some View {
        ZStack {
            subview
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .offset(index < viewStates.count ? viewStates[index].dragOffset : .zero)
        .zIndex(index < viewStates.count ? viewStates[index].zIndex : Double(index))
        .allowsHitTesting(false)
    }
    
    private var upperAreaViews: [Int] {
        viewStates.enumerated().compactMap { index, state in
            state.isInUpperArea ? index : nil
        }
    }
    
    private var lowerAreaViews: [Int] {
        viewStates.enumerated().compactMap { index, state in
            !state.isInUpperArea ? index : nil
        }
    }
    
    private func initializeViewStates(count: Int) {
        if viewStates.count != count {
            viewStates = (0..<count).map { index in
                ViewState(zIndex: Double(index))
            }
        }
    }
    
    private func handleDragChanged(index: Int, value: DragGesture.Value) {
        viewStates[index].dragOffset = CGSize(width: 0, height: value.translation.height)
        viewStates[index].isDragging = true
    }
    
    private func handleDragEnded(index: Int, value: DragGesture.Value, geometry: GeometryProxy, isUpperArea: Bool) {
        let currentY = (isUpperArea ? -geometry.size.height / 2 : geometry.size.height / 2) + value.translation.height
        
        // Calculate velocity from predictedEndTranslation
        let velocity = CGSize(
            width: value.predictedEndTranslation.width - value.translation.width,
            height: value.predictedEndTranslation.height - value.translation.height
        )
        
        // Determine if area should change based on position and velocity
        let shouldChangeArea: Bool
        let velocityThreshold: CGFloat = 50
        
        if isUpperArea {
            shouldChangeArea = currentY > 0 || velocity.height > velocityThreshold
        } else {
            shouldChangeArea = currentY < 0 || velocity.height < -velocityThreshold
        }
        
        if shouldChangeArea {
            // Use easeOut animation with velocity consideration
            let duration = max(0.2, min(0.5, abs(velocity.height) / 1000))
            
            withAnimation(.easeOut(duration: duration)) {
                viewStates[index].isInUpperArea = !isUpperArea
                viewStates[index].dragOffset = .zero
                viewStates[index].isDragging = false
            }
        } else {
            // Animate back to original position
            withAnimation(.easeOut(duration: 0.2)) {
                viewStates[index].dragOffset = .zero
                viewStates[index].isDragging = false
            }
        }
    }
    
    private func createGlobalDragGesture(geometry: GeometryProxy, subviewCount: Int) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if draggedViewIndex == nil {
                    let targetViews: [Int]
                    if value.translation.height < 0 {
                        // Dragging up - select from lower area
                        targetViews = lowerAreaViews
                    } else {
                        // Dragging down - select from upper area
                        targetViews = upperAreaViews
                    }
                    
                    if let nearestIndex = findNearestView(to: value.startLocation, in: targetViews) {
                        draggedViewIndex = nearestIndex
                        viewStates[nearestIndex].isDragging = true
                    }
                }
                
                if let index = draggedViewIndex {
                    viewStates[index].dragOffset = CGSize(width: 0, height: value.translation.height)
                }
            }
            .onEnded { value in
                if let index = draggedViewIndex {
                    let currentIsUpperArea = viewStates[index].isInUpperArea
                    handleDragEnded(index: index, value: value, geometry: geometry, isUpperArea: currentIsUpperArea)
                    draggedViewIndex = nil
                }
            }
    }
    
    private func findNearestView(to location: CGPoint, in viewIndices: [Int]) -> Int? {
        guard !viewIndices.isEmpty else { return nil }
        
        // Check if we're looking at lower area views (not in upper area)
        let isLowerAreaViews = viewIndices.allSatisfy { !viewStates[$0].isInUpperArea }
        
        if isLowerAreaViews {
            // For lower area, return the one with highest zIndex
            return viewIndices.max(by: { index1, index2 in
                viewStates[index1].zIndex < viewStates[index2].zIndex
            })
        } else {
            // For upper area, find nearest by distance
            return viewIndices.min(by: { index1, index2 in
                let distance1 = distanceToView(index: index1, from: location)
                let distance2 = distanceToView(index: index2, from: location)
                return distance1 < distance2
            })
        }
    }
    
    private func distanceToView(index: Int, from location: CGPoint) -> CGFloat {
        let viewCenter = CGPoint(x: 50, y: 50) // Assuming views are 100x100 and centered
        let dx = location.x - viewCenter.x
        let dy = location.y - viewCenter.y
        return sqrt(dx * dx + dy * dy)
    }
}

@available(iOS 18.0, macOS 15.0, *)
#Preview {
    ZStackPagingLayout {
        ForEach(0..<3) { i in
            Rectangle()
                .fill(Color.red)
                .overlay {
                    Text("\(i)")
                }
                .mask(RoundedRectangle(cornerRadius: 64))
                .shadow(radius: 20)
                .onAppear {
                    print(i)
                }
        }
        Color.green
            .overlay {
                Text("Done")
            }
    }.ignoresSafeArea()
}
