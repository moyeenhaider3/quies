
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/quote_model.dart';

abstract class QuoteLocalDataSource {
  Future<List<QuoteModel>> getQuotes();
}

@LazySingleton(as: QuoteLocalDataSource)
class QuoteLocalDataSourceImpl implements QuoteLocalDataSource {
  @override
  Future<List<QuoteModel>> getQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/quotes.json');
      print('QuoteLocalDataSourceImpl: Loaded JSON string length: ${jsonString.length}');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => QuoteModel.fromJson(json)).toList();
    } catch (e) {
      print('QuoteLocalDataSourceImpl: Error loading quotes: $e');
      throw CacheException();
    }
  }
}
