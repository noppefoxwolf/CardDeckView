import SwiftUI

/// A SwiftUI view that provides an interactive card deck with drag-and-drop functionality
/// for reordering cards between upper and lower areas.

public struct CardDeckView<Content: View>: View {

    // MARK: - Properties

    internal let content: Content

    @State var state = CardDeckViewState()
    @Environment(\.cardDeckViewProxy) var proxy: (any CardDeckViewProxyProtocol)?
    @Environment(\.cardDeckDisabledScrollDirections) var disabledScrollDirections

    // MARK: - Initialization

    /// Creates a new CardDeckView
    /// - Parameter content: The cards to display in the deck
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
            .environment(\.cardDeckViewGeometryProxy, geometry)
        }
    }
}


extension EnvironmentValues {
    @Entry
    var cardDeckViewGeometryProxy: GeometryProxy? = nil
}


// MARK: - Preview

#Preview {
    @Previewable
    @State
    var currentPosition: String? = nil

    TabView {
        Tab {
            NavigationStack {
                CardDeckView {
                    ForEach(0..<3) { index in
                        Color.green
                            .stackCardBackground{
                                Color.red.shadow(radius: 10)
                            }
                            .tag("\(index)")
                    }
                    
                    Color.blue
                    
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
                .navigationTitle("CardDeckView")
            }
        }
    }
}
