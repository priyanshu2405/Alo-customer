import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool isNetwork;

  const AppImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.isNetwork = true,
  });

  @override
  Widget build(BuildContext context) {
    return isNetwork
        ? Image.network(
      image,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.image_not_supported);
      },
    )
        : Image.asset(
      image,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
