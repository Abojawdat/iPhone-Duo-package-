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
      // blur plus a 1 px light edge, the usual Liquid Glass stand in
      glass = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color:
                  tint ??
                  (dark ? const Color(0x1FFFFFFF) : const Color(0x8CFFFFFF)),
              borderRadius: radius,
              border: Border.all(
                color: dark ? const Color(0x24FFFFFF) : const Color(0x14000000),
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
