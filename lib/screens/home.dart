import 'package:flutter/material.dart';
import '../data/sample_songs.dart';
import '../models/song.dart';
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
                  _titleForIndex(context, _selectedIndex),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                  ),
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
    final settings = PlaybackSettingsProvider.of(context);
    final theme = Theme.of(context);
    switch (idx) {
      case 0:
        // song list
        return SingleChildScrollView(
          child: Column(
            children: sampleSongs.asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;
              final settings = PlaybackSettingsProvider.of(context);
              final selected = settings.currentSongId == s.id;

              return InkWell(
                onTap: () {
                  settings.setCurrentSong(s.id);
                  final manager = PlaybackManagerProvider.of(context);
                  manager.playIndex(idx);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(song: s)));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(),
                  child: Row(
                    children: [
                      // cover: use image if available, else use first letter
                      s.coverPath != null && s.coverPath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                s.coverPath!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) => Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      s.title.characters.first,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  s.title.characters.first,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(width: 12),

                      // title , artist
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title, style: TextStyle(
                                color: selected ? theme.colorScheme.secondary : Colors.white
                              )
                            ),

                            const SizedBox(height: 2),

                            Text(
                              s.artist,
                              style: TextStyle(
                                color: selected ? theme.colorScheme.secondary : Colors.white.withOpacity(0.8), 
                                fontSize: 12
                              )
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );

      case 1:
        return Center(child: Text(settings.t('playlists_coming'), style: theme.textTheme.bodyLarge));

      case 2:
        // settings
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // en/vi toggle
              Text(
                settings.t('language'), 
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface
                )
              ),

              const SizedBox(height: 8),

              ToggleButtons(
                isSelected: [settings.languageCode == 'en', settings.languageCode == 'vi'],
                onPressed: (i) {
                  settings.setLanguage(i == 0 ? 'en' : 'vi');
                },
                color: Colors.white70,
                selectedColor: theme.colorScheme.onPrimary,
                fillColor: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
                children: const [Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 8
                  ), 
                  child: Text('EN')
                ), 
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 8
                  ), 
                  child: Text('VI')
                )
                ],
              ),

              const SizedBox(height: 20),

              // group info
              Text(settings.t('author'), style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Name: Nguyễn Hoàng Dương', style: TextStyle(color: Colors.white)),
                    SizedBox(height: 6),
                    Text('Student ID: 22012865', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 6),
                    Text('Class: N02', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

              const Spacer(),

              // app version
              Center(
                child: Text(
                  settings.t('version'), 
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7)
                  )
                )
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _titleForIndex(BuildContext context, int idx) {
    final settings = PlaybackSettingsProvider.of(context);
    switch (idx) {
      case 0:
        return settings.t('your_music');
      case 1:
        return settings.t('your_playlists');
      case 2:
        return settings.t('info_settings');
      default:
        return settings.t('your_music');
    }
  }
}

class _MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final manager = PlaybackManagerProvider.of(context);
    final settings = PlaybackSettingsProvider.of(context);

  // first time launch => hide miniplayer, on pause => keep
    final idx = manager.currentIndex;
    final bool hasTrack = idx != null && idx >= 0 && idx < sampleSongs.length;

    // if no track is loaded, show a placeholder mini player
  final Song? activeSong = hasTrack ? sampleSongs[idx] : null;
    final position = hasTrack ? manager.position : Duration.zero;
    final dur = hasTrack ? (manager.duration ?? Duration.zero) : Duration.zero;
    final progress = (dur.inMilliseconds > 0) ? (position.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: hasTrack ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(song: activeSong!))) : null,
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
                hasTrack && (activeSong?.coverPath ?? '').isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          activeSong!.coverPath!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800, 
                              borderRadius: BorderRadius.circular(6)
                            ),
                            child: Center(
                              child: Text(
                                activeSong.title.characters.first, 
                                style: const TextStyle(color: Colors.white)
                              )
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            hasTrack ? activeSong!.title.characters.first : '-', 
                            style: const TextStyle(
                              color: Colors.white
                            )
                          )
                        ),
                      ),
                const SizedBox(width: 12),
                // title + artist
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasTrack ? activeSong!.title : settings.t('not_playing'), 
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                        ), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                      ),

                      const SizedBox(height: 2),

                      Text(
                        hasTrack ? activeSong!.artist : '', 
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8)
                        ), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                      ),
                    ],
                  ),
                ),
                // controls
                IconButton(
                  onPressed: hasTrack ? () => manager.previous() : null,
                  icon: Icon(
                    Icons.skip_previous, 
                    color: hasTrack ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4)
                  ),
                ),
                Material(
                  shape: const CircleBorder(),
                  color: theme.colorScheme.primary,
                  child: IconButton(
                    onPressed: hasTrack ? () => manager.togglePlay() : null,
                    icon: Icon(
                      manager.playing ? Icons.pause : Icons.play_arrow, 
                      color: hasTrack ? theme.colorScheme.onPrimary : theme.colorScheme.onPrimary.withOpacity(0.6)
                    ),
                  ),
                ),
                IconButton(
                  onPressed: hasTrack ? () => manager.next() : null,
                  icon: Icon(
                    Icons.skip_next, 
                    color: hasTrack ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4)
                  ),
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
          _tabItem(context, icon: Icons.library_music, label: 'songs', index: 0),
          _tabItem(context, icon: Icons.playlist_play, label: 'playlists_tab', index: 1),
          _tabItem(context, icon: Icons.info, label: 'info_tab', index: 2),
        ],
      ),
    );
  }

  Widget _tabItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final theme = Theme.of(context);
    final active = index == selectedIndex;
    final settings = PlaybackSettingsProvider.of(context);
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: active ? theme.colorScheme.secondary : theme.colorScheme.onSurface
            ),

            const SizedBox(height: 4),

            Text(
              settings.t(label), 
              style: theme.textTheme.bodySmall?.copyWith(
                color: active ? theme.colorScheme.secondary : theme.colorScheme.onSurface
              )
            ),
          ],
        ),
      ),
    );
  }
}
