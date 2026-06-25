import 'dart:typed_data';
import 'package:flutter/material.dart';

class TrackImage extends StatelessWidget {
  final Uint8List? image;
  final double size;
  final double borderRadius;

  const TrackImage({
    super.key,
    required this.image,
    this.size = 48,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) return _placeholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.memory(
        image!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.music_note,
        size: size * 0.5,
        color: Colors.grey[600],
      ),
    );
  }
}