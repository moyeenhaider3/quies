# Plan 11-01 Summary: AdMob SDK Setup & Platform Configuration

## Objective

Integrate the `google_mobile_ads` and `app_tracking_transparency` packages, configure both Android and iOS platforms with AdMob identifiers, create an `AdConfig` constants class with test ad unit IDs, implement GDPR/ATT consent handling, and initialize AdMob in `main.dart`.

## What Was Done

### Task 1: Add dependencies to pubspec.yaml
- Added `google_mobile_ads: ^5.3.0` (resolved to 5.3.1)
- Added `app_tracking_transparency: ^2.0.6`
- Ran `flutter pub get` successfully

### Task 2: Create AdConfig constants class
- Created `lib/core/ads/ad_config.dart` with test ad unit IDs for all 4 ad formats (native, interstitial, rewarded, app open) per platform
- Includes frequency cap constants and native ad factory ID

### Task 3: Create ConsentManager for GDPR/ATT
- Created `lib/core/ads/consent_manager.dart` with `@lazySingleton` annotation
- Handles ATT prompt on iOS 14.5+ via `app_tracking_transparency`
- Handles GDPR consent via Google UMP SDK (`ConsentInformation`, `ConsentForm`)
- Exposes `canShowPersonalizedAds` getter

### Task 4: Configure Android — AndroidManifest.xml
- Added `com.google.android.gms.ads.APPLICATION_ID` meta-data with test app ID before the flutter embedding meta-data

### Task 5: Configure iOS — Info.plist
- Added `GADApplicationIdentifier` with test app ID
- Added `NSUserTrackingUsageDescription` with user-friendly message
- Added `SKAdNetworkItems` array with 14 SKAdNetwork identifiers

### Task 6: Configure iOS — Podfile platform version
- Changed `# platform :ios, '13.0'` to `platform :ios, '14.0'` (uncommented and bumped)

### Task 7: Initialize AdMob in main.dart
- Added imports for `google_mobile_ads` and `ConsentManager`
- Added `await getIt<ConsentManager>().gatherConsent()` after `configureDependencies()`
- Added `await MobileAds.instance.initialize()` after consent gathering
- Both calls placed BEFORE `NotificationService.init()`

### Task 8: Run build_runner to register ConsentManager in DI
- Ran `dart run build_runner build --delete-conflicting-outputs`
- Verified `ConsentManager` registered as `lazySingleton` in `injection.config.dart`

### Build Verification
- `flutter build apk --release` completed successfully (59.3MB APK)

## Files Created
- `lib/core/ads/ad_config.dart`
- `lib/core/ads/consent_manager.dart`
- `.planning/phases/11-google-ads-monetization/11-01-SUMMARY.md`

## Files Modified
- `pubspec.yaml`
- `pubspec.lock`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
- `ios/Podfile`
- `lib/main.dart`
- `lib/core/di/injection.config.dart`

## Commit Hashes
| Hash | Message |
|------|---------|
| `b5608c5` | `chore(11-01): add google_mobile_ads and app_tracking_transparency deps` |
| `ba58b73` | `feat(11-01): create AdConfig and ConsentManager` |
| `09c4c36` | `feat(11-01): configure Android and iOS for AdMob` |
| `751eb1f` | `feat(11-01): initialize AdMob SDK in main.dart` |

## Deviations
- None. All tasks completed exactly as specified in the plan.
