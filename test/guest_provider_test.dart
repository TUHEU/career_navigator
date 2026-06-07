// test/guest_provider_test.dart — tests providers/guest_provider.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/providers/guest_provider.dart';

void main() {
  late GuestProvider guest;
  setUp(() => guest = GuestProvider());

  group('guest mode toggle', () {
    test('starts NOT guest', () => expect(guest.isGuest, isFalse));
    test('enterGuestMode', () {
      guest.enterGuestMode();
      expect(guest.isGuest, isTrue);
    });
    test('exitGuestMode', () {
      guest.enterGuestMode();
      guest.exitGuestMode();
      expect(guest.isGuest, isFalse);
    });
  });

  group('canAccess — authenticated', () {
    test('can access everything', () {
      for (final f in GuestFeature.values) {
        expect(guest.canAccess(f), isTrue);
      }
    });
  });

  group('canAccess — guest', () {
    setUp(() => guest.enterGuestMode());
    test('browseJobs allowed', () => expect(guest.canAccess(GuestFeature.browseJobs), isTrue));
    test('viewMentors allowed', () => expect(guest.canAccess(GuestFeature.viewMentors), isTrue));
    test('viewAbout allowed', () => expect(guest.canAccess(GuestFeature.viewAbout), isTrue));
    test('applyJob blocked', () => expect(guest.canAccess(GuestFeature.applyJob), isFalse));
    test('chat blocked', () => expect(guest.canAccess(GuestFeature.chat), isFalse));
    test('aiTools blocked', () => expect(guest.canAccess(GuestFeature.aiTools), isFalse));
    test('editProfile blocked', () => expect(guest.canAccess(GuestFeature.editProfile), isFalse));
    test('notifications blocked', () => expect(guest.canAccess(GuestFeature.notifications), isFalse));
    test('sendRequest blocked', () => expect(guest.canAccess(GuestFeature.sendRequest), isFalse));
  });

  test('GuestFeature has 9 values', () => expect(GuestFeature.values.length, 9));
}
