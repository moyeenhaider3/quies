import 'dart:io';

/// Centralized ad configuration constants.
/// All ad unit IDs are test IDs — replace with production IDs before release.
class AdConfig {
  AdConfig._();

  // ── AdMob Application IDs (test) ──
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';

  // ── Native Ad Unit IDs (test) ──
  static String get nativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  // ── Interstitial Ad Unit IDs (test) ──
  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  // ── Rewarded Ad Unit IDs (test) ──
  static String get rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  // ── App Open Ad Unit IDs (test) ──
  static String get appOpenAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9257395921'
      : 'ca-app-pub-3940256099942544/5575463023';

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
}
