import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:quies/features/quotes/data/datasources/quote_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late QuoteRemoteDataSource dataSource;

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = QuoteRemoteDataSource(mockClient);
  });

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api.quotable.io'));
  });

  // ---------------------------------------------------------------------------
  // fetchApiInfo  –  GET /info/count  (curl #1)
  // ---------------------------------------------------------------------------
  group('fetchApiInfo', () {
    test('returns ApiInfoModel with real API payload', () async {
      // Actual response from curl #1
      final responseBody = json.encode({
        'quotes': 2127,
        'authors': 803,
        'tags': 67,
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final info = await dataSource.fetchApiInfo();

      expect(info.quotes, 2127);
      expect(info.authors, 803);
      expect(info.tags, 67);

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.path, '/info/count');
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Error', 500));

      expect(() => dataSource.fetchApiInfo(), throwsA(isA<Exception>()));
    });
  });

  // ---------------------------------------------------------------------------
  // fetchRandomQuotes  –  GET /quotes/random  (curl #3, #9)
  // ---------------------------------------------------------------------------
  group('fetchRandomQuotes', () {
    // Curl #3: GET /quotes/random?limit=3&tags=love
    test('returns list of RemoteQuote from real API payload', () async {
      final responseBody = json.encode([
        {
          '_id': 'WL-3GSsLFw',
          'content':
              'Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.',
          'author': 'Lao Tzu',
          'authorSlug': 'lao-tzu',
          'length': 95,
          'tags': ['Love'],
        },
        {
          '_id': 'GTHO2DGxLa',
          'content': 'Love is composed of a single soul inhabiting two bodies.',
          'author': 'Aristotle',
          'authorSlug': 'aristotle',
          'length': 56,
          'tags': ['Love'],
        },
        {
          '_id': 'kV5FOmIF8V',
          'content':
              'We love life, not because we are used to living but because we are used to loving.',
          'author': 'Friedrich Nietzsche',
          'authorSlug': 'friedrich-nietzsche',
          'length': 82,
          'tags': ['Love', 'Life'],
        },
      ]);

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final quotes = await dataSource.fetchRandomQuotes(limit: 3, tags: 'love');

      expect(quotes.length, 3);
      expect(quotes[0].id, 'WL-3GSsLFw');
      expect(quotes[0].author, 'Lao Tzu');
      expect(quotes[0].length, 95);
      expect(quotes[1].id, 'GTHO2DGxLa');
      expect(quotes[2].tags, ['Love', 'Life']);
    });

    // Curl #9: GET /quotes/random?limit=1
    test('returns single quote from array when limit=1', () async {
      final responseBody = json.encode([
        {
          '_id': 'BRC6vxE3Im',
          'content': 'Only a life lived for others is a life worthwhile.',
          'author': 'Albert Einstein',
          'authorSlug': 'albert-einstein',
          'length': 51,
          'tags': ['Famous Quotes'],
        },
      ]);

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final quotes = await dataSource.fetchRandomQuotes(limit: 1);

      expect(quotes.length, 1);
      expect(quotes[0].id, 'BRC6vxE3Im');
      expect(
        quotes[0].content,
        'Only a life lived for others is a life worthwhile.',
      );
    });

    test('handles single object response (fallback)', () async {
      final responseBody = json.encode({
        '_id': 'BRC6vxE3Im',
        'content': 'Only a life lived for others is a life worthwhile.',
        'author': 'Albert Einstein',
        'authorSlug': 'albert-einstein',
        'length': 51,
        'tags': ['Famous Quotes'],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final quotes = await dataSource.fetchRandomQuotes(limit: 1);

      expect(quotes.length, 1);
      expect(
        quotes[0].content,
        'Only a life lived for others is a life worthwhile.',
      );
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Server error', 500));

      expect(() => dataSource.fetchRandomQuotes(), throwsA(isA<Exception>()));
    });

    test('includes all query params in URL', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('[]', 200));

      await dataSource.fetchRandomQuotes(
        limit: 5,
        tags: 'love|life',
        author: 'einstein',
        maxLength: 100,
        minLength: 10,
        query: 'success',
      );

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.queryParameters['limit'], '5');
      expect(uri.queryParameters['tags'], 'love|life');
      expect(uri.queryParameters['author'], 'einstein');
      expect(uri.queryParameters['maxLength'], '100');
      expect(uri.queryParameters['minLength'], '10');
      expect(uri.queryParameters['query'], 'success');
    });
  });

  // ---------------------------------------------------------------------------
  // fetchQuoteById  –  GET /quotes/:id  (curl #11)
  // ---------------------------------------------------------------------------
  group('fetchQuoteById', () {
    // Curl #11: GET /quotes/2xpHvSOQMi
    test('returns RemoteQuote from real API payload', () async {
      final responseBody = json.encode({
        '_id': '2xpHvSOQMi',
        'content':
            'Try not to become a man of success, but rather try to become a man of value.',
        'author': 'Albert Einstein',
        'authorSlug': 'albert-einstein',
        'length': 76,
        'tags': ['Famous Quotes'],
        'dateAdded': '2019-07-03',
        'dateModified': '2023-04-14',
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final quote = await dataSource.fetchQuoteById('2xpHvSOQMi');

      expect(quote.id, '2xpHvSOQMi');
      expect(
        quote.content,
        'Try not to become a man of success, but rather try to become a man of value.',
      );
      expect(quote.author, 'Albert Einstein');
      expect(quote.authorSlug, 'albert-einstein');
      expect(quote.length, 76);
      expect(quote.dateAdded, '2019-07-03');

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.path, '/quotes/2xpHvSOQMi');
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Not found', 404));

      expect(
        () => dataSource.fetchQuoteById('invalid'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // fetchQuotes  –  GET /quotes  (curl #8)
  // ---------------------------------------------------------------------------
  group('fetchQuotes', () {
    // Curl #8: GET /quotes?tags=love&limit=3&page=1
    test('returns PaginatedQuotes from real API payload', () async {
      final responseBody = json.encode({
        'count': 3,
        'totalCount': 17,
        'page': 1,
        'totalPages': 6,
        'lastItemIndex': 3,
        'results': [
          {
            '_id': 'WL-3GSsLFw',
            'content':
                'Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.',
            'author': 'Lao Tzu',
            'authorSlug': 'lao-tzu',
            'length': 95,
            'tags': ['Love'],
            'dateAdded': '2020-03-18',
            'dateModified': '2023-04-14',
          },
          {
            '_id': 'GTHO2DGxLa',
            'content':
                'Love is composed of a single soul inhabiting two bodies.',
            'author': 'Aristotle',
            'authorSlug': 'aristotle',
            'length': 56,
            'tags': ['Love'],
            'dateAdded': '2020-03-18',
            'dateModified': '2023-04-14',
          },
          {
            '_id': 'kV5FOmIF8V',
            'content':
                'We love life, not because we are used to living but because we are used to loving.',
            'author': 'Friedrich Nietzsche',
            'authorSlug': 'friedrich-nietzsche',
            'length': 82,
            'tags': ['Love', 'Life'],
            'dateAdded': '2020-05-21',
            'dateModified': '2023-04-14',
          },
        ],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await dataSource.fetchQuotes(
        tags: 'love',
        limit: 3,
        page: 1,
      );

      expect(result.page, 1);
      expect(result.totalPages, 6);
      expect(result.totalCount, 17);
      expect(result.results.length, 3);
      expect(result.results[0].id, 'WL-3GSsLFw');
      expect(result.results[0].length, 95);
      expect(result.results[2].tags, ['Love', 'Life']);
    });

    test('includes maxLength, minLength, and order in query params', () async {
      final responseBody = json.encode({
        'page': 1,
        'totalPages': 1,
        'totalCount': 0,
        'results': <dynamic>[],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      await dataSource.fetchQuotes(
        tags: 'wisdom',
        order: 'asc',
        maxLength: 50,
        minLength: 10,
      );

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.queryParameters['tags'], 'wisdom');
      expect(uri.queryParameters['order'], 'asc');
      expect(uri.queryParameters['maxLength'], '50');
      expect(uri.queryParameters['minLength'], '10');
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Not found', 404));

      expect(() => dataSource.fetchQuotes(), throwsA(isA<Exception>()));
    });
  });

  // ---------------------------------------------------------------------------
  // searchQuotes  –  GET /search/quotes  (curl #10)
  // ---------------------------------------------------------------------------
  group('searchQuotes', () {
    // Curl #10: GET /search/quotes?query=love&limit=2
    test('returns PaginatedQuotes from real search API payload', () async {
      final responseBody = json.encode({
        'count': 2,
        'totalCount': 31,
        'page': 1,
        'totalPages': 16,
        'results': [
          {
            '_id': 'uskMQk0-cqaF',
            'content': 'Be the love you never received.',
            'author': 'Rune Lazuli',
            'authorSlug': 'rune-lazuli',
            'authorId': 'A1bFeO7m1G',
            'length': 31,
            'tags': ['Famous Quotes', 'Love'],
            'dateAdded': '2022-07-06',
            'dateModified': '2023-04-14',
          },
          {
            '_id': 'P2sDmmCHKp',
            'content': 'Where there is love there is life.',
            'author': 'Mahatma Gandhi',
            'authorSlug': 'mahatma-gandhi',
            'authorId': 'B3tEdRe9HJ',
            'length': 34,
            'tags': ['Famous Quotes', 'Love'],
            'dateAdded': '2019-08-12',
            'dateModified': '2023-04-14',
          },
        ],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await dataSource.searchQuotes(query: 'love', limit: 2);

      expect(result.page, 1);
      expect(result.totalPages, 16);
      expect(result.totalCount, 31);
      expect(result.results.length, 2);
      expect(result.results[0].id, 'uskMQk0-cqaF');
      expect(result.results[0].authorId, 'A1bFeO7m1G');
      expect(result.results[1].content, 'Where there is love there is life.');

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.path, '/search/quotes/');
      expect(uri.queryParameters['query'], 'love');
      expect(uri.queryParameters['limit'], '2');
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () => dataSource.searchQuotes(query: 'test'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // fetchTags  –  GET /tags  (curl #4)
  // ---------------------------------------------------------------------------
  group('fetchTags', () {
    // Curl #4: GET /tags (partial – first 2 tags)
    test('returns list of TagModel from real API payload', () async {
      final responseBody = json.encode([
        {
          '_id': 'fvpORe-t',
          'name': 'Famous Quotes',
          'slug': 'famous-quotes',
          'quoteCount': 1090,
          'dateAdded': '2019-07-23',
          'dateModified': '2023-04-14',
        },
        {
          '_id': '6J1qxxuj3',
          'name': 'Wisdom',
          'slug': 'wisdom',
          'quoteCount': 550,
          'dateAdded': '2019-10-18',
          'dateModified': '2023-04-14',
        },
      ]);

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final tags = await dataSource.fetchTags();

      expect(tags.length, 2);
      expect(tags[0].id, 'fvpORe-t');
      expect(tags[0].name, 'Famous Quotes');
      expect(tags[0].quoteCount, 1090);
      expect(tags[0].dateAdded, '2019-07-23');
      expect(tags[1].name, 'Wisdom');
      expect(tags[1].quoteCount, 550);
    });

    test('passes sortBy and sortOrder query params', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('[]', 200));

      await dataSource.fetchTags(sortBy: 'name', sortOrder: 'asc');

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.queryParameters['sortBy'], 'name');
      expect(uri.queryParameters['sortOrder'], 'asc');
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Error', 500));

      expect(() => dataSource.fetchTags(), throwsA(isA<Exception>()));
    });
  });

  // ---------------------------------------------------------------------------
  // searchAuthors  –  GET /search/authors  (curl #2, #5)
  // ---------------------------------------------------------------------------
  group('searchAuthors', () {
    // Curl #2: GET /search/authors?query=Jon%20Kabat-Zinn
    test('returns authors from real API search payload', () async {
      final responseBody = json.encode({
        'count': 1,
        'totalCount': 1,
        'page': 1,
        'totalPages': 1,
        'results': [
          {
            '_id': 'gNqnmMb9jE3H',
            'name': 'Jon Kabat-Zinn',
            'bio':
                'Jon Kabat-Zinn is an American professor emeritus of medicine.',
            'description': 'American professor emeritus of medicine',
            'link': 'https://en.wikipedia.org/wiki/Jon_Kabat-Zinn',
            'quoteCount': 20,
            'slug': 'jon-kabat-zinn',
            'dateAdded': '2020-09-06',
            'dateModified': '2023-04-06',
          },
        ],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final authors = await dataSource.searchAuthors('Jon Kabat-Zinn');

      expect(authors.length, 1);
      expect(authors[0].name, 'Jon Kabat-Zinn');
      expect(authors[0].slug, 'jon-kabat-zinn');
      expect(authors[0].link, 'https://en.wikipedia.org/wiki/Jon_Kabat-Zinn');
      expect(authors[0].quoteCount, 20);
    });

    // Curl #5: GET /search/authors?query=dalai%20lama&autocomplete=true&limit=5&matchThreshold=2
    test('passes autocomplete and matchThreshold params', () async {
      final responseBody = json.encode({
        'count': 1,
        'totalCount': 1,
        'page': 1,
        'totalPages': 1,
        'results': [
          {
            '_id': '97UkJOAghGQ0',
            'name': '14th Dalai Lama',
            'bio': 'The 14th Dalai Lama is the current Dalai Lama.',
            'description': 'Tibetan Buddhist monk',
            'link': 'https://en.wikipedia.org/wiki/14th_Dalai_Lama',
            'quoteCount': 58,
            'slug': '14th-dalai-lama',
            'dateAdded': '2019-12-11',
            'dateModified': '2023-04-06',
          },
        ],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final authors = await dataSource.searchAuthors(
        'dalai lama',
        autocomplete: true,
        limit: 5,
        matchThreshold: 2,
      );

      expect(authors.length, 1);
      expect(authors[0].name, '14th Dalai Lama');
      expect(authors[0].quoteCount, 58);

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.queryParameters['query'], 'dalai lama');
      expect(uri.queryParameters['autocomplete'], 'true');
      expect(uri.queryParameters['limit'], '5');
      expect(uri.queryParameters['matchThreshold'], '2');
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Error', 500));

      expect(() => dataSource.searchAuthors('test'), throwsA(isA<Exception>()));
    });
  });

  // ---------------------------------------------------------------------------
  // fetchAuthors  –  GET /authors
  // ---------------------------------------------------------------------------
  group('fetchAuthors', () {
    test('returns PaginatedAuthors on 200 response', () async {
      final responseBody = json.encode({
        'count': 1,
        'totalCount': 803,
        'page': 1,
        'totalPages': 41,
        'results': [
          {
            '_id': 'L76FRuEeGIUJ',
            'name': 'Albert Einstein',
            'bio': 'Theoretical physicist',
            'description': 'Theoretical physicist',
            'link': 'https://en.wikipedia.org/wiki/Albert_Einstein',
            'quoteCount': 50,
            'slug': 'albert-einstein',
            'dateAdded': '2019-07-03',
            'dateModified': '2023-04-06',
          },
        ],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await dataSource.fetchAuthors(page: 1, limit: 1);

      expect(result.page, 1);
      expect(result.totalPages, 41);
      expect(result.totalCount, 803);
      expect(result.results.length, 1);
      expect(result.results[0].name, 'Albert Einstein');

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.path, '/authors');
    });

    test('includes sortBy, order, and slug params', () async {
      final responseBody = json.encode({
        'page': 1,
        'totalPages': 1,
        'totalCount': 0,
        'results': <dynamic>[],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      await dataSource.fetchAuthors(
        sortBy: 'quoteCount',
        order: 'desc',
        slug: 'albert-einstein',
      );

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.queryParameters['sortBy'], 'quoteCount');
      expect(uri.queryParameters['order'], 'desc');
      expect(uri.queryParameters['slug'], 'albert-einstein');
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Error', 500));

      expect(() => dataSource.fetchAuthors(), throwsA(isA<Exception>()));
    });
  });

  // ---------------------------------------------------------------------------
  // fetchAuthorById  –  GET /authors/:id  (curl #6)
  // ---------------------------------------------------------------------------
  group('fetchAuthorById', () {
    // Curl #6: GET /authors/L76FRuEeGIUJ (Albert Einstein)
    test('returns AuthorDetailModel from real API payload', () async {
      final responseBody = json.encode({
        '_id': 'L76FRuEeGIUJ',
        'bio': 'Albert Einstein was a German-born theoretical physicist.',
        'description': 'Theoretical physicist',
        'link': 'https://en.wikipedia.org/wiki/Albert_Einstein',
        'name': 'Albert Einstein',
        'slug': 'albert-einstein',
        'quoteCount': 50,
        'dateAdded': '2019-07-03',
        'dateModified': '2023-04-06',
        'quotes': [
          {
            '_id': '2xpHvSOQMi',
            'author': 'Albert Einstein',
            'content':
                'Try not to become a man of success, but rather try to become a man of value.',
            'authorSlug': 'albert-einstein',
            'length': 76,
            'tags': ['Famous Quotes'],
          },
        ],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final detail = await dataSource.fetchAuthorById('L76FRuEeGIUJ');

      expect(detail.author.id, 'L76FRuEeGIUJ');
      expect(detail.author.name, 'Albert Einstein');
      expect(
        detail.author.link,
        'https://en.wikipedia.org/wiki/Albert_Einstein',
      );
      expect(detail.quotes.length, 1);
      expect(detail.quotes[0].id, '2xpHvSOQMi');
      expect(detail.quotes[0].length, 76);

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.path, '/authors/L76FRuEeGIUJ');
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Not found', 404));

      expect(
        () => dataSource.fetchAuthorById('invalid'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // fetchAuthorBySlug  –  GET /authors/slug/:slug  (curl #7)
  // ---------------------------------------------------------------------------
  group('fetchAuthorBySlug', () {
    // Curl #7: GET /authors/slug/albert-camus
    test('returns AuthorDetailModel from real API payload', () async {
      final responseBody = json.encode({
        '_id': 'PVzslq_W8B-h',
        'bio': 'Albert Camus was a French philosopher, author, dramatist.',
        'description': 'French author and philosopher',
        'link': 'https://en.wikipedia.org/wiki/Albert_Camus',
        'name': 'Albert Camus',
        'slug': 'albert-camus',
        'quoteCount': 10,
        'dateAdded': '2019-12-18',
        'dateModified': '2023-04-06',
        'quotes': [
          {
            '_id': 'gxs-AmFzTJ9b',
            'author': 'Albert Camus',
            'content':
                'You will never be happy if you continue to search for what happiness consists of.',
            'authorSlug': 'albert-camus',
            'length': 81,
            'tags': ['Happiness'],
          },
        ],
      });

      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final detail = await dataSource.fetchAuthorBySlug('albert-camus');

      expect(detail.author.id, 'PVzslq_W8B-h');
      expect(detail.author.name, 'Albert Camus');
      expect(detail.author.description, 'French author and philosopher');
      expect(detail.quotes.length, 1);
      expect(
        detail.quotes[0].content,
        'You will never be happy if you continue to search for what happiness consists of.',
      );

      final captured = verify(() => mockClient.get(captureAny())).captured;
      final uri = captured.first as Uri;
      expect(uri.path, '/authors/slug/albert-camus');
    });

    test('throws on non-200 status code', () async {
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Not found', 404));

      expect(
        () => dataSource.fetchAuthorBySlug('invalid'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // PaginatedQuotes & PaginatedAuthors  –  Equatable
  // ---------------------------------------------------------------------------
  group('PaginatedQuotes', () {
    test('supports equality via Equatable', () {
      const p1 = PaginatedQuotes(
        page: 1,
        totalPages: 6,
        totalCount: 17,
        results: [],
      );
      const p2 = PaginatedQuotes(
        page: 1,
        totalPages: 6,
        totalCount: 17,
        results: [],
      );
      const p3 = PaginatedQuotes(
        page: 2,
        totalPages: 6,
        totalCount: 17,
        results: [],
      );

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
    });
  });

  group('PaginatedAuthors', () {
    test('supports equality via Equatable', () {
      const p1 = PaginatedAuthors(
        page: 1,
        totalPages: 41,
        totalCount: 803,
        results: [],
      );
      const p2 = PaginatedAuthors(
        page: 1,
        totalPages: 41,
        totalCount: 803,
        results: [],
      );
      const p3 = PaginatedAuthors(
        page: 2,
        totalPages: 41,
        totalCount: 803,
        results: [],
      );

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
    });
  });
}
