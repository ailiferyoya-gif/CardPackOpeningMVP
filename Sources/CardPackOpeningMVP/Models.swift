import SwiftUI

enum CardRarity: String, CaseIterable, Identifiable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .common:
            "Common"
        case .rare:
            "Rare"
        case .epic:
            "Epic"
        case .legendary:
            "Legendary"
        }
    }

    var tint: Color {
        switch self {
        case .common:
            .gray
        case .rare:
            .blue
        case .epic:
            .purple
        case .legendary:
            .orange
        }
    }
}

struct Card: Identifiable, Hashable {
    let id: UUID
    let name: String
    let rarity: CardRarity
    let power: Int
    let flavorText: String

    init(
        id: UUID = UUID(),
        name: String,
        rarity: CardRarity,
        power: Int,
        flavorText: String
    ) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.power = power
        self.flavorText = flavorText
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
    case revealing(index: Int)
    case completed
}

extension Card {
    static let dummyCards: [Card] = [
        Card(name: "Spark Squire", rarity: .common, power: 120, flavorText: "A bright first step into the arena."),
        Card(name: "Moss Guard", rarity: .common, power: 140, flavorText: "Stands firm when the field gets loud."),
        Card(name: "River Scout", rarity: .common, power: 150, flavorText: "Finds a path before the map catches up."),
        Card(name: "Amber Archer", rarity: .rare, power: 230, flavorText: "Every shot carries a little sunrise."),
        Card(name: "Moonlit Sage", rarity: .rare, power: 260, flavorText: "Reads tomorrow from a silver cup."),
        Card(name: "Crimson Duelist", rarity: .rare, power: 280, flavorText: "Bows once, then ends the argument."),
        Card(name: "Storm Chimera", rarity: .epic, power: 420, flavorText: "Three roars, one terrible answer."),
        Card(name: "Crystal Oracle", rarity: .epic, power: 450, flavorText: "The future reflects whoever dares look."),
        Card(name: "Sunforged Dragon", rarity: .legendary, power: 720, flavorText: "Its wings remember the first flame."),
        Card(name: "Eclipse Empress", rarity: .legendary, power: 760, flavorText: "Night and day negotiate at her feet.")
    ]
}

extension CardPack {
    static let dummyPacks: [CardPack] = [
        CardPack(
            name: "Starter Pack",
            subtitle: "A balanced 5-card opening for the first MVP test.",
            cards: Card.dummyCards
        ),
        CardPack(
            name: "Rare Boost Pack",
            subtitle: "A simple local pack with the same dummy pool.",
            cards: Card.dummyCards.shuffled()
        )
    ]
}
