// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_finals/screens/home.dart';
import 'package:flutter_finals/models/playback_settings.dart';
import 'package:flutter_finals/services/playback_manager.dart';

void main() {
  testWidgets('Home screen basic smoke test', (WidgetTester tester) async {
    final settings = PlaybackSettings();
    final manager = PlaybackManager();

    // Build HomeScreen inside the real providers so it has the expected context.
    await tester.pumpWidget(PlaybackSettingsProvider(
      notifier: settings,
      child: PlaybackManagerProvider(
        notifier: manager,
        child: const MaterialApp(home: HomeScreen()),
      ),
    ));

    // Verify title text is present (simple smoke assertion).
    expect(find.textContaining('Your Music'), findsOneWidget);
  });
}
