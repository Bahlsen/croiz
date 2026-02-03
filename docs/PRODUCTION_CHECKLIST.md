# 🚀 Production Checklist

A comprehensive guide for preparing Croiz for release on the Google Play Store and Apple App Store.

## 📱 Application Logic & QA

- [ ] **Ads Configuration**
  - [ ] Replace Test Ad Unit IDs with real AdMob Unit IDs in `lib/core/config/ad_config.dart`.
  - [ ] Verify `app-ads.txt` is hosted on your developer website.
  - [ ] Ensure "Data Safety" form in Play Console matches the AdMob data collection.

- [ ] **Feature Flags**
  - [ ] Disable debug logs (ensure `kDebugMode` checks are in place).
  - [ ] Verify `skipTutorial` or debug shortcuts are removed/disabled.

- [ ] **Testing**
  - [ ] **Smoke Test**: Install release build (`flutter run --release`) on a physical Android device.
  - [ ] **Smoke Test**: Install release build on a physical iOS device.
  - [ ] **Offline Test**: Verify app works 100% offline (except for AI generation which should fail gracefully).
  - [ ] **Upgrade Test**: If updating from a previous version, test migration of `drift` database and `shared_preferences`.

- [ ] **Localization**
  - [ ] Verify all 8 languages have complete translations (no missing keys).
  - [ ] Check UI layout for text overflow in verbose languages (German, Russian).

## 🔐 Security & Compliance

- [ ] **Privacy Policy & ToS**
  - [ ] Host policies on a public URL (e.g., GitHub Pages or website).
  - [ ] Update links in `AboutDialog` / Settings screen.
  - [ ] Ensure compliance with **GDPR** (EU) and **CCPA** (California) - AdMob consent form should assume this responsibility but verify configuration in AdMob console.

- [ ] **Signing**
  - [ ] **Android**: Generate upload keystore (`.jks`).
  - [ ] **Android**: Configure `key.properties` (never commit this!).
  - [ ] **iOS**: Create Distribution Certificate and Provisioning Profile via Xcode/Apple Developer Portal.

- [ ] **Permissions**
  - [ ] Review `AndroidManifest.xml` and `Info.plist`.
  - [ ] Remove any unused permissions (e.g., internet is needed, but check for others like location or camera if not used).

## 🎨 Assets & Store Listing

- [ ] **App Icons**
  - [ ] Verify adaptive icons for Android (foreground/background).
  - [ ] Verify all iOS icon sizes using `flutter_launcher_icons`.

- [ ] **Screenshots**
  - [/] Generate screenshots for 6.5" and 5.5" displays (can use `integration_test` to automate).
  - [ ] Update screenshots with new Achievements and Statistics screens.
  - [ ] Create a "Feature Graphic" for Play Store (1024x500).

- [ ] **Metadata**
  - [ ] Write Title (30 chars), Short Description (80 chars), Full Description (4000 chars).
  - [ ] Translate store listing into target languages (EN, FR, ES, etc.).

## 📦 Build & Release

- [ ] **Versioning**
  - [ ] Update `version` in `pubspec.yaml` (e.g., `1.0.0+1`).
  - [ ] Ensure `versionCode` (Android) and `CFBundleVersion` (iOS) are incremented.

- [ ] **Android Build**
  ```bash
  flutter build appbundle --release --obfuscate --split-debug-info=./debug-info
  ```

- [ ] **iOS Build**
  ```bash
  flutter build ipa --release --obfuscate --split-debug-info=./debug-info
  ```

- [ ] **Upload**
  - [ ] Upload `.aab` to Play Console (Internal Testing first).
  - [ ] Upload `.ipa` to TestFlight via Transporter or Xcode.

## 📡 Post-Release

- [ ] **Monitoring**
  - [ ] Check Firebase Crashlytics for any immediate crashes.
  - [ ] Monitor AdMob match rates.

- [ ] **Marketing**
  - [ ] Announce on social media / channels.

---

**Last Updated**: February 2026
