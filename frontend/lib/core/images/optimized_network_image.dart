import 'package:flutter/material.dart';
import 'package:frontend/core/images/optimized_image_url.dart';

class OptimizedNetworkImage extends StatelessWidget {
  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.cacheWidth,
    this.cacheHeight,
    this.fit,
    this.alignment = Alignment.center,
    this.quality = 72,
    this.filterQuality = FilterQuality.medium,
    this.gaplessPlayback = false,
    this.excludeFromSemantics = true,
    this.errorBuilder,
    this.loadingBuilder,
  });

  final String imageUrl;
  final int cacheWidth;
  final int? cacheHeight;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final int quality;
  final FilterQuality filterQuality;
  final bool gaplessPlayback;
  final bool excludeFromSemantics;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Image.network(
        optimizedImageUrl(imageUrl, width: cacheWidth, quality: quality),
        fit: fit,
        alignment: alignment,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        excludeFromSemantics: excludeFromSemantics,
        filterQuality: filterQuality,
        gaplessPlayback: gaplessPlayback,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
      ),
    );
  }
}
