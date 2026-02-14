import 'package:flutter_test/flutter_test.dart';
import 'package:quies/features/quotes/data/models/author_model.dart';

void main() {
  group('AuthorModel', () {
    // Uses actual API response from curl #5: GET /authors
    test('fromJson parses full API response with all fields', () {
      final json = {
        '_id': '76ISAUD3P5',
        'name': '14th Dalai Lama',
        'bio':
            'The 14th Dalai Lama (né Lhamo Thondup), known as Gyalwa Rinpoche to the Tibetan people, is the current Dalai Lama, the highest spiritual leader and former head of state of Tibet.',
        'description': 'Current foremost spiritual leader of Tibet',
        'link': 'https://en.wikipedia.org/wiki/14th_Dalai_Lama',
        'quoteCount': 0,
        'slug': '14th-dalai-lama',
        'dateAdded': '2022-07-06',
        'dateModified': '2022-07-06',
      };

      final author = AuthorModel.fromJson(json);

      expect(author.id, '76ISAUD3P5');
      expect(author.name, '14th Dalai Lama');
      expect(author.slug, '14th-dalai-lama');
      expect(author.bio, contains('Gyalwa Rinpoche'));
      expect(author.description, 'Current foremost spiritual leader of Tibet');
      expect(author.quoteCount, 0);
      expect(author.link, 'https://en.wikipedia.org/wiki/14th_Dalai_Lama');
      expect(author.dateAdded, '2022-07-06');
      expect(author.dateModified, '2022-07-06');
    });

    // Uses actual API response from curl #2: search/authors result
    test('fromJson parses search author response', () {
      final json = {
        '_id': 'm8GybB_kTLvv',
        'name': 'Jon Kabat-Zinn',
        'link': 'https://en.wikipedia.org/wiki/Jon_Kabat-Zinn',
        'bio':
            'Jon Kabat-Zinn (born Jon Kabat, June 5, 1944) is an American professor emeritus of medicine.',
        'description': 'American professor',
        'quoteCount': 1,
        'slug': 'jon-kabat-zinn',
        'dateAdded': '2019-02-13',
        'dateModified': '2019-02-13',
      };

      final author = AuthorModel.fromJson(json);

      expect(author.id, 'm8GybB_kTLvv');
      expect(author.name, 'Jon Kabat-Zinn');
      expect(author.link, 'https://en.wikipedia.org/wiki/Jon_Kabat-Zinn');
      expect(author.quoteCount, 1);
      expect(author.slug, 'jon-kabat-zinn');
    });

    test('fromJson handles null fields with defaults', () {
      final json = <String, dynamic>{
        '_id': null,
        'name': null,
        'slug': null,
        'bio': null,
        'description': null,
        'quoteCount': null,
        'link': null,
        'dateAdded': null,
      };

      final author = AuthorModel.fromJson(json);

      expect(author.id, '');
      expect(author.name, '');
      expect(author.slug, '');
      expect(author.bio, '');
      expect(author.description, '');
      expect(author.quoteCount, 0);
      expect(author.link, isNull);
      expect(author.dateAdded, isNull);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final author = AuthorModel.fromJson(json);

      expect(author.id, '');
      expect(author.name, '');
      expect(author.slug, '');
      expect(author.bio, '');
      expect(author.description, '');
      expect(author.quoteCount, 0);
      expect(author.link, isNull);
      expect(author.dateAdded, isNull);
      expect(author.dateModified, isNull);
    });

    test('supports equality via Equatable', () {
      const a1 = AuthorModel(
        id: 'a1',
        name: 'Einstein',
        slug: 'einstein',
        bio: 'Physicist',
        description: 'Science',
        quoteCount: 10,
        link: 'https://en.wikipedia.org/wiki/Albert_Einstein',
        dateAdded: '2019-07-03',
      );
      const a2 = AuthorModel(
        id: 'a1',
        name: 'Einstein',
        slug: 'einstein',
        bio: 'Physicist',
        description: 'Science',
        quoteCount: 10,
        link: 'https://en.wikipedia.org/wiki/Albert_Einstein',
        dateAdded: '2019-07-03',
      );
      const a3 = AuthorModel(
        id: 'a2',
        name: 'Newton',
        slug: 'newton',
        bio: 'Mathematician',
        description: 'Math',
        quoteCount: 5,
      );

      expect(a1, equals(a2));
      expect(a1, isNot(equals(a3)));
    });

    test('props contains all fields including new optional fields', () {
      const author = AuthorModel(
        id: 'id1',
        name: 'Name',
        slug: 'slug',
        bio: 'Bio',
        description: 'Desc',
        quoteCount: 7,
        link: 'https://example.com',
        dateAdded: '2023-01-01',
        dateModified: '2023-01-02',
      );

      expect(author.props, [
        'id1',
        'Name',
        'slug',
        'Bio',
        'Desc',
        7,
        'https://example.com',
        '2023-01-01',
        '2023-01-02',
      ]);
    });
  });
}
