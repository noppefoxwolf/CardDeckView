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
    
    internal var setFrontmostLowerAreaTag: ((AnyHashable?) -> Void)?
    
    internal init() {}
    
    public func slideTo(_ tag: Tag, anchor: UnitPoint? = nil) {
        setFrontmostLowerAreaTag?(AnyHashable(tag))
    }
    
    func setFrontmostLowerAreaTagHandler(_ handler: @escaping (AnyHashable?) -> Void) {
        setFrontmostLowerAreaTag = handler
    }
    
    func updateFrontmostLowerAreaTag(_ tag: AnyHashable?) {
        if let tagValue = tag as? Tag {
            frontmostLowerAreaTag = tagValue
        }
    }
}
