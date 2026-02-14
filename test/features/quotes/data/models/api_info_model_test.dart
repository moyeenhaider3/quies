import 'package:flutter_test/flutter_test.dart';
import 'package:quies/features/quotes/data/models/api_info_model.dart';

void main() {
  group('ApiInfoModel', () {
    // Uses actual API response from curl #1: GET /info/count
    test('fromJson parses real API response', () {
      final json = {'quotes': 2127, 'authors': 803, 'tags': 67};

      final info = ApiInfoModel.fromJson(json);

      expect(info.quotes, 2127);
      expect(info.authors, 803);
      expect(info.tags, 67);
    });

    test('fromJson handles null values with zero defaults', () {
      final json = <String, dynamic>{
        'quotes': null,
        'authors': null,
        'tags': null,
      };

      final info = ApiInfoModel.fromJson(json);

      expect(info.quotes, 0);
      expect(info.authors, 0);
      expect(info.tags, 0);
    });

    test('fromJson handles missing fields with zero defaults', () {
      final json = <String, dynamic>{};

      final info = ApiInfoModel.fromJson(json);

      expect(info.quotes, 0);
      expect(info.authors, 0);
      expect(info.tags, 0);
    });

    test('supports equality via Equatable', () {
      const info1 = ApiInfoModel(quotes: 2127, authors: 803, tags: 67);
      const info2 = ApiInfoModel(quotes: 2127, authors: 803, tags: 67);
      const info3 = ApiInfoModel(quotes: 100, authors: 50, tags: 10);

      expect(info1, equals(info2));
      expect(info1, isNot(equals(info3)));
    });

    test('props contains all fields', () {
      const info = ApiInfoModel(quotes: 2127, authors: 803, tags: 67);

      expect(info.props, [2127, 803, 67]);
    });
  });
}
