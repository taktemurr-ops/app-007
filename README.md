# APP-007 — Tarif 360 (development snapshot, not a completed release)

Offline-first Flutter recipe manager with recipe creation, ingredient quantities and scaling, multi-step preparation notes, favorites, seven-day meal planner, aggregated weekly shopping lists, clipboard sharing, secure local persistence, JSON backup/restore and user-confirmed deletion. Turkish, English and Arabic UI labels are included for the main navigation and essential workflows; language and accessibility audits remain outstanding.

## Build and tests

```sh
flutter create --platforms=android,ios --project-name tarif_360 .
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

The project is not publication-ready: native Android/iOS tests and signing, original 20-module product scope acceptance, store assets and any approved production integrations remain unverified. Recipe instructions and amounts are user-provided, not externally verified. Keep copied JSON exports private because clipboard text is unencrypted.
