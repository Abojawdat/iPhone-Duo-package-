import 'dart:async';
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const inner = Size(951, 669);
const band = Rect.fromLTWH(455.5, 0, 40, 669);

DuoHardware hinge(
  DuoHingeStatus status, {
  bool active = true,
  Rect fold = band,
  double? angle,
  List<DuoRegion> cameras = const [],
  DuoBarEdge bar = DuoBarEdge.none,
}) => DuoHardware(
  supported: true,
  hasHinge: true,
  status: status,
  angle: angle,
  folds: [DuoRegion(fold, isActive: active)],
  cameras: cameras,
  barEdge: bar,
);

DuoData duo(
  DuoHardware h, {
  Size size = inner,
  TargetPlatform platform = TargetPlatform.iOS,
  List<DisplayFeature> features = const [],
}) => DuoData(
  size: size,
  platform: platform,
  hardware: h,
  displayFeatures: features,
);

const _methods = MethodChannel('duo_dynamic_sizing');
const _events = EventChannel('duo_dynamic_sizing/events');

void main() {
  group('fromMap', () {
    test('reads a full iOS snapshot', () {
      final h = DuoHardware.fromMap({
        'supported': true,
        'hinge': true,
        'status': 2,
        'angle': 110.4,
        'hSize': 2,
        'vSize': 1,
        'bar': 2,
        'regions': [
          {
            'kind': 'division',
            'x': 455.5,
            'y': 0,
            'w': 40,
            'h': 669,
            'ml': 4,
            'mr': 4,
            'active': true,
          },
          {'kind': 'occlusion', 'x': 900, 'y': 10, 'w': 30, 'h': 30},
        ],
      });
      expect(h.status, DuoHingeStatus.partiallyOpen);
      expect(h.angle, 110.4);
      expect(h.hasHinge, isTrue);
      expect(h.horizontalSizeClass, DuoSizeClass.regular);
      expect(h.verticalSizeClass, DuoSizeClass.compact);
      expect(h.barEdge, DuoBarEdge.right);
      expect(h.folds.single.frame, band);
      expect(h.folds.single.reserved, const Rect.fromLTWH(459.5, 0, 32, 669));
      expect(h.cameras.single.isActive, isTrue);
    });

    test('junk becomes none instead of throwing', () {
      final h = DuoHardware.fromMap({
        'supported': 'yes',
        'status': 9,
        'angle': double.nan,
        'hSize': -1,
        'bar': 'left',
        'regions': [
          'nope',
          {'x': 1, 'y': 1, 'w': -5, 'h': 3},
          {'x': 1, 'y': 1, 'w': double.infinity, 'h': 3},
          {'x': 1, 'y': 'a', 'w': 2, 'h': 3},
        ],
      });
      expect(h, DuoHardware.none);
      expect(DuoHardware.fromMap(const {}), DuoHardware.none);
      expect(DuoHardware.fromMap({'regions': 'x'}), DuoHardware.none);
    });

    test('angle is clamped to 0...180', () {
      expect(DuoHardware.fromMap({'angle': 200}).angle, 180);
      expect(DuoHardware.fromMap({'angle': -3}).angle, 0);
    });

    test('regions lists are read only', () {
      final h = DuoHardware.fromMap({
        'regions': [
          {'x': 0, 'y': 0, 'w': 1, 'h': 1},
        ],
      });
      expect(() => h.folds.add(h.folds.first), throwsUnsupportedError);
    });
  });

  group('DuoData from the hinge', () {
    test('half open: 40 pt fold that separates, book posture', () {
      final d = duo(hinge(DuoHingeStatus.partiallyOpen));
      expect(d.fold, band);
      expect(d.isSeparating, isTrue);
      expect(d.posture, DuoPosture.book);
      expect(d.isIphoneDuo, isTrue);
    });

    test('flat: zero thick line at the fold center, even if isActive lags', () {
      final d = duo(hinge(DuoHingeStatus.fullyOpen, active: true));
      expect(d.fold, const Rect.fromLTWH(475.5, 0, 0, 669));
      expect(d.isSeparating, isFalse);
      expect(d.posture, DuoPosture.flat);
    });

    test('half open wins over a lagging inactive flag', () {
      final d = duo(hinge(DuoHingeStatus.partiallyOpen, active: false));
      expect(d.isSeparating, isTrue);
    });

    test('unknown status falls back to isActive', () {
      expect(duo(hinge(DuoHingeStatus.unknown)).isSeparating, isTrue);
      expect(
        duo(hinge(DuoHingeStatus.unknown, active: false)).isSeparating,
        isFalse,
      );
    });

    test('closed: no fold on the cover screen', () {
      final d = duo(hinge(DuoHingeStatus.closed), size: const Size(466, 678));
      expect(d.fold, isNull);
      expect(d.posture, DuoPosture.closed);
      expect(d.mode, DuoMode.closedPortrait);
    });

    test('horizontal fold is tabletop', () {
      final d = duo(
        hinge(
          DuoHingeStatus.partiallyOpen,
          fold: const Rect.fromLTWH(0, 455.5, 669, 40),
        ),
        size: const Size(669, 951),
      );
      expect(d.posture, DuoPosture.tabletop);
      expect(d.foldDirection, Axis.horizontal);
    });

    test('a zero width region never splits', () {
      final d = duo(
        hinge(
          DuoHingeStatus.partiallyOpen,
          fold: const Rect.fromLTWH(475.5, 0, 0, 669),
        ),
      );
      expect(d.isSeparating, isFalse);
    });

    test('Android display features win over the hinge data', () {
      const f = DisplayFeature(
        bounds: Rect.fromLTWH(420, 0, 0, 700),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureFlat,
      );
      final d = duo(
        hinge(DuoHingeStatus.partiallyOpen),
        size: const Size(840, 700),
        platform: TargetPlatform.android,
        features: const [f],
      );
      expect(d.fold, f.bounds);
      expect(d.posture, DuoPosture.flat);
      expect(d.isIphoneDuo, isFalse);
    });

    test('hinge spots a letterboxed Duo window (older SDK)', () {
      final d = duo(
        hinge(DuoHingeStatus.fullyOpen).copy(folds: const []),
        size: const Size(800, 600),
      );
      expect(d.isIphoneDuo, isTrue);
      expect(d.mode, DuoMode.openLandscape);
      // no region, so the window center stands in for the fold
      expect(d.fold, const Rect.fromLTWH(400, 0, 0, 600));
    });

    test('hinge half open in a narrow window is split view', () {
      final d = duo(
        hinge(DuoHingeStatus.partiallyOpen),
        size: const Size(475.5, 669),
      );
      expect(d.mode, DuoMode.splitView);
    });

    test('an Android hinge sensor never makes an iPhone Duo', () {
      final d = duo(
        hinge(DuoHingeStatus.unknown),
        size: const Size(800, 600),
        platform: TargetPlatform.android,
      );
      expect(d.isIphoneDuo, isFalse);
    });

    test('cameraInsets clear each active camera from its nearest edge', () {
      final d = duo(
        const DuoHardware(
          cameras: [
            DuoRegion(Rect.fromLTWH(900, 300, 30, 30)),
            DuoRegion(Rect.fromLTWH(400, 5, 20, 20)),
            DuoRegion(Rect.fromLTWH(10, 300, 20, 20), isActive: false),
            DuoRegion(Rect.fromLTWH(100, 100, 0, 0)),
          ],
        ),
      );
      expect(d.cameras, hasLength(2));
      expect(d.cameraInsets, const EdgeInsets.only(right: 51, top: 25));
    });

    test('a camera bigger than the window stays inside it', () {
      final d = duo(
        const DuoHardware(
          cameras: [DuoRegion(Rect.fromLTWH(-50, -50, 2000, 2000))],
        ),
      );
      final i = d.cameraInsets;
      expect(i.horizontal, lessThanOrEqualTo(inner.width * 2));
      expect(i.left, lessThanOrEqualTo(inner.width));
      expect(i.top, lessThanOrEqualTo(inner.height));
    });

    test('splitPanes keeps both panes off the 40 pt fold', () {
      final panes = splitPanes(
        duo(hinge(DuoHingeStatus.partiallyOpen)),
        inner,
        Offset.zero,
      )!;
      expect(panes.$1.right, 455.5);
      expect(panes.$2.left, 495.5);
    });

    test('toString shows the angle', () {
      expect(
        duo(hinge(DuoHingeStatus.partiallyOpen, angle: 110.4)).toString(),
        contains('book 110°'),
      );
    });
  });

  group('displayFeatures bridge', () {
    final cam = DuoRegion(const Rect.fromLTWH(900, 10, 30, 30));

    test('none publishes nothing', () {
      expect(
        hinge(DuoHingeStatus.partiallyOpen).displayFeatures(DuoBridge.none),
        isEmpty,
      );
    });

    test('cameras publishes cutouts only', () {
      final f = hinge(
        DuoHingeStatus.partiallyOpen,
        cameras: [cam],
      ).displayFeatures(DuoBridge.cameras);
      expect(f.single.type, DisplayFeatureType.cutout);
      expect(f.single.state, DisplayFeatureState.unknown);
    });

    test('all publishes the fold only while half open', () {
      List<DisplayFeature> at(DuoHingeStatus s, {bool active = true}) =>
          hinge(s, active: active).displayFeatures(DuoBridge.all);
      expect(
        at(DuoHingeStatus.partiallyOpen).single.state,
        DisplayFeatureState.postureHalfOpened,
      );
      expect(at(DuoHingeStatus.fullyOpen), isEmpty);
      expect(at(DuoHingeStatus.unknown), isEmpty);
      expect(at(DuoHingeStatus.closed), isEmpty);
      expect(at(DuoHingeStatus.partiallyOpen, active: false), isEmpty);
    });

    test('never a zero width fold or anything while closed', () {
      expect(
        hinge(
          DuoHingeStatus.partiallyOpen,
          fold: const Rect.fromLTWH(475, 0, 0, 669),
        ).displayFeatures(DuoBridge.all),
        isEmpty,
      );
      expect(
        hinge(
          DuoHingeStatus.closed,
          cameras: [cam],
        ).displayFeatures(DuoBridge.all),
        isEmpty,
      );
    });
  });

  group('DuoHardwareScope', () {
    testWidgets('no scope means none', (tester) async {
      late DuoHardware seen;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            seen = DuoHardware.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(seen, DuoHardware.none);
    });

    testWidgets('layout readers skip angle ticks, angle readers dont', (
      tester,
    ) async {
      var layout = 0, angle = 0;
      // built once, so only the model can rebuild them
      final children = Column(
        children: [
          Builder(
            builder: (context) {
              DuoHardware.of(context);
              layout++;
              return const SizedBox();
            },
          ),
          Builder(
            builder: (context) {
              DuoHardware.angleOf(context);
              angle++;
              return const SizedBox();
            },
          ),
        ],
      );
      Widget app(double a) => DuoHardwareScope(
        hardware: hinge(DuoHingeStatus.partiallyOpen, angle: a),
        child: children,
      );
      await tester.pumpWidget(app(100));
      for (var a = 101.0; a < 130; a++) {
        await tester.pumpWidget(app(a));
      }
      expect(layout, 1);
      expect(angle, 30);
    });

    testWidgets('bridge all splits a dialog around the half open fold', (
      tester,
    ) async {
      tester.view.physicalSize = inner * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        DuoHardwareScope(
          bridge: DuoBridge.all,
          hardware: hinge(DuoHingeStatus.partiallyOpen),
          child: MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(title: Text('hi')),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final dialog = tester.getRect(find.byType(AlertDialog));
      expect(dialog.right <= 455.5 || dialog.left >= 495.5, isTrue);
    });

    testWidgets('bridge none leaves dialogs full width', (tester) async {
      tester.view.physicalSize = inner * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      late List<DisplayFeature> seen;
      await tester.pumpWidget(
        DuoHardwareScope(
          hardware: hinge(DuoHingeStatus.partiallyOpen),
          child: Builder(
            builder: (context) {
              seen = MediaQuery.displayFeaturesOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(seen, isEmpty);
    });

    testWidgets('bridge stands down when the engine reports features', (
      tester,
    ) async {
      const engine = DisplayFeature(
        bounds: Rect.fromLTWH(1, 0, 0, 10),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureFlat,
      );
      late List<DisplayFeature> seen;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(displayFeatures: [engine]),
          child: DuoHardwareScope(
            bridge: DuoBridge.all,
            hardware: hinge(DuoHingeStatus.partiallyOpen),
            child: Builder(
              builder: (context) {
                seen = MediaQuery.displayFeaturesOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(seen, [engine]);
    });

    testWidgets('simulator hides the real device and feeds the pose', (
      tester,
    ) async {
      final seen = <DuoData>[];
      Widget app(DuoPose pose) => DuoHardwareScope(
        hardware: hinge(DuoHingeStatus.closed),
        child: DuoSimulator(
          pose: pose,
          child: Builder(
            builder: (context) {
              seen.add(context.duo);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpWidget(app(DuoPose.openLandscape));
      expect(seen.last.hardware, DuoHardware.none);
      await tester.pumpWidget(app(DuoPose.halfOpenBook));
      expect(seen.last.posture, DuoPosture.book);
      expect(seen.last.fold!.width, 40);
      await tester.pumpWidget(app(DuoPose.halfOpenTabletop));
      expect(seen.last.posture, DuoPosture.tabletop);
    });

    testWidgets('rail follows the bar edge iOS reports', (tester) async {
      Future<double> railX(DuoBarEdge bar) async {
        await tester.pumpWidget(
          DuoSimulator(
            pose: DuoPose(
              'test',
              inner,
              hardware: hinge(DuoHingeStatus.fullyOpen, bar: bar),
            ),
            child: MaterialApp(
              home: DuoNavigationScaffold(
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                destinations: const [
                  DuoDestination(icon: Icon(Icons.home), label: 'a'),
                  DuoDestination(icon: Icon(Icons.star), label: 'b'),
                ],
                body: const SizedBox(),
              ),
            ),
          ),
        );
        return tester.getCenter(find.byType(NavigationRail)).dx;
      }

      expect(await railX(DuoBarEdge.left), lessThan(inner.width / 2));
      expect(await railX(DuoBarEdge.right), greaterThan(inner.width / 2));
      // unknown keeps the island side
      expect(await railX(DuoBarEdge.none), greaterThan(inner.width / 2));
    });

    testWidgets('glass rail draws DuoGlass and keeps the rail usable', (
      tester,
    ) async {
      var picked = -1;
      await tester.pumpWidget(
        DuoSimulator(
          pose: DuoPose.openLandscape,
          child: MaterialApp(
            home: DuoNavigationScaffold(
              glass: true,
              selectedIndex: 0,
              onDestinationSelected: (i) => picked = i,
              destinations: const [
                DuoDestination(icon: Icon(Icons.home), label: 'a'),
                DuoDestination(icon: Icon(Icons.star), label: 'b'),
              ],
              body: const SizedBox(),
            ),
          ),
        ),
      );
      expect(find.byType(DuoGlass), findsOneWidget);
      await tester.tap(find.text('b'));
      expect(picked, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('live channel', () {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() {
      messenger.setMockMethodCallHandler(_methods, null);
      messenger.setMockStreamHandler(_events, null);
    });

    testWidgets(
      'snapshot then events reach context.duo',
      (tester) async {
        late MockStreamHandlerEventSink sink;
        messenger.setMockMethodCallHandler(
          _methods,
          (call) async => {'hinge': true, 'status': 3, 'angle': 180.0},
        );
        messenger.setMockStreamHandler(
          _events,
          MockStreamHandler.inline(
            onListen: (_, s) {
              sink = s;
            },
          ),
        );
        late DuoData seen;
        await tester.pumpWidget(
          DuoHardwareScope(
            child: MediaQuery(
              data: const MediaQueryData(size: inner, devicePixelRatio: 3),
              child: Builder(
                builder: (context) {
                  seen = context.duo;
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 10));
        expect(seen.posture, DuoPosture.flat);
        sink.success({
          'hinge': true,
          'status': 2,
          'angle': 100.0,
          'regions': [
            {'kind': 'division', 'x': 455.5, 'y': 0, 'w': 40, 'h': 669},
          ],
        });
        await tester.pump(const Duration(milliseconds: 10));
        expect(seen.posture, DuoPosture.book);
        expect(seen.fold, band);
        // junk and errors from the platform never crash the app
        sink.success('garbage');
        sink.error(code: 'x');
        await tester.pump(const Duration(milliseconds: 10));
        expect(seen.hardware, DuoHardware.none);
        await tester.pumpWidget(const SizedBox());
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'a missing plugin is just none, no errors',
      (tester) async {
        late DuoHardware seen;
        await tester.pumpWidget(
          DuoHardwareScope(
            child: Builder(
              builder: (context) {
                seen = DuoHardware.of(context);
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.pump();
        expect(seen, DuoHardware.none);
        expect(tester.takeException(), isNull);
        expect(
          await tester.runAsync(DuoHardware.describeNative),
          'Plugin not registered.',
        );
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'desktop never touches the channel',
      (tester) async {
        var calls = 0;
        messenger.setMockMethodCallHandler(_methods, (_) async => calls++);
        expect(await DuoHardware.stream.isEmpty, isTrue);
        expect(await DuoHardware.describeNative(), contains('No native side'));
        expect(calls, 0);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    );

    testWidgets(
      'angleStream skips nulls and repeats',
      (tester) async {
        messenger.setMockMethodCallHandler(
          _methods,
          (call) async => {'hinge': true},
        );
        messenger.setMockStreamHandler(
          _events,
          MockStreamHandler.inline(
            onListen: (_, s) {
              for (final a in [90.0, 90.0, 120.0]) {
                s.success({'hinge': true, 'angle': a});
              }
            },
          ),
        );
        final got = <double>[];
        final sub = DuoHardware.angleStream.listen(got.add);
        await tester.pump(const Duration(milliseconds: 10));
        expect(got, [90.0, 120.0]);
        // awaiting the cancel would wait on a platform reply fake time never
        // delivers
        unawaited(sub.cancel());
        await tester.pump(const Duration(milliseconds: 10));
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets(
      'switching from pinned to live and back',
      (tester) async {
        messenger.setMockMethodCallHandler(
          _methods,
          (call) async => {'hinge': true, 'status': 1},
        );
        late DuoHardware seen;
        Widget app(DuoHardware? h) => DuoHardwareScope(
          hardware: h,
          child: Builder(
            builder: (context) {
              seen = DuoHardware.of(context);
              return const SizedBox();
            },
          ),
        );
        await tester.pumpWidget(app(hinge(DuoHingeStatus.partiallyOpen)));
        expect(seen.status, DuoHingeStatus.partiallyOpen);
        await tester.pumpWidget(app(null));
        await tester.pump();
        expect(seen.status, DuoHingeStatus.closed);
        await tester.pumpWidget(app(hinge(DuoHingeStatus.fullyOpen)));
        expect(seen.status, DuoHingeStatus.fullyOpen);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  });
}

extension on DuoHardware {
  DuoHardware copy({List<DuoRegion>? folds}) => DuoHardware(
    supported: supported,
    hasHinge: hasHinge,
    status: status,
    angle: angle,
    folds: folds ?? this.folds,
    cameras: cameras,
    horizontalSizeClass: horizontalSizeClass,
    verticalSizeClass: verticalSizeClass,
    barEdge: barEdge,
  );
}
