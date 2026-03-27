import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImageType { network, asset, svgNetwork, svgAsset }

class AppImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final ImageType imageType;
  final Color? color;

  const AppImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.imageType = ImageType.network,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (imageType) {
    /// 🔹 Network Image (PNG/JPG)
      case ImageType.network:
        return Image.network(
          image,
          height: height,
          width: width,
          fit: fit,
          color: color,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported);
          },
        );

    /// 🔹 Asset Image (PNG/JPG)
      case ImageType.asset:
        return Image.asset(
          image,
          height: height,
          width: width,
          fit: fit,
          color: color,
        );

    /// 🔹 SVG Asset
      case ImageType.svgAsset:
        return SvgPicture.asset(
          image,
          height: height,
          width: width,
          fit: fit,
          colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          placeholderBuilder: (context) =>
          const Center(child: CircularProgressIndicator()),
        );

    /// 🔹 SVG Network
      case ImageType.svgNetwork:
        return SvgPicture.network(
          image,
          height: height,
          width: width,
          fit: fit,
          colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          placeholderBuilder: (context) =>
          const Center(child: CircularProgressIndicator()),
        );
    }
  }
}
