import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';

/// Manages user consent for ad tracking.
/// - iOS 14.5+: Requests App Tracking Transparency (ATT) permission.
/// - EU users: Uses Google UMP SDK for GDPR consent.
@lazySingleton
class ConsentManager {
  bool _consentGathered = false;

  bool get consentGathered => _consentGathered;

  /// Call once at app startup, BEFORE loading any ads.
  Future<void> gatherConsent() async {
    // 1. ATT prompt on iOS 14.5+
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    // 2. UMP SDK consent (GDPR)
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _showConsentForm();
        }
        _consentGathered = true;
      },
      (FormError error) {
        _consentGathered = true;
      },
    );
  }

  void _showConsentForm() {
    ConsentForm.loadConsentForm((ConsentForm consentForm) {
      final status = ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        consentForm.show((FormError? error) {});
      }
    }, (FormError error) {});
  }

  bool get canShowPersonalizedAds {
    final status = ConsentInformation.instance.getConsentStatus();
    return status == ConsentStatus.obtained ||
        status == ConsentStatus.notRequired;
  }
}
