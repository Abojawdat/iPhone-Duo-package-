import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Liquid Glass behind child: real UIGlassEffect on iOS 26+, a blurred
/// capsule elsewhere. Follows the app theme, not the system, unless
/// brightness is set. Decorative, touches go to child.
class DuoGlass extends StatelessWidget {
  const DuoGlass({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.tint,
    this.brightness,
  });

  final Widget child;
  final double borderRadius;
  final Color? tint;
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    // a dark app on a light system would get light glass otherwise
    final dark =
        (brightness ?? Theme.of(context).brightness) == Brightness.dark;
    final Widget glass;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      glass = UiKitView(
        key: ValueKey((borderRadius, tint, dark)),
        viewType: 'duo_dynamic_sizing/glass',
        creationParams: {
          'radius': borderRadius,
          'tint': tint?.toARGB32(),
          'dark': dark,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      // the glassmorphism recipe: saturated blur, a thin fill, a sheen, a
      // bright hairline and a shadow that stays outside the glass
      glass = CustomPaint(
        painter: _GlassShadow(borderRadius, dark),
        foregroundPainter: _GlassEdge(borderRadius, dark),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.compose(
              outer: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              inner: ColorFilter.matrix(_saturate(dark ? 1.6 : 1.8)),
            ),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.white.withValues(alpha: dark ? .14 : .5),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      tint ??
                      (dark
                          ? const Color(0x1AFFFFFF)
                          : const Color(0x66FFFFFF)),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Stack(
      children: [
        Positioned.fill(child: IgnorePointer(child: glass)),
        child,
      ],
    );
  }
}

List<double> _saturate(double s) {
  const r = .2126, g = .7152, b = .0722;
  final i = 1 - s;
  return [
    r * i + s, g * i, b * i, 0, 0, //
    r * i, g * i + s, b * i, 0, 0, //
    r * i, g * i, b * i + s, 0, 0, //
    0, 0, 0, 1, 0,
  ];
}

// a shadow under see-through glass would darken what shows through it
class _GlassShadow extends CustomPainter {
  const _GlassShadow(this.radius, this.dark);

  final double radius;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas
      ..save()
      ..clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect((Offset.zero & size).inflate(80))
          ..addRRect(shape),
      )
      ..drawRRect(
        shape.shift(const Offset(0, 10)),
        Paint()
          ..color = dark ? const Color(0x80000000) : const Color(0x2E000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlassShadow old) =>
      old.radius != radius || old.dark != dark;
}

// light catching the rim: bright top left, fading, bright again bottom right
class _GlassEdge extends CustomPainter {
  const _GlassEdge(this.radius, this.dark);

  final double radius;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rim = RRect.fromRectAndRadius(
      rect.deflate(.5),
      Radius.circular(radius),
    );
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0x8CFFFFFF), Color(0x14FFFFFF), Color(0x40FFFFFF)]
              : const [Color(0xF2FFFFFF), Color(0x40FFFFFF), Color(0xB3FFFFFF)],
          stops: const [0, .55, 1],
        ).createShader(rect),
    );
    // light glass on a light app needs a faint dark rim to stand apart
    if (!dark) {
      canvas.drawRRect(
        rim.inflate(.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .5
          ..color = const Color(0x1F000000),
      );
    }
  }

  @override
  bool shouldRepaint(_GlassEdge old) =>
      old.radius != radius || old.dark != dark;
}
