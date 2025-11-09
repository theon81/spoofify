import 'dart:async';

import 'package:audio_session/audio_session.dart';
/// https://pub.dev/packages/audio_session

import 'package:just_audio/just_audio.dart' as ja;
/// audio playback: https://pub.dev/packages/just_audio

import 'package:flutter/widgets.dart';

import '../data/sample_songs.dart';
import '../models/playback_settings.dart';
import '../models/song.dart';
import 'dart:io';

class PlaybackManager extends ChangeNotifier {
  final ja.AudioPlayer _player = ja.AudioPlayer();

  bool _playing = false;
  int? _currentIndex;
  Duration _position = Duration.zero;
  Duration? _duration;

  // playlist songs (initially loaded from sampleSongs, then can be extended
  // by importing files at runtime)
  final List<Song> _playlistSongs = List<Song>.from(sampleSongs);

  /// Expose a read-only view of the current playlist for the UI
  List<Song> get playlistSongs => List.unmodifiable(_playlistSongs);

  bool get playing => _playing;
  int? get currentIndex => _currentIndex;
  Duration get position => _position;
  Duration? get duration => _duration;

  // store settings listener for disposal
  PlaybackSettings? _settings;
  VoidCallback? _settingsListener;

  /// initialize audio session and load the playlist from sampleSongs.
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // playlist: build audio sources from the initial sampleSongs list
    /// https://pub.dev/documentation/just_audio/latest/just_audio/ConcatenatingAudioSource-class.html
    final sources = _playlistSongs.map((s) {
      // if asset path looks like an asset (starts with assets/), load as asset
      if (s.assetPath.startsWith('assets/')) {
        return ja.AudioSource.asset(s.assetPath, tag: {'id': s.id, 'title': s.title, 'artist': s.artist});
      }
      // otherwise treat it as a file path
      return ja.AudioSource.uri(Uri.file(s.assetPath), tag: {'id': s.id, 'title': s.title, 'artist': s.artist});
    }).toList();

    final playlist = ja.ConcatenatingAudioSource(children: sources);
    await _player.setAudioSource(playlist);

    // streams
    _player.playingStream.listen((p) {
      _playing = p;
      notifyListeners();
    });

    _player.currentIndexStream.listen((i) {
      _currentIndex = i;
      // update settings currentSongId if available
      if (i != null && i >= 0 && i < _playlistSongs.length) {
        _settings?.setCurrentSong(_playlistSongs[i].id);
      }
      notifyListeners();
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((d) {
      _duration = d;
      notifyListeners();
    });
  }

  void attachSettings(PlaybackSettings settings) {
    // detach previous listener
    if (_settings != null && _settingsListener != null) {
      _settings!.removeListener(_settingsListener!);
    }

    _settings = settings;
    _settingsListener = () {
      // apply shuffle
      /// https://pub.dev/documentation/just_audio/latest/just_audio/AudioPlayer/setShuffleModeEnabled.html
      _player.setShuffleModeEnabled(_settings!.shuffle);

      // apply loop mode
      /// https://pub.dev/documentation/just_audio/latest/just_audio/LoopMode-class.html
      switch (_settings!.loopMode) {
        case LoopMode.off:
          _player.setLoopMode(ja.LoopMode.off);
          break;
        case LoopMode.one:
          _player.setLoopMode(ja.LoopMode.one);
          break;
        case LoopMode.all:
          _player.setLoopMode(ja.LoopMode.all);
          break;
      }
    };
    settings.addListener(_settingsListener!);

    // initialize player modes to current settings
    _player.setShuffleModeEnabled(settings.shuffle);
    switch (settings.loopMode) {
      case LoopMode.off:
        _player.setLoopMode(ja.LoopMode.off);
        break;
      case LoopMode.one:
        _player.setLoopMode(ja.LoopMode.one);
        break;
      case LoopMode.all:
        _player.setLoopMode(ja.LoopMode.all);
        break;
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> togglePlay() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() => _player.seekToNext();
  

  Future<void> playIndex(int index) async {
    if (index < 0 || index >= _playlistSongs.length) return;
    try {
      // seek to the start of the requested index and play
      await _player.seek(Duration.zero, index: index);
      await _player.play();
    } catch (_) {
      // ignore errors here to keep UI responsive; errors can be logged later
    }
  }
  Future<void> previous() async {
    // let the user restart the song instead of going to previous every time
    try {
      if (_position > const Duration(seconds: 4)) {
        await _player.seek(Duration.zero);
      } else {
        await _player.seekToPrevious();
      }
    } catch (_) {
      // fallback: try to seek to previous even if an error occurs
      await _player.seekToPrevious();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> disposeAsync() async {
    await _player.dispose();
    if (_settings != null && _settingsListener != null) {
      _settings!.removeListener(_settingsListener!);
    }
    super.dispose();
  }

  /// Import a file path and append it to
  /// the current playlist.
  Future<Song?> importFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final title = file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last.split('.').first : 'Imported';
      final id = 'imported-${DateTime.now().millisecondsSinceEpoch}';
      final song = Song(id: id, title: title, artist: 'Imported', assetPath: path, coverPath: null);

      // create audio source from file URI and add to playlist
      final source = ja.AudioSource.uri(Uri.file(path), tag: {'id': song.id, 'title': song.title, 'artist': song.artist});

      // append to _player's playlist
      final current = _player.audioSource;
      if (current is ja.ConcatenatingAudioSource) {
        await current.add(source);
      } else {
        // if for some reason audioSource is not concatenating, set a new one
        final playlist = ja.ConcatenatingAudioSource(children: [source]);
        await _player.setAudioSource(playlist);
      }

      _playlistSongs.add(song);
      notifyListeners();
      return song;
    } catch (e) {
      return null;
    }
  }
}

class PlaybackManagerProvider extends InheritedNotifier<PlaybackManager> {
  const PlaybackManagerProvider({Key? key, required PlaybackManager notifier, required Widget child}) : super(key: key, notifier: notifier, child: child);

  static PlaybackManager of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PlaybackManagerProvider>();
    assert(provider != null, 'No PlaybackManagerProvider found in context');
    return provider!.notifier!;
  }
}
