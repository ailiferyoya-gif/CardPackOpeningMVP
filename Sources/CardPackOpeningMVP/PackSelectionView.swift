import SwiftUI

struct PackSelectionView: View {
    private let packs: [CardPack]

    init(packs: [CardPack] = CardPack.dummyPacks) {
        self.packs = packs
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CelestialBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PACK LAB // 01")
                                .font(.caption.weight(.black))
                                .tracking(2.4)
                                .foregroundStyle(Color.packGoldBright)

                            Text("Chase the reveal.")
                                .font(.largeTitle.weight(.black))
                                .foregroundStyle(.white)

                            Text("Hold, tear, and flip through five escalating rarities. This showcase pack always contains one of each.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.76))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        ForEach(packs) { pack in
                            NavigationLink(value: pack) {
                                ShowcasePackRow(pack: pack)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Open \(pack.name). \(pack.subtitle)")
                            .accessibilityHint("Starts the card pack opening experience.")
                        }

                        RarityLegend()
                    }
                    .padding(20)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Card Packs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: CardPack.self) { pack in
                PackOpeningView(pack: pack)
            }
        }
        .tint(.packGoldBright)
    }
}

private struct ShowcasePackRow: View {
    let pack: CardPack

    var body: some View {
        HStack(spacing: 18) {
            PackThumbnail()
                .frame(width: 104, height: 144)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 10) {
                Text("GUARANTEED 5")
                    .font(.caption2.weight(.black))
                    .tracking(1.3)
                    .foregroundStyle(Color.packGoldBright)

                Text(pack.name)
                    .font(.title2.weight(.black))
                    .foregroundStyle(.white)

                Text(pack.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)

                Label("Open pack", systemImage: "hand.tap.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 44)
                    .background(Color.packGoldBright, in: Capsule())
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.packGoldBright.opacity(0.8), .white.opacity(0.18), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

private struct PackThumbnail: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(
                LinearGradient(
                    colors: [.packNavyDeep, Color(red: 0.18, green: 0.11, blue: 0.42), .packGold],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 34, weight: .black))
                    Text("CELESTIAL\nRIFT")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.white)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(0.65), lineWidth: 1.5)
                    .padding(6)
            }
            .shadow(color: .packGold.opacity(0.36), radius: 18, y: 10)
            .rotationEffect(.degrees(-3))
    }
}

private struct RarityLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ONE OF EACH")
                .font(.caption.weight(.black))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.62))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 82), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(CardRarity.allCases) { rarity in
                    Label(rarity.shortName, systemImage: rarity.symbolName)
                        .font(.caption2.weight(.black))
                        .foregroundStyle(rarity.tint)
                        .padding(.horizontal, 9)
                        .frame(minHeight: 36)
                        .background(rarity.tint.opacity(0.14), in: Capsule())
                        .accessibilityLabel(rarity.displayName)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("Pack Selection") {
    PackSelectionView()
}
