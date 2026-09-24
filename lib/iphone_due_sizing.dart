import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Scales sizes from an iPhone design frame to the current screen.
///
/// Wrap your app once:
/// ```dart
/// IphoneSizing(child: MaterialApp(...))
/// ```
/// then use `16.w`, `24.h`, `12.r`, `14.sp` anywhere below it.
class IphoneSizing extends StatelessWidget {
  const IphoneSizing({
    super.key,
    this.designSize = iphone15,
    required this.child,
  });

  /// iPhone 15 / 15 Pro / 16 logical size.
  static const iphone15 = Size(393, 852);

  /// Frame the design was drawn at.
  final Size designSize;
  final Widget child;

  static double _scaleW = 1, _scaleH = 1, _textScale = 1;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    _scaleW = mq.size.width / designSize.width;
    _scaleH = mq.size.height / designSize.height;
    _textScale = mq.textScaler.scale(1);
    return child;
  }
}

extension IphoneSizingNum on num {
  /// Scaled by screen width.
  double get w => this * IphoneSizing._scaleW;

  /// Scaled by screen height.
  double get h => this * IphoneSizing._scaleH;

  /// Scaled by the smaller axis, for radii and square things.
  double get r => this * math.min(IphoneSizing._scaleW, IphoneSizing._scaleH);

  /// Font size scaled by width, respecting the user's text-size setting.
  double get sp => w * IphoneSizing._textScale;
}
