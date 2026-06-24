# CardPackOpeningMVP

SwiftUI-based iOS card pack opening MVP.

## GitHub Pages Preview

The SwiftUI app itself should be built with Xcode, but this repository also includes a small static browser preview under `PreviewWeb/` so the MVP flow can be checked on GitHub Pages.

## Contents

- `PackSelectionView`: Lists local dummy packs.
- `PackOpeningView`: Opens a selected pack and prepares results.
- `ResultsView`: Displays opened cards.
- `Card`, `CardRarity`, `CardPack`, `OpeningStage`: Core MVP models.

## Notes

- The card pool is generated locally with 10 dummy cards.
- Advanced opening animation and external assets are intentionally out of scope for this MVP.
- This project is a Swift Package intended to be opened in Xcode for iOS.
