import SwiftUI

struct PackOpeningView: View {
    let pack: CardPack

    @State private var stage: OpeningStage = .idle
    @State private var openedCards: [Card] = []
    @State private var revealedCards: [Card] = []
    @State private var showResults = false
    @State private var sequenceTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            OpeningHeaderView(pack: pack, stage: stage)

            InteractivePackView(
                stage: stage,
                cardsPerOpening: pack.cardsPerOpening,
                onPressingChanged: handlePressingChanged,
                onChargeCompleted: handleChargeCompleted,
                onDragChanged: handleDragChanged,
                onDragEnded: handleDragEnded
            )

            StageInstructionView(stage: stage, cardsPerOpening: pack.cardsPerOpening)

            RevealedCardsStrip(cards: revealedCards, highlightedIndex: highlightedRevealIndex)

            OpeningFooterView(stage: stage) {
                showResults = true
            } onReset: {
                resetOpening()
            }

            Spacer()
        }
        .navigationTitle("Open Pack")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showResults) {
            ResultsView(cards: openedCards)
        }
        .onDisappear {
            sequenceTask?.cancel()
        }
    }

    private var highlightedRevealIndex: Int? {
        if case .revealing(let index) = stage {
            index
        } else {
            nil
        }
    }

    private func handlePressingChanged(_ isPressing: Bool) {
        if isPressing {
            if stage == .idle {
                stage = .charging
            }
        } else if stage == .charging {
            stage = .idle
        }
    }

    private func handleChargeCompleted() {
        if stage == .charging || stage == .idle {
            stage = .readyToTear
        }
    }

    private func handleDragChanged(_ horizontalTranslation: CGFloat) {
        guard stage == .readyToTear || stage.isTearing else {
            return
        }

        let progress = min(max(horizontalTranslation / 180, 0), 1)
        stage = .tearing(progress: progress)

        if progress >= 1 {
            beginOpeningSequence()
        }
    }

    private func handleDragEnded(_ horizontalTranslation: CGFloat) {
        guard stage.isTearing else {
            return
        }

        let progress = min(max(horizontalTranslation / 180, 0), 1)
        if progress >= 1 {
            beginOpeningSequence()
        } else {
            stage = .readyToTear
        }
    }

    private func beginOpeningSequence() {
        guard !stage.isOpeningOrBeyond else {
            return
        }

        openedCards = Array(pack.cards.shuffled().prefix(pack.cardsPerOpening))
        revealedCards = []
        stage = .opening
        sequenceTask?.cancel()
        sequenceTask = Task {
            await runOpeningSequence()
        }
    }

    @MainActor
    private func runOpeningSequence() async {
        try? await Task.sleep(for: .milliseconds(650))

        for index in openedCards.indices {
            guard !Task.isCancelled else {
                return
            }

            stage = .revealing(index: index)
            revealedCards = Array(openedCards.prefix(index + 1))
            try? await Task.sleep(for: .milliseconds(420))
        }

        guard !Task.isCancelled else {
            return
        }

        stage = .completed
    }

    private func resetOpening() {
        sequenceTask?.cancel()
        openedCards = []
        revealedCards = []
        showResults = false
        stage = .idle
    }
}

private struct OpeningHeaderView: View {
    let pack: CardPack
    let stage: OpeningStage

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: stage.symbolName)
                .font(.system(size: 48))
                .foregroundStyle(.indigo)

            Text(pack.name)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

private struct InteractivePackView: View {
    let stage: OpeningStage
    let cardsPerOpening: Int
    let onPressingChanged: (Bool) -> Void
    let onChargeCompleted: () -> Void
    let onDragChanged: (CGFloat) -> Void
    let onDragEnded: (CGFloat) -> Void

    var body: some View {
        ZStack {
            PackCardBack(progress: stage.tearProgress)

            if stage == .charging {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
            }

            if stage.isOpeningOrBeyond {
                Text("\(cardsPerOpening)")
                    .font(.system(size: 46, weight: .black))
                    .foregroundStyle(.white.opacity(0.92))
            }
        }
        .frame(width: 178, height: 236)
        .scaleEffect(stage == .charging ? 1.04 : 1)
        .rotationEffect(.degrees(stage.isTearing ? 2 : 0))
        .animation(.spring(response: 0.28, dampingFraction: 0.8), value: stage)
        .accessibilityLabel(accessibilityLabel)
        .onLongPressGesture(minimumDuration: 0.75, maximumDistance: 28) {
            onChargeCompleted()
        } onPressingChanged: { isPressing in
            onPressingChanged(isPressing)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 8)
                .onChanged { value in
                    onDragChanged(value.translation.width)
                }
                .onEnded { value in
                    onDragEnded(value.translation.width)
                }
        )
    }

    private var accessibilityLabel: String {
        switch stage {
        case .idle:
            "Hold the pack to charge it."
        case .charging:
            "Charging the pack."
        case .readyToTear:
            "Swipe right to tear the pack."
        case .tearing(let progress):
            "Tearing progress \(Int(progress * 100)) percent."
        case .opening:
            "Opening the pack."
        case .revealing(let index):
            "Revealing card \(index + 1)."
        case .completed:
            "Opening completed."
        }
    }
}

private struct PackCardBack: View {
    let progress: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [.indigo, .teal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.7), lineWidth: 2)
                        .padding(10)
                }

            Rectangle()
                .fill(.white.opacity(0.42))
                .frame(width: max(10, 158 * progress), height: 3)
                .offset(x: 10)

            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 42, weight: .bold))
                Text("PACK")
                    .font(.title2.weight(.black))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .indigo.opacity(0.28), radius: 18, x: 0, y: 14)
    }
}

private struct StageInstructionView: View {
    let stage: OpeningStage
    let cardsPerOpening: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(stage.title)
                .font(.headline)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 58)
        .padding(.horizontal, 24)
    }

    private var message: String {
        switch stage {
        case .idle:
            "Long press the pack to build energy."
        case .charging:
            "Keep holding until the pack is ready."
        case .readyToTear:
            "Swipe right across the pack to tear it open."
        case .tearing(let progress):
            "Tearing \(Int(progress * 100))%. Keep swiping right."
        case .opening:
            "The pack is opening. Cards will reveal one by one."
        case .revealing(let index):
            "Revealing card \(index + 1) of \(cardsPerOpening)."
        case .completed:
            "All cards are revealed. You can inspect the full result list."
        }
    }
}

private struct RevealedCardsStrip: View {
    let cards: [Card]
    let highlightedIndex: Int?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    RevealedCardMiniView(card: card, isHighlighted: highlightedIndex == index)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .frame(height: cards.isEmpty ? 0 : 138)
        .opacity(cards.isEmpty ? 0 : 1)
        .animation(.snappy, value: cards)
    }
}

private struct RevealedCardMiniView: View {
    let card: Card
    let isHighlighted: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(card.rarity.displayName)
                .font(.caption2.weight(.black))
                .foregroundStyle(card.rarity.tint)
            Text(card.name)
                .font(.caption.weight(.bold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text("\(card.power)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(width: 92, height: 118)
        .padding(8)
        .background(card.rarity.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(card.rarity.tint.opacity(isHighlighted ? 0.9 : 0.25), lineWidth: isHighlighted ? 2 : 1)
        }
        .scaleEffect(isHighlighted ? 1.06 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isHighlighted)
    }
}

private struct OpeningFooterView: View {
    let stage: OpeningStage
    let onViewResults: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            if stage == .completed {
                Button {
                    onViewResults()
                } label: {
                    Label("View Full Results", systemImage: "rectangle.stack.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            if stage != .idle {
                Button("Reset Pack") {
                    onReset()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal)
    }
}

private extension OpeningStage {
    var title: String {
        switch self {
        case .idle:
            "Hold to charge"
        case .charging:
            "Charging"
        case .readyToTear:
            "Ready to tear"
        case .tearing:
            "Tearing"
        case .opening:
            "Opening"
        case .revealing:
            "Revealing"
        case .completed:
            "Completed"
        }
    }

    var symbolName: String {
        switch self {
        case .idle, .charging, .readyToTear, .tearing:
            "shippingbox.fill"
        case .opening:
            "sparkles"
        case .revealing, .completed:
            "rectangle.stack.fill"
        }
    }

    var tearProgress: CGFloat {
        if case .tearing(let progress) = self {
            progress
        } else if isOpeningOrBeyond {
            1
        } else {
            0
        }
    }

    var isTearing: Bool {
        if case .tearing = self {
            true
        } else {
            false
        }
    }

    var isOpeningOrBeyond: Bool {
        switch self {
        case .opening, .revealing, .completed:
            true
        case .idle, .charging, .readyToTear, .tearing:
            false
        }
    }
}

#Preview("Pack Opening") {
    NavigationStack {
        PackOpeningView(pack: CardPack.dummyPacks[0])
    }
}
