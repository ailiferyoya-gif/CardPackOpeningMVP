import SwiftUI

struct PackSelectionView: View {
    private let packs: [CardPack]

    init(packs: [CardPack] = CardPack.dummyPacks) {
        self.packs = packs
    }

    var body: some View {
        NavigationStack {
            List(packs) { pack in
                NavigationLink(value: pack) {
                    PackRowView(pack: pack)
                }
                .accessibilityLabel("\(pack.name), \(pack.subtitle)")
            }
            .navigationTitle("Card Packs")
            .navigationDestination(for: CardPack.self) { pack in
                PackOpeningView(pack: pack)
            }
        }
    }
}

private struct PackRowView: View {
    let pack: CardPack

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [.indigo, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 88)
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(pack.name)
                    .font(.headline)
                Text(pack.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(pack.cardsPerOpening) cards")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
            }
            .lineLimit(2)
        }
        .padding(.vertical, 6)
    }
}

#Preview("Pack Selection") {
    PackSelectionView()
}
