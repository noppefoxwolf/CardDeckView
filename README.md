# ZStackView

A SwiftUI library that provides an interactive ZStack with drag-and-drop functionality for reordering views between upper and lower areas.

## Features

- **Interactive ZStack**: Drag views between upper and lower areas
- **Smooth Animations**: Fluid transitions with velocity-based animations
- **SwiftUI Native**: Built entirely with SwiftUI components
- **iOS & macOS Support**: Compatible with iOS 18+ and macOS 15+

## Requirements

- iOS 18.0+ / macOS 15.0+
- Swift 6.2+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add ZStackView to your project using Swift Package Manager:

1. In Xcode, select File → Add Package Dependencies
2. Enter the repository URL
3. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/noppefoxwolf/ZStackView.git", from: "1.0.0")
]
```

## Usage

```swift
import SwiftUI
import ZStackView

struct ContentView: View {
    var body: some View {
        ZStackView {
            ForEach(0..<3) { i in
                Rectangle()
                    .fill(Color.red)
                    .overlay {
                        Text("\(i)")
                    }
                    .shadow(radius: 20)
            }
            
            Color.green
                .overlay {
                    Text("Done")
                }
        }
        .ignoresSafeArea()
    }
}
```

## How It Works

ZStackView creates two areas:
- **Upper Area**: Views positioned above the center
- **Lower Area**: Views positioned below the center

Users can drag views between these areas with smooth animations and velocity-based transitions.

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