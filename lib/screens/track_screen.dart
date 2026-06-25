import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vi/services/player_service.dart';
import 'package:vi/widgets/track_image.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  StreamSubscription? _errorSubscription;

  @override
  void initState() {
    super.initState();

    _errorSubscription = PlayerService()
      .player
      .playbackEventStream
      .listen(
        (_) {},
        onError: (error, stackTrace) {
          debugPrint('[TrackScreen] playback error: $error');
          if (!mounted) return; 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error To Play'),
            ),
          );
        },
      );
  }

  @override
  void dispose() {
    _errorSubscription?.cancel(); 
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerService().player;

    return Scaffold(
      appBar: AppBar(title: const Text('Vi Player')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // — Metadata TRack actually
            StreamBuilder<SequenceState?>(
              stream: player.sequenceStateStream,
              builder: (context, snapshot) {
                final track = PlayerService().currentTrack;
                return Column(
                  children: [
                    TrackImage(image: track?.image, size: 270, borderRadius: 16),
                    const SizedBox(height: 24),
                    Text(
                      track?.title ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      track?.artist ?? 'Unknown',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = player.duration ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      value: position.inSeconds
                        .toDouble()
                        .clamp(0, duration.inSeconds.toDouble()),
                      max: duration.inSeconds.toDouble() > 0
                        ? duration.inSeconds.toDouble() : 1,
                      onChanged: (v) =>
                        PlayerService().seekTo(Duration(seconds: v.toInt())),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_format(position)),
                        Text(_format(duration)),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () => PlayerService().previous(),
                ),
                StreamBuilder<bool>(
                  stream: player.playingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return IconButton(
                      iconSize: 72,
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                      ),
                      onPressed: () => PlayerService().togglePlay(),
                    );
                  },
                ),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => PlayerService().next(),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}