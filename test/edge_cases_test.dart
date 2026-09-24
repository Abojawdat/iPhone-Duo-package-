import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget sim(DuoPose pose, Widget home, {double textScale = 1}) => DuoSimulator(
  pose: pose,
  child: MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  ),
);

DuoData ios(double w, double h, {double dpr = 3}) => DuoData(
  size: Size(w, h),
  platform: TargetPlatform.iOS,
  devicePixelRatio: dpr,
);

DisplayFeature fold(
  double x,
  double h, [
  DisplayFeatureState s = DisplayFeatureState.postureHalfOpened,
]) => DisplayFeature(
  bounds: Rect.fromLTWH(x, 0, 0, h),
  type: DisplayFeatureType.fold,
  state: s,
);

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int n = 0;

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: () => setState(() => n++), child: Text('count $n'));
}

class Builds extends StatelessWidget {
  const Builds(this.log, {super.key});

  final List<String> log;

  @override
  Widget build(BuildContext context) {
    log.add(context.duo.mode.name);
    return const SizedBox.expand();
  }
}

Widget scaffold(int destinations, {bool fab = true}) => DuoNavigationScaffold(
  selectedIndex: 0,
  onDestinationSelected: (_) {},
  floatingActionButton: fab
      ? FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add))
      : null,
  destinations: [
    for (var i = 0; i < destinations; i++)
      DuoDestination(icon: const Icon(Icons.circle), label: 'Tab number $i'),
  ],
  body: const SizedBox.expand(),
);

void main() {
  group('broken windows', () {
    test('zero sized window', () {
      final d = ios(0, 0);
      expect(
        [d.mode, d.columns, d.gridColumns(100), d.fold],
        [DuoMode.closedPortrait, 1, 1, null],
      );
      expect(d.toString, returnsNormally);
      expect(splitPanes(d, Size.zero, Offset.zero), isNull);
      expect(DuoMedia.fitSize(16 / 9, Size.zero), Size.zero);
    });

    testWidgets('zero sized box does not throw', (tester) async {
      await tester.pumpWidget(
        sim(
          DuoPose.openLandscape,
          const Center(
            child: SizedBox.shrink(
              child: DuoSplit(
                primary: ColoredBox(color: Colors.red),
                secondary: ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        sim(
          DuoPose.openLandscape,
          const SizedBox.shrink(
            child: DuoMedia(aspectRatio: 16 / 9, child: SizedBox.expand()),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('150 x 150 window', (tester) async {
      await tester.pumpWidget(
        sim(const DuoPose('tiny', Size(150, 150)), scaffold(3)),
      );
      expect(tester.takeException(), isNull);
    });

    test('4K desktop window', () {
      const d = DuoData(
        size: Size(3840, 2160),
        platform: TargetPlatform.macOS,
        devicePixelRatio: 2,
      );
      expect(
        [d.mode, d.gridColumns(160), d.prefersRail],
        [DuoMode.desktop, 24, true],
      );
      final (a, b) = splitPanes(d, const Size(3840, 2160), Offset.zero)!;
      expect([a.width, b.width], [1920, 1920]);
    });

    test('fractional sizes and a wobbly dpr still read as the Duo', () {
      expect(ios(950.6, 669.4, dpr: 2.9999).mode, DuoMode.openLandscape);
      expect(ios(466.4, 677.8).mode, DuoMode.closedPortrait);
    });

    test('Display Zoom falls back to the generic modes', () {
      final zoomed = ios(400, 582);
      expect(
        [zoomed.isIphoneDuo, zoomed.mode],
        [false, DuoMode.closedPortrait],
      );
    });
  });

  group('bad input', () {
    test('silly aspect ratios never blow up the fit', () {
      const box = Size(951, 669);
      for (final r in [0.0, -1.0, double.nan, double.infinity]) {
        final s = DuoMedia.fitSize(r, box);
        expect(s.isFinite, isTrue, reason: '$r');
        expect(s, box, reason: '$r');
      }
    });

    test('DuoMedia rejects a bad ratio in debug', () {
      expect(
        () => DuoMedia(aspectRatio: 0, child: const SizedBox()),
        throwsAssertionError,
      );
    });

    test('maxCrop outside 0..1', () {
      const box = Size(951, 669);
      expect(DuoMedia.fitSize(16 / 9, box, maxCrop: 5).height, 669);
      expect(DuoMedia.fitSize(4 / 3, box, maxCrop: -1).height, 669);
    });
  });

  group('wrong layouts', () {
    testWidgets('DuoSplit in an unbounded Column falls back to one pane', (
      tester,
    ) async {
      await tester.pumpWidget(
        sim(
          DuoPose.openLandscape,
          const SingleChildScrollView(
            child: Column(
              children: [
                DuoSplit(
                  primary: SizedBox(height: 100, child: Text('primary')),
                  secondary: Text('secondary'),
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('primary'), findsOneWidget);
      expect(find.text('secondary'), findsNothing);
    });

    testWidgets('DuoSplit in a horizontal scroll view', (tester) async {
      await tester.pumpWidget(
        sim(
          DuoPose.openLandscape,
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DuoSplit(
              primary: SizedBox(width: 100, child: Text('primary')),
              secondary: Text('secondary'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('primary'), findsOneWidget);
    });

    testWidgets('DuoListDetail with no MaterialApp or Navigator', (
      tester,
    ) async {
      await tester.pumpWidget(
        DuoSimulator(
          pose: DuoPose.closedPortrait,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: DuoListDetail<int>(
              selected: 2,
              onClose: () {},
              list: (_) => const Text('list'),
              detail: (_, i) => Text('detail $i'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('detail 2'), findsOneWidget);
    });

    testWidgets('DuoAvoidFold with no Directionality', (tester) async {
      await tester.pumpWidget(
        const DuoSimulator(
          pose: DuoPose.foldableBook,
          child: DuoAvoidFold(child: SizedBox.expand(key: Key('c'))),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const Key('c'))), const Size(420, 700));
    });

    testWidgets('nested DuoLayouts reuse the same ids safely', (tester) async {
      Widget inner() => DuoLayout(
        closed: (_) => const DuoKeep(id: 'x', child: Counter()),
        open: (_) => const Row(
          children: [
            Expanded(
              child: DuoKeep(id: 'x', child: Counter()),
            ),
          ],
        ),
      );
      Widget app(DuoPose p) => sim(
        p,
        DuoLayout(
          closed: (_) => DuoKeep(id: 'x', child: inner()),
          open: (_) => Row(
            children: [
              Expanded(
                child: DuoKeep(id: 'x', child: inner()),
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(app(DuoPose.closedPortrait));
      await tester.tap(find.text('count 0'));
      await tester.pump();
      await tester.pumpWidget(app(DuoPose.openLandscape));
      expect(tester.takeException(), isNull);
      expect(find.text('count 1'), findsOneWidget);
    });

    testWidgets('nested simulators: the inner pose wins', (tester) async {
      await tester.pumpWidget(
        DuoSimulator(
          pose: DuoPose.openLandscape,
          child: Center(
            child: DuoSimulator(
              pose: DuoPose.foldableBook,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Builder(
                  builder: (context) => Text(context.duo.posture.name),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('book'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('hardware', () {
    testWidgets('tri-fold with two hinges splits at a fold', (tester) async {
      const trifold = DuoPose(
        'trifold',
        Size(1200, 800),
        platform: TargetPlatform.android,
        devicePixelRatio: 2.5,
        displayFeatures: [
          DisplayFeature(
            bounds: Rect.fromLTWH(400, 0, 0, 800),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
          DisplayFeature(
            bounds: Rect.fromLTWH(800, 0, 0, 800),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );
      await tester.pumpWidget(
        sim(
          trifold,
          const DuoSplit(
            primary: SizedBox.expand(key: Key('a')),
            secondary: SizedBox.expand(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const Key('a'))).width, 400);
    });

    test('a fold outside the window is ignored by the split', () {
      final d = DuoData(
        size: const Size(900, 700),
        platform: TargetPlatform.android,
        displayFeatures: [fold(1000, 700)],
      );
      final (a, _) = splitPanes(d, const Size(900, 700), Offset.zero)!;
      expect(a.width, 450);
    });

    test('fold with unknown state', () {
      final d = DuoData(
        size: const Size(840, 700),
        platform: TargetPlatform.android,
        displayFeatures: [fold(420, 700, DisplayFeatureState.unknown)],
      );
      expect([d.posture, d.isSeparating], [DuoPosture.unknown, false]);
    });
  });

  group('stress', () {
    testWidgets('60 rapid folds keep state and scroll', (tester) async {
      Widget app(DuoPose p) => sim(
        p,
        Scaffold(
          body: DuoLayout(
            closed: (_) => const DuoKeep(id: 'c', child: Counter()),
            open: (_) => const Row(
              children: [
                Expanded(
                  child: DuoKeep(id: 'c', child: Counter()),
                ),
                Expanded(child: Text('side')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpWidget(app(DuoPose.closedPortrait));
      await tester.tap(find.text('count 0'));
      await tester.pump();
      const poses = [
        DuoPose.openLandscape,
        DuoPose.closedLandscape,
        DuoPose.splitLeft,
        DuoPose.openPortrait,
        DuoPose.closedPortrait,
        DuoPose.foldableTabletop,
      ];
      for (var i = 0; i < 60; i++) {
        await tester.pumpWidget(app(poses[i % poses.length]));
      }
      expect(tester.takeException(), isNull);
      expect(find.text('count 1'), findsOneWidget);
    });

    testWidgets('flipping rtl keeps the panes alive', (tester) async {
      Widget app(TextDirection d) => sim(
        DuoPose.openLandscape,
        Directionality(
          textDirection: d,
          child: const DuoSplit(primary: Counter(), secondary: Text('side')),
        ),
      );
      await tester.pumpWidget(app(TextDirection.ltr));
      await tester.tap(find.text('count 0'));
      await tester.pump();
      for (var i = 0; i < 6; i++) {
        await tester.pumpWidget(
          app(i.isEven ? TextDirection.rtl : TextDirection.ltr),
        );
        await tester.pump();
      }
      expect(find.text('count 1'), findsOneWidget);
    });

    testWidgets('changing DuoScope live', (tester) async {
      final probe = Builder(
        builder: (context) => Text('cols ${context.duo.columns}'),
      );
      await tester.pumpWidget(
        DuoScope(child: sim(DuoPose.openLandscape, probe)),
      );
      expect(find.text('cols 2'), findsOneWidget);
      await tester.pumpWidget(
        DuoScope(expandedWidth: 2000, child: sim(DuoPose.openLandscape, probe)),
      );
      expect(find.text('cols 1'), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('3x text on the closed Duo', (tester) async {
      await tester.pumpWidget(
        sim(DuoPose.closedPortrait, scaffold(3), textScale: 3),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('7 destinations on the closed sideways Duo', (tester) async {
      await tester.pumpWidget(sim(DuoPose.closedLandscape, scaffold(7)));
      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets('3x text with a bottom bar on the iPhone', (tester) async {
      await tester.pumpWidget(sim(DuoPose.iPhone, scaffold(3), textScale: 3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('very long labels in the rail', (tester) async {
      await tester.pumpWidget(
        sim(
          DuoPose.closedPortrait,
          DuoNavigationScaffold(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              DuoDestination(
                icon: Icon(Icons.circle),
                label: 'Notifications and account settings for everyone',
              ),
              DuoDestination(icon: Icon(Icons.circle), label: 'Home'),
            ],
            body: const SizedBox.expand(key: Key('body')),
          ),
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('body'))).width,
        greaterThan(466 * .5),
      );
    });

    testWidgets('7 destinations in a bottom bar on the iPhone', (tester) async {
      await tester.pumpWidget(sim(DuoPose.iPhone, scaffold(7)));
      expect(tester.takeException(), isNull);
    });
  });

  group('performance', () {
    testWidgets('keyboard and text size do not rebuild context.duo readers', (
      tester,
    ) async {
      final log = <String>[];
      final probe = Builds(log);
      Widget app(double keyboard, double scale) => DuoSimulator(
        pose: DuoPose.closedPortrait,
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              viewInsets: EdgeInsets.only(bottom: keyboard),
              textScaler: TextScaler.linear(scale),
            ),
            child: probe,
          ),
        ),
      );
      await tester.pumpWidget(app(0, 1));
      expect(log, ['closedPortrait']);
      await tester.pumpWidget(app(300, 1));
      await tester.pumpWidget(app(300, 2));
      expect(log, ['closedPortrait']);
      await tester.pumpWidget(
        DuoSimulator(pose: DuoPose.openLandscape, child: Builds(log)),
      );
      expect(log.last, 'openLandscape');
    });
  });
}
