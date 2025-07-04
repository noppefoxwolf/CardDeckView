import SwiftUI

public struct StackPositionModifier<Tag: Hashable>: ViewModifier {

    @Binding private var tag: Tag?

    public init(tag: Binding<Tag?>) {
        self._tag = tag
    }

    public func body(content: Content) -> some View {
        CardDeckViewReader { proxy in
            content
                .onAppear {
                    setupProxyBinding(proxy: proxy)
                }
                .onChange(of: tag) { _, newTag in
                    if let newTag = newTag {
                        proxy.slideTo(newTag)
                    }
                }
                .onChange(of: proxy.frontmostLowerAreaTag) { _, newTag in
                    if newTag != tag {
                        self.tag = newTag
                    }
                }
        }
    }

    private func setupProxyBinding(proxy: CardDeckViewProxy<Tag>) {
        // Sync initial value from proxy to binding
        self.tag = proxy.frontmostLowerAreaTag

        // Listen for changes from proxy and update binding
        proxy.setFrontmostLowerAreaTagHandler { newTag in
            self.tag = newTag
        }
    }
}

extension View {
    /// Binds a tag to the current stack position in CardDeckView
    /// - Parameter tag: A binding to the tag value that represents the current frontmost position
    /// - Returns: A view with the stack position modifier applied
    public func stackPosition<Tag: Hashable>(tag: Binding<Tag?>) -> some View {
        self.modifier(StackPositionModifier(tag: tag))
    }
}
