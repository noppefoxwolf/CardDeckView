import SwiftUI

struct ViewState {
    var isInUpperArea: Bool = false
    var dragOffset: CGSize = .zero
    var isDragging: Bool = false
    var zIndex: Double
}

@available(iOS 13.0, macOS 10.15, *)
public struct ZStackPagingLayout: View {
    private let colors: [Color]
    @State private var viewStates: [ViewState] = []
    @State private var draggedViewIndex: Int? = nil
    
    public init(colors: [Color] = [.red, .green]) {
        self.colors = colors
    }
    
    public var body: some View {
        GeometryReader { geometry in
            self.createLayout(geometry: geometry)
        }
        .onAppear {
            self.initializeViewStates()
        }
    }
    
    private func createLayout(geometry: GeometryProxy) -> some View {
        ZStack {
            // Background areas
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: geometry.size.height / 2)
                Color.gray.opacity(0.2)
                    .frame(height: geometry.size.height / 2)
            }
            
            // Area drag gestures
            VStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(createAreaDragGesture(geometry: geometry, isUpperArea: true))
                    .frame(height: geometry.size.height / 2)
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(createAreaDragGesture(geometry: geometry, isUpperArea: false))
                    .frame(height: geometry.size.height / 2)
            }
            
            // All views in the same ZStack to maintain global zIndex
            ForEach(viewStates.indices, id: \.self) { index in
                createDraggableView(
                    index: index,
                    geometry: geometry,
                    isUpperArea: viewStates[index].isInUpperArea
                )
                .position(
                    x: geometry.size.width / 2,
                    y: viewStates[index].isInUpperArea ? 
                        geometry.size.height / 4 : 
                        geometry.size.height * 3 / 4
                )
            }
        }
    }
    
    
    private func createDraggableView(index: Int, geometry: GeometryProxy, isUpperArea: Bool) -> some View {
        ZStack {
            Rectangle()
                .fill(colors[index])
                .frame(width: 100, height: 100)
            
            Text("\(Int(viewStates[index].zIndex))")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .offset(viewStates[index].dragOffset)
        .zIndex(viewStates[index].zIndex)
        .gesture(
            DragGesture()
                .onChanged { value in
                    handleDragChanged(index: index, value: value)
                }
                .onEnded { value in
                    handleDragEnded(index: index, value: value, geometry: geometry, isUpperArea: isUpperArea)
                }
        )
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
    
    private func initializeViewStates() {
        viewStates = colors.enumerated().map { index, _ in
            ViewState(zIndex: Double(index))
        }
    }
    
    private func handleDragChanged(index: Int, value: DragGesture.Value) {
        viewStates[index].dragOffset = value.translation
        viewStates[index].isDragging = true
    }
    
    private func handleDragEnded(index: Int, value: DragGesture.Value, geometry: GeometryProxy, isUpperArea: Bool) {
        let screenMidPoint = geometry.size.height / 2
        let finalY: CGFloat
        
        if isUpperArea {
            finalY = value.location.y + value.translation.height
        } else {
            finalY = value.location.y + value.translation.height + screenMidPoint
        }
        
        if isUpperArea && finalY > screenMidPoint {
            viewStates[index].isInUpperArea = false
        } else if !isUpperArea && finalY < screenMidPoint {
            viewStates[index].isInUpperArea = true
        }
        
        viewStates[index].dragOffset = .zero
        viewStates[index].isDragging = false
    }
    
    private func createAreaDragGesture(geometry: GeometryProxy, isUpperArea: Bool) -> some Gesture {
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
                    viewStates[index].dragOffset = value.translation
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

@available(iOS 13.0, macOS 10.15, *)
#Preview {
    ZStackPagingLayout(colors: [.red, .green, .blue, .orange, .purple])
}
