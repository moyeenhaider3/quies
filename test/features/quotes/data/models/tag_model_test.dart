import 'package:flutter_test/flutter_test.dart';
import 'package:quies/features/quotes/data/models/tag_model.dart';

void main() {
  group('TagModel', () {
    // Uses actual API response from curl #4: GET /tags
    test('fromJson parses full API response with all fields', () {
      final json = {
        '_id': '6J1qxxuj3',
        'name': 'Wisdom',
        'slug': 'wisdom',
        'quoteCount': 550,
        'dateAdded': '2019-10-18',
        'dateModified': '2023-04-14',
      };

      final tag = TagModel.fromJson(json);

      expect(tag.id, '6J1qxxuj3');
      expect(tag.name, 'Wisdom');
      expect(tag.slug, 'wisdom');
      expect(tag.quoteCount, 550);
      expect(tag.dateAdded, '2019-10-18');
      expect(tag.dateModified, '2023-04-14');
    });

    // Another real tag from curl #4
    test('fromJson parses tag with low quoteCount', () {
      final json = {
        '_id': 'AN2qILFNzW',
        'name': 'Weakness',
        'slug': 'weakness',
        'quoteCount': 1,
        'dateAdded': '2023-04-14',
        'dateModified': '2023-04-14',
      };

      final tag = TagModel.fromJson(json);

      expect(tag.id, 'AN2qILFNzW');
      expect(tag.name, 'Weakness');
      expect(tag.slug, 'weakness');
      expect(tag.quoteCount, 1);
    });

    test('fromJson handles null fields with defaults', () {
      final json = <String, dynamic>{
        '_id': null,
        'name': null,
        'slug': null,
        'quoteCount': null,
        'dateAdded': null,
        'dateModified': null,
      };

      final tag = TagModel.fromJson(json);

      expect(tag.id, '');
      expect(tag.name, '');
      expect(tag.slug, '');
      expect(tag.quoteCount, 0);
      expect(tag.dateAdded, isNull);
      expect(tag.dateModified, isNull);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final tag = TagModel.fromJson(json);

      expect(tag.id, '');
      expect(tag.name, '');
      expect(tag.slug, '');
      expect(tag.quoteCount, 0);
      expect(tag.dateAdded, isNull);
      expect(tag.dateModified, isNull);
    });

    test('supports equality via Equatable', () {
      const tag1 = TagModel(
        id: 'fvpORe-t',
        name: 'Famous Quotes',
        slug: 'famous-quotes',
        quoteCount: 1090,
        dateAdded: '2019-07-23',
        dateModified: '2023-04-14',
      );
      const tag2 = TagModel(
        id: 'fvpORe-t',
        name: 'Famous Quotes',
        slug: 'famous-quotes',
        quoteCount: 1090,
        dateAdded: '2019-07-23',
        dateModified: '2023-04-14',
      );
      const tag3 = TagModel(
        id: 'rnrd8q9X1',
        name: 'Love',
        slug: 'love',
        quoteCount: 20,
      );

      expect(tag1, equals(tag2));
      expect(tag1, isNot(equals(tag3)));
    });

    test('props contains all fields including optional date fields', () {
      const tag = TagModel(
        id: '6J1qxxuj3',
        name: 'Wisdom',
        slug: 'wisdom',
        quoteCount: 550,
        dateAdded: '2019-10-18',
        dateModified: '2023-04-14',
      );

      expect(tag.props, [
        '6J1qxxuj3',
        'Wisdom',
        'wisdom',
        550,
        '2019-10-18',
        '2023-04-14',
      ]);
    });
  });
}
