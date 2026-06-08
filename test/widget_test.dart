// test/widget_test.dart
// Career Navigator — Widget smoke test
// Verifies the app boots inside its full provider tree without crashing.
// FIX: SplashScreen starts timers (auto-navigate + pulsing dots) in initState.
// We let those timers fire and settle before the test ends, so no timer is
// left pending when the widget tree is disposed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:career_navigator/main.dart';
import 'package:career_navigator/providers/theme_provider.dart';
import 'package:career_navigator/providers/auth_provider.dart';
import 'package:career_navigator/providers/chat_provider.dart';
import 'package:career_navigator/providers/job_provider.dart';
import 'package:career_navigator/providers/notification_provider.dart';
import 'package:career_navigator/providers/guest_provider.dart';
import 'package:career_navigator/providers/user_provider.dart';
import 'package:career_navigator/l10n/language_provider.dart';

Widget _app() => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => LanguageProvider()),
    ChangeNotifierProvider(create: (_) => GuestProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => JobProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
  ],
  child: const CareerNavigatorApp(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Provide empty mock prefs so ThemeProvider / LanguageProvider
    // don't fail reading SharedPreferences during the test.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app builds a MaterialApp', (tester) async {
    await tester.pumpWidget(_app());

    // SplashScreen schedules timers; pump through them so none stay pending.
    await tester.pump(const Duration(seconds: 1)); // pulsing-dots tick
    await tester.pump(const Duration(seconds: 3)); // splash auto-navigate fires
    await tester.pump(const Duration(seconds: 1)); // settle any follow-up frame

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('app title and banner correct', (tester) async {
    await tester.pumpWidget(_app());

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Career Navigator');
    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}
