import 'dart:math';

import 'package:injectable/injectable.dart';

import '../../features/quotes/domain/entities/quote.dart';

@lazySingleton
class ContentMatchingService {
  static final _random = Random();

  /// Mood-to-target mapping for energy and valence
  static const Map<String, List<int>> _moodTargets = {
    'Calm': [1, 4],
    'Energized': [5, 5],
    'Reflective': [2, 3],
    'Anxious': [1, 5],
    'Grateful': [3, 5],
    'Hopeful': [4, 5],
  };

  /// Returns the current time period string
  String _getTimePeriod(int hour) {
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 18 && hour < 24) return 'evening';
    return 'anytime';
  }

  /// Score a single quote against current context
  double _scoreQuote(
    Quote quote, {
    String? mood,
    required int hour,
    required List<String> themes,
  }) {
    double score = 0;

    // Mood match (0-10 range)
    if (mood != null && _moodTargets.containsKey(mood)) {
      final targets = _moodTargets[mood]!;
      final targetEnergy = targets[0];
      final targetValence = targets[1];
      score +=
          10 -
          (quote.energy - targetEnergy).abs() -
          (quote.valence - targetValence).abs();
    }

    // Time-of-day match
    final timePeriod = _getTimePeriod(hour);
    if (quote.timeOfDay.contains(timePeriod) ||
        quote.timeOfDay.contains('anytime')) {
      score += 3;
    }

    // Preference match — tags & category vs user themes
    for (final theme in themes) {
      final lower = theme.toLowerCase();
      if (quote.category.toLowerCase() == lower ||
          quote.tags.any((t) => t.toLowerCase() == lower)) {
        score += 2;
      }
    }

    // Random jitter to prevent identical ordering
    score += _random.nextDouble();

    return score;
  }

  /// Sort quotes by personalized relevance score
  List<Quote> personalizeQuotes(
    List<Quote> quotes, {
    String? mood,
    int? hour,
    List<String> themes = const [],
  }) {
    final currentHour = hour ?? DateTime.now().hour;

    final scored = quotes.map((q) {
      final s = _scoreQuote(q, mood: mood, hour: currentHour, themes: themes);
      return MapEntry(q, s);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.map((e) => e.key).toList();
  }
}
