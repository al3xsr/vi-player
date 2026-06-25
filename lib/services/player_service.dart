import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:vi/models/track_model.dart';

class PlayerService {
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;
  PlayerService._internal();

  final AudioPlayer player = AudioPlayer();
  List<TrackModel> _queue = [];

  TrackModel? get currentTrack {
    final index = player.currentIndex;
    if (index == null || index >= _queue.length) return null;
    return _queue[index];
  }

  Future<bool> loadQueue({
    required List<TrackModel> tracks,
    required int startIndex,
  }) async {
    _queue = tracks;

    //  dynamic timeout
    final track = tracks[startIndex];
    final timeout = track.path.endsWith('.flac')
      ? const Duration(seconds: 20)
      : const Duration(seconds: 10);

    try {
      final sources = ConcatenatingAudioSource(
        children: tracks.map((t) => AudioSource.file(
          t.path,
          tag: MediaItem(
            id: t.path,
            title: t.title,
            artist: t.artist ?? 'Desconocido',
          ),
        )).toList(),
      );

      await player
        .setAudioSource(sources, initialIndex: startIndex)
        .timeout(
          timeout,
          onTimeout: () => throw Exception(
            'Timeout cargando: ${track.title}',
          ),
        );

      await player.play();
      return true;

    } on PlayerException catch (e) {
      debugPrint('[PlayerService] PlayerException: ${e.message}');
      return false;
    } on PlayerInterruptedException catch (e) {
      debugPrint('[PlayerService] Interrupted: ${e.message}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('[PlayerService] Error: $e');
      debugPrint('[PlayerService] StackTrace: $stackTrace');
      // haere can be FirebaseCrashlytics.instance.recordError(e, stackTrace)
      return false;
    }
  }

  Future<void> togglePlay() async =>
    player.playing ? await player.pause() : await player.play();
  Future<void> next()     async => await player.seekToNext();
  Future<void> previous() async => await player.seekToPrevious();
  Future<void> seekTo(Duration position) async => await player.seek(position);

  void dispose() => player.dispose();
}