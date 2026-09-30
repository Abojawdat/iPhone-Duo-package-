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
      // blur, a sheen on top, a 1 px edge and a soft shadow so it reads as
      // glass even over a plain background
      glass = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: dark ? const Color(0x66000000) : const Color(0x24000000),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.white.withValues(alpha: dark ? .16 : .5),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      tint ??
                      (dark
                          ? const Color(0x24FFFFFF)
                          : const Color(0xA6FFFFFF)),
                  borderRadius: radius,
                  border: Border.all(
                    color: dark
                        ? const Color(0x33FFFFFF)
                        : const Color(0x1A000000),
                  ),
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
