/// Configuration constants for in-app update checking.
///
/// The app uses the `upgrader` package with an Appcast XML file
/// hosted on GitHub raw to determine if updates are available.
/// See `/appcast.xml` at the repo root for the version manifest.
class AppUpdateConfig {
  AppUpdateConfig._();

  /// URL to the Appcast XML file hosted on GitHub raw.
  ///
  /// Update this if the repository is renamed or transferred.
  /// The `upgrader` package fetches this on launch to check for updates.
  ///
  /// TODO(phase-12): Replace `<owner>` with actual GitHub username/org
  /// once the repo is public and the app ID is finalized.
  static const String appcastUrl =
      'https://raw.githubusercontent.com/moyeenhaider3/quies/main/appcast.xml';

  /// Supported OS identifiers for Appcast filtering.
  /// `upgrader` uses this to match `<sparkle:os>` tags in the XML.
  static const List<String> supportedOS = ['android'];

  /// How long to wait before showing an optional update prompt again.
  ///
  /// After the user dismisses an optional update dialog with "Later",
  /// the dialog won't reappear for this duration.
  /// The `upgrader` package stores this timestamp internally via SharedPreferences.
  static const Duration durationUntilAlertAgain = Duration(days: 3);

  /// Whether to enable debug logging for the upgrader.
  ///
  /// Set to `true` during development to see version check details in console.
  /// MUST be `false` in release builds.
  static const bool debugLogging = false;

  /// Whether to always display the upgrade dialog (for testing).
  ///
  /// When `true`, the dialog shows on every launch regardless of version.
  /// MUST be `false` in release builds.
  static const bool debugDisplayAlways = false;
}
