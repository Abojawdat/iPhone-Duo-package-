import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget sim(DuoPose pose, Widget home) => DuoSimulator(
  pose: pose,
  child: MaterialApp(home: home),
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

Widget longList({void Function(int)? onTap}) => ListView.builder(
  itemCount: 100,
  itemBuilder: (_, i) => ListTile(
    title: Text('row $i'),
    onTap: onTap == null ? null : () => onTap(i),
  ),
);

double scrollOf(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;

double centerX(WidgetTester tester, Finder f) => tester.getCenter(f).dx;

const body = Key('body');

Widget nav(
  DuoPose pose, {
  Widget? content,
  bool fab = false,
  bool rtl = false,
  DuoRailSide side = DuoRailSide.auto,
}) {
  final scaffold = DuoNavigationScaffold(
    selectedIndex: 0,
    onDestinationSelected: (_) {},
    destinations: const [
      DuoDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
      DuoDestination(icon: Icon(Icons.settings), label: 'Settings'),
    ],
    floatingActionButton: fab
        ? FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add))
        : null,
    body: content ?? const SizedBox.expand(key: body),
    railSide: side,
  );
  return sim(
    pose,
    rtl
        ? Directionality(textDirection: TextDirection.rtl, child: scaffold)
        : scaffold,
  );
}

void main() {
  group('context.duo', () {
    testWidgets('rebuilds on fold, unfold and split', (tester) async {
      final probe = Builder(builder: (context) => Text(context.duo.mode.name));
      for (final (pose, mode) in [
        (DuoPose.closedPortrait, 'closedPortrait'),
        (DuoPose.openLandscape, 'openLandscape'),
        (DuoPose.splitRight, 'splitView'),
        (DuoPose.openPortrait, 'openPortrait'),
        (DuoPose.closedLandscape, 'closedLandscape'),
        (DuoPose.foldableTabletop, 'openPortrait'),
        (DuoPose.iPad, 'tablet'),
      ]) {
        await tester.pumpWidget(sim(pose, probe));
        expect(find.text(mode), findsOneWidget, reason: pose.name);
      }
    });

    testWidgets('DuoBuilder and DuoScope thresholds', (tester) async {
      final cols = DuoBuilder(builder: (_, d) => Text('cols ${d.columns}'));
      await tester.pumpWidget(sim(DuoPose.closedPortrait, cols));
      expect(find.text('cols 1'), findsOneWidget);
      await tester.pumpWidget(sim(DuoPose.openLandscape, cols));
      expect(find.text('cols 2'), findsOneWidget);
      await tester.pumpWidget(
        DuoScope(expandedWidth: 1000, child: sim(DuoPose.openLandscape, cols)),
      );
      expect(find.text('cols 1'), findsOneWidget);
    });

    testWidgets('text survives unfolding', (tester) async {
      Widget app(DuoPose p) =>
          sim(p, const Scaffold(body: Center(child: TextField())));
      await tester.pumpWidget(app(DuoPose.closedPortrait));
      await tester.enterText(find.byType(TextField), 'draft');
      await tester.pumpWidget(app(DuoPose.openLandscape));
      expect(find.text('draft'), findsOneWidget);
    });
  });

  group('DuoLayout', () {
    testWidgets('DuoKeep keeps state and scroll through fold and unfold', (
      tester,
    ) async {
      Widget app(DuoPose p) => sim(
        p,
        Scaffold(
          body: DuoLayout(
            closed: (_) => DuoKeep(id: 'list', child: longList()),
            open: (_) => Row(
              children: [
                Expanded(
                  child: DuoKeep(id: 'list', child: longList()),
                ),
                const Expanded(child: Text('detail')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpWidget(app(DuoPose.closedPortrait));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      final offset = scrollOf(tester);
      expect(offset, greaterThan(0));

      await tester.pumpWidget(app(DuoPose.openLandscape));
      expect(find.text('detail'), findsOneWidget);
      expect(scrollOf(tester), offset);

      await tester.pumpWidget(app(DuoPose.closedPortrait));
      expect(find.text('detail'), findsNothing);
      expect(scrollOf(tester), offset);
    });

    testWidgets('DuoKeep needs a DuoLayout', (tester) async {
      await tester.pumpWidget(const DuoKeep(id: 1, child: SizedBox()));
      expect(tester.takeException(), isAssertionError);
    });
  });

  group('DuoSplit', () {
    testWidgets('one pane closed, two open, state kept', (tester) async {
      Widget app(DuoPose p) =>
          sim(p, const DuoSplit(primary: Counter(), secondary: Text('second')));
      await tester.pumpWidget(app(DuoPose.closedPortrait));
      expect(find.text('second'), findsNothing);
      await tester.tap(find.text('count 0'));
      await tester.pump();

      await tester.pumpWidget(app(DuoPose.openLandscape));
      await tester.pump();
      expect(find.text('second'), findsOneWidget);
      expect(find.text('count 1'), findsOneWidget);
      expect(tester.getSize(find.byType(Counter)).width, 475.5);
    });

    testWidgets('follows an Android fold', (tester) async {
      const panes = DuoSplit(
        primary: SizedBox.expand(key: Key('a')),
        secondary: SizedBox.expand(key: Key('b')),
      );
      await tester.pumpWidget(sim(DuoPose.foldableBook, panes));
      await tester.pump();
      expect(tester.getSize(find.byKey(const Key('a'))), const Size(420, 700));
      await tester.pumpWidget(sim(DuoPose.foldableTabletop, panes));
      await tester.pump();
      expect(tester.getSize(find.byKey(const Key('a'))), const Size(700, 420));
    });

    testWidgets('an offset box still splits at the fold', (tester) async {
      await tester.pumpWidget(
        sim(
          DuoPose.openLandscape,
          Scaffold(
            appBar: AppBar(title: const Text('x')),
            body: const Padding(
              padding: EdgeInsets.only(left: 100),
              child: DuoSplit(
                primary: SizedBox.expand(key: Key('a')),
                secondary: SizedBox.expand(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.getSize(find.byKey(const Key('a'))).width, 375.5);
    });
  });

  group('rtl and ltr', () {
    const a = Key('a'), b = Key('b');
    const panes = DuoSplit(
      primary: SizedBox.expand(key: a),
      secondary: SizedBox.expand(key: b),
    );

    testWidgets('rtl app: primary on the right, still at the fold', (
      tester,
    ) async {
      await tester.pumpWidget(
        sim(
          DuoPose.openLandscape,
          const Directionality(textDirection: TextDirection.rtl, child: panes),
        ),
      );
      await tester.pump();
      expect(tester.getSize(find.byKey(a)).width, 475.5);
      expect(
        centerX(tester, find.byKey(a)),
        greaterThan(centerX(tester, find.byKey(b))),
      );
    });

    testWidgets('textDirection overrides the app', (tester) async {
      await tester.pumpWidget(
        sim(
          DuoPose.foldableBook,
          const DuoSplit(
            textDirection: TextDirection.rtl,
            primary: SizedBox.expand(key: a),
            secondary: SizedBox.expand(key: b),
          ),
        ),
      );
      await tester.pump();
      expect(
        centerX(tester, find.byKey(a)),
        greaterThan(centerX(tester, find.byKey(b))),
      );
    });

    testWidgets('rtl list detail puts the list on the right', (tester) async {
      await tester.pumpWidget(
        sim(
          DuoPose.openLandscape,
          Directionality(
            textDirection: TextDirection.rtl,
            child: DuoListDetail<int>(
              selected: 1,
              onClose: () {},
              list: (_) => const SizedBox.expand(key: a),
              detail: (_, _) => const SizedBox.expand(key: b),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        centerX(tester, find.byKey(a)),
        greaterThan(centerX(tester, find.byKey(b))),
      );
    });

    testWidgets('DuoAvoidFold takes the trailing half in rtl', (tester) async {
      await tester.pumpWidget(
        sim(
          DuoPose.foldableBook,
          const Directionality(
            textDirection: TextDirection.rtl,
            child: DuoAvoidFold(child: SizedBox.expand(key: a)),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(a)), const Size(420, 700));
      expect(
        tester.getTopLeft(find.byKey(a)).dx,
        tester.getTopLeft(find.byType(DuoAvoidFold)).dx,
      );
    });

    testWidgets('railSide lets the app choose', (tester) async {
      Future<bool> onRight(
        DuoPose p,
        DuoRailSide side, {
        bool rtl = false,
      }) async {
        await tester.pumpWidget(nav(p, side: side, rtl: rtl));
        return centerX(tester, find.byType(NavigationRail)) >
            centerX(tester, find.byKey(body));
      }

      expect(await onRight(DuoPose.closedPortrait, DuoRailSide.auto), isTrue);
      expect(await onRight(DuoPose.closedPortrait, DuoRailSide.start), isFalse);
      expect(
        await onRight(DuoPose.closedPortrait, DuoRailSide.start, rtl: true),
        isTrue,
      );
      expect(await onRight(DuoPose.foldableBook, DuoRailSide.end), isTrue);
      expect(
        await onRight(DuoPose.foldableBook, DuoRailSide.end, rtl: true),
        isFalse,
      );
      expect(await onRight(DuoPose.iPad, DuoRailSide.left, rtl: true), isFalse);
      expect(await onRight(DuoPose.foldableBook, DuoRailSide.right), isTrue);
    });
  });

  group('DuoListDetail', () {
    int? selected;
    Widget app(DuoPose p) => sim(
      p,
      StatefulBuilder(
        builder: (context, setState) => Scaffold(
          body: DuoListDetail<int>(
            selected: selected,
            onClose: () => setState(() => selected = null),
            empty: (_) => const Text('empty'),
            list: (_) => longList(onTap: (i) => setState(() => selected = i)),
            detail: (_, i) => Text('detail $i'),
          ),
        ),
      ),
    );

    setUp(() => selected = null);

    testWidgets('select, system back, unfold', (tester) async {
      await tester.pumpWidget(app(DuoPose.closedPortrait));
      expect(find.text('empty'), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      final offset = scrollOf(tester);

      await tester.tap(find.byType(ListTile).hitTestable().first);
      await tester.pump();
      expect(find.text('detail $selected'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);

      await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
      await tester.pump();
      expect(selected, isNull);
      expect(scrollOf(tester), offset);

      await tester.tap(find.byType(ListTile).hitTestable().first);
      await tester.pump();
      await tester.pumpWidget(app(DuoPose.openLandscape));
      await tester.pump();
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('detail $selected'), findsOneWidget);
      expect(scrollOf(tester), offset);
    });

    testWidgets('empty detail pane when open', (tester) async {
      await tester.pumpWidget(app(DuoPose.openLandscape));
      await tester.pump();
      expect(find.text('empty'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('DuoNavigationScaffold', () {
    testWidgets('closed Duo: rail on the right with the FAB in it', (
      tester,
    ) async {
      await tester.pumpWidget(nav(DuoPose.closedPortrait, fab: true));
      expect(find.byType(NavigationBar), findsNothing);
      expect(
        centerX(tester, find.byType(NavigationRail)),
        greaterThan(centerX(tester, find.byKey(body))),
      );
      expect(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.byType(FloatingActionButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('open upright Duo and iPhone: bottom bar', (tester) async {
      for (final p in [DuoPose.openPortrait, DuoPose.iPhone]) {
        await tester.pumpWidget(nav(p, fab: true));
        expect(find.byType(NavigationBar), findsOneWidget, reason: p.name);
        expect(find.byType(NavigationRail), findsNothing, reason: p.name);
      }
    });

    testWidgets('split view: each app gets its outer edge', (tester) async {
      await tester.pumpWidget(nav(DuoPose.splitLeft));
      expect(
        centerX(tester, find.byType(NavigationRail)),
        lessThan(centerX(tester, find.byKey(body))),
      );
      await tester.pumpWidget(nav(DuoPose.splitRight));
      expect(
        centerX(tester, find.byType(NavigationRail)),
        greaterThan(centerX(tester, find.byKey(body))),
      );
    });

    testWidgets('leading rail elsewhere, flipped for rtl', (tester) async {
      await tester.pumpWidget(nav(DuoPose.foldableBook));
      expect(
        centerX(tester, find.byType(NavigationRail)),
        lessThan(centerX(tester, find.byKey(body))),
      );
      await tester.pumpWidget(nav(DuoPose.foldableBook, rtl: true));
      expect(
        centerX(tester, find.byType(NavigationRail)),
        greaterThan(centerX(tester, find.byKey(body))),
      );
    });

    testWidgets('Duo rail stays on the right in rtl', (tester) async {
      await tester.pumpWidget(nav(DuoPose.closedPortrait, rtl: true));
      expect(
        centerX(tester, find.byType(NavigationRail)),
        greaterThan(centerX(tester, find.byKey(body))),
      );
    });

    testWidgets('page state survives the bar to rail swap', (tester) async {
      const page = Center(child: Counter());
      await tester.pumpWidget(nav(DuoPose.openPortrait, content: page));
      await tester.tap(find.text('count 0'));
      await tester.pump();
      await tester.pumpWidget(nav(DuoPose.openLandscape, content: page));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('count 1'), findsOneWidget);
    });

    testWidgets('the rail takes the island inset, not the body', (
      tester,
    ) async {
      late EdgeInsets inset;
      await tester.pumpWidget(
        nav(
          DuoPose.closedPortrait,
          content: Builder(
            builder: (context) {
              inset = MediaQuery.paddingOf(context);
              return const SizedBox.expand();
            },
          ),
        ),
      );
      expect(inset.right, 0);
    });
  });

  group('media and fold helpers', () {
    testWidgets('DuoMedia lays the child out at its fitted size', (
      tester,
    ) async {
      await tester.pumpWidget(
        sim(
          DuoPose.openLandscape,
          const DuoMedia(
            aspectRatio: 16 / 9,
            child: SizedBox.expand(key: Key('v')),
          ),
        ),
      );
      final s = tester.getSize(find.byKey(const Key('v')));
      expect(s.width, 951);
      expect(s.height, closeTo(534.9, .1));
    });

    testWidgets('DuoMedia in a scroll view falls back to its ratio', (
      tester,
    ) async {
      await tester.pumpWidget(
        sim(
          DuoPose.iPhone,
          ListView(
            children: const [
              DuoMedia(aspectRatio: 2, child: SizedBox.expand(key: Key('v'))),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('v'))), const Size(402, 201));
    });

    testWidgets('DuoAvoidFold moves controls off the fold', (tester) async {
      const child = DuoAvoidFold(child: SizedBox.expand(key: Key('c')));
      final c = find.byKey(const Key('c'));
      final avoid = find.byType(DuoAvoidFold);

      await tester.pumpWidget(sim(DuoPose.foldableTabletop, child));
      expect(tester.getSize(c), const Size(700, 420));
      expect(tester.getTopLeft(c).dy, greaterThan(tester.getTopLeft(avoid).dy));

      await tester.pumpWidget(sim(DuoPose.foldableBook, child));
      expect(tester.getSize(c), const Size(420, 700));
      expect(tester.getTopLeft(c).dx, greaterThan(tester.getTopLeft(avoid).dx));

      await tester.pumpWidget(sim(DuoPose.openLandscape, child));
      expect(tester.getSize(c), const Size(951, 669));
    });
  });

  group('tools', () {
    testWidgets('DuoDebugOverlay shows the live values', (tester) async {
      await tester.pumpWidget(
        sim(DuoPose.openLandscape, const DuoDebugOverlay(child: SizedBox())),
      );
      expect(find.textContaining('openLandscape 951×669'), findsOneWidget);
      await tester.pumpWidget(
        sim(
          DuoPose.openLandscape,
          const DuoDebugOverlay(enabled: false, child: SizedBox()),
        ),
      );
      expect(find.textContaining('openLandscape'), findsNothing);
    });

    testWidgets('guides draw without resetting the app', (tester) async {
      Widget app(bool guides) => DuoSimulator(
        pose: DuoPose.openLandscape,
        showGuides: guides,
        child: const MaterialApp(home: Center(child: Counter())),
      );
      await tester.pumpWidget(app(false));
      await tester.tap(find.text('count 0'));
      await tester.pump();
      await tester.pumpWidget(app(true));
      expect(find.text('count 1'), findsOneWidget);
    });
  });
}
