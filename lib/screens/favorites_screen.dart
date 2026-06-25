import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:vi/models/track_model.dart';
import 'package:vi/screens/track_screen.dart';
import 'package:vi/services/db_service.dart';
import 'dart:io';

import 'package:vi/services/player_service.dart';
import 'package:vi/widgets/track_image.dart';


class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<TrackModel> _favorites = [];
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final saved = await _db.getFavorites();

    List<TrackModel> withImages = [];
    for (final track in saved) {
      final file = File(track.path);
      if (!await file.exists()) continue;
      final metadata = readMetadata(file, getImage: true);
      withImages.add(track.copyWith(
        image: metadata.pictures.isNotEmpty
          ? metadata.pictures.first.bytes
          : null,
      ));
    }

    setState(() => _favorites = withImages);
  }

  @override
  Widget build(BuildContext context) {
    if (_favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('You do not have any favorites yet',
              style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final track = _favorites[index];
        return ListTile(
          leading: track.image != null
            ? TrackImage(image: track.image!, size: 40, borderRadius: 16)
            : const Icon(Icons.music_note),
          title: Text(track.title),
          subtitle: Text(track.artist ?? 'Unknown'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () async {
              await _db.toggleFavorite(track);
              setState(() => _favorites.removeAt(index)); // remove of favorites
            },
          ),
          onTap: () {
            PlayerService().loadQueue(tracks: _favorites, startIndex: index);
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TrackScreen()));
          },
        );
      },
    );
  }
}