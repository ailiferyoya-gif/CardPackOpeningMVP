import SwiftUI

enum CardRarity: String, CaseIterable, Identifiable, Hashable {
    case normal = "Normal"
    case rare = "Rare"
    case superRare = "Super Rare"
    case ultraRare = "Ultra Rare"
    case ultimateRare = "Ultimate Rare"

    var id: String { rawValue }
    var displayName: String { rawValue }

    var tint: Color {
        switch self {
        case .normal:
            Color(red: 0.55, green: 0.61, blue: 0.68)
        case .rare:
            Color(red: 0.24, green: 0.68, blue: 1)
        case .superRare:
            Color(red: 1, green: 0.78, blue: 0.2)
        case .ultraRare:
            Color(red: 0.98, green: 0.35, blue: 0.68)
        case .ultimateRare:
            Color(red: 0.72, green: 0.46, blue: 1)
        }
    }

    var shortName: String {
        switch self {
        case .normal: "N"
        case .rare: "R"
        case .superRare: "SR"
        case .ultraRare: "UR"
        case .ultimateRare: "UTR"
        }
    }
}

struct Card: Identifiable, Hashable {
    let id: UUID
    let name: String
    let rarity: CardRarity
    let power: Int
    let flavorText: String
    let artAssetName: String

    init(
        id: UUID = UUID(),
        name: String,
        rarity: CardRarity,
        power: Int,
        flavorText: String,
        artAssetName: String
    ) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.power = power
        self.flavorText = flavorText
        self.artAssetName = artAssetName
    }
}

struct CardPack: Identifiable, Hashable {
    let id: UUID
    let name: String
    let subtitle: String
    let cards: [Card]
    let cardsPerOpening: Int

    init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        cards: [Card],
        cardsPerOpening: Int = 5
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.cards = cards
        self.cardsPerOpening = cardsPerOpening
    }
}

enum OpeningStage: Hashable {
    case idle
    case charging
    case readyToTear
    case tearing(progress: CGFloat)
    case opening
    case revealing(index: Int, phase: RevealPhase)
    case completed
}

enum RevealPhase: Hashable {
    case waiting
    case buildup
    case flippingToEdge
    case flippingToFace
    case resting
}

extension Card {
    static let showcaseCards: [Card] = [
        Card(
            name: "Flint Imp",
            rarity: .normal,
            power: 1200,
            flavorText: "A stone-armored goblin knight who never retreats from a larger foe.",
            artAssetName: "normal"
        ),
        Card(
            name: "Azure Gale Wyvern",
            rarity: .rare,
            power: 1650,
            flavorText: "Blue lightning gathers wherever its wings split the midnight wind.",
            artAssetName: "rare"
        ),
        Card(
            name: "Selene of the Moon Mirror",
            rarity: .superRare,
            power: 2100,
            flavorText: "Her silver-blue blade reflects spells beneath an unbroken moon.",
            artAssetName: "super-rare"
        ),
        Card(
            name: "Noctis Drakon",
            rarity: .ultraRare,
            power: 2800,
            flavorText: "An obsidian dragon emperor crowned by the power of a captive sun.",
            artAssetName: "ultra-rare"
        ),
        Card(
            name: "Astra Nova",
            rarity: .ultimateRare,
            power: 3600,
            flavorText: "A white-and-black machine deity awakened at the edge of the cosmos.",
            artAssetName: "ultimate-rare"
        )
    ]

    static let dummyCards = showcaseCards
}

extension CardPack {
    static let showcasePack = CardPack(
        name: "Celestial Rift",
        subtitle: "A guaranteed showcase: one card from every rarity.",
        cards: Card.showcaseCards,
        cardsPerOpening: CardRarity.allCases.count
    )

    static let dummyPacks: [CardPack] = [
        showcasePack
    ]

    var guaranteedShowcaseCards: [Card] {
        CardRarity.allCases.compactMap { rarity in
            cards.first { $0.rarity == rarity }
        }
    }
}
