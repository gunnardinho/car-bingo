# Car Bingo — Design Language v2

> **One spec, held to literally.** This is the single source of truth for how the
> app *looks* and how every tile illustration is produced. It covers the app-wide
> design language (color, type, shape, motion, components) **and** the template for
> the AI-generated stickers that fill the board.
>
> v2 supersedes v1. **The big change:** tiles are now **silhouette die-cut stickers
> (transparent art + a white outline) floating on a dynamic, themeable cell
> background**, not flat pictograms baked onto category-colored backgrounds. See the
> [Changelog](#14-changelog-v1--v2).

---

## 1. Personality & principles

Car Bingo is a game a kid plays in the back seat. It should feel like a **sheet of
bright stickers** — cheerful, tactile, instantly readable at a glance and at arm's
length. Five principles, in priority order:

1. **Vibrant** — saturated, confident color. No mud, no pastels-by-default.
2. **Playful** — rounded geometry, soft bounce in motion, friendly icons, real
   peel-off *stickers*.
3. **Clear** — high contrast, big touch targets, one idea per element.
4. **Minimal** — lots of space, few colors per view, nothing decorative that doesn't
   earn its place. Vibrancy comes from *the art*, not from busy chrome.
5. **Accessible** — never encode meaning by color alone; meet WCAG AA contrast.

> **The tension to hold:** *vibrant + minimal.* We get both by keeping the app
> chrome calm and near-monochrome (one brand blue on neutrals) and letting the
> **sticker illustrations carry the color** on a **themeable background**.

---

## 2. Color

### Neutrals (the canvas)

| Token | Hex | Use |
|---|---|---|
| White | `#FFFFFF` | Sticker outline, cards, the default cell background |
| Cloud | `#F5F7F9` | App background / scaffold, grid gaps |
| Line | `#E3E8EC` | Hairline dividers, subtle tile edge |
| Slate | `#5B6B78` | Secondary text, captions, muted icons |
| Ink | `#16212B` | Primary text, glyph detail |

### Brand

| Token | Hex | Use |
|---|---|---|
| Brand Blue | `#2E86AB` | Primary actions, selection ring, links. This is the Material `ColorScheme` **seed**. |

### Playful accent palette

A fixed, curated set of high-saturation colors that read cleanly against both light
and dark backgrounds. These drive **sticker art**, celebratory moments, and small
accents. The first five double as the legacy category colors — **still defined in
`content/catalog.config.json` and in `BingoPalette`, but v2 does not paint category
backgrounds with them** (see §7).

| Name | Hex |
|---|---|
| Blue | `#2E86AB` |
| Coral | `#E4572E` |
| Grass | `#6A994E` |
| Teal | `#4C956C` |
| Terracotta | `#C1666B` |
| Sunshine | `#F6BD60` |
| Grape | `#8E44AD` |
| Sky | `#1B9AAA` |

Rules: **≤ 3 accents per screen**, **≤ 4 colors per sticker** (see §8). A sticker's
**white outline is what guarantees contrast** against any themed background, so the
accents inside are free to be vivid.

### Cell background — a *dynamic* theme token

The color *behind* the stickers is **not fixed** — it's the themeable
`BingoTokens.cellBackground` token. The default (light) value is White and the
default (dark) value is a deep slate, so today the board reads as white stickers on
white/dark. **A future theme just overrides this one token** (see §7 for a Christmas
example). This is why stickers are die-cut with a transparent surround (§8): so the
themed background shows through.

### Semantic & difficulty

| Token | Light | Dark | Use |
|---|---|---|---|
| Free space | `#F6BD60` | `#D9A441` | The centre free tile |
| Celebration | `#2E7D32` | `#66BB6A` | Win banner / success |
| Difficulty · Easy | `#2E7D32` | `#81C784` | "Easy" chip |
| Difficulty · Medium | `#E08A00` | `#FFB74D` | "Medium" chip |
| Difficulty · Hard | `#C62828` | `#EF9A9A` | "Hard" chip |

Difficulty is always **label + color**, never color alone.

---

## 3. Typography

Rounded, friendly, legible. **Recommended family: [Fredoka](https://fonts.google.com/specimen/Fredoka)**
for display/headline (playful rounded) and **[Nunito Sans](https://fonts.google.com/specimen/Nunito+Sans)**
(or the system sans) for body. Fonts are *not bundled yet* — until they are, the app
uses the platform default; wire them in `pubspec.yaml` `fonts:` and `app_theme.dart`
`textTheme` when ready.

| Role | Size / Weight | Notes |
|---|---|---|
| Display | 32 / 700 | Home headline |
| Headline | 24 / 700 | Screen titles, item name in detail |
| Title | 18 / 600 | Buttons, list rows |
| Body | 15 / 400 | Descriptions |
| Caption | 11–13 / 600 | Tile caption (clamped to 1.3× scale in-cell) |
| Label | 13 / 600 | Chips, overlines |

Never bake text into a sticker (§8). The item name is drawn by the app so tiles stay
font- and localization-independent.

---

## 4. Shape & radius

Soft, consistent rounding everywhere. One scale (`AppRadii`):

| Token | px | Use |
|---|---|---|
| `xs` | 8 | Chips, small controls |
| `sm` | 12 | Inputs, small buttons |
| `md` | 16 | **Cells/tiles, primary buttons** (`BingoTokens.cellRadius`) |
| `lg` | 24 | Cards, sheets, detail pane |
| `xl` | 32 | Large containers, dialogs |
| `pill` | 999 | Fully rounded pills |

The **cell** is a rounded square (radius `md` = 16). It clips the themed
`cellBackground` and the die-cut sticker floating on it. The sticker itself has **no
rounded frame** — its shape is the subject's silhouette (§8).

---

## 5. Elevation & shadow

Minimal, soft, single-layer. Elevation says "tappable/liftable," nothing more.

- Cells: one soft shadow, `blur 4`, `offset (0, 2)`, opacity from
  `BingoTokens.cellShadowOpacity` (light `0.12`, dark `0.30`).
- Cards/sheets: Material 3 at `0` elevation + the radius scale; prefer a hairline
  `Line` border over a heavy shadow.
- **No shadow baked into sticker art.** The white outline provides sticker "lift";
  the cell provides UI elevation.

---

## 6. Spacing, icons & motion

- **Spacing scale (`AppSpacing`):** `4, 8, 12, 16, 24, 32, 48`. Default gutter 16;
  screen padding 24; grid gap 8.
- **Icons:** Material Symbols **Rounded**, filled variants for state (e.g.
  `check_circle_rounded`, `auto_awesome_rounded`). Consistent optical size.
- **Motion:** quick and springy. Mark toggle = a small scale "pop" (0.9 → 1.0,
  ~180 ms, ease-out-back). Transitions 150–250 ms. Win = one celebratory bounce,
  never a long blocking animation. Respect `MediaQuery.disableAnimations`.

---

## 7. Components (quick specs)

| Component | Spec |
|---|---|
| **Filled button** | Brand blue, `md` radius, Title text, vertical padding 12, full-width on Home. |
| **Cell / tile** | Themed `cellBackground`, `md` radius clip, soft shadow; a die-cut sticker (§8) floats on it; selected = 3 px brand-blue ring. Marked = 50% ink scrim + white `check_circle_rounded`. Free = `Sunshine` fill + `auto_awesome_rounded`. |
| **Difficulty chip** | Label + difficulty color; `xs` radius; 18% tint fill + solid color border. |
| **Card / detail pane** | White, `lg` radius, hairline `Line` border, 20–24 padding; the item image sits on the same themed `cellBackground` for parity with the board. |
| **App bar** | Flat, `Cloud`/surface, ink title, no drop shadow. |

### Theming the background (dynamic)

Because the cell background is the single token `BingoTokens.cellBackground`, a whole
new seasonal look is a token override — no art changes. Example Christmas theme:

```dart
// A festive variant: same die-cut stickers, red board.
static const christmas = BingoTokens(
  cellBackground: Color(0xFFB3261E), // deep Christmas red
  cellFree: Color(0xFF2E7D32),       // green free space
  // ...the rest inherited/tuned as needed
);
```

The white-outlined stickers pop on the red exactly as they do on white.

> **Category color is intentionally *not* surfaced in v2 chrome.** It stays in the
> data model and `BingoPalette` for future use (filters, legends), but nothing
> renders a category-colored background today.

---

## 8. The tile sticker system

Every board tile is a **silhouette die-cut sticker**: one bold subject, wrapped by a
uniform **white outline**, on a **transparent** surround so the themed cell
background (§2/§7) shows around it. Consistency across ~30–60 tiles from mixed
sources (authentic road signs + AI art) is what makes the board read as one
intentional set instead of a scrapbook.

### 8.1 Canvas & geometry

| Property | Value |
|---|---|
| Master format | **SVG** (vector) preferred; **transparent PNG** accepted for AI output |
| Authoring canvas | **512 × 512**, aspect **1:1** only |
| Background | **Transparent.** Never bake a solid background — the app draws the themed `cellBackground` behind the sticker. |
| White outline (die-cut) | Uniform white keyline hugging the subject silhouette, **≈ 16–20 px on the 512 canvas**. Consistent width across all tiles. |
| Safe area | Subject + its outline fully inside the center **≈ 430 × 430** box (the build adds a transparent margin so the outline never touches the cell edge). |
| Corner radius | Applied by the *cell* to the background, not to the art. Do not bake corners into the sticker. |
| Export | WebP @ 512 px **with alpha**, quality 90, single density. |
| Composition | **One subject, centered.** No scenes, no multiple focal points. |

### 8.2 Visual language

- **Bold & flat-ish.** Vibrant solid fills; a *single* soft tint or flat shadow for
  depth is allowed, but no photorealism and no heavy gradients.
- **The white outline does the contrast work.** Because every sticker is wrapped in a
  consistent white keyline, the subject reads on any themed background (white, dark,
  red). Keep the outline uniform — that uniformity is what unifies the set.
- **Line weight (interior).** If outlining details, one consistent weight ≈
  **stroke 12** on the 512 canvas (~2.3%). Rounded joins/caps — friendly geometry.
- **≤ 4 colors per sticker**, drawn from the §2 accent palette + ink; plus the white
  outline.
- **Squint test.** Readable as a silhouette at **48 px**. If you can't tell what it
  is when tiny, simplify.

### 8.3 Road signs — the accurate exception

Real signs have legally fixed colors/shapes. Render them as **flat, accurate
pictograms in the sign's own palette** (e.g. red-bordered white warning triangle),
then wrap the whole sign in the standard white die-cut outline so it still reads as
part of the sticker set. **Do not recolor a sign** — keep it accurate; harmonize via
the shared outline and flat style.

---

## 9. AI sticker generation template

Use one **fixed scaffold + a reference image + a stable seed** so outputs land in the
same visual family. Then run every output through the same pipeline (§10).

### 9.1 Prompt scaffold (fill the `<slots>`)

```
A single <SUBJECT>, centered, as a die-cut sticker illustration.
Square 1:1 composition, centered with even padding on all sides. Bold,
playful, minimal — chunky rounded shapes, thick clean interior lines,
high contrast. Vibrant flat colors from this palette: <2–3 HEX FROM §2>.
Wrapped in a THICK EVEN WHITE STICKER BORDER that hugs the subject's
outline. Fully TRANSPARENT background (PNG with alpha) — no scene, no
ground, no cast shadow. One subject only, simple and iconic, readable as
a tiny icon. No text, no letters, no watermark.
```

> **Aspect ratio is a *parameter*, not prose.** The "square 1:1" line above
> reinforces the intent, but you must also set the model's size/aspect control to a
> square — e.g. `1024×1024`, or `--ar 1:1` (Midjourney) — or it won't be honored.
> Don't put a literal `512×512` in the prompt: generate large (≥ 1024²) and let the
> pipeline downscale to the 512 export target (§8.1).

**Negative prompt:**
```
photo, photorealistic, 3d render, gradient mesh, busy background, scene,
multiple objects, solid background, colored background, drop shadow on
background, text, letters, numbers, watermark, signature, clipped edges,
thin or uneven border, non-square, portrait, landscape, noise, grain
```

### 9.2 Per-category prompt hints

Pick the subject's accent from §2 — these are *hints* for the subject's fills; the
background stays transparent:

| Category | Lead accent(s) | Hint |
|---|---|---|
| Road signs | sign's real colors | accurate pictogram; keep legal palette |
| Vehicles | Blue `#2E86AB`, Sky `#1B9AAA` | side/front-on, chunky wheels |
| Animals | Grass `#6A994E`, Sunshine `#F6BD60` | friendly, front-facing, big features |
| Nature | Teal `#4C956C`, Sunshine `#F6BD60` | single element (one tree, one sun) |
| Buildings | Terracotta `#C1666B`, Coral `#E4572E` | one structure, head-on elevation |

### 9.3 Consistency workflow

1. Lock a **reference image** (one approved hero sticker) and pass it to the model
   for style transfer on every generation — this keeps the **white border width and
   the flat look uniform**, which is the whole game.
2. Keep a **stable seed** per batch; vary only `<SUBJECT>`.
3. Save the **exact prompt + model + seed** into `item.json` `license` (§11).
4. Generate **square 1:1 at ≥ 1024×1024** (set the size/aspect parameter — see the
   note under §9.1), then let the pipeline downscale to the 512 export target.

---

## 10. Post-process pipeline (mandatory, uniform)

Raw AI output is never shipped directly. Normalize it, drop it in
`content/items/<id>/master.(svg|png)`, then let the build enforce the frame:

1. **Clean the alpha:** remove any background matte / halo so the surround is
   *truly transparent* (this is what lets the themed background show).
2. **Verify the white border** is present and even; trim & center the subject.
3. Set `item.json` `image` (`px`, `master` filename, `format`).
4. Run the pipeline:
   ```bash
   npm run validate && npm run build
   ```
   `build-catalog.mjs` treats every tile identically: contain into the inner box, add
   a uniform **transparent** safe-area margin, export **WebP with alpha** (no
   flatten). Corner rounding and the background color are the app's job, not the
   file's.
5. Eyeball it in a real cell against multiple themes: `flutter run -d chrome`.

Placeholders (`make-placeholders.mjs`) already emit v2-correct die-cut stickers — a
vibrant accent glyph with a white outline on transparency — so the board looks right
(and theming works) before real art lands. Regenerate them after a style tweak with
`node scripts/make-placeholders.mjs --force` (only touches `placeholder`-licensed
items).

---

## 11. Provenance & licensing (per tile, mandatory)

Every `item.json` records a `license` block. It **records** a decision; it clears
nothing.

- **AI art:** `source: "ai:<model>"`, keep the **exact `prompt`** and `seed`, prefer a
  model with clear commercial terms, expect to declare AI use at store review.
- **Road signs:** verify reuse terms first; if Statens vegvesen, set
  `source: "statens_vegvesen"`, the real `type`/`url`, and `attributionRequired`.
- **Placeholders (current):** `source: "placeholder"`, `type: "CC0-1.0"`.

---

## 12. Production checklist (per tile)

- [ ] 512-authored, **transparent background**, one centered subject
- [ ] Uniform **white die-cut outline** hugging the silhouette (≈ 16–20 px @ 512)
- [ ] Vibrant, ≤ 4 colors, high contrast; reads on white **and** dark **and** red
- [ ] Passes the **48 px squint test**
- [ ] **No baked-in text**; no baked background; no baked corners/shadow
- [ ] `item.json` `license` filled with real provenance (prompt/seed for AI)
- [ ] `difficulty` reflects real-world spot-rarity (Easy 1–2 / Medium 3 / Hard 4–5)
- [ ] `npm run validate && npm run build` pass; eyeballed in a cell across themes

---

## 13. Where the tokens live (code map)

| Concept | Source of truth |
|---|---|
| Seed / `ColorScheme` / component shapes | `lib/core/theme/app_theme.dart` |
| Game tokens incl. **dynamic `cellBackground`**, marked/free/celebration/difficulty, radius, shadow | `lib/core/theme/bingo_tokens.dart` → `BingoTokens` |
| Playful accent palette, radius scale, spacing scale | `lib/core/theme/bingo_tokens.dart` → `BingoPalette` / `AppRadii` / `AppSpacing` |
| Themed variants (e.g. Christmas) | additional `BingoTokens` presets (see §7) |
| Category colors (data, unused in chrome) | `content/catalog.config.json` |
| Transparent tile export + safe-area margin | `scripts/build-catalog.mjs` |
| Die-cut placeholder stickers | `scripts/make-placeholders.mjs` |

---

## 14. Changelog (v1 → v2)

- **Tiles are now silhouette die-cut stickers** — transparent art wrapped in a
  uniform white outline — replacing v1's flat pictograms baked onto category-colored
  backgrounds.
- **The cell background is a dynamic theme token** (`BingoTokens.cellBackground`),
  so a seasonal theme (e.g. a red Christmas board) is a one-token override with no art
  changes. The white sticker outline guarantees contrast on any background.
- **Category color is no longer rendered** as tile/cell backgrounds; it stays in the
  data model + `BingoPalette` for future use.
- Added an app-wide design language: neutrals, playful accent palette, type scale
  (rounded font recommendation), radius/spacing scales, motion, component specs.
- The build now exports **transparent WebP** (alpha preserved); background color and
  corner rounding are applied by the app, not baked per tile.
