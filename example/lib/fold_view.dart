import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// how the device is being held, in the screen's own points
@immutable
class FoldShape {
  const FoldShape({
    required this.inner,
    this.cover,
    this.angle = 180,
    this.sideways = false,
    this.radius = 44,
    this.island,
    this.spin = 0,
    this.tilt = Offset.zero,
  });

  // the unfolded screen
  final Size inner;
  // the outer screen, null on a phone that doesnt fold
  final Size? cover;
  // hinge in degrees, 0 shut and 180 flat
  final double angle;
  // the fold runs across instead of down
  final bool sideways;
  final double radius;
  // on whichever screen is lit
  final Rect? island;
  // radians, while the device is being turned
  final double spin;
  final Offset tilt;

  static const shutBelow = 28.0;

  bool get folds => cover != null;
  bool get shut => folds && angle < shutBelow;
  // the screen the app is laid out on right now
  Size get display => shut ? cover! : inner;
}

// the bent device worked out for one stage size, shared by paint and touch
class Fold3D {
  Fold3D(this.shape, this.stage) {
    final w = shape.inner.width, h = shape.inner.height;
    final across = shape.sideways;
    final bend = shape.folds ? (180 - shape.angle) / 2 * _deg : 0.0;
    final closing = shape.folds ? 1 - _smooth(shape.angle / 100) : 0.0;
    final reveal = 78 * _deg * closing;
    // on a table the lower half lies back and the upper one stands
    final lean = across && shape.folds
        ? -math.min(1.26 * bend, 75 * _deg - bend).clamp(0.0, 75 * _deg)
        : 0.0;

    halves = across
        ? [Rect.fromLTWH(0, 0, w, h / 2), Rect.fromLTWH(0, h / 2, w, h / 2)]
        : [Rect.fromLTWH(0, 0, w / 2, h), Rect.fromLTWH(w / 2, 0, w / 2, h)];

    final turn = Matrix4.identity();
    across ? turn.rotateX(lean - reveal) : turn.rotateY(reveal);
    final hinge = [
      for (final sign in const [-1.0, 1.0])
        across
            ? (Matrix4.identity()..rotateX(-sign * bend))
            : (Matrix4.identity()..rotateY(sign * bend)),
    ];

    // keep whatever is showing in the middle of the stage
    var cx = 0.0, cy = 0.0, cz = 0.0;
    for (var i = 0; i < 2; i++) {
      final sign = i == 0 ? -1.0 : 1.0;
      final p = _apply(
        turn.multiplied(hinge[i]),
        across ? 0 : sign * w / 4,
        across ? sign * h / 4 : 0,
        thick / 2,
      );
      cx += p.$1 / 2;
      cy += p.$2 / 2;
      cz += p.$3 / 2;
    }

    final fit = math.min(stage.width * .84 / w, stage.height * .8 / h);
    var zoom = 1 + .35 * closing;
    if (shape.folds) {
      final c = shape.cover!;
      zoom = math.min(
        zoom,
        math.min(stage.width * .8 / c.width, stage.height * .8 / c.height) /
            fit,
      );
    }
    scale = fit * math.max(zoom, .2);

    final view = Matrix4.identity()
      ..rotateX(shape.tilt.dy * .16)
      ..rotateY(-shape.tilt.dx * .2)
      ..rotateZ(shape.spin)
      ..translateByDouble(-cx, -cy, -cz, 1)
      ..multiply(turn);
    // perspective goes on last so it vanishes at the middle of the stage
    final lens = Matrix4.identity()
      ..translateByDouble(stage.width / 2, stage.height / 2, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1)
      ..multiply(Matrix4.identity()..setEntry(3, 2, .55 / math.max(w, h)));

    final depth = <double>[];
    for (var i = 0; i < 2; i++) {
      final body = view.multiplied(hinge[i]);
      final sign = i == 0 ? -1.0 : 1.0;
      faceUp.add(body.storage[10] > 0);
      depth.add(
        _apply(
          body,
          across ? 0 : sign * w / 4,
          across ? sign * h / 4 : 0,
          thick / 2,
        ).$3,
      );
      half.add(lens.multiplied(body)..translateByDouble(-w / 2, -h / 2, 0, 1));
    }
    order = depth[0] >= depth[1] ? const [0, 1] : const [1, 0];

    if (shape.folds) {
      final c = shape.cover!, back = halves[1].deflate(6);
      final f = math.min(back.width / c.width, back.height / c.height);
      final at = back.center - Offset(c.width, c.height) * f / 2;
      // seen from behind, so flipped back to read the right way
      final m = half[1].clone()..translateByDouble(0, 0, thick, 1);
      if (across) {
        m
          ..translateByDouble(0, 2 * halves[1].center.dy, 0, 1)
          ..scaleByDouble(1, -1, 1, 1);
      } else {
        m
          ..translateByDouble(2 * halves[1].center.dx, 0, 0, 1)
          ..scaleByDouble(-1, 1, 1, 1);
      }
      final flipped = across
          ? Offset(at.dx, 2 * halves[1].center.dy - at.dy - c.height * f)
          : Offset(2 * halves[1].center.dx - at.dx - c.width * f, at.dy);
      coverBox = flipped & (c * f);
      cover = m
        ..translateByDouble(flipped.dx, flipped.dy, 0, 1)
        ..scaleByDouble(f, f, 1, 1);
    }
  }

  final FoldShape shape;
  final Size stage;
  var _glow = 0;

  static const thick = 11.0;
  static const _layers = 5;
  static const _deg = math.pi / 180;

  late final double scale;
  late final List<Rect> halves;
  // each half's screen to the stage
  final half = <Matrix4>[];
  final faceUp = <bool>[];
  // far half first
  late final List<int> order;
  // the outer screen to the stage
  Matrix4? cover;
  Rect? coverBox;

  static double _smooth(double t) {
    final x = t.clamp(0.0, 1.0);
    return x * x * (3 - 2 * x);
  }

  static (double, double, double, double) _apply(
    Matrix4 m,
    double x,
    double y,
    double z,
  ) {
    final s = m.storage;
    return (
      s[0] * x + s[4] * y + s[8] * z + s[12],
      s[1] * x + s[5] * y + s[9] * z + s[13],
      s[2] * x + s[6] * y + s[10] * z + s[14],
      s[3] * x + s[7] * y + s[11] * z + s[15],
    );
  }

  // a point on half i, where it lands on the stage
  Offset project(int i, Offset p, [double z = 0]) {
    final r = _apply(half[i], p.dx, p.dy, z);
    return Offset(r.$1 / r.$4, r.$2 / r.$4);
  }

  // where a hand would grab to fold it: the free edge of the second half
  Offset get grip {
    final r = halves[1];
    final edge = shape.sideways ? r.bottomCenter : r.centerRight;
    return project(1, edge, faceUp[1] ? 0 : thick);
  }

  // lit screens the pointer can reach, nearest first
  List<(Matrix4, Rect)> get touch {
    if (shape.shut) {
      return faceUp[1] ? const [] : [(cover!, Offset.zero & shape.cover!)];
    }
    return [
      for (final i in order.reversed)
        if (faceUp[i]) (half[i], halves[i]),
    ];
  }

  RRect _outline(int i, {double past = 0}) {
    final r = Radius.circular(shape.radius);
    final first = i == 0;
    final h = halves[i];
    return shape.sideways
        ? RRect.fromRectAndCorners(
            Rect.fromLTRB(
              h.left,
              h.top - (first ? 0 : past),
              h.right,
              h.bottom + (first ? past : 0),
            ),
            topLeft: first ? r : Radius.zero,
            topRight: first ? r : Radius.zero,
            bottomLeft: first ? Radius.zero : r,
            bottomRight: first ? Radius.zero : r,
          )
        : RRect.fromRectAndCorners(
            Rect.fromLTRB(
              h.left - (first ? 0 : past),
              h.top,
              h.right + (first ? past : 0),
              h.bottom,
            ),
            topLeft: first ? r : Radius.zero,
            bottomLeft: first ? r : Radius.zero,
            topRight: first ? Radius.zero : r,
            bottomRight: first ? Radius.zero : r,
          );
  }

  // with no picture of the app the lit screen just glows, glow says which
  // side of Split View is ours
  void paint(Canvas canvas, ui.Image? screen, {int glow = 0}) {
    _glow = glow;
    final reach = stage.width * .31;
    canvas.save();
    canvas.translate(stage.width / 2, stage.height * .93);
    canvas.scale(1, .16);
    canvas.drawCircle(
      Offset.zero,
      reach,
      Paint()
        ..shader = ui.Gradient.radial(Offset.zero, reach, const [
          Color(0x99000000),
          Color(0x00000000),
        ]),
    );
    canvas.restore();

    for (final i in order) {
      final up = faceUp[i];
      final outline = _outline(i);
      for (var k = 0; k < _layers; k++) {
        final z = thick * (up ? _layers - k : k) / _layers;
        _on(canvas, half[i], z, () {
          canvas.drawRRect(
            outline,
            Paint()
              ..color = Color.lerp(
                const Color(0xFF1B1C22),
                const Color(0xFF6A6C7A),
                k / (_layers - 1),
              )!,
          );
        });
      }
      up
          ? _front(canvas, i, outline, screen)
          : _back(canvas, i, outline, screen);
    }
  }

  void _on(Canvas canvas, Matrix4 m, double z, VoidCallback draw) {
    canvas.save();
    canvas.transform((m.clone()..translateByDouble(0, 0, z, 1)).storage);
    draw();
    canvas.restore();
  }

  void _front(Canvas canvas, int i, RRect outline, ui.Image? screen) {
    final r = halves[i];
    final bent = shape.folds ? (180 - shape.angle) / 180 : 0.0;
    _on(canvas, half[i], 0, () {
      canvas.clipRRect(outline);
      canvas.drawRect(r, Paint()..color = const Color(0xFF040406));
      if (!shape.shut) {
        if (screen == null) {
          _lit(canvas, r, dim: _glow != 0 && _glow != i + 1);
        } else {
          final k = screen.width / shape.inner.width;
          canvas.drawImageRect(
            screen,
            Rect.fromLTWH(r.left * k, r.top * k, r.width * k, r.height * k),
            r,
            Paint()..filterQuality = FilterQuality.medium,
          );
        }
        _island(canvas);
      }
      // each half catches less light the further it bends
      canvas.drawRect(
        r,
        Paint()..color = Color.fromRGBO(0, 0, 0, bent * (i == 0 ? .16 : .34)),
      );
      if (bent > .02) _crease(canvas, i, bent);
      // the rim runs past the hinge so the fold itself stays clean
      canvas.drawRRect(
        _outline(i, past: 24).deflate(1.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF2A2B33),
      );
    });
  }

  // the soft shadow a real fold throws along the hinge
  void _crease(Canvas canvas, int i, double bent) {
    final r = halves[i];
    const reach = 46.0;
    final Rect band;
    final Offset from, to;
    if (shape.sideways) {
      final y = i == 0 ? r.bottom : r.top;
      band = Rect.fromLTRB(
        r.left,
        i == 0 ? y - reach : y,
        r.right,
        i == 0 ? y : y + reach,
      );
      from = Offset(0, y);
      to = Offset(0, i == 0 ? y - reach : y + reach);
    } else {
      final x = i == 0 ? r.right : r.left;
      band = Rect.fromLTRB(
        i == 0 ? x - reach : x,
        r.top,
        i == 0 ? x : x + reach,
        r.bottom,
      );
      from = Offset(x, 0);
      to = Offset(i == 0 ? x - reach : x + reach, 0);
    }
    canvas.drawRect(
      band,
      Paint()
        ..shader = ui.Gradient.linear(from, to, [
          Color.fromRGBO(0, 0, 0, .5 * bent),
          const Color(0x00000000),
        ]),
    );
  }

  void _lit(Canvas canvas, Rect r, {bool dim = false}) => canvas.drawRect(
    r,
    Paint()
      ..shader = ui.Gradient.linear(
        r.topLeft,
        r.bottomRight,
        dim
            ? const [Color(0xFF1B2433), Color(0xFF0E131B)]
            : const [Color(0xFF9C8FFF), Color(0xFF3B2FB8)],
      ),
  );

  void _island(Canvas canvas) {
    final island = shape.island;
    if (island == null) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(island, const Radius.circular(99)),
      Paint()..color = const Color(0xFF000000),
    );
  }

  void _back(Canvas canvas, int i, RRect outline, ui.Image? screen) {
    final r = halves[i];
    _on(canvas, half[i], thick, () {
      canvas.drawRRect(
        outline,
        Paint()
          ..shader = ui.Gradient.linear(r.topLeft, r.bottomRight, const [
            Color(0xFF3B3D4A),
            Color(0xFF191A20),
          ]),
      );
    });
    if (i != 1 || cover == null) return;
    final c = shape.cover!;
    canvas.save();
    canvas.transform(cover!.storage);
    final glass = RRect.fromRectAndRadius(
      Offset.zero & c,
      Radius.circular(
        math.max(shape.radius - 8, 4) * c.width / coverBox!.width,
      ),
    );
    canvas.clipRRect(glass);
    canvas.drawRect(Offset.zero & c, Paint()..color = const Color(0xFF040406));
    if (shape.shut) {
      if (screen == null) {
        _lit(canvas, Offset.zero & c);
      } else {
        canvas.drawImageRect(
          screen,
          Rect.fromLTWH(
            0,
            0,
            screen.width.toDouble(),
            screen.height.toDouble(),
          ),
          Offset.zero & c,
          Paint()..filterQuality = FilterQuality.medium,
        );
      }
      _island(canvas);
    } else {
      // dark glass with a streak of light across it
      canvas.drawRect(
        Offset.zero & c,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(c.width, c.height),
            const [Color(0x00FFFFFF), Color(0x1FFFFFFF), Color(0x00FFFFFF)],
            const [.3, .5, .7],
          ),
      );
    }
    canvas.restore();
  }
}

// draws the app's snapshot onto the bent device
class DevicePainter extends SnapshotPainter {
  DevicePainter(this.fold);

  final Fold3D fold;

  @override
  void paintSnapshot(
    PaintingContext context,
    Offset offset,
    Size size,
    ui.Image image,
    Size sourceSize,
    double pixelRatio,
  ) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    fold.paint(canvas, image);
    canvas.restore();
  }

  // a platform view inside cant be snapshotted, so show the flat screen
  @override
  void paint(
    PaintingContext context,
    Offset offset,
    Size size,
    PaintingContextCallback painter,
  ) {
    final s = math.min(
      fold.stage.width / size.width,
      fold.stage.height / size.height,
    );
    context.pushTransform(
      true,
      offset,
      Matrix4.identity()
        ..translateByDouble(
          (fold.stage.width - size.width * s) / 2,
          (fold.stage.height - size.height * s) / 2,
          0,
          1,
        )
        ..scaleByDouble(s, s, 1, 1),
      painter,
    );
  }

  @override
  bool shouldRepaint(DevicePainter oldDelegate) => oldDelegate.fold != fold;
}

// fills the stage, keeps the app at its real size and sends touches through
// the same bend it was painted with
class FoldView extends SingleChildRenderObjectWidget {
  const FoldView({super.key, required this.fold, required Widget super.child});

  final Fold3D fold;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderFold(fold);

  @override
  void updateRenderObject(BuildContext context, RenderFold renderObject) =>
      renderObject.fold = fold;
}

class RenderFold extends RenderProxyBox {
  RenderFold(this._fold);

  Fold3D _fold;
  set fold(Fold3D value) {
    final resized =
        value.shape.display != _fold.shape.display ||
        value.stage != _fold.stage;
    _fold = value;
    resized ? markNeedsLayout() : markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    child?.layout(BoxConstraints.tight(_fold.shape.display));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    for (final (matrix, bounds) in _fold.touch) {
      final hit = result.addWithPaintTransform(
        transform: matrix,
        position: position,
        hitTest: (result, at) =>
            bounds.contains(at) && child.hitTest(result, position: at),
      );
      if (hit) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }
}
