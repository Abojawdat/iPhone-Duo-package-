import 'dart:async';
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Hinge state, Apple's UIHingeStatus.
enum DuoHingeStatus { unknown, closed, partiallyOpen, fullyOpen }

/// iOS size class.
enum DuoSizeClass { unspecified, compact, regular }

/// Physical side the system puts its vertical bar on, none where it keeps
/// bars horizontal.
enum DuoBarEdge { none, left, right }

/// What DuoHardwareScope writes into MediaQuery.displayFeatures. all makes
/// dialogs and sheets split around a half open fold.
enum DuoBridge { none, cameras, all }

/// A reserved region, the fold or a camera, in window coords.
@immutable
class DuoRegion {
  const DuoRegion(
    this.frame, {
    this.margins = EdgeInsets.zero,
    this.isActive = true,
  });

  /// Includes the margins.
  final Rect frame;
  final EdgeInsets margins;
  final bool isActive;

  Rect get reserved => margins.deflateRect(frame);

  @override
  bool operator ==(Object other) =>
      other is DuoRegion &&
      other.frame == frame &&
      other.margins == margins &&
      other.isActive == isActive;

  @override
  int get hashCode => Object.hash(frame, margins, isActive);

  @override
  String toString() => 'DuoRegion($frame${isActive ? '' : ', inactive'})';
}

/// Hinge, fold and camera data from the device, read it with
/// DuoHardware.of or context.duo.hardware.
@immutable
class DuoHardware {
  const DuoHardware({
    this.supported = false,
    this.hasHinge = false,
    this.status = DuoHingeStatus.unknown,
    this.angle,
    this.folds = const [],
    this.cameras = const [],
    this.horizontalSizeClass = DuoSizeClass.unspecified,
    this.verticalSizeClass = DuoSizeClass.unspecified,
    this.barEdge = DuoBarEdge.none,
  });

  /// Nothing known, every platform without the native side.
  static const none = DuoHardware();

  /// Parses the platform channel map, junk becomes none.
  factory DuoHardware.fromMap(Map<Object?, Object?> map) {
    T pick<T>(List<T> values, Object? i) =>
        i is int && i >= 0 && i < values.length ? values[i] : values.first;
    double? number(Object? v) => v is num && v.isFinite ? v.toDouble() : null;
    final folds = <DuoRegion>[], cameras = <DuoRegion>[];
    final regions = map['regions'];
    if (regions is List) {
      for (final r in regions) {
        if (r is! Map) continue;
        final x = number(r['x']), y = number(r['y']);
        final w = number(r['w']), h = number(r['h']);
        if (x == null || y == null || w == null || h == null) continue;
        if (w < 0 || h < 0) continue;
        final region = DuoRegion(
          Rect.fromLTWH(x, y, w, h),
          margins: EdgeInsets.fromLTRB(
            number(r['ml']) ?? 0,
            number(r['mt']) ?? 0,
            number(r['mr']) ?? 0,
            number(r['mb']) ?? 0,
          ),
          isActive: r['active'] != false,
        );
        (r['kind'] == 'occlusion' ? cameras : folds).add(region);
      }
    }
    final angle = number(map['angle']);
    return DuoHardware(
      supported: map['supported'] == true,
      hasHinge: map['hinge'] == true,
      status: pick(DuoHingeStatus.values, map['status']),
      angle: angle?.clamp(0, 180).toDouble(),
      folds: List.unmodifiable(folds),
      cameras: List.unmodifiable(cameras),
      horizontalSizeClass: pick(DuoSizeClass.values, map['hSize']),
      verticalSizeClass: pick(DuoSizeClass.values, map['vSize']),
      barEdge: pick(DuoBarEdge.values, map['bar']),
    );
  }

  /// The OS has the hinge APIs (iOS 27.1, or an Android hinge sensor).
  final bool supported;
  final bool hasHinge;
  final DuoHingeStatus status;

  /// Degrees, 0 shut and 180 flat.
  final double? angle;

  /// Fold regions, reported even while inactive (flat).
  final List<DuoRegion> folds;

  /// Camera regions, active only while that camera is in use.
  final List<DuoRegion> cameras;
  final DuoSizeClass horizontalSizeClass;
  final DuoSizeClass verticalSizeClass;
  final DuoBarEdge barEdge;

  /// Everything but the angle, so layout skips angle ticks.
  bool sameLayout(DuoHardware other) =>
      supported == other.supported &&
      hasHinge == other.hasHinge &&
      status == other.status &&
      listEquals(folds, other.folds) &&
      listEquals(cameras, other.cameras) &&
      horizontalSizeClass == other.horizontalSizeClass &&
      verticalSizeClass == other.verticalSizeClass &&
      barEdge == other.barEdge;

  /// Display features for bridge. A fold only while half open, since its
  /// isActive lags the hinge, and never a zero thick or closed one.
  List<DisplayFeature> displayFeatures(DuoBridge bridge) {
    if (bridge == DuoBridge.none || status == DuoHingeStatus.closed) {
      return const [];
    }
    return [
      if (bridge == DuoBridge.all && status == DuoHingeStatus.partiallyOpen)
        for (final f in folds)
          if (f.isActive && !f.frame.isEmpty)
            DisplayFeature(
              bounds: f.frame,
              type: DisplayFeatureType.fold,
              state: DisplayFeatureState.postureHalfOpened,
            ),
      for (final c in cameras)
        if (c.isActive && !c.frame.isEmpty)
          DisplayFeature(
            bounds: c.frame,
            type: DisplayFeatureType.cutout,
            state: DisplayFeatureState.unknown,
          ),
    ];
  }

  /// Layout data from the nearest DuoHardwareScope, rebuilds on posture,
  /// regions, size class and bar edge but not the angle.
  static DuoHardware of(BuildContext context) =>
      InheritedModel.inheritFrom<_DuoHardwareModel>(
        context,
        aspect: _Aspect.layout,
      )?.data ??
      none;

  /// Live angle from the nearest DuoHardwareScope, rebuilds on every tick.
  static double? angleOf(BuildContext context) =>
      InheritedModel.inheritFrom<_DuoHardwareModel>(
        context,
        aspect: _Aspect.angle,
      )?.data.angle;

  static const _methods = MethodChannel('duo_dynamic_sizing');
  static final _events = const EventChannel(
    'duo_dynamic_sizing/events',
  ).receiveBroadcastStream().map(_parse);

  static DuoHardware _parse(Object? event) =>
      event is Map ? DuoHardware.fromMap(event) : none;

  static bool get _native =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// Device updates, current value first. Ends at once off iOS and Android.
  static Stream<DuoHardware> get stream async* {
    if (!_native) return;
    final Object? first;
    try {
      first = await _methods.invokeMethod<Object?>('snapshot');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
    yield _parse(first);
    yield* _events.handleError((Object _) {});
  }

  /// Per frame angle for effects, keep it out of layout.
  static Stream<double> get angleStream => stream
      .map((h) => h.angle)
      .where((a) => a != null)
      .cast<double>()
      .distinct();

  /// What the running OS exposes, for bug reports.
  static Future<String> describeNative() async {
    if (!_native) return 'No native side on this platform.';
    try {
      return await _methods.invokeMethod<String>('describe') ?? '';
    } on MissingPluginException {
      return 'Plugin not registered.';
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  @override
  bool operator ==(Object other) =>
      other is DuoHardware && sameLayout(other) && other.angle == angle;

  @override
  int get hashCode => Object.hash(
    supported,
    hasHinge,
    status,
    angle,
    Object.hashAll(folds),
    Object.hashAll(cameras),
    horizontalSizeClass,
    verticalSizeClass,
    barEdge,
  );

  @override
  String toString() =>
      'DuoHardware(${status.name}'
      '${angle == null ? '' : ' ${angle!.round()}°'}'
      '${hasHinge ? ', hinge' : ''}'
      '${folds.isEmpty ? '' : ', folds $folds'}'
      '${cameras.isEmpty ? '' : ', cameras $cameras'}'
      '${barEdge == DuoBarEdge.none ? '' : ', bar ${barEdge.name}'})';
}

/// Feeds device hinge data to everything below, put it above MaterialApp.
/// hardware pins fixed data instead, for tests.
class DuoHardwareScope extends StatefulWidget {
  const DuoHardwareScope({
    super.key,
    required this.child,
    this.bridge = DuoBridge.none,
    this.hardware,
  });

  final Widget child;
  final DuoBridge bridge;
  final DuoHardware? hardware;

  @override
  State<DuoHardwareScope> createState() => _DuoHardwareScopeState();
}

class _DuoHardwareScopeState extends State<DuoHardwareScope> {
  StreamSubscription<DuoHardware>? _sub;
  DuoHardware _live = DuoHardware.none;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(DuoHardwareScope old) {
    super.didUpdateWidget(old);
    if ((old.hardware == null) != (widget.hardware == null)) _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = widget.hardware != null
        ? null
        : DuoHardware.stream.listen((h) {
            if (mounted && h != _live) setState(() => _live = h);
          });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.hardware ?? _live;
    final child = _DuoHardwareModel(data: data, child: widget.child);
    final media = MediaQuery.maybeOf(context);
    // stands down once the engine reports features itself
    if (media == null || media.displayFeatures.isNotEmpty) return child;
    final features = data.displayFeatures(widget.bridge);
    if (features.isEmpty) return child;
    return MediaQuery(
      data: media.copyWith(displayFeatures: features),
      child: child,
    );
  }
}

enum _Aspect { layout, angle }

class _DuoHardwareModel extends InheritedModel<_Aspect> {
  const _DuoHardwareModel({required this.data, required super.child});

  final DuoHardware data;

  @override
  bool updateShouldNotify(_DuoHardwareModel old) => data != old.data;

  @override
  bool updateShouldNotifyDependent(
    _DuoHardwareModel old,
    Set<_Aspect> aspects,
  ) =>
      (aspects.contains(_Aspect.layout) && !data.sameLayout(old.data)) ||
      (aspects.contains(_Aspect.angle) && data.angle != old.data.angle);
}

/// Internal, registers the Dart only platforms (web, desktop).
class DuoHardwarePlugin {
  static void registerWith([Object? registrar]) {}
}
