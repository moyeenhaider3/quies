import 'package:equatable/equatable.dart';

/// Represents an author from the Quotable API.
class AuthorModel extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String bio;
  final String description;
  final int quoteCount;
  final String? link;
  final String? dateAdded;
  final String? dateModified;

  const AuthorModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.bio,
    required this.description,
    required this.quoteCount,
    this.link,
    this.dateAdded,
    this.dateModified,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      bio: json['bio'] ?? '',
      description: json['description'] ?? '',
      quoteCount: json['quoteCount'] ?? 0,
      link: json['link'] as String?,
      dateAdded: json['dateAdded'] as String?,
      dateModified: json['dateModified'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    bio,
    description,
    quoteCount,
    link,
    dateAdded,
    dateModified,
  ];
}
