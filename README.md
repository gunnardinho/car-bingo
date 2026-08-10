# car-bingo

Offline-first road-trip bingo for iOS and Android, built with Flutter. The full
item catalog and tiles ship in the binary, so a first-ever launch works with zero
connectivity. Progress is saved locally and is designed to sync to Firebase
(Firestore + anonymous auth) once the sync layer is activated — the offline engine
is complete behind clean seams, but the Firebase adapters are not wired up yet (see
[`docs/SYNC.md`](docs/SYNC.md)).

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

> On Windows/git-bash, `flutter` may not be on your PATH by default. Add your
> Flutter `bin` directory to it (adjust the path to your install location):
> ```bash
> export PATH="$PATH:/c/Users/<your-username>/flutter/bin"
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
