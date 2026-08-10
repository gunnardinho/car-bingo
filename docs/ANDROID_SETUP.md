# Android SDK setup + on-device Firebase smoke test

One-time setup to install the Android toolchain on the Windows dev box and run
the Firebase smoke test (FIREBASE_SETUP.md step 8) on a **real Android phone via
USB**. iOS verification is deferred until a Mac is available.

> Starting state (verified 2026-08): `flutter doctor` reports **no Android SDK**,
> no Android Studio, no AVDs. The SDK install below is required whether you use a
> phone or an emulator — even a physical phone needs the SDK's `adb`/platform-tools
> to build and install onto it.

Paths on this machine:
- Flutter: `C:\Users\ZGP\flutter\bin` (in git-bash: `/c/Users/ZGP/flutter/bin`)
- SDK (default target): `C:\Users\ZGP\AppData\Local\Android\Sdk`
- adb (after install): `C:\Users\ZGP\AppData\Local\Android\Sdk\platform-tools\adb.exe`

---

## 1. Install Android Studio

- Download the latest stable from **https://developer.android.com/studio**.
- Run the installer, accept defaults. The **Android Virtual Device** component is
  optional for a physical phone — leave it checked (simplest) or uncheck it to
  save ~1–2 GB.

## 2. First-launch Setup Wizard (this installs the SDK)

On first open, Android Studio runs a setup wizard:
- Choose **Standard** → **Next** → accept licenses → **Finish**.
- It downloads the **Android SDK**, **SDK Platform** (latest API), **Platform-Tools**
  (= `adb`), and **Build-Tools** — the multi-GB step.
- Installs to `C:\Users\ZGP\AppData\Local\Android\Sdk`, exactly where Flutter looks,
  so no manual path config is needed.

## 3. Add the Google USB Driver

Android Studio → **More Actions ▸ SDK Manager ▸ SDK Tools** tab → check
**Google USB Driver** → **Apply**.
- Covers Pixel/Nexus. Other brands (Samsung / Xiaomi / OnePlus / etc.) may also
  need that vendor's USB driver from their website.

**Checkpoint A:** SDK installed. Verify the toolchain:
```bash
export PATH="$PATH:/c/Users/ZGP/flutter/bin"
flutter doctor
```
Expect the **Android toolchain** line to go green. If the SDK landed elsewhere:
```bash
flutter config --android-sdk "C:/Users/ZGP/AppData/Local/Android/Sdk"
```

## 4. Accept the SDK licenses (interactive — run it yourself)

This prompts for input, so run it in an interactive terminal:
```
export PATH="$PATH:/c/Users/ZGP/flutter/bin"; flutter doctor --android-licenses
```
Press **y** through all prompts.

## 5. Prep the phone

- Settings → **About phone** → tap **Build number** ×7 ("You're a developer").
- Settings → **System ▸ Developer options** → enable **USB debugging**.
- Connect via USB; set the USB mode to **File transfer (MTP)**, not "charging only".
- Accept the **"Allow USB debugging?"** RSA prompt on the phone → check
  **Always allow** → **OK**.

**Checkpoint B:** Verify the phone is seen:
```bash
export PATH="$PATH:/c/Users/ZGP/AppData/Local/Android/Sdk/platform-tools:/c/Users/ZGP/flutter/bin"
adb devices        # phone must show as "device", not "unauthorized"
flutter devices    # phone should be listed
```
- `unauthorized` → the RSA prompt wasn't accepted (re-plug, accept it).
- Not listed at all → USB driver issue (step 3 / vendor driver).

---

## 6. Run the smoke test (FIREBASE_SETUP.md step 8)

Add this **temporary** probe at the top of `bootstrap()` in
`lib/app/bootstrap.dart`, right after `WidgetsFlutterBinding.ensureInitialized();`:

```dart
// --- TEMP smoke probe (remove after verifying) ---
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
final cred = await FirebaseAuth.instance.signInAnonymously();
await FirebaseFirestore.instance
    .doc('boards/smoke/players/${cred.user!.uid}')
    .set({'uid': cred.user!.uid, 'marks': {'0': {'m': true}}}, SetOptions(merge: true));
debugPrint('SMOKE OK -> boards/smoke/players/${cred.user!.uid}');
// --- end TEMP ---
```

Add these imports to the same file (note the `../` for firebase_options):

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
```

Run on the phone:
```bash
export PATH="$PATH:/c/Users/ZGP/flutter/bin"
flutter run
```

**Pass criteria:**
- Log prints `SMOKE OK -> boards/smoke/players/<uid>`.
- Firebase console → **Firestore → `boards/smoke/players/<uid>`** shows the doc
  with `marks: {0: {m: true}}` and a `uid` field.
- You must verify via the **console**, not the app — the `players/{uid}` read rule
  intentionally blocks the client from reading that path (`boards/smoke` has no
  `memberUids`). A *rejected write* means Anonymous auth isn't enabled (setup
  step 3) or the rules aren't deployed (setup step 6).

## 7. Cleanup

1. Remove the TEMP probe code + the four imports from `bootstrap.dart`.
2. Delete the probe doc. Client rules correctly forbid self-delete, so use the
   owner-authed CLI (the Firebase CLI here is logged in as the project owner,
   `g.sigstad@gmail.com`):
   ```bash
   firebase firestore:delete "boards/smoke" --recursive --force
   ```
   (Or delete `boards/smoke` in the console.)

---

## Notes

- The `Visual Studio not installed` line in `flutter doctor` is only for **Windows
  desktop** builds — irrelevant to Android, ignore it.
- This shell won't auto-pick-up the new SDK env vars, but that's fine: invoke
  `flutter`/`adb` with the explicit paths above (no restart of the session needed).
- **iOS is deferred** until a Mac is available. When it is: `flutterfire configure
  --project=car-bingo-no --platforms=android,ios` (the iOS
  `GoogleService-Info.plist` is currently missing), set the Podfile to
  `platform :ios, '15.0'`, then `pod install`. The iOS deployment target is
  already bumped to 15.0 in `ios/Runner.xcodeproj/project.pbxproj`.
