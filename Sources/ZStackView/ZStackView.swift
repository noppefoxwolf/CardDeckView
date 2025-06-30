import SwiftUI

/// A SwiftUI view that provides an interactive ZStack with drag-and-drop functionality
/// for reordering views between upper and lower areas.
@available(iOS 18.0, macOS 15.0, *)
public struct ZStackView<Content: View, Tag: Hashable>: View {
    
    // MARK: - Properties
    
    private let content: Content
    
    @State var viewStates: [ViewState] = []
    @State var draggedViewIndex: Int? = nil
    @Binding var frontmostLowerAreaTag: Tag?
    
    // MARK: - Initialization
    
    /// Creates a new ZStackView with optional frontmost tag binding
    /// - Parameters:
    ///   - frontmostLowerAreaTag: Binding to track the frontmost view tag in the lower area
    ///   - content: The views to display in the stack
    public init(
        frontmostLowerAreaTag: Binding<Tag?> = .constant(nil),
        @ViewBuilder content: () -> Content
    ) {
        self._frontmostLowerAreaTag = frontmostLowerAreaTag
        self.content = content()
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            Group(subviews: content) { subviews in
                createMainLayout(geometry: geometry, subviews: subviews)
                    .onAppear {
                        updateFrontmostLowerAreaTag(subviews: subviews)
                    }
                    .onChange(of: frontmostLowerAreaTag) { _, newTag in
                        handleFrontmostTagChange(newTag: newTag, subviews: subviews)
                    }
            }
        }
    }
}

// MARK: - Preview

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
            Text(frontmostTag ?? "nil")
        }
    }
}
