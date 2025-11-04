import 'package:flutter/material.dart';
import '../models/song.dart';
import '../data/sample_songs.dart';
import '../models/playback_settings.dart';
import '../services/playback_manager.dart';
import 'player.dart';

/// home
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0: songs, 1: playlists, 2: settings

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.primary,
              child: Center(
                child: Text(
                  'Your Music',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // main content
            Expanded(
              child: _buildTabContent(context, _selectedIndex),
            ),

            // mini player
            _MiniPlayer(),

            // screens tab
            _BottomTabs(selectedIndex: _selectedIndex, onTabSelected: (i) => setState(() => _selectedIndex = i)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, int idx) {
    final theme = Theme.of(context);
    switch (idx) {
      case 0:
        // song list
        return SingleChildScrollView(
          child: Column(
            children: sampleSongs.map((s) {
              final settings = PlaybackSettingsProvider.of(context);
              final selected = settings.currentSongId == s.id;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(),
                child: Row(
                  children: [
                    // cover
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(20)),
                      child: Center(child: Text(s.title.characters.first, style: const TextStyle(color: Colors.white))),
                    ),
                    const SizedBox(width: 12),
                    // title , artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: TextStyle(color: selected ? theme.colorScheme.secondary : Colors.white)),
                          const SizedBox(height: 2),
                          Text(s.artist, style: TextStyle(color: selected ? theme.colorScheme.secondary : Colors.white.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                    ),
                    // chevron
                    GestureDetector(
                      onTap: () {
                        settings.setCurrentSong(s.id);
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(song: s)));
                      },
                      child: const Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );

      case 1:
        return Center(child: Text('Playlists (coming soon)', style: theme.textTheme.bodyLarge));

      case 2:
        return Center(child: Text('Info / About', style: theme.textTheme.bodyLarge));

      default:
        return const SizedBox.shrink();
    }
  }
}

class _MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final manager = PlaybackManagerProvider.of(context);

  // first time launch => hide miniplayer, on pause => keep
    final idx = manager.currentIndex;
    final bool hasTrack = idx != null && idx >= 0 && idx < sampleSongs.length;

    // if no track is loaded, show a placeholder mini player
  final song = hasTrack ? sampleSongs[idx] : null;
    final position = hasTrack ? manager.position : Duration.zero;
    final dur = hasTrack ? (manager.duration ?? Duration.zero) : Duration.zero;
    final progress = (dur.inMilliseconds > 0) ? (position.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: hasTrack ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(song: song!))) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: theme.colorScheme.surface.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.secondary),
          ),
          Container(
            height: 72,
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // small cover / avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(child: Text(hasTrack ? song!.title.characters.first : '-', style: const TextStyle(color: Colors.white))),
                ),
                const SizedBox(width: 12),
                // title + artist
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hasTrack ? song!.title : 'Not playing', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(hasTrack ? song!.artist : '', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // controls
                IconButton(
                  onPressed: hasTrack ? () => manager.previous() : null,
                  icon: Icon(Icons.skip_previous, color: hasTrack ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4)),
                ),
                Material(
                  shape: const CircleBorder(),
                  color: theme.colorScheme.primary,
                  child: IconButton(
                    onPressed: hasTrack ? () => manager.togglePlay() : null,
                    icon: Icon(manager.playing ? Icons.pause : Icons.play_arrow, color: hasTrack ? theme.colorScheme.onPrimary : theme.colorScheme.onPrimary.withOpacity(0.6)),
                  ),
                ),
                IconButton(
                  onPressed: hasTrack ? () => manager.next() : null,
                  icon: Icon(Icons.skip_next, color: hasTrack ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _BottomTabs({required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 64,
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          _tabItem(context, icon: Icons.library_music, label: 'Songs', index: 0),
          _tabItem(context, icon: Icons.playlist_play, label: 'Playlists', index: 1),
          _tabItem(context, icon: Icons.info, label: 'Info', index: 2),
        ],
      ),
    );
  }

  Widget _tabItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final theme = Theme.of(context);
    final active = index == selectedIndex;
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? theme.colorScheme.secondary : theme.colorScheme.onSurface),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: active ? theme.colorScheme.secondary : theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
