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
/// Uses terms that return songs with vocals and lyrics (not instrumentals).
const Map<String, String> genreMusicMap = {
  'inspirational': 'motivational pop songs',
  'love': 'love songs acoustic',
  'peace': 'calm indie folk',
  'sad': 'sad songs ballad',
  'success': 'empowerment anthem songs',
};

/// Fallback keywords when primary music search returns no preview.
const Map<String, String> fallbackMusicMap = {
  'inspirational': 'uplifting pop hits',
  'love': 'romantic ballad songs',
  'peace': 'peaceful acoustic singer',
  'sad': 'heartbreak songs',
  'success': 'victory celebration songs',
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
/// All keywords target songs with vocals/lyrics, not instrumentals.
const Map<String, String> tagMusicKeywordMap = {
  'inspirational': 'motivational pop songs',
  'motivational': 'motivational workout songs',
  'love': 'love songs ballad',
  'happiness': 'happy pop songs',
  'life': 'life lessons songs',
  'wisdom': 'soulful acoustic songs',
  'success': 'empowerment anthem songs',
  'friendship': 'feel good friendship songs',
  'knowledge': 'thoughtful indie songs',
  'humor': 'fun pop songs',
  'philosophy': 'deep lyrical songs',
  'science': 'alternative rock songs',
  'technology': 'synthpop songs',
  'faith': 'gospel praise songs',
  'hope': 'hopeful pop songs',
  'courage': 'brave anthem songs',
  'change': 'change the world songs',
  'character': 'singer songwriter',
  'competition': 'pump up rock songs',
  'education': 'acoustic study songs',
  'famous-quotes': 'classic pop hits',
  'film': 'movie soundtrack songs',
  'freedom': 'freedom anthem songs',
  'future': 'dream pop songs',
  'history': 'classic rock songs',
  'nature': 'folk nature songs',
  'power-quotes': 'powerful vocal songs',
  'religion': 'worship songs',
  'sports': 'sports anthem songs',
  'tolerance': 'unity songs',
  'virtue': 'gentle acoustic ballad',
  'work': 'focus chill songs',
};

/// Default music keyword when no tag matches.
const String defaultMusicKeyword = 'popular songs';

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
/// All moods now target songs with lyrics/vocals.
const Map<String, String> moodMusicKeywordMap = {
  'Calm': 'calm acoustic songs',
  'Energized': 'upbeat pop hits',
  'Reflective': 'acoustic indie folk',
  'Anxious': 'soothing acoustic songs',
  'Grateful': 'feel good happy songs',
  'Hopeful': 'uplifting pop songs',
  'Stressed': 'relaxing acoustic songs',
  'Tired': 'gentle folk songs',
  'Sad': 'sad ballad songs',
  'Okay': 'chill lofi songs',
};

/// Moods that should get softer, calmer vocal songs.
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
/// Example: mood='Calm', tags=['nature'] → 'calm acoustic songs folk nature songs'
String buildMusicSearchQuery(String? mood, List<String> tags) {
  final moodKeyword = mood != null
      ? (moodMusicKeywordMap[mood] ?? 'popular songs')
      : 'popular songs';

  final tagKeyword = getMusicKeywordForTags(tags);

  // If mood and tag produce the same keyword, just use mood
  if (moodKeyword == tagKeyword) return moodKeyword;

  return '$moodKeyword $tagKeyword';
}
