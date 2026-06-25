import 'dart:io';
import 'dart:typed_data';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vi/models/track_model.dart';
import 'package:vi/screens/track_screen.dart';
import 'package:vi/services/db_service.dart';
import 'package:vi/services/player_service.dart';
import 'package:vi/widgets/track_image.dart';

class TrackList extends StatefulWidget {
  const TrackList({super.key});

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  List<TrackModel> _tracks = [];
  int? _loadingIndex;        // index of track loading
  bool _isLoadingList = false;
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadSavedTracks();
  }

  Future<void> _loadSavedTracks() async {
    setState(() => _isLoadingList = true);

    final saved = await _db.getAllTracks();
    List<TrackModel> withImages = [];

    for (final track in saved) {
      final file = File(track.path);
      if (!await file.exists()) continue;

      final metadata = readMetadata(file, getImage: true);
      Uint8List? validImage;
      if (metadata.pictures.isNotEmpty) {
        final bytes = metadata.pictures.first.bytes;
        if (bytes.length > 100) validImage = bytes;
      }

      withImages.add(track.copyWith(image: validImage));
    }

    if (!mounted) return; 
    setState(() {
      _tracks = withImages;
      _isLoadingList = false;
    });
  }

  Future<void> pickAudioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'flac', 'm4a'],
      allowMultiple: true,
    );

    if (result == null) return;
    if (!mounted) return; 

    setState(() => _isLoadingList = true);

    List<TrackModel> newTracks = [];

    for (final file in result.files) {
      if (file.path == null) continue;

      final metadata = readMetadata(File(file.path!), getImage: true);

      Uint8List? validImage;
      if (metadata.pictures.isNotEmpty) {
        final bytes = metadata.pictures.first.bytes;
        if (bytes.length > 100) validImage = bytes;
      }

      newTracks.add(TrackModel(
        path: file.path!,
        title: metadata.title ?? file.name,
        artist: metadata.artist,
        album: metadata.album,
        duration: metadata.duration?.inMilliseconds,
        image: validImage,
      ));
    }

    await _db.insertTracks(newTracks);

    if (!mounted) return; 
    setState(() {
      _tracks = [..._tracks, ...newTracks];
      _isLoadingList = false;
    });
  }

  Future<void> _playTrack(int index) async {
    final track = _tracks[index];

    // verify that file exists
    if (!await File(track.path).exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          content: Text('File Not founded: ${track.title}'),
        ),
      );
      return;
    }

    // spinner only for the track
    setState(() => _loadingIndex = index);

    final success = await PlayerService().loadQueue(
      tracks: _tracks,
      startIndex: index,
    );

    if (!mounted) return; 
    setState(() => _loadingIndex = null);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TrackScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No se puede reproducir "${track.title}"',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(int index) async {
    final track = _tracks[index];
    await _db.toggleFavorite(track);

    if (!mounted) return;
    setState(() {
      _tracks[index] = track.copyWith(isFavorite: !track.isFavorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        ElevatedButton(
          onPressed: pickAudioFiles,
          child: const Text('Add Tracks'),
        ),

        // spinner List
        if (_isLoadingList) const LinearProgressIndicator(),

        if (_tracks.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                final isLoading = _loadingIndex == index; 

                return ListTile(
                  leading: TrackImage(image: track.image, size: 48),
                  title: Text(track.title),
                  subtitle: Text(track.artist ?? 'Unknown'),
                  trailing: isLoading
                    // spinner only track loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(
                          track.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                          color: track.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => _toggleFavorite(index),
                      ),
                  onTap: isLoading ? null : () => _playTrack(index), // no touch if is loading...
                );
              },
            ),
          ),

      ],
    );
  }
}