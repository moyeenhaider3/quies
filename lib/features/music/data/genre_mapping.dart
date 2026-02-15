/// Supported genres for genre selection.
const List<String> supportedGenres = [
  'inspirational',
  'love',
  'peace',
  'sad',
  'success',
];

/// Maps user-facing genre to Quotable API tag.
const Map<String, String> genreQuoteTagMap = {
  'inspirational': 'inspirational',
  'love': 'love',
  'peace': 'wisdom',
  'sad': 'life',
  'success': 'success',
};

/// Maps user-facing genre to iTunes music search keyword.
const Map<String, String> genreMusicMap = {
  'inspirational': 'motivational instrumental',
  'love': 'romantic instrumental',
  'peace': 'calm ambient',
  'sad': 'soft piano instrumental',
  'success': 'epic instrumental',
};

/// Fallback keywords when primary music search returns no preview.
const Map<String, String> fallbackMusicMap = {
  'inspirational': 'uplifting background',
  'love': 'love song acoustic',
  'peace': 'meditation music',
  'sad': 'melancholy piano',
  'success': 'triumphant music',
};

/// Genre display metadata for UI.
const Map<String, String> genreIcons = {
  'inspirational': '✨',
  'love': '❤️',
  'peace': '🕊️',
  'sad': '🌧️',
  'success': '🏆',
};

// ---------------------------------------------------------------------------
// Comprehensive tag → music keyword mapping for all API tags
// ---------------------------------------------------------------------------

/// Maps Quotable API tag slugs to iTunes music search keywords.
const Map<String, String> tagMusicKeywordMap = {
  'inspirational': 'motivational instrumental',
  'motivational': 'motivational instrumental',
  'love': 'romantic instrumental',
  'happiness': 'happy upbeat instrumental',
  'life': 'ambient peaceful',
  'wisdom': 'calm ambient',
  'success': 'epic instrumental',
  'friendship': 'feel good acoustic',
  'knowledge': 'calm piano',
  'humor': 'playful instrumental',
  'philosophy': 'contemplative ambient',
  'science': 'electronic ambient',
  'technology': 'electronic ambient',
  'faith': 'spiritual instrumental',
  'hope': 'uplifting instrumental',
  'courage': 'epic cinematic',
  'change': 'transformative ambient',
  'character': 'classical instrumental',
  'competition': 'energetic instrumental',
  'education': 'calm study music',
  'famous-quotes': 'classical instrumental',
  'film': 'cinematic score',
  'freedom': 'uplifting acoustic',
  'future': 'electronic ambient',
  'history': 'classical orchestral',
  'nature': 'nature sounds ambient',
  'power-quotes': 'powerful orchestral',
  'religion': 'spiritual meditation',
  'sports': 'energetic pump up',
  'tolerance': 'peaceful world music',
  'virtue': 'gentle classical',
  'work': 'focus instrumental',
};

/// Default music keyword when no tag matches.
const String defaultMusicKeyword = 'ambient instrumental';

/// Maps mood names (case-insensitive keys) to lists of Quotable API tags.
///
/// Keys match the mood options in onboarding and feed mood selector.
const Map<String, List<String>> moodToTagsMap = {
  // Feed moods (primary)
  'Calm': ['wisdom', 'nature', 'philosophy', 'tolerance'],
  'Energized': ['motivational', 'success', 'sports', 'competition'],
  'Reflective': ['life', 'philosophy', 'wisdom', 'change'],
  'Anxious': ['hope', 'faith', 'courage', 'tolerance'],
  'Grateful': ['happiness', 'friendship', 'love', 'virtue'],
  'Hopeful': ['inspirational', 'hope', 'freedom', 'future'],
  // Onboarding moods (extras)
  'Stressed': ['wisdom', 'nature', 'tolerance', 'philosophy'],
  'Tired': ['inspirational', 'motivational', 'hope', 'nature'],
  'Sad': ['hope', 'faith', 'change', 'happiness'],
  'Okay': ['life', 'wisdom', 'humor', 'knowledge'],
};

/// Returns the best iTunes music keyword for the given [tags].
///
/// Checks each tag against [tagMusicKeywordMap] and returns the first match.
/// Falls back to [defaultMusicKeyword] if no tags match.
String getMusicKeywordForTags(List<String> tags) {
  for (final tag in tags) {
    final keyword = tagMusicKeywordMap[tag];
    if (keyword != null) return keyword;
  }
  return defaultMusicKeyword;
}

// ---------------------------------------------------------------------------
// Mood-based music keywords (Phase 8)
// ---------------------------------------------------------------------------

/// Maps mood names to iTunes search keywords for music tone.
const Map<String, String> moodMusicKeywordMap = {
  'Calm': 'calm ambient',
  'Energized': 'upbeat pop hits',
  'Reflective': 'acoustic indie',
  'Anxious': 'soothing instrumental',
  'Grateful': 'feel good songs',
  'Hopeful': 'uplifting songs',
  'Stressed': 'relaxing piano',
  'Tired': 'gentle ambient',
  'Sad': 'soft piano ballad',
  'Okay': 'chill lofi',
};

/// Moods that should get instrumental music (no vocals).
const Set<String> instrumentalMoods = {'Calm', 'Anxious', 'Stressed', 'Tired'};

/// Moods that should get vocal songs.
const Set<String> vocalMoods = {
  'Energized',
  'Reflective',
  'Grateful',
  'Hopeful',
};

/// Build combined iTunes search query from mood and tag.
///
/// Example: mood='Calm', tags=['nature'] → 'calm ambient nature sounds ambient'
String buildMusicSearchQuery(String? mood, List<String> tags) {
  final moodKeyword = mood != null
      ? (moodMusicKeywordMap[mood] ?? 'ambient instrumental')
      : 'ambient instrumental';

  final tagKeyword = getMusicKeywordForTags(tags);

  // If mood and tag produce the same keyword, just use mood
  if (moodKeyword == tagKeyword) return moodKeyword;

  return '$moodKeyword $tagKeyword';
}
