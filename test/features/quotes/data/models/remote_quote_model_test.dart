import 'package:flutter_test/flutter_test.dart';
import 'package:quies/features/quotes/data/models/remote_quote_model.dart';

void main() {
  group('RemoteQuote', () {
    // Uses actual API response from curl #10: GET /quotes/:id
    test('fromJson parses full API response with all fields', () {
      final json = {
        '_id': 'bfNpGC2NI',
        'author': 'Thomas Edison',
        'content': 'As a cure for worrying, work is better than whisky.',
        'tags': ['Humorous'],
        'authorSlug': 'thomas-edison',
        'length': 51,
        'dateAdded': '2023-04-14',
        'dateModified': '2023-04-14',
      };

      final quote = RemoteQuote.fromJson(json);

      expect(quote.id, 'bfNpGC2NI');
      expect(
        quote.content,
        'As a cure for worrying, work is better than whisky.',
      );
      expect(quote.author, 'Thomas Edison');
      expect(quote.authorSlug, 'thomas-edison');
      expect(quote.tags, ['Humorous']);
      expect(quote.length, 51);
      expect(quote.dateAdded, '2023-04-14');
      expect(quote.dateModified, '2023-04-14');
    });

    // Uses actual API response from curl #9: GET /quotes/random
    test('fromJson parses random quote response with authorId', () {
      final json = {
        '_id': '3ng6IDEjZW4v',
        'content':
            'Edison failed 10,000 times before he made the electric light. Do not be discouraged if you fail a few times.',
        'author': 'Napoleon Hill',
        'tags': ['Famous Quotes'],
        'authorSlug': 'napoleon-hill',
        'length': 108,
        'dateAdded': '2020-06-24',
        'dateModified': '2023-04-14',
      };

      final quote = RemoteQuote.fromJson(json);

      expect(quote.id, '3ng6IDEjZW4v');
      expect(quote.author, 'Napoleon Hill');
      expect(quote.length, 108);
      expect(quote.dateAdded, '2020-06-24');
    });

    // Uses actual API response from curl #3: search/quotes result item
    test('fromJson parses search result quote with authorId', () {
      final json = {
        '_id': 'zJCNH3Q5shhD',
        'content':
            'Friends show their love in times of trouble, not in happiness.',
        'author': 'Euripides',
        'tags': ['Famous Quotes', 'Friendship'],
        'authorId': 'yVMYpy-GWFq',
        'authorSlug': 'euripides',
        'length': 62,
        'dateAdded': '2021-03-26',
        'dateModified': '2023-04-14',
      };

      final quote = RemoteQuote.fromJson(json);

      expect(quote.id, 'zJCNH3Q5shhD');
      expect(quote.author, 'Euripides');
      expect(quote.authorId, 'yVMYpy-GWFq');
      expect(quote.tags, ['Famous Quotes', 'Friendship']);
      expect(quote.length, 62);
    });

    test('fromJson handles null fields with defaults', () {
      final json = <String, dynamic>{
        '_id': null,
        'content': null,
        'author': null,
        'authorSlug': null,
        'tags': null,
        'length': null,
        'dateAdded': null,
      };

      final quote = RemoteQuote.fromJson(json);

      expect(quote.id, '');
      expect(quote.content, '');
      expect(quote.author, 'Unknown');
      expect(quote.authorSlug, '');
      expect(quote.tags, isEmpty);
      expect(quote.length, isNull);
      expect(quote.dateAdded, isNull);
    });

    test('fromJson handles missing optional fields gracefully', () {
      final json = {
        '_id': 'minimal',
        'content': 'Hello',
        'author': 'World',
        'authorSlug': 'world',
        'tags': ['test'],
      };

      final quote = RemoteQuote.fromJson(json);

      expect(quote.length, isNull);
      expect(quote.authorId, isNull);
      expect(quote.dateAdded, isNull);
      expect(quote.dateModified, isNull);
    });

    test('toJson produces correct output with all fields', () {
      const quote = RemoteQuote(
        id: 'bfNpGC2NI',
        content: 'As a cure for worrying, work is better than whisky.',
        author: 'Thomas Edison',
        authorSlug: 'thomas-edison',
        tags: ['Humorous'],
        length: 51,
        dateAdded: '2023-04-14',
        dateModified: '2023-04-14',
      );

      final json = quote.toJson();

      expect(json['_id'], 'bfNpGC2NI');
      expect(
        json['content'],
        'As a cure for worrying, work is better than whisky.',
      );
      expect(json['author'], 'Thomas Edison');
      expect(json['authorSlug'], 'thomas-edison');
      expect(json['tags'], ['Humorous']);
      expect(json['length'], 51);
      expect(json['dateAdded'], '2023-04-14');
      expect(json['dateModified'], '2023-04-14');
    });

    test('toJson omits null optional fields', () {
      const quote = RemoteQuote(
        id: 'test',
        content: 'Test',
        author: 'Author',
        authorSlug: 'author',
        tags: [],
      );

      final json = quote.toJson();

      expect(json.containsKey('length'), false);
      expect(json.containsKey('authorId'), false);
      expect(json.containsKey('dateAdded'), false);
      expect(json.containsKey('dateModified'), false);
    });

    test('fromJson/toJson round-trip preserves data', () {
      const original = RemoteQuote(
        id: '3-iBAZN0jrh',
        content:
            'A monarchy conducted with infinite wisdom and infinite benevolence is the most perfect of all possible governments.',
        author: 'Ezra Stiles',
        authorSlug: 'ezra-stiles',
        tags: ['Wisdom'],
        length: 115,
        dateAdded: '2019-10-12',
        dateModified: '2023-04-14',
      );

      final json = original.toJson();
      final restored = RemoteQuote.fromJson(json);

      expect(restored, original);
    });

    test('equality works correctly', () {
      const a = RemoteQuote(
        id: '1',
        content: 'Hello',
        author: 'World',
        authorSlug: 'world',
        tags: ['test'],
        length: 5,
      );

      const b = RemoteQuote(
        id: '1',
        content: 'Hello',
        author: 'World',
        authorSlug: 'world',
        tags: ['test'],
        length: 5,
      );

      const c = RemoteQuote(
        id: '2',
        content: 'Hello',
        author: 'World',
        authorSlug: 'world',
        tags: ['test'],
        length: 5,
      );

      expect(a, b);
      expect(a, isNot(c));
    });

    test('toQuote converts to domain Quote correctly', () {
      const remote = RemoteQuote(
        id: 'q1',
        content: 'Stay hungry, stay foolish.',
        author: 'Steve Jobs',
        authorSlug: 'steve-jobs',
        tags: ['inspirational', 'motivational'],
        length: 26,
        dateAdded: '2020-01-01',
      );

      final quote = remote.toQuote();

      expect(quote.id, 'q1');
      expect(quote.text, 'Stay hungry, stay foolish.');
      expect(quote.author, 'Steve Jobs');
      expect(quote.category, 'inspirational');
      expect(quote.tags, ['inspirational', 'motivational']);
      expect(quote.energy, 4); // inspirational heuristic
      expect(quote.valence, 4);
      expect(quote.timeOfDay, ['anytime']);
    });

    test('toQuote uses defaults when tags are empty', () {
      const remote = RemoteQuote(
        id: 'q2',
        content: 'No tags here.',
        author: 'Anonymous',
        authorSlug: 'anonymous',
        tags: [],
      );

      final quote = remote.toQuote();

      expect(quote.category, 'general');
      expect(quote.energy, 3);
      expect(quote.valence, 3);
    });
  });
}
