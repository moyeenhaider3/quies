
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:quies/features/quotes/data/models/quote_model.dart';
import 'dart:io';

void main() {
  test('Should list all quotes from file', () async {
    final file = File('assets/data/quotes.json');
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = json.decode(jsonString);
    final quotes = jsonList.map((json) => QuoteModel.fromJson(json)).toList();

    expect(quotes.isNotEmpty, true);
    expect(quotes.length, 15); // We added 15 quotes
    expect(quotes.any((q) => q.category == 'sleep'), true);
  });
}
