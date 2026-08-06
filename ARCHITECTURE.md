# Car Bingo — Target Architecture

> A single-codebase, offline-first mobile bingo game for road trips. Native iOS + Android, phone + tablet. Solo play ships first; the data model and backend are shaped so async and real-time multiplayer bolt on later without a rewrite.
>
> **Status:** target architecture for a solo hobby developer. Version-checked August 2026 (Flutter 3.44 / Dart 3.12; Firestore Spark free tier 50K reads / 20K writes / 20K deletes per day, 1 GiB, one default DB; Cloud Storage requires Blaze since Feb 3 2026).

## Executive summary

Build Car Bingo as a single **Flutter (Dart)** app for iOS and Android, phone and tablet, distributed only through the App Store and Google Play. Flutter is the cleanest fit for the exact constraint set: Google-maintained FlutterFire with **Firestore offline persistence on by default**, the healthiest on-device database story (**Drift/SQLite**), first-class Material 3 adaptive layouts, and Impeller (now the default and only renderer on Android 10+ and iOS) for smooth check-off animations. The MVP runs on the **Firebase Spark free plan** — which has a real hard cap (a product simply stops serving for the rest of the month if you exceed the free quota, and can never bill you) — because the solo app uses **no Cloud Storage and no Cloud Functions**. The catalog of road items is treated as **versioned data, fully bundled in the app binary for the MVP** (≈100–300 WebP tiles ≈ 5–18 MB), so a complete, winnable game works the instant the app opens in a tunnel having never had signal. Firestore holds **only tiny per-user progress documents**; the on-device store (Drift) is the local source of truth for progress until a real anonymous UID exists, which fixes the one scenario that would otherwise silently eat a first-ever offline session. Boards are a **pure deterministic function of a small frozen seed spec**, so solo play is the one-player case of the exact schema that async and real-time multiplayer reuse. Deferred-until-actually-needed: Blaze + billing guardrails, Cloudflare R2/CDN content packs, Cloud Functions, RTDB presence, and CRDT-grade conflict machinery.

### Recommended stack at a glance

| Layer | Choice (MVP) | Why / one-line |
|---|---|---|
| Client framework | **Flutter 3.44 / Dart 3.12** | One codebase, native iOS+Android phone+tablet, best offline + Firebase + adaptive story. |
| Rendering | **Impeller** (default, only option on Android 10+/iOS) | Precompiled shaders → consistent 60/90/120 fps, no first-frame jank. Verify on real mid-range Android. |
| Local persistence | **Drift (SQLite)** | Type-safe, reactive, maintained. Local source of truth for catalog **and** progress-before-sync. |
| Sync datastore | **Cloud Firestore** (offline persistence on) | Zero-config write queue + snapshot listeners = solo→multiplayer on one API. Progress only. |
| Backend plan | **Firebase Spark (free, hard-capped)** for MVP/v1 | No Storage, no Functions in solo ⇒ Spark's shut-off cap is a stronger, zero-code cost guard than Blaze. |
| Auth | **Anonymous Auth → `linkWithCredential` (Apple + Google)** | Instant play; stable UID owns all data; upgrades with no progress loss. Never phone auth (paid). |
| Catalog source of truth | **Git-versioned JSON + JSON Schema (CI-validated)** | Free, diffable, reviewable, offline by definition. No CMS, no Firestore catalog. |
| Catalog images | **WebP, fully bundled in the binary (MVP)** | Universal native decode (AVIF has no core Flutter codec); ~15–60 KB/tile. |
| Content delivery | **Bundled only (MVP)** → R2+CDN packs later | Whole catalog fits in the binary now; defer the download pipeline until it doesn't. |
| Board generation | **Pure deterministic seeded generator** (sfc32 / cyrb128) | `board = f(seed,size,catalogVersion,algoVersion,configHash)`; golden-tested in CI. |
| State / DI | **Riverpod 3 (code-gen)** | One system for state + DI; `AsyncValue` models sync states; `autoDispose` bounds listeners. |
| Navigation | **go_router** | Flutter-team maintained; shell + redirect guards; deep-link seam for later sharing. |
| UI localization | **`flutter_localizations` + `intl` + gen-l10n (ARB)** | First-party, in-binary, CLDR plurals. Fine for 1–3 launch locales. |
| Content localization | **Locale-keyed maps + one English-defaulting resolver** | Add a language with no migration; a fixed grid never loses a cell. |
| Theming | **Material 3 `ColorScheme.fromSeed` + typed `ThemeExtension`** | Light + dark for MVP; compile-time token completeness. |
| Adaptive layout | **Material 3 width breakpoints + a ~60-line `AppShell`** | Branch on available width, never "is-tablet." (`flutter_adaptive_scaffold` is discontinued.) |
| CI / delivery | **One system: Codemagic** (or GitHub Actions + Fastlane) | Flutter-native build + Apple signing + store publish. Drop the split until it hurts. |
| Observability | **Crashlytics + Analytics + Performance** (opt-in, off by default) | Free; GDPR-safe; consent-gated. |

## Architecture & data flow

```
                    ROAD TRIP — must remain fully playable with zero connectivity
 ┌───────────────────────────────────────────────────────────────────────────────────┐
 │                      MOBILE DEVICE  (iOS + Android · phone + tablet)                │
 │  ┌─────────────────────────────────────────────────────────────────────────────┐  │
 │  │                 FLUTTER APP  (Dart 3.12 · Impeller · Material 3)              │  │
 │  │  PRESENTATION            DOMAIN (pure Dart)          DATA                     │  │
 │  │  ┌──────────────┐       ┌───────────────────┐      ┌────────────────────────┐│  │
 │  │  │ Adaptive UI  │◄────► │ Deterministic      │◄───► │ Drift / SQLite         ││  │
 │  │  │ (breakpoints │       │ seeded generator   │      │  • item catalog        ││  │
 │  │  │  + theme     │       │ + win detection    │      │  • persisted board     ││  │
 │  │  │  + i18n)     │       │ + repo interfaces  │      │    layout + PROGRESS    ││  │
 │  │  │  Riverpod    │       └───────────────────┘      │    (local SoR)         ││  │
 │  │  └──────────────┘                                   │  • outbox (to Firestore)││  │
 │  │        ▲                ┌───────────────────┐      └────────────────────────┘│  │
 │  │        └───────────────►│ BUNDLED catalog    │─────►┌────────────────────────┐│  │
 │  │                         │ (all items + WebP  │      │ Firestore SDK cache    ││  │
 │  │                         │  in the binary)    │      │ (progress sync, on)    ││  │
 │  │                         └───────────────────┘      └────────────────────────┘│  │
 │  └─────────────────────────────────────────────────────────────────────────────┘  │
 └────────────────────────────────────────┬──────────────────────────────────────────┘
                        opportunistic sync │ (PROGRESS ONLY, after real anon UID)
        ════════════════════════════════════╪═══════════════════════════════════════════
                                            ▼
        ┌──────────────────────────────────────────────────────────────────┐
        │                     FIREBASE  (Spark, free, hard-capped)          │
        │  ┌────────────────┐  ┌────────────────┐  ┌────────────────────┐   │
        │  │ Firestore      │  │ Anonymous Auth │  │ Crashlytics /       │   │
        │  │ PROGRESS ONLY: │  │  → link        │  │ Analytics / Perf    │   │
        │  │ boards/{id}    │  │  Apple/Google  │  │ (opt-in, off default)│  │
        │  │  /players/{uid}│  └────────────────┘  └────────────────────┘   │
        │  └────────────────┘                                               │
        │  ┌───────────────────────────────────────────────────────────┐   │
        │  │ [ DEFERRED — added only when the feature ships ]            │   │
        │  │  • Blaze plan + budget guardrails (when Storage/Functions) │   │
        │  │  • Cloudflare R2 + CDN content packs (when catalog > binary)│   │
        │  │  • Cloud Functions: joinBoard (async), validateWin (RT)    │   │
        │  │  • RTDB onDisconnect presence (real-time)                  │   │
        │  │  • Remote Config content pointer + flags                   │   │
        │  └───────────────────────────────────────────────────────────┘   │
        └──────────────────────────────────────────────────────────────────┘
```

**Reading it:** everything inside the device runs with no network — the bundled catalog and images are always present, the generator produces the board locally, and progress is written to Drift immediately. Firestore is a sync transport for tiny progress docs and only after a real anonymous UID exists. The entire dashed block is deferred; nothing above it changes when those pieces arrive.

## 1. North-star principles

Resolve ambiguous trade-offs in this order.

**P1 — Offline-first is the ground truth; the network is an optimization.** The board, the item catalog, and the images are all usable with zero connectivity on first launch. The cloud backs up and shares state, never enables core play. A complete, winnable game must exist the instant the app opens in airplane mode having never had signal — *including the very first launch* (see §4, the fix for pre-auth progress).

**P2 — Content-as-data.** Road items are immutable, versioned data authored in git, validated by schema, and (for the MVP) compiled straight into the app binary. The catalog is never read live from Firestore and images are never streamed on demand. Firestore holds mutable per-user progress only.

**P3 — Multiplayer-ready without a rewrite.** The data model ships shaped for many players: an immutable board *spec* separated from per-player *progress*, where solo is the one-player instance of that exact schema. The generator is a pure, deterministic, versioned function of a seed, so any two devices reproduce an identical board offline — the prerequisite for shared boards and later free server-side anti-cheat.

**P4 — Leanest viable MVP (the tie-breaker this document adds).** Where a feature exists only to serve multiplayer or a content operation that is not being built yet, defer it and keep only the cheap seam. Every descope below follows from this.

## 2. Recommended stack — and why (with the contradictions resolved)

Flutter beats the alternatives for this constraint set: React Native's Firebase-JS offline persistence is broken on RN (needs the native SDK + a dev build); Kotlin Multiplatform still has no official Firebase SDK in 2026; .NET MAUI has 2026 tooling regressions and no official Firebase. The accepted cost is that Dart is a niche language with a ~2–3 week learning curve for a solo dev.

Local storage is **Drift** (type-safe, reactive, maintained). Realm's sync engine was killed and never open-sourced; Hive/Isar are abandoned. Reviewers suggested holding a ~300-item read-only catalog in memory to shed a dependency — but Drift now earns its place regardless, because the offline-correctness fix (§4) needs a *durable local store for progress before auth*, and Drift is the natural home for that plus the persisted board layout.

Images are **WebP everywhere**, not AVIF: Flutter has no core AVIF decoder and mobile AVIF decode is flaky, so bundled AVIF risks broken tiles. AVIF stays a possible future optimization for remote-only packs.

**Contradictions resolved (leaner option wins):**

- **Spark, not Blaze, for MVP/v1.** The prior design mandated Blaze "because Storage/Functions require it" — but the solo app uses neither. On Spark, a runaway listener or unbounded query simply stops serving at the daily cap and resets next day: a brief outage, which for a hobby app *is* graceful degradation and can never bill. That is a stronger guard than Blaze's uncapped bill plus a hand-built circuit breaker. Move to Blaze only at the phase that first ships a Cloud Function or Cloud Storage. **This deletes the Pub/Sub disable-billing function, the $0.01 alert, and App Check from MVP scope.**
- **Bundle the whole catalog; defer R2/CDN packs.** At 50–300 items, WebP tiles total ≈ 5–18 MB — trivially bundleable. The manifest/delta/checksum/atomic-apply/Remote-Config-pointer subsystem, a second vendor, and a whole class of failure modes (half-applied packs, eviction, locale-pack gaps) all wait until the catalog genuinely outgrows the binary budget or you need no-review content updates.
- **Progress is local-first in Drift, synced whole-doc to Firestore after auth.** This resolves the "one store per concern (Firestore only)" claim against the offline mandate — see §4.
- **No Firestore catalog mirror in MVP.** It is never read in solo, contradicts the offline/generator sections, and is a latent per-read cost trap. Add a server-side catalog only when a Cloud Function needs it (v3 anti-cheat), and if it exists make client reads `allow read: if false`.
- **One Firebase project, one CI system, no Shorebird, light+dark only** for MVP (see §11, §8, §7).

## 3. Client app architecture

Four layers, strict inward dependency rule (dependencies point down; `domain` imports neither Flutter nor Firebase).

```
PRESENTATION  ConsumerWidgets, adaptive layout   — renders state, dispatches intent
STATE         Riverpod Notifier/AsyncNotifier    — orchestrates use-cases, holds AsyncValue
DOMAIN        pure Dart: entities, repo INTERFACES, deterministic generator, win rules
DATA          repo IMPLEMENTATIONS: Drift, Firestore SDK, bundled-asset reader
```

The pure-Dart domain is load-bearing: the generator and win detection must be byte-reproducible, unit-testable with golden vectors, and reusable server-side later. Keeping them free of `package:flutter` and `cloud_firestore` guarantees that.

**State/DI: Riverpod 3 (code-gen).** Controllers are `Notifier`/`AsyncNotifier` exposing `AsyncValue<T>` (loading/error/data pairs naturally with an app that is often mid-sync). Repositories are providers overridden at `ProviderScope` and in tests — one system for state and DI, no service locator. `keepAlive` the catalog/repositories; default `autoDispose` for screen controllers so leaving the board tears down its listeners. Follow riverpod.dev v3 docs (breaking changes vs 2.x); do **not** rely on Riverpod's experimental persistence — real persistence is Drift + the Firestore cache.

**Navigation: go_router** with `StatefulShellRoute.indexedStack` for a small tabbed shell and one declarative `redirect` guard for onboarding. Register `/board/:boardId` and `/join/:code` now but leave them inert — the cost of the seam is near-zero and it makes sharing additive. Keep navigation isolated in `app/router` so go_router's fast iteration is contained.

**Adaptive navigation** is built on framework `NavigationRail`/`NavigationBar` inside a ~60-line in-repo `AppShell`. Do **not** depend on `flutter_adaptive_scaffold` — it is discontinued (flutter/flutter#162965).

### Responsiveness — phone vs tablet, 3×3–5×5, orientation

Governing rule: **branch on available width/space, never on "is this a tablet."** This folds phone/tablet and portrait/landscape into one continuum via Material 3 breakpoints (compact <600, medium <840, expanded <1200 dp).

| Window size | Navigation | Play screen |
|---|---|---|
| compact (phone portrait) | bottom `NavigationBar` | single pane; item detail = modal bottom sheet |
| medium (phone landscape / small tablet) | collapsed `NavigationRail` | board + detail pane if leftover width ≥ ~360 dp, else sheet |
| expanded / large (tablet) | extended `NavigationRail` | master–detail two-pane: board left, detail right |

The board is always a **centered square** sized to the shorter side of the content area, so it stays square in both orientations; leftover width becomes the detail pane, never stretched cells.

```dart
LayoutBuilder(builder: (ctx, c) {
  const minDetail = 360.0, gap = 16.0;
  final canSplit = c.maxWidth - c.maxHeight >= minDetail + gap;
  final boardSide = canSplit ? c.maxHeight : min(c.maxWidth, c.maxHeight);
  final board = Center(child: AspectRatio(aspectRatio: 1,
    child: GridView.count(
      crossAxisCount: spec.size,                          // 3, 4, or 5
      physics: const NeverScrollableScrollPhysics(),      // cells never scroll/distort
      mainAxisSpacing: 6, crossAxisSpacing: 6,
      children: [for (final cell in layout) BingoCell(cell)],
    )));
  return canSplit
    ? Row(children: [SizedBox(width: boardSide, child: board),
                     const SizedBox(width: gap), const Expanded(child: ItemDetailPane())])
    : board; // detail opens as a bottom sheet on tap
});
```

Decode images at cell size (`cacheWidth: (cellPx * devicePixelRatio).round()`) so a 512 px WebP renders into a ~150 px cell without wasting memory. Orientation is emergent, not special-cased — support all orientations. Clamp `textScaler` **inside cells only** (`clamp(maxScaleFactor: 1.6)`) and hide in-cell captions at extreme scale (surface the name via the detail pane/semantics) so large accessibility fonts can't shatter a 5×5 grid; the rest of the UI honors full scaling.

### Accessibility (day one)

Each cell is a `Semantics(button:true, toggled: marked, label: name)` toggle with `ExcludeSemantics` on the decorative image ("Red barn, marked / not marked"). Never encode state with color alone — a marked cell gets a check icon + scrim, not just a tint. Tap targets ≥ 48 dp. Gate check-off/confetti on `disableAnimations`. Announce wins via `SemanticsService.announce`. Use `EdgeInsetsDirectional`/`start`/`end` and directional icons throughout so RTL works later with no layout change.

### Project structure

```
lib/
  app/            main.dart, bootstrap.dart, app.dart, router/, di/
  core/           responsive/, theme/, l10n/, widgets/ (AppShell), result.dart
  domain/         catalog/, board/generator/ (sfc32), board/win_rules.dart,
                  game/, repositories/ (interfaces)
  data/           local/drift/, local/assets/ (bundled catalog reader),
                  remote/firestore/, repositories/ (impls), mappers/
  features/       home/  play/ (BoardGrid, BingoCell)  catalog/  settings/  onboarding/
assets/catalog/   items.json + WebP tiles (the whole bundled catalog)
test/domain/board/generator_golden_test.dart
```

## 4. Offline-first storage, content & sync

**Three data domains, three lifecycles:**

| Domain | Source of truth | On-device store | Firestore role | Conflict model |
|---|---|---|---|---|
| Item catalog + images | git → **bundled in binary (MVP)** | Drift rows + bundled WebP assets | none | none (immutable per app version) |
| UI strings | app binary (ARB) | in-binary | none | none |
| Board spec | Firestore `boards/{id}` (durable/shareable) | Drift mirror | durable copy | none (immutable create) |
| Progress / marks | **device (Drift) at write time**, Firestore = convergence | Drift (local SoR) + outbox; Firestore SDK cache | durable record | per-cell last-write-wins map |

### The fix that makes first-launch-offline actually work

The prior design routed pre-auth progress into the Firestore cache under a "provisional UID." That is a **silent data-loss bug**: `signInAnonymously()` needs a network round-trip, so a first-ever launch in a tunnel has no authenticated user; Firestore evaluates security rules **server-side at flush time**, so those queued writes are rejected on reconnect and the SDK reverts the optimistic local state — the user watches a whole session's check-offs vanish.

**Resolution (mandatory for v1):**
- Progress is written to **Drift immediately** as the local source of truth. There is no provisional Firestore UID and no re-keying.
- The app signs in anonymously opportunistically when connectivity first appears; **only then** does an outbox flush write progress to `boards/{id}/players/{uid}` under the real UID.
- This makes "one store per concern" false in the naive sense, and that is the correct trade: Drift is the progress SoR (at least through the unauthenticated window; simplest is to keep it the always-on local SoR with Firestore as sync transport). The whole session is durable in Drift before any cloud contact.

This also resolves the general silent-rejection risk: because writes go through a Drift outbox with explicit ack/retry (not fire-and-forget), a rejected write (rules-propagation lag on a just-shared board, a stale UID after link-collision) is detectable and re-drivable, and the UI reflects true sync state from `SnapshotMetadata.hasPendingWrites`/`fromCache`.

### Reproducibility fix — the catalog must stay pinned

A board pins `catalogVersion`, but the prior design let delta updates UPSERT catalog rows keyed by `id` alone, so a content update overwrites the version a board depends on; since marks are stored by **cell index** and the layout is regenerated, a changed pool silently remaps a user's checked cells onto *different items* — play-state corruption across an app/content update.

**Resolution:**
- **MVP (bundled catalog):** `catalogVersion` == the app's bundled catalog version, immutable by construction. No mutation problem exists.
- **Durability rule (all versions):** for any board that has progress, **persist the generated cell layout** (`board_cache` becomes authoritative, not "disposable"). Regenerating 9–25 cells is instant, so this is cheap insurance; the "never persist cells" purity is abandoned for in-flight boards.
- **When packs return (post-MVP):** either store catalog rows version-scoped (PK includes `catalogVersion`, GC only versions no live board references) or rely on the persisted layout. A joiner must have the *fully-enumerated item universe* for a `catalogVersion` (not just the version string) before regenerating — fold a `packSetHash` into the seed and refuse to regenerate from a partial install rather than diverge silently.
- **Image-present gate:** the generator only selects items whose images are physically present offline (bundled asset or verified disk file), so a board can never render a placeholder for a missing image. In the bundled MVP this is automatic.

### Marks representation (kept multiplayer-shaped, stripped of dead weight)

Keep the doc **shape** that makes multiplayer additive — one doc per player, marks as a map keyed by cell index — but drop the machinery that has no reader yet:

```jsonc
// boards/{boardId}/players/{uid}   — each player writes ONLY its own doc
{
  "uid": "uidA",
  "marks": { "0": {"m": true}, "7": {"m": true}, "12": {"m": false} }, // key = cell index
  "completedAt": null,          // serverTimestamp when a win is validated; also derivable
  "updatedAt": <serverTimestamp>
}
```

- Written with `set(data, SetOptions(merge: true))` so different-cell edits **union** instead of clobbering (an array overwrite would lose check-offs). Exercise merge semantics in tests — `update()` with dotted paths throws if the doc is absent.
- **Un-mark is a value (`m:false`), never a key delete** — a stale re-mark can't resurrect a cell.
- **HLC / per-cell timestamps are removed from the MVP.** Solo is single-device, so the concurrent-edit merge never happens and the HLC field was written-but-never-read dead metadata. When async multiplayer ships and a second device can edit concurrently, add a `t` field and a resolver that actually consumes it (Hybrid Logical Clock, drop-in, no reshape). For MVP, coalesce taps with a ~400–600 ms debounce so a whole board is 1–3 writes (well under Firestore's ~500 pending-write ceiling).
- **Win/completion is derived**, recomputed from `(spec, marks, winModes)` — never trusted as stored authoritative state.

### Firestore config (correct API)

```dart
FirebaseFirestore.instance.settings = const Settings(
  cache: PersistentCacheSettings(sizeBytes: Settings.CACHE_SIZE_UNLIMITED),
);
// after Firebase.initializeApp():
FirebaseFirestore.instance.persistentCacheIndexManager()
    ?.enableIndexAutoCreation();   // null-safe; keeps offline queries fast as the cache grows
```

Note the manager can be null and auto-indexing is off by default. Do **not** use the non-existent top-level `enablePersistentCacheIndexAutoCreation()`. During online init, pre-fetch the user's active board + player docs (the cache only holds docs already read). On the road prefer one-shot `get()` over long-lived listeners (a listener left attached offline >30 min re-bills the whole query on reconnect); reserve `snapshots()` for real-time multiplayer.

### Bootstrap sequence

```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(cache: PersistentCacheSettings(...));
  final db = await openDrift();                 // runs Drift MigrationStrategy (see §11)
  await seedCatalogFromBundledAssetsIfNeeded(db);
  final prefs = await loadPersistedPrefs();     // locale + theme BEFORE first paint
  ensureAnonymousUserWhenOnline();              // non-blocking; does NOT gate play
  FirebaseFirestore.instance.persistentCacheIndexManager()?.enableIndexAutoCreation();
  runApp(ProviderScope(overrides: [driftDbProvider.overrideWithValue(db),
                                   prefsProvider.overrideWithValue(prefs)],
                       child: const CarBingoApp()));
}
```

## 5. Data model

### Firestore (progress only — no catalog, no mirror)

```
users/{uid}                       profile + prefs (optional; can start local-only)
boards/{boardId}                  immutable seed-based SPEC (cells never sent over the wire)
  players/{uid}                   participant + marks map = per-cell progress
```

**Board spec** (tiny, regenerable):

```jsonc
// boards/{boardId}
{
  "seed": "ROADTRIP-7QF2",
  "size": 5,                       // 3 | 4 | 5 → 9 / 16 / 25 cells
  "freeSpace": true,              // center auto-marked on odd sizes
  "catalogVersion": "2026.08.0",  // freezes WHICH item universe the pool comes from
  "algoVersion": 1,               // versioned generator dispatch
  "configHash": "cfg-7c1e…",      // snapshot of quotas/weights/caps/winModes
  "winModes": ["full_board", "lines"],
  "mode": "solo",                 // label only; shape identical for async/realtime
  "createdBy": "uidA",
  "memberUids": ["uidA"],         // grows 1→N; drives array-contains queries + rules
  "visibility": "private",        // private | link | public
  "createdAt": <ts>
}
```

**Item document** (git source of truth; bundled at build; shown here as the authoring shape). Localized fields are locale-keyed maps, never suffixed columns; metadata is flat; images are referenced by content hash.

```jsonc
// content/items/red_barn/item.json
{
  "id": "red_barn",
  "schemaVersion": 1,
  "catalogVersion": "2026.08.0",
  "categoryId": "buildings", "subCategoryId": "rural_structures",
  "difficulty": 2,                 // 1..5 → generator quotas
  "weight": 1,                     // INTEGER sampling weight (floats break determinism)
  "regions": ["*"], "enabled": true,
  "name":        { "en": "Red barn", "nb": "Rød låve", "de": "Rote Scheune" },
  "description": { "en": "A classic red-painted barn.", "nb": "En klassisk rødmalt låve." },
  "image": { "hash": "sha256-9f2c…", "aspect": "1:1", "format": "webp", "px": 512 },
  "license": { "source": "internal", "type": "CC0-1.0", "author": "…",
               "attributionRequired": false, "acquiredAt": "2026-07-01" }
}
```

### On-device (Drift/SQLite)

```sql
-- CATALOG (seeded from bundled assets)
items(id PK, category_id, sub_category_id, difficulty, weight, image_hash,
      regions, enabled, catalog_version)
item_locales(item_id, locale, name, description, PRIMARY KEY(item_id, locale))
categories(id PK, sort_order, icon); category_locales(category_id, locale, name, PK(...))
subcategories(id PK, category_id, sort_order); subcategory_locales(...)
images(hash PK, format, width, height, local_path)   -- resolves to bundled asset

-- PROGRESS (LOCAL SOURCE OF TRUTH until synced) + spec mirror + outbox
board_specs(board_id PK, seed, size, catalog_version, algo_version, config_hash,
            win_modes, owner_id, created_at, sync_state)
board_layout(board_id PK, cell_item_ids /* JSON, index-ordered */,   -- AUTHORITATIVE once progress exists
             algo_version, catalog_version, config_hash, generated_at)
player_progress(board_id, uid, cell_index, marked, updated_at, PRIMARY KEY(board_id, uid, cell_index))
sync_outbox(id PK, board_id, payload, created_at, attempts, last_error)  -- explicit ack/retry

app_meta(key PK, value)   -- ui_locale, theme, db_schema_version, active_catalog_version
```

Indexes cover catalog filtering (`category_id`, `sub_category_id`, `difficulty`, `enabled`) and locale lookups. Add an FTS5 table over `item_locales` only if you add catalog search.

**Firestore indexing/cost notes for later phases:** create a composite index on `boards` (`memberUids` array-contains + `updatedAt` desc) for "my games," and a collection-group index on `players.uid`. **Exempt the `marks` map from single-field auto-indexing** — Firestore indexes every map key, so an un-exempted `marks` map costs one index write per cell per write on the hottest path.

### Scaling 1 → N players (no schema change)

Only the cardinality of `players` and the length of `memberUids` change. Nothing is "player-1-special." Writes are pre-partitioned by uid (rules allow writing only `players/{request.auth.uid}`), so N concurrent players can never collide. The board is shared by reference + deterministic regeneration. Real-time is a *read pattern* (attach a listener to the docs solo already writes), not a schema.

## 6. Firebase backend topology & auth

**One Firebase project, one default Firestore database** for the MVP. (Only the first/default DB gets free quota; named DBs, PITR, and backups require billing even at zero volume — avoid them.) Add a `dev`/`prod` split only when real users' data must be protected.

**Auth: Anonymous first, upgradable via `linkWithCredential` (Apple + Google), never phone auth.** Anonymous users are not billable MAU (auto-cleanup default since 2024), so the real anon risk is *data loss*, not cost: an unlinked guest loses everything on uninstall/clear-storage, so prompt linking early. Handle `credential-already-in-use`/`email-already-in-use` with explicit merge-then-delete so linking never orphans progress. **Store compliance:** if you offer Google sign-in you must also offer Sign in with Apple (Apple guideline 5.1.1(v)) — the two ship together, not sequenced.

Security rules (least privilege; the `players/{uid}` self-write rule is the linchpin that makes concurrent multiplayer conflict-free and is already in force for solo):

```
match /boards/{boardId} {
  allow read:   if request.auth != null &&
                  (resource.data.visibility != 'private' || resource.data.createdBy == request.auth.uid);
  allow create: if request.auth != null && request.resource.data.createdBy == request.auth.uid;
  allow update, delete: if false;                       // spec is frozen
  match /players/{playerId} {
    allow read:  if request.auth.uid in
                    get(/databases/$(db)/documents/boards/$(boardId)).data.memberUids;
    allow write: if request.auth.uid == playerId && request.resource.data.uid == playerId;
  }
}
```

Cloud Functions, RTDB presence, App Check, and Remote Config are **not** part of the MVP (see §10). App Check becomes relevant only once Blaze is in play and there are billable endpoints to firewall.

## 7. Localization & theming

**Two independent tracks.** UI strings ship in the binary and version with the app; item content lives in the bundled catalog + Drift and (later) in packs.

**UI strings: first-party `flutter_localizations` + `intl` + gen-l10n (ARB)** for MVP. This is the leaner choice for 1–3 launch locales and has no third-party dependency. (The third-party `slang` — with its `analyze` CI key-drift gate and context-free `t.x` access — is a reasonable upgrade once locales multiply; keep strings behind a thin facade so swapping is cheap.) A CI check fails the build if any locale file is missing a key present in the base — a silent missing key is a blank UI string.

**Content localization: locale-keyed maps + one centralized fallback resolver**, reused everywhere (and portable to a future Cloud Function):

```
resolve(field, locale):
  field[locale]            // "pt-BR"
  ?? field[language(locale)]// "pt"
  ?? field["en"]           // app base, guaranteed present in the bundled catalog
  ?? itemId                // last-ditch — a fixed grid never loses a cell
```

Falling back to English (then the id) rather than hiding an item is mandatory: a hidden cell on a fixed 3×3–5×5 board makes it unwinnable. **Localization never touches board generation** — items are selected by `id`; names/descriptions resolve only at render. A CI golden test asserts identical board output across locales.

**Theming: Material 3 `ColorScheme.fromSeed` (light + dark from one seed) + a typed `ThemeExtension` (`BingoTokens`)** for game-specific tokens (`cellMarked`, `cellFree`, `difficultyEasy/Med/Hard`, `celebration`, `cellShadowOpacity`, `cellRadius`) with `copyWith`/`lerp`. A *typed* extension means a theme that forgets a token won't compile — the compile-time answer to "missing key → silent blank color." `cellShadowOpacity` is per-brightness (light-mode shadows wash out in dark). Ship **light + dark only** for MVP; defer a high-contrast family and `dynamic_color`/Material You. Theme preference is two orthogonal fields (`ThemeMode mode` + `String familyId`) so "high-contrast + follow system" works for free later.

**Persistence:** theme + locale live in `shared_preferences` (or `app_meta`), read in `main()` before `runApp` so there is no flash of the wrong theme/language. Device-local is the offline source of truth; mirror to the user profile later for cross-device sync.

## 8. Deterministic board generation & game logic

**The reproducibility contract.** A board is never persisted as cells over the wire; it is persisted as a spec and regenerated by re-running the generator. Persist exactly five fields and fold all of them into the PRNG seed so identical specs yield identical boards and any change yields a different board: `seed`, `size`, `catalogVersion`, `algoVersion`, `configHash`. Dispatch on `algoVersion` (`generators[algoVersion]`) so changing the algorithm never breaks already-shared boards. Commit **golden test vectors** (`spec → id[]`) in CI. (For MVP, `algoVersion`/`configHash`/board_cache are trivially satisfied — the value is that the seam exists.)

**PRNG: sfc32 seeded via cyrb128** — not `Random()`/`Math.random` (unseedable, engine-specific), not mulberry32 (its author documented it skips ~⅓ of outputs). sfc32 has 128-bit state, top statistical quality, and is ~10 lines so it can be reimplemented byte-identically in Node for later server-side validation. Draw integers by **rejection sampling**, never `nextU32() % n` (modulo bias) and never from a float. **Dart determinism:** mask every op with `& 0xFFFFFFFF`, use `>>>`, implement `imul` as `(x*y)&0xFFFFFFFF`; iterate seed strings by UTF-16 code unit; keep seeds ASCII.

**Generation (single deterministic pass):** stable-sort the pool by string `id` (never trust file/Firestore/locale order); allocate difficulty quotas by largest-remainder; select by weighted sampling **without replacement**, per difficulty, capped per category (`ceil(pick/#categories)+1`) so no category floods the board; place via seeded Fisher-Yates with the center reserved as a free square on odd sizes. A deterministic relaxation order (raise cap → borrow adjacent tier → any enabled item) is a safety net; a **build-time validator** asserts the catalog has enough enabled items per (difficulty × category) to fill a 5×5 without relaxation. The generator only selects items whose images are present offline (§4).

**Difficulty mix by size** (small boards skew easy; fractions resolved to integers deterministically):

| Size | Cells | Free | Pick | Easy | Medium | Hard |
|---|---|---|---|---|---|---|
| 3×3 | 9 | 1 | 8 | 5 | 3 | 0 |
| 4×4 | 16 | 0 | 16 | 7 | 6 | 3 |
| 5×5 | 25 | 1 | 24 | 8 | 10 | 6 |

**Win detection** (derived, never stored authoritatively): `FULL_BOARD` (all non-free cells) and `LINES` (any full row/column/diagonal; the free square counts toward any line through the center). `winModes` live on the board so shared boards agree on victory.

**MVP game loop (pinned so infra doesn't get built ahead of a defined game):** one active solo board at a time; start a new game = pick a size (3/4/5) and generate; tap to mark/unmark; win = full board (v1 adds line-win as an option); a completed/abandoned board can be cleared and a new one started; a short local history of completed boards. No timer/scoring in MVP (candidate for v1). Session/history queries and the `games`-vs-`boards` split are collapsed into `boards/{id}` — a public/daily board is just `visibility:"public"` with each joiner adding a player doc.

## 9. Content authoring, image pipeline & licensing

This is the real project risk and the biggest gap in the source design — the app is worthless without ~100–300 consistent road-item images.

- **Sourcing plan (decide before feature work):** pick one primary path and budget it. Options, cheapest-first for a solo dev: (a) commission a single illustrator for a consistent flat-icon set (best style consistency, real cost/time); (b) curate CC0/CC-BY stock and normalize to a common treatment; (c) AI-generated art. **AI art carries licensing ambiguity and heightened App Store/Play review scrutiny** — if used, keep prompts/provenance records, prefer models with clear commercial terms, and expect to declare it. The `license` metadata field records provenance; it does not source or clear anything.
- **Style consistency** is a launch-quality gate: fixed canvas, consistent palette/line-weight/perspective, transparent or uniform background. Define a one-page style spec and hold every tile to it.
- **Pipeline:** git folder-per-item JSON (metadata + per-locale name/description) → JSON-Schema validation in CI → `sharp` rasterizes masters to **WebP** at a single sensible density (e.g. 2x/3x; skip 1x/2x/3x triples for MVP) with content-hash filenames → assembled into `assets/catalog/` and bundled. Use a solid-color/icon placeholder rather than blurhash for MVP.
- **Editorial / moderation gate:** every catalog change passes a human review before release — wrong, offensive, or mistranslated items must not reach a child-inclusive general audience. This matters even more if/when Remote Config lets content ship without store review (defer that, and gate it when it arrives).

## 10. Multiplayer roadmap (solo → async → realtime)

The engine and both data shapes are identical across all phases; each phase only adds sharing/rules/listeners.

| | Phase 0 — Solo (MVP) | Phase 1 — Async shared boards | Phase 2 — Realtime / race |
|---|---|---|---|
| Generation | client-side pure generator, offline | unchanged — joiner regenerates from spec | unchanged |
| Data model | `boards/{id}` + `players/{uid}` | unchanged — more `players/{uid}` docs | unchanged |
| Marks | local Drift + whole-doc/merge sync | add `t` (HLC) + resolver for concurrent edits | unchanged |
| Sharing | none | share `boardId` (link/QR/code) | same |
| Reads | local cache only | one-time `get()` of sibling player docs | scoped `snapshots()` listeners |
| Presence | n/a | n/a | RTDB `onDisconnect` (Firestore stays SoR) |
| Cloud Functions | none | `joinBoard` (membership/cap) | `validateWin` (recompute from seed) |
| Backend plan | **Spark** | **Blaze** (Functions ship here) | Blaze |
| Auth | Anonymous | prompt link; async ok anon | gate ranked play behind linked account |

**Phase 1 changes only sharing + rules,** not the engine: the joiner fetches the spec (or decodes the five contract fields from a share code) and **must fully install the item universe for that `catalogVersion` before regenerating**, then creates its own `players/{uid}` doc. `joinBoard` caps participants and validates membership.

**Phase 2 changes only reads + adds presence + anti-cheat:** scoped, background-detached `snapshots()` listeners; RTDB presence; a `validateWin` Function that recomputes the board from its seed (free anti-cheat from determinism). **Cost caution:** a live listener bills 1 read per changed doc *per listening client*, so an N-player race costs on the order of N × changed_docs × N reads — quantify before shipping, keep real-time opt-in and board-scoped, bound concurrency (linked accounts), and keep cheap async `get()` as the default competitive mode.

## 11. DevOps / CI-CD / testing / observability

**CI/CD — one system for MVP.** Use **Codemagic** (Flutter-native: build + Apple code signing + App Store Connect / Play publishers, generous free macOS tier) *or* GitHub Actions + Fastlane — not both. Drop the GH-Actions-plus-Codemagic split and **Shorebird** until there are users to hotfix. Start with **one Firebase project and one flavor**; add a dev/prod split only when real user data needs isolating.

- **Signing:** Play App Signing (Google holds the app key; you hold an upload key); iOS via App Store Connect API key (`.p8`) + managed signing. All keystores/keys in CI encrypted secrets, never in git; add gitleaks pre-commit + CI scan and a `.gitignore` covering `*.jks`/`*.keystore`/`.p8`.
- **Release flow:** tag → build appbundle + ipa → Play internal track + TestFlight → self smoke test → staged Play rollout (20% → 100%).

**Testing** (weighted to fast, deviceless tests; Linux for unit/widget, macOS only for iOS device runs):

- **Generator golden vectors** (`spec → id[]`) per `algoVersion`, plus a cross-locale-identity test — the whole shared-board promise depends on determinism.
- **Firestore security-rules unit tests** on the Emulator Suite — assert a player can write only `players/{ownUid}`.
- **Real-device offline QA matrix (call it out explicitly):** first-*ever* launch in airplane mode → play a full board → reconnect → **progress survives**; clear-storage recovery; sign-out data loss; on physical iOS *and* Android, phone *and* tablet.
- Widget/golden tests for board grid, cell states, light/dark parity, adaptive layouts at 360/700/1000 dp. Coverage gate ~70–80% (exclude generated files). Delete flaky tests; never add retries.
- Drift **`MigrationStrategy`** with a test per migration, and a defined rule for re-seeding the bundled catalog on app update (upsert new/changed items; never wipe user progress) — a concrete correctness risk on every release.

**Observability** (all free; opt-in, off by default — see §13): Crashlytics, Analytics (install → first board → first check-off → complete), Performance Monitoring (validate the Impeller 120 fps goal on real mid-range Android; have a reduce-motion fallback rather than assuming it). Because opt-in rates are low, instrument a **sync-health UI** (`hasPendingWrites`/`fromCache`) and keep a local diagnostic log the user can export/email — a solo dev debugging road-trip failures can't rely on telemetry arriving.

## 12. Firebase cost controls

**MVP is on Spark, so cost control is structural, not monitored.** Firestore free tier (verified Aug 2026): 50K reads / 20K writes / 20K deletes per day, 1 GiB stored, 10 GiB egress/month, one default DB. On Spark, exceeding a product's daily quota shuts that product off for the rest of the month and resets — a brief outage that can never bill. That is the hard cap; **no budget alerts, no Pub/Sub disable-billing function, no App Check are needed for MVP.**

Cost is removed by construction: the catalog is bundled (zero catalog reads, zero image egress), images never come from Cloud Storage, and Firestore holds only tiny progress docs written as 1–3 coalesced writes per board.

**Free-tier ceiling (so "near-$0" is verifiable):** writes bind first — a handful of coalesced writes per session vs 20K/day ⇒ order-of-thousands of sessions/day free; one-shot `get()` of active board + player docs vs 50K reads/day puts the free ceiling roughly in the low-thousands-to-~10K DAU range. Overage (only if/when on Blaze) is ≈ $0.18/100K reads, $0.18/100K writes — pennies per extra thousand users.

**When Blaze becomes necessary (first Cloud Function or Cloud Storage, i.e. Phase 1+):** set budget alerts at 50/90/100% of a low target plus a $0.01 alert; add the Pub/Sub → disable-billing circuit breaker (or the Auto Stop Services extension) understanding it is a *lagging* cut-off; enforce App Check. Treat **client discipline as the real control** (App Check and budget breakers don't stop *your own* buggy client within the alert lag): `autoDispose` all listeners, always `limit()`, detach on background/offline, add a client self-circuit-breaker that aborts + logs on runaway reads. Serve R2 images through the Cloudflare CDN/custom domain (cached), not the raw `r2.dev` endpoint. Expect a ~$0–1/mo floor once any 2nd-gen Function is deployed (Artifact Registry image storage) and add an image cleanup policy. **Skip scheduled Firestore exports** — they bill 1 read per exported document, are invisible in the usage dashboard, and single-handedly force Blaze; git backs up all content and account-linking is the real progress-durability mechanism.

## 13. Security, privacy & store compliance

**Data minimization is the compliance strategy.** Solo play is anonymous auth + local data; the only cloud PII-ish thing is a stable UID and per-cell progress. No ads, no third-party tracking SDKs, no advertising ID (IDFA/AAID), no location, no contacts.

- **GDPR:** you are the controller, Google the processor under its DPA. Analytics/Crashlytics/Performance are **disabled by default** (manifest/Info.plist flags) and enabled only after explicit opt-in, with a Settings toggle to withdraw. Wire in-app **account deletion** (required by both stores) → delete the user's Firestore docs + auth user; the anonymous UID makes erasure trivial. Operationalize DSR requests that arrive by email (export + erasure), not just the in-app button. Host a privacy policy at a stable URL, generated from a single data inventory so the policy, Play Data Safety, and Apple privacy labels always agree.
- **Not a kids app.** Car Bingo appeals to children on road trips, but **do not enter Apple's Kids Category or Google's Designed-for-Families** — that regime demands verified parental consent, certified ad SDKs, and no persistent identifiers, a heavy solo-dev burden with COPPA (>$53k/violation) and GDPR-K exposure. Instead ship **general-audience "Everyone"** and make the burden zero regardless of who plays (no ads/tracking/AAID; analytics opt-in and off). Keep marketing family-friendly-but-general so Google doesn't reclassify (they validate against marketing), and align the IARC questionnaire with the general-audience stance. Confirm classification with counsel before EU/US launch. Add a neutral age gate only if you ever add child-directed features or chat.
- **Store-review specifics:** Sign in with Apple must be offered alongside Google (guideline 5.1.1(v)). Remote Config is **not** unconditionally safe — using it to change app *behavior* (feature flags, difficulty) can trip Apple/Google "changing behavior without review" rules; it's deferred anyway, and when it returns, restrict it to content pointers, not behavior changes.
- **Backups:** git is the source of truth/backup for catalog, images, UI strings, and generator code (content packs are immutable/hash-addressed). User progress is low-value and reconstructable — rely on prompting **account linking early** rather than scheduled exports. Reintroduce weekly Firestore export (tagged `goog-firestoremanaged:exportimport`, since it's invisible in the dashboard) only once a real user base justifies the Blaze exposure.

## 14. Delivery roadmap

**Phase 0 — Foundations.** One repo, one Firebase project, one CI system (Codemagic) with signing + TestFlight/Play internal track. Git content pipeline (JSON Schema + `sharp` → WebP + hash names, bundled). Design tokens (light/dark) + gen-l10n scaffolding. **Content sourcing plan committed (§9) — this gates everything.**

**MVP — Solo, fully offline (Spark, $0).** Anonymous Auth (opportunistic, never gates play); Drift as local SoR for catalog + persisted board layout + progress + outbox; Firestore offline persistence for progress sync after auth; **whole catalog bundled** so first-ever launch in a tunnel is fully winnable; deterministic seeded generator (sfc32, golden vectors in CI); check-off + full-board win; light/dark; adaptive phone/tablet. Data model already `boards/{id}` + `players/{uid}` with per-cell merge-write marks (no HLC yet). Opt-in Crashlytics/Analytics; privacy policy; Play Data Safety + Apple labels; in-app deletion; "Everyone" rating; App Distribution beta. Real-device offline QA matrix (§11).

**v1 — Content, localization, themes, polish.** More items and 1–2 more locales (locale-keyed maps + resolver, RTL-clean code); line-win mode and optional timer/scoring; Performance dashboards; staged rollouts. Still bundled catalog, still solo, still Spark/$0. Introduce R2+CDN content packs + Remote Config pointer **only if** the catalog outgrows the binary or you need no-review content updates (with the moderation gate).

**v2 — Async shared boards (→ Blaze).** Share by id/code → joiner installs the full item universe for the pinned `catalogVersion`, regenerates the identical board, creates its own player doc. Add `t` (HLC) + a same-cell resolver. Tighten rules (participants read, self-only writes). Add Sign in with Apple + Google linking. First Cloud Function (`joinBoard`) forces Blaze → stand up budget alerts + circuit breaker + App Check + client listener discipline.

**v3 — Realtime + competitive.** Scoped `snapshots()` listeners; RTDB `onDisconnect` presence; `validateWin` Function (anti-cheat from determinism); optional ranked play behind linked accounts; FCM nudges. Quantify listener fan-out cost and keep real-time opt-in before enabling.

## 15. Key decisions

| Decision | Choice | Rationale | Alternatives (rejected) |
|---|---|---|---|
| Client framework | Flutter 3.44 / Dart 3.12 | One codebase, native iOS+Android phone+tablet, best offline+Firebase+adaptive story | React Native (RN Firebase-JS offline broken), KMP (no Firebase SDK), MAUI (2026 regressions) |
| Backend plan (MVP) | **Spark (free, hard-capped)** | Solo uses no Storage/Functions; Spark's shut-off is a stronger, zero-code cost guard than uncapped Blaze | Blaze + circuit breaker (unneeded until Functions/Storage ship) |
| Content delivery (MVP) | **Whole catalog bundled in binary** | 5–18 MB fits; deletes a second vendor + delta/checksum/pack-failure classes | R2+CDN packs (deferred until catalog outgrows binary) |
| Progress store | **Drift local SoR + outbox → Firestore after real UID** | Fixes silent first-launch-offline data loss (rules reject pre-auth writes); enables detectable retry | Provisional-UID reconcile into Firestore cache (broken: rejected writes revert) |
| Board reproducibility | Seed spec + **persist generated layout for in-flight boards**; catalogVersion pins item universe | Prevents index→item remap corruption across content updates; MVP catalogVersion is immutable (bundled) | "Never persist cells" purity over a disposable cache (corrupts progress) |
| Marks model | Per-cell merge-write map, one doc per player; **HLC deferred** | Union of different-cell edits; per-player docs = conflict-free at N players; HLC had no reader in solo | Whole-board array (clobbers); full CRDT / HLC now (dead metadata) |
| Local DB | Drift/SQLite | Type-safe, reactive, maintained; needed as durable pre-auth progress store | Realm (sync killed), Hive/Isar (abandoned), in-memory only (no durable progress) |
| Auth | Anonymous → link Apple+Google | Instant offline play; stable UID; upgrade with no loss; Apple required alongside Google | Phone auth (paid), sign-up-first (friction, breaks offline) |
| PRNG | sfc32 via cyrb128, rejection-sampled ints | Byte-reproducible cross-engine; 128-bit state; reimplementable in Node for anti-cheat | Math.random/Random (unseedable), mulberry32 (skips ~⅓ outputs), `% n` (bias) |
| State / DI | Riverpod 3 code-gen | One system for state + DI; AsyncValue models sync; autoDispose bounds read cost | Bloc (boilerplate + separate DI), Provider/GetX, get_it |
| Adaptive nav | Framework NavigationRail/NavigationBar behind ~60-line AppShell | `flutter_adaptive_scaffold` is discontinued; width-based, not is-tablet | flutter_adaptive_scaffold (abandoned), per-platform layouts |
| UI localization | gen-l10n + intl (first-party) | Leaner for 1–3 locales, no third-party dep | slang (upgrade when locales multiply) |
| Content localization | Locale-keyed maps + English-defaulting resolver | Add a language with no migration; fixed grid never loses a cell | Suffixed fields, per-locale collections |
| Theming | M3 `fromSeed` + typed `ThemeExtension`, light+dark only | Compile-time token completeness; per-brightness shadows; defer high-contrast/Material You | Constants file (runtime-only safety), shipping unused theme families |
| Images | WebP, single density, bundled | Universal Flutter decode; AVIF has no core codec; ~15–60 KB/tile | AVIF (broken bundled decode), 1x/2x/3x triples + blurhash (over-polish for MVP) |
| CI/CD | One system (Codemagic), one Firebase project, no Shorebird | Enterprise release-eng is overkill for a solo dev with zero users | GH Actions+Codemagic+Shorebird split, 3 flavors→3 projects |
| Firestore catalog mirror | **None in MVP** (read:false if ever added) | Never read in solo; contradicts offline design; latent per-read cost trap | Client-readable mirror for "future validation" (YAGNI) |
| Kids classification | General-audience "Everyone," data-minimized | COPPA/GDPR-K safe without the Families-program burden | Kids/Designed-for-Families (heavy ongoing obligations) |
| Backups | Git (content) + account-linking (progress) | Progress is low-value/reconstructable; scheduled export bills hidden reads + forces Blaze | Scheduled Firestore export / PITR at MVP |

*Version notes (verified Aug 2026): Flutter 3.44 / Dart 3.12; Impeller is the default and only renderer on Android 10+ (Skia removed) and iOS. Firestore Spark free tier: 50K reads / 20K writes / 20K deletes per day, 1 GiB stored, 10 GiB egress/month, one default DB; exceeding a quota on Spark shuts that product off until the next cycle (never bills). Cloud Storage for Firebase requires Blaze since Feb 3 2026 — a reinforcing reason to bundle images. Pin exact FlutterFire versions via `flutter pub add`; the archived firebase.flutter.dev docs are stale — use firebase.google.com + pub.dev.*
