import SwiftUI

// MARK: - Tag Management
extension ZStackView {
    
    /// Updates the frontmost lower area tag based on current view states
    func updateFrontmostLowerAreaTag(subviews: SubviewsCollection) {
        let frontmostIndex = findFrontmostLowerAreaViewIndex()
        let newTag = extractTag(from: subviews, at: frontmostIndex)
        
        if frontmostLowerAreaTag != newTag {
            frontmostLowerAreaTag = newTag
        }
    }
    
    /// Handles programmatic changes to the frontmost tag
    func handleFrontmostTagChange(newTag: Tag?, subviews: SubviewsCollection) {
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
    private func extractTag(from subviews: SubviewsCollection, at index: Int?) -> Tag? {
        guard let index = index,
              subviews.indices.contains(index),
              let tag = subviews[index].containerValues.tag(for: Tag.self) else {
            return nil
        }
        return tag
    }
    
    /// Finds the index of a view with the specified tag
    private func findViewIndex(with targetTag: Tag, in subviews: SubviewsCollection) -> Int? {
        for index in subviews.indices {
            if let tag = subviews[index].containerValues.tag(for: Tag.self),
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