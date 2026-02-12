
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:quies/features/quotes/data/models/quote_model.dart';

void main() {
  test('Should parse quotes.json correctly', () {
    const jsonString = '''
    [
      {
        "id": "1",
        "text": "The only way to do great work is to love what you do.",
        "author": "Steve Jobs",
        "category": "motivation",
        "tags": [
            "work",
            "passion",
            "success"
        ]
      },
      {
        "id": "2",
        "text": "Believe you can and you're halfway there.",
        "author": "Theodore Roosevelt",
        "category": "inspiration",
        "tags": [
            "belief",
            "confidence"
        ]
      }
    ]
    ''';

    final List<dynamic> jsonList = json.decode(jsonString);
    final quotes = jsonList.map((json) => QuoteModel.fromJson(json)).toList();

    expect(quotes.length, 2);
    expect(quotes.first.author, 'Steve Jobs');
    expect(quotes.first.tags, contains('passion'));
  });
}
