import SwiftUI

// MARK: - Tag Management
extension ZStackView {
    
    /// Updates the frontmost lower area tag based on current view states
    func updateFrontmostLowerAreaTag(subviews: SubviewsCollection) {
        guard let proxy = proxy else { return }
        
        let frontmostIndex = findFrontmostLowerAreaViewIndex()
        updateProxyFrontmostTag(from: subviews, at: frontmostIndex, proxy: proxy)
    }
    
    /// Sets up the proxy connection for ZStackViewReader
    func setupProxyConnection(subviews: SubviewsCollection) {
        guard let proxy = proxy else { return }
        
        setupProxyTagHandler(proxy: proxy, subviews: subviews)
        
        let frontmostIndex = findFrontmostLowerAreaViewIndex()
        updateProxyFrontmostTag(from: subviews, at: frontmostIndex, proxy: proxy)
    }
    
    /// Sets up the proxy tag handler
    private func setupProxyTagHandler<Proxy: ZStackViewProxyProtocol>(proxy: Proxy, subviews: SubviewsCollection) {
        proxy.setFrontmostLowerAreaTagHandler { tag in
            self.handleFrontmostTagChange(newTag: tag, subviews: subviews, proxy: proxy)
        }
    }
    
    /// Updates the proxy's frontmost tag
    private func updateProxyFrontmostTag<Proxy: ZStackViewProxyProtocol>(from subviews: SubviewsCollection, at index: Int?, proxy: Proxy) {
        let tag = proxy.extractTag(from: subviews, at: index)
        proxy.updateFrontmostLowerAreaTag(tag)
    }
    
    /// Handles programmatic changes to the frontmost tag
    private func handleFrontmostTagChange<Tag: Hashable, Proxy: ZStackViewProxyProtocol>(newTag: Tag?, subviews: SubviewsCollection, proxy: Proxy) where Tag == Proxy.TagType {
        guard let targetTag = newTag else { return }
        
        let targetIndex: Int? = proxy.findViewIndex(with: targetTag, in: subviews)
        
        guard let targetIndex = targetIndex else { return }
        
        let targetIsInUpperArea = isInUpperArea(index: targetIndex)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if targetIsInUpperArea {
                moveViewFromUpperToLowerArea(index: targetIndex)
            }
            // Always reorganize all views based on z-index relative to target
            reorganizeViewsByZIndex(targetIndex: targetIndex)
        }
        
        updateFrontmostLowerAreaTag(subviews: subviews)
    }
    
    /// Updates proxy using AnyHashable fallback for uncommon types
    private func updateProxyWithAnyHashable<Tag: Hashable>(tagType: Tag.Type, subviews: SubviewsCollection, index: Int) {
        if extractTagWithReflection(from: subviews, at: index, type: tagType) != nil {
            // We can't call updateFrontmostLowerAreaTag directly due to associatedtype limitations
            // The proxy will handle this through its own implementation
            print("Warning: Using AnyHashable fallback for tag type: \(tagType)")
        }
    }
    
    /// Finds view index using AnyHashable fallback for uncommon types
    private func findViewIndexWithAnyHashable<Tag: Hashable, Proxy: ZStackViewProxyProtocol>(targetTag: Tag, subviews: SubviewsCollection, proxy: Proxy) -> Int? where Tag == Proxy.TagType {
        let tagType = proxy.tagType
        
        for index in subviews.indices {
            if let tag = extractTagWithReflection(from: subviews, at: index, type: tagType), tag == targetTag {
                return index
            }
        }
        return nil
    }
    
    /// Extracts tag using reflection for any Hashable type
    private func extractTagWithReflection<Tag: Hashable>(from subviews: SubviewsCollection, at index: Int, type: Tag.Type) -> Tag? {
        subviews[index].containerValues.tag(for: Tag.self)
    }
    
    /// Finds the index of the frontmost view in the lower area
    private func findFrontmostLowerAreaViewIndex() -> Int? {
        lowerAreaViewIndices.max { index1, index2 in
            let zIndex1 = getZIndex(for: index1)
            let zIndex2 = getZIndex(for: index2)
            return zIndex1 < zIndex2
        }
    }
    
    
    /// Moves a view from upper area to lower area
    private func moveViewFromUpperToLowerArea(index: Int) {
        viewStates[index].isInUpperArea = false
    }
    
    /// Reorganizes all views based on their z-index relative to the target
    private func reorganizeViewsByZIndex(targetIndex: Int) {
        let targetZIndex = getZIndex(for: targetIndex)
        
        for index in viewStates.indices {
            if index != targetIndex {
                let zIndex = getZIndex(for: index)
                if zIndex > targetZIndex {
                    viewStates[index].isInUpperArea = true
                } else if zIndex < targetZIndex {
                    viewStates[index].isInUpperArea = false
                }
            }
        }
    }
    
    /// Moves views with higher z-index than target to upper area and lower z-index views to lower area
    private func moveHigherZIndexViewsToUpperArea(targetIndex: Int) {
        reorganizeViewsByZIndex(targetIndex: targetIndex)
    }
}
