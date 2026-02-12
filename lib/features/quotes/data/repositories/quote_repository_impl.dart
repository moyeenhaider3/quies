
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';
import '../datasources/quote_local_data_source.dart';

@LazySingleton(as: QuoteRepository)
class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteLocalDataSource localDataSource;

  QuoteRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Quote>>> getQuotes() async {
    try {
      final quotes = await localDataSource.getQuotes();
      return Right(quotes);
    } on CacheException {
        print('QuoteRepositoryImpl: CacheException');
        return Left(CacheFailure());
    } catch (e, stackTrace) {
        print('QuoteRepositoryImpl: Error $e');
        print(stackTrace);
        return Left(CacheFailure());
    }
  }
}
