import SwiftUI

/// A SwiftUI view that provides an interactive ZStack with drag-and-drop functionality
/// for reordering views between upper and lower areas.

public struct ZStackView<Content: View>: View {

    // MARK: - Properties

    private let content: Content

    @State var state = ZStackViewState()
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
            .environment(\.zStackViewGeometryProxy, geometry)
        }
    }
}


extension EnvironmentValues {
    @Entry
    var zStackViewGeometryProxy: GeometryProxy? = nil
}


// MARK: - Preview

#Preview {
    @Previewable
    @State
    var currentPosition: String? = nil

    TabView {
        Tab {
            NavigationStack {
                ZStackView {
                    ForEach(0..<5) { index in
                        Color.green
                            .stackCardBackground{
                                Color.red.shadow(radius: 10)
                            }
                    }
                    
                    Color.green
                        .overlay {
                            Text("Done")
                        }
                        .tag("done")
                }
                .stackPosition(tag: $currentPosition)
                .safeAreaInset(edge: .bottom, content: {
                    Text("Current Position: \(currentPosition)")
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                })
                .navigationTitle("ZStackView")
            }
        }
    }
}
