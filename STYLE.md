# Car Bingo — Illustration Style Spec (v1)

> **The launch-quality gate.** Every tile ships to this spec or it doesn't ship. One page, held to literally. Style consistency is what makes ~30–60 tiles from mixed sources (authentic road signs + AI-generated art) read as one intentional set instead of a scrapbook.

**Chosen direction: Unified flat pictograms.** *Everything* — including the road signs — is rendered in one flat, iconographic language. The AI-generated items echo the visual grammar of traffic signage (bold, geometric, high-contrast, minimal). This is the most achievable "consistent" for a solo dev and the most forgiving register at the ~150 px size a tile actually renders in a cell.

---

## 1. Canvas & geometry

| Property | Value |
|---|---|
| Master format | **SVG** (vector), authored on a **512×512** viewBox |
| Aspect | **1:1** only (the board is a square grid of square cells) |
| Export | WebP @ 512 px (single density — no 1x/2x/3x triples for MVP) |
| Safe area | Subject fully inside a **center 448×448** box (32 px padding all sides) so nothing clips when the cell adds its own rounded mask |
| Tile shape | Full-bleed rounded square, corner radius **64** (matches `BingoTokens.cellRadius`) |
| Composition | **One subject, centered.** No scenes, no multiple focal points. If it needs a caption to be legible, it's too detailed. |

The item **name is rendered by the app** (caption under the image, and via the detail pane / semantics) — **never bake text into the tile.** This keeps tiles font-independent, localization-independent, and legible at any size.

## 2. Visual language

- **Flat.** No gradients, no photorealism, no drop shadows *inside* the art (the cell supplies elevation). Solid fills only; at most one flat tint for depth.
- **Line weight.** If using strokes, a single consistent weight: **stroke-width 12** on the 512 viewBox (≈ 2.3% of canvas). Prefer solid shapes over outlines where possible.
- **Corners.** Rounded joins/caps (`stroke-linejoin="round"`, `stroke-linecap="round"`); soft, friendly geometry — no sharp spikes.
- **Perspective.** Head-on / flat elevation. No 3/4 view, no vanishing points.
- **Detail budget.** Readable as a **silhouette at 48 px**. Squint test: if you can't tell what it is when tiny, simplify.

## 3. Palette

A fixed, limited palette. Each **category owns a background color**; subjects use white + a small shared accent set. (Placeholders already use these category colors — see `content/catalog.config.json`.)

| Category | Background | Notes |
|---|---|---|
| Road signs | `#E4572E` | signal red-orange |
| Vehicles | `#2E86AB` | blue |
| Animals | `#6A994E` | green |
| Nature | `#4C956C` | deep green |
| Buildings | `#C1666B` | terracotta |

Shared subject palette: **white `#FFFFFF`**, ink `#20303A`, and one warm accent `#F6BD60`. Keep total colors per tile ≤ 4. Category background must clear **WCAG contrast** against white subjects and against both light/dark cell scrims.

> **Road signs are the exception that proves the rule:** real Norwegian signs have legally fixed colors/shapes. Render them as *flat pictograms in the sign's own palette* (e.g. red-bordered white triangle for warnings) placed on the category background, so an authentic sign still reads as part of the set. Do **not** recolor a sign into the category color — keep the sign accurate, harmonize via layout, padding, and flatness.

## 4. Background

- Tile background = **the category's solid color**, full-bleed to the rounded square. No transparency in the final WebP (a transparent tile on a themed cell looks broken in dark mode).
- No textures, no photos, no busy patterns.

## 5. Category ↔ difficulty ↔ rarity

Difficulty is **spot-rarity on a road trip**, not visual complexity. It drives the generator's quotas (see `ARCHITECTURE.md` §8, and `lib/domain/board/difficulty_mix.dart`).

| `difficulty` | Tier | Meaning | Examples |
|---|---|---|---|
| 1–2 | Easy | You'll see it within minutes | speed-limit sign, red car, cow |
| 3 | Medium | Once or twice a trip | roundabout sign, tractor, church |
| 4–5 | Hard | Lucky to spot | falling-rocks sign, fox, rainbow |

Tag rarity honestly as you author — the build-time validator (`npm run validate`) reports which (tier × category) buckets are too thin to fill a 5×5 without relaxation.

## 6. Provenance & licensing (mandatory per tile)

Every tile records its `license` block in `item.json`. This **records** a decision — it clears nothing.

- **Road signs:** verify reuse terms *before* building on them. If Norwegian (Statens vegvesen), confirm the license explicitly and set `source: "statens_vegvesen"`, the real `type`/`url`, and `attributionRequired` correctly.
- **AI-generated art:** set `source: "ai:<model>"`, keep the **exact `prompt`**, prefer a model with clear commercial terms, and expect to declare AI use at store review. For consistency, generate with a fixed prompt scaffold + reference image, then run every output through the same pipeline post-process.
- **Placeholders (current):** `source: "placeholder"`, `type: "CC0-1.0"` — these are the generated flat tiles you'll replace.

## 7. Production checklist (per tile, before it replaces a placeholder)

- [ ] 512×512 SVG master, subject within the 448 safe area
- [ ] Flat, single line weight, ≤ 4 colors, category background
- [ ] Passes the 48 px squint test
- [ ] No baked-in text
- [ ] `item.json` `license` filled with real provenance
- [ ] `difficulty` reflects real-world spot-rarity
- [ ] `npm run validate && npm run build` pass; eyeball it in a cell (`flutter run -d chrome`)
