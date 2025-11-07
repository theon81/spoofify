import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'models/playback_settings.dart';
import 'services/playback_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // color palette
  const background = Color(0xFF333446);
  const primaryColor = Color(0xFF7F8CAA);
  const highlight = Color(0xFFB8CFCE);

  final settings = PlaybackSettings();
  final manager = PlaybackManager();
  await manager.init();
  manager.attachSettings(settings);

  final colorScheme = ColorScheme.dark(
    surface: background,
    primary: primaryColor,
    secondary: highlight,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
  );

  final theme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(backgroundColor: primaryColor, foregroundColor: Colors.white),
  );

  runApp(PlaybackSettingsProvider(
    notifier: settings,
    child: PlaybackManagerProvider(
      notifier: manager,
      child: MaterialApp(
        title: 'Spoofify',
        theme: theme,
        home: const HomeScreen(),
      ),
    ),
  ));
}


