import 'dart:io';

import 'package:flutter/foundation.dart';

/// Centralized ad configuration constants.
///
/// ## Debug vs Production
/// - Set [isProduction] to `true` before releasing to the store.
/// - When `false` (default), all ad unit IDs are Google's official test IDs
///   so you can develop safely without risking account flags.
/// - When `true`, real production ad unit IDs are used.
///
/// ## How to go live
/// 1. Create ad units in your AdMob dashboard (https://admob.google.com).
/// 2. Paste the real IDs into the `_prod*` constants below.
/// 3. Update `AndroidManifest.xml` and `Info.plist` app IDs.
/// 4. Set `isProduction = true`.
/// 5. Build a release APK/IPA.
class AdConfig {
  AdConfig._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔧 MASTER SWITCH — flip to true for production builds
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const bool isProduction = false;

  /// Returns true when running with real ads (production mode).
  /// In debug builds this is always false regardless of [isProduction]
  /// to protect against accidental live-ad clicks during development.
  static bool get useProductionAds => isProduction && kReleaseMode;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🏭 PRODUCTION IDs — Replace with your real AdMob IDs before release
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // App IDs (from AdMob dashboard → Apps → App settings)
  static const String _prodAndroidAppId =
      'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX'; // TODO: replace
  static const String _prodIosAppId =
      'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX'; // TODO: replace

  // Native Ad Unit IDs
  static const String _prodNativeAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: replace
  static const String _prodNativeIos =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: replace

  // Interstitial Ad Unit IDs
  static const String _prodInterstitialAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: replace
  static const String _prodInterstitialIos =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: replace

  // Rewarded Ad Unit IDs
  static const String _prodRewardedAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: replace
  static const String _prodRewardedIos =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: replace

  // App Open Ad Unit IDs
  static const String _prodAppOpenAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: replace
  static const String _prodAppOpenIos =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: replace

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🧪 TEST IDs — Google's official test ad unit IDs (safe for development)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String _testAndroidAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String _testIosAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const String _testNativeAndroid =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _testNativeIos = 'ca-app-pub-3940256099942544/3986624511';

  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';

  static const String _testAppOpenAndroid =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _testAppOpenIos =
      'ca-app-pub-3940256099942544/5575463023';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 📡 PUBLIC GETTERS — automatically resolve debug vs production
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// AdMob Application IDs (used in AndroidManifest.xml / Info.plist at build time).
  static String get androidAppId =>
      useProductionAds ? _prodAndroidAppId : _testAndroidAppId;
  static String get iosAppId =>
      useProductionAds ? _prodIosAppId : _testIosAppId;

  /// Native Ad Unit ID for the current platform.
  static String get nativeAdUnitId => Platform.isAndroid
      ? (useProductionAds ? _prodNativeAndroid : _testNativeAndroid)
      : (useProductionAds ? _prodNativeIos : _testNativeIos);

  /// Interstitial Ad Unit ID for the current platform.
  static String get interstitialAdUnitId => Platform.isAndroid
      ? (useProductionAds ? _prodInterstitialAndroid : _testInterstitialAndroid)
      : (useProductionAds ? _prodInterstitialIos : _testInterstitialIos);

  /// Rewarded Ad Unit ID for the current platform.
  static String get rewardedAdUnitId => Platform.isAndroid
      ? (useProductionAds ? _prodRewardedAndroid : _testRewardedAndroid)
      : (useProductionAds ? _prodRewardedIos : _testRewardedIos);

  /// App Open Ad Unit ID for the current platform.
  static String get appOpenAdUnitId => Platform.isAndroid
      ? (useProductionAds ? _prodAppOpenAndroid : _testAppOpenAndroid)
      : (useProductionAds ? _prodAppOpenIos : _testAppOpenIos);

  // ── Native Ad Factory ID (must match platform registration) ──
  static const String nativeAdFactoryId = 'quiesNativeAd';

  // ── Frequency Cap Constants ──
  static const int interstitialCooldownSeconds = 60;
  static const int interstitialMinIntervalMinutes = 10;
  static const int interstitialMaxPerDay = 3;
  static const int appOpenInactivityMinutes = 30;
  static const int appOpenMaxPerSession = 1;
  static const int nativeAdInterval = 8;
  static const int rewardedUnlockHours = 24;

  /// Show an interstitial attempt every Nth breathing prompt the user swipes
  /// past. E.g. 2 means every 2nd breathing prompt triggers an ad attempt
  /// (subject to existing cooldown / daily caps).
  static const int breathingPromptsPerInterstitial = 2;
}
