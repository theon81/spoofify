import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum LoopMode { off, one, all }

/// audio play mode
class PlaybackSettings extends ChangeNotifier {
  bool _shuffle = false;
  LoopMode _loopMode = LoopMode.off;
  String? _currentSongId;

  bool get shuffle => _shuffle;
  LoopMode get loopMode => _loopMode;
  String? get currentSongId => _currentSongId;

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void cycleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.off;
        break;
    }
    notifyListeners();
  }

  void setCurrentSong(String? id) {
    _currentSongId = id;
    notifyListeners();
  }
}

/// InheritedNotifier wrapper so widgets can access PlaybackSettings without
/// adding external dependencies. Usage: `PlaybackSettingsProvider.of(context)`.
class PlaybackSettingsProvider extends InheritedNotifier<PlaybackSettings> {
  const PlaybackSettingsProvider({super.key, required PlaybackSettings notifier, required super.child}) : super(notifier: notifier);

  static PlaybackSettings of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PlaybackSettingsProvider>();
    assert(provider != null, 'No PlaybackSettingsProvider found in context');
    return provider!.notifier!;
  }
}
