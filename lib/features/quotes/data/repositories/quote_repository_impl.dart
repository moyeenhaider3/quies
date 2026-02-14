import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';
import '../datasources/quote_local_data_source.dart';
import '../datasources/quote_remote_data_source.dart';
import '../models/api_info_model.dart';
import '../models/author_detail_model.dart';
import '../models/author_model.dart';
import '../models/tag_model.dart';

@LazySingleton(as: QuoteRepository)
class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteLocalDataSource localDataSource;
  final QuoteRemoteDataSource remoteDataSource;

  QuoteRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<Either<Failure, List<Quote>>> getQuotes() async {
    try {
      final quotes = await localDataSource.getQuotes();
      return Right(quotes);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Quote>>> getRemoteQuotes({int limit = 10}) async {
    try {
      final remoteQuotes = await remoteDataSource.fetchRandomQuotes(
        limit: limit,
      );
      final quotes = remoteQuotes.map((rq) => rq.toQuote()).toList();
      return Right(quotes);
    } catch (e) {
      // Fallback to local quotes on any remote failure
      return getQuotes();
    }
  }

  @override
  Future<Either<Failure, PaginatedQuotes>> getFilteredQuotes({
    String? tags,
    String? authorSlug,
    int page = 1,
    int limit = 20,
    int? maxLength,
    int? minLength,
  }) async {
    try {
      final result = await remoteDataSource.fetchQuotes(
        tags: tags,
        author: authorSlug,
        page: page,
        limit: limit,
        maxLength: maxLength,
        minLength: minLength,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<TagModel>>> getTags() async {
    try {
      final tags = await remoteDataSource.fetchTags();
      return Right(tags);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AuthorModel>>> searchAuthors(String query) async {
    try {
      final authors = await remoteDataSource.searchAuthors(query);
      return Right(authors);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaginatedQuotes>> searchQuotes({
    required String query,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final result = await remoteDataSource.searchQuotes(
        query: query,
        limit: limit,
        page: page,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Quote>> getQuoteById(String id) async {
    try {
      final remoteQuote = await remoteDataSource.fetchQuoteById(id);
      return Right(remoteQuote.toQuote());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AuthorDetailModel>> getAuthorBySlug(
    String slug,
  ) async {
    try {
      final detail = await remoteDataSource.fetchAuthorBySlug(slug);
      return Right(detail);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AuthorDetailModel>> getAuthorById(String id) async {
    try {
      final detail = await remoteDataSource.fetchAuthorById(id);
      return Right(detail);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaginatedAuthors>> getAuthors({
    String? sortBy,
    String? order,
    String? slug,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final result = await remoteDataSource.fetchAuthors(
        sortBy: sortBy,
        order: order,
        slug: slug,
        limit: limit,
        page: page,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ApiInfoModel>> getApiInfo() async {
    try {
      final info = await remoteDataSource.fetchApiInfo();
      return Right(info);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
