import SwiftUI

struct ResultsView: View {
    let cards: [Card]

    var body: some View {
        ZStack {
            CelestialBackground()

            ScrollView {
                LazyVStack(spacing: 14) {
                    ResultsSummary(cards: cards)

                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        CardResultRow(index: index, card: card)
                    }
                }
                .padding(20)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Pack Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

private struct ResultsSummary: View {
    let cards: [Card]

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "crown.fill")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(Color.packGoldBright)

            Text("SHOWCASE COMPLETE")
                .font(.title2.weight(.black))
                .foregroundStyle(.white)

            Text("\(cards.count) cards acquired - one of every rarity")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))

            HStack(spacing: 8) {
                ForEach(CardRarity.allCases) { rarity in
                    Image(systemName: rarity.symbolName)
                        .foregroundStyle(rarity.tint)
                        .frame(width: 32, height: 32)
                        .background(rarity.tint.opacity(0.14), in: Circle())
                        .accessibilityLabel(rarity.displayName)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.packGoldBright.opacity(0.42), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct CardResultRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let index: Int
    let card: Card

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 14) {
                    artwork
                        .frame(maxWidth: .infinity)
                    details
                }
            } else {
                HStack(spacing: 16) {
                    artwork
                    details
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(card.rarity.tint.opacity(0.38), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Card \(index + 1), \(card.name), \(card.rarity.displayName), power \(card.power). \(card.flavorText)"
        )
    }

    private var artwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(card.rarity.cardGradient)

            Image(card.artAssetName, bundle: .module)
                .resizable()
                .scaledToFit()
                .padding(6)
        }
        .frame(width: dynamicTypeSize.isAccessibilitySize ? 150 : 92, height: dynamicTypeSize.isAccessibilitySize ? 190 : 120)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(card.rarity.tint.opacity(0.9), lineWidth: 1.5)
        }
        .shadow(color: card.rarity.tint.opacity(0.26), radius: 9, y: 6)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline) {
                Text(card.name)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                Spacer(minLength: 8)

                Text("#\(index + 1)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white.opacity(0.48))
            }

            Label(card.rarity.displayName, systemImage: card.rarity.symbolName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(card.rarity.tint)

            Text("POWER \(card.power)")
                .font(.subheadline.weight(.black).monospaced())
                .foregroundStyle(Color.packGoldBright)

            Text(card.flavorText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview("Results") {
    NavigationStack {
        ResultsView(cards: Card.showcaseCards)
    }
}
