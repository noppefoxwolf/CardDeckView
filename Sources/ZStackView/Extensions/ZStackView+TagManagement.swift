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
    
    /// Sets up the proxy tag handler using type erasure
    private func setupProxyTagHandler(proxy: any ZStackViewProxyProtocol, subviews: SubviewsCollection) {
        let tagType = proxy.tagType
        
        if tagType == String.self {
            proxy.setFrontmostLowerAreaTagHandler { (tag: String?) in
                self.handleFrontmostTagChange(newTag: tag, subviews: subviews, proxy: proxy)
            }
        } else if tagType == Int.self {
            proxy.setFrontmostLowerAreaTagHandler { (tag: Int?) in
                self.handleFrontmostTagChange(newTag: tag, subviews: subviews, proxy: proxy)
            }
        } else if tagType == UUID.self {
            proxy.setFrontmostLowerAreaTagHandler { (tag: UUID?) in
                self.handleFrontmostTagChange(newTag: tag, subviews: subviews, proxy: proxy)
            }
        }
    }
    
    /// Updates the proxy's frontmost tag using generic extraction
    private func updateProxyFrontmostTag(from subviews: SubviewsCollection, at index: Int?, proxy: any ZStackViewProxyProtocol) {
        let tagType = proxy.tagType
        
        if tagType == String.self {
            let tag = proxy.extractTag(from: subviews, at: index, as: String.self)
            proxy.updateFrontmostLowerAreaTag(tag)
        } else if tagType == Int.self {
            let tag = proxy.extractTag(from: subviews, at: index, as: Int.self)
            proxy.updateFrontmostLowerAreaTag(tag)
        } else if tagType == UUID.self {
            let tag = proxy.extractTag(from: subviews, at: index, as: UUID.self)
            proxy.updateFrontmostLowerAreaTag(tag)
        }
    }
    
    /// Handles programmatic changes to the frontmost tag
    private func handleFrontmostTagChange<T: Hashable>(newTag: T?, subviews: SubviewsCollection, proxy: any ZStackViewProxyProtocol) {
        guard let targetTag = newTag else { return }
        guard let targetIndex = proxy.findViewIndex(with: targetTag, in: subviews) else { return }
        
        let targetIsInUpperArea = isInUpperArea(index: targetIndex)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if targetIsInUpperArea {
                moveViewFromUpperToLowerArea(index: targetIndex)
            } else {
                moveHigherZIndexViewsToUpperArea(targetIndex: targetIndex)
            }
        }
        
        updateFrontmostLowerAreaTag(subviews: subviews)
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
    
    /// Moves views with higher z-index than target to upper area
    private func moveHigherZIndexViewsToUpperArea(targetIndex: Int) {
        let targetZIndex = getZIndex(for: targetIndex)
        
        for index in lowerAreaViewIndices {
            if index != targetIndex {
                let zIndex = getZIndex(for: index)
                if zIndex > targetZIndex {
                    viewStates[index].isInUpperArea = true
                }
            }
        }
    }
}
