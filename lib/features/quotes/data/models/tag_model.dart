import 'package:equatable/equatable.dart';

/// Represents a tag from the Quotable API.
class TagModel extends Equatable {
  final String id;
  final String name;
  final String slug;
  final int quoteCount;
  final String? dateAdded;
  final String? dateModified;

  const TagModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.quoteCount,
    this.dateAdded,
    this.dateModified,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      quoteCount: json['quoteCount'] ?? 0,
      dateAdded: json['dateAdded'] as String?,
      dateModified: json['dateModified'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    quoteCount,
    dateAdded,
    dateModified,
  ];
}
