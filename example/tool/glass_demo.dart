// real Liquid Glass for doc/glass.webp: two Duo screens at 1:1, dark and
// light, on the iPad Pro 13-inch simulator (iOS 26+). screenshot it, then
// python3 ../tool/crop_glass.py <screenshot.png>
import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:duo_dynamic_sizing_example/main.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(
  Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: const Color(0xFF0A0B14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final dark in [true, false]) ...[
            SizedBox.fromSize(
              size: DuoPose.openLandscape.size,
              child: DuoSimulator(
                pose: DuoPose.openLandscape,
                child: DuoApp(dark: dark, glass: true, initialTrack: 1),
              ),
            ),
            const SizedBox(height: 7),
          ],
        ],
      ),
    ),
  ),
);
