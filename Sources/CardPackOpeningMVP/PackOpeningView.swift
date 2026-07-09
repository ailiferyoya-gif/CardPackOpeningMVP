import SwiftUI

@MainActor
struct PackOpeningView: View {
    let pack: CardPack

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @AppStorage("cardPack.soundEnabled") private var soundEnabled = true

    @State private var stage: OpeningStage = .idle
    @State private var openedCards: [Card] = []
    @State private var revealedCards: [Card] = []
    @State private var showResults = false
    @State private var sequenceTask: Task<Void, Never>?

    @State private var packOpenAmount: CGFloat = 0
    @State private var cardRiseAmount: CGFloat = 0
    @State private var currentFlipDegrees = 0.0
    @State private var isShowingCardFront = false
    @State private var activeRevealEffect: RevealEffect?
    @State private var effectSequence = 0
    @State private var screenFlashOpacity = 0.0

    @State private var audio = PackAudioService()
    @State private var haptics = PackHaptics()

    var body: some View {
        ZStack {
            CelestialBackground()

            GeometryReader { proxy in
                let compact = proxy.size.height < 720 || verticalSizeClass == .compact
                let landscape = verticalSizeClass == .compact && proxy.size.width > 580

                ScrollView {
                    openingContent(compact: compact, landscape: landscape)
                        .frame(maxWidth: 720)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: landscape ? nil : proxy.size.height - 12)
                        .padding(.horizontal, compact ? 14 : 20)
                        .padding(.vertical, compact ? 10 : 18)
                }
                .scrollIndicators(.hidden)
            }

            if isUltimateBuildup {
                UltimateBuildupOverlay(reduceMotion: reduceMotion)
                    .transition(.opacity)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            if let activeRevealEffect {
                RarityRevealLayer(effect: activeRevealEffect, reduceMotion: reduceMotion)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            ScreenFlashView(opacity: screenFlashOpacity)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .navigationTitle("Open Pack")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    soundEnabled.toggle()
                } label: {
                    Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(soundEnabled ? "Mute sound effects" : "Enable sound effects")
            }
        }
        .navigationDestination(isPresented: $showResults) {
            ResultsView(cards: openedCards)
        }
        .task {
            audio.preload()
            haptics.prepare()
        }
        .onChange(of: soundEnabled) { _, enabled in
            if !enabled {
                audio.stopAll()
            } else {
                audio.preload()
            }
        }
        .onDisappear {
            sequenceTask?.cancel()
            audio.stopAll()
        }
    }

    @ViewBuilder
    private func openingContent(compact: Bool, landscape: Bool) -> some View {
        if landscape {
            HStack(alignment: .center, spacing: 18) {
                VStack(spacing: 12) {
                    OpeningHeaderView(pack: pack, stage: stage, compact: true)
                    StageInstructionView(stage: stage, cardCount: openedCardCount)
                    OpeningControls(
                        stage: stage,
                        primaryAction: performPrimaryAction,
                        resetAction: resetOpening
                    )
                }
                .frame(maxWidth: .infinity)

                openingArena(compact: true)
                    .frame(maxWidth: .infinity)
            }
        } else {
            VStack(spacing: compact ? 10 : 16) {
                OpeningHeaderView(pack: pack, stage: stage, compact: compact)
                openingArena(compact: compact)
                StageInstructionView(stage: stage, cardCount: openedCardCount)
                FlippedCardStripView(cards: revealedCards, compact: compact)
                OpeningControls(
                    stage: stage,
                    primaryAction: performPrimaryAction,
                    resetAction: resetOpening
                )
            }
        }
    }

    private func openingArena(compact: Bool) -> some View {
        TearablePackView(
            stage: stage,
            openAmount: packOpenAmount,
            cardRiseAmount: cardRiseAmount,
            activeCard: activeCard,
            flipDegrees: currentFlipDegrees,
            isFaceUp: isShowingCardFront,
            compact: compact,
            reduceMotion: reduceMotion,
            onFlip: flipCurrentCard
        )
        .frame(width: compact ? 184 : 232, height: compact ? 258 : 326)
        .frame(maxWidth: .infinity)
        .onLongPressGesture(
            minimumDuration: reduceMotion ? 0.35 : 0.7,
            maximumDistance: 28,
            perform: handleChargeCompleted,
            onPressingChanged: handlePressingChanged
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 8)
                .onChanged { value in
                    handleDragChanged(value.translation.width)
                }
                .onEnded { value in
                    handleDragEnded(value.translation.width)
                }
        )
        .accessibilityAction(named: Text(stage.primaryActionTitle)) {
            performPrimaryAction()
        }
    }

    private var openedCardCount: Int {
        openedCards.isEmpty ? max(pack.cardsPerOpening, 0) : openedCards.count
    }

    private var activeCard: Card? {
        switch stage {
        case .opening:
            openedCards.first
        case .revealing(let index, _):
            openedCards[safe: index]
        case .completed:
            openedCards.last
        case .idle, .charging, .readyToTear, .tearing:
            nil
        }
    }

    private var isUltimateBuildup: Bool {
        guard activeCard?.rarity == .ultimateRare,
              case .revealing(_, .buildup) = stage else {
            return false
        }
        return true
    }

    private func handlePressingChanged(_ isPressing: Bool) {
        if isPressing, stage == .idle {
            withAnimation(reduceMotion ? .linear(duration: 0.01) : .easeOut(duration: 0.18)) {
                stage = .charging
            }
            audio.play(.charge, enabled: soundEnabled)
            haptics.chargingStarted()
        } else if !isPressing, stage == .charging {
            audio.stop(.charge)
            withAnimation(.easeOut(duration: 0.12)) {
                stage = .idle
            }
        }
    }

    private func handleChargeCompleted() {
        guard stage == .charging || stage == .idle else { return }
        audio.stop(.charge)
        audio.play(.ready, enabled: soundEnabled)
        haptics.packReady()

        withAnimation(reduceMotion ? .linear(duration: 0.01) : .spring(response: 0.3, dampingFraction: 0.72)) {
            stage = .readyToTear
        }
    }

    private func handleDragChanged(_ horizontalTranslation: CGFloat) {
        guard stage == .readyToTear || stage.isTearing else { return }

        let progress = min(max(horizontalTranslation / 170, 0), 1)
        if stage == .readyToTear, progress <= 0.02 {
            return
        }

        if stage == .readyToTear, progress > 0.02 {
            audio.play(.tear, enabled: soundEnabled)
            haptics.tearStarted()
        }

        stage = .tearing(progress: progress)
        if progress >= 1 {
            beginOpeningSequence()
        }
    }

    private func handleDragEnded(_ horizontalTranslation: CGFloat) {
        guard stage.isTearing else { return }

        let progress = min(max(horizontalTranslation / 170, 0), 1)
        if progress >= 0.72 {
            beginOpeningSequence()
        } else {
            withAnimation(reduceMotion ? .linear(duration: 0.01) : .spring(response: 0.28, dampingFraction: 0.7)) {
                stage = .readyToTear
            }
        }
    }

    private func beginOpeningSequence() {
        guard !stage.isOpeningOrBeyond else { return }
        audio.stop(.tear)

        let guaranteedCards = pack.guaranteedShowcaseCards
        let openingCards = guaranteedCards.count == CardRarity.allCases.count
            ? guaranteedCards
            : Array(pack.cards.prefix(max(0, pack.cardsPerOpening)))
        guard !openingCards.isEmpty else {
            stage = .idle
            return
        }

        openedCards = openingCards
        revealedCards = []
        packOpenAmount = 0
        cardRiseAmount = 0
        currentFlipDegrees = 0
        isShowingCardFront = false
        activeRevealEffect = nil
        screenFlashOpacity = 0
        stage = .opening

        audio.play(.whoosh, enabled: soundEnabled)
        haptics.wrapperOpened()

        sequenceTask?.cancel()
        sequenceTask = Task {
            await runOpeningSequence()
        }
    }

    @MainActor
    private func runOpeningSequence() async {
        withAnimation(reduceMotion ? .linear(duration: 0.08) : .spring(response: 0.48, dampingFraction: 0.72)) {
            packOpenAmount = 1
        }

        guard await pause(milliseconds: reduceMotion ? 90 : 430) else { return }

        withAnimation(reduceMotion ? .linear(duration: 0.08) : .spring(response: 0.48, dampingFraction: 0.76)) {
            cardRiseAmount = 1
        }

        guard await pause(milliseconds: reduceMotion ? 100 : 470), !openedCards.isEmpty else { return }
        stage = .revealing(index: 0, phase: .waiting)
    }

    private func flipCurrentCard() {
        guard case .revealing(let index, .waiting) = stage,
              let card = openedCards[safe: index] else {
            return
        }

        sequenceTask?.cancel()
        sequenceTask = Task {
            await runFlipSequence(card: card, index: index)
        }
    }

    @MainActor
    private func runFlipSequence(card: Card, index: Int) async {
        let buildupMilliseconds = card.rarity.buildupMilliseconds(reduceMotion: reduceMotion)
        if buildupMilliseconds > 0 {
            withAnimation(.easeInOut(duration: reduceMotion ? 0.01 : 0.2)) {
                stage = .revealing(index: index, phase: .buildup)
            }
            guard await pause(milliseconds: buildupMilliseconds) else { return }
        }

        audio.play(.whoosh, enabled: soundEnabled)
        stage = .revealing(index: index, phase: .flippingToEdge)
        let halfDuration = card.rarity.flipHalfDuration(reduceMotion: reduceMotion)
        withAnimation(.easeIn(duration: halfDuration)) {
            currentFlipDegrees = 90
        }

        guard await pause(milliseconds: Int(halfDuration * 1_000)) else { return }

        var midpointTransaction = Transaction()
        midpointTransaction.disablesAnimations = true
        withTransaction(midpointTransaction) {
            isShowingCardFront = true
            stage = .revealing(index: index, phase: .flippingToFace)
        }

        // This is the only reveal-effect trigger: exactly at the 90-degree midpoint.
        triggerMidpointReveal(for: card)

        withAnimation(.easeOut(duration: halfDuration)) {
            currentFlipDegrees = 180
        }

        guard await pause(milliseconds: Int(halfDuration * 1_000) + 40) else { return }
        stage = .revealing(index: index, phase: .resting)

        guard await pause(milliseconds: card.rarity.faceHoldMilliseconds(reduceMotion: reduceMotion)) else { return }
        if !revealedCards.contains(where: { $0.id == card.id }) {
            revealedCards.append(card)
        }

        let nextIndex = index + 1
        if openedCards.indices.contains(nextIndex) {
            activeRevealEffect = nil

            var resetTransaction = Transaction()
            resetTransaction.disablesAnimations = true
            withTransaction(resetTransaction) {
                currentFlipDegrees = 0
                isShowingCardFront = false
                stage = .revealing(index: nextIndex, phase: .waiting)
            }
        } else {
            // Keep the final card on screen. Results are opened only by the explicit button.
            stage = .completed
        }
    }

    private func triggerMidpointReveal(for card: Card) {
        effectSequence += 1
        activeRevealEffect = RevealEffect(id: effectSequence, rarity: card.rarity)
        audio.play(.reveal(for: card.rarity), enabled: soundEnabled)
        haptics.reveal(card.rarity)

        if card.rarity.flashOpacity > 0, !reduceMotion {
            flashScreen(opacity: card.rarity.flashOpacity)
        }
    }

    private func flashScreen(opacity: Double) {
        var flashTransaction = Transaction()
        flashTransaction.disablesAnimations = true
        withTransaction(flashTransaction) {
            screenFlashOpacity = opacity
        }

        withAnimation(.easeOut(duration: 0.42)) {
            screenFlashOpacity = 0
        }
    }

    private func performPrimaryAction() {
        switch stage {
        case .idle, .charging:
            handleChargeCompleted()
        case .readyToTear, .tearing:
            beginOpeningSequence()
        case .revealing(_, .waiting):
            flipCurrentCard()
        case .completed:
            showResults = true
        case .opening, .revealing:
            break
        }
    }

    private func resetOpening() {
        sequenceTask?.cancel()
        audio.stopAll()
        openedCards = []
        revealedCards = []
        showResults = false
        packOpenAmount = 0
        cardRiseAmount = 0
        currentFlipDegrees = 0
        isShowingCardFront = false
        activeRevealEffect = nil
        screenFlashOpacity = 0
        stage = .idle
    }

    private func pause(milliseconds: Int) async -> Bool {
        do {
            try await Task.sleep(nanoseconds: UInt64(max(milliseconds, 0)) * 1_000_000)
            return !Task.isCancelled
        } catch {
            return false
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview("Pack Opening") {
    NavigationStack {
        PackOpeningView(pack: CardPack.showcasePack)
    }
}
