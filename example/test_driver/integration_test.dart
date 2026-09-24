import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

// writes the screenshots the app sends back into build/screens
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    final shots = (data?['screenshots'] as Map?) ?? const {};
    final dir = Directory('build/screens')..createSync(recursive: true);
    for (final e in shots.entries) {
      File(
        '${dir.path}/${e.key}.png',
      ).writeAsBytesSync(base64Decode(e.value as String));
    }
    stdout.writeln('saved ${shots.length} screenshots to ${dir.path}');
  },
);
