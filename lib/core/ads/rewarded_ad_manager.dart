import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';

import 'ad_config.dart';
import 'ad_frequency_manager.dart';

@lazySingleton
class RewardedAdManager {
  final AdFrequencyManager _frequencyManager;

  RewardedAd? _cachedAd;
  bool _isLoading = false;

  RewardedAdManager(this._frequencyManager);

  void preload() {
    if (_cachedAd != null || _isLoading) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    _isLoading = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedAd = ad;
          _isLoading = false;
          debugPrint('[AdMob] Rewarded ad pre-loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('[AdMob] Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
  }

  bool get isReady => _cachedAd != null;

  Future<bool> tryShow({
    required String rewardKey,
    VoidCallback? onRewardEarned,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    if (_frequencyManager.isRewardActive(rewardKey)) {
      debugPrint('[AdMob] Reward "$rewardKey" already active');
      onRewardEarned?.call();
      return true;
    }

    final ad = _cachedAd;
    if (ad == null) {
      debugPrint('[AdMob] No rewarded ad cached, preloading...');
      preload();
      return false;
    }

    bool rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _cachedAd = null;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMob] Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _cachedAd = null;
        preload();
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) async {
        debugPrint(
          '[AdMob] Reward earned: ${reward.amount} ${reward.type} for "$rewardKey"',
        );
        rewarded = true;
        await _frequencyManager.recordRewardEarned(rewardKey);
        onRewardEarned?.call();
      },
    );

    return rewarded;
  }

  bool isRewardActive(String rewardKey) =>
      _frequencyManager.isRewardActive(rewardKey);

  int rewardRemainingHours(String rewardKey) =>
      _frequencyManager.rewardRemainingHours(rewardKey);

  void dispose() {
    _cachedAd?.dispose();
    _cachedAd = null;
  }
}
