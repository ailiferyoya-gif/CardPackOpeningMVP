import SwiftUI

struct OpeningHeaderView: View {
    let pack: CardPack
    let stage: OpeningStage
    let compact: Bool

    var body: some View {
        VStack(spacing: compact ? 6 : 9) {
            HStack(spacing: 7) {
                Image(systemName: stage.symbolName)
                Text(stage.title.uppercased())
            }
            .font(.caption.weight(.black))
            .tracking(1.2)
            .foregroundStyle(stage.headerTint)

            Text(pack.name)
                .font(compact ? .title2.weight(.black) : .largeTitle.weight(.black))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            RevealProgressView(stage: stage)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct RevealProgressView: View {
    let stage: OpeningStage

    var body: some View {
        HStack(spacing: 7) {
            ForEach(Array(CardRarity.allCases.enumerated()), id: \.element.id) { index, rarity in
                HStack(spacing: 4) {
                    Image(systemName: rarity.symbolName)
                    Text(rarity.shortName)
                }
                .font(.caption2.weight(.black))
                .foregroundStyle(foreground(for: index, rarity: rarity))
                .padding(.horizontal, 7)
                .frame(minHeight: 28)
                .background(background(for: index, rarity: rarity), in: Capsule())
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Five rarity showcase progress. \(stage.progressAccessibilityLabel)")
    }

    private func foreground(for index: Int, rarity: CardRarity) -> Color {
        if index <= stage.lastReachedCardIndex {
            rarity.tint
        } else {
            .white.opacity(0.46)
        }
    }

    private func background(for index: Int, rarity: CardRarity) -> Color {
        if index == stage.activeCardIndex {
            rarity.tint.opacity(0.24)
        } else {
            .white.opacity(index < stage.activeCardIndex ? 0.1 : 0.055)
        }
    }
}

struct StageInstructionView: View {
    let stage: OpeningStage
    let cardCount: Int

    var body: some View {
        VStack(spacing: 5) {
            Text(stage.instructionTitle)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Text(stage.instructionMessage(cardCount: cardCount))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 520, minHeight: 62)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

struct OpeningControls: View {
    let stage: OpeningStage
    let primaryAction: () -> Void
    let resetAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: primaryAction) {
                Label(stage.primaryActionTitle, systemImage: stage.primaryActionSymbol)
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.plain)
            .foregroundStyle(stage.primaryActionEnabled ? Color.black : Color.white.opacity(0.52))
            .background(
                stage.primaryActionEnabled ? Color.packGoldBright : Color.white.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .disabled(!stage.primaryActionEnabled)
            .accessibilityHint(stage.primaryActionHint)

            if stage != .idle {
                Button(action: resetAction) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline.weight(.bold))
                        .frame(width: 52, height: 52)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                }
                .accessibilityLabel("Reset pack")
            }
        }
        .frame(maxWidth: 520)
    }
}

struct FlippedCardStripView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let cards: [Card]
    let compact: Bool

    var body: some View {
        HStack(spacing: compact ? -5 : 4) {
            ForEach(cards) { card in
                MiniCardView(card: card, compact: compact)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(height: cards.isEmpty ? 0 : (compact ? 48 : 58))
        .opacity(cards.isEmpty ? 0 : 1)
        .animation(reduceMotion ? nil : .snappy, value: cards)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(cards.isEmpty ? "No revealed cards" : "\(cards.count) cards revealed")
    }
}

private struct MiniCardView: View {
    let card: Card
    let compact: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(card.rarity.cardGradient)

            Image(card.artAssetName, bundle: .module)
                .resizable()
                .scaledToFit()
                .padding(3)
        }
        .frame(width: compact ? 34 : 42, height: compact ? 46 : 56)
        .overlay {
            RoundedRectangle(cornerRadius: 7)
                .stroke(card.rarity.tint.opacity(0.9), lineWidth: 1)
        }
        .shadow(color: card.rarity.tint.opacity(0.3), radius: 5, y: 3)
        .accessibilityLabel("\(card.name), \(card.rarity.displayName)")
    }
}

struct TearablePackView: View {
    let stage: OpeningStage
    let openAmount: CGFloat
    let cardRiseAmount: CGFloat
    let activeCard: Card?
    let flipDegrees: Double
    let isFaceUp: Bool
    let compact: Bool
    let reduceMotion: Bool
    let onFlip: () -> Void

    var body: some View {
        ZStack {
            if let activeCard {
                FlipCardView(
                    card: activeCard,
                    flipDegrees: flipDegrees,
                    isFaceUp: isFaceUp,
                    isInteractive: stage.isWaitingForReveal,
                    riseAmount: cardRiseAmount,
                    compact: compact,
                    onFlip: onFlip
                )
                .id(activeCard.id)
                .zIndex(1)
            }

            SplitPackShell(
                progress: stage.tearProgress,
                isReady: stage == .readyToTear,
                openAmount: openAmount,
                reduceMotion: reduceMotion
            )
            .opacity(stage == .completed ? 0 : 1)
            .zIndex(2)
        }
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stage.accessibilityLabel)
        .accessibilityHint(stage.primaryActionHint)
    }
}

private struct FlipCardView: View {
    let card: Card
    let flipDegrees: Double
    let isFaceUp: Bool
    let isInteractive: Bool
    let riseAmount: CGFloat
    let compact: Bool
    let onFlip: () -> Void

    var body: some View {
        ZStack {
            CardBackFace()
                .opacity(isFaceUp ? 0 : 1)

            CardFrontFace(card: card)
                .opacity(isFaceUp ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: compact ? 142 : 164, height: compact ? 206 : 238)
        .rotation3DEffect(
            .degrees(flipDegrees),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.72
        )
        .offset(y: (1 - riseAmount) * (compact ? 76 : 102))
        .scaleEffect(isFaceUp ? 1.025 : 0.98 + riseAmount * 0.02)
        .shadow(
            color: card.rarity.tint.opacity(isFaceUp ? 0.55 : 0.18),
            radius: isFaceUp ? 26 : 12,
            y: 12
        )
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .onTapGesture {
            if isInteractive { onFlip() }
        }
        .gesture(
            DragGesture(minimumDistance: 14)
                .onEnded { value in
                    if isInteractive, value.translation.height < -24 {
                        onFlip()
                    }
                }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            isFaceUp
                ? "\(card.name), \(card.rarity.displayName), power \(card.power)"
                : "Face-down card. Rarity hidden until reveal."
        )
        .accessibilityHint(isInteractive ? "Double tap to reveal." : "")
        .accessibilityAction {
            if isInteractive { onFlip() }
        }
    }
}

private struct CardBackFace: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(
                AngularGradient(
                    colors: [.packNavyDeep, .indigo, .packGold, .packNavyDeep, .indigo],
                    center: .center
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.72), lineWidth: 1.5)
                    .padding(7)
            }
            .overlay {
                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.packGoldBright.opacity(0.42 - Double(index) * 0.1), lineWidth: 1.5)
                            .padding(CGFloat(22 + index * 13))
                    }

                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 38, weight: .black))
                        .foregroundStyle(.white)
                }
            }
            .overlay(alignment: .bottom) {
                Text("CELESTIAL RIFT")
                    .font(.caption2.weight(.black))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.78))
                    .padding(.bottom, 15)
            }
    }
}

private struct CardFrontFace: View {
    let card: Card

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(card.rarity.cardGradient)

                VStack(spacing: width * 0.032) {
                    HStack(spacing: 4) {
                        Text(card.name)
                            .font(.system(size: width * 0.078, weight: .black, design: .serif))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.58)

                        Spacer(minLength: 2)

                        Image(systemName: card.rarity.symbolName)
                            .font(.system(size: width * 0.075, weight: .black))
                            .foregroundStyle(card.rarity.tint)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(.black.opacity(0.24))

                        RadialGradient(
                            colors: [card.rarity.tint.opacity(0.34), .clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: width * 0.62
                        )

                        Image(card.artAssetName, bundle: .module)
                            .resizable()
                            .scaledToFit()
                            .padding(width * 0.025)
                    }
                    .frame(height: height * 0.56)
                    .overlay {
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(card.rarity.tint.opacity(0.86), lineWidth: 1.5)
                    }

                    HStack {
                        Text(card.rarity.displayName.uppercased())
                            .font(.system(size: width * 0.054, weight: .black))
                            .foregroundStyle(card.rarity.tint)
                            .lineLimit(1)

                        Spacer(minLength: 2)

                        Text("POWER \(card.power)")
                            .font(.system(size: width * 0.054, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }

                    Text(card.flavorText)
                        .font(.system(size: width * 0.043, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.76))
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(width * 0.065)

                if card.rarity.foilOpacity > 0 {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            AngularGradient(
                                colors: [.clear, .cyan, .yellow, .pink, .clear],
                                center: .center
                            )
                        )
                        .opacity(card.rarity.foilOpacity)
                        .blendMode(.screen)
                        .allowsHitTesting(false)
                }

                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.82), card.rarity.tint, .black.opacity(0.45)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: width * 0.022
                    )
            }
        }
    }
}

private struct SplitPackShell: View {
    let progress: CGFloat
    let isReady: Bool
    let openAmount: CGFloat
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { proxy in
            let wiggle = sin(Double(progress) * .pi * 6) * 3

            ZStack {
                PackHalf(side: .left, progress: progress, isReady: isReady, openAmount: openAmount)
                PackHalf(side: .right, progress: progress, isReady: isReady, openAmount: openAmount)

                PerforationCanvas(progress: progress, isReady: isReady)
                    .frame(height: 34)
                    .padding(.horizontal, 20)
                    .offset(y: -proxy.size.height * 0.34)
                    .opacity(openAmount < 0.92 ? 1 : 0)
            }
            .rotationEffect(.degrees(Double(progress) * 4 + wiggle))
            .offset(x: CGFloat(wiggle) * 0.8, y: progress * 3)
            .animation(reduceMotion ? .linear(duration: 0.01) : .spring(response: 0.22, dampingFraction: 0.68), value: progress)
            .animation(reduceMotion ? .linear(duration: 0.01) : .spring(response: 0.46, dampingFraction: 0.72), value: openAmount)
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
                    Rectangle().frame(width: halfWidth)
                }
                .offset(x: side == .left ? -openAmount * 62 : openAmount * 62)
                .rotation3DEffect(
                    .degrees(side == .left ? -Double(openAmount) * 36 : Double(openAmount) * 36),
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
                    colors: [.packNavyDeep, Color(red: 0.16, green: 0.1, blue: 0.4), .packGold],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(isReady ? 0.9 : 0.5), lineWidth: isReady ? 3 : 1.5)
                    .padding(8)
            }
            .overlay {
                PackSurfacePattern()
                    .opacity(0.18 + progress * 0.13)
                    .mask(RoundedRectangle(cornerRadius: 18))
            }
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 44, weight: .black))
                    Text("CELESTIAL\nRIFT")
                        .font(.headline.weight(.black))
                        .tracking(1.5)
                        .multilineTextAlignment(.center)
                    Text("5 CARD SHOWCASE")
                        .font(.caption2.weight(.black))
                        .tracking(1)
                }
                .foregroundStyle(.white)
            }
            .shadow(
                color: Color.packGold.opacity(isReady ? 0.52 : 0.26),
                radius: isReady ? 24 : 14,
                y: 14
            )
    }
}

private struct PackSurfacePattern: View {
    var body: some View {
        Canvas { context, size in
            for index in 0..<10 {
                let y = CGFloat(index) * size.height / 9
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y + 22))
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
            let baseline = size.height / 2
            var guide = Path()
            guide.move(to: CGPoint(x: 0, y: baseline))
            guide.addLine(to: CGPoint(x: size.width, y: baseline))
            context.stroke(
                guide,
                with: .color(.white.opacity(isReady ? 0.92 : 0.5)),
                style: StrokeStyle(lineWidth: 2, dash: [8, 6])
            )

            if progress > 0 {
                var tear = Path()
                let maxX = size.width * progress
                tear.move(to: CGPoint(x: 0, y: baseline))
                for step in 1...12 {
                    let x = maxX * CGFloat(step) / 12
                    let y = baseline + (step.isMultiple(of: 2) ? -4 : 4)
                    tear.addLine(to: CGPoint(x: x, y: y))
                }
                context.stroke(
                    tear,
                    with: .color(Color.packGoldBright),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .shadow(color: Color.packGoldBright.opacity(isReady ? 0.9 : 0), radius: isReady ? 10 : 0)
    }
}

extension CardRarity {
    var cardGradient: LinearGradient {
        switch self {
        case .normal:
            LinearGradient(colors: [.gray.opacity(0.78), .packNavy], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rare:
            LinearGradient(colors: [.blue.opacity(0.86), .packNavyDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .superRare:
            LinearGradient(colors: [.packGold, Color(red: 0.28, green: 0.12, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ultraRare:
            LinearGradient(colors: [.purple, .pink.opacity(0.82), .packNavyDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ultimateRare:
            LinearGradient(colors: [.black, .indigo, .white.opacity(0.72), .packNavyDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var foilOpacity: Double {
        switch self {
        case .normal: 0
        case .rare: 0.05
        case .superRare: 0.11
        case .ultraRare: 0.18
        case .ultimateRare: 0.26
        }
    }
}

extension OpeningStage {
    var title: String {
        switch self {
        case .idle: "Awaiting pack"
        case .charging: "Charging"
        case .readyToTear: "Seal unlocked"
        case .tearing: "Tearing"
        case .opening: "Opening"
        case .revealing(_, let phase): phase.title
        case .completed: "Showcase complete"
        }
    }

    var instructionTitle: String {
        switch self {
        case .idle: "Wake the pack"
        case .charging: "Keep holding"
        case .readyToTear: "Break the seal"
        case .tearing: "Pull through"
        case .opening: "The cards are rising"
        case .revealing(_, let phase): phase.instructionTitle
        case .completed: "Final card secured"
        }
    }

    func instructionMessage(cardCount: Int) -> String {
        switch self {
        case .idle:
            "Long press the wrapper, or use the Charge Pack button."
        case .charging:
            "Hold until the gold seam locks into place."
        case .readyToTear:
            "Swipe right across the seam, or use Tear Open."
        case .tearing(let progress):
            "Seal integrity \(max(0, 100 - Int(progress * 100)))%."
        case .opening:
            "Listen for the wrapper snap and watch the first card rise."
        case .revealing(let index, let phase):
            phase.instructionMessage(cardNumber: index + 1, cardCount: cardCount)
        case .completed:
            "The Ultimate Rare stays visible until you choose View Results."
        }
    }

    var symbolName: String {
        switch self {
        case .idle, .charging: "bolt.fill"
        case .readyToTear, .tearing: "scissors"
        case .opening: "shippingbox.fill"
        case .revealing: "rectangle.portrait.on.rectangle.portrait.fill"
        case .completed: "crown.fill"
        }
    }

    var headerTint: Color {
        switch self {
        case .idle, .charging: .white.opacity(0.76)
        case .readyToTear, .tearing: .packGoldBright
        case .opening: .cyan
        case .revealing(let index, _):
            CardRarity.allCases.indices.contains(index) ? CardRarity.allCases[index].tint : .white
        case .completed: .packGoldBright
        }
    }

    var primaryActionTitle: String {
        switch self {
        case .idle, .charging: "Charge Pack"
        case .readyToTear, .tearing: "Tear Open"
        case .opening: "Opening..."
        case .revealing(_, .waiting): "Reveal Card"
        case .revealing(_, .buildup): "Building Energy..."
        case .revealing: "Revealing..."
        case .completed: "View Results"
        }
    }

    var primaryActionSymbol: String {
        switch self {
        case .idle, .charging: "bolt.fill"
        case .readyToTear, .tearing: "scissors"
        case .opening: "shippingbox.fill"
        case .revealing: "sparkles"
        case .completed: "rectangle.stack.fill"
        }
    }

    var primaryActionHint: String {
        switch self {
        case .idle, .charging: "Charges the pack without requiring a long press."
        case .readyToTear, .tearing: "Opens the pack without requiring a swipe."
        case .revealing(_, .waiting): "Flips the current card."
        case .completed: "Shows all five cards in a list."
        case .opening, .revealing: "Wait for the current animation to finish."
        }
    }

    var primaryActionEnabled: Bool {
        switch self {
        case .idle, .charging, .readyToTear, .tearing, .revealing(_, .waiting), .completed:
            true
        case .opening, .revealing:
            false
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
        if case .tearing = self { true } else { false }
    }

    var isOpeningOrBeyond: Bool {
        switch self {
        case .opening, .revealing, .completed: true
        case .idle, .charging, .readyToTear, .tearing: false
        }
    }

    var isWaitingForReveal: Bool {
        if case .revealing(_, .waiting) = self { true } else { false }
    }

    var activeCardIndex: Int {
        if case .revealing(let index, _) = self { index }
        else if self == .completed { CardRarity.allCases.count - 1 }
        else { -1 }
    }

    var lastReachedCardIndex: Int {
        switch self {
        case .revealing(let index, _): index
        case .completed: CardRarity.allCases.count - 1
        default: -1
        }
    }

    var progressAccessibilityLabel: String {
        switch self {
        case .revealing(let index, _): "Card \(index + 1) of \(CardRarity.allCases.count)."
        case .completed: "All cards revealed."
        default: "No cards revealed yet."
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .idle: "Unopened card pack."
        case .charging: "Card pack is charging."
        case .readyToTear: "Card pack is ready to tear."
        case .tearing(let progress): "Tearing progress \(Int(progress * 100)) percent."
        case .opening: "The wrapper is opening and a card is rising."
        case .revealing(let index, let phase): "Card \(index + 1). \(phase.accessibilityLabel)"
        case .completed: "All five cards are revealed. The final card remains visible."
        }
    }
}

private extension RevealPhase {
    var title: String {
        switch self {
        case .waiting: "Ready to reveal"
        case .buildup: "Energy rising"
        case .flippingToEdge: "Approaching the edge"
        case .flippingToFace: "Rarity revealed"
        case .resting: "Card acquired"
        }
    }

    var instructionTitle: String {
        switch self {
        case .waiting: "Your next card"
        case .buildup: "Something is coming"
        case .flippingToEdge: "Watch the edge"
        case .flippingToFace: "Reveal!"
        case .resting: "Take it in"
        }
    }

    func instructionMessage(cardNumber: Int, cardCount: Int) -> String {
        switch self {
        case .waiting: "Tap the card, swipe up, or use Reveal Card (\(cardNumber)/\(cardCount))."
        case .buildup: "The card is holding its energy before the flip."
        case .flippingToEdge: "The front stays hidden until the card reaches 90 degrees."
        case .flippingToFace: "The rarity resolves at the exact midpoint of the flip."
        case .resting: "Card \(cardNumber) of \(cardCount) has been revealed."
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .waiting: "Ready to flip."
        case .buildup: "Reveal buildup in progress."
        case .flippingToEdge, .flippingToFace: "Card is flipping."
        case .resting: "Card is face up."
        }
    }
}
