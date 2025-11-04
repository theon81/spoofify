import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'models/playback_settings.dart';
import 'services/playback_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // user color palette
  const background = Color(0xFF1A1A1D);
  const primaryColor = Color(0xFF6A1E55);
  const highlight = Color(0xFFA64D79);

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
    onBackground: Colors.white,
    onSurface: Colors.white,
  );

  final theme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: Typography.whiteMountainView,
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


