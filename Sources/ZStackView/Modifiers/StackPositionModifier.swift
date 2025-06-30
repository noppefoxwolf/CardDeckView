import SwiftUI

public struct StackPositionModifier<Tag: Hashable>: ViewModifier {

  @Binding private var tag: Tag

  public init(tag: Binding<Tag>) {
    self._tag = tag
  }

  public func body(content: Content) -> some View {
    ZStackViewReader { proxy in
      content
        .onAppear {
          setupProxyBinding(proxy: proxy)
        }
        .onChange(of: tag) { _, newTag in
          proxy.slideTo(newTag)
        }
        .onChange(of: proxy.frontmostLowerAreaTag) { _, newTag in
          if let newTag = newTag, newTag != tag {
            DispatchQueue.main.async {
              self.tag = newTag
            }
          }
        }
    }
  }

  private func setupProxyBinding(proxy: ZStackViewProxy<Tag>) {
    // Sync initial value from proxy to binding
    if let frontmostTag = proxy.frontmostLowerAreaTag {
      self.tag = frontmostTag
    }

    // Listen for changes from proxy and update binding
    proxy.setFrontmostLowerAreaTagHandler { newTag in
      if let newTag = newTag {
        self.tag = newTag
      }
    }
  }
}

extension View {
  /// Binds a tag to the current stack position in ZStackView
  /// - Parameter tag: A binding to the tag value that represents the current frontmost position
  /// - Returns: A view with the stack position modifier applied
  public func stackPosition<Tag: Hashable>(tag: Binding<Tag>) -> some View {
    self.modifier(StackPositionModifier(tag: tag))
  }
}
