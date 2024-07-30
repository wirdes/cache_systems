import 'package:cache_systems/cache_systems.dart';
import 'package:flutter/material.dart';

/// A widget that displays an image from a URL with caching
class CachedImage extends StatefulWidget {
  /// The URL of the image
  final Uri url;

  /// The widget to display while the image is loading
  final Widget placeholder;

  /// The widget to display if the image fails to load
  final Widget errorWidget;

  /// The fit of the image
  final BoxFit fit;

  /// The width of the image
  final double? width;

  /// The height of the image
  final double? height;

  const CachedImage({
    super.key,
    required this.url,
    this.placeholder = const SizedBox.shrink(),
    this.errorWidget = const SizedBox.shrink(),
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CacheSystem().getImageProvider(widget.url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder;
        } else if (snapshot.hasError) {
          return widget.errorWidget;
        } else {
          final imageProvider = snapshot.data as ImageProvider;
          return Image(
            image: imageProvider,
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
          );
        }
      },
    );
  }
}
