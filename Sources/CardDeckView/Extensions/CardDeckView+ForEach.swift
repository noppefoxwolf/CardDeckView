import SwiftUI

// MARK: - ForEach Initializers

public extension CardDeckView {
    
    /// Creates a new CardDeckView with a ForEach loop over a collection of data
    /// - Parameters:
    ///   - data: A collection of data to iterate over
    ///   - id: A key path to a property that uniquely identifies each element
    ///   - content: A closure that creates a view for each element
    init<Data, ID, ItemContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> ItemContent
    ) where Data: RandomAccessCollection, ID: Hashable, Content == ForEach<Data, ID, ItemContent> {
        self.content = ForEach(data, id: id, content: content)
    }
    
    /// Creates a new CardDeckView with a ForEach loop over a collection of identifiable data
    /// - Parameters:
    ///   - data: A collection of identifiable data to iterate over
    ///   - content: A closure that creates a view for each element
    init<Data, ItemContent>(
        _ data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> ItemContent
    ) where Data: RandomAccessCollection, Data.Element: Identifiable, Content == ForEach<Data, Data.Element.ID, ItemContent> {
        self.content = ForEach(data, content: content)
    }
    
    /// Creates a new CardDeckView with a ForEach loop over a range
    /// - Parameters:
    ///   - range: A range of integers to iterate over
    ///   - content: A closure that creates a view for each integer
    init<ItemContent>(
        _ range: Range<Int>,
        @ViewBuilder content: @escaping (Int) -> ItemContent
    ) where Content == ForEach<Range<Int>, Int, ItemContent> {
        self.content = ForEach(range, id: \.self, content: content)
    }
}