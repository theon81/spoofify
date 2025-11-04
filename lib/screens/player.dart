import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/playback_settings.dart';
import '../services/playback_manager.dart';


/// song screen
class PlayerScreen extends StatelessWidget {
  final Song song;

  const PlayerScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = PlaybackSettingsProvider.of(context);
    final manager = PlaybackManagerProvider.of(context);

    return Material(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.arrow_back, color: Colors.white)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(song.title, style: const TextStyle(color: Colors.white, fontSize: 18))),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // cover
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(song.title, textAlign: TextAlign.center)),
            ),

            const SizedBox(height: 20),

            // title, artist
            Text(song.title, style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 6),
            Text(song.artist, style: const TextStyle(color: Colors.white70)),

            const Spacer(),

            // controls
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // shuffle
                  GestureDetector(onTap: () => settings.toggleShuffle(), child: Icon(Icons.shuffle, color: settings.shuffle ? theme.colorScheme.secondary : Colors.white)),
                  const SizedBox(width: 24),

                  // prev
                  GestureDetector(onTap: () => manager.previous(), child: const Icon(Icons.skip_previous, color: Colors.white, size: 32)),
                  const SizedBox(width: 16),

                  // play, pause
                  GestureDetector(
                    onTap: () => manager.togglePlay(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                      child: Center(child: Icon(manager.playing ? Icons.pause : Icons.play_arrow, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // next
                  GestureDetector(onTap: () => manager.next(), child: const Icon(Icons.skip_next, color: Colors.white, size: 32)),
                  const SizedBox(width: 24),

                  // loop
                  GestureDetector(onTap: () => settings.cycleLoopMode(), child: _loopIcon(context, settings.loopMode)),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

Widget _loopIcon(BuildContext context, LoopMode mode) {
  final theme = Theme.of(context);
  final activeColor = theme.colorScheme.secondary;

  switch (mode) {
    case LoopMode.off:
      return const Icon(Icons.repeat, color: Colors.white);
    case LoopMode.one:
      return Icon(Icons.repeat_one, color: activeColor);
    case LoopMode.all:
      return Icon(Icons.repeat, color: activeColor);
  }
}
