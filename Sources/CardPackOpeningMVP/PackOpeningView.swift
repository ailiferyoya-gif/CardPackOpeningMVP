import SpriteKit
import SwiftUI
import UIKit

struct PackOpeningView: View {
    let pack: CardPack

    @State private var stage: OpeningStage = .idle
    @State private var openedCards: [Card] = []
    @State private var flippedCards: [Card] = []
    @State private var showResults = false
    @State private var sequenceTask: Task<Void, Never>?
    @State private var packOpenAmount: CGFloat = 0
    @State private var cardRiseAmount: CGFloat = 0
    @State private var currentFlipDegrees = 0.0
    @State private var currentCardFaceUp = false
    @State private var isFlipping = false
    @State private var activeRarity: CardRarity?
    @State private var effectID = 0
    @State private var screenFlashOpacity = 0.0

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                Spacer(minLength: 10)

                OpeningHeaderView(pack: pack, stage: stage)

                ZStack {
                    if let activeRarity {
                        RarityParticleLayer(rarity: activeRarity, trigger: effectID)
                            .allowsHitTesting(false)
                    }

                    TearablePackView(
                        stage: stage,
                        openAmount: packOpenAmount,
                        cardRiseAmount: cardRiseAmount,
                        activeCard: activeCard,
                        flipDegrees: currentFlipDegrees,
                        isFaceUp: currentCardFaceUp,
                        onFlip: flipCurrentCard
                    )
                    .frame(width: 220, height: 300)
                    .onLongPressGesture(minimumDuration: 0.75, maximumDistance: 28) {
                        handleChargeCompleted()
                    } onPressingChanged: { isPressing in
                        handlePressingChanged(isPressing)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 8)
                            .onChanged { value in
                                handleDragChanged(value.translation.width)
                            }
                            .onEnded { value in
                                handleDragEnded(value.translation.width)
                            }
                    )
                }
                .frame(height: 318)

                StageInstructionView(stage: stage, cardsPerOpening: pack.cardsPerOpening)

                FlippedCardStackView(cards: flippedCards)

                OpeningFooterView(stage: stage) {
                    resetOpening()
                }

                Spacer(minLength: 8)
            }
            .navigationTitle("Open Pack")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showResults) {
                ResultsView(cards: openedCards)
            }
            .onDisappear {
                sequenceTask?.cancel()
            }

            ScreenFlashView(opacity: screenFlashOpacity)
                .allowsHitTesting(false)
        }
    }

    private var activeRevealIndex: Int? {
        if case .revealing(let index) = stage {
            index
        } else {
            nil
        }
    }

    private var activeCard: Card? {
        if let activeRevealIndex {
            openedCards[safe: activeRevealIndex]
        } else if stage == .opening {
            openedCards.first
        } else {
            nil
        }
    }

    private func handlePressingChanged(_ isPressing: Bool) {
        if isPressing {
            if stage == .idle {
                withAnimation(.easeOut(duration: 0.18)) {
                    stage = .charging
                }
            }
        } else if stage == .charging {
            withAnimation(.easeOut(duration: 0.16)) {
                stage = .idle
            }
        }
    }

    private func handleChargeCompleted() {
        if stage == .charging || stage == .idle {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                stage = .readyToTear
            }
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
            withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                stage = .readyToTear
            }
        }
    }

    private func beginOpeningSequence() {
        guard !stage.isOpeningOrBeyond else {
            return
        }

        openedCards = Array(pack.cards.shuffled().prefix(pack.cardsPerOpening))
        flippedCards = []
        activeRarity = nil
        currentFlipDegrees = 0
        currentCardFaceUp = false
        isFlipping = false
        stage = .opening
        sequenceTask?.cancel()
        sequenceTask = Task {
            await runOpeningSequence()
        }
    }

    @MainActor
    private func runOpeningSequence() async {
        withAnimation(.spring(response: 0.48, dampingFraction: 0.74)) {
            packOpenAmount = 1
        }

        try? await Task.sleep(for: .milliseconds(420))
        guard !Task.isCancelled else {
            return
        }

        withAnimation(.spring(response: 0.48, dampingFraction: 0.76)) {
            cardRiseAmount = 1
        }

        try? await Task.sleep(for: .milliseconds(460))
        guard !Task.isCancelled else {
            return
        }

        stage = .revealing(index: 0)
        triggerRarityEffect(for: openedCards.first?.rarity)
    }

    private func flipCurrentCard() {
        guard let index = activeRevealIndex,
              let card = openedCards[safe: index],
              !isFlipping,
              !currentCardFaceUp else {
            return
        }

        isFlipping = true
        sequenceTask?.cancel()
        sequenceTask = Task {
            await runFlipSequence(card: card, index: index)
        }
    }

    @MainActor
    private func runFlipSequence(card: Card, index: Int) async {
        try? await Task.sleep(for: .milliseconds(card.rarity.flipHoldMilliseconds))
        guard !Task.isCancelled else {
            return
        }

        if card.rarity == .ultraRare {
            flashScreen(opacity: card.rarity.flashOpacity)
            try? await Task.sleep(for: .milliseconds(90))
        }

        withAnimation(.easeInOut(duration: card.rarity.flipDuration)) {
            currentFlipDegrees = 180
            currentCardFaceUp = true
        }

        try? await Task.sleep(for: .milliseconds(Int(card.rarity.flipDuration * 1000) + 120))
        guard !Task.isCancelled else {
            return
        }

        flippedCards.append(card)

        try? await Task.sleep(for: .milliseconds(220))
        guard !Task.isCancelled else {
            return
        }

        let nextIndex = index + 1
        if openedCards.indices.contains(nextIndex) {
            currentFlipDegrees = 0
            currentCardFaceUp = false
            isFlipping = false
            stage = .revealing(index: nextIndex)
            triggerRarityEffect(for: openedCards[nextIndex].rarity)
        } else {
            stage = .completed
            try? await Task.sleep(for: .milliseconds(520))
            guard !Task.isCancelled else {
                return
            }
            showResults = true
        }
    }

    private func triggerRarityEffect(for rarity: CardRarity?) {
        guard let rarity else {
            return
        }

        activeRarity = rarity
        effectID += 1

        if rarity.flashOpacity > 0 {
            flashScreen(opacity: rarity.flashOpacity)
        }
    }

    private func flashScreen(opacity: Double) {
        screenFlashOpacity = opacity
        withAnimation(.easeOut(duration: 0.34)) {
            screenFlashOpacity = 0
        }
    }

    private func resetOpening() {
        sequenceTask?.cancel()
        openedCards = []
        flippedCards = []
        showResults = false
        activeRarity = nil
        packOpenAmount = 0
        cardRiseAmount = 0
        currentFlipDegrees = 0
        currentCardFaceUp = false
        isFlipping = false
        screenFlashOpacity = 0
        stage = .idle
    }
}

private struct OpeningHeaderView: View {
    let pack: CardPack
    let stage: OpeningStage

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: stage.symbolName)
                .font(.system(size: 42))
                .foregroundStyle(stage.headerTint)

            Text(pack.name)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

private struct TearablePackView: View {
    let stage: OpeningStage
    let openAmount: CGFloat
    let cardRiseAmount: CGFloat
    let activeCard: Card?
    let flipDegrees: Double
    let isFaceUp: Bool
    let onFlip: () -> Void

    var body: some View {
        ZStack {
            if let activeCard {
                FlipCardView(
                    card: activeCard,
                    flipDegrees: flipDegrees,
                    isFaceUp: isFaceUp,
                    isInteractive: stage.isRevealing,
                    riseAmount: cardRiseAmount,
                    onFlip: onFlip
                )
                .zIndex(1)
            }

            SplitPackShell(
                progress: stage.tearProgress,
                isReady: stage == .readyToTear,
                openAmount: openAmount
            )
            .opacity(stage == .completed ? 0 : 1)
            .zIndex(2)
        }
        .accessibilityLabel(stage.accessibilityLabel)
    }
}

private struct SplitPackShell: View {
    let progress: CGFloat
    let isReady: Bool
    let openAmount: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let wiggle = sin(Double(progress) * .pi * 6) * 3
            let tilt = Double(progress) * 5 + wiggle

            ZStack {
                PackHalf(side: .left, progress: progress, isReady: isReady, openAmount: openAmount)
                PackHalf(side: .right, progress: progress, isReady: isReady, openAmount: openAmount)

                PerforationCanvas(progress: progress, isReady: isReady)
                    .frame(height: 34)
                    .padding(.horizontal, 24)
                    .offset(y: -proxy.size.height * 0.34)
                    .opacity(openAmount < 0.92 ? 1 : 0)
            }
            .rotationEffect(.degrees(tilt))
            .offset(x: CGFloat(wiggle) * 0.8, y: progress * 3)
            .animation(.spring(response: 0.22, dampingFraction: 0.68), value: progress)
            .animation(.spring(response: 0.46, dampingFraction: 0.72), value: openAmount)
        }
    }
}

private enum PackSide {
    case left
    case right
}

private struct PackHalf: View {
    let side: PackSide
    let progress: CGFloat
    let isReady: Bool
    let openAmount: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let halfWidth = proxy.size.width / 2 + 4
            PackSurface(progress: progress, isReady: isReady)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .mask(alignment: side == .left ? .leading : .trailing) {
                    Rectangle()
                        .frame(width: halfWidth)
                }
                .offset(x: side == .left ? -openAmount * 58 : openAmount * 58)
                .rotation3DEffect(
                    .degrees(side == .left ? -Double(openAmount) * 34 : Double(openAmount) * 34),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.62
                )
                .scaleEffect(x: 1 + progress * 0.018, y: 1 - progress * 0.016)
        }
    }
}

private struct PackSurface: View {
    let progress: CGFloat
    let isReady: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.22, green: 0.18, blue: 0.78),
                        Color(red: 0.05, green: 0.58, blue: 0.68),
                        Color(red: 0.96, green: 0.62, blue: 0.22)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(isReady ? 0.78 : 0.42), lineWidth: isReady ? 3 : 1.5)
                    .padding(9)
            }
            .overlay {
                PackSurfacePattern()
                    .opacity(0.18 + progress * 0.12)
                    .mask(RoundedRectangle(cornerRadius: 18))
            }
            .shadow(color: .indigo.opacity(isReady ? 0.46 : 0.24), radius: isReady ? 22 : 14, x: 0, y: 14)
    }
}

private struct PackSurfacePattern: View {
    var body: some View {
        Canvas { context, size in
            for index in 0..<9 {
                let y = CGFloat(index) * size.height / 8
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y + 18))
                context.stroke(path, with: .color(.white), lineWidth: 1)
            }
        }
    }
}

private struct PerforationCanvas: View {
    let progress: CGFloat
    let isReady: Bool

    var body: some View {
        Canvas { context, size in
            let baselineY = size.height / 2
            let startX: CGFloat = 6
            let endX = size.width - 6

            var perforation = Path()
            perforation.move(to: CGPoint(x: startX, y: baselineY))
            perforation.addLine(to: CGPoint(x: endX, y: baselineY))

            context.stroke(
                perforation,
                with: .color(.white.opacity(isReady ? 0.95 : 0.58)),
                style: StrokeStyle(lineWidth: isReady ? 3 : 2, lineCap: .round, dash: [7, 6])
            )

            let tearEnd = startX + (endX - startX) * progress
            if progress > 0 {
                var tear = Path()
                tear.move(to: CGPoint(x: startX, y: baselineY))
                let segmentCount = 14
                for step in 1...segmentCount {
                    let t = CGFloat(step) / CGFloat(segmentCount)
                    let x = startX + (tearEnd - startX) * t
                    let y = baselineY + (step.isMultiple(of: 2) ? -5 : 5)
                    tear.addLine(to: CGPoint(x: x, y: y))
                }

                context.stroke(
                    tear,
                    with: .color(.white),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .shadow(color: .white.opacity(isReady ? 0.86 : 0.1), radius: isReady ? 10 : 0)
    }
}

private struct FlipCardView: View {
    let card: Card
    let flipDegrees: Double
    let isFaceUp: Bool
    let isInteractive: Bool
    let riseAmount: CGFloat
    let onFlip: () -> Void

    var body: some View {
        ZStack {
            CardBackFace()
                .opacity(flipDegrees < 90 ? 1 : 0)

            CardFrontFace(card: card)
                .opacity(flipDegrees >= 90 ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: 138, height: 196)
        .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0), perspective: 0.72)
        .offset(y: (1 - riseAmount) * 105)
        .scaleEffect(isFaceUp ? 1.02 : 0.98 + riseAmount * 0.02)
        .shadow(color: card.rarity.glowColor.opacity(isFaceUp ? 0.44 : 0.18), radius: isFaceUp ? 22 : 12, x: 0, y: 12)
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .onTapGesture {
            if isInteractive {
                onFlip()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 14)
                .onEnded { value in
                    if isInteractive && value.translation.height < -24 {
                        onFlip()
                    }
                }
        )
        .accessibilityLabel(isFaceUp ? "\(card.name), \(card.rarity.displayName)" : "Card back. Tap or swipe up to reveal.")
    }
}

private struct CardBackFace: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.12, blue: 0.28), Color(red: 0.2, green: 0.34, blue: 0.78)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(0.68), lineWidth: 2)
                    .padding(9)
            }
            .overlay {
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(.white.opacity(0.84))
            }
    }
}

private struct CardFrontFace: View {
    let card: Card

    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(card.rarity.frontGradient)
            .overlay(alignment: .topLeading) {
                Text(card.rarity.displayName)
                    .font(.caption2.weight(.black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.78), in: Capsule())
                    .foregroundStyle(card.rarity.textColor)
                    .padding(10)
            }
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: card.rarity.symbolName)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(card.rarity.textColor)
                    Text(card.name)
                        .font(.headline.weight(.black))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                    Text("\(card.power)")
                        .font(.title3.weight(.black))
                        .foregroundStyle(card.rarity.textColor)
                }
                .padding(14)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(card.rarity.glowColor.opacity(0.88), lineWidth: 2)
            }
    }
}

private struct FlippedCardStackView: View {
    let cards: [Card]

    var body: some View {
        ZStack {
            ForEach(Array(cards.suffix(5).enumerated()), id: \.element.id) { offset, card in
                MiniStackCard(card: card)
                    .offset(x: CGFloat(offset) * 18 - CGFloat(cards.suffix(5).count - 1) * 9, y: CGFloat(offset) * -2)
                    .zIndex(Double(offset))
            }
        }
        .frame(height: cards.isEmpty ? 0 : 86)
        .opacity(cards.isEmpty ? 0 : 1)
        .animation(.snappy, value: cards)
    }
}

private struct MiniStackCard: View {
    let card: Card

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(card.rarity.frontGradient)
            .overlay {
                VStack(spacing: 3) {
                    Image(systemName: card.rarity.symbolName)
                    Text(card.name)
                        .font(.caption2.weight(.bold))
                        .lineLimit(1)
                }
                .foregroundStyle(card.rarity.textColor)
                .padding(5)
            }
            .frame(width: 58, height: 78)
            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
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
        .frame(minHeight: 62)
        .padding(.horizontal, 24)
    }

    private var message: String {
        switch stage {
        case .idle:
            "Long press the pack to build energy."
        case .charging:
            "Keep holding until the perforation glows."
        case .readyToTear:
            "Swipe right across the glowing seam to tear it open."
        case .tearing(let progress):
            "Tearing \(Int(progress * 100))%. Keep pulling right."
        case .opening:
            "The wrapper is opening and a card back is rising."
        case .revealing(let index):
            "Tap or swipe up to flip card \(index + 1) of \(cardsPerOpening)."
        case .completed:
            "All cards are flipped. Moving to results."
        }
    }
}

private struct OpeningFooterView: View {
    let stage: OpeningStage
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 8) {
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

private struct RarityParticleLayer: View {
    let rarity: CardRarity
    let trigger: Int

    var body: some View {
        SpriteView(
            scene: RarityParticleScene(rarity: rarity),
            options: [.allowsTransparency]
        )
        .id(trigger)
        .frame(width: 320, height: 360)
        .opacity(rarity.particleOpacity)
    }
}

private final class RarityParticleScene: SKScene {
    private let rarity: CardRarity

    init(rarity: CardRarity) {
        self.rarity = rarity
        super.init(size: CGSize(width: 320, height: 360))
        scaleMode = .resizeFill
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        view.allowsTransparency = true
        view.backgroundColor = .clear

        addEmitter(
            color: rarity.particleColor,
            birthRate: rarity.particleBirthRate,
            count: rarity.particleCount,
            speed: rarity.particleSpeed,
            lifetime: rarity.particleLifetime,
            scale: rarity.particleScale
        )

        if rarity == .ultraRare {
            addRainbowAura()
            addShockwave()
        } else if rarity == .superRare {
            addFlashBurst(color: .systemYellow)
        }
    }

    private func addEmitter(
        color: SKColor,
        birthRate: CGFloat,
        count: Int,
        speed: CGFloat,
        lifetime: CGFloat,
        scale: CGFloat
    ) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(image: particleImage(color: color))
        emitter.particleBirthRate = birthRate
        emitter.numParticlesToEmit = count
        emitter.particleLifetime = lifetime
        emitter.particleLifetimeRange = lifetime * 0.3
        emitter.particleSpeed = speed
        emitter.particleSpeedRange = speed * 0.55
        emitter.emissionAngleRange = .pi * 2
        emitter.particleAlpha = 0.95
        emitter.particleAlphaSpeed = -0.9 / lifetime
        emitter.particleScale = scale
        emitter.particleScaleRange = scale * 0.45
        emitter.position = CGPoint(x: size.width / 2, y: size.height / 2 + 18)
        emitter.particlePositionRange = CGVector(dx: 54, dy: 42)
        addChild(emitter)
    }

    private func addFlashBurst(color: SKColor) {
        let node = SKShapeNode(circleOfRadius: 64)
        node.position = CGPoint(x: size.width / 2, y: size.height / 2 + 24)
        node.fillColor = color.withAlphaComponent(0.28)
        node.strokeColor = color.withAlphaComponent(0.46)
        node.lineWidth = 2
        node.run(.sequence([
            .group([.scale(to: 2.2, duration: 0.34), .fadeOut(withDuration: 0.34)]),
            .removeFromParent()
        ]))
        addChild(node)
    }

    private func addShockwave() {
        let ring = SKShapeNode(circleOfRadius: 42)
        ring.position = CGPoint(x: size.width / 2, y: size.height / 2 + 18)
        ring.fillColor = .clear
        ring.strokeColor = .white.withAlphaComponent(0.86)
        ring.lineWidth = 5
        ring.run(.sequence([
            .group([.scale(to: 4.0, duration: 0.48), .fadeOut(withDuration: 0.48)]),
            .removeFromParent()
        ]))
        addChild(ring)
    }

    private func addRainbowAura() {
        let colors: [SKColor] = [.systemPink, .systemYellow, .systemGreen, .systemCyan, .systemPurple]
        for (index, color) in colors.enumerated() {
            let ring = SKShapeNode(circleOfRadius: CGFloat(34 + index * 9))
            ring.position = CGPoint(x: size.width / 2, y: size.height / 2 + 18)
            ring.fillColor = .clear
            ring.strokeColor = color.withAlphaComponent(0.34)
            ring.lineWidth = 5
            ring.run(.sequence([
                .group([.scale(to: 2.0 + CGFloat(index) * 0.12, duration: 0.62), .fadeOut(withDuration: 0.62)]),
                .removeFromParent()
            ]))
            addChild(ring)
        }
    }

    private func particleImage(color: SKColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 1, y: 1, width: 8, height: 8))
        }
    }
}

private struct ScreenFlashView: View {
    let opacity: Double

    var body: some View {
        Rectangle()
            .fill(.white.opacity(opacity))
            .ignoresSafeArea()
    }
}

private extension CardRarity {
    var glowColor: Color {
        switch self {
        case .common:
            .white
        case .rare:
            .blue
        case .superRare:
            .yellow
        case .ultraRare:
            .pink
        }
    }

    var frontGradient: LinearGradient {
        switch self {
        case .common:
            LinearGradient(colors: [.white, .gray.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rare:
            LinearGradient(colors: [.cyan.opacity(0.35), .blue.opacity(0.25), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .superRare:
            LinearGradient(colors: [.yellow.opacity(0.55), .orange.opacity(0.28), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ultraRare:
            LinearGradient(colors: [.pink.opacity(0.42), .yellow.opacity(0.32), .cyan.opacity(0.36), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var textColor: Color {
        switch self {
        case .common:
            .gray
        case .rare:
            .blue
        case .superRare:
            .orange
        case .ultraRare:
            .purple
        }
    }

    var symbolName: String {
        switch self {
        case .common:
            "circle.fill"
        case .rare:
            "diamond.fill"
        case .superRare:
            "star.fill"
        case .ultraRare:
            "sparkles"
        }
    }

    var flipHoldMilliseconds: Int {
        switch self {
        case .common:
            80
        case .rare:
            160
        case .superRare:
            280
        case .ultraRare:
            460
        }
    }

    var flipDuration: Double {
        switch self {
        case .common:
            0.42
        case .rare:
            0.5
        case .superRare:
            0.58
        case .ultraRare:
            0.68
        }
    }

    var flashOpacity: Double {
        switch self {
        case .common:
            0
        case .rare:
            0
        case .superRare:
            0.32
        case .ultraRare:
            0.78
        }
    }

    var particleColor: SKColor {
        switch self {
        case .common:
            .white
        case .rare:
            .systemBlue
        case .superRare:
            .systemYellow
        case .ultraRare:
            .systemPink
        }
    }

    var particleCount: Int {
        switch self {
        case .common:
            20
        case .rare:
            38
        case .superRare:
            70
        case .ultraRare:
            96
        }
    }

    var particleBirthRate: CGFloat {
        switch self {
        case .common:
            70
        case .rare:
            120
        case .superRare:
            190
        case .ultraRare:
            240
        }
    }

    var particleSpeed: CGFloat {
        switch self {
        case .common:
            42
        case .rare:
            64
        case .superRare:
            92
        case .ultraRare:
            118
        }
    }

    var particleLifetime: CGFloat {
        switch self {
        case .common:
            0.44
        case .rare:
            0.7
        case .superRare:
            0.88
        case .ultraRare:
            1.08
        }
    }

    var particleScale: CGFloat {
        switch self {
        case .common:
            0.12
        case .rare:
            0.16
        case .superRare:
            0.2
        case .ultraRare:
            0.22
        }
    }

    var particleOpacity: Double {
        switch self {
        case .common:
            0.55
        case .rare:
            0.72
        case .superRare:
            0.88
        case .ultraRare:
            1
        }
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
            "Reveal the card"
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

    var headerTint: Color {
        switch self {
        case .readyToTear, .tearing:
            .orange
        case .opening, .revealing:
            .indigo
        case .completed:
            .green
        case .idle, .charging:
            .teal
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

    var isRevealing: Bool {
        if case .revealing = self {
            true
        } else {
            false
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .idle:
            "Unopened card pack. Long press to charge."
        case .charging:
            "Charging the pack."
        case .readyToTear:
            "Pack is ready. Swipe right to tear."
        case .tearing(let progress):
            "Tearing progress \(Int(progress * 100)) percent."
        case .opening:
            "Pack is opening and a card back is rising."
        case .revealing(let index):
            "Card \(index + 1) is ready to flip."
        case .completed:
            "All cards are revealed."
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
        PackOpeningView(pack: CardPack.dummyPacks[0])
    }
}
