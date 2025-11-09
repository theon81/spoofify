import 'package:flutter/material.dart';

enum LoopMode { off, one, all }

/// audio play mode
class PlaybackSettings extends ChangeNotifier {
  bool _shuffle = false;
  LoopMode _loopMode = LoopMode.off;
  String? _currentSongId;
  String _languageCode = 'en';

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

  String get languageCode => _languageCode;

  void setLanguage(String code) {
    if (code != 'en' && code != 'vi') return;
    _languageCode = code;
    notifyListeners();
  }

  void toggleLanguage() {
    _languageCode = (_languageCode == 'en') ? 'vi' : 'en';
    notifyListeners();
  }

  // localization mapping
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'your_music': 'Your Music',
      'your_playlists': 'Your Playlists',
      'info_settings': 'Info / Settings',
      'playlists_coming': 'Playlists (coming soon)',
      'language': 'Language',
      'author': 'Author',
      'version': 'Version 1.0.0+1',
      'songs': 'Songs',
      'playlists_tab': 'Playlists',
      'info_tab': 'Info',
      'not_playing': 'Not playing',
      'now_playing': 'Now Playing',
      'import': 'Import',
    },
    'vi': {
      'your_music': 'Thư viện',
      'your_playlists': 'Danh sách phát',
      'info_settings': 'Thông tin / Cài đặt',
      'playlists_coming': 'Danh sách phát (đang phát triển)',
      'language': 'Ngôn ngữ',
      'author': 'Tác giả',
      'version': 'Phiên bản 1.0.0+1',
      'songs': 'Bài hát',
      'playlists_tab': 'Danh sách phát',
      'info_tab': 'Thông tin',
      'not_playing': 'Không có bài nào',
      'now_playing': 'Đang phát',
      'import': 'Nhập bài hát',
    },
  };

  String t(String key) => _strings[_languageCode]?[key] ?? key;
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
