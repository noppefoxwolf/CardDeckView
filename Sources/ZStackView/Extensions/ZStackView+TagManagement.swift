import SwiftUI

// MARK: - Tag Management
extension ZStackView {
    
    /// Updates the frontmost lower area tag based on current view states
    func updateFrontmostLowerAreaTag(subviews: SubviewsCollection) {
        let frontmostIndex = findFrontmostLowerAreaViewIndex()
        let newTag = extractTag(from: subviews, at: frontmostIndex)
        updateProxyFrontmostTag(newTag)
    }
    
    /// Sets up the proxy connection for ZStackViewReader
    func setupProxyConnection(subviews: SubviewsCollection) {
        guard let proxy = proxy else { return }
        
        proxy.setFrontmostLowerAreaTagHandler { tag in
            self.handleFrontmostTagChange(newTag: tag, subviews: subviews)
        }
        
        let frontmostIndex = findFrontmostLowerAreaViewIndex()
        let currentTag = extractTag(from: subviews, at: frontmostIndex)
        updateProxyFrontmostTag(currentTag)
    }
    
    /// Updates the proxy's frontmost tag
    private func updateProxyFrontmostTag(_ tag: AnyHashable?) {
        proxy?.updateFrontmostLowerAreaTag(tag)
    }
    
    /// Handles programmatic changes to the frontmost tag
    func handleFrontmostTagChange(newTag: AnyHashable?, subviews: SubviewsCollection) {
        guard let targetTag = newTag else { return }
        guard let targetIndex = findViewIndex(with: targetTag, in: subviews) else { return }
        
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
    
    /// Extracts the tag from a subview at the given index
    private func extractTag(from subviews: SubviewsCollection, at index: Int?) -> AnyHashable? {
        guard let index = index,
              subviews.indices.contains(index) else {
            return nil
        }
        
        // Try to extract any hashable tag
        return subviews[index].containerValues.anyHashableTag
    }
    
    /// Finds the index of a view with the specified tag
    private func findViewIndex(with targetTag: AnyHashable, in subviews: SubviewsCollection) -> Int? {
        for index in subviews.indices {
            if let tag = subviews[index].containerValues.anyHashableTag,
               tag == targetTag {
                return index
            }
        }
        return nil
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
