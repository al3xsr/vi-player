import 'dart:typed_data';

class TrackModel {
  final int? id;
  final String path;
  final String title;
  final String? artist;
  final String? album;
  final int? duration;
  final Uint8List? image;   // ✅ image in memory, not db
  final bool isFavorite;

  TrackModel({
    this.id,
    required this.path,
    required this.title,
    this.artist,
    this.album,
    this.duration,
    this.image,         
    this.isFavorite = false    
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'path': path,
    'title': title,
    'artist': artist,
    'album': album,
    'duration': duration,
    'is_favorite': isFavorite ? 1 : 0
  };

  factory TrackModel.fromMap(Map<String, dynamic> map) => TrackModel(
    id: map['id'],
    path: map['path'],
    title: map['title'],
    artist: map['artist'],
    album: map['album'],
    duration: map['duration'],
    isFavorite: map['is_favorite'] == 1,
    // image starts like null, it loaded after
  );

TrackModel copyWith({bool? isFavorite, Uint8List? image}) {
    return TrackModel(
      id: id,
      path: path,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }


}


