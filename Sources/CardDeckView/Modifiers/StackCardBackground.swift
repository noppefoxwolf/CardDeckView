import SwiftUI

struct StackCardBackgroundModifier<V: View>: ViewModifier {
    @Environment(\.cardDeckViewGeometryProxy)
    var geometryProxy
    
    let view: V
    
    func body(content: Content) -> some View {
        if let geometryProxy {
            let height = geometryProxy.size.height + geometryProxy.safeAreaInsets.top + geometryProxy.safeAreaInsets.bottom
            content
                .background(alignment: .top) {
                    view
                        .frame(height: height)
                        .offset(y: -geometryProxy.safeAreaInsets.top)
                }
        } else {
            content
                .background(view)
        }
    }
}

extension View {
    public func stackCardBackground<Content: View>(_ view: () -> Content) -> some View {
        modifier(StackCardBackgroundModifier(view: view()))
    }
}

