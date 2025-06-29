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
            Color.gray.opacity(0.2)
            
            // All views in reverse order
            ForEach(subviews.indices.reversed(), id: \.self) { index in
                createDraggableView(
                    subview: subviews[index],
                    index: index,
                    geometry: geometry,
                    isUpperArea: viewStates.indices.contains(index) && viewStates[index].isInUpperArea
                )
                .position(
                    x: geometry.size.width / 2,
                    y: viewStates.indices.contains(index) && viewStates[index].isInUpperArea ? 
                        -geometry.size.height / 2 : 
                        geometry.size.height / 2
                )
            }
        }
        .contentShape(Rectangle())
        .gesture(createGlobalDragGesture(geometry: geometry))
        .onAppear {
            initializeViewStates(count: subviews.count)
        }
    }
    
    
    private func createDraggableView(subview: Subview, index: Int, geometry: GeometryProxy, isUpperArea: Bool) -> some View {
        subview
            .frame(width: geometry.size.width, height: geometry.size.height)
            .offset(viewStates.indices.contains(index) ? viewStates[index].dragOffset : .zero)
            .zIndex(viewStates.indices.contains(index) ? viewStates[index].zIndex : Double(index))
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
    
    private func handleDragEnded(index: Int, value: DragGesture.Value, geometry: GeometryProxy, isUpperArea: Bool) {
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
    
    private func createGlobalDragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if draggedViewIndex == nil {
                    let targetViews = value.translation.height < 0 ? lowerAreaViews : upperAreaViews
                    
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
        
        let isLowerAreaViews = viewIndices.allSatisfy { !viewStates[$0].isInUpperArea }
        
        return isLowerAreaViews ?
            viewIndices.max { viewStates[$0].zIndex < viewStates[$1].zIndex } :
            viewIndices.min { 
                distanceToView(index: $0, from: location) < distanceToView(index: $1, from: location)
            }
    }
    
    private func distanceToView(index: Int, from location: CGPoint) -> CGFloat {
        let viewCenter = CGPoint(x: 50, y: 50)
        let dx = location.x - viewCenter.x
        let dy = location.y - viewCenter.y
        return sqrt(dx * dx + dy * dy)
    }
}

@available(iOS 18.0, macOS 15.0, *)
#Preview {
    ZStackPagingLayout {
        Color.green
            .overlay {
                Text("Done")
            }
        
        ForEach(0..<3) { i in
            Rectangle()
                .fill(Color.red)
                .overlay {
                    Text("\(i)")
                }
                .mask(RoundedRectangle(cornerRadius: 64))
                .shadow(radius: 20)
        }
    }.ignoresSafeArea()
}
