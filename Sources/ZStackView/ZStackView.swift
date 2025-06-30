import SwiftUI

/// A SwiftUI view that provides an interactive ZStack with drag-and-drop functionality
/// for reordering views between upper and lower areas.
@available(iOS 18.0, macOS 15.0, *)
public struct ZStackView<Content: View>: View {
    
    // MARK: - Properties
    
    private let content: Content
    
    @State var viewStates: [ViewState] = []
    @State var draggedViewIndex: Int? = nil
    @Environment(\.zStackViewProxy) var proxy: (any ZStackViewProxyProtocol)?
    
    // MARK: - Initialization
    
    /// Creates a new ZStackView
    /// - Parameter content: The views to display in the stack
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            Group(subviews: content) { subviews in
                createMainLayout(geometry: geometry, subviews: subviews)
                    .onAppear {
                        setupProxyConnection(subviews: subviews)
                    }
            }
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, macOS 15.0, *)
#Preview {
    ZStackViewReader { proxy in
        ZStackView {
            ForEach(0..<3) { index in
                Color.red
                    .overlay {
                        Button {
                            print("Action: \(index)")
                            proxy.slideTo("1")
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
        .overlay(alignment: .bottom) {
            Text("\(proxy.frontmostLowerAreaTag ?? "nil")")
        }
    }
    .ignoresSafeArea()
}
