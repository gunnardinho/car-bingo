# car-bingo

Offline-first road-trip bingo for iOS and Android, built with Flutter. The full
item catalog and tiles ship in the binary, so a first-ever launch works with zero
connectivity; progress syncs to Firebase (Firestore + anonymous auth) when a
connection is available.

## Prerequisites

- **Flutter** 3.44+ with **Dart** SDK `^3.12.2` (see `environment` in `pubspec.yaml`)
- **Android**: Android SDK + an emulator or physical device — see
  [`docs/ANDROID_SETUP.md`](docs/ANDROID_SETUP.md)
- **iOS**: a Mac with Xcode (currently deferred — see notes in `docs/ANDROID_SETUP.md`)
- **Node.js** ≥ 20 — only needed to regenerate the bundled catalog assets
- **Firebase**: config is checked in (`lib/firebase_options.dart`,
  `android/app/google-services.json`). To set up your own project, follow
  [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md).

## Setup

```bash
flutter pub get
```

The catalog assets (`assets/catalog/`) are already committed, so this is all you
need for a normal run.

## Running the app

### Android emulator

```bash
# List available emulators, then launch one (see docs/ANDROID_SETUP.md to create one)
flutter emulators
flutter emulators --launch pixel_fb

# Once it's booted, run the app on it
flutter run
```

If multiple devices are connected, target one explicitly:

```bash
flutter devices              # list connected devices
flutter run -d emulator-5554 # or any device id from the list above
```

### Web (for quick UI iteration)

```bash
flutter run -d chrome
```

> On this Windows dev box, `flutter` isn't on the git-bash PATH by default. Prefix
> commands with:
> ```bash
> export PATH="$PATH:/c/Users/ZGP/flutter/bin"
> ```

## Tests

```bash
flutter test        # unit + widget tests
flutter analyze     # static analysis / lints
```

## Regenerating catalog assets (optional)

The item universe and WebP tiles under `assets/catalog/` are build output. To
regenerate them:

```bash
npm install
npm run content     # seed → placeholders → validate → build
```

Individual steps are also available: `npm run seed`, `npm run placeholders`,
`npm run validate`, `npm run build`.

## Documentation

- [`docs/ANDROID_SETUP.md`](docs/ANDROID_SETUP.md) — Android SDK + emulator setup and on-device Firebase smoke test
- [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md) — Firebase project, rules, and auth setup
- [`docs/SYNC.md`](docs/SYNC.md) — offline progress-sync design (outbox engine)
