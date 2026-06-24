import SwiftUI

struct PackOpeningView: View {
    let pack: CardPack

    @State private var stage: OpeningStage = .ready
    @State private var openedCards: [Card] = []
    @State private var showResults = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 14) {
                Image(systemName: stage == .ready ? "shippingbox.fill" : "rectangle.stack.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.indigo)

                Text(pack.name)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(stageText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                openPack()
            } label: {
                Label(stage == .ready ? "Open Pack" : "View Results", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Open Pack")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showResults) {
            ResultsView(cards: openedCards)
        }
    }

    private var stageText: String {
        switch stage {
        case .ready:
            "Tap the button to open \(pack.cardsPerOpening) local dummy cards."
        case .opening:
            "Your pack is open. The MVP skips advanced animation for now."
        case .results:
            "Results are ready."
        }
    }

    private func openPack() {
        if openedCards.isEmpty {
            openedCards = Array(pack.cards.shuffled().prefix(pack.cardsPerOpening))
            stage = .opening
        } else {
            stage = .results
        }

        showResults = true
    }
}

#Preview("Pack Opening") {
    NavigationStack {
        PackOpeningView(pack: CardPack.dummyPacks[0])
    }
}
