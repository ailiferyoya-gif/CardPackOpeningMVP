# ARCANA//BURST — Card Pack Opening MVP

A premium card-pack opening showcase built in SwiftUI, with a feature-matched static browser edition for GitHub Pages.

## Live browser edition

Open the public preview:

https://ailiferyoya-gif.github.io/CardPackOpeningMVP/

The browser edition has no CDN or runtime dependency. It is designed for narrow phones first and includes keyboard controls, gesture alternatives, safe-area padding, focus management, and a reduced-motion mode.

## Showcase contents

Every opening is intentionally deterministic so all five rarity treatments can be evaluated in one run:

1. Normal — Flint Imp
2. Rare — Azure Gale Wyvern
3. Super Rare — Selene of the Moon Mirror
4. Ultra Rare — Noctis Drakon
5. Ultimate Rare — Astra Nova

Each character is an original ChatGPT-generated illustration. The app renders the card frame, title, rarity, stats, foil, and reveal effects in code so typography stays crisp. No sprite sheet or third-party artwork is used.

## Opening flow

- Long-press the wrapper to charge it, then swipe right to tear the seal.
- Visible buttons provide equivalent Charge, Tear, Reveal, and Results actions.
- Cards use a two-phase 3D flip; art, rarity, sound, particles, lighting, and haptics resolve at the 90-degree midpoint.
- Effect intensity escalates from Normal to Ultimate Rare.
- Ultimate Rare adds a scene dim, prismatic rings, gold-white burst, longer stinger, and extended reward hold.
- The final card stays on screen until the user explicitly opens the results.

## Original assets

- Five transparent PNG character illustrations for SwiftUI.
- Five optimized transparent WebP copies for the browser.
- Nine original procedurally synthesized PCM WAV effects: charge, ready, tear, whoosh, and one reveal stinger per rarity.

See [ASSET_MANIFEST.md](ASSET_MANIFEST.md) for the generation direction, file mapping, and audio validation details.

## Native SwiftUI edition

Requirements:

- Xcode with an iOS 17+ SDK
- iOS 17 or later

Open `Package.swift` in Xcode, select the `CardPackOpeningMVP` scheme and an iOS Simulator, then build the package. Package resources are loaded through `Bundle.module`.

This repository currently uses a standalone Swift Package rather than a signed `.xcodeproj` application container. The macOS CI workflow is a native compile gate; Simulator installation and launch remain a separate Xcode verification step. The GitHub Pages edition is the directly runnable deliverable in this repository.

The native edition uses SwiftUI, SpriteKit particle layers, AVFoundation sound playback, UIKit feedback generators, Dynamic Type, VoiceOver labels, compact-height layouts, and Reduce Motion handling.

## Repository layout

- `Sources/CardPackOpeningMVP/` — SwiftUI app, opening state machine, effects, feedback, and results.
- `Sources/CardPackOpeningMVP/Resources/` — generated PNG cards and original WAV effects.
- `PreviewWeb/` — self-contained GitHub Pages edition.
- `.github/workflows/ios-simulator-build.yml` — macOS CI build for the iOS Simulator destination.
- `HANDOFF.md` — current implementation and verification state.

## Verification

The browser flow is syntax-checked and exercised at a 320×740 viewport through the complete five-card opening. Native compilation is delegated to the repository's macOS GitHub Actions workflow because this Windows workspace does not include Xcode.
