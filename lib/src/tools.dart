import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/widgets.dart';

import 'duo_data.dart';
import 'window.dart';

/// Pose for DuoSimulator. Duo insets are estimates (59 island strip, 21 home
/// bar) since Apple hasnt published them.
@immutable
class DuoPose {
  const DuoPose(
    this.name,
    this.size, {
    this.padding = EdgeInsets.zero,
    this.displayFeatures = const [],
    this.platform = TargetPlatform.iOS,
    this.devicePixelRatio = 3,
  });

  final String name;
  final Size size;
  final EdgeInsets padding;
  final List<DisplayFeature> displayFeatures;
  final TargetPlatform platform;
  final double devicePixelRatio;

  static const closedPortrait = DuoPose(
    'closedPortrait',
    Size(466, 678),
    padding: EdgeInsets.only(right: 59, bottom: 21),
  );

  static const closedLandscape = DuoPose(
    'closedLandscape',
    Size(678, 466),
    padding: EdgeInsets.only(top: 59, bottom: 21),
  );

  static const openLandscape = DuoPose(
    'openLandscape',
    Size(951, 669),
    padding: EdgeInsets.only(right: 59, bottom: 21),
  );

  static const openPortrait = DuoPose(
    'openPortrait',
    Size(669, 951),
    padding: EdgeInsets.only(top: 59, bottom: 21),
  );

  static const splitLeft = DuoPose(
    'splitLeft',
    Size(475.5, 669),
    padding: EdgeInsets.only(bottom: 21),
  );

  static const splitRight = DuoPose(
    'splitRight',
    Size(475.5, 669),
    padding: EdgeInsets.only(right: 59, bottom: 21),
  );

  static const foldableBook = DuoPose(
    'foldableBook',
    Size(840, 700),
    platform: TargetPlatform.android,
    devicePixelRatio: 2.625,
    displayFeatures: [
      DisplayFeature(
        bounds: Rect.fromLTWH(420, 0, 0, 700),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureHalfOpened,
      ),
    ],
  );

  static const foldableTabletop = DuoPose(
    'foldableTabletop',
    Size(700, 840),
    platform: TargetPlatform.android,
    devicePixelRatio: 2.625,
    displayFeatures: [
      DisplayFeature(
        bounds: Rect.fromLTWH(0, 420, 700, 0),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureHalfOpened,
      ),
    ],
  );

  static const iPhone = DuoPose(
    'iPhone',
    Size(402, 874),
    padding: EdgeInsets.only(top: 62, bottom: 34),
  );

  static const iPad = DuoPose(
    'iPad',
    Size(1032, 1376),
    devicePixelRatio: 2,
    padding: EdgeInsets.only(top: 24, bottom: 20),
  );

  static const values = [
    closedPortrait,
    closedLandscape,
    openLandscape,
    openPortrait,
    splitLeft,
    splitRight,
    foldableBook,
    foldableTabletop,
    iPhone,
    iPad,
  ];

  MediaQueryData apply(MediaQueryData base) => base.copyWith(
    size: size,
    padding: padding,
    viewPadding: padding,
    devicePixelRatio: devicePixelRatio,
    displayFeatures: displayFeatures,
  );

  @override
  String toString() => 'DuoPose.$name';
}

/// Runs child as pose on any device or in tests, scaled to fit. Put a whole
/// MaterialApp inside so dialogs stay on the fake screen.
class DuoSimulator extends StatefulWidget {
  const DuoSimulator({
    super.key,
    required this.pose,
    required this.child,
    this.showGuides = false,
  });

  final DuoPose pose;
  final Widget child;

  final bool showGuides;

  @override
  State<DuoSimulator> createState() => _DuoSimulatorState();
}

class _DuoSimulatorState extends State<DuoSimulator> {
  final _window = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final pose = widget.pose;
    final scope = DuoScope.maybeOf(context);
    final media = pose.apply(
      MediaQuery.maybeOf(context) ?? const MediaQueryData(),
    );
    return FittedBox(
      child: SizedBox.fromSize(
        key: _window,
        size: pose.size,
        child: ClipRect(
          child: MediaQuery(
            data: media,
            child: DuoScope(
              expandedWidth: scope?.expandedWidth ?? 600,
              expandedHeight: scope?.expandedHeight ?? 480,
              platform: pose.platform,
              child: DuoWindow(
                box: _window,
                child: Stack(
                  textDirection: TextDirection.ltr,
                  fit: StackFit.expand,
                  children: [
                    widget.child,
                    if (widget.showGuides)
                      const IgnorePointer(child: _Guides()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Guides extends StatelessWidget {
  const _Guides();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GuidesPainter(context.duo));
}

class _GuidesPainter extends CustomPainter {
  _GuidesPainter(this.duo);

  final DuoData duo;

  @override
  void paint(Canvas canvas, Size size) {
    final p = duo.padding;
    final tint = Paint()..color = const Color(0x40FF3B30);
    canvas
      ..drawRect(Rect.fromLTWH(0, 0, p.left, size.height), tint)
      ..drawRect(
        Rect.fromLTWH(size.width - p.right, 0, p.right, size.height),
        tint,
      )
      ..drawRect(Rect.fromLTWH(0, 0, size.width, p.top), tint)
      ..drawRect(
        Rect.fromLTWH(0, size.height - p.bottom, size.width, p.bottom),
        tint,
      );
    final fold = duo.fold;
    if (fold == null) return;
    final vertical = duo.foldDirection == Axis.vertical;
    canvas.drawLine(
      vertical ? fold.topCenter : fold.centerLeft,
      vertical ? fold.bottomCenter : fold.centerRight,
      Paint()
        ..color = const Color(0xCC007AFF)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_GuidesPainter old) =>
      old.duo.toString() != duo.toString();
}

/// Live DuoData readout, touch through. Gate it with kDebugMode.
class DuoDebugOverlay extends StatelessWidget {
  const DuoDebugOverlay({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final duo = context.duo;
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        Positioned(
          left: duo.padding.left + 8,
          right: duo.padding.right + 8,
          top: duo.padding.top + 4,
          child: IgnorePointer(
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xB3000000),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  child: Text(
                    duo.toString(),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
