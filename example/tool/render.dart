// renders the README / pub.dev visuals from the real widgets. from example/:
//   flutter test tool/render.dart && python3 ../tool/pack_visuals.py
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:duo_dynamic_sizing_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const ink = Color(0xFF0A0B14);
const muted = Color(0xFF9AA0B8);
const violet = Color(0xFFA855F7);
const cyan = Color(0xFF22D3EE);
const out = 'build/visuals';

void main() {
  setUpAll(_loadFonts);

  testWidgets('iphone duo gallery', (tester) async {
    await _shoot(tester, const Size(1400, 1290), _duoGallery(), 'iphone-duo');
  });

  testWidgets('everywhere gallery', (tester) async {
    await _shoot(tester, const Size(1560, 900), _elsewhere(), 'everywhere');
  });

  testWidgets('social preview', (tester) async {
    await _shoot(tester, const Size(1280, 640), _social(), 'social', ratio: 1);
  });

  testWidgets('fold animation', (tester) async {
    final t = ValueNotifier(0.0);
    final frames = <Map<String, Object>>[];
    Future<void> frame(double v, int ms) async {
      t.value = v;
      final name = 'fold_${frames.length.toString().padLeft(3, '0')}';
      await _shoot(
        tester,
        const Size(1200, 720),
        ValueListenableBuilder(
          valueListenable: t,
          builder: (_, v, _) => _FoldScene(v),
        ),
        name,
        ratio: 1.2,
      );
      frames.add({'file': '$name.png', 'ms': ms});
    }

    const steps = 26;
    await frame(0, 1100);
    for (var i = 1; i < steps; i++) {
      await frame(i / steps, 42);
    }
    await frame(1, 2200);
    for (var i = steps - 1; i > 0; i--) {
      await frame(i / steps, 42);
    }
    File('$out/fold.json').writeAsStringSync(jsonEncode(frames));
  });
}

Future<void> _loadFonts() async {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      File(
        Platform.resolvedExecutable,
      ).parent.parent.parent.parent.parent.parent.path;
  final dir = '$root/bin/cache/artifacts/material_fonts';
  Future<ByteData> bytes(String f) async =>
      ByteData.sublistView(await File('$dir/$f').readAsBytes());
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold', 'Black']) {
    roboto.addFont(bytes('Roboto-$w.ttf'));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(bytes('MaterialIcons-Regular.otf'))).load();
}

Future<void> _shoot(
  WidgetTester tester,
  Size size,
  Widget scene,
  String name, {
  double ratio = 1.5,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  debugDisableShadows = false;
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(key: key, child: scene),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: ratio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(out).createSync(recursive: true);
    File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
  debugDisableShadows = true;
}

TextStyle _text(double size, {Color color = Colors.white, FontWeight? w}) =>
    TextStyle(
      fontFamily: 'Roboto',
      fontSize: size,
      color: color,
      fontWeight: w,
      letterSpacing: size > 30 ? -1 : 0,
      decoration: TextDecoration.none,
    );

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child, this.radius = 0});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(painter: _GlowPainter(), child: child),
    );
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = ink);
    void glow(Alignment at, Color color, double r) {
      final c = at.withinRect(rect);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = ui.Gradient.radial(c, r, [
            color.withValues(alpha: .28),
            color.withValues(alpha: 0),
          ]),
      );
    }

    glow(const Alignment(-.9, -1), const Color(0xFF6D5DFC), size.width * .55);
    glow(const Alignment(1, 1), cyan, size.width * .4);
    final dot = Paint()..color = Colors.white.withValues(alpha: .045);
    for (var x = 12.0; x < size.width; x += 28) {
      for (var y = 12.0; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.1, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_GlowPainter old) => false;
}

class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final body = RRect.fromLTRBR(6, 14, 94, 86, const Radius.circular(18));
    canvas
      ..save()
      ..clipRRect(body)
      ..drawRect(
        const Rect.fromLTRB(6, 14, 50, 86),
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(6, 14),
            const Offset(50, 86),
            [const Color(0xFF8B7CFF), const Color(0xFF5B4BEF)],
          ),
      )
      ..drawRect(
        const Rect.fromLTRB(50, 14, 94, 86),
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(50, 14),
            const Offset(94, 86),
            [const Color(0xFFC084FC), const Color(0xFF8B3FF0)],
          ),
      );
    final white = Paint()..color = Colors.white.withValues(alpha: .9);
    for (final y in [28.0, 42.0, 56.0]) {
      canvas
        ..drawCircle(Offset(18, y + 3), 4, white)
        ..drawRRect(
          RRect.fromLTRBR(26, y, 42, y + 6, const Radius.circular(3)),
          white,
        );
    }
    canvas
      ..drawRRect(
        RRect.fromLTRBR(58, 26, 86, 56, const Radius.circular(6)),
        white,
      )
      ..drawRRect(
        RRect.fromLTRBR(58, 62, 80, 68, const Radius.circular(3)),
        white,
      )
      ..restore()
      ..drawLine(
        const Offset(50, 10),
        const Offset(50, 90),
        Paint()
          ..color = cyan.withValues(alpha: .55)
          ..strokeWidth = 9
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawLine(
        const Offset(50, 10),
        const Offset(50, 90),
        Paint()
          ..color = const Color(0xFFCFFAFE)
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_LogoPainter old) => false;
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Logo(size: 30),
      const SizedBox(width: 10),
      Text(
        'duo_dynamic_sizing',
        style: _text(17, color: muted, w: FontWeight.w500),
      ),
    ],
  );
}

class Frame extends StatelessWidget {
  const Frame({
    super.key,
    required this.size,
    required this.child,
    this.radius = 20,
    this.overlay,
    this.corners,
  });

  final Size size;
  final Widget child;
  final double radius;
  final Widget? overlay;
  final BorderRadius? corners;

  @override
  Widget build(BuildContext context) {
    const bezel = 5.0;
    final inner = corners ?? BorderRadius.circular(radius);
    final outer =
        inner.resolve(TextDirection.ltr) + BorderRadius.circular(bezel);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF040406),
        borderRadius: outer,
        border: Border.all(color: const Color(0xFF4A4A57), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xA6000000),
            blurRadius: 50,
            offset: Offset(0, 30),
          ),
          BoxShadow(color: Color(0x2E6D5DFC), blurRadius: 90, spreadRadius: -8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(bezel),
        child: ClipRRect(
          borderRadius: inner,
          child: SizedBox.fromSize(
            size: size,
            child: Stack(fit: StackFit.expand, children: [child, ?overlay]),
          ),
        ),
      ),
    );
  }
}

class Device extends StatelessWidget {
  const Device(this.pose, this.app, {super.key, this.scale = .5});

  final DuoPose pose;
  final Widget app;
  final double scale;

  @override
  Widget build(BuildContext context) => Frame(
    size: pose.size * scale,
    radius: (pose == DuoPose.iPad ? 22 : 44) * scale,
    overlay: IgnorePointer(child: _Island(pose, scale)),
    child: DuoSimulator(pose: pose, child: app),
  );
}

class _Island extends StatelessWidget {
  const _Island(this.pose, this.s);

  final DuoPose pose;
  final double s;

  @override
  Widget build(BuildContext context) {
    final p = pose.padding;
    Widget pill(double w, double h) => Container(
      width: w * s,
      height: h * s,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(99),
      ),
    );
    if (pose == DuoPose.iPad) return const SizedBox();
    if (pose.platform == TargetPlatform.android) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 12 * s),
          child: pill(12, 12),
        ),
      );
    }
    if (pose == DuoPose.iPhone) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 11 * s),
          child: pill(124, 36),
        ),
      );
    }
    if (p.right > 0) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(right: (p.right - 22) / 2 * s, top: 44 * s),
          child: pill(22, 78),
        ),
      );
    }
    if (p.top > 0) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: (p.top - 22) / 2 * s, right: 44 * s),
          child: pill(78, 22),
        ),
      );
    }
    return const SizedBox();
  }
}

class _SplitDevice extends StatelessWidget {
  const _SplitDevice();

  static const scale = .5;

  @override
  Widget build(BuildContext context) {
    final half = DuoPose.splitLeft.size * scale;
    return Frame(
      size: DuoPose.openLandscape.size * scale,
      radius: 44 * scale,
      overlay: IgnorePointer(child: _Island(DuoPose.openLandscape, scale)),
      child: ColoredBox(
        color: Colors.black,
        child: Row(
          children: [
            SizedBox.fromSize(
              size: half,
              child: const DuoSimulator(
                pose: DuoPose.splitLeft,
                child: MailApp(debugOverlay: false),
              ),
            ),
            SizedBox.fromSize(
              size: half,
              child: const DuoSimulator(
                pose: DuoPose.splitRight,
                child: MailApp(debugOverlay: false, initialTab: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shot extends StatelessWidget {
  const _Shot(this.device, this.title, this.caption);

  final Widget device;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      device,
      const SizedBox(height: 22),
      Text(title, style: _text(19, w: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(caption, style: _text(14, color: muted)),
    ],
  );
}

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.title,
    required this.subtitle,
    required this.rows,
  });

  final String title;
  final String subtitle;
  final List<List<Widget>> rows;

  @override
  Widget build(BuildContext context) => _Backdrop(
    radius: 36,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(64, 52, 64, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Brand(),
          const SizedBox(height: 18),
          Text(title, style: _text(44, w: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, style: _text(18, color: muted)),
          const Spacer(),
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: 56),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: row,
            ),
          ],
          const Spacer(),
        ],
      ),
    ),
  );
}

Widget _duoGallery() => const _Gallery(
  title: 'iPhone Duo, every pose.',
  subtitle:
      'Real renders of duo_dynamic_sizing. One codebase, zero native code.',
  rows: [
    [
      _Shot(
        Device(DuoPose.closedPortrait, MailApp(debugOverlay: false)),
        'Closed',
        '466 × 678 · one pane, rail by the island',
      ),
      _Shot(
        Device(
          DuoPose.openLandscape,
          MailApp(debugOverlay: false, initialMail: 1),
        ),
        'Open',
        '951 × 669 · list + detail, split at the fold',
      ),
      _Shot(
        Device(
          DuoPose.openPortrait,
          MailApp(debugOverlay: false, initialMail: 2),
        ),
        'Open, upright',
        '669 × 951 · two panes, bottom bar',
      ),
    ],
    [
      _Shot(
        Device(
          DuoPose.closedLandscape,
          MailApp(debugOverlay: false, initialTab: 1),
        ),
        'Closed, sideways',
        '678 × 466 · one pane, media fit',
      ),
      _Shot(
        _SplitDevice(),
        'Split View',
        '475 × 669 each · every app gets its own rail side',
      ),
    ],
  ],
);

Widget _elsewhere() => const _Gallery(
  title: 'And every other screen.',
  subtitle: 'Same widgets on phones, Android foldables, tablets and desktop.',
  rows: [
    [
      _Shot(
        Device(DuoPose.iPhone, MailApp(debugOverlay: false)),
        'iPhone',
        '402 × 874 · bottom bar',
      ),
      _Shot(
        Device(
          DuoPose.foldableBook,
          MailApp(debugOverlay: false, initialMail: 3),
        ),
        'Android fold, book',
        'panes split right at the hinge',
      ),
      _Shot(
        Device(
          DuoPose.foldableTabletop,
          MailApp(debugOverlay: false, initialTab: 1),
        ),
        'Android fold, tabletop',
        'video up top, controls below the fold',
      ),
      _Shot(
        Device(
          DuoPose.iPad,
          MailApp(debugOverlay: false, initialMail: 4),
          scale: .4,
        ),
        'iPad',
        '1032 × 1376 · list + detail, side rail',
      ),
    ],
  ],
);

Widget _social() => _Backdrop(
  child: Stack(
    children: [
      Positioned(
        left: 72,
        top: 0,
        bottom: 0,
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Logo(size: 84),
            const SizedBox(height: 28),
            Text('duo_dynamic_sizing', style: _text(46, w: FontWeight.w800)),
            const SizedBox(height: 14),
            Text(
              'Adaptive layout for the foldable iPhone Duo and every other screen.',
              style: _text(
                23,
                color: const Color(0xFFD4D7E6),
                w: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final c in [
                  'Pure Dart',
                  'Fold aware',
                  'Split View',
                  'Android foldables',
                ])
                  _Chip(c),
              ],
            ),
          ],
        ),
      ),
      const Positioned(
        right: 44,
        top: 140,
        child: Device(
          DuoPose.openLandscape,
          MailApp(debugOverlay: false, initialMail: 1),
          scale: .54,
        ),
      ),
      const Positioned(
        right: 424,
        top: 250,
        child: Device(
          DuoPose.closedPortrait,
          MailApp(debugOverlay: false),
          scale: .5,
        ),
      ),
    ],
  ),
);

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(99),
      color: Colors.white.withValues(alpha: .06),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: Text(
      label,
      style: _text(15, color: const Color(0xFFE4E6F0), w: FontWeight.w500),
    ),
  );
}

class _FoldScene extends StatelessWidget {
  const _FoldScene(this.t);

  final double t;

  static const s = .62;

  @override
  Widget build(BuildContext context) {
    final e = Curves.easeInOutCubic.transform(t);
    final theta = e * math.pi;
    final closed = DuoPose.closedPortrait.size * s;
    final open = DuoPose.openLandscape.size * s;
    const cx = 600.0, cy = 362.0;
    final half = open.width / 2;
    final hinge = ui.lerpDouble(cx - closed.width / 2, cx, e)!;
    final r = 44 * s;
    const outerApp = MailApp(debugOverlay: false, initialMail: 2);
    const innerApp = MailApp(debugOverlay: false, initialMail: 2);

    Widget innerHalf(bool left) => SizedBox(
      width: half,
      height: open.height,
      child: ClipRect(
        child: OverflowBox(
          alignment: left ? Alignment.centerLeft : Alignment.centerRight,
          maxWidth: open.width,
          minWidth: open.width,
          child: const DuoSimulator(
            pose: DuoPose.openLandscape,
            child: innerApp,
          ),
        ),
      ),
    );
    Widget shade(Widget child, double a) => Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: Colors.black.withValues(alpha: a)),
          ),
        ),
      ],
    );
    final persp = Matrix4.identity()..setEntry(3, 2, .0011);

    final List<Widget> device;
    if (t == 0) {
      device = [
        Positioned(
          left: cx - closed.width / 2 - 5,
          top: cy - closed.height / 2 - 5,
          child: Device(DuoPose.closedPortrait, outerApp, scale: s),
        ),
      ];
    } else if (t == 1) {
      device = [
        Positioned(
          left: cx - open.width / 2 - 5,
          top: cy - open.height / 2 - 5,
          child: Device(DuoPose.openLandscape, innerApp, scale: s),
        ),
      ];
    } else {
      final lift = math.sin(theta);
      device = [
        Positioned(
          left: hinge - 5,
          top: cy - open.height / 2 - 5,
          child: Frame(
            size: Size(half, open.height),
            corners: BorderRadius.horizontal(right: Radius.circular(r)),
            child: shade(innerHalf(false), .18 * (1 - e)),
          ),
        ),
        if (theta < math.pi / 2)
          Positioned(
            left: hinge - 5,
            top: cy - closed.height / 2 - 5,
            child: Transform(
              alignment: Alignment.centerLeft,
              transform: persp.clone()..rotateY(-theta),
              child: shade(
                Device(DuoPose.closedPortrait, outerApp, scale: s),
                .3 * lift,
              ),
            ),
          )
        else
          Positioned(
            left: hinge - half - 5,
            top: cy - open.height / 2 - 5,
            child: Transform(
              alignment: Alignment.centerRight,
              transform: persp.clone()..rotateY(math.pi - theta),
              child: Frame(
                size: Size(half, open.height),
                corners: BorderRadius.horizontal(left: Radius.circular(r)),
                child: shade(innerHalf(true), .28 * lift),
              ),
            ),
          ),
      ];
    }

    return _Backdrop(
      child: Stack(
        children: [
          const Positioned(left: 48, top: 40, child: _Brand()),
          Positioned(
            left: 0,
            right: 0,
            top: 88,
            child: Text(
              'Fold it. Unfold it. Nothing resets.',
              textAlign: TextAlign.center,
              style: _text(34, w: FontWeight.w800),
            ),
          ),
          ...device,
          Positioned(
            left: 0,
            right: 0,
            bottom: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: (1 - e * 2).clamp(0, 1),
                  child: const _ModePill(
                    'closedPortrait',
                    '466 × 678',
                    'one pane, same email open',
                  ),
                ),
                Opacity(
                  opacity: ((e - .5) * 2).clamp(0, 1),
                  child: const _ModePill(
                    'openLandscape',
                    '951 × 669',
                    'list + detail, split at the fold',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill(this.mode, this.size, this.what);

  final String mode;
  final String size;
  final String what;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(99),
      color: Colors.white.withValues(alpha: .06),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: cyan, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(mode, style: _text(16, w: FontWeight.w700)),
        Text(
          '   $size   ',
          style: _text(16, color: violet, w: FontWeight.w500),
        ),
        Text(what, style: _text(16, color: muted)),
      ],
    ),
  );
}
