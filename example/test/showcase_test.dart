import 'package:duo_dynamic_sizing_example/fold_view.dart';
import 'package:duo_dynamic_sizing_example/showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> run(WidgetTester tester, [int frames = 90]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('opens by itself, then goes through every pose', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const Showcase());
    await run(tester, 150);
    expect(find.text('180°'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.grid_view));
    await run(tester, 10);
    for (final (key, _, _) in scenes) {
      await tester.tap(find.byKey(ValueKey(key)));
      await run(tester);
      expect(tester.takeException(), isNull, reason: key);
      await tester.tap(find.byIcon(Icons.grid_view));
      await run(tester, 10);
    }
  });

  testWidgets('dragging the handle closes it onto the cover screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const Showcase(opening: false));
    await run(tester, 10);
    expect(find.text('180°'), findsOneWidget);

    await tester.drag(
      find.byIcon(Icons.back_hand_outlined),
      const Offset(-400, 0),
    );
    await run(tester);
    expect(find.text('0°'), findsOneWidget);
    expect(find.text('Closed'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('every hold lays out and keeps a lit screen reachable', () {
    for (final (key, _, hold) in scenes) {
      for (final angle in [0.0, 10.0, 40.0, 90.0, 110.0, 150.0, 180.0]) {
        final fold = Fold3D(
          FoldShape(
            inner: innerOf(hold.kind, hold.turned),
            cover: coverOf(hold.kind, hold.turned),
            angle: angle,
            sideways: hold.turned,
          ),
          const Size(900, 600),
        );
        expect(fold.scale.isFinite && fold.scale > 0, isTrue, reason: key);
        expect(fold.grip.isFinite, isTrue, reason: '$key $angle');
        expect(fold.touch, isNotEmpty, reason: '$key $angle');
      }
    }
  });
}
