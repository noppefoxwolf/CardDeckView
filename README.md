# CardDeckView

A SwiftUI library that provides an interactive card deck with swipe navigation and drag gestures for iOS apps.

![Example](.github/docs/example.gif)

[日本語版 README](.github/docs/README_ja.md)

## Features

- **Card Stack Navigation**: Swipe through cards with smooth animations
- **Interactive Drag Gestures**: Natural touch interactions for card navigation
- **Position Tracking**: Monitor current card position with binding support
- **Customizable Styling**: Built-in card background modifiers and shadows
- **SwiftUI Native**: Built entirely with SwiftUI components
- **iOS & macOS Support**: Compatible with iOS 18+ and macOS 15+

## Requirements

- iOS 18.0+ / macOS 15.0+
- Swift 6.2+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add CardDeckView to your project using Swift Package Manager:

1. In Xcode, select File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/noppefoxwolf/CardDeckView`
3. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/noppefoxwolf/CardDeckView.git", from: "1.0.0")
]
```

## Usage

### Basic Implementation

```swift
import SwiftUI
import CardDeckView

struct ContentView: View {
    @State private var currentPosition: String? = nil
    
    var body: some View {
        CardDeckView {
            ForEach(0..<5) { index in
                CardView(title: "Card \(index + 1)")
                    .tag("\(index)")
            }
        }
        .stackPosition(tag: $currentPosition)
    }
}

struct CardView: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.gradient)
        .foregroundColor(.white)
        .stackCardBackground {
            Color.blue.opacity(0.3)
                .shadow(radius: 10)
        }
        .cornerRadius(20)
    }
}
```

### Advanced Example

```swift
struct AdvancedCardDeck: View {
    @State private var currentPosition: String? = nil
    
    var body: some View {
        NavigationStack {
            CardDeckView {
                ForEach(cards) { card in
                    CustomCardView(card: card)
                        .tag(card.id)
                }
                
                CompletionCard()
                    .tag("completed")
            }
            .stackPosition(tag: $currentPosition)
            .safeAreaInset(edge: .bottom) {
                StatusIndicator(position: currentPosition)
            }
            .navigationTitle("Card Deck")
        }
    }
}
```

## Key Components

### CardDeckView
The main container that manages card navigation and gestures.

### .stackPosition(tag:)
Modifier to track the current visible card position.

### .stackCardBackground
Modifier to add shadow and background styling to cards.

## How It Works

CardDeckView manages a stack of cards where users can:
- **Swipe up/down** to navigate between cards
- **Drag** cards to reveal the next/previous card
- **Track position** using the stackPosition modifier

The view automatically handles:
- Smooth animations between cards
- Velocity-based gesture recognition
- Z-index management for proper layering

### Important Note About onAppear

Since CardDeckView is built on top of ZStack, **all cards' `onAppear` modifiers are called when the deck is first displayed**, not when individual cards become visible. This is the expected behavior for ZStack in SwiftUI.

If you need to trigger actions when a specific card becomes visible, use the `stackPosition` binding instead:

```swift
CardDeckView {
    ForEach(cards) { card in
        CardView(card: card)
            .tag(card.id)
    }
}
.stackPosition(tag: $currentPosition)
.onChange(of: currentPosition) { newPosition in
    // Trigger actions when card position changes
    handleCardAppeared(for: newPosition)
}
```

## Development

### Building

```bash
swift build
```

### Testing

```bash
swift test
```

### Xcode Integration

Open `Package.swift` directly in Xcode for the modern SPM workflow, or generate an Xcode project:

```bash
swift package generate-xcodeproj
```

## License

This project is available under the MIT license. See the LICENSE file for more info.
