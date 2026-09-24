import 'package:flutter/widgets.dart';

/// How DuoMedia fits off ratio media.
enum DuoMediaFit { contain, cover, smart }

/// Fits video and images, smart crops only when it hides at most maxCrop.
/// Child keeps its real size, no scaling.
class DuoMedia extends StatelessWidget {
  const DuoMedia({
    super.key,
    required this.aspectRatio,
    required this.child,
    this.fit = DuoMediaFit.smart,
    this.maxCrop = .15,
    this.background = const Color(0xFF000000),
  });

  final double aspectRatio;
  final Widget child;
  final DuoMediaFit fit;
  final double maxCrop;
  final Color background;

  static Size fitSize(
    double aspectRatio,
    Size box, {
    DuoMediaFit fit = DuoMediaFit.smart,
    double maxCrop = .15,
  }) {
    final wider = box.width / box.height > aspectRatio;
    final contain = wider
        ? Size(box.height * aspectRatio, box.height)
        : Size(box.width, box.width / aspectRatio);
    final cover = wider
        ? Size(box.width, box.width / aspectRatio)
        : Size(box.height * aspectRatio, box.height);
    return switch (fit) {
      DuoMediaFit.contain => contain,
      DuoMediaFit.cover => cover,
      DuoMediaFit.smart =>
        1 - (box.width * box.height) / (cover.width * cover.height) <= maxCrop
            ? cover
            : contain,
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          return AspectRatio(aspectRatio: aspectRatio, child: child);
        }
        final size = fitSize(
          aspectRatio,
          constraints.biggest,
          fit: fit,
          maxCrop: maxCrop,
        );
        return ColoredBox(
          color: background,
          child: ClipRect(
            child: OverflowBox(
              minWidth: size.width,
              maxWidth: size.width,
              minHeight: size.height,
              maxHeight: size.height,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
