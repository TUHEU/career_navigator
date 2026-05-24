// providers/guest_provider.dart
// Manages guest mode — browsing without an account.
// Guest users can: browse jobs, view mentors, read about the app.
// Guest users CANNOT: apply, chat, use AI, access profile.

import 'package:flutter/material.dart';

class GuestProvider extends ChangeNotifier {
  bool _isGuest = false;

  bool get isGuest => _isGuest;

  void enterGuestMode() {
    _isGuest = true;
    notifyListeners();
  }

  void exitGuestMode() {
    _isGuest = false;
    notifyListeners();
  }

  /// Returns true if the feature is available in guest mode
  bool canAccess(GuestFeature feature) {
    if (!_isGuest) return true; // authenticated users can access everything
    switch (feature) {
      case GuestFeature.browseJobs:
      case GuestFeature.viewMentors:
      case GuestFeature.viewAbout:
        return true;
      case GuestFeature.applyJob:
      case GuestFeature.chat:
      case GuestFeature.aiTools:
      case GuestFeature.editProfile:
      case GuestFeature.notifications:
      case GuestFeature.sendRequest:
        return false;
    }
  }
}

enum GuestFeature {
  browseJobs,
  viewMentors,
  viewAbout,
  applyJob,
  chat,
  aiTools,
  editProfile,
  notifications,
  sendRequest,
}
