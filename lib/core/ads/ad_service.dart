import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'ad_frequency_manager.dart';
import 'interstitial_ad_manager.dart';

@lazySingleton
class AdService {
  final InterstitialAdManager _interstitialManager;
  final AdFrequencyManager _frequencyManager;

  AdService(
    this._interstitialManager,
    this._frequencyManager,
  );

  void initialize() {
    _interstitialManager.preload();
    debugPrint('[AdMob] AdService initialized — preloading ads');
  }

  Future<bool> tryShowInterstitial() async {
    return _interstitialManager.tryShow();
  }

  bool isRewardActive(String rewardKey) =>
      _frequencyManager.isRewardActive(rewardKey);

  Future<void> recordRewardEarned(String rewardKey) =>
      _frequencyManager.recordRewardEarned(rewardKey);

  int rewardRemainingHours(String rewardKey) =>
      _frequencyManager.rewardRemainingHours(rewardKey);

  Map<String, dynamic> debugState() => _frequencyManager.debugState();

  void dispose() {
    _interstitialManager.dispose();
  }
}
