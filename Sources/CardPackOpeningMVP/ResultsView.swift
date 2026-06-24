import SwiftUI

struct ResultsView: View {
    let cards: [Card]

    var body: some View {
        List(cards) { card in
            CardResultRow(card: card)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CardResultRow: View {
    let card: Card

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(card.rarity.tint.opacity(0.2))
                .overlay {
                    VStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(card.rarity.tint)
                        Text(card.rarity.displayName)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(card.rarity.tint)
                    }
                }
                .frame(width: 72, height: 96)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(card.name)
                        .font(.headline)
                    Spacer()
                    Text("\(card.power)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(card.rarity.tint)
                }

                Text(card.flavorText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview("Results") {
    NavigationStack {
        ResultsView(cards: Array(Card.dummyCards.prefix(5)))
    }
}
