import SwiftUI

@available(iOS 18.0, macOS 15.0, *)
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


@available(iOS 18.0, macOS 15.0, *)
public class ZStackViewProxy<Tag: Hashable>: ObservableObject, ZStackViewProxyProtocol {
    
    @Published public var frontmostLowerAreaTag: Tag?
    
    internal var setFrontmostLowerAreaTagHandler: ((Tag?) -> Void)?
    
    public var tagType: Any.Type {
        return Tag.self
    }
    
    internal init() {}
    
    public func slideTo(_ tag: Tag) {
        setFrontmostLowerAreaTagHandler?(tag)
    }
    
    func setFrontmostLowerAreaTagHandler<T: Hashable>(_ handler: @escaping (T?) -> Void) {
        if T.self == Tag.self {
            setFrontmostLowerAreaTagHandler = { tag in
                handler(tag as? T)
            }
        }
    }
    
    func updateFrontmostLowerAreaTag<T: Hashable>(_ tag: T?) {
        if let tagValue = tag as? Tag {
            frontmostLowerAreaTag = tagValue
        }
    }
    
    func extractTag<T: Hashable>(from subviews: SubviewsCollection, at index: Int?, as type: T.Type) -> T? {
        guard let index = index,
              subviews.indices.contains(index) else {
            return nil
        }
        
        return subviews[index].containerValues.tag(for: type)
    }
    
    func findViewIndex<T: Hashable>(with targetTag: T, in subviews: SubviewsCollection) -> Int? {
        for index in subviews.indices {
            if let tag = subviews[index].containerValues.tag(for: T.self),
               tag == targetTag {
                return index
            }
        }
        return nil
    }
}
