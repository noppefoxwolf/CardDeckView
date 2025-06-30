import SwiftUI

struct ViewState: Sendable, Equatable {
    var isInUpperArea: Bool = false
    var dragOffset: CGSize = .zero
    var isDragging: Bool = false
    var zIndex: Double
}


@available(iOS 18.0, macOS 15.0, *)
public struct ZStackView<Content: View, Tag: Hashable>: View {
    private let content: Content
    
    @State
    var viewStates: [ViewState] = []
    
    @State
    var draggedViewIndex: Int? = nil
    
    @Binding
    var frontmostLowerAreaTag: Tag?
    
    public init(frontmostLowerAreaTag: Binding<Tag?> = .constant(nil), @ViewBuilder content: () -> Content) {
        self._frontmostLowerAreaTag = frontmostLowerAreaTag
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Group(subviews: content) { subviews in
                self.createLayout(geometry: geometry, subviews: subviews)
                    .onAppear {
                        updateLowerAreaTags(subviews: subviews)
                    }
                    .onChange(of: frontmostLowerAreaTag) { _, newTag in
                        handleFrontmostTagChange(newTag: newTag, subviews: subviews)
                    }
            }
        }
        .onChange(of: viewStates) { _, newValue in
            // We need subviews to update tags, will be called from createLayout
        }
    }
    
    private func createLayout(geometry: GeometryProxy, subviews: SubviewsCollection) -> some View {
        ZStack {
            Color.clear
            
            // All views in reverse order
            ForEach(subviews.indices, id: \.self) { index in
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
        .onChange(of: viewStates) { _, _ in
            updateLowerAreaTags(subviews: subviews)
        }
    }
    
    
    private func createDraggableView(subview: Subview, index: Int, geometry: GeometryProxy, isUpperArea: Bool) -> some View {
        subview
            .frame(width: geometry.size.width, height: geometry.size.height)
            .offset(viewStates.indices.contains(index) ? viewStates[index].dragOffset : .zero)
            .zIndex(viewStates.indices.contains(index) ? viewStates[index].zIndex : Double(index))
            .allowsHitTesting(!viewStates.indices.contains(index) || !viewStates[index].isDragging)
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
                ViewState(zIndex: Double(count - 1 - index))
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
                    let targetViews = value.translation.height > 0 ? upperAreaViews : lowerAreaViews
                    
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
        
        let isUpperAreaViews = viewIndices.allSatisfy { viewStates[$0].isInUpperArea }
        
        return isUpperAreaViews ?
            viewIndices.max() :
            viewIndices.min()
    }
    
    
    private func updateLowerAreaTags(subviews: SubviewsCollection) {
        // Find the frontmost (highest zIndex) view in lower area
        let frontmostIndex = lowerAreaViews.max { index1, index2 in
            let zIndex1 = viewStates.indices.contains(index1) ? viewStates[index1].zIndex : Double(index1)
            let zIndex2 = viewStates.indices.contains(index2) ? viewStates[index2].zIndex : Double(index2)
            return zIndex1 < zIndex2
        }
        
        var newTag: Tag? = nil
        if let index = frontmostIndex,
           subviews.indices.contains(index),
           let tag = subviews[index].containerValues.tag(for: Tag.self) {
            newTag = tag
        }
        
        if frontmostLowerAreaTag != newTag {
            frontmostLowerAreaTag = newTag
        }
    }
    
    private func handleFrontmostTagChange(newTag: Tag?, subviews: SubviewsCollection) {
        guard let targetTag = newTag else { return }
        
        // Find the index of the view with the target tag
        var targetIndex: Int? = nil
        for index in subviews.indices {
            if let tag = subviews[index].containerValues.tag(for: Tag.self),
               tag == targetTag {
                targetIndex = index
                break
            }
        }
        
        guard let targetIdx = targetIndex else { return }
        
        let targetIsInUpperArea = viewStates.indices.contains(targetIdx) && viewStates[targetIdx].isInUpperArea
        let targetZIndex = viewStates.indices.contains(targetIdx) ? viewStates[targetIdx].zIndex : Double(targetIdx)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if targetIsInUpperArea {
                // If target is in upper area, move it to lower area
                viewStates[targetIdx].isInUpperArea = false
            } else {
                // If target is in lower area, move views with higher zIndex to upper area
                for index in lowerAreaViews {
                    if index != targetIdx {
                        let zIndex = viewStates.indices.contains(index) ? viewStates[index].zIndex : Double(index)
                        if zIndex > targetZIndex {
                            viewStates[index].isInUpperArea = true
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
#Preview {
    @Previewable @State var frontmostTag: String? = nil
    
    return NavigationStack {
        ZStackView(frontmostLowerAreaTag: $frontmostTag) {
            ForEach(0..<3) { index in
                Color.red
                    .overlay {
                        Button {
                            print("Action: \(index)")
                            frontmostTag = "1"
                        } label: {
                            Text("Card: \(index)")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .shadow(radius: 30)
                    .tag("\(index)")
            }
            
            Color.green
                .overlay {
                    Text("Done")
                }
                .tag("done")
        }
        .ignoresSafeArea()
        .navigationTitle("ZStackView")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Debug") {
                    print("Frontmost lower area tag: \(frontmostTag ?? "nil")")
                }
            }
        }
        .overlay(alignment: .bottom) {
            Text("\(frontmostTag)")
        }
    }
}
