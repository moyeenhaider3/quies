import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/ads/ad_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../data/services/user_preferences_service.dart';
import '../bloc/feed_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    final prefs = getIt<UserPreferencesService>();
    _notificationsEnabled = prefs.notificationsEnabled;
    _reminderTime = TimeOfDay(
      hour: prefs.reminderHour,
      minute: prefs.reminderMinute,
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    final notifService = getIt<NotificationService>();

    if (value) {
      final granted = await notifService.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Notification permission denied',
                style: GoogleFonts.outfit(),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      await notifService.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      await notifService.cancelDailyReminder();
    }

    setState(() => _notificationsEnabled = value);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'Set reminder time',
    );
    if (picked == null) return;

    setState(() => _reminderTime = picked);

    if (_notificationsEnabled) {
      await getIt<NotificationService>().scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
      );
    } else {
      // Just persist the time even if not enabled yet
      final prefs = getIt<UserPreferencesService>();
      await prefs.setReminderHour(picked.hour);
      await prefs.setReminderMinute(picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          getIt<AdService>().tryShowInterstitial();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildSectionHeader(context, 'Appearance'),
              _buildThemeToggle(context, themeState, isDark),
              const SizedBox(height: 8),
              _buildFontSelector(context, themeState, isDark),
              const SizedBox(height: 8),
              _buildFontSizeSlider(context, themeState, isDark),

              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Notifications'),
              _buildNotificationToggle(context, isDark),
              const SizedBox(height: 8),
              _buildReminderTimeTile(context, isDark),

              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Preferences'),
              _buildRetakeQuizTile(context, isDark),

              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Data'),
              _buildExportBookmarksTile(context, isDark),

              const SizedBox(height: 32),
              _buildFontPreview(themeState, isDark),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isDark,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildThemeToggle(
    BuildContext context,
    ThemeState themeState,
    bool isDark,
  ) {
    return _buildSettingsTile(
      context: context,
      icon: themeState.isDarkMode
          ? Icons.dark_mode_rounded
          : Icons.light_mode_rounded,
      title: 'Dark Mode',
      subtitle: themeState.isDarkMode ? 'On' : 'Off',
      isDark: isDark,
      trailing: Switch.adaptive(
        value: themeState.isDarkMode,
        onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => context.read<ThemeCubit>().toggleTheme(),
    );
  }

  Widget _buildFontSelector(
    BuildContext context,
    ThemeState themeState,
    bool isDark,
  ) {
    return _buildSettingsTile(
      context: context,
      icon: Icons.font_download_rounded,
      title: 'Quote Font',
      subtitle: themeState.quoteFont,
      isDark: isDark,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showFontPicker(context, themeState.quoteFont),
    );
  }

  void _showFontPicker(BuildContext context, String currentFont) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1A2E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose Quote Font',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...AppTheme.availableFonts.map((font) {
                  final isSelected = font == currentFont;
                  return ListTile(
                    title: Text(
                      'The quick brown fox',
                      style: AppTheme.quoteTextStyle(
                        fontFamily: font,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      font,
                      style: GoogleFonts.outfit(fontSize: 13),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      context.read<ThemeCubit>().setQuoteFont(font);
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    ThemeState themeState,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_fields_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                'Text Size',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${themeState.quoteFontSize.round()}',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          Slider(
            value: themeState.quoteFontSize,
            min: 20,
            max: 44,
            divisions: 12,
            label: '${themeState.quoteFontSize.round()}',
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              context.read<ThemeCubit>().setQuoteFontSize(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRetakeQuizTile(BuildContext context, bool isDark) {
    return _buildSettingsTile(
      context: context,
      icon: Icons.quiz_rounded,
      title: 'Retake Preference Quiz',
      subtitle: 'Update your mood and theme preferences',
      isDark: isDark,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Retake Quiz?',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'This will take you back to the onboarding quiz to update your preferences.',
              style: GoogleFonts.outfit(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  final prefs = getIt<UserPreferencesService>();
                  prefs.setOnboardingCompleted(false);
                  context.go('/onboarding');
                },
                child: const Text('Retake'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportBookmarksTile(BuildContext context, bool isDark) {
    return _buildSettingsTile(
      context: context,
      icon: Icons.ios_share_rounded,
      title: 'Export Bookmarks',
      subtitle: 'Share your saved quotes as text',
      isDark: isDark,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        final feedState = context.read<FeedBloc>().state;
        if (feedState is! FeedLoaded || feedState.bookmarkedIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No bookmarked quotes to export',
                style: GoogleFonts.outfit(),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final bookmarked = feedState.quotes
            .where((q) => feedState.bookmarkedIds.contains(q.id))
            .toList();

        final buffer = StringBuffer('My Saved Quotes from Quies\n\n');
        for (final q in bookmarked) {
          buffer.writeln('"${q.text}"');
          buffer.writeln('— ${q.author}');
          buffer.writeln();
        }

        SharePlus.instance.share(ShareParams(text: buffer.toString()));
      },
    );
  }

  Widget _buildNotificationToggle(BuildContext context, bool isDark) {
    return _buildSettingsTile(
      context: context,
      icon: _notificationsEnabled
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_rounded,
      title: 'Daily Reminder',
      subtitle: _notificationsEnabled ? 'On' : 'Off',
      isDark: isDark,
      trailing: Switch.adaptive(
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => _toggleNotifications(!_notificationsEnabled),
    );
  }

  Widget _buildReminderTimeTile(BuildContext context, bool isDark) {
    final formatted = _reminderTime.format(context);
    return _buildSettingsTile(
      context: context,
      icon: Icons.access_time_rounded,
      title: 'Reminder Time',
      subtitle: formatted,
      isDark: isDark,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: _pickReminderTime,
    );
  }

  Widget _buildFontPreview(ThemeState themeState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Preview',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white38 : Colors.black38,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Peace comes from within.',
            style: AppTheme.quoteTextStyle(
              fontFamily: themeState.quoteFont,
              fontSize: themeState.quoteFontSize,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '— Buddha',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
