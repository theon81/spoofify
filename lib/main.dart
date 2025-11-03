import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'models/playback_settings.dart';

void main() {
  runApp(const MyApp());
}

/// main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1A1A1D);
    const surfaceVariant = Color(0xFF3B1C32);
    const primaryColor = Color(0xFF6A1E55);
    const highlight = Color(0xFFA64D79);

    final settings = PlaybackSettings();

    final colorScheme = ColorScheme.dark(
      background: background,
      surface: surfaceVariant,
      primary: primaryColor,
      secondary: highlight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // force white text by default
      textTheme: Typography.whiteMountainView,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(backgroundColor: primaryColor, foregroundColor: Colors.white),
    );

    return PlaybackSettingsProvider(
      notifier: settings,
      child: MaterialApp(
        title: 'Spoofify',
        theme: theme,
        home: const HomeScreen(),
      ),
    );
  }
}

