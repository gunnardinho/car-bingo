# Firebase project setup (MVP)

One-time setup to stand up the Firebase backend for Car Bingo. This is the
prerequisite for the **anonymous auth + Firestore progress outbox** increment.
It follows the architecture decisions locked in `ARCHITECTURE.md`:

- **One** Firebase project, **one default** Firestore database, **Spark (free)** plan.
- **No Cloud Storage, no Cloud Functions** in the MVP — that's what keeps Spark's
  hard cap a real cost guard (§6, §12). Do **not** upgrade to Blaze.
- Firestore holds **progress only** (`boards/{id}/players/{uid}`); the catalog is
  bundled, never in Firestore (§2, §4).
- Auth is **Anonymous** now; Apple/Google linking is deferred to v2 (§6, §10).

App identifiers are already set on both platforms: **`no.sigstad.carbingo`**.

---

## 0. Prerequisites

- A Google account (use one you're happy owning the project long-term).
- Node/npm — already installed for the content pipeline.
- Flutter on PATH (this shell needs `export PATH="$PATH:/c/Users/ZGP/flutter/bin"`).

```bash
# Firebase CLI (project/rules/deploy)
npm install -g firebase-tools
firebase login

# FlutterFire CLI (generates firebase_options.dart + registers platform apps)
dart pub global activate flutterfire_cli
# Ensure the pub global bin is on PATH (Windows):
#   %LOCALAPPDATA%\Pub\Cache\bin   → in git-bash: /c/Users/ZGP/AppData/Local/Pub/Cache/bin
export PATH="$PATH:/c/Users/ZGP/AppData/Local/Pub/Cache/bin"
flutterfire --version
```

---

## 1. Create the project

Easiest via the console (you'll be enabling Auth + Firestore there anyway):

1. https://console.firebase.google.com → **Add project** → name it (e.g. `Car Bingo`).
2. **Disable Google Analytics** for the project. Analytics/Crashlytics are opt-in
   and off by default for privacy (§13); add them later behind a consent toggle if
   ever wanted. Skipping GA now avoids creating a GA property you don't want.
3. Confirm the plan is **Spark (free)**. Don't add a billing account.

> CLI alternative: `firebase projects:create carbingo-prod --display-name "Car Bingo"`
> (project IDs are globally unique; pick something free like `carbingo-prod` or
> `no-sigstad-carbingo`). You still enable Auth + Firestore in the console.

Note the **Project ID** (not the display name) — you'll pass it to `flutterfire`.

---

## 2. Create the Firestore database  ⚠️ region is permanent

1. Console → **Build → Firestore Database → Create database**.
2. Start in **Production mode** (locked rules; we deploy real rules in step 6).
3. **Location:** pick a **European** region for GDPR data residency + low latency
   from Norway, and understand **this can never be changed**. Recommended:
   - `europe-north1` (Finland) — nearest single region, cheapest, or
   - `eur3` (Europe multi-region) — higher availability, still free-tier eligible.
   Recommendation: **`europe-north1`** for a solo hobby app.
4. This is the **default** database. Never create a *named* database — only the
   default one gets free quota (§6).

---

## 3. Enable Anonymous Authentication

1. Console → **Build → Authentication → Get started**.
2. **Sign-in method → Anonymous → Enable → Save.**

That's all for the MVP. (Anonymous users aren't billable MAU and auto-clean up;
Apple + Google `linkWithCredential` come with v2 — and per Apple 5.1.1(v) those two
ship together, never one alone.)

---

## 4. Wire the Flutter app to Firebase

```bash
export PATH="$PATH:/c/Users/ZGP/flutter/bin"

# Pin exact versions via pub add (don't hand-edit pubspec).
# MVP needs only these three — NOT analytics/crashlytics/storage/functions.
flutter pub add firebase_core cloud_firestore firebase_auth

# Register the android + ios apps and generate lib/firebase_options.dart.
# Use the Project ID from step 1. Bundle/app id is already no.sigstad.carbingo.
flutterfire configure --project=<YOUR_PROJECT_ID> --platforms=android,ios
```

`flutterfire configure` will:
- create/reuse the Android + iOS apps under `no.sigstad.carbingo`,
- write `lib/firebase_options.dart`,
- drop `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`,
- inject the Android Google-Services Gradle plugin (recent CLI does this for you).

These config files are **safe to commit** — the keys in them are not secrets
(they're per-app restricted). Do commit `lib/firebase_options.dart` (the build
needs it). If you'd rather not track the platform json/plist, gitignore *those*
two, but never `firebase_options.dart`.

---

## 5. Platform minimums (required by the Firebase SDKs)

**Android — needs API 23+** (Firebase Auth/Firestore floor). Flutter 3.44's
default `flutter.minSdkVersion` is already **24**, so the existing
`minSdk = flutter.minSdkVersion` in `android/app/build.gradle.kts` satisfies this
— **leave it as is**. Do *not* hardcode `minSdk = 23`: on this Flutter version
that would *lower* the floor by an API level. Only pin an explicit value if a
future Flutter bump ever drops the default below 23 (`flutter build apk` warns if
so).

If `flutterfire configure` did **not** wire the Gradle plugin, add it manually:

```kotlin
// android/settings.gradle.kts — in the plugins { } block
id("com.google.gms.google-services") version "4.4.2" apply false
```
```kotlin
// android/app/build.gradle.kts — in the top plugins { } block
id("com.google.gms.google-services")
```

**iOS — raise the deployment target to 15.0** (current Firebase Apple SDK minimum;
project is at 13.0). Easiest in Xcode (`open ios/Runner.xcworkspace` → Runner
target → General → Minimum Deployments → iOS 15.0), and in `ios/Podfile` set:

```ruby
platform :ios, '15.0'
```
then:
```bash
cd ios && pod install && cd ..
```

---

## 6. Security rules + the marks-map index exemption

```bash
firebase init firestore     # select your project; accept firestore.rules + firestore.indexes.json
```

Put this in **`firestore.rules`** (least-privilege; already solo-safe and
multiplayer-ready — the `players/{uid}` self-write rule is the linchpin, §6):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /boards/{boardId} {
      allow read:   if request.auth != null &&
                      (resource.data.visibility != 'private' ||
                       resource.data.createdBy == request.auth.uid);
      allow create: if request.auth != null &&
                      request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if false;              // spec is frozen

      match /players/{playerId} {
        allow read:  if request.auth.uid in
                        get(/databases/$(database)/documents/boards/$(boardId)).data.memberUids;
        allow write: if request.auth.uid == playerId &&
                        request.resource.data.uid == playerId;
      }
    }
  }
}
```

Put this in **`firestore.indexes.json`** to exempt the per-cell `marks` map from
single-field auto-indexing (otherwise Firestore writes one index entry per cell
per write on the hottest path, §5):

```json
{
  "indexes": [],
  "fieldOverrides": [
    { "collectionGroup": "players", "fieldPath": "marks", "indexes": [] }
  ]
}
```

Deploy:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

---

## 7. Stay on Spark (structural cost control)

- Do **not** add a billing account / upgrade to Blaze.
- Do **not** enable Cloud Storage or Cloud Functions (both force Blaze).
- App Check, budget alerts, and the disable-billing function are **not** needed on
  Spark — the daily free cap simply shuts the product off until reset and can never
  bill (§12). Revisit only when v2 ships a Cloud Function.

---

## 8. Smoke-test the wiring

Minimal check that init + anonymous auth + an offline-capable write work. This is
just a throwaway probe — the real §4 bootstrap sequence (persistent-cache
settings, opportunistic auth, the Drift→Firestore outbox) lands in the next
increment.

```dart
// temporary, in bootstrap() before runApp — remove after verifying
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
final cred = await FirebaseAuth.instance.signInAnonymously();
await FirebaseFirestore.instance
    .doc('boards/smoke/players/${cred.user!.uid}')
    .set({'uid': cred.user!.uid, 'marks': {'0': {'m': true}}}, SetOptions(merge: true));
```

Run on a device/emulator, then confirm the doc appears in the console under
`boards/smoke/players/...`. Delete the probe (and the `boards/smoke` doc) after.

---

## What stays deferred (next increment, not this setup)

- `Firebase.initializeApp` + `Settings(cache: PersistentCacheSettings(...))` +
  `persistentCacheIndexManager()?.enableIndexAutoCreation()` in `bootstrap()` (§4).
- Opportunistic anonymous sign-in that **never gates play**.
- The Drift `sync_outbox` table + a flusher writing `boards/{id}/players/{uid}`
  with `SetOptions(merge: true)`, ~400–600 ms tap debounce, explicit ack/retry.
- Sync-health UI from `SnapshotMetadata` (`hasPendingWrites` / `fromCache`).
- Real-device offline QA matrix (§11): first-ever launch in airplane mode → play →
  reconnect → progress survives.

---

## Quick checklist

- [ ] `firebase-tools` + `flutterfire_cli` installed, `firebase login` done
- [ ] Project created, **Google Analytics off**, **Spark** plan
- [ ] Firestore created in **europe-north1** (or eur3), production mode — region is permanent
- [ ] Anonymous auth enabled
- [ ] `flutter pub add firebase_core cloud_firestore firebase_auth`
- [ ] `flutterfire configure` → `firebase_options.dart` + platform config generated
- [ ] Android minSdk ≥ 23 (Flutter default 24 already OK); google-services plugin applied
- [ ] iOS deployment target **15.0**; `pod install`
- [ ] `firestore.rules` + `marks` index exemption deployed
- [ ] Still on Spark; no Storage/Functions/Blaze
- [ ] Smoke test writes a doc, visible in console, then cleaned up
