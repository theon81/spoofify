import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/playback_settings.dart';

/// player screen
class PlayerScreen extends StatelessWidget {
  final Song song;

  const PlayerScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final settings = PlaybackSettingsProvider.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Custom top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(song.title, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary))),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // big placeholder cover
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text(song.title, textAlign: TextAlign.center)),
            ),
            const SizedBox(height: 24),
            Text(song.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(song.artist, style: theme.textTheme.bodyLarge),
            const Spacer(),
            // controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // shuffle
                IconButton(
                  onPressed: () => settings.toggleShuffle(),
                  icon: Icon(Icons.shuffle,
                      color: settings.shuffle ? theme.colorScheme.secondary : theme.colorScheme.onSurface),
                ),
                const SizedBox(width: 12),
                // basic control
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous), iconSize: 36, color: theme.colorScheme.onSurface),
                const SizedBox(width: 8),
                // play button
                Material(
                  shape: const CircleBorder(),
                  color: theme.colorScheme.primary,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.play_arrow, color: theme.colorScheme.onPrimary),
                    iconSize: 28,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next), iconSize: 36, color: theme.colorScheme.onSurface),
                const SizedBox(width: 12),
                // loop
                IconButton(
                  onPressed: () => settings.cycleLoopMode(),
                  icon: _loopIcon(settings.loopMode),
                  color: (settings.loopMode == LoopMode.off) ? theme.colorScheme.onSurface : theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

Widget _loopIcon(LoopMode mode) {
  switch (mode) {
    case LoopMode.off:
      return const Icon(Icons.repeat);
    case LoopMode.one:
      return const Icon(Icons.repeat_one);
    case LoopMode.all:
      return const Icon(Icons.repeat);
  }
}
