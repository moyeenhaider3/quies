
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quote.dart';

abstract class QuoteRepository {
  Future<Either<Failure, List<Quote>>> getQuotes();
}
