import 'package:flutter_test/flutter_test.dart';
import 'package:quies/core/updater/app_update_config.dart';

void main() {
  group('AppUpdateConfig', () {
    test('appcastUrl points to GitHub raw', () {
      expect(AppUpdateConfig.appcastUrl, contains('raw.githubusercontent.com'));
      expect(AppUpdateConfig.appcastUrl, endsWith('appcast.xml'));
    });

    test('supportedOS includes android', () {
      expect(AppUpdateConfig.supportedOS, contains('android'));
    });

    test('durationUntilAlertAgain is 3 days', () {
      expect(
        AppUpdateConfig.durationUntilAlertAgain,
        equals(const Duration(days: 3)),
      );
    });

    test('debug flags are disabled by default', () {
      expect(AppUpdateConfig.debugLogging, isFalse);
      expect(AppUpdateConfig.debugDisplayAlways, isFalse);
    });
  });
}
