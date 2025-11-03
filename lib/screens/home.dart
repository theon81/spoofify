import 'package:flutter/material.dart';
import '../models/song.dart';
import '../data/sample_songs.dart';
import '../models/playback_settings.dart';
import 'player.dart';

/// home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  Text('Spoofify', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                  const Spacer(),
                  // placeholder actions
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            ),

            // song list
            Expanded(
              child: ListView.separated(
                itemCount: sampleSongs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final Song s = sampleSongs[index];
                  final settings = PlaybackSettingsProvider.of(context);
                  final selected = settings.currentSongId == s.id;
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(s.title.characters.first),
                    ),
                    title: Text(s.title, style: TextStyle(color: selected ? theme.colorScheme.secondary : null)),
                    subtitle: Text(s.artist, style: TextStyle(color: selected ? theme.colorScheme.secondary : null)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      settings.setCurrentSong(s.id);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(song: s)));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
