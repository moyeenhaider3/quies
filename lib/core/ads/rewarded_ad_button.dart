import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../di/injection.dart';
import '../theme/app_theme.dart';
import 'ad_service.dart';

class RewardedAdButton extends StatefulWidget {
  final String rewardKey;
  final String label;
  final IconData icon;
  final VoidCallback? onRewardEarned;

  const RewardedAdButton({
    super.key,
    required this.rewardKey,
    required this.label,
    this.icon = Icons.play_circle_outline_rounded,
    this.onRewardEarned,
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  bool _isLoading = false;

  AdService get _adService => getIt<AdService>();

  bool get _isUnlocked => _adService.isRewardActive(widget.rewardKey);

  int get _remainingHours => _adService.rewardRemainingHours(widget.rewardKey);

  Future<void> _watchAd() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final earned = await _adService.tryShowRewarded(
      rewardKey: widget.rewardKey,
      onRewardEarned: () {
        widget.onRewardEarned?.call();
      },
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (!earned) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ad not ready yet. Please try again in a moment.',
              style: GoogleFonts.outfit(),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isUnlocked) {
      return _buildUnlockedState(isDark);
    }

    return _buildLockedState(isDark);
  }

  Widget _buildUnlockedState(bool isDark) {
    final hours = _remainingHours;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.calmTeal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.calmTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.calmTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Unlocked • ${hours}h remaining',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.calmTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedState(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _watchAd,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    )
                  : Icon(
                      widget.icon,
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 20,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.calmTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 14,
                      color: AppTheme.calmTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Watch ad',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.calmTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
