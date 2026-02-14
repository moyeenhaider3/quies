import 'package:equatable/equatable.dart';

import 'author_model.dart';
import 'remote_quote_model.dart';

/// Extended author response from `GET /authors/:id` or `GET /authors/slug/:slug`.
///
/// The API returns author fields at the top level along with an embedded
/// `quotes` array containing the author's quotes.
class AuthorDetailModel extends Equatable {
  final AuthorModel author;
  final List<RemoteQuote> quotes;

  const AuthorDetailModel({required this.author, required this.quotes});

  /// Parses the flat API response into author + embedded quotes.
  ///
  /// Example response:
  /// ```json
  /// {
  ///   "_id": "L76FRuEeGIUJ",
  ///   "name": "Albert Einstein",
  ///   "bio": "...",
  ///   "description": "Theoretical physicist",
  ///   "link": "https://...",
  ///   "quoteCount": 50,
  ///   "slug": "albert-einstein",
  ///   "dateAdded": "2019-07-03",
  ///   "dateModified": "2023-04-06",
  ///   "quotes": [{ "_id": "...", "content": "...", ... }]
  /// }
  /// ```
  factory AuthorDetailModel.fromJson(Map<String, dynamic> json) {
    final quotesJson = json['quotes'] as List<dynamic>? ?? [];
    return AuthorDetailModel(
      author: AuthorModel.fromJson(json),
      quotes: quotesJson
          .cast<Map<String, dynamic>>()
          .map((q) => RemoteQuote.fromJson(q))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [author, quotes];
}
