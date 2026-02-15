import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';

import 'ad_config.dart';
import 'ad_frequency_manager.dart';

@lazySingleton
class InterstitialAdManager {
  final AdFrequencyManager _frequencyManager;

  InterstitialAd? _cachedAd;
  bool _isLoading = false;

  InterstitialAdManager(this._frequencyManager);

  void preload() {
    if (_cachedAd != null || _isLoading) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedAd = ad;
          _isLoading = false;
          debugPrint('[AdMob] Interstitial pre-loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('[AdMob] Interstitial failed to load: ${error.message}');
        },
      ),
    );
  }

  Future<bool> tryShow() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    if (!_frequencyManager.canShowInterstitial()) {
      debugPrint('[AdMob] Interstitial blocked by frequency cap');
      return false;
    }

    final ad = _cachedAd;
    if (ad == null) {
      debugPrint('[AdMob] No interstitial cached, preloading...');
      preload();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _cachedAd = null;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMob] Interstitial failed to show: ${error.message}');
        ad.dispose();
        _cachedAd = null;
        preload();
      },
    );

    await ad.show();
    await _frequencyManager.recordInterstitialShown();
    debugPrint('[AdMob] Interstitial shown');
    return true;
  }

  void dispose() {
    _cachedAd?.dispose();
    _cachedAd = null;
  }
}
