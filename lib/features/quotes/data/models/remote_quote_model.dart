import 'package:equatable/equatable.dart';

import '../../../quotes/domain/entities/quote.dart';

/// Heuristic energy/valence values based on quote tags.
const Map<String, Map<String, int>> _tagEnergyValence = {
  'inspirational': {'energy': 4, 'valence': 4},
  'motivational': {'energy': 5, 'valence': 5},
  'love': {'energy': 3, 'valence': 5},
  'happiness': {'energy': 4, 'valence': 5},
  'life': {'energy': 3, 'valence': 3},
  'wisdom': {'energy': 2, 'valence': 4},
  'success': {'energy': 5, 'valence': 5},
  'friendship': {'energy': 3, 'valence': 4},
  'knowledge': {'energy': 2, 'valence': 3},
  'humor': {'energy': 4, 'valence': 5},
  'philosophy': {'energy': 2, 'valence': 3},
  'science': {'energy': 3, 'valence': 3},
  'technology': {'energy': 3, 'valence': 3},
  'faith': {'energy': 2, 'valence': 4},
  'hope': {'energy': 3, 'valence': 5},
  'courage': {'energy': 5, 'valence': 4},
  'change': {'energy': 3, 'valence': 3},
  'character': {'energy': 3, 'valence': 4},
  'competition': {'energy': 5, 'valence': 3},
  'education': {'energy': 2, 'valence': 3},
  'famous-quotes': {'energy': 3, 'valence': 3},
  'film': {'energy': 3, 'valence': 3},
  'freedom': {'energy': 4, 'valence': 5},
  'future': {'energy': 3, 'valence': 4},
  'history': {'energy': 2, 'valence': 3},
  'nature': {'energy': 2, 'valence': 4},
  'power-quotes': {'energy': 5, 'valence': 4},
  'religion': {'energy': 2, 'valence': 3},
  'sports': {'energy': 5, 'valence': 4},
  'tolerance': {'energy': 2, 'valence': 4},
  'virtue': {'energy': 2, 'valence': 4},
  'work': {'energy': 4, 'valence': 3},
};

/// Represents a quote fetched from the Quotable API.
class RemoteQuote extends Equatable {
  final String id;
  final String content;
  final String author;
  final String authorSlug;
  final List<String> tags;
  final int? length;
  final String? authorId;
  final String? dateAdded;
  final String? dateModified;

  const RemoteQuote({
    required this.id,
    required this.content,
    required this.author,
    required this.authorSlug,
    required this.tags,
    this.length,
    this.authorId,
    this.dateAdded,
    this.dateModified,
  });

  factory RemoteQuote.fromJson(Map<String, dynamic> json) {
    return RemoteQuote(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? 'Unknown',
      authorSlug: json['authorSlug'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      length: json['length'] as int?,
      authorId: json['authorId'] as String?,
      dateAdded: json['dateAdded'] as String?,
      dateModified: json['dateModified'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'content': content,
      'author': author,
      'authorSlug': authorSlug,
      'tags': tags,
      if (length != null) 'length': length,
      if (authorId != null) 'authorId': authorId,
      if (dateAdded != null) 'dateAdded': dateAdded,
      if (dateModified != null) 'dateModified': dateModified,
    };
  }

  /// Converts this API model to the domain [Quote] entity.
  Quote toQuote() {
    final category = tags.isNotEmpty ? tags.first : 'general';

    // Derive energy/valence from first matching tag heuristic
    int energy = 3;
    int valence = 3;
    for (final tag in tags) {
      final ev = _tagEnergyValence[tag];
      if (ev != null) {
        energy = ev['energy']!;
        valence = ev['valence']!;
        break;
      }
    }

    return Quote(
      id: id,
      text: content,
      author: author,
      category: category,
      tags: tags,
      energy: energy,
      valence: valence,
      timeOfDay: const ['anytime'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    author,
    authorSlug,
    tags,
    length,
    authorId,
    dateAdded,
    dateModified,
  ];
}
