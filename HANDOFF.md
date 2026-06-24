# Handoff

## Project

- Path: `D:\Codex\CardPackOpeningMVP`
- Type: Swift Package / SwiftUI iOS MVP

## Implemented

- Added `Card`, `CardRarity`, `CardPack`, and `OpeningStage` models.
- Added 10 local dummy cards.
- Added `PackSelectionView`, `PackOpeningView`, and `ResultsView`.
- Added SwiftUI previews for all three screens.
- Pack selection uses `NavigationStack` and pushes `PackOpeningView`.
- `PackOpeningView` now supports the full stage flow: long press charge, ready-to-tear, swipe tear progress, opening, one-by-one reveal, completed.
- Added a placeholder tear animation using SwiftUI `Canvas`, `mask`, `overlay`, `animation`, and `rotation3DEffect`.
- Added a glowing perforation, left-to-right tear line, pack wiggle/tilt, wrapper peel, and rising card back.
- Added rarity effects for `common`, `rare`, `superRare`, and `ultraRare`.
- Particle effects are embedded with SpriteKit via `SpriteView` and tuned by rarity count/rate.
- Added card flip reveal by tap or upward swipe, with rarity-specific delay and ultra-rare flash.
- Flipped cards stack below the active card, then navigate to `ResultsView`.
- Added `PreviewWeb/` for GitHub Pages browser verification.
- Added root `index.html` redirect and `.nojekyll` for Pages.
- Synced preview rarity labels to `Super Rare` and `Ultra Rare`.

## Not Done Yet

- No generated image assets yet.
- No persistence or collection screen.
- iOS build has not been run in this Windows environment because `swift` and `xcodebuild` are unavailable.

## Next

- Open the package in Xcode on macOS and run an iOS Simulator build.
- Tune timings and visuals on a real Simulator after the package compiles cleanly.
- If character/card art is needed, generate transparent-background images with ChatGPT and avoid sprite sheets unless confirmed first.
