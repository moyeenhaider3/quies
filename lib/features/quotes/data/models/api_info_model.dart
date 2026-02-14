import 'package:equatable/equatable.dart';

/// Represents the API info/count response from `GET /info/count`.
///
/// Contains aggregate counts of quotes, authors, and tags available.
class ApiInfoModel extends Equatable {
  final int quotes;
  final int authors;
  final int tags;

  const ApiInfoModel({
    required this.quotes,
    required this.authors,
    required this.tags,
  });

  factory ApiInfoModel.fromJson(Map<String, dynamic> json) {
    return ApiInfoModel(
      quotes: json['quotes'] as int? ?? 0,
      authors: json['authors'] as int? ?? 0,
      tags: json['tags'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [quotes, authors, tags];
}
