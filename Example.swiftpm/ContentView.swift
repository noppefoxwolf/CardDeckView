import SwiftUI
import CardDeckView

enum ExampleType: String, CaseIterable {
    case normal = "Normal"
    case upDisabled = "Up Swipe Disabled"
    case downDisabled = "Down Swipe Disabled"
    case allDisabled = "All Disabled"
    
    var icon: String {
        switch self {
        case .normal: return "hand.point.up"
        case .upDisabled: return "arrow.up.square"
        case .downDisabled: return "arrow.down.square"
        case .allDisabled: return "hand.raised"
        }
    }
    
    var color: Color {
        switch self {
        case .normal: return .blue
        case .upDisabled: return .red
        case .downDisabled: return .orange
        case .allDisabled: return .gray
        }
    }
    
    var subtitle: String {
        switch self {
        case .normal: return "All gestures enabled"
        case .upDisabled: return "Up swipe disabled"
        case .downDisabled: return "Down swipe disabled"
        case .allDisabled: return "All gestures disabled"
        }
    }
}

struct ContentView: View {
    @State private var selectedExample: ExampleType = .normal
    @State private var currentPosition: String? = nil
    
    var body: some View {
        NavigationStack {
            createCardDeckView()
                .cardDeckDisabledScrollDirections(disabledDirections)
                .stackPosition(tag: $currentPosition)
                .safeAreaInset(edge: .bottom) {
                    StatusBar(
                        currentPosition: currentPosition,
                        info: selectedExample.subtitle
                    )
                }
                .navigationTitle("CardDeckView")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Picker("Examples", selection: $selectedExample) {
                            ForEach(ExampleType.allCases, id: \.self) { example in
                                Label(example.rawValue, systemImage: example.icon)
                                    .tag(example)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                }
        }
    }
    
    private var disabledDirections: CardDeckScrollDirection {
        switch selectedExample {
        case .normal: return []
        case .upDisabled: return .up
        case .downDisabled: return .down
        case .allDisabled: return .all
        }
    }
    
    @ViewBuilder
    private func createCardDeckView() -> some View {
        CardDeckView {
            ForEach(allCardData, id: \.id) { card in
                CardView(
                    title: card.title,
                    subtitle: selectedExample.subtitle,
                    color: card.color
                )
                .tag(card.tag)
            }
            
            CompletionCard()
                .tag("completed")
        }
    }
    
    private let allCardData = [
        CardData(id: "0", title: "Card 1", tag: "0", color: .blue),
        CardData(id: "1", title: "Card 2", tag: "1", color: .green),
        CardData(id: "2", title: "Card 3", tag: "2", color: .orange),
        CardData(id: "3", title: "Card 4", tag: "3", color: .purple),
        CardData(id: "4", title: "Card 5", tag: "4", color: .pink)
    ]
}

struct CardData {
    let id: String
    let title: String
    let tag: String
    let color: Color
}


struct CardView: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color.gradient)
        .stackCardBackground {
            color.opacity(0.3)
                .shadow(radius: 10)
        }
        .cornerRadius(20)
    }
}

struct CompletionCard: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("All Done!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You've completed all cards")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .cornerRadius(20)
    }
}

struct StatusBar: View {
    let currentPosition: String?
    let info: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Current: \(currentPosition ?? "None")")
                Spacer()
                Text(info)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
