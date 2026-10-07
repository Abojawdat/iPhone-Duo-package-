import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'fold_view.dart';
import 'main.dart' show DuoApp, brand;

enum Kind { duo, android, iphone, ipad }

// one way of holding a device
typedef Hold = ({Kind kind, bool turned, double angle, int split});

const _text = {
  'en': {
    'fold': 'Fold it',
    'poses': 'Every pose',
    'use': 'Use it',
    'hint': 'Drag the handle to fold the phone. The app inside is live.',
    'closed': 'Closed',
    'book': 'Book',
    'tabletop': 'Tabletop',
    'flat': 'Open',
    'turn': 'Turn it',
    'split': 'Split View',
    'tour': 'Play all',
    'stop': 'Stop',
    'guides': 'Guides',
    'light': 'Light',
    'hinge': 'Hinge',
    'other': 'Another app',
    'duo': 'iPhone Duo',
    'android': 'Android fold',
    'iphone': 'iPhone',
    'ipad': 'iPad',
    'sClosed': 'Cover screen. One pane, like a small phone.',
    'sFlat': 'Inner screen, flat. Two panes meet at the fold.',
    'sBook': 'Half open like a book. Panes move off the fold.',
    'sTable': 'Half open on a table. Top and bottom halves.',
    'sSplit': 'Split View. Two apps share the screen, one pane each.',
    'sSlab': 'No hinge here. The same widgets, one screen.',
    'posesHint': 'Everything a hand can do to a foldable. Tap one to try it.',
    'pClosed': 'Closed',
    'pClosedSide': 'Closed, sideways',
    'pOpen': 'Open',
    'pOpenUp': 'Open, upright',
    'pBook': 'Half open, book',
    'pTable': 'Half open, tabletop',
    'pSplitL': 'Split View, left app',
    'pSplitR': 'Split View, right app',
    'pABook': 'Android fold, book',
    'pATable': 'Android fold, tabletop',
    'pAFlat': 'Android fold, open',
    'pPhone': 'Regular iPhone',
    'pPad': 'iPad',
    'install': 'Add it to your app',
    'copied': 'Copied',
    'one': 'One context.duo',
    'oneBody':
        'Knows if the phone is folded, open, sideways or sharing the screen, '
        'and rebuilds your widget only when that changes.',
    'two': 'Layouts that follow the hinge',
    'twoBody':
        'DuoSplit, DuoListDetail and DuoNavigationScaffold put panes on each '
        'side of the fold and keep their state while it bends.',
    'three': 'Live hinge data',
    'threeBody':
        'The real angle and posture on iOS and Android. Everywhere else it is '
        'plain Dart, so the same code runs on web and desktop.',
  },
  'ar': {
    'fold': 'اطوِه',
    'poses': 'كل الوضعيات',
    'use': 'استخدمه',
    'hint': 'اسحب المقبض حتى تطوي الهاتف. التطبيق بداخله حي.',
    'closed': 'مغلق',
    'book': 'كتاب',
    'tabletop': 'على الطاولة',
    'flat': 'مفتوح',
    'turn': 'دوّره',
    'split': 'تقسيم الشاشة',
    'tour': 'شغّل الكل',
    'stop': 'إيقاف',
    'guides': 'الخطوط',
    'light': 'فاتح',
    'hinge': 'المفصل',
    'other': 'تطبيق آخر',
    'duo': 'iPhone Duo',
    'android': 'أندرويد قابل للطي',
    'iphone': 'iPhone',
    'ipad': 'iPad',
    'sClosed': 'الشاشة الخارجية. لوحة واحدة مثل هاتف صغير.',
    'sFlat': 'الشاشة الداخلية مسطحة. لوحتان تلتقيان عند الطية.',
    'sBook': 'نصف مفتوح مثل كتاب. اللوحتان تبتعدان عن الطية.',
    'sTable': 'نصف مفتوح على الطاولة. نصف علوي ونصف سفلي.',
    'sSplit': 'تقسيم الشاشة. تطبيقان يتشاركان الشاشة.',
    'sSlab': 'لا يوجد مفصل هنا. نفس الواجهات على شاشة واحدة.',
    'posesHint': 'كل ما يمكن أن تفعله اليد بهاتف قابل للطي. انقر لتجربه.',
    'pClosed': 'مغلق',
    'pClosedSide': 'مغلق، بالعرض',
    'pOpen': 'مفتوح',
    'pOpenUp': 'مفتوح، بالطول',
    'pBook': 'نصف مفتوح، كتاب',
    'pTable': 'نصف مفتوح، على الطاولة',
    'pSplitL': 'تقسيم الشاشة، التطبيق الأيسر',
    'pSplitR': 'تقسيم الشاشة، التطبيق الأيمن',
    'pABook': 'أندرويد، كتاب',
    'pATable': 'أندرويد، على الطاولة',
    'pAFlat': 'أندرويد، مفتوح',
    'pPhone': 'iPhone عادي',
    'pPad': 'iPad',
    'install': 'أضفه إلى تطبيقك',
    'copied': 'تم النسخ',
    'one': 'context.duo واحد',
    'oneBody':
        'يعرف إن كان الهاتف مطوياً أو مفتوحاً أو بالعرض أو يتشارك الشاشة، '
        'ويعيد بناء واجهتك فقط عند تغير ذلك.',
    'two': 'تخطيطات تتبع المفصل',
    'twoBody':
        'DuoSplit و DuoListDetail و DuoNavigationScaffold تضع اللوحات على '
        'جانبي الطية وتحافظ على حالتها أثناء الطي.',
    'three': 'بيانات المفصل الحية',
    'threeBody':
        'الزاوية والوضعية الحقيقية على iOS و Android. وفي كل مكان آخر Dart '
        'فقط، فيعمل نفس الكود على الويب وسطح المكتب.',
  },
};

const List<(String, IconData, Hold)> scenes = [
  (
    'pClosed',
    Icons.smartphone,
    (kind: Kind.duo, turned: false, angle: 0, split: 0),
  ),
  (
    'pClosedSide',
    Icons.stay_current_landscape,
    (kind: Kind.duo, turned: true, angle: 0, split: 0),
  ),
  (
    'pOpen',
    Icons.tablet,
    (kind: Kind.duo, turned: false, angle: 180, split: 0),
  ),
  (
    'pOpenUp',
    Icons.tablet_android,
    (kind: Kind.duo, turned: true, angle: 180, split: 0),
  ),
  (
    'pBook',
    Icons.menu_book,
    (kind: Kind.duo, turned: false, angle: 110, split: 0),
  ),
  (
    'pTable',
    Icons.laptop,
    (kind: Kind.duo, turned: true, angle: 110, split: 0),
  ),
  (
    'pSplitL',
    Icons.vertical_split,
    (kind: Kind.duo, turned: false, angle: 180, split: 1),
  ),
  (
    'pSplitR',
    Icons.vertical_split_outlined,
    (kind: Kind.duo, turned: false, angle: 180, split: 2),
  ),
  (
    'pABook',
    Icons.menu_book_outlined,
    (kind: Kind.android, turned: false, angle: 110, split: 0),
  ),
  (
    'pATable',
    Icons.laptop_chromebook,
    (kind: Kind.android, turned: true, angle: 110, split: 0),
  ),
  (
    'pAFlat',
    Icons.tablet_outlined,
    (kind: Kind.android, turned: false, angle: 180, split: 0),
  ),
  (
    'pPhone',
    Icons.phone_iphone,
    (kind: Kind.iphone, turned: false, angle: 180, split: 0),
  ),
  (
    'pPad',
    Icons.tablet_mac,
    (kind: Kind.ipad, turned: false, angle: 180, split: 0),
  ),
];

Size innerOf(Kind kind, bool turned) {
  final s = switch (kind) {
    Kind.duo => const Size(951, 669),
    Kind.android => const Size(840, 700),
    Kind.iphone => const Size(402, 874),
    Kind.ipad => const Size(1032, 1376),
  };
  return turned ? s.flipped : s;
}

Size? coverOf(Kind kind, bool turned) {
  final s = switch (kind) {
    Kind.duo => const Size(466, 678),
    Kind.android => const Size(408, 700),
    _ => null,
  };
  return turned ? s?.flipped : s;
}

// the pose the app inside is laid out for
DuoPose poseOf(Hold h) {
  final shut = h.angle < FoldShape.shutBelow;
  final flat = h.angle >= 176;
  switch (h.kind) {
    case Kind.iphone:
      return h.turned
          ? const DuoPose(
              'iPhoneSideways',
              Size(874, 402),
              padding: EdgeInsets.only(left: 62, right: 62, bottom: 21),
            )
          : DuoPose.iPhone;
    case Kind.ipad:
      return h.turned
          ? const DuoPose(
              'iPadSideways',
              Size(1376, 1032),
              devicePixelRatio: 2,
              padding: EdgeInsets.only(top: 24, bottom: 20),
            )
          : DuoPose.iPad;
    case Kind.android:
      if (shut) {
        return DuoPose(
          'foldableClosed',
          coverOf(h.kind, h.turned)!,
          platform: TargetPlatform.android,
          devicePixelRatio: 2.625,
        );
      }
      final base = h.turned ? DuoPose.foldableTabletop : DuoPose.foldableBook;
      return DuoPose(
        base.name,
        base.size,
        platform: base.platform,
        devicePixelRatio: base.devicePixelRatio,
        displayFeatures: [
          DisplayFeature(
            bounds: base.displayFeatures.single.bounds,
            type: DisplayFeatureType.fold,
            state: flat
                ? DisplayFeatureState.postureFlat
                : DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );
    case Kind.duo:
      if (shut) {
        return h.turned ? DuoPose.closedLandscape : DuoPose.closedPortrait;
      }
      if (h.split != 0) {
        return h.split == 1 ? DuoPose.splitLeft : DuoPose.splitRight;
      }
      final open = h.turned ? DuoPose.openPortrait : DuoPose.openLandscape;
      final bent = h.turned ? DuoPose.halfOpenTabletop : DuoPose.halfOpenBook;
      final hw = bent.hardware!;
      return DuoPose(
        flat ? open.name : bent.name,
        open.size,
        padding: open.padding,
        hardware: DuoHardware(
          supported: true,
          hasHinge: true,
          status: flat
              ? DuoHingeStatus.fullyOpen
              : DuoHingeStatus.partiallyOpen,
          angle: h.angle,
          folds: hw.folds,
          horizontalSizeClass: hw.horizontalSizeClass,
          verticalSizeClass: hw.verticalSizeClass,
          barEdge: hw.barEdge,
        ),
      );
  }
}

// the camera cutout, on whichever screen is lit
Rect? islandOf(Hold h) {
  final shut = h.angle < FoldShape.shutBelow;
  final size = shut && coverOf(h.kind, h.turned) != null
      ? coverOf(h.kind, h.turned)!
      : innerOf(h.kind, h.turned);
  switch (h.kind) {
    case Kind.ipad:
      return null;
    case Kind.android:
      return Rect.fromLTWH(size.width / 2 - 6, 12, 12, 12);
    case Kind.iphone:
      return h.turned
          ? Rect.fromLTWH(13, size.height / 2 - 62, 36, 124)
          : Rect.fromLTWH(size.width / 2 - 62, 11, 124, 36);
    case Kind.duo:
      return h.turned
          ? Rect.fromLTWH(size.width - 122, 18.5, 78, 22)
          : Rect.fromLTWH(size.width - 40.5, 44, 22, 78);
  }
}

class Showcase extends StatefulWidget {
  const Showcase({super.key, this.opening = true});

  // start shut and open by itself
  final bool opening;

  @override
  State<Showcase> createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase>
    with SingleTickerProviderStateMixin {
  var kind = Kind.duo;
  var turned = false;
  var split = 0;
  late double angle = widget.opening ? 0 : 180;
  // where a preset is taking the hinge
  late double? goal = widget.opening ? 180 : null;
  var spin = 0.0;
  var hover = Offset.zero, tilt = Offset.zero;
  var arabic = false, dark = true, guides = false;
  var tab = 0;
  Timer? touring;

  final _app = GlobalKey();
  final _snap = SnapshotController(allowSnapshotting: true);
  late final Ticker _ticker;
  var _last = Duration.zero;

  bool get folds => kind == Kind.duo || kind == Kind.android;
  Hold get hold =>
      (kind: kind, turned: turned, angle: folds ? angle : 180, split: split);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    touring?.cancel();
    _ticker.dispose();
    _snap.dispose();
    super.dispose();
  }

  void _tick(Duration now) {
    final dt = math.min((now - _last).inMicroseconds / 1e6, .12);
    _last = now;
    // the app inside keeps moving, so its picture is retaken every frame
    _snap.clear();
    final to = goal;
    final settled = to == null && spin == 0 && (tilt - hover).distance < .002;
    if (settled) return;
    setState(() {
      if (to != null) {
        angle += (to - angle) * (1 - math.exp(-dt * 6));
        if ((to - angle).abs() < .4) {
          angle = to;
          goal = null;
        }
      }
      spin *= math.exp(-dt * 8);
      if (spin.abs() < .003) spin = 0;
      tilt = Offset.lerp(tilt, hover, 1 - math.exp(-dt * 7))!;
    });
  }

  void bend(double by) {
    if (!folds) return;
    stopTour();
    setState(() {
      goal = null;
      angle = (angle + by).clamp(0.0, 180.0);
      if (angle < 176) split = 0;
    });
  }

  // let go near an end and it finishes the move
  void release() {
    if (angle < FoldShape.shutBelow) goal = 0;
    if (angle > 166) goal = 180;
  }

  void go(Hold h) => setState(() {
    if (h.turned != turned) spin = h.turned ? math.pi / 2 : -math.pi / 2;
    kind = h.kind;
    turned = h.turned;
    split = h.split;
    if (h.kind == Kind.duo || h.kind == Kind.android) {
      goal = h.angle;
    } else {
      goal = null;
      angle = 180;
    }
  });

  void stopTour() {
    touring?.cancel();
    touring = null;
  }

  void toggleTour() {
    if (touring != null) return setState(stopTour);
    var i = 0;
    go(scenes[i++].$3);
    setState(
      () => touring = Timer.periodic(
        const Duration(milliseconds: 2600),
        (_) => go(scenes[i++ % scenes.length].$3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _text[arabic ? 'ar' : 'en']!;
    return MaterialApp(
      title: 'duo_dynamic_sizing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: brand,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      builder: (context, child) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.7),
            radius: 1.3,
            colors: [Color(0xFF211C4D), Color(0xFF07070C)],
          ),
        ),
        child: Directionality(
          textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'duo_dynamic_sizing',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'by Mohammad Othman · Abojawdat',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => setState(() => arabic = !arabic),
              child: Text(arabic ? 'EN' : 'عربي'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: switch (tab) {
            0 => foldTab(t),
            1 => PosesTab(
              t: t,
              onPick: (h) {
                stopTour();
                go(h);
                setState(() => tab = 0);
              },
            ),
            _ => UseTab(t: t),
          },
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.black26,
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.devices_fold),
              label: t['fold']!,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view),
              label: t['poses']!,
            ),
            NavigationDestination(
              icon: const Icon(Icons.code),
              label: t['use']!,
            ),
          ],
        ),
      ),
    );
  }

  Widget foldTab(Map<String, String> t) => Column(
    children: [
      Expanded(child: stage()),
      readout(t),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: controls(t),
      ),
    ],
  );

  Widget stage() => LayoutBuilder(
    builder: (context, box) {
      final h = hold;
      final fold = Fold3D(
        FoldShape(
          inner: innerOf(kind, turned),
          cover: coverOf(kind, turned),
          angle: h.angle,
          sideways: turned,
          radius: kind == Kind.android ? 30 : 44,
          island: islandOf(h),
          spin: spin,
          tilt: tilt,
        ),
        box.biggest,
      );
      final grip = fold.grip;
      return MouseRegion(
        onHover: (e) => hover = Offset(
          (e.localPosition.dx / box.maxWidth - .5) * 2,
          (e.localPosition.dy / box.maxHeight - .5) * 2,
        ),
        onExit: (_) => hover = Offset.zero,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // empty space folds it too
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (d) => bend(pull(d.delta)),
                onPanEnd: (_) => setState(release),
              ),
            ),
            Positioned.fill(
              child: FoldView(
                fold: fold,
                child: SnapshotWidget(
                  controller: _snap,
                  mode: SnapshotMode.permissive,
                  autoresize: true,
                  painter: DevicePainter(fold),
                  child: screen(poseOf(h)),
                ),
              ),
            ),
            if (folds)
              Positioned(
                left: grip.dx - 26,
                top: grip.dy - 26,
                child: GestureDetector(
                  onPanUpdate: (d) => bend(pull(d.delta)),
                  onPanEnd: (_) => setState(release),
                  child: const _Grip(),
                ),
              ),
          ],
        ),
      );
    },
  );

  // a drag away from the hinge opens it
  double pull(Offset d) => (turned ? d.dy : d.dx) * .5;

  Widget screen(DuoPose pose) {
    final app = KeyedSubtree(
      key: _app,
      child: DuoApp(
        dark: dark,
        arabic: arabic,
        // the native glass is a platform view, which cant be pictured
        glass: kIsWeb || defaultTargetPlatform != TargetPlatform.iOS,
      ),
    );
    final sim = DuoSimulator(pose: pose, showGuides: guides, child: app);
    if (split == 0 || pose.name.startsWith('closed')) return sim;
    final other = _OtherApp(_text[arabic ? 'ar' : 'en']!['other']!);
    return Row(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: split == 1 ? sim : other),
        Expanded(child: split == 1 ? other : sim),
      ],
    );
  }

  Widget readout(Map<String, String> t) {
    final shut = folds && angle < FoldShape.shutBelow;
    final flat = !folds || angle >= 176;
    final (name, note) = !folds
        ? (t[kind.name]!, t['sSlab']!)
        : shut
        ? (t['closed']!, t['sClosed']!)
        : split != 0
        ? (t['split']!, t['sSplit']!)
        : flat
        ? (t['flat']!, t['sFlat']!)
        : turned
        ? (t['tabletop']!, t['sTable']!)
        : (t['book']!, t['sBook']!);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (folds)
                Text(
                  '${angle.round()}°',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              if (folds) const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: brand.withValues(alpha: .28),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            note,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget controls(Map<String, String> t) {
    final canSplit = kind == Kind.duo && !turned && angle >= 176;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 190),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Column(
          children: [
            if (folds)
              Row(
                children: [
                  const Icon(
                    Icons.devices_fold,
                    size: 20,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t['hinge']!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Slider(
                        max: 180,
                        value: angle.clamp(0.0, 180.0),
                        onChanged: (v) => bend(v - angle),
                        onChangeEnd: (_) => setState(release),
                      ),
                    ),
                  ),
                ],
              ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<Kind>(
                    showSelectedIcon: false,
                    segments: [
                      for (final k in Kind.values)
                        ButtonSegment(value: k, label: Text(t[k.name]!)),
                    ],
                    selected: {kind},
                    onSelectionChanged: (s) {
                      stopTour();
                      go((
                        kind: s.first,
                        turned: turned,
                        angle: angle < FoldShape.shutBelow ? 0 : 180,
                        split: 0,
                      ));
                    },
                  ),
                ),
                if (folds)
                  for (final (label, to) in [
                    (t['closed']!, 0.0),
                    (t[turned ? 'tabletop' : 'book']!, 110.0),
                    (t['flat']!, 180.0),
                  ])
                    ActionChip(
                      label: Text(label),
                      onPressed: () {
                        stopTour();
                        setState(() {
                          split = 0;
                          goal = to;
                        });
                      },
                    ),
                ActionChip(
                  avatar: const Icon(Icons.screen_rotation, size: 18),
                  label: Text(t['turn']!),
                  onPressed: () {
                    stopTour();
                    go((
                      kind: kind,
                      turned: !turned,
                      angle: goal ?? angle,
                      split: 0,
                    ));
                  },
                ),
                if (canSplit)
                  FilterChip(
                    label: Text(t['split']!),
                    selected: split != 0,
                    onSelected: (_) => setState(() => split = (split + 1) % 3),
                  ),
                FilterChip(
                  label: Text(t['guides']!),
                  selected: guides,
                  onSelected: (v) => setState(() => guides = v),
                ),
                FilterChip(
                  label: Text(t['light']!),
                  selected: !dark,
                  onSelected: (v) => setState(() => dark = !v),
                ),
                ActionChip(
                  avatar: Icon(
                    touring == null ? Icons.play_arrow : Icons.stop,
                    size: 18,
                  ),
                  label: Text(t[touring == null ? 'tour' : 'stop']!),
                  onPressed: toggleTour,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              t['hint']!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grip extends StatelessWidget {
  const _Grip();

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.grab,
    child: Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: brand,
        border: Border.all(color: Colors.white70, width: 2),
        boxShadow: [
          BoxShadow(color: brand.withValues(alpha: .6), blurRadius: 22),
        ],
      ),
      child: const Icon(Icons.back_hand_outlined, color: Colors.white),
    ),
  );
}

// stands in for the app on the other side of Split View
class _OtherApp extends StatelessWidget {
  const _OtherApp(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF12202E), Color(0xFF0A0F16)],
      ),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.apps, size: 72, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 28,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class PosesTab extends StatelessWidget {
  const PosesTab({super.key, required this.t, required this.onPick});

  final Map<String, String> t;
  final ValueChanged<Hold> onPick;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    children: [
      Text(
        t['posesHint']!,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white60),
      ),
      const SizedBox(height: 18),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final (key, icon, hold) in scenes)
            InkWell(
              key: ValueKey(key),
              borderRadius: BorderRadius.circular(18),
              onTap: () => onPick(hold),
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: CustomPaint(painter: _Mini(hold)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 16, color: Colors.white60),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            t[key]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

// the same 3D body, small and with its screens just glowing
class _Mini extends CustomPainter {
  _Mini(this.hold);

  final Hold hold;

  @override
  void paint(Canvas canvas, Size size) => Fold3D(
    FoldShape(
      inner: innerOf(hold.kind, hold.turned),
      cover: coverOf(hold.kind, hold.turned),
      angle: hold.angle,
      sideways: hold.turned,
      radius: hold.kind == Kind.android ? 30 : 44,
      tilt: const Offset(.5, -.4),
    ),
    size,
  ).paint(canvas, null, glow: hold.split);

  @override
  bool shouldRepaint(_Mini oldDelegate) => oldDelegate.hold != hold;
}

class UseTab extends StatelessWidget {
  const UseTab({super.key, required this.t});

  final Map<String, String> t;

  static const install = 'flutter pub add duo_dynamic_sizing';
  static const sample = '''
DuoNavigationScaffold(
  appBar: AppBar(title: Text(context.duo.mode.name)),
  selectedIndex: tab,
  onDestinationSelected: (i) => setState(() => tab = i),
  destinations: const [
    DuoDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
    DuoDestination(icon: Icon(Icons.star), label: 'Starred'),
  ],
  body: DuoListDetail<int>(
    selected: open,
    onClose: () => setState(() => open = null),
    empty: (_) => const Center(child: Text('Pick a message')),
    list: (_) => Messages(onTap: (i) => setState(() => open = i)),
    detail: (_, i) => Center(child: Text('Message \$i')),
  ),
)''';

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    children: [
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t['install']!,
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 8),
              _Code(install, copied: t['copied']!),
              const SizedBox(height: 20),
              for (final key in const ['one', 'two', 'three'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t[key]!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t['${key}Body']!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              _Code(sample, copied: t['copied']!),
            ],
          ),
        ),
      ),
    ],
  );
}

class _Code extends StatelessWidget {
  const _Code(this.code, {required this.copied});

  final String code, copied;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              code,
              style: const TextStyle(fontFamily: 'monospace', height: 1.45),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(copied)));
            },
          ),
        ],
      ),
    ),
  );
}
