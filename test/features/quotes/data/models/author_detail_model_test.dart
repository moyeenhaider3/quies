import 'package:flutter_test/flutter_test.dart';
import 'package:quies/features/quotes/data/models/author_detail_model.dart';

void main() {
  group('AuthorDetailModel', () {
    // Uses actual API response from curl #6: GET /authors/L76FRuEeGIUJ (Albert Einstein)
    test('fromJson parses real API response with embedded quotes', () {
      final json = {
        '_id': 'L76FRuEeGIUJ',
        'bio':
            'Albert Einstein was a German-born theoretical physicist, widely acknowledged to be one of the greatest and most influential physicists of all time.',
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
          {
            '_id': 'BRC6vxE3Im',
            'author': 'Albert Einstein',
            'content': 'Only a life lived for others is a life worthwhile.',
            'authorSlug': 'albert-einstein',
            'length': 51,
            'tags': ['Famous Quotes'],
          },
        ],
      };

      final detail = AuthorDetailModel.fromJson(json);

      // Author fields
      expect(detail.author.id, 'L76FRuEeGIUJ');
      expect(detail.author.name, 'Albert Einstein');
      expect(detail.author.slug, 'albert-einstein');
      expect(detail.author.description, 'Theoretical physicist');
      expect(
        detail.author.link,
        'https://en.wikipedia.org/wiki/Albert_Einstein',
      );
      expect(detail.author.quoteCount, 50);
      expect(detail.author.dateAdded, '2019-07-03');
      expect(detail.author.dateModified, '2023-04-06');

      // Embedded quotes
      expect(detail.quotes.length, 2);
      expect(detail.quotes[0].id, '2xpHvSOQMi');
      expect(
        detail.quotes[0].content,
        'Try not to become a man of success, but rather try to become a man of value.',
      );
      expect(detail.quotes[0].length, 76);
      expect(detail.quotes[1].id, 'BRC6vxE3Im');
    });

    // Uses actual API response from curl #7: GET /authors/slug/albert-camus
    test('fromJson parses slug response with embedded quotes', () {
      final json = {
        '_id': 'PVzslq_W8B-h',
        'bio':
            'Albert Camus was a French philosopher, author, dramatist, journalist, and political activist.',
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
      };

      final detail = AuthorDetailModel.fromJson(json);

      expect(detail.author.id, 'PVzslq_W8B-h');
      expect(detail.author.name, 'Albert Camus');
      expect(detail.author.slug, 'albert-camus');
      expect(detail.author.description, 'French author and philosopher');
      expect(detail.quotes.length, 1);
      expect(detail.quotes[0].id, 'gxs-AmFzTJ9b');
      expect(detail.quotes[0].length, 81);
    });

    test('fromJson handles empty quotes array', () {
      final json = {
        '_id': 'test-id',
        'name': 'Test Author',
        'slug': 'test-author',
        'bio': 'A test author.',
        'description': 'Test',
        'quoteCount': 0,
        'quotes': <dynamic>[],
      };

      final detail = AuthorDetailModel.fromJson(json);

      expect(detail.author.name, 'Test Author');
      expect(detail.quotes, isEmpty);
    });

    test('fromJson handles missing quotes key', () {
      final json = {
        '_id': 'test-id',
        'name': 'Test Author',
        'slug': 'test-author',
        'bio': 'A test author.',
        'description': 'Test',
        'quoteCount': 0,
      };

      final detail = AuthorDetailModel.fromJson(json);

      expect(detail.quotes, isEmpty);
    });

    test('supports equality via Equatable', () {
      final json1 = {
        '_id': 'L76FRuEeGIUJ',
        'name': 'Albert Einstein',
        'slug': 'albert-einstein',
        'bio': 'Physicist',
        'description': 'Theoretical physicist',
        'quoteCount': 50,
        'quotes': <dynamic>[],
      };

      final detail1 = AuthorDetailModel.fromJson(json1);
      final detail2 = AuthorDetailModel.fromJson(json1);

      expect(detail1, equals(detail2));
    });
  });
}
