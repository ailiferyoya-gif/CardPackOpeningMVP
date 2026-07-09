import AVFoundation
import UIKit

final class PackAudioService {
    enum Cue: String, CaseIterable, Hashable {
        case charge
        case ready
        case tear
        case whoosh
        case revealNormal = "reveal-normal"
        case revealRare = "reveal-rare"
        case revealSuper = "reveal-super"
        case revealUltra = "reveal-ultra"
        case revealUltimate = "reveal-ultimate"

        var volume: Float {
            switch self {
            case .charge: 0.52
            case .ready: 0.7
            case .tear: 0.82
            case .whoosh: 0.72
            case .revealNormal: 0.58
            case .revealRare: 0.66
            case .revealSuper: 0.76
            case .revealUltra: 0.86
            case .revealUltimate: 1
            }
        }

        static func reveal(for rarity: CardRarity) -> Cue {
            switch rarity {
            case .normal: .revealNormal
            case .rare: .revealRare
            case .superRare: .revealSuper
            case .ultraRare: .revealUltra
            case .ultimateRare: .revealUltimate
            }
        }
    }

    private var players: [Cue: AVAudioPlayer] = [:]
    private var hasPreloaded = false

    func preload() {
        guard !hasPreloaded else { return }
        hasPreloaded = true

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])

        for cue in Cue.allCases {
            guard let url = resourceURL(for: cue) else { continue }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = cue.volume
                player.prepareToPlay()
                players[cue] = player
            } catch {
                // Missing or invalid optional audio should never block the opening flow.
            }
        }
    }

    func play(_ cue: Cue, enabled: Bool) {
        guard enabled else { return }
        preload()
        guard let player = players[cue] else { return }
        player.currentTime = 0
        player.volume = cue.volume
        player.play()
    }

    func stop(_ cue: Cue) {
        players[cue]?.stop()
        players[cue]?.currentTime = 0
    }

    func stopAll() {
        players.values.forEach {
            $0.stop()
            $0.currentTime = 0
        }
    }

    private func resourceURL(for cue: Cue) -> URL? {
        Bundle.module.url(forResource: cue.rawValue, withExtension: "wav")
            ?? Bundle.module.url(forResource: cue.rawValue, withExtension: "wav", subdirectory: "Sounds")
    }
}

@MainActor
final class PackHaptics {
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    func prepare() {
        softImpact.prepare()
        rigidImpact.prepare()
        notification.prepare()
        selection.prepare()
    }

    func chargingStarted() {
        softImpact.impactOccurred(intensity: 0.36)
        softImpact.prepare()
    }

    func packReady() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    func tearStarted() {
        rigidImpact.impactOccurred(intensity: 0.72)
        rigidImpact.prepare()
    }

    func wrapperOpened() {
        rigidImpact.impactOccurred(intensity: 0.9)
        rigidImpact.prepare()
    }

    func reveal(_ rarity: CardRarity) {
        switch rarity {
        case .normal:
            selection.selectionChanged()
        case .rare:
            softImpact.impactOccurred(intensity: 0.52)
        case .superRare:
            rigidImpact.impactOccurred(intensity: 0.68)
        case .ultraRare:
            rigidImpact.impactOccurred(intensity: 0.9)
        case .ultimateRare:
            notification.notificationOccurred(.success)
        }

        prepare()
    }
}
