import '../../domain/entities/quote.dart';

class QuoteModel extends Quote {
  const QuoteModel({
    required super.id,
    required super.text,
    required super.author,
    super.authorSlug,
    required super.category,
    required super.tags,
    super.energy,
    super.valence,
    super.timeOfDay,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'],
      text: json['text'],
      author: json['author'],
      category: json['category'],
      tags: List<String>.from(json['tags']),
      energy: json['energy'] ?? 3,
      valence: json['valence'] ?? 3,
      timeOfDay: json['timeOfDay'] != null
          ? List<String>.from(json['timeOfDay'])
          : const ['anytime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'tags': tags,
      'energy': energy,
      'valence': valence,
      'timeOfDay': timeOfDay,
    };
  }
}
