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
// A festive variant: same die-cut stickers, red board. Derive from a preset with
// copyWith so only the overridden tokens change (const constructor needs every arg,
// so this is `static final`, not `static const`).
static final christmas = BingoTokens.light.copyWith(
  cellBackground: const Color(0xFFB3261E), // deep Christmas red
  cellFree: const Color(0xFF2E7D32),       // green free space
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
| Master format | **PNG — coloured subject on solid white, NO border** for AI output; **SVG** (vector, transparent, carries its own outline) also fine for hand-drawn art |
| Authoring canvas | **512 × 512**, aspect **1:1** only |
| Background | **Solid flat white** for raster/AI masters — the build removes it to transparency and draws the outline (§10). Subject only, even padding, nothing touching the edge. Vector SVG masters are authored transparent instead. Either way the final tile is transparent so the themed `cellBackground` shows through. |
| White outline (die-cut) | **Drawn by the build** for raster masters (uniform width = `stickerOutlineRatio` × px ≈ **18 px @ 512**), so it's byte-identical across every tile. Do NOT draw a border in AI output. SVG masters carry their own. |
| Safe area | Subject + its outline fully inside the center **≈ 430 × 430** box (the build adds a transparent margin so the outline never touches the cell edge). |
| Corner radius | Applied by the *cell* to the background, not to the art. Do not bake corners into the sticker. |
| Export | WebP @ 512 px **with alpha**, quality 90, single density. |
| Composition | **One subject, centered.** No scenes, no multiple focal points. |

### 8.2 Visual language

- **Bold & flat-ish.** Vibrant solid fills; a *single* soft tint or flat shadow for
  depth is allowed, but no photorealism and no heavy gradients.
- **The white outline does the contrast work.** Every sticker is wrapped in a white
  keyline (build-drawn for raster art) so the subject reads on any themed background
  (white, dark, red). Because the build draws it, the width is uniform by construction
  — that uniformity is what unifies the set.
- **Keep subject colours clear of white.** The background remover keys out
  edge-connected near-white, so a subject whose *silhouette* is white (a swan, a white
  sign face) can lose its edge. Give such subjects an ink outline or a slightly
  off-white fill; interior white fully enclosed by colour is safe.
- **Line weight (interior).** If outlining details, one consistent weight ≈
  **stroke 12** on the 512 canvas (~2.3%). Rounded joins/caps — friendly geometry.
- **≤ 4 colors per sticker**, drawn from the §2 accent palette + ink; plus the white
  outline.
- **Squint test.** Readable as a silhouette at **48 px**. If you can't tell what it
  is when tiny, simplify.

### 8.3 Road signs — the accurate exception

Real signs have legally fixed colors/shapes. Render them as **flat, accurate
pictograms in the sign's own palette** (e.g. red-bordered white warning triangle) on
the solid white background; the build's outline wraps the whole sign so it still reads
as part of the sticker set. **Do not recolor a sign** — keep it accurate; harmonize
via the shared (build-drawn) outline and flat style. *Caution:* a white-faced sign can
be trimmed by the background remover — give it a dark border/edge so its silhouette
isn't pure white.

---

## 9. AI sticker generation template

Use one **fixed scaffold + a reference image** so outputs land in the same visual
family. Then run every output through the same pipeline (§10).

### 9.1 Prompt scaffold (fill the `<slots>`)

```
A single <SUBJECT>, in <ORIENTATION> (e.g. standing side profile),
centered, as a flat vector illustration. Square 1:1 composition, centered
with generous even padding on all sides. Bold, playful, minimal — chunky
rounded shapes, thick clean interior lines, high contrast. Instantly
recognizable at tiny sizes; simplify away fine detail. Using ONLY these
colors: <HEX>, <HEX>, <HEX> — no other colors. Place it on a SOLID FLAT
WHITE background (#FFFFFF) that completely fills the frame — no scene, no
ground, no cast shadow, no gradient. Do NOT draw any border, outline, or
sticker edge around the subject. One subject only. No text, no letters,
no watermark.
```

Why each clause is there (from real icon-set experience):
- **`<ORIENTATION>` (e.g. standing side profile)** — pins the pose so the set doesn't
  drift between front- and side-facing. Use the *same* orientation for every item in a
  category (§9.2).
- **"Using ONLY these colors … — no other colors"** — a hard allow-list prevents the
  model sneaking in stray hues. List exact hex (≤ 4, per §8.2).
- **"Instantly recognizable at tiny sizes; simplify away fine detail"** — forces the
  silhouette-first simplification the 48 px squint test (§8.2) checks for.
- **"SOLID FLAT WHITE background … Do NOT draw any border/outline"** — AI models can't
  reliably emit real alpha, so we generate on flat white and the **build** removes it
  and draws the die-cut outline itself. Letting the model draw the border makes the
  width vary tile-to-tile; leaving it to the build makes it byte-identical. **Keep the
  subject's silhouette clear of white** (§8.2) so the background remover doesn't trim
  its edge — give white-ish subjects a dark edge or off-white fill.

> **Aspect ratio is a *parameter*, not prose.** The "square 1:1" line above
> reinforces the intent, but you must also set the model's size/aspect control to a
> square — e.g. `1024×1024`, or `--ar 1:1` (Midjourney) — or it won't be honored.
> Don't put a literal `512×512` in the prompt: generate large (≥ 1024²) and let the
> pipeline downscale to the 512 export target (§8.1).

**Negative prompt:**
```
photo, photorealistic, 3d render, gradient mesh, busy background, scene,
multiple objects, colored background, gradient background, shaded
background, transparent background, checkerboard, drop shadow, border,
outline, sticker edge, frame, text, letters, numbers, watermark,
signature, clipped edges, extra colors, off-palette colors, mixed
orientation, non-square, portrait, landscape, noise, grain
```

### 9.2 Per-category orientation & palette

**Lock one orientation per category and hold every item in that category to it** —
mixed front/side views within a category are the single most common thing that breaks
a set's consistency. The colors below are the *only* colors for that category's
subjects (the build adds the white outline separately); feed them into the "Using ONLY
these colors" slot.

| Category | Orientation (fixed) | Use ONLY these colors |
|---|---|---|
| Road signs | flat front-on pictogram | the sign's real, legal colors |
| Vehicles | **side profile** (side-on), chunky wheels | Blue `#2E86AB`, Sky `#1B9AAA`, Ink `#16212B` |
| Animals | **standing side profile**, big friendly features | Grass `#6A994E`, Sunshine `#F6BD60`, Ink `#16212B` |
| Nature | front-on, single element (one tree, one sun) | Teal `#4C956C`, Sunshine `#F6BD60`, Ink `#16212B` |
| Buildings | head-on elevation, one structure | Terracotta `#C1666B`, Coral `#E4572E`, Ink `#16212B` |

### 9.3 Consistency workflow

1. Lock a **reference image** (one approved hero subject) and pass it to the model for
   style transfer on every generation — this keeps the **subject style and flat look
   uniform** (the border is the build's job, so it's already uniform).
2. Batch **by category**: keep the fixed `<ORIENTATION>` and the category's color
   allow-list constant across the batch — vary only `<SUBJECT>`.
3. Save the **exact prompt + model** into `item.json` `license` (§11).
4. Generate **square 1:1 at ≥ 1024×1024** (set the size/aspect parameter — see the
   note under §9.1), then let the pipeline downscale to the 512 export target.

---

## 10. Post-process pipeline (mandatory, uniform)

Raw AI output is never shipped directly. Normalize it, drop it in
`content/items/<id>/master.(svg|png)`, then let the build enforce the frame:

1. **Confirm a clean white background:** the surround should be even, near-pure white
   with no gradient/shadow/noise, the subject centered with padding and **no part
   touching the edge**, and the subject's silhouette not pure white (§8.2). Do **not**
   draw a border — the build adds it.
2. Set `item.json` `image` — for a non-default master, set `master` (e.g.
   `"master.png"`); `format` stays `webp` (it's the built-tile output). Update the
   `license` block (§11).
3. Run the pipeline:
   ```bash
   npm run validate && npm run build
   ```
   `build-catalog.mjs` frames every tile identically: for raster masters it **removes
   the white background to alpha (flood-fill from the edges) and draws the uniform
   white die-cut outline** (SVGs skip this — already transparent), then adds a
   **transparent** safe-area margin and exports **WebP with alpha** (no flatten).
   Corner rounding and background colour are the app's job. Outline width is
   configurable via `stickerOutlineRatio` in `content/catalog.config.json`.
4. Eyeball it in a real cell against multiple themes: `flutter run -d chrome`.

Placeholders (`make-placeholders.mjs`) already emit v2-correct die-cut stickers — a
vibrant accent glyph with a white outline on transparency — so the board looks right
(and theming works) before real art lands. Regenerate them after a style tweak with
`node scripts/make-placeholders.mjs --force` (only touches `placeholder`-licensed
items).

---

## 11. Provenance & licensing (per tile, mandatory)

Every `item.json` records a `license` block. It **records** a decision; it clears
nothing.

- **AI art:** `source: "ai:<model>"`, keep the **exact `prompt`**, prefer a model with
  clear commercial terms, expect to declare AI use at store review.
- **Road signs:** verify reuse terms first; if Statens vegvesen, set
  `source: "statens_vegvesen"`, the real `type`/`url`, and `attributionRequired`.
- **Placeholders (current):** `source: "placeholder"`, `type: "CC0-1.0"`.

---

## 12. Production checklist (per tile)

- [ ] 512-authored, one centered subject on a **flat white background** (raster) or
      **true transparency** (vector SVG); generous padding, nothing touching the edge
- [ ] **No border drawn in the art** — the build adds the uniform white outline
- [ ] Subject silhouette **not pure white** (else the background remover trims it)
- [ ] Vibrant, ≤ 4 colors, high contrast; reads on white **and** dark **and** red
- [ ] Passes the **48 px squint test**
- [ ] **No baked-in text**; no baked corners/shadow; no gradient/shaded background
- [ ] `item.json` `license` filled with real provenance (prompt for AI)
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
| Sticker margin ratio, outline width (`stickerOutlineRatio`) | `content/catalog.config.json` |
| White-bg removal + build-drawn outline + transparent export | `scripts/build-catalog.mjs` |
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
- Raster/AI masters are authored as a **coloured subject on flat white, with no
  border**: the build removes the white background (edge flood-fill) and **draws the
  white die-cut outline itself**, so the outline is byte-identical on every tile and
  the workflow doesn't depend on the true alpha AI models can't emit.
