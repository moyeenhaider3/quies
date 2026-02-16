import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'ad_frequency_manager.dart';
import 'app_open_ad_manager.dart';
import 'interstitial_ad_manager.dart';
import 'rewarded_ad_manager.dart';

@lazySingleton
class AdService {
  final InterstitialAdManager _interstitialManager;
  final AppOpenAdManager _appOpenAdManager;
  final RewardedAdManager _rewardedAdManager;
  final AdFrequencyManager _frequencyManager;

  AdService(
    this._interstitialManager,
    this._appOpenAdManager,
    this._rewardedAdManager,
    this._frequencyManager,
  );

  void initialize() {
    _interstitialManager.preload();
    _rewardedAdManager.preload();
    _appOpenAdManager.startListening();
    debugPrint(
      '[AdMob] AdService initialized — preloading ads, listening for resume',
    );
  }

  Future<bool> tryShowInterstitial() async {
    return _interstitialManager.tryShow();
  }

  Future<bool> tryShowRewarded({
    required String rewardKey,
    VoidCallback? onRewardEarned,
  }) async {
    return _rewardedAdManager.tryShow(
      rewardKey: rewardKey,
      onRewardEarned: onRewardEarned,
    );
  }

  bool get isRewardedAdReady => _rewardedAdManager.isReady;

  bool isRewardActive(String rewardKey) =>
      _frequencyManager.isRewardActive(rewardKey);

  Future<void> recordRewardEarned(String rewardKey) =>
      _frequencyManager.recordRewardEarned(rewardKey);

  int rewardRemainingHours(String rewardKey) =>
      _frequencyManager.rewardRemainingHours(rewardKey);

  Map<String, dynamic> debugState() => _frequencyManager.debugState();

  void dispose() {
    _interstitialManager.dispose();
    _rewardedAdManager.dispose();
    _appOpenAdManager.stopListening();
  }
}
