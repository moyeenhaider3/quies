import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

/// Central gatekeeper for ad frequency caps and cooldowns.
/// All timestamps and counters persist in a dedicated Hive box
/// so limits survive app restarts.
@lazySingleton
class AdFrequencyManager {
  static const String _keyInterstitialTimestamps = 'interstitial_timestamps';
  static const String _keyLastInterstitialTime = 'last_interstitial_time';
  static const String _keyAppOpenShowCount = 'app_open_show_count';
  static const String _keyAppOpenSessionId = 'app_open_session_id';
  static const String _keyRewardedUnlocks = 'rewarded_unlocks';
  static const String _keyFirstLaunchDone = 'first_launch_done';

  final Box<dynamic> _box;

  /// In-memory session ID — changes every cold start.
  late final String _currentSessionId;

  AdFrequencyManager(@Named('adFrequencyBox') this._box) {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  // ═══════════════════════════════════════════════════════
  // FIRST LAUNCH
  // ═══════════════════════════════════════════════════════

  bool get isFirstLaunchEver => !_box.containsKey(_keyFirstLaunchDone);

  Future<void> markFirstSessionComplete() async {
    if (!_box.containsKey(_keyFirstLaunchDone)) {
      await _box.put(_keyFirstLaunchDone, true);
    }
  }

  // ═══════════════════════════════════════════════════════
  // INTERSTITIAL ADS
  // ═══════════════════════════════════════════════════════

  bool canShowInterstitial() {
    final now = DateTime.now();

    // 1. 60-second cooldown
    final lastShow = _box.get(_keyLastInterstitialTime) as int?;
    if (lastShow != null) {
      final elapsed = now.millisecondsSinceEpoch - lastShow;
      if (elapsed < 60 * 1000) return false;
    }

    // 2. Max 1 per 10 minutes (rolling window)
    final timestamps = _getInterstitialTimestamps();
    final tenMinAgo = now.millisecondsSinceEpoch - (10 * 60 * 1000);
    final recentCount = timestamps.where((t) => t > tenMinAgo).length;
    if (recentCount >= 1) return false;

    // 3. Max 3 per calendar day
    final todayStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;
    final todayCount = timestamps.where((t) => t >= todayStart).length;
    if (todayCount >= 3) return false;

    return true;
  }

  Future<void> recordInterstitialShown() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _box.put(_keyLastInterstitialTime, now);

    final timestamps = _getInterstitialTimestamps();
    timestamps.add(now);

    final cutoff = now - (24 * 60 * 60 * 1000);
    final pruned = timestamps.where((t) => t > cutoff).toList();
    await _box.put(_keyInterstitialTimestamps, pruned);
  }

  List<int> _getInterstitialTimestamps() {
    final raw = _box.get(_keyInterstitialTimestamps);
    if (raw == null) return [];
    return List<int>.from(raw);
  }

  // ═══════════════════════════════════════════════════════
  // APP OPEN ADS
  // ═══════════════════════════════════════════════════════

  bool canShowAppOpenAd() {
    if (isFirstLaunchEver) return false;

    final storedSessionId = _box.get(_keyAppOpenSessionId) as String?;
    final showCount = _box.get(_keyAppOpenShowCount, defaultValue: 0) as int;

    if (storedSessionId == _currentSessionId && showCount >= 1) {
      return false;
    }

    return true;
  }

  Future<void> recordAppOpenAdShown() async {
    final storedSessionId = _box.get(_keyAppOpenSessionId) as String?;

    if (storedSessionId != _currentSessionId) {
      await _box.put(_keyAppOpenSessionId, _currentSessionId);
      await _box.put(_keyAppOpenShowCount, 1);
    } else {
      final count = _box.get(_keyAppOpenShowCount, defaultValue: 0) as int;
      await _box.put(_keyAppOpenShowCount, count + 1);
    }
  }

  // ═══════════════════════════════════════════════════════
  // REWARDED ADS
  // ═══════════════════════════════════════════════════════

  bool isRewardActive(String rewardKey) {
    final unlocks = _getRewardedUnlocks();
    final unlockTime = unlocks[rewardKey];
    if (unlockTime == null) return false;

    final elapsed = DateTime.now().millisecondsSinceEpoch - unlockTime;
    return elapsed < 24 * 60 * 60 * 1000;
  }

  Future<void> recordRewardEarned(String rewardKey) async {
    final unlocks = _getRewardedUnlocks();
    unlocks[rewardKey] = DateTime.now().millisecondsSinceEpoch;
    await _box.put(_keyRewardedUnlocks, unlocks);
  }

  int rewardRemainingHours(String rewardKey) {
    final unlocks = _getRewardedUnlocks();
    final unlockTime = unlocks[rewardKey];
    if (unlockTime == null) return 0;

    final elapsed = DateTime.now().millisecondsSinceEpoch - unlockTime;
    final remaining = (24 * 60 * 60 * 1000) - elapsed;
    if (remaining <= 0) return 0;
    return (remaining / (60 * 60 * 1000)).ceil();
  }

  Map<String, int> _getRewardedUnlocks() {
    final raw = _box.get(_keyRewardedUnlocks);
    if (raw == null) return {};
    return Map<String, int>.from(raw);
  }

  // ═══════════════════════════════════════════════════════
  // DIAGNOSTICS
  // ═══════════════════════════════════════════════════════

  Map<String, dynamic> debugState() {
    final now = DateTime.now();
    final todayStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;
    final timestamps = _getInterstitialTimestamps();

    return {
      'interstitials_today': timestamps.where((t) => t >= todayStart).length,
      'last_interstitial_ms_ago': _box.get(_keyLastInterstitialTime) != null
          ? now.millisecondsSinceEpoch -
                (_box.get(_keyLastInterstitialTime) as int)
          : null,
      'app_open_shown_this_session':
          _box.get(_keyAppOpenSessionId) == _currentSessionId
          ? _box.get(_keyAppOpenShowCount, defaultValue: 0)
          : 0,
      'session_id': _currentSessionId,
      'active_rewards': _getRewardedUnlocks().entries
          .where(
            (e) =>
                DateTime.now().millisecondsSinceEpoch - e.value <
                24 * 60 * 60 * 1000,
          )
          .map((e) => e.key)
          .toList(),
    };
  }
}
