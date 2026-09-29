import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'hardware.dart';

/// Window mode, exact on iPhone Duo and size or fold based elsewhere.
enum DuoMode {
  closedPortrait,
  closedLandscape,
  openLandscape,
  openPortrait,
  splitView,
  tablet,
  desktop,
}

/// Fold posture, on iOS it needs a DuoHardwareScope.
enum DuoPosture { unknown, closed, flat, book, tabletop }

/// Window snapshot from MediaQuery and the hinge, read it with context.duo.
@immutable
class DuoData {
  const DuoData({
    required this.size,
    required this.platform,
    this.padding = EdgeInsets.zero,
    this.displayFeatures = const [],
    this.devicePixelRatio = 3,
    this.isWeb = false,
    this.expandedWidth = 600,
    this.expandedHeight = 480,
    this.hardware = DuoHardware.none,
  });

  factory DuoData.of(BuildContext context) {
    final scope = DuoScope.maybeOf(context);
    return DuoData(
      size: MediaQuery.sizeOf(context),
      padding: MediaQuery.paddingOf(context),
      displayFeatures: MediaQuery.displayFeaturesOf(context),
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      platform: scope?.platform ?? defaultTargetPlatform,
      isWeb: scope?.platform == null && kIsWeb,
      expandedWidth: scope?.expandedWidth ?? 600,
      expandedHeight: scope?.expandedHeight ?? 480,
      hardware: DuoHardware.of(context),
    );
  }

  static const outerScreen = Size(466, 678);

  // drawn @3x then downsampled onto the 1878x2670 panel
  static const innerScreen = Size(669, 951);

  final Size size;

  final EdgeInsets padding;

  final List<DisplayFeature> displayFeatures;
  final double devicePixelRatio;
  final TargetPlatform platform;
  final bool isWeb;

  final double expandedWidth;
  final double expandedHeight;

  /// Angle here only refreshes with the layout, use DuoHardware.angleOf.
  final DuoHardware hardware;

  DuoMode get mode => _duoMode ?? _otherMode;

  bool get isIphoneDuo => _duoMode != null;

  bool get isOpen => switch (mode) {
    DuoMode.openLandscape || DuoMode.openPortrait || DuoMode.splitView => true,
    _ => false,
  };

  bool get isClosed => switch (mode) {
    DuoMode.closedPortrait || DuoMode.closedLandscape => true,
    _ => false,
  };

  bool get isSplit => mode == DuoMode.splitView;

  bool get isPortrait => size.height >= size.width;

  /// Room for two panes, drive layout off this not mode.
  bool get isExpanded =>
      size.width >= expandedWidth && size.height >= expandedHeight;

  int get columns => isExpanded ? 2 : 1;

  EdgeInsets get safe => padding;

  EdgeInsets get symmetricSafe => EdgeInsets.symmetric(
    horizontal: math.max(padding.left, padding.right),
    vertical: math.max(padding.top, padding.bottom),
  );

  double get margin => size.width < 600 ? 16 : 24;

  /// Window coords, zero thick when flat. On the Duo its the hinge's region
  /// (40 pt while half open) or else the physical center line.
  Rect? get fold {
    final feature = _foldFeature;
    if (feature != null) return feature.bounds;
    final region = _hingeFold;
    if (region != null) {
      if (_hingeSeparating) return region.frame;
      final r = region.frame, c = r.center;
      return r.height >= r.width
          ? Rect.fromLTWH(c.dx, r.top, 0, r.height)
          : Rect.fromLTWH(r.left, c.dy, r.width, 0);
    }
    final exact = _duoSize != null;
    return switch (_duoMode) {
      DuoMode.openLandscape => Rect.fromLTWH(
        exact ? 475.5 : size.width / 2,
        0,
        0,
        size.height,
      ),
      DuoMode.openPortrait => Rect.fromLTWH(
        0,
        exact ? 475.5 : size.height / 2,
        size.width,
        0,
      ),
      _ => null,
    };
  }

  /// Active cameras in window coords, from the hinge data.
  List<Rect> get cameras => [
    for (final c in hardware.cameras)
      if (c.isActive && !c.frame.isEmpty) c.frame,
  ];

  /// Insets clearing each active camera from its nearest window edge.
  EdgeInsets get cameraInsets {
    double l = 0, t = 0, r = 0, b = 0;
    for (final c in cameras) {
      final gaps = [
        c.left,
        c.top,
        size.width - c.right,
        size.height - c.bottom,
      ];
      switch (gaps.indexOf(gaps.reduce(math.min))) {
        case 0:
          l = math.max(l, c.right);
        case 1:
          t = math.max(t, c.bottom);
        case 2:
          r = math.max(r, size.width - c.left);
        default:
          b = math.max(b, size.height - c.top);
      }
    }
    return EdgeInsets.fromLTRB(
      l.clamp(0, size.width),
      t.clamp(0, size.height),
      r.clamp(0, size.width),
      b.clamp(0, size.height),
    );
  }

  Axis? get foldDirection {
    final f = fold;
    if (f == null) return null;
    return f.height >= f.width ? Axis.vertical : Axis.horizontal;
  }

  bool get isSeparating {
    final f = _foldFeature;
    if (f == null) return _hingeSeparating;
    return f.type == DisplayFeatureType.hinge ||
        f.bounds.shortestSide > 0 ||
        f.state == DisplayFeatureState.postureHalfOpened;
  }

  DuoPosture get posture {
    final f = _foldFeature;
    if (f != null) {
      return switch (f.state) {
        DisplayFeatureState.postureHalfOpened =>
          f.bounds.height >= f.bounds.width
              ? DuoPosture.book
              : DuoPosture.tabletop,
        DisplayFeatureState.postureFlat => DuoPosture.flat,
        _ => DuoPosture.unknown,
      };
    }
    return switch (hardware.status) {
      DuoHingeStatus.closed => DuoPosture.closed,
      DuoHingeStatus.fullyOpen => DuoPosture.flat,
      DuoHingeStatus.partiallyOpen =>
        foldDirection == Axis.horizontal
            ? DuoPosture.tabletop
            : DuoPosture.book,
      DuoHingeStatus.unknown =>
        isClosed && isIphoneDuo ? DuoPosture.closed : DuoPosture.unknown,
    };
  }

  bool get prefersRail {
    final duo = _duoMode;
    if (duo != null) return duo != DuoMode.openPortrait;
    return size.width >= expandedWidth;
  }

  /// Kept even on a vertical fold so no tile sits on the crease.
  int gridColumns(double minItemWidth) {
    var n = math.max(
      1,
      ((size.width - padding.horizontal) / minItemWidth).floor(),
    );
    if (n > 1 && n.isOdd && foldDirection == Axis.vertical) n -= 1;
    return n;
  }

  DisplayFeature? get _foldFeature {
    for (final f in displayFeatures) {
      if (f.type == DisplayFeatureType.fold ||
          f.type == DisplayFeatureType.hinge) {
        return f;
      }
    }
    return null;
  }

  // none on the cover screen, where the view has no fold
  DuoRegion? get _hingeFold => hardware.status == DuoHingeStatus.closed
      ? null
      : hardware.folds.firstOrNull;

  // posture decides, isActive lags the hinge by up to a second
  bool get _hingeSeparating {
    final r = _hingeFold;
    if (r == null || r.frame.isEmpty) return false;
    return switch (hardware.status) {
      DuoHingeStatus.partiallyOpen => true,
      DuoHingeStatus.unknown => r.isActive,
      _ => false,
    };
  }

  DuoMode? get _duoMode => _duoSize ?? _duoHinge;

  // the hinge says Duo even when an older SDK letterboxes the window
  DuoMode? get _duoHinge {
    if (platform != TargetPlatform.iOS || isWeb || !hardware.hasHinge) {
      return null;
    }
    final landscape = size.width > size.height;
    return switch (hardware.status) {
      DuoHingeStatus.closed =>
        landscape ? DuoMode.closedLandscape : DuoMode.closedPortrait,
      DuoHingeStatus.unknown => null,
      _ when !isExpanded => DuoMode.splitView,
      _ => landscape ? DuoMode.openLandscape : DuoMode.openPortrait,
    };
  }

  // 3x iOS only so iPads and android dont false positive
  DuoMode? get _duoSize {
    if (platform != TargetPlatform.iOS ||
        isWeb ||
        (devicePixelRatio - 3).abs() > .01) {
      return null;
    }
    final w = size.width, h = size.height;
    bool near(double a, double b) => (a - b).abs() <= 1;
    const outerShort = 466.0,
        outerLong = 678.0,
        innerShort = 669.0,
        innerLong = 951.0;
    if (near(h, outerLong) && w <= outerShort + 1) {
      return DuoMode.closedPortrait;
    }
    if (near(w, outerLong) && h <= outerShort + 1) {
      return DuoMode.closedLandscape;
    }
    if (near(h, innerShort) && w <= innerLong + 1) {
      return w > innerLong * .75 ? DuoMode.openLandscape : DuoMode.splitView;
    }
    if (near(h, innerLong) && w <= innerShort + 1) {
      return w > innerShort * .75 ? DuoMode.openPortrait : DuoMode.splitView;
    }
    if (near(w, innerShort) && h <= innerLong * .75) return DuoMode.splitView;
    return null;
  }

  DuoMode get _otherMode {
    final landscape = size.width > size.height;
    if (_foldFeature != null) {
      return landscape ? DuoMode.openLandscape : DuoMode.openPortrait;
    }
    if (!isExpanded) {
      return landscape ? DuoMode.closedLandscape : DuoMode.closedPortrait;
    }
    final desktop =
        isWeb ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux;
    return desktop ? DuoMode.desktop : DuoMode.tablet;
  }

  @override
  String toString() {
    String n(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
    final p = padding;
    final f = fold;
    final at = foldDirection == Axis.vertical ? f?.center.dx : f?.center.dy;
    return '${mode.name} ${n(size.width)}×${n(size.height)}'
        '${isIphoneDuo ? ' · iPhone Duo' : ''}'
        ' · safe L${n(p.left)} T${n(p.top)} R${n(p.right)} B${n(p.bottom)}'
        ' · $columns col'
        '${f == null ? '' : ' · fold ${foldDirection!.name} @${n(at!)}'}'
        '${posture == DuoPosture.unknown ? '' : ' · ${posture.name}'}'
        '${hardware.angle == null ? '' : ' ${hardware.angle!.round()}°'}';
  }
}

/// Optional thresholds and platform override.
class DuoScope extends InheritedWidget {
  const DuoScope({
    super.key,
    this.expandedWidth = 600,
    this.expandedHeight = 480,
    this.platform,
    required super.child,
  });

  final double expandedWidth;
  final double expandedHeight;
  final TargetPlatform? platform;

  static DuoScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DuoScope>();

  @override
  bool updateShouldNotify(DuoScope oldWidget) =>
      expandedWidth != oldWidget.expandedWidth ||
      expandedHeight != oldWidget.expandedHeight ||
      platform != oldWidget.platform;
}

extension DuoContext on BuildContext {
  /// Rebuilds on fold, rotate and split.
  DuoData get duo => DuoData.of(this);
}

class DuoBuilder extends StatelessWidget {
  const DuoBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, DuoData duo) builder;

  @override
  Widget build(BuildContext context) => builder(context, context.duo);
}
