import 'package:flutter/material.dart';
import '../models/song.dart';
import '../data/sample_songs.dart';
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
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // top bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10
              ),
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(), 
                    child: const Icon(
                      Icons.expand_more,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Text(
                              settings.t('now_playing'),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary, 
                                fontSize: 18,
                              )
                            )
                    )
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // cover
            Builder(builder: (ctx) {
              final currentIdx = manager.currentIndex;
              final hasTrack = currentIdx != null && currentIdx >= 0 && currentIdx < sampleSongs.length;
              final displaySong = hasTrack ? sampleSongs[currentIdx] : song;

              if (displaySong.coverPath != null && displaySong.coverPath!.isNotEmpty) {
                return Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), 
                    color: theme.colorScheme.surface
                  ),

                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(
                    displaySong.coverPath!, 
                    fit: BoxFit.cover
                  ),
                );
              }

              return Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.06), 
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Center(
                  child: Text(
                    displaySong.title, 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  )
                ),
              );
            }),

            const SizedBox(height: 20),

            // title, artist
              Builder(builder: (ctx) {
                final currentIdx = manager.currentIndex;
                final hasTrack = currentIdx != null && currentIdx >= 0 && currentIdx < sampleSongs.length;
                final displaySong = hasTrack ? sampleSongs[currentIdx] : song;

                return Column(
                  children: [
                    Text(
                      displaySong.title, 
                      style: TextStyle(
                          color: theme.colorScheme.onSurface, 
                          fontSize: 20
                        )
                    ),

                    const SizedBox(height: 6),

                    Text(
                      displaySong.artist, 
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.8)
                      )
                    ),
                  ],
                );
              }),

            const Spacer(),

              // progress bar
              /// tutorial ref: https://api.flutter.dev/flutter/material/LinearProgressIndicator-class.html
              
              Builder(builder: (ctx) {
                final pos = manager.position;
                final dur = manager.duration ?? Duration.zero;
                final progress = (dur.inMilliseconds > 0) ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0) : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                      backgroundColor: theme.colorScheme.surface.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.secondary),
                  ),
                );
              }),

              const SizedBox(height: 12),
              
            // controls
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // shuffle
                  GestureDetector(
                    onTap: () => settings.toggleShuffle(), 
                    child: Icon(
                      Icons.shuffle, 
                      color: settings.shuffle ? theme.colorScheme.secondary : theme.colorScheme.onSurface
                    )
                  ),

                  const SizedBox(width: 24),

                  // prev
                  GestureDetector(
                    onTap: () => manager.previous(), 
                    child: Icon(
                      Icons.skip_previous, 
                      color: theme.colorScheme.onSurface, size: 32
                    )
                  ),

                  const SizedBox(width: 16),

                  // play, pause
                  GestureDetector(
                    onTap: () => manager.togglePlay(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Icon(
                          manager.playing ? Icons.pause : Icons.play_arrow, 
                          color: theme.colorScheme.onPrimary
                        )
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // next
                  GestureDetector(
                    onTap: () => manager.next(), 
                    child: Icon(
                      Icons.skip_next, 
                      color: theme.colorScheme.onSurface, 
                      size: 32
                    )
                  ),

                  const SizedBox(width: 24),

                  // loop
                  GestureDetector(
                    onTap: () => settings.cycleLoopMode(), 
                    child: _loopIcon(context, settings.loopMode)
                  ),
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
