import SwiftUI

public struct ZStackViewReader<Tag: Hashable, Content: View>: View {

  private let content: (ZStackViewProxy<Tag>) -> Content

  @StateObject private var proxy: ZStackViewProxy<Tag> = ZStackViewProxy()

  public init(@ViewBuilder content: @escaping (ZStackViewProxy<Tag>) -> Content) {
    self.content = content
  }

  public var body: some View {
    content(proxy)
      .environment(\.zStackViewProxy, proxy)
  }
}

public class ZStackViewProxy<Tag: Hashable>: ObservableObject, ZStackViewProxyProtocol {

  typealias TagType = Tag

  @Published public var frontmostLowerAreaTag: Tag?

  internal var setFrontmostLowerAreaTagHandler: ((Tag?) -> Void)?

  public var tagType: Tag.Type {
    return Tag.self
  }

  internal init() {}

  public func slideTo(_ tag: Tag) {
    setFrontmostLowerAreaTagHandler?(tag)
  }

  func setFrontmostLowerAreaTagHandler(_ handler: @escaping (Tag?) -> Void) {
    setFrontmostLowerAreaTagHandler = handler
  }

  func updateFrontmostLowerAreaTag(_ tag: Tag?) {
    frontmostLowerAreaTag = tag
  }

  func extractTag(from subviews: SubviewsCollection, at index: Int?) -> Tag? {
    guard let index = index,
      subviews.indices.contains(index)
    else {
      return nil
    }

    return subviews[index].containerValues.tag(for: Tag.self)
  }

  func findViewIndex(with targetTag: Tag, in subviews: SubviewsCollection) -> Int? {
    for index in subviews.indices {
      if let tag = subviews[index].containerValues.tag(for: Tag.self),
        tag == targetTag
      {
        return index
      }
    }
    return nil
  }
}
