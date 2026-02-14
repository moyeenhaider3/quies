import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/datasources/quote_remote_data_source.dart';
import '../../data/models/api_info_model.dart';
import '../../data/models/author_detail_model.dart';
import '../../data/models/author_model.dart';
import '../../data/models/tag_model.dart';
import '../entities/quote.dart';

abstract class QuoteRepository {
  /// Loads quotes from local JSON asset (offline fallback).
  Future<Either<Failure, List<Quote>>> getQuotes();

  /// Fetches random quotes from the API.
  Future<Either<Failure, List<Quote>>> getRemoteQuotes({int limit = 10});

  /// Fetches paginated quotes with optional tag/author filters.
  Future<Either<Failure, PaginatedQuotes>> getFilteredQuotes({
    String? tags,
    String? authorSlug,
    int page = 1,
    int limit = 20,
    int? maxLength,
    int? minLength,
  });

  /// Fetches all available tags from the API.
  Future<Either<Failure, List<TagModel>>> getTags();

  /// Searches authors by query string.
  Future<Either<Failure, List<AuthorModel>>> searchAuthors(String query);

  /// Searches quotes by free-text query with pagination.
  Future<Either<Failure, PaginatedQuotes>> searchQuotes({
    required String query,
    int limit = 20,
    int page = 1,
  });

  /// Fetches a single quote by its ID.
  Future<Either<Failure, Quote>> getQuoteById(String id);

  /// Fetches an author with their quotes by slug.
  Future<Either<Failure, AuthorDetailModel>> getAuthorBySlug(String slug);

  /// Fetches an author with their quotes by ID.
  Future<Either<Failure, AuthorDetailModel>> getAuthorById(String id);

  /// Fetches paginated list of authors.
  Future<Either<Failure, PaginatedAuthors>> getAuthors({
    String? sortBy,
    String? order,
    String? slug,
    int limit = 20,
    int page = 1,
  });

  /// Fetches aggregate API info (counts).
  Future<Either<Failure, ApiInfoModel>> getApiInfo();
}
