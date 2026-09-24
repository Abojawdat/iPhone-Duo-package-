// pixel goldens per pose. made on macOS (fonts render diffrent elsewhere):
//   flutter test --update-goldens test/golden_test.dart
import 'dart:io';

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final skip = !Platform.isMacOS;

Future<void> loadFonts() async {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      File(
        Platform.resolvedExecutable,
      ).parent.parent.parent.parent.parent.parent.path;
  final dir = '$root/bin/cache/artifacts/material_fonts';
  Future<ByteData> bytes(String f) async =>
      ByteData.sublistView(await File('$dir/$f').readAsBytes());
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(bytes('Roboto-$w.ttf'));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(bytes('MaterialIcons-Regular.otf'))).load();
}

Widget inbox({TextDirection direction = TextDirection.ltr}) => Directionality(
  textDirection: direction,
  child: DuoNavigationScaffold(
    appBar: AppBar(title: const Text('Inbox')),
    selectedIndex: 0,
    onDestinationSelected: (_) {},
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.edit),
    ),
    destinations: const [
      DuoDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
      DuoDestination(icon: Icon(Icons.play_circle), label: 'Watch'),
      DuoDestination(icon: Icon(Icons.devices_fold), label: 'Device'),
    ],
    body: DuoListDetail<int>(
      selected: 1,
      onClose: () {},
      list: (_) => ListView(
        children: [
          for (var i = 0; i < 14; i++)
            ListTile(
              selected: i == 1,
              leading: CircleAvatar(child: Text('$i')),
              title: Text('Mail $i'),
              subtitle: const Text('Fold it, unfold it, nothing resets.'),
            ),
        ],
      ),
      detail: (context, i) => Padding(
        padding: EdgeInsets.all(context.duo.margin),
        child: Text(
          'Mail $i\n\n${context.duo}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ),
  ),
);

Widget tabletopMedia() => Scaffold(
  body: DuoSplit(
    primary: const DuoMedia(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: Color(0xFF6D5DFC),
        child: Center(
          child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
        ),
      ),
    ),
    secondary: Center(
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.play_arrow),
        label: const Text('Play'),
      ),
    ),
  ),
);

Future<void> golden(
  WidgetTester tester,
  DuoPose pose,
  Widget home,
  String name,
) async {
  tester.view
    ..physicalSize = pose.size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: DuoSimulator(
        pose: pose,
        showGuides: true,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: const Color(0xFF6D5DFC)),
          home: home,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(find.byKey(key), matchesGoldenFile('goldens/$name.png'));
}

void main() {
  setUpAll(loadFonts);

  for (final pose in DuoPose.values) {
    testWidgets('golden ${pose.name}', skip: skip, (tester) async {
      await golden(tester, pose, inbox(), pose.name);
    });
  }

  testWidgets('golden openLandscape rtl', skip: skip, (tester) async {
    await golden(
      tester,
      DuoPose.openLandscape,
      inbox(direction: TextDirection.rtl),
      'openLandscape_rtl',
    );
  });

  testWidgets('golden tabletop media', skip: skip, (tester) async {
    await golden(
      tester,
      DuoPose.foldableTabletop,
      tabletopMedia(),
      'foldableTabletop_media',
    );
  });
}
