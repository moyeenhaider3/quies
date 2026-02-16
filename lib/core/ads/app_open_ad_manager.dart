import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';

import '../../data/services/user_preferences_service.dart';
import 'ad_config.dart';
import 'ad_frequency_manager.dart';

@lazySingleton
class AppOpenAdManager with WidgetsBindingObserver {
  final AdFrequencyManager _frequencyManager;
  final UserPreferencesService _userPreferences;

  AppOpenAd? _cachedAd;
  bool _isLoading = false;
  bool _isShowingAd = false;

  AppOpenAdManager(this._frequencyManager, this._userPreferences);

  void startListening() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    WidgetsBinding.instance.addObserver(this);
    _preload();
    debugPrint('[AdMob] AppOpenAdManager started lifecycle listening');
  }

  void stopListening() {
    WidgetsBinding.instance.removeObserver(this);
    _cachedAd?.dispose();
    _cachedAd = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  void _onAppPaused() {
    _userPreferences.setLastActiveTimestamp(
      DateTime.now().millisecondsSinceEpoch,
    );
    _frequencyManager.markFirstSessionComplete();
    debugPrint('[AdMob] App paused — timestamp recorded');
  }

  void _onAppResumed() {
    debugPrint('[AdMob] App resumed — checking for app open ad');
    if (_isShowingAd) return;
    if (!_userPreferences.hasBeenInactiveFor(
      minutes: AdConfig.appOpenInactivityMinutes,
    )) {
      debugPrint('[AdMob] App open ad skipped — not inactive long enough');
      return;
    }
    if (!_frequencyManager.canShowAppOpenAd()) {
      debugPrint('[AdMob] App open ad blocked by frequency cap');
      return;
    }
    _tryShow();
  }

  void _preload() {
    if (_cachedAd != null || _isLoading) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    _isLoading = true;
    AppOpenAd.load(
      adUnitId: AdConfig.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedAd = ad;
          _isLoading = false;
          debugPrint('[AdMob] App open ad pre-loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('[AdMob] App open ad failed to load: ${error.message}');
        },
      ),
    );
  }

  Future<void> _tryShow() async {
    final ad = _cachedAd;
    if (ad == null) {
      debugPrint('[AdMob] No app open ad cached, preloading...');
      _preload();
      return;
    }
    _isShowingAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdMob] App open ad dismissed');
        _isShowingAd = false;
        ad.dispose();
        _cachedAd = null;
        _preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMob] App open ad failed to show: ${error.message}');
        _isShowingAd = false;
        ad.dispose();
        _cachedAd = null;
        _preload();
      },
    );
    await ad.show();
    await _frequencyManager.recordAppOpenAdShown();
    debugPrint('[AdMob] App open ad shown');
  }
}
