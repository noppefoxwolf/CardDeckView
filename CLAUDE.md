# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
ZStackPagingLayout is a SwiftUI library package that implements paging layout functionality using ZStack. This is a Swift Package Manager (SPM) project targeting iOS 26+ with Swift 6.2+.

## Development Commands

### Building and Testing
- `swift build` - Build the package
- `swift test` - Run all tests
- `swift package resolve` - Resolve package dependencies

### Xcode Integration
- `swift package generate-xcodeproj` - Generate Xcode project (if needed)
- Open Package.swift directly in Xcode for modern SPM workflow

## Code Architecture

### Package Structure
- **Sources/ZStackPagingLayout/** - Main library code
  - Currently contains a preview implementation with basic ZStack color layering
- **Tests/ZStackPagingLayoutTests/** - Test suite using Swift Testing framework
- **Package.swift** - SPM manifest defining iOS 26+ target and Swift 6.2+ requirement

### Testing Framework
Uses Swift Testing framework (import Testing) rather than XCTest. Test functions are marked with `@Test` attribute.

### Key Technical Notes
- Minimum iOS version: 26.0 (latest/beta iOS version)
- Swift version: 6.2+ (latest Swift version)
- Uses SwiftUI for UI implementation
- Library target exposes ZStackPagingLayout module