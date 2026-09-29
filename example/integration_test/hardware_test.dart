// the real native side on whatever device runs it:
//   flutter test integration_test/hardware_test.dart -d <device>
import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the live hinge data matches the platform', (tester) async {
    final seen = <DuoData>[];
    await tester.pumpWidget(
      DuoHardwareScope(
        bridge: DuoBridge.all,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              seen.add(context.duo);
              return const Scaffold(body: SizedBox.expand());
            },
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final duo = seen.last;
    final native = await DuoHardware.describeNative();
    debugPrint('DUO ${duo.hardware}\nDUO $duo\nDUO native: $native');

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // a foldable emulator has a hinge angle sensor
        expect(native, contains('Android'));
        if (duo.hardware.hasHinge) {
          expect(duo.hardware.supported, isTrue);
          // null until the hinge moves when Android has no reading since
          // the last wake, posture still comes from the display feature
          if (duo.hardware.angle case final a?) {
            expect(a, inInclusiveRange(0, 180));
          }
        }
        expect(duo.isIphoneDuo, isFalse);
      case TargetPlatform.iOS:
        // iOS before 27.1: the plugin runs but reports nothing
        expect(native, contains('hinge interaction'));
        expect(duo.hardware.hasHinge, isFalse);
        expect(duo.hardware.folds, isEmpty);
        expect(
          duo.hardware.horizontalSizeClass,
          isNot(DuoSizeClass.unspecified),
        );
      default:
        expect(duo.hardware, DuoHardware.none);
        expect(native, contains('No native side'));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('glass rail builds and stays tappable', (tester) async {
    var picked = 0;
    tester.view.physicalSize =
        const Size(1200, 800) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => DuoNavigationScaffold(
            glass: true,
            railSide: DuoRailSide.left,
            selectedIndex: picked,
            onDestinationSelected: (i) => setState(() => picked = i),
            destinations: const [
              DuoDestination(icon: Icon(Icons.home), label: 'Home'),
              DuoDestination(icon: Icon(Icons.star), label: 'Star'),
            ],
            body: ListView(
              children: [
                for (var i = 0; i < 40; i++)
                  ListTile(
                    title: Text('row $i'),
                    tileColor: Colors.primaries[i % 18],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DuoGlass), findsOneWidget);
    await tester.tap(find.text('Star'));
    await tester.pumpAndSettle();
    expect(picked, 1);
    // glass survives a resize, like a rotation or a fold
    tester.view.physicalSize =
        const Size(900, 1200) * tester.view.devicePixelRatio;
    await tester.pumpAndSettle();
    tester.view.physicalSize =
        const Size(1200, 800) * tester.view.devicePixelRatio;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
