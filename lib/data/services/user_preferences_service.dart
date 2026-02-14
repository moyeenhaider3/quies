import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserPreferencesService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyMood = 'mood';
  static const String _keyThemes = 'themes';
  static const String _keyGoals = 'goals';
  static const String _keyBookmarkedQuoteIds = 'bookmarked_quote_ids';
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyQuoteFont = 'quote_font';
  static const String _keyQuoteFontSize = 'quote_font_size';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';
  static const String _keyLastActiveTimestamp = 'last_active_timestamp';
  static const String _keyAudioEnabled = 'audio_enabled';

  final Box<dynamic> _box;

  UserPreferencesService(@Named('userBox') this._box);

  bool get onboardingCompleted =>
      _box.get(_keyOnboardingCompleted, defaultValue: false);

  Future<void> setOnboardingCompleted(bool value) async {
    await _box.put(_keyOnboardingCompleted, value);
  }

  String? get mood => _box.get(_keyMood);

  Future<void> setMood(String mood) async {
    await _box.put(_keyMood, mood);
  }

  List<String> get themes =>
      List<String>.from(_box.get(_keyThemes, defaultValue: []) ?? []);

  Future<void> setThemes(List<String> themes) async {
    await _box.put(_keyThemes, themes);
  }

  List<String> get goals =>
      List<String>.from(_box.get(_keyGoals, defaultValue: []) ?? []);

  Future<void> setGoals(List<String> goals) async {
    await _box.put(_keyGoals, goals);
  }

  // Bookmark persistence
  List<String> get bookmarkedQuoteIds => List<String>.from(
    _box.get(_keyBookmarkedQuoteIds, defaultValue: []) ?? [],
  );

  bool isBookmarked(String quoteId) => bookmarkedQuoteIds.contains(quoteId);

  Future<void> addBookmark(String quoteId) async {
    final ids = bookmarkedQuoteIds;
    if (!ids.contains(quoteId)) {
      ids.add(quoteId);
      await _box.put(_keyBookmarkedQuoteIds, ids);
    }
  }

  Future<void> removeBookmark(String quoteId) async {
    final ids = bookmarkedQuoteIds;
    ids.remove(quoteId);
    await _box.put(_keyBookmarkedQuoteIds, ids);
  }

  // Theme settings
  bool get isDarkMode => _box.get(_keyIsDarkMode, defaultValue: true);

  Future<void> setIsDarkMode(bool value) async {
    await _box.put(_keyIsDarkMode, value);
  }

  String get quoteFont =>
      _box.get(_keyQuoteFont, defaultValue: 'Playfair Display');

  Future<void> setQuoteFont(String font) async {
    await _box.put(_keyQuoteFont, font);
  }

  double get quoteFontSize =>
      (_box.get(_keyQuoteFontSize, defaultValue: 32.0) as num).toDouble();

  Future<void> setQuoteFontSize(double size) async {
    await _box.put(_keyQuoteFontSize, size);
  }

  // Notification settings
  bool get notificationsEnabled =>
      _box.get(_keyNotificationsEnabled, defaultValue: false);

  Future<void> setNotificationsEnabled(bool value) async {
    await _box.put(_keyNotificationsEnabled, value);
  }

  int get reminderHour => _box.get(_keyReminderHour, defaultValue: 9);

  Future<void> setReminderHour(int hour) async {
    await _box.put(_keyReminderHour, hour);
  }

  int get reminderMinute => _box.get(_keyReminderMinute, defaultValue: 0);

  Future<void> setReminderMinute(int minute) async {
    await _box.put(_keyReminderMinute, minute);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  // Session awareness
  int? get lastActiveTimestamp => _box.get(_keyLastActiveTimestamp);

  Future<void> setLastActiveTimestamp(int millis) async {
    await _box.put(_keyLastActiveTimestamp, millis);
  }

  /// Returns true if the user has been away for more than [minutes] minutes.
  bool hasBeenInactiveFor({int minutes = 30}) {
    final last = lastActiveTimestamp;
    if (last == null) return false;
    final elapsed = DateTime.now().millisecondsSinceEpoch - last;
    return elapsed > minutes * 60 * 1000;
  }

  // Audio preference (default: enabled for fresh installs)
  bool get audioEnabled => _box.get(_keyAudioEnabled, defaultValue: true);

  Future<void> setAudioEnabled(bool value) async {
    await _box.put(_keyAudioEnabled, value);
  }
}
