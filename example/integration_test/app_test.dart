// drives the real playground app. screenshots come back thru flutter drive:
//   flutter drive -d macos --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
// or just the checks: flutter test integration_test -d macos
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:duo_dynamic_sizing_example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final shots = <String, String>{};
  final root = GlobalKey();

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final boundary =
        root.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    shots[name] = base64Encode(png!.buffer.asUint8List());
    binding.reportData = {'screenshots': shots};
  }

  Future<void> launch(
    WidgetTester tester, [
    Size window = const Size(1400, 1000),
  ]) async {
    tester.view.physicalSize = window * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    // reduce motion, so the record stands still and pumpAndSettle settles
    await tester.pumpWidget(
      MediaQuery.fromView(
        view: tester.view,
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: RepaintBoundary(
              key: root,
              child: const Playground(helpOnStart: false),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pose(WidgetTester tester, String name) async {
    final chip = find.widgetWithText(ChoiceChip, name);
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> resize(WidgetTester tester, Size window) async {
    tester.view.physicalSize = window * tester.view.devicePixelRatio;
    await tester.pumpAndSettle();
  }

  final list = find.byType(DuoListDetail<int>);
  final track = find.text(iso('Two Screens, One Heart')).first;

  bool railOnRight(WidgetTester tester) =>
      tester.getCenter(find.byType(NavigationRail)).dx >
      tester.getCenter(list).dx;

  Finder listScrollable() =>
      find.descendant(of: list, matching: find.byType(Scrollable)).first;

  testWidgets('open Duo: list, then list + player', (tester) async {
    await launch(tester);
    await pose(tester, 'openLandscape');
    expect(find.text(en.pick), findsOneWidget);
    expect(railOnRight(tester), isTrue);
    await shot(tester, '01_open_empty');

    await tester.tap(track);
    await tester.pumpAndSettle();
    expect(find.byType(NowPlaying), findsOneWidget);
    expect(find.text(en.pick), findsNothing);
    await shot(tester, '02_open_playing');
  });

  testWidgets('fold keeps the player, close shows the list', (tester) async {
    await launch(tester);
    await pose(tester, 'openLandscape');
    await tester.tap(track);
    await tester.pumpAndSettle();
    final player = tester.state(find.byType(NowPlaying));

    await pose(tester, 'closedPortrait');
    expect(tester.state(find.byType(NowPlaying)), same(player));
    expect(find.byType(ListTile), findsNothing);
    await shot(tester, '03_closed_playing');

    await pose(tester, 'openLandscape');
    expect(tester.state(find.byType(NowPlaying)), same(player));

    await pose(tester, 'closedPortrait');
    await tester.tap(find.byTooltip(en.close));
    await tester.pumpAndSettle();
    expect(find.byType(NowPlaying), findsNothing);
    expect(find.byType(ListTile), findsWidgets);
    await shot(tester, '04_closed_list');
  });

  testWidgets('list scroll survives fold and unfold', (tester) async {
    await launch(tester);
    await pose(tester, 'closedLandscape');
    await tester.drag(listScrollable(), const Offset(0, -200));
    await tester.pumpAndSettle();
    final before = tester
        .state<ScrollableState>(listScrollable())
        .position
        .pixels;
    expect(before, greaterThan(0));

    await pose(tester, 'openLandscape');
    expect(
      tester.state<ScrollableState>(listScrollable()).position.pixels,
      before,
    );
  });

  testWidgets('every pose: bar or rail on the right side', (tester) async {
    await launch(tester);
    final expectations = {
      'closedPortrait': 'right',
      'closedLandscape': 'right',
      'openLandscape': 'right',
      'openPortrait': 'bar',
      'splitLeft': 'left',
      'splitRight': 'right',
      'foldableBook': 'left',
      'foldableTabletop': 'left',
      'iPhone': 'bar',
      'iPad': 'left',
    };
    for (final MapEntry(key: name, value: nav) in expectations.entries) {
      await pose(tester, name);
      if (nav == 'bar') {
        expect(find.byType(NavigationBar), findsOneWidget, reason: name);
        expect(find.byType(NavigationRail), findsNothing, reason: name);
      } else {
        expect(railOnRight(tester), nav == 'right', reason: name);
      }
      await shot(tester, '05_pose_$name');
    }
  });

  testWidgets('Lab state survives every pose', (tester) async {
    await launch(tester);
    await tab(tester, 'Lab');
    await tester.ensureVisible(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.add));
    }
    await tester.enterText(find.byType(TextField), 'still here');
    await tester.pumpAndSettle();
    for (final p in [
      'openLandscape',
      'closedPortrait',
      'foldableBook',
      'iPad',
    ]) {
      await pose(tester, p);
      expect(find.widgetWithText(Card, '3'), findsOneWidget, reason: p);
      expect(find.text('still here'), findsOneWidget, reason: p);
    }
    await shot(tester, '06_lab_ipad');
  });

  testWidgets('tabletop: photo above the fold, info below', (tester) async {
    await launch(tester);
    await pose(tester, 'foldableTabletop');
    await tab(tester, 'Gallery');
    await tester.tap(
      find
          .descendant(of: find.byType(GridView), matching: find.byType(Hero))
          .first,
    );
    await tester.pumpAndSettle();
    final media = tester.getRect(find.byType(DuoMedia));
    final info = tester.getRect(find.text('16:9 · ${en.photo}'));
    expect(info.top, greaterThanOrEqualTo(media.bottom));
    await shot(tester, '07_tabletop_photo');
  });

  testWidgets('media fit modes', (tester) async {
    await launch(tester);
    await pose(tester, 'openLandscape');
    await tab(tester, 'Gallery');
    await tester.tap(
      find
          .descendant(of: find.byType(GridView), matching: find.byType(Hero))
          .first,
    );
    await tester.pumpAndSettle();
    for (final fit in ['contain', 'cover', 'smart']) {
      await tester.tap(find.byTooltip(fit));
      await tester.pumpAndSettle();
      expect(find.textContaining('$fit ·'), findsOneWidget);
      await shot(tester, '08_media_$fit');
    }
  });

  testWidgets('arabic mirrors the panes, split stays on the fold', (
    tester,
  ) async {
    await launch(tester);
    await pose(tester, 'openLandscape');
    await tester.tap(track);
    await tester.pumpAndSettle();
    final ltrList = tester.getCenter(listScrollable()).dx;

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();
    expect(find.text(ar.tabs.first), findsWidgets);
    expect(tester.getCenter(listScrollable()).dx, greaterThan(ltrList));
    await shot(tester, '09_arabic_open');

    await pose(tester, 'foldableBook');
    await shot(tester, '10_arabic_book');
  });

  testWidgets('dialog and card stay on the simulated screen', (tester) async {
    await launch(tester);
    await pose(tester, 'foldableBook');
    await tab(tester, 'Lab');
    final screen = tester.getRect(find.byType(DuoSimulator));

    await tester.tap(find.text(en.dialog));
    await tester.pumpAndSettle();
    expect(screen.contains(tester.getCenter(find.byType(AlertDialog))), isTrue);
    await tester.tap(find.text(en.ok));
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.popCard));
    await tester.pumpAndSettle();
    final card = tester.getRect(find.text(en.cardBody));
    // one half of the book, never across the hinge
    final hinge = screen.left + screen.width / 2;
    expect(card.right <= hinge || card.left >= hinge, isTrue);
    await shot(tester, '11_avoid_fold_card');
  });

  testWidgets('help sheet explains the lab', (tester) async {
    await launch(tester);
    await tester.tap(find.byTooltip('How to test'));
    await tester.pumpAndSettle();
    expect(find.text('How to test duo_dynamic_sizing'), findsOneWidget);
    await shot(tester, '12_help');
  });

  testWidgets('hinge slider bends the simulated Duo', (tester) async {
    await launch(tester);
    await pose(tester, 'openLandscape');
    await tab(tester, 'Lab');
    final slider = find.byType(Slider);
    expect(slider, findsOneWidget);
    final track = tester.getRect(slider);

    // about 110°, half open like a book: the 40 pt fold splits the panes
    await tester.tapAt(Offset(track.left + track.width * .55, track.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('book'), findsOneWidget);
    expect(find.textContaining('partiallyOpen'), findsOneWidget);
    await shot(tester, '14_hinge_book');

    // all the way open again: flat
    await tester.tapAt(Offset(track.right - 2, track.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('flat'), findsOneWidget);
    expect(find.textContaining('fullyOpen'), findsOneWidget);

    // picking a pose resets the hinge
    await pose(tester, 'openPortrait');
    expect(find.text('flat'), findsNothing);
  });

  testWidgets('glass button puts the rail on glass', (tester) async {
    await launch(tester);
    await pose(tester, 'openLandscape');
    // on by default on iOS only
    final before = find.byType(DuoGlass).evaluate().isNotEmpty;
    await tester.tap(find.byTooltip('Glass rail'));
    await tester.pumpAndSettle();
    expect(find.byType(DuoGlass).evaluate().isNotEmpty, !before);
    if (!before) await shot(tester, '15_glass_rail');
    await tester.tap(find.byTooltip('Glass rail'));
    await tester.pumpAndSettle();
    expect(find.byType(DuoGlass).evaluate().isNotEmpty, before);
  });

  testWidgets(
    'this device: live window resizing on macOS',
    (tester) async {
      await launch(tester, const Size(1280, 800));
      await pose(tester, 'real device');
      await tab(tester, 'Lab');

      final windows = {
        'desktop': const Size(1280, 800),
        'closedPortrait': const Size(420, 860),
        'closedLandscape': const Size(760, 440),
      };
      for (final MapEntry(key: mode, value: size) in windows.entries) {
        await resize(tester, size);
        expect(find.text(mode), findsWidgets, reason: '$size');
        await shot(
          tester,
          '13_mac_${mode}_${size.width.round()}x${size.height.round()}',
        );
      }
      await resize(tester, const Size(420, 860));
      expect(find.byType(NavigationBar), findsOneWidget);
    },
    skip: defaultTargetPlatform != TargetPlatform.macOS,
  );
}
