class Song {
  final String id;
  final String title;
  final String artist;
  final String assetPath;
  final String? coverPath;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.assetPath,
    this.coverPath,
  });

  @override
  String toString() => '$title — $artist';
}
