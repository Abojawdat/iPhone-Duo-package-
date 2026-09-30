// real Liquid Glass for doc/glass.webp, at 1:1 on the iPad Pro 13-inch
// simulator (iOS 26+): the open Duo with its glass rail, dark, then after 15 s
// the upright Duo with its floating glass bar, light. screenshot each, then
// python3 ../tool/crop_glass.py rail.png bar.png
import 'dart:async';

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:duo_dynamic_sizing_example/main.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(const _Demo());

class _Demo extends StatefulWidget {
  const _Demo();

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  var rail = true;
  Timer? _flip;

  @override
  void initState() {
    super.initState();
    _flip = Timer(
      const Duration(seconds: 15),
      () => setState(() => rail = false),
    );
  }

  @override
  void dispose() {
    _flip?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pose = rail ? DuoPose.openLandscape : DuoPose.openPortrait;
    // centred, 24 pt from the top: crop_glass.py expects exactly this
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFF0A0B14),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: SizedBox.fromSize(
              size: pose.size,
              child: DuoSimulator(
                key: ValueKey(rail),
                pose: pose,
                child: DuoApp(dark: rail, glass: true, initialTrack: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
