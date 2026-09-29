// watches a live fold for 30 s, fold the device (or the emulator's hinge
// sensor) while it runs:
//   flutter test integration_test/fold_sweep_test.dart -d <device>
import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // frames follow the device, even while it sits closed with no frames
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('follows a live fold without errors', (tester) async {
    final seen = <DuoData>[];
    final angles = <double>{};
    await tester.pumpWidget(
      DuoHardwareScope(
        bridge: DuoBridge.all,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              seen.add(context.duo);
              if (DuoHardware.angleOf(context) case final a?) angles.add(a);
              return Scaffold(
                body: DuoSplit(
                  primary: const ColoredBox(color: Colors.red),
                  secondary: const ColoredBox(color: Colors.blue),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    if (!seen.last.hardware.hasHinge) {
      return markTestSkipped('No hinge on this device.');
    }
    for (var i = 0; i < 60; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      expect(tester.takeException(), isNull);
    }
    final postures = seen.map((d) => d.posture).toSet();
    debugPrint(
      'DUO postures $postures angles ${angles.map((a) => a.round()).toSet()}',
    );
    debugPrint('DUO modes ${seen.map((d) => d.mode).toSet()}');
    expect(angles.length, greaterThan(2));
    expect(postures, containsAll([DuoPosture.book, DuoPosture.closed]));
  });
}
