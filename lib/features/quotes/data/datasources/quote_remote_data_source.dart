import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../models/api_info_model.dart';
import '../models/author_detail_model.dart';
import '../models/author_model.dart';
import '../models/remote_quote_model.dart';
import '../models/tag_model.dart';

/// Paginated response wrapper for quote listings.
class PaginatedQuotes extends Equatable {
  final int page;
  final int totalPages;
  final int totalCount;
  final List<RemoteQuote> results;

  const PaginatedQuotes({
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.results,
  });

  @override
  List<Object?> get props => [page, totalPages, totalCount, results];
}

/// Paginated response wrapper for author listings.
class PaginatedAuthors extends Equatable {
  final int page;
  final int totalPages;
  final int totalCount;
  final List<AuthorModel> results;

  const PaginatedAuthors({
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.results,
  });

  @override
  List<Object?> get props => [page, totalPages, totalCount, results];
}

/// Remote data source for the Quotable API.
///
/// Handles all network calls to `https://api.quotable.io/`.
/// Covers endpoints:
///   - `GET /info/count`
///   - `GET /quotes/random`
///   - `GET /quotes/:id`
///   - `GET /quotes`
///   - `GET /search/quotes`
///   - `GET /tags`
///   - `GET /search/authors`
///   - `GET /authors`
///   - `GET /authors/:id`
///   - `GET /authors/slug/:slug`
@lazySingleton
class QuoteRemoteDataSource {
  static const _baseUrl = 'https://api.quotable.io';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  QuoteRemoteDataSource(this._client);

  // ---------------------------------------------------------------------------
  // Info
  // ---------------------------------------------------------------------------

  /// Fetches aggregate counts of quotes, authors, and tags.
  ///
  /// Uses `GET /info/count`.
  Future<ApiInfoModel> fetchApiInfo() async {
    final url = Uri.parse('$_baseUrl/info/count');

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch API info: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return ApiInfoModel.fromJson(data);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  // ---------------------------------------------------------------------------
  // Quotes
  // ---------------------------------------------------------------------------

  /// Fetches [limit] random quotes, optionally filtered by [tags], [author],
  /// [maxLength], [minLength], and free-text [query].
  ///
  /// Uses `GET /quotes/random?limit={n}&tags={t}&author={a}&maxLength={max}&minLength={min}&query={q}`.
  /// [tags] is pipe-separated (e.g. `"love|life"`).
  /// [author] is the author slug.
  Future<List<RemoteQuote>> fetchRandomQuotes({
    int limit = 10,
    String? tags,
    String? author,
    int? maxLength,
    int? minLength,
    String? query,
  }) async {
    final params = <String, String>{'limit': limit.toString()};
    if (tags != null && tags.isNotEmpty) params['tags'] = tags;
    if (author != null && author.isNotEmpty) params['author'] = author;
    if (maxLength != null) params['maxLength'] = maxLength.toString();
    if (minLength != null) params['minLength'] = minLength.toString();
    if (query != null && query.isNotEmpty) params['query'] = query;

    final url = Uri.parse(
      '$_baseUrl/quotes/random',
    ).replace(queryParameters: params);

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch random quotes: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);

      // API returns an array for batch random quotes
      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map((e) => RemoteQuote.fromJson(e))
            .toList();
      }

      // Single object when limit=1
      if (data is Map<String, dynamic>) {
        return [RemoteQuote.fromJson(data)];
      }

      throw Exception('Unexpected response format');
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  /// Fetches a single quote by [id].
  ///
  /// Uses `GET /quotes/:id`.
  Future<RemoteQuote> fetchQuoteById(String id) async {
    final url = Uri.parse('$_baseUrl/quotes/$id');

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch quote: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return RemoteQuote.fromJson(data);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  /// Fetches paginated quotes with optional filters.
  ///
  /// Uses `GET /quotes?tags={t}&author={a}&page={p}&limit={l}&sortBy={s}&order={o}&maxLength={max}&minLength={min}`.
  Future<PaginatedQuotes> fetchQuotes({
    String? tags,
    String? author,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? order,
    int? maxLength,
    int? minLength,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (tags != null && tags.isNotEmpty) params['tags'] = tags;
    if (author != null && author.isNotEmpty) params['author'] = author;
    if (sortBy != null && sortBy.isNotEmpty) params['sortBy'] = sortBy;
    if (order != null && order.isNotEmpty) params['order'] = order;
    if (maxLength != null) params['maxLength'] = maxLength.toString();
    if (minLength != null) params['minLength'] = minLength.toString();

    final url = Uri.parse('$_baseUrl/quotes').replace(queryParameters: params);

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch quotes: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      final results = (data['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => RemoteQuote.fromJson(e))
          .toList();

      return PaginatedQuotes(
        page: data['page'] as int? ?? page,
        totalPages: data['totalPages'] as int? ?? 1,
        totalCount: data['totalCount'] as int? ?? results.length,
        results: results,
      );
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  /// Searches quotes by free-text [query] with pagination.
  ///
  /// Uses `GET /search/quotes/?query={q}&limit={l}&page={p}`.
  /// The `__info__` metadata field in the response is ignored.
  Future<PaginatedQuotes> searchQuotes({
    required String query,
    int limit = 20,
    int page = 1,
  }) async {
    final params = <String, String>{
      'query': query,
      'limit': limit.toString(),
      'page': page.toString(),
    };

    final url = Uri.parse(
      '$_baseUrl/search/quotes/',
    ).replace(queryParameters: params);

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to search quotes: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      final results = (data['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => RemoteQuote.fromJson(e))
          .toList();

      return PaginatedQuotes(
        page: data['page'] as int? ?? page,
        totalPages: data['totalPages'] as int? ?? 1,
        totalCount: data['totalCount'] as int? ?? results.length,
        results: results,
      );
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  // ---------------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------------

  /// Fetches all available tags.
  ///
  /// Uses `GET /tags?sortBy={sortBy}&sortOrder={sortOrder}`.
  /// Defaults to sorting by quote count descending.
  Future<List<TagModel>> fetchTags({
    String sortBy = 'quoteCount',
    String sortOrder = 'desc',
  }) async {
    final url = Uri.parse('$_baseUrl/tags?sortBy=$sortBy&sortOrder=$sortOrder');

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch tags: ${response.statusCode}');
      }

      final data = json.decode(response.body) as List<dynamic>;
      return data
          .cast<Map<String, dynamic>>()
          .map((e) => TagModel.fromJson(e))
          .toList();
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  // ---------------------------------------------------------------------------
  // Authors
  // ---------------------------------------------------------------------------

  /// Searches authors by [query] with autocomplete support.
  ///
  /// Uses `GET /search/authors?query={q}&autocomplete={a}&limit={l}&page={p}&matchThreshold={m}`.
  Future<List<AuthorModel>> searchAuthors(
    String query, {
    bool autocomplete = true,
    int limit = 10,
    int page = 1,
    int? matchThreshold,
  }) async {
    final params = <String, String>{
      'query': query,
      'autocomplete': autocomplete.toString(),
      'limit': limit.toString(),
      'page': page.toString(),
    };
    if (matchThreshold != null) {
      params['matchThreshold'] = matchThreshold.toString();
    }

    final url = Uri.parse(
      '$_baseUrl/search/authors',
    ).replace(queryParameters: params);

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to search authors: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = (data['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => AuthorModel.fromJson(e))
          .toList();

      return results;
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  /// Fetches paginated authors with optional filters.
  ///
  /// Uses `GET /authors?sortBy={s}&order={o}&slug={slug}&limit={l}&page={p}`.
  Future<PaginatedAuthors> fetchAuthors({
    String? sortBy,
    String? order,
    String? slug,
    int limit = 20,
    int page = 1,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
    };
    if (sortBy != null && sortBy.isNotEmpty) params['sortBy'] = sortBy;
    if (order != null && order.isNotEmpty) params['order'] = order;
    if (slug != null && slug.isNotEmpty) params['slug'] = slug;

    final url = Uri.parse('$_baseUrl/authors').replace(queryParameters: params);

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch authors: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      final results = (data['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => AuthorModel.fromJson(e))
          .toList();

      return PaginatedAuthors(
        page: data['page'] as int? ?? page,
        totalPages: data['totalPages'] as int? ?? 1,
        totalCount: data['totalCount'] as int? ?? results.length,
        results: results,
      );
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  /// Fetches an author by [id] with their quotes.
  ///
  /// Uses `GET /authors/:id`.
  Future<AuthorDetailModel> fetchAuthorById(String id) async {
    final url = Uri.parse('$_baseUrl/authors/$id');

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch author: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return AuthorDetailModel.fromJson(data);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  /// Fetches an author by [slug] with their quotes.
  ///
  /// Uses `GET /authors/slug/:slug`.
  Future<AuthorDetailModel> fetchAuthorBySlug(String slug) async {
    final url = Uri.parse('$_baseUrl/authors/slug/$slug');

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch author: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return AuthorDetailModel.fromJson(data);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }
}
