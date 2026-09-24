// drives the real showcase app. screenshots come back thru flutter drive:
//   flutter drive -d macos --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
// or just the checks: flutter test integration_test -d macos
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:duo_dynamic_sizing_example/main.dart';
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
    Size window = const Size(1400, 900),
  ]) async {
    tester.view.physicalSize = window * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      RepaintBoundary(key: root, child: const Showcase()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pose(WidgetTester tester, String name) async {
    await tester.tap(find.widgetWithText(ChoiceChip, name));
    await tester.pumpAndSettle();
  }

  Future<void> resize(WidgetTester tester, Size window) async {
    tester.view.physicalSize = window * tester.view.devicePixelRatio;
    await tester.pumpAndSettle();
  }

  bool railOnRight(WidgetTester tester) {
    final rail = tester.getCenter(find.byType(NavigationRail)).dx;
    final list = tester.getCenter(find.byType(DuoListDetail<int>)).dx;
    return rail > list;
  }

  double listScroll(WidgetTester tester) => tester
      .state<ScrollableState>(
        find
            .descendant(
              of: find.byType(DuoListDetail<int>),
              matching: find.byType(Scrollable),
            )
            .first,
      )
      .position
      .pixels;

  final mail = find.text('Omar Khalil').first;
  final mailList = find
      .descendant(
        of: find.byType(DuoListDetail<int>),
        matching: find.byType(ListView),
      )
      .first;
  final subject = find.text('Split View feedback');

  testWidgets('open Duo: list, then list + detail', (tester) async {
    await launch(tester);
    expect(find.text('Pick an email'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(railOnRight(tester), isTrue);
    await shot(tester, '01_open_empty');

    await tester.tap(mail);
    await tester.pumpAndSettle();
    expect(subject, findsWidgets);
    expect(find.text('Pick an email'), findsNothing);
    await shot(tester, '02_open_detail');
  });

  testWidgets('fold keeps the email, back shows the list', (tester) async {
    await launch(tester);
    await tester.tap(mail);
    await tester.pumpAndSettle();

    await pose(tester, 'closedPortrait');
    expect(find.textContaining('Fold the phone'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    expect(railOnRight(tester), isTrue);
    await shot(tester, '03_closed_detail');

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Close'), findsNothing);
    await shot(tester, '04_closed_list');
  });

  testWidgets('list scroll survives fold and unfold', (tester) async {
    await launch(tester);
    await pose(tester, 'closedPortrait');
    await tester.drag(
      find
          .descendant(
            of: find.byType(DuoListDetail<int>),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();
    final before = listScroll(tester);
    expect(before, greaterThan(0));

    await pose(tester, 'openLandscape');
    expect(listScroll(tester), before);
    await pose(tester, 'closedPortrait');
    expect(listScroll(tester), before);
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

  testWidgets('tabletop: video above the fold, controls below', (tester) async {
    await launch(tester);
    await pose(tester, 'foldableTabletop');
    await tester.tap(find.text('Watch').last);
    await tester.pumpAndSettle();
    final media = tester.getRect(find.byType(DuoMedia));
    final controls = tester.getRect(find.byIcon(Icons.play_arrow));
    expect(controls.top, greaterThan(media.bottom));
    await shot(tester, '06_tabletop_watch');
  });

  testWidgets('media fit modes', (tester) async {
    await launch(tester);
    await tester.tap(find.text('Watch').last);
    await tester.pumpAndSettle();
    for (final fit in ['contain', 'cover', 'smart']) {
      await tester.tap(find.text(fit));
      await tester.pumpAndSettle();
      await shot(tester, '07_media_$fit');
    }
  });

  testWidgets('rtl mirrors the panes, split stays on the fold', (tester) async {
    await launch(tester);
    await tester.tap(mail);
    await tester.pumpAndSettle();
    final ltrList = tester.getCenter(mailList).dx;

    await tester.tap(find.widgetWithText(FilterChip, 'RTL'));
    await tester.pumpAndSettle();
    final rtlList = tester.getCenter(mailList).dx;
    expect(rtlList, greaterThan(ltrList));
    await shot(tester, '08_rtl_open');

    await pose(tester, 'foldableBook');
    await shot(tester, '09_rtl_book');
  });

  testWidgets('compose dialog stays on the simulated screen', (tester) async {
    await launch(tester);
    await tester.tap(find.byTooltip('Compose'));
    await tester.pumpAndSettle();
    final dialog = tester.getRect(find.byType(AlertDialog));
    final screen = tester.getRect(find.byType(DuoSimulator));
    expect(screen.contains(dialog.center), isTrue);
    await shot(tester, '10_compose_dialog');
  });

  testWidgets('this device: live window resizing on macOS', (tester) async {
    await launch(tester, const Size(1280, 800));
    await tester.tap(find.text('This device'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Device').last);
    await tester.pumpAndSettle();

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
        '11_mac_${mode}_${size.width.round()}x${size.height.round()}',
      );
    }
    await resize(tester, const Size(420, 860));
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
