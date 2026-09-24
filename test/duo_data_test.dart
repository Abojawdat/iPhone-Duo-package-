import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

DuoData duo(
  double w,
  double h, {
  TargetPlatform platform = TargetPlatform.iOS,
  double dpr = 3,
  List<DisplayFeature> features = const [],
  bool web = false,
}) => DuoData(
  size: Size(w, h),
  platform: platform,
  devicePixelRatio: dpr,
  displayFeatures: features,
  isWeb: web,
);

DuoData pose(DuoPose p) => DuoData(
  size: p.size,
  platform: p.platform,
  devicePixelRatio: p.devicePixelRatio,
  padding: p.padding,
  displayFeatures: p.displayFeatures,
);

DisplayFeature feature(
  Rect bounds,
  DisplayFeatureState state, [
  DisplayFeatureType type = DisplayFeatureType.fold,
]) => DisplayFeature(bounds: bounds, type: type, state: state);

final hinge = feature(
  const Rect.fromLTWH(540, 0, 34, 720),
  DisplayFeatureState.unknown,
  DisplayFeatureType.hinge,
);

void main() {
  group('iPhone Duo', () {
    test('every pose maps to its mode', () {
      expect(pose(DuoPose.closedPortrait).mode, DuoMode.closedPortrait);
      expect(pose(DuoPose.closedLandscape).mode, DuoMode.closedLandscape);
      expect(pose(DuoPose.openLandscape).mode, DuoMode.openLandscape);
      expect(pose(DuoPose.openPortrait).mode, DuoMode.openPortrait);
      expect(pose(DuoPose.splitLeft).mode, DuoMode.splitView);
      expect(pose(DuoPose.splitRight).mode, DuoMode.splitView);
      for (final p in DuoPose.values.take(6)) {
        expect(pose(p).isIphoneDuo, isTrue, reason: p.name);
      }
    });

    test('open, closed, split and columns', () {
      final closed = pose(DuoPose.closedPortrait);
      expect(
        [closed.isClosed, closed.isOpen, closed.columns],
        [true, false, 1],
      );
      final open = pose(DuoPose.openLandscape);
      expect([open.isOpen, open.isExpanded, open.columns], [true, true, 2]);
      expect(pose(DuoPose.openPortrait).columns, 2);
      final split = pose(DuoPose.splitLeft);
      expect([split.isOpen, split.isSplit, split.columns], [true, true, 1]);
      expect(pose(DuoPose.closedLandscape).columns, 1);
    });

    test('posture and fold line', () {
      expect(pose(DuoPose.closedPortrait).posture, DuoPosture.closed);
      final open = pose(DuoPose.openLandscape);
      expect(open.posture, DuoPosture.unknown);
      expect(open.fold, const Rect.fromLTWH(475.5, 0, 0, 669));
      expect(open.foldDirection, Axis.vertical);
      expect(open.isSeparating, isFalse);
      final upright = pose(DuoPose.openPortrait);
      expect(upright.fold, const Rect.fromLTWH(0, 475.5, 669, 0));
      expect(upright.foldDirection, Axis.horizontal);
      expect(pose(DuoPose.closedPortrait).fold, isNull);
      expect(pose(DuoPose.splitRight).fold, isNull);
    });

    test('rail everywhere but open portrait', () {
      expect(pose(DuoPose.closedPortrait).prefersRail, isTrue);
      expect(pose(DuoPose.closedLandscape).prefersRail, isTrue);
      expect(pose(DuoPose.openLandscape).prefersRail, isTrue);
      expect(pose(DuoPose.splitLeft).prefersRail, isTrue);
      expect(pose(DuoPose.openPortrait).prefersRail, isFalse);
    });

    test('partial windows from older SDKs and split slices', () {
      expect(duo(900, 669).mode, DuoMode.openLandscape);
      expect(duo(420, 678).mode, DuoMode.closedPortrait);
      expect(duo(334, 951).mode, DuoMode.splitView);
      expect(duo(669, 475).mode, DuoMode.splitView);
    });

    test('same sizes elsewhere are not a Duo', () {
      expect(duo(466, 678, dpr: 2).isIphoneDuo, isFalse);
      expect(
        duo(466, 678, platform: TargetPlatform.android).isIphoneDuo,
        isFalse,
      );
      expect(duo(951, 669, web: true).isIphoneDuo, isFalse);
      expect(duo(375, 667).isIphoneDuo, isFalse);
    });
  });

  group('other devices', () {
    test('phones', () {
      final iphone = pose(DuoPose.iPhone);
      expect(
        [iphone.mode, iphone.isIphoneDuo, iphone.columns, iphone.prefersRail],
        [DuoMode.closedPortrait, false, 1, false],
      );
      final landscape = duo(874, 402);
      expect(
        [landscape.mode, landscape.columns, landscape.prefersRail],
        [DuoMode.closedLandscape, 1, true],
      );
      expect(
        duo(412, 915, platform: TargetPlatform.android).mode,
        DuoMode.closedPortrait,
      );
    });

    test('tablets and desktop', () {
      expect(pose(DuoPose.iPad).mode, DuoMode.tablet);
      expect(
        duo(1280, 800, platform: TargetPlatform.android, dpr: 2).mode,
        DuoMode.tablet,
      );
      expect(
        duo(1440, 900, platform: TargetPlatform.macOS, dpr: 2).mode,
        DuoMode.desktop,
      );
      expect(
        duo(1280, 800, platform: TargetPlatform.windows, dpr: 1).mode,
        DuoMode.desktop,
      );
      expect(duo(1280, 800, web: true, dpr: 1).mode, DuoMode.desktop);
    });
  });

  group('android foldables', () {
    test('book', () {
      final d = pose(DuoPose.foldableBook);
      expect(
        [d.mode, d.posture, d.isSeparating, d.foldDirection, d.isOpen],
        [DuoMode.openLandscape, DuoPosture.book, true, Axis.vertical, true],
      );
    });

    test('tabletop', () {
      final d = pose(DuoPose.foldableTabletop);
      expect(
        [d.mode, d.posture, d.isSeparating, d.foldDirection],
        [DuoMode.openPortrait, DuoPosture.tabletop, true, Axis.horizontal],
      );
    });

    test('flat fold does not separate', () {
      final d = duo(
        840,
        700,
        platform: TargetPlatform.android,
        features: [
          feature(
            const Rect.fromLTWH(420, 0, 0, 700),
            DisplayFeatureState.postureFlat,
          ),
        ],
      );
      expect([d.posture, d.isSeparating], [DuoPosture.flat, false]);
    });

    test('hinge always separates', () {
      final d = duo(
        1114,
        720,
        platform: TargetPlatform.android,
        features: [hinge],
      );
      expect(
        [d.isSeparating, d.posture, d.mode],
        [true, DuoPosture.unknown, DuoMode.openLandscape],
      );
    });

    test('cutouts are not folds', () {
      final d = duo(
        412,
        915,
        platform: TargetPlatform.android,
        features: [
          feature(
            const Rect.fromLTWH(180, 0, 50, 30),
            DisplayFeatureState.unknown,
            DisplayFeatureType.cutout,
          ),
        ],
      );
      expect([d.fold, d.mode], [null, DuoMode.closedPortrait]);
    });
  });

  group('sizing helpers', () {
    test('safe area stays per side', () {
      final d = pose(DuoPose.closedPortrait);
      expect(d.safe, const EdgeInsets.only(right: 59, bottom: 21));
      expect(
        d.symmetricSafe,
        const EdgeInsets.symmetric(horizontal: 59, vertical: 21),
      );
    });

    test('margins', () {
      expect(pose(DuoPose.closedPortrait).margin, 16);
      expect(pose(DuoPose.openLandscape).margin, 24);
    });

    test('grid columns stay even across a vertical fold', () {
      expect(pose(DuoPose.openLandscape).gridColumns(250), 2);
      expect(pose(DuoPose.openLandscape).gridColumns(200), 4);
      expect(pose(DuoPose.openPortrait).gridColumns(200), 3);
      expect(pose(DuoPose.closedPortrait).gridColumns(500), 1);
    });

    test('custom thresholds', () {
      const d = DuoData(
        size: Size(700, 500),
        platform: TargetPlatform.android,
        expandedWidth: 800,
      );
      expect(d.isExpanded, isFalse);
    });

    test('toString', () {
      expect(
        pose(DuoPose.openLandscape).toString(),
        'openLandscape 951×669 · iPhone Duo · safe L0 T0 R59 B21 · 2 col'
        ' · fold vertical @475.5',
      );
    });
  });

  group('media fit', () {
    const inner = Size(951, 669);

    test('16:9 letterboxes on the inner screen', () {
      final s = DuoMedia.fitSize(16 / 9, inner);
      expect(s.width, 951);
      expect(s.height, closeTo(534.9, .1));
    });

    test('4:3 fills, it only crops a bit', () {
      final s = DuoMedia.fitSize(4 / 3, inner);
      expect(s.width, 951);
      expect(s.height, closeTo(713.25, .01));
    });

    test('explicit fits and maxCrop', () {
      expect(
        DuoMedia.fitSize(16 / 9, inner, fit: DuoMediaFit.cover).height,
        669,
      );
      expect(
        DuoMedia.fitSize(4 / 3, inner, fit: DuoMediaFit.contain).height,
        669,
      );
      expect(DuoMedia.fitSize(16 / 9, inner, maxCrop: .25).height, 669);
    });
  });

  group('splitPanes', () {
    test('open Duo splits at the fold', () {
      final (a, b) = splitPanes(
        pose(DuoPose.openLandscape),
        const Size(951, 669),
        Offset.zero,
      )!;
      expect(a, const Rect.fromLTWH(0, 0, 475.5, 669));
      expect(b, const Rect.fromLTWH(475.5, 0, 475.5, 669));
    });

    test('offset box still lines up with the fold', () {
      final (a, _) = splitPanes(
        pose(DuoPose.openLandscape),
        const Size(812, 613),
        const Offset(0, 56),
      )!;
      expect(a.width, 475.5);
    });

    test('stacked on open portrait', () {
      final (a, b) = splitPanes(
        pose(DuoPose.openPortrait),
        const Size(669, 951),
        Offset.zero,
      )!;
      expect(a, const Rect.fromLTWH(0, 0, 669, 475.5));
      expect(b.top, 475.5);
    });

    test('one pane when closed', () {
      expect(
        splitPanes(
          pose(DuoPose.closedPortrait),
          const Size(466, 678),
          Offset.zero,
        ),
        isNull,
      );
    });

    test('separating fold beats the axis', () {
      final (a, b) = splitPanes(
        pose(DuoPose.foldableTabletop),
        const Size(700, 840),
        Offset.zero,
        axis: Axis.horizontal,
      )!;
      expect(a, const Rect.fromLTWH(0, 0, 700, 420));
      expect(b, const Rect.fromLTWH(0, 420, 700, 420));
    });

    test('hinge gap stays empty', () {
      final d = duo(
        1114,
        720,
        platform: TargetPlatform.android,
        features: [hinge],
      );
      final (a, b) = splitPanes(d, const Size(1114, 720), Offset.zero)!;
      expect([a.right, b.left], [540, 574]);
    });

    test('rtl swaps the panes but keeps the fold', () {
      final (a, b) = splitPanes(
        pose(DuoPose.openLandscape),
        const Size(851, 613),
        const Offset(100, 56),
        textDirection: TextDirection.rtl,
      )!;
      expect(a, const Rect.fromLTWH(375.5, 0, 475.5, 613));
      expect(b, const Rect.fromLTWH(0, 0, 375.5, 613));
    });

    test('rtl ratio counts from the start edge', () {
      final (a, _) = splitPanes(
        pose(DuoPose.iPad),
        const Size(1032, 1376),
        Offset.zero,
        axis: Axis.horizontal,
        ratio: .25,
        textDirection: TextDirection.rtl,
      )!;
      expect(a, const Rect.fromLTWH(774, 0, 258, 1376));
    });

    test('rtl hinge and stacked panes', () {
      final d = duo(
        1114,
        720,
        platform: TargetPlatform.android,
        features: [hinge],
      );
      final (a, b) = splitPanes(
        d,
        const Size(1114, 720),
        Offset.zero,
        textDirection: TextDirection.rtl,
      )!;
      expect([a.left, b.right], [574, 540]);
      final (top, _) = splitPanes(
        pose(DuoPose.openPortrait),
        const Size(669, 951),
        Offset.zero,
        textDirection: TextDirection.rtl,
      )!;
      expect(top.top, 0);
    });

    test('ratio', () {
      final (a, _) = splitPanes(
        pose(DuoPose.iPad),
        const Size(1032, 1376),
        Offset.zero,
        axis: Axis.horizontal,
        ratio: .25,
      )!;
      expect(a.width, 258);
    });
  });
}
