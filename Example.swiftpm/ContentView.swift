import SwiftUI
import CardDeckView

struct ContentView: View {
    @State private var currentPosition: String? = nil
    
    var body: some View {
        NavigationStack {
            CardDeckView {
                ForEach(0..<5) { index in
                    CardView(
                        title: "Card \(index + 1)",
                        subtitle: "Swipe to see next card",
                        color: cardColors[index % cardColors.count]
                    )
                    .tag("\(index)")
                }
                
                // Final completion card
                CompletionCard()
                    .tag("completed")
            }
            .stackPosition(tag: $currentPosition)
            .safeAreaInset(edge: .bottom) {
                StatusBar(currentPosition: currentPosition)
            }
            .navigationTitle("Card Deck Example")
        }
    }
    
    private let cardColors: [Color] = [
        .blue, .green, .orange, .purple, .pink
    ]
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
    
    var body: some View {
        HStack {
            Text("Current: \(currentPosition ?? "None")")
            Spacer()
            Text("Swipe up to navigate")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
