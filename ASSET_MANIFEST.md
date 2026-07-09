# Asset Manifest

All visual and audio assets in this repository are original assets created for this MVP. No existing trading-card characters, logos, frames, music, or sound recordings are used.

## Generated card art

The five character illustrations were generated with ChatGPT's built-in image generation tool on 2026-07-10. Each source was requested as one isolated character on a perfectly flat `#ff00ff` chroma-key background with no text, numbers, frame, border, UI, logo, or watermark. The background was removed locally with the Codex image-generation skill's chroma-key helper, including soft matte, despill, and a one-pixel edge contraction. The final iOS resources are transparent PNGs; the browser preview uses optimized transparent WebP copies.

| Rarity | Card | Generated subject | iOS resource | Web resource |
| --- | --- | --- | --- | --- |
| Normal | Flint Imp | Stone-armored goblin knight with a chipped crescent blade and basalt shield | `Resources/Cards/normal.png` | `assets/cards/normal.webp` |
| Rare | Azure Gale Wyvern | Azure storm wyvern with silver horns and lightning-charged wings | `Resources/Cards/rare.png` | `assets/cards/rare.webp` |
| Super Rare | Selene of the Moon Mirror | Adult silver-blue moon priestess and spellblade with floating mirror talismans | `Resources/Cards/super-rare.png` | `assets/cards/super-rare.webp` |
| Ultra Rare | Noctis Drakon | Obsidian-and-gold solar dragon emperor with a contained sun core | `Resources/Cards/ultra-rare.png` | `assets/cards/ultra-rare.webp` |
| Ultimate Rare | Astra Nova | White porcelain and black star-metal cosmic machine deity with prismatic wings | `Resources/Cards/ultimate-rare.png` | `assets/cards/ultimate-rare.webp` |

Shared generation direction:

> Premium hand-painted Japanese dark-fantasy trading-card illustration with a late-1990s occult-duel atmosphere, crisp ink contours, detailed painted texture, original design only. Exactly one complete subject, centered in a portrait composition with generous padding. Perfectly flat solid `#ff00ff` chroma-key background, no shadow, gradient, texture, floor, reflection, smoke, particles, text, numbers, frame, border, UI, logo, recognizable copyrighted design, or watermark.

The rarity-specific subject descriptions in the table above were appended to that shared direction. Higher rarities were progressively given richer material and lighting direction: restrained earth tones, cobalt lightning, moonlit silver, obsidian and antique gold, then pearl-white prismatic cosmic metal.

## Original sound effects

Nine mono PCM16 WAV files at 44.1 kHz were synthesized specifically for this project from oscillators, envelopes, filtered noise, and deterministic procedural layers. No sampled or third-party recordings are included.

| File | Purpose | Duration |
| --- | --- | ---: |
| `charge.wav` | Long-press energy rise | 1.35 s |
| `ready.wav` | Charge-complete confirmation | 0.64 s |
| `tear.wav` | Wrapper rip | 0.94 s |
| `whoosh.wav` | Card flip | 0.70 s |
| `reveal-normal.wav` | Normal reveal tick | 0.50 s |
| `reveal-rare.wav` | Rare reveal chime | 0.74 s |
| `reveal-super.wav` | Super Rare layered stinger | 0.98 s |
| `reveal-ultra.wav` | Ultra Rare impact and shimmer | 1.30 s |
| `reveal-ultimate.wav` | Ultimate Rare cinematic chord | 1.98 s |

Validation confirmed mono 44.1 kHz 16-bit PCM headers, zero clipped samples, and matching SHA-256 hashes between the SwiftUI and browser copies.
