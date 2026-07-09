import SpriteKit
import SwiftUI
import UIKit

struct RevealEffect: Identifiable, Equatable {
    let id: Int
    let rarity: CardRarity
}

@MainActor
struct RarityRevealLayer: View {
    let effect: RevealEffect
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { proxy in
            if reduceMotion {
                StaticRevealHalo(rarity: effect.rarity)
            } else {
                ParticleSpriteHost(rarity: effect.rarity, size: proxy.size)
                .id(effect.id)
            }
        }
    }
}

@MainActor
private struct ParticleSpriteHost: View {
    @State private var scene: RarityParticleScene

    init(rarity: CardRarity, size: CGSize) {
        _scene = State(initialValue: RarityParticleScene(rarity: rarity, size: size))
    }

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .ignoresSafeArea()
    }
}

private struct StaticRevealHalo: View {
    let rarity: CardRarity

    var body: some View {
        RadialGradient(
            colors: [rarity.tint.opacity(0.24), .clear],
            center: .center,
            startRadius: 14,
            endRadius: 190
        )
        .ignoresSafeArea()
    }
}

struct UltimateBuildupOverlay: View {
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(reduceMotion ? 0.38 : 0.58)
                .ignoresSafeArea()

            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { timeline in
                Canvas { context, size in
                    drawBuildup(
                        context: &context,
                        size: size,
                        time: timeline.date.timeIntervalSinceReferenceDate
                    )
                }
            }
            .ignoresSafeArea()

            VStack {
                Spacer()
                Text("ULTIMATE SIGNAL")
                    .font(.caption.weight(.black))
                    .tracking(3)
                    .foregroundStyle(Color.packGoldBright)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 36)
                    .background(.black.opacity(0.48), in: Capsule())
                    .padding(.bottom, 112)
            }
        }
    }

    private func drawBuildup(
        context: inout GraphicsContext,
        size: CGSize,
        time: TimeInterval
    ) {
        let center = CGPoint(x: size.width / 2, y: size.height * 0.46)
        let cycle = reduceMotion ? 0.45 : time.truncatingRemainder(dividingBy: 1.4) / 1.4
        let prismColors: [Color] = [.cyan, .blue, .purple, .pink, .yellow, .mint]

        for index in 0..<4 {
            let offsetCycle = (cycle + Double(index) * 0.2).truncatingRemainder(dividingBy: 1)
            let radius = 42 + CGFloat(offsetCycle) * 150
            let rect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            context.opacity = 0.68 * (1 - offsetCycle)
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(prismColors[index % prismColors.count]),
                lineWidth: 2.5
            )
        }

        for index in 0..<26 {
            let seed = Double(index) * 0.739
            let angle = seed * .pi * 2 + cycle * .pi * 0.7
            let pulse = 0.62 + 0.38 * sin(time * 2.2 + seed * 5)
            let radius = CGFloat(72 + (index % 7) * 18) * CGFloat(pulse)
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius * 0.72
            )
            let side = CGFloat(3 + index % 4)
            let rect = CGRect(x: point.x - side, y: point.y - side, width: side * 2, height: side * 2)
            context.opacity = 0.36 + Double(index % 5) * 0.1
            context.fill(
                Path(roundedRect: rect, cornerRadius: side * 0.35),
                with: .color(prismColors[index % prismColors.count])
            )
        }
    }
}

struct ScreenFlashView: View {
    let opacity: Double

    var body: some View {
        Rectangle()
            .fill(.white.opacity(opacity))
            .ignoresSafeArea()
    }
}

private final class RarityParticleScene: SKScene {
    private let rarity: CardRarity

    init(rarity: CardRarity, size: CGSize) {
        self.rarity = rarity
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        guard children.isEmpty else { return }

        backgroundColor = .clear
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        let origin = CGPoint(x: size.width / 2, y: size.height * 0.54)
        addEmitter(
            color: rarity.particleColor,
            origin: origin,
            count: rarity.particleCount,
            speed: rarity.particleSpeed,
            lifetime: rarity.particleLifetime,
            scale: rarity.particleScale
        )

        switch rarity {
        case .normal:
            addRing(at: origin, color: .white, radius: 34, scale: 2.2, duration: 0.38)
        case .rare:
            addRing(at: origin, color: .systemBlue, radius: 38, scale: 2.7, duration: 0.46)
        case .superRare:
            addStarburst(at: origin, color: .systemYellow)
            addRing(at: origin, color: .systemYellow, radius: 42, scale: 3.2, duration: 0.58)
        case .ultraRare:
            addPrismaticBurst(at: origin, countPerColor: 13)
            addRing(at: origin, color: .systemPink, radius: 44, scale: 3.8, duration: 0.68)
        case .ultimateRare:
            addPrismaticBurst(at: origin, countPerColor: 21)
            addUltimateRings(at: origin)
            addStarburst(at: origin, color: .white)
        }

        run(.sequence([
            .wait(forDuration: 2.3),
            .run { [weak self] in self?.isPaused = true }
        ]))
    }

    private func addEmitter(
        color: SKColor,
        origin: CGPoint,
        count: Int,
        speed: CGFloat,
        lifetime: CGFloat,
        scale: CGFloat
    ) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(image: particleImage(color: color))
        emitter.particleBirthRate = CGFloat(count) / max(lifetime * 0.55, 0.1)
        emitter.numParticlesToEmit = count
        emitter.particleLifetime = lifetime
        emitter.particleLifetimeRange = lifetime * 0.28
        emitter.particleSpeed = speed
        emitter.particleSpeedRange = speed * 0.48
        emitter.emissionAngleRange = .pi * 2
        emitter.particleAlpha = 0.96
        emitter.particleAlphaSpeed = -0.82 / lifetime
        emitter.particleScale = scale
        emitter.particleScaleRange = scale * 0.42
        emitter.particleScaleSpeed = -scale * 0.22
        emitter.position = origin
        emitter.particlePositionRange = CGVector(dx: 42, dy: 36)
        addChild(emitter)
    }

    private func addPrismaticBurst(at origin: CGPoint, countPerColor: Int) {
        let colors: [SKColor] = [.systemCyan, .systemBlue, .systemPurple, .systemPink, .systemYellow, .systemGreen]
        for (index, color) in colors.enumerated() {
            let emitter = SKEmitterNode()
            emitter.particleTexture = SKTexture(image: diamondImage(color: color))
            emitter.particleBirthRate = 280
            emitter.numParticlesToEmit = countPerColor
            emitter.particleLifetime = rarity == .ultimateRare ? 1.45 : 1.05
            emitter.particleLifetimeRange = 0.24
            emitter.particleSpeed = rarity == .ultimateRare ? 150 : 116
            emitter.particleSpeedRange = 44
            emitter.emissionAngle = CGFloat(index) * (.pi * 2 / CGFloat(colors.count))
            emitter.emissionAngleRange = 0.74
            emitter.particleRotationRange = .pi
            emitter.particleRotationSpeed = 3.4
            emitter.particleScale = rarity == .ultimateRare ? 0.3 : 0.22
            emitter.particleScaleRange = 0.11
            emitter.particleAlpha = 0.95
            emitter.particleAlphaSpeed = -0.68
            emitter.position = origin
            addChild(emitter)
        }
    }

    private func addRing(
        at origin: CGPoint,
        color: SKColor,
        radius: CGFloat,
        scale: CGFloat,
        duration: TimeInterval
    ) {
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.position = origin
        ring.fillColor = .clear
        ring.strokeColor = color.withAlphaComponent(0.9)
        ring.lineWidth = 4
        ring.run(.sequence([
            .group([.scale(to: scale, duration: duration), .fadeOut(withDuration: duration)]),
            .removeFromParent()
        ]))
        addChild(ring)
    }

    private func addUltimateRings(at origin: CGPoint) {
        let colors: [SKColor] = [.white, .systemCyan, .systemPurple, .systemYellow]
        for (index, color) in colors.enumerated() {
            let ring = SKShapeNode(circleOfRadius: CGFloat(30 + index * 13))
            ring.position = origin
            ring.fillColor = .clear
            ring.strokeColor = color.withAlphaComponent(0.82)
            ring.lineWidth = CGFloat(5 - index)
            let delay = TimeInterval(index) * 0.055
            let duration = 0.78 + TimeInterval(index) * 0.08
            ring.run(.sequence([
                .wait(forDuration: delay),
                .group([.scale(to: 3.6, duration: duration), .fadeOut(withDuration: duration)]),
                .removeFromParent()
            ]))
            addChild(ring)
        }
    }

    private func addStarburst(at origin: CGPoint, color: SKColor) {
        let node = SKShapeNode()
        let path = CGMutablePath()
        for index in 0..<16 {
            let angle = CGFloat(index) * (.pi * 2 / 16)
            let inner = CGPoint(x: cos(angle) * 22, y: sin(angle) * 22)
            let outer = CGPoint(x: cos(angle) * 92, y: sin(angle) * 92)
            path.move(to: inner)
            path.addLine(to: outer)
        }
        node.path = path
        node.position = origin
        node.strokeColor = color.withAlphaComponent(0.76)
        node.lineWidth = 2.5
        node.run(.sequence([
            .group([.scale(to: 1.8, duration: 0.46), .fadeOut(withDuration: 0.46)]),
            .removeFromParent()
        ]))
        addChild(node)
    }

    private func particleImage(color: SKColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 12, height: 12))
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 1, y: 1, width: 10, height: 10))
        }
    }

    private func diamondImage(color: SKColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 14, height: 14))
        return renderer.image { context in
            color.setFill()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 7, y: 0))
            path.addLine(to: CGPoint(x: 14, y: 7))
            path.addLine(to: CGPoint(x: 7, y: 14))
            path.addLine(to: CGPoint(x: 0, y: 7))
            path.close()
            path.fill()
        }
    }
}

extension CardRarity {
    func buildupMilliseconds(reduceMotion: Bool) -> Int {
        if reduceMotion {
            return self == .ultimateRare ? 180 : 40
        }

        switch self {
        case .normal: return 80
        case .rare: return 130
        case .superRare: return 260
        case .ultraRare: return 460
        case .ultimateRare: return 1_150
        }
    }

    func flipHalfDuration(reduceMotion: Bool) -> Double {
        if reduceMotion { return 0.07 }

        switch self {
        case .normal: return 0.2
        case .rare: return 0.23
        case .superRare: return 0.27
        case .ultraRare: return 0.31
        case .ultimateRare: return 0.4
        }
    }

    func faceHoldMilliseconds(reduceMotion: Bool) -> Int {
        if reduceMotion { return 220 }

        switch self {
        case .normal: return 420
        case .rare: return 540
        case .superRare: return 720
        case .ultraRare: return 930
        case .ultimateRare: return 1_350
        }
    }

    var flashOpacity: Double {
        switch self {
        case .normal: 0
        case .rare: 0.08
        case .superRare: 0.24
        case .ultraRare: 0.48
        case .ultimateRare: 0.72
        }
    }

    fileprivate var particleColor: SKColor {
        switch self {
        case .normal: .white
        case .rare: .systemBlue
        case .superRare: .systemYellow
        case .ultraRare: .systemPink
        case .ultimateRare: .white
        }
    }

    fileprivate var particleCount: Int {
        switch self {
        case .normal: 18
        case .rare: 34
        case .superRare: 62
        case .ultraRare: 88
        case .ultimateRare: 118
        }
    }

    fileprivate var particleSpeed: CGFloat {
        switch self {
        case .normal: 44
        case .rare: 66
        case .superRare: 94
        case .ultraRare: 122
        case .ultimateRare: 148
        }
    }

    fileprivate var particleLifetime: CGFloat {
        switch self {
        case .normal: 0.48
        case .rare: 0.68
        case .superRare: 0.88
        case .ultraRare: 1.05
        case .ultimateRare: 1.42
        }
    }

    fileprivate var particleScale: CGFloat {
        switch self {
        case .normal: 0.12
        case .rare: 0.15
        case .superRare: 0.19
        case .ultraRare: 0.22
        case .ultimateRare: 0.26
        }
    }
}
