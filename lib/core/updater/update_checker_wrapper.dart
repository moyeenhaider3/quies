import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import 'app_update_config.dart';

/// Wraps a child widget with in-app update checking via [UpgradeAlert].
///
/// Place this inside the router's [ShellRoute] builder so that:
/// - Update checks only happen after onboarding is complete
/// - The update dialog appears on top of the main app screens
/// - Force-updates (critical) block usage; optional updates are dismissible
///
/// The [UpgradeAlert] widget from the `upgrader` package handles:
/// - Fetching the Appcast XML from GitHub
/// - Comparing remote version with installed version (semver)
/// - Showing force-update dialog for critical versions (non-dismissible)
/// - Showing optional update dialog for minor versions (dismissible)
/// - "Don't nag" frequency control via [AppUpdateConfig.durationUntilAlertAgain]
/// - Graceful fallback if the fetch fails (app continues normally)
/// - Redirecting to the correct store (Play Store / App Store)
class UpdateCheckerWrapper extends StatelessWidget {
  const UpdateCheckerWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        storeController: UpgraderStoreController(
          onAndroid: () =>
              UpgraderAppcastStore(appcastURL: AppUpdateConfig.appcastUrl),
          oniOS: () =>
              UpgraderAppcastStore(appcastURL: AppUpdateConfig.appcastUrl),
        ),
        durationUntilAlertAgain: AppUpdateConfig.durationUntilAlertAgain,
        debugLogging: AppUpdateConfig.debugLogging,
        debugDisplayAlways: AppUpdateConfig.debugDisplayAlways,
      ),
      child: child,
    );
  }
}
