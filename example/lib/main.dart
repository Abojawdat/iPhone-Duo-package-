// Playground for duo_dynamic_sizing: flip through every pose and watch the
// app keep its state. flutter run on any device, emulator or desktop.
import 'dart:async';
import 'dart:math' as math;

import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';

void main() => runApp(const Playground());

const brand = Color(0xFF6D5DFC);

typedef Track = ({String title, String artist, Color a, Color b, int secs});

const tracks = <Track>[
  (
    title: 'Hinge Theory',
    artist: 'The Creases',
    a: Color(0xFFFF6B6B),
    b: Color(0xFF6D5DFC),
    secs: 214,
  ),
  (
    title: 'Two Screens, One Heart',
    artist: 'Split View',
    a: Color(0xFF00C9A7),
    b: Color(0xFF0081CF),
    secs: 187,
  ),
  (
    title: 'Tabletop Nights',
    artist: 'Posture',
    a: Color(0xFFFFC75F),
    b: Color(0xFFFF6F91),
    secs: 243,
  ),
  (
    title: 'Island on the Right',
    artist: 'Safe Area',
    a: Color(0xFF845EC2),
    b: Color(0xFFD65DB1),
    secs: 198,
  ),
  (
    title: 'Fold at 475.5',
    artist: 'Passport',
    a: Color(0xFF4D8076),
    b: Color(0xFFC4FCEF),
    secs: 226,
  ),
  (
    title: 'Book Mode',
    artist: 'The Creases',
    a: Color(0xFFF9F871),
    b: Color(0xFF2C73D2),
    secs: 171,
  ),
  (
    title: 'GlobalKey Lullaby',
    artist: 'Reparent',
    a: Color(0xFFFF9671),
    b: Color(0xFF008F7A),
    secs: 255,
  ),
  (
    title: 'Never Scale',
    artist: '153 ppi',
    a: Color(0xFFB39CD0),
    b: Color(0xFF00C2A8),
    secs: 202,
  ),
  (
    title: 'Crease Lightning',
    artist: 'Hinge Theory',
    a: Color(0xFFFF5E62),
    b: Color(0xFFFF9966),
    secs: 189,
  ),
  (
    title: 'Safe Area Blues',
    artist: 'The Insets',
    a: Color(0xFF3A7BD5),
    b: Color(0xFF00D2FF),
    secs: 231,
  ),
  (
    title: 'Rail by the Island',
    artist: 'Split View',
    a: Color(0xFF11998E),
    b: Color(0xFF38EF7D),
    secs: 176,
  ),
  (
    title: 'Pure Dart Heart',
    artist: 'No Channels',
    a: Color(0xFFDA22FF),
    b: Color(0xFF9733EE),
    secs: 244,
  ),
];

typedef Photo = ({
  String title,
  double ratio,
  Color sky,
  Color sun,
  Color land,
});

const photos = <Photo>[
  (
    title: 'Wide dusk',
    ratio: 16 / 9,
    sky: Color(0xFF2B2D6E),
    sun: Color(0xFFFF8A5B),
    land: Color(0xFF3A2E5C),
  ),
  (
    title: 'Square noon',
    ratio: 1,
    sky: Color(0xFF4FC3F7),
    sun: Color(0xFFFFF176),
    land: Color(0xFF2E7D32),
  ),
  (
    title: 'Tall story',
    ratio: 9 / 16,
    sky: Color(0xFF6A1B9A),
    sun: Color(0xFFFFAB91),
    land: Color(0xFF1A237E),
  ),
  (
    title: 'Classic 4:3',
    ratio: 4 / 3,
    sky: Color(0xFFFFCC80),
    sun: Color(0xFFFFFFFF),
    land: Color(0xFF8D6E63),
  ),
  (
    title: 'Cinema',
    ratio: 21 / 9,
    sky: Color(0xFF0D1B2A),
    sun: Color(0xFFE0E1DD),
    land: Color(0xFF1B263B),
  ),
  (
    title: 'Portrait 3:4',
    ratio: 3 / 4,
    sky: Color(0xFFF48FB1),
    sun: Color(0xFFFFF59D),
    land: Color(0xFF6D4C41),
  ),
  (
    title: 'Aurora',
    ratio: 3 / 2,
    sky: Color(0xFF004D40),
    sun: Color(0xFF69F0AE),
    land: Color(0xFF102027),
  ),
  (
    title: 'Desert',
    ratio: 2 / 3,
    sky: Color(0xFFFFE0B2),
    sun: Color(0xFFFF7043),
    land: Color(0xFFD84315),
  ),
];

// the poses the tour walks through, a full day with the Duo
const tour = [
  DuoPose.closedPortrait,
  DuoPose.openLandscape,
  DuoPose.splitLeft,
  DuoPose.splitRight,
  DuoPose.openPortrait,
  DuoPose.closedLandscape,
  DuoPose.foldableBook,
  DuoPose.foldableTabletop,
];

String n(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

// english names read right inside arabic text
String iso(String s) => '\u2068$s\u2069';

typedef Copy = ({
  List<String> tabs,
  String shuffle,
  String pick,
  String close,
  String photo,
  List<String> fits,
  String book,
  String tabletop,
  String closed,
  String open,
  String openPortrait,
  String split,
  String other,
  String counter,
  String note,
  String popCard,
  String dialog,
  String dialogBody,
  String ok,
  String cardBody,
});

const Copy en = (
  tabs: ['Music', 'Gallery', 'Lab'],
  shuffle: 'Shuffle',
  pick: 'Pick a track',
  close: 'Close',
  photo: 'photo',
  fits: [
    'Fills the pane when it hides 15% or less, else letterboxes.',
    'Whole photo, bars where it doesn\'t fit.',
    'Fills the pane, crops whatever sticks out.',
  ],
  book:
      'Book posture: a real hinge. Panes split exactly at it, the gallery '
      'keeps an even column count and "Pop a card" lands on one half.',
  tabletop:
      'Tabletop: open a photo, it goes on top and the info sits on the '
      'bottom half, like a laptop.',
  closed:
      'Closed. Play a track, bump the counter, type a note, then unfold. '
      'Everything should still be there, the record still spinning.',
  open:
      'Open. List and detail sit on each side of the fold at 475.5, the '
      'rail moved next to the island and the FAB went into it.',
  openPortrait:
      'Open portrait. Bottom bar is back, panes stack above and below the '
      'fold.',
  split:
      'Split View: half the inner screen. One pane, and the rail follows '
      'the side the island is on (try splitLeft and splitRight).',
  other: 'Not a Duo. Same app, it just gets two panes because there is room.',
  counter: 'DuoKeep counter\nshould survive every fold',
  note: 'Type something, then fold',
  popCard: 'Pop a card',
  dialog: 'Dialog',
  dialogBody: 'Material dialogs dodge a separating fold on their own.',
  ok: 'OK',
  cardBody: 'Never on the crease. Tap to close.',
);

const Copy ar = (
  tabs: ['الأغاني', 'الصور', 'المختبر'],
  shuffle: 'عشوائي',
  pick: 'اختار أغنية',
  close: 'سد',
  photo: 'صورة',
  fits: [
    'يملّي المساحة إذا ما يگص أكثر من 15%، وإلا يخلي حواشي.',
    'الصورة كلها، وحواشي بالمكان اللي ما تركب بي.',
    'يملّي المساحة ويگص اللي يطلع برّه.',
  ],
  book:
      'وضعية الكتاب: مفصل حقيقي. الألواح تنقسم عليه بالضبط، الصور تبقى '
      'أعمدتها زوجية، و"طلّع كارت" يطلع بنص واحد.',
  tabletop:
      'وضعية الطاولة: افتح صورة، تصير فوگ والمعلومات تنزل للنص الجوّاني، '
      'مثل اللابتوب.',
  closed:
      'مسدود. شغّل أغنية، زيد العداد، اكتب ملاحظة، وبعدين افتحه. كلشي لازم '
      'يبقى، والأسطوانة بعدها تدور.',
  open:
      'مفتوح. القائمة والتفاصيل كل وحدة بصف من الطبگة عند 475.5، الشريط صار '
      'يم الجزيرة والزر دخل بي.',
  openPortrait: 'مفتوح بالطول. الشريط الجوّاني رجع، والألواح فوگ وجوّه الطبگة.',
  split:
      'Split View: نص الشاشة الداخلية. لوح واحد، والشريط يمشي ويه الصف اللي '
      'بي الجزيرة (جرّب splitLeft و splitRight).',
  other: 'مو Duo. نفس التطبيق، بس ياخذ لوحين لأن اكو مكان.',
  counter: 'عداد DuoKeep\nلازم يبقى بكل طبگة',
  note: 'اكتب شي، وبعدين طبّگه',
  popCard: 'طلّع كارت',
  dialog: 'نافذة',
  dialogBody: 'نوافذ Material تتجنب الطبگة الفاصلة من نفسها.',
  ok: 'تمام',
  cardBody: 'أبد ما يگعد عالطبگة. دوس حتى تسده.',
);

// the language follows the direction the lab picks
extension on BuildContext {
  Copy get copy => Directionality.of(this) == TextDirection.rtl ? ar : en;
}

// ---------------------------------------------------------------- lab shell

/// The test lab: a pose picker and toggles around the demo app.
class Playground extends StatefulWidget {
  const Playground({super.key, this.helpOnStart = true});

  final bool helpOnStart;

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground>
    with SingleTickerProviderStateMixin {
  // null = the real device, no simulator
  DuoPose? pose = DuoPose.closedPortrait;
  bool guides = true, debug = false, rtl = false, dark = true, bigText = false;
  Timer? touring;
  final _app = GlobalKey();
  final _home = GlobalKey();
  late final flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    if (widget.helpOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _home.currentContext;
        if (context != null) showHelp(context);
      });
    }
  }

  void setPose(DuoPose? p) {
    if (p == pose) return;
    setState(() => pose = p);
    flip.forward(from: 0);
  }

  void toggleTour() {
    if (touring != null) {
      touring!.cancel();
      return setState(() => touring = null);
    }
    var i = math.max(0, tour.indexOf(pose ?? tour.last) + 1);
    setPose(tour[i++ % tour.length]);
    setState(
      () => touring = Timer.periodic(
        const Duration(milliseconds: 2800),
        (_) => setPose(tour[i++ % tour.length]),
      ),
    );
  }

  @override
  void dispose() {
    touring?.cancel();
    flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.dark),
      home: Builder(key: _home, builder: stage),
    );
  }

  Widget stage(BuildContext context) {
    final base = MediaQuery.of(context);
    // same element across every pose, debug and real-device switch
    final app = KeyedSubtree(
      key: _app,
      child: DuoApp(dark: dark, arabic: rtl),
    );
    final p = pose;
    Widget screen = MediaQuery(
      data: base.copyWith(
        textScaler: bigText ? const TextScaler.linear(2) : base.textScaler,
      ),
      child: p == null
          ? DuoDebugOverlay(enabled: debug, child: app)
          : DuoSimulator(
              pose: p,
              showGuides: guides,
              child: DuoDebugOverlay(enabled: debug, child: app),
            ),
    );
    if (p != null) {
      screen = Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Center(
          child: AnimatedBuilder(
            animation: flip,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF2A2A33), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: brand.withValues(alpha: .35),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: screen,
              ),
            ),
            builder: (context, child) {
              final t = flip.value;
              final bump = math.sin(t * math.pi);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, .0012)
                  ..rotateY(bump * .45 * (1 - t)),
                child: Transform.scale(
                  scale: 1 - .07 * bump,
                  child: Stack(
                    children: [
                      child!,
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: _Sweep(t)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B10),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  top: p != null,
                  bottom: false,
                  left: p != null,
                  right: p != null,
                  child: screen,
                ),
              ),
              if (p != null) controls(context),
            ],
          ),
          if (p == null)
            Positioned(
              top: base.padding.top + 6,
              right: 12,
              child: FilledButton.tonalIcon(
                onPressed: () => setPose(tour.first),
                icon: const Icon(Icons.devices_fold),
                label: const Text('Back to poses'),
              ),
            ),
        ],
      ),
    );
  }

  Widget controls(BuildContext context) {
    Widget toggle(IconData icon, String tip, bool on, VoidCallback tap) =>
        IconButton(
          tooltip: tip,
          isSelected: on,
          onPressed: tap,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            foregroundColor: on ? Colors.white : Colors.white54,
            backgroundColor: on ? brand : Colors.transparent,
          ),
        );
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Caption(pose: pose, guides: guides),
          SizedBox(
            height: 48,
            // 11 chips, all built so each one can be scrolled to
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (final p in [...DuoPose.values, null])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        selected: pose == p,
                        onSelected: (_) {
                          touring?.cancel();
                          touring = null;
                          setPose(p);
                        },
                        avatar: Icon(poseIcon(p), size: 18),
                        label: Text(p?.name ?? 'real device'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: toggleTour,
                  icon: Icon(
                    touring == null ? Icons.play_arrow : Icons.stop_rounded,
                  ),
                  label: Text(touring == null ? 'Tour' : 'Stop'),
                ),
                const Spacer(),
                toggle(
                  Icons.help_outline,
                  'How to test',
                  false,
                  () => showHelp(context),
                ),
                toggle(
                  Icons.grid_on,
                  'Fold & safe-area guides',
                  guides,
                  () => setState(() => guides = !guides),
                ),
                toggle(
                  Icons.bug_report_outlined,
                  'DuoDebugOverlay',
                  debug,
                  () => setState(() => debug = !debug),
                ),
                toggle(
                  Icons.translate,
                  'العربية, right to left',
                  rtl,
                  () => setState(() => rtl = !rtl),
                ),
                toggle(
                  Icons.format_size,
                  'Text 2x',
                  bigText,
                  () => setState(() => bigText = !bigText),
                ),
                toggle(
                  Icons.dark_mode_outlined,
                  'Dark app',
                  dark,
                  () => setState(() => dark = !dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// what each pose is, in plain words
(String, String) poseInfo(DuoPose? p) => switch (p?.name) {
  null => (
    'This device',
    'No simulation. The app sees your real screen, so on a foldable '
        '(like a Pixel Fold emulator) the fold comes from Android itself.',
  ),
  'closedPortrait' => (
    'iPhone Duo, closed',
    'Outer screen, 466 × 678. Works like a small phone: one pane.',
  ),
  'closedLandscape' => (
    'iPhone Duo, closed, sideways',
    'Outer screen turned, 678 × 466. Still one pane.',
  ),
  'openLandscape' => (
    'iPhone Duo, open',
    'Inner screen, 951 × 669, fold down the middle. Two panes.',
  ),
  'openPortrait' => (
    'iPhone Duo, open, upright',
    'Inner screen turned, 669 × 951, fold across. Two panes, bottom bar.',
  ),
  'splitLeft' => (
    'iPhone Duo, Split View, left app',
    'Two apps side by side, this is the left one. One pane.',
  ),
  'splitRight' => (
    'iPhone Duo, Split View, right app',
    'This is the right one, next to the island. One pane.',
  ),
  'foldableBook' => (
    'Android foldable, half open',
    'Held like a book with a real hinge. Panes split at it.',
  ),
  'foldableTabletop' => (
    'Android foldable, tabletop',
    'Half open on a table, like a laptop. Top and bottom halves.',
  ),
  'iPhone' => ('Regular iPhone', '402 × 874. Nothing special, one pane.'),
  'iPad' => ('iPad', '1032 × 1376. Room for two panes.'),
  _ => (p!.name, ''),
};

const statHelp = {
  'mode': 'What kind of window this is: closed, open, split view, tablet…',
  'posture':
      'How a foldable is bent. iOS does not report it yet, so it '
      'stays unknown on the Duo.',
  'size': 'Window size in points.',
  'iPhone Duo': 'True only for the exact Duo sizes on iOS.',
  'expanded': 'Room for two panes (at least 600 × 480). Layouts use this.',
  'columns': '1 or 2, from expanded.',
  'rail': 'Side rail instead of a bottom bar.',
  'fold': 'Where the fold is, in points.',
  'separating':
      'A real hinge or a half-open fold that content should '
      'avoid.',
  'safe': 'Space the system covers: left, top, right, bottom.',
  'grid(150)': 'Columns for 150 pt tiles, even on a vertical fold.',
  'platform': 'Which platform the app thinks it runs on.',
};

class _Caption extends StatelessWidget {
  const _Caption({required this.pose, required this.guides});

  final DuoPose? pose;
  final bool guides;

  @override
  Widget build(BuildContext context) {
    final (title, about) = poseInfo(pose);
    Widget dot(Color c, String label) => Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Row(
          key: ValueKey('$title$guides'),
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$title  ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: about,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (guides && pose != null) ...[
              dot(const Color(0xFFFF6B60), 'system'),
              dot(const Color(0xFF3B8BFF), 'fold'),
            ],
          ],
        ),
      ),
    );
  }
}

void showHelp(BuildContext context) {
  Widget h(String t) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 6),
    child: Text(
      t,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    ),
  );
  Widget row(Widget lead, String title, String body) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 36, child: lead),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$title\n',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: body,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  Widget icon(IconData i) => Icon(i, color: brand);
  Widget swatch(Color c) => Align(
    alignment: Alignment.topLeft,
    child: Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .85,
      maxChildSize: .95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const Text(
            'How to test duo_dynamic_sizing',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'The phone in the middle is a real Flutter app running inside a '
            'pretend screen. Pick a pose at the bottom and the same app '
            'rearranges itself for that screen, without losing what you '
            'were doing. That is the whole package in one sentence.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          h('Try this'),
          row(
            const Text('1', style: TextStyle(fontSize: 20)),
            'Fold with music playing',
            'On closedPortrait, open Music and play a track. Tap '
                'openLandscape: the list appears next to it and the song '
                'keeps playing from the same second.',
          ),
          row(
            const Text('2', style: TextStyle(fontSize: 20)),
            'Nothing gets lost',
            'In Lab, bump the counter and type a note. Switch poses as '
                'much as you like, they stay.',
          ),
          row(
            const Text('3', style: TextStyle(fontSize: 20)),
            'Laptop mode',
            'Pick foldableTabletop, open a photo in Gallery: photo on top, '
                'details on the bottom half.',
          ),
          row(
            const Text('4', style: TextStyle(fontSize: 20)),
            'Split View',
            'Compare splitLeft and splitRight: the side rail moves to the '
                'side of the Dynamic Island.',
          ),
          row(
            const Text('5', style: TextStyle(fontSize: 20)),
            'Arabic and big text',
            'Turn on العربية: everything mirrors but panes stay on the fold. '
                'Turn on 2x text: nothing should overflow.',
          ),
          h('The colors on the screen'),
          row(
            swatch(const Color(0xFFFF6B60)),
            'Red: the system uses this',
            'On the Duo, the wide strip is the vertical Dynamic Island and '
                'the thin one at the bottom is the home bar. Content stays '
                'out of it.',
          ),
          row(
            swatch(const Color(0xFF3B8BFF)),
            'Blue: the fold',
            'Where the screen bends. Two-pane layouts split exactly here.',
          ),
          h('The buttons'),
          row(
            icon(Icons.play_arrow),
            'Tour',
            'Walks through the Duo poses by itself every few seconds.',
          ),
          row(
            icon(Icons.grid_on),
            'Guides',
            'Shows or hides the red and blue areas above.',
          ),
          row(
            icon(Icons.bug_report_outlined),
            'Debug overlay',
            'Prints what the package sees (context.duo) on top of the app.',
          ),
          row(
            icon(Icons.translate),
            'العربية',
            'Switches the app to Arabic, right to left.',
          ),
          row(icon(Icons.format_size), 'Big text', 'Text at 200%.'),
          row(icon(Icons.dark_mode_outlined), 'Dark', 'Light or dark app.'),
          h('The poses'),
          for (final p in [...DuoPose.values, null])
            row(
              icon(poseIcon(p)),
              '${p?.name ?? 'real device'} · ${poseInfo(p).$1}',
              poseInfo(p).$2,
            ),
          h('The tabs'),
          row(
            icon(Icons.library_music),
            'Music',
            'A list and a player. One pane on small screens, side by side '
                'when there is room (DuoListDetail).',
          ),
          row(
            icon(Icons.photo_library),
            'Gallery',
            'Tap a photo. The three buttons at the top change how it fits '
                'odd-shaped screens (DuoMedia).',
          ),
          row(
            icon(Icons.science),
            'Lab',
            'Live values from the package. Tap any value to see what it '
                'means.',
          ),
          h('Lab values'),
          for (final e in statHelp.entries)
            row(const SizedBox(), e.key, e.value),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Start testing'),
          ),
        ],
      ),
    ),
  );
}

IconData poseIcon(DuoPose? p) => switch (p?.name) {
  null => Icons.phone_android,
  'closedPortrait' => Icons.stay_current_portrait,
  'closedLandscape' => Icons.stay_current_landscape,
  'openLandscape' || 'openPortrait' => Icons.menu_book,
  'splitLeft' || 'splitRight' => Icons.vertical_split,
  'foldableBook' => Icons.auto_stories,
  'foldableTabletop' => Icons.laptop,
  'iPad' => Icons.tablet_mac,
  _ => Icons.phone_iphone,
};

// light sweep across the screen on every fold
class _Sweep extends CustomPainter {
  _Sweep(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0 || t == 1) return;
    final x = size.width * (t * 1.6 - .3);
    final band = Rect.fromLTWH(x - 80, 0, 160, size.height);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: .22 * math.sin(t * math.pi)),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(band),
    );
  }

  @override
  bool shouldRepaint(_Sweep old) => old.t != t;
}

ThemeData theme(Brightness b) {
  final scheme = ColorScheme.fromSeed(seedColor: brand, brightness: b);
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
  );
}

// ---------------------------------------------------------------- the app

/// The demo app. The lab around it picks the pose, language and theme.
class DuoApp extends StatelessWidget {
  const DuoApp({
    super.key,
    this.dark = true,
    this.arabic = false,
    this.initialTab = 0,
    this.initialTrack,
    this.initialPhoto,
    this.initialFit = DuoMediaFit.smart,
    this.fontFallback,
  });

  final bool dark, arabic;
  final int initialTab;
  final int? initialTrack, initialPhoto;
  final DuoMediaFit initialFit;
  final List<String>? fontFallback;

  @override
  Widget build(BuildContext context) {
    ThemeData themed(Brightness b) => theme(b).copyWith(
      textTheme: theme(b).textTheme.apply(fontFamilyFallback: fontFallback),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themed(Brightness.light),
      darkTheme: themed(Brightness.dark),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 400),
      builder: (context, child) => Directionality(
        textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) =>
            Home(initialTab: initialTab, initialTrack: initialTrack),
      ),
      // home, with a photo already open on top for the README renders
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute(
          builder: (_) =>
              Home(initialTab: initialTab, initialTrack: initialTrack),
        ),
        if (initialPhoto case final photo?)
          MaterialPageRoute(
            builder: (_) => Viewer(index: photo, initialFit: initialFit),
          ),
      ],
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, this.initialTab = 0, this.initialTrack});

  final int initialTab;
  final int? initialTrack;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int tab = widget.initialTab;
  late final playing = ValueNotifier<int?>(widget.initialTrack);
  final _rng = math.Random();

  @override
  void dispose() {
    playing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.copy;
    return DuoNavigationScaffold(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, .4),
                end: Offset.zero,
              ).animate(a),
              child: child,
            ),
          ),
          child: Text(
            c.tabs[tab],
            key: ValueKey(tab),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: c.shuffle,
        onPressed: () {
          playing.value = _rng.nextInt(tracks.length);
          setState(() => tab = 0);
        },
        child: const Icon(Icons.shuffle),
      ),
      destinations: [
        DuoDestination(
          icon: const Icon(Icons.library_music_outlined),
          selectedIcon: const Icon(Icons.library_music),
          label: c.tabs[0],
        ),
        DuoDestination(
          icon: const Icon(Icons.photo_library_outlined),
          selectedIcon: const Icon(Icons.photo_library),
          label: c.tabs[1],
        ),
        DuoDestination(
          icon: const Icon(Icons.science_outlined),
          selectedIcon: const Icon(Icons.science),
          label: c.tabs[2],
        ),
      ],
      // every tab stays alive, so a fold never loses anything
      body: IndexedStack(
        index: tab,
        children: [
          MusicPage(playing: playing),
          const GalleryPage(),
          const LabPage(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- music

class MusicPage extends StatelessWidget {
  const MusicPage({super.key, required this.playing});

  final ValueNotifier<int?> playing;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playing,
      builder: (context, selected, _) => DuoListDetail<int>(
        selected: selected,
        onClose: () => playing.value = null,
        list: (context) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tracks.length,
          itemBuilder: (context, i) => _Stagger(
            index: i,
            child: _TrackTile(
              track: tracks[i],
              selected: i == selected,
              onTap: () => playing.value = i,
            ),
          ),
        ),
        empty: (context) =>
            _Empty(icon: Icons.album_outlined, text: context.copy.pick),
        detail: (context, i) => NowPlaying(
          key: ValueKey(i),
          track: tracks[i],
          onClose: () => playing.value = null,
        ),
      ),
    );
  }
}

// slides in once, a replay after a fold would mean the list lost its state
class _Stagger extends StatelessWidget {
  const _Stagger({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 70),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - v)),
          child: child,
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.track,
    required this.selected,
    required this.onTap,
  });

  final Track track;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        selected: selected,
        selectedTileColor: scheme.primaryContainer,
        selectedColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: [track.a, track.b]),
          ),
          child: selected
              ? const Icon(Icons.graphic_eq, color: Colors.white)
              : null,
        ),
        title: Text(
          iso(track.title),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(iso(track.artist)),
        trailing: Text(clock(track.secs.toDouble())),
      ),
    );
  }
}

String clock(double secs) =>
    '${secs ~/ 60}:${(secs % 60).floor().toString().padLeft(2, '0')}';

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key, required this.track, required this.onClose});

  final Track track;
  final VoidCallback onClose;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> with TickerProviderStateMixin {
  // spin angle and position survive a fold, that's the test
  late final spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late final progress = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.track.secs),
  );
  bool playing = true;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // reduce motion: a still record
    if (MediaQuery.disableAnimationsOf(context)) return;
    spin.repeat();
    progress.repeat();
  }

  void toggle() {
    setState(() => playing = !playing);
    if (playing) {
      spin.repeat();
      progress.repeat();
    } else {
      spin.stop();
      progress.stop();
    }
  }

  @override
  void dispose() {
    spin.dispose();
    progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.track;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.a.withValues(alpha: .45), scheme.surface],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth > box.maxHeight * 1.15;
          final disc = wide
              ? math.min(box.maxHeight * .7, box.maxWidth * .4)
              : math.min(box.maxWidth * .62, box.maxHeight * .42);
          final record = SizedBox.square(
            dimension: disc,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RotationTransition(
                  turns: spin,
                  child: CustomPaint(painter: _Vinyl(t.a, t.b)),
                ),
                const IgnorePointer(child: CustomPaint(painter: _Shine())),
              ],
            ),
          );
          final info = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                iso(t.title),
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                iso(t.artist),
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(color: scheme.outline),
              ),
              const SizedBox(height: 16),
              Center(
                child: _Equalizer(spin: spin, playing: playing, color: t.a),
              ),
              AnimatedBuilder(
                animation: progress,
                builder: (context, _) => Column(
                  children: [
                    Slider(
                      value: progress.value,
                      activeColor: t.a,
                      onChanged: (v) => progress.value = v,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(clock(progress.value * t.secs)),
                          Text(clock(t.secs.toDouble())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => progress.value = 0,
                    icon: const Icon(Icons.skip_previous_rounded, size: 32),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.large(
                    heroTag: null,
                    backgroundColor: t.a,
                    foregroundColor: Colors.white,
                    onPressed: toggle,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (c, a) =>
                          ScaleTransition(scale: a, child: c),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        key: ValueKey(playing),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () =>
                        progress.value = math.min(1, progress.value + .1),
                    icon: const Icon(Icons.skip_next_rounded, size: 32),
                  ),
                ],
              ),
            ],
          );
          return Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: Center(child: record)),
                            const SizedBox(width: 20),
                            Expanded(child: info),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [record, const SizedBox(height: 20), info],
                        ),
                ),
              ),
              PositionedDirectional(
                top: 4,
                start: 4,
                child: IconButton(
                  tooltip: context.copy.close,
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Equalizer extends StatelessWidget {
  const _Equalizer({
    required this.spin,
    required this.playing,
    required this.color,
  });

  final Animation<double> spin;
  final bool playing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: AnimatedBuilder(
        animation: spin,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 9; i++)
              Container(
                width: 5,
                height: playing
                    ? 6 +
                          28 *
                              (.5 +
                                  .5 *
                                      math.sin(
                                        spin.value * math.pi * 2 * (i % 4 + 3) +
                                            i * 1.3,
                                      ))
                    : 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Vinyl extends CustomPainter {
  _Vinyl(this.a, this.b);

  final Color a, b;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF111116));
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .07);
    for (var g = r * .42; g < r * .97; g += r * .035) {
      canvas.drawCircle(c, g, groove);
    }
    final label = Rect.fromCircle(center: c, radius: r * .36);
    canvas
      ..drawCircle(
        c,
        r * .36,
        Paint()..shader = LinearGradient(colors: [a, b]).createShader(label),
      )
      ..drawCircle(
        c + Offset(0, -r * .24),
        r * .04,
        Paint()..color = Colors.white70,
      )
      ..drawCircle(c, r * .035, Paint()..color = const Color(0xFF111116));
  }

  @override
  bool shouldRepaint(_Vinyl old) => old.a != a || old.b != b;
}

// static glare, stays put while the record turns under it
class _Shine extends CustomPainter {
  const _Shine();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawCircle(
      rect.center,
      size.shortestSide / 2,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: .10),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: .10),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_Shine old) => false;
}

class _Empty extends StatefulWidget {
  const _Empty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  State<_Empty> createState() => _EmptyState();
}

class _EmptyState extends State<_Empty> with SingleTickerProviderStateMixin {
  late final pulse = AnimationController(
    vsync: this,
    value: .5,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) && !pulse.isAnimating) {
      pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween(
              begin: .9,
              end: 1.1,
            ).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut)),
            child: Icon(widget.icon, size: 72, color: scheme.primary),
          ),
          const SizedBox(height: 12),
          Text(widget.text, style: TextStyle(color: scheme.outline)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- gallery

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    return GridView.builder(
      padding: EdgeInsets.all(duo.margin),
      // even count on a vertical fold, no tile sits on the crease
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: duo.gridColumns(150),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) => _Stagger(
        index: i,
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 450),
              reverseTransitionDuration: const Duration(milliseconds: 350),
              pageBuilder: (context, a, _) => FadeTransition(
                opacity: a,
                child: Viewer(index: i),
              ),
            ),
          ),
          child: Hero(
            tag: 'photo$i',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CustomPaint(painter: _Landscape(photos[i])),
            ),
          ),
        ),
      ),
    );
  }
}

class _Landscape extends CustomPainter {
  _Landscape(this.p);

  final Photo p;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.sky, Color.lerp(p.sky, p.sun, .55)!],
        ).createShader(rect),
    );
    final sun = Offset(size.width * .66, size.height * .42);
    final s = size.shortestSide;
    canvas
      ..drawCircle(sun, s * .26, Paint()..color = p.sun.withValues(alpha: .18))
      ..drawCircle(sun, s * .14, Paint()..color = p.sun);
    for (var k = 0; k < 3; k++) {
      final base = size.height * (.6 + k * .13);
      final path = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= size.width; x += size.width / 32) {
        final wave = math.sin(x / size.width * math.pi * (2 + k) + k * 1.7);
        path.lineTo(x, base - (wave + 1) * size.height * .06);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = Color.lerp(p.land, Colors.black, k * .28)!,
      );
    }
  }

  @override
  bool shouldRepaint(_Landscape old) => old.p != p;
}

class Viewer extends StatefulWidget {
  const Viewer({
    super.key,
    required this.index,
    this.initialFit = DuoMediaFit.smart,
  });

  final int index;
  final DuoMediaFit initialFit;

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  late DuoMediaFit fit = widget.initialFit;

  @override
  Widget build(BuildContext context) {
    final p = photos[widget.index];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(iso(p.title)),
        actions: [
          SegmentedButton<DuoMediaFit>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              foregroundColor: Colors.white70,
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: brand,
              visualDensity: VisualDensity.compact,
            ),
            segments: const [
              ButtonSegment(
                value: DuoMediaFit.smart,
                icon: Icon(Icons.auto_awesome),
                tooltip: 'smart',
              ),
              ButtonSegment(
                value: DuoMediaFit.contain,
                icon: Icon(Icons.fit_screen),
                tooltip: 'contain',
              ),
              ButtonSegment(
                value: DuoMediaFit.cover,
                icon: Icon(Icons.crop),
                tooltip: 'cover',
              ),
            ],
            selected: {fit},
            onSelectionChanged: (s) => setState(() => fit = s.first),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // book: photo | info, tabletop: photo over info, closed: photo only
      body: DuoSplit(
        primary: LayoutBuilder(
          builder: (context, box) {
            final shown = DuoMedia.fitSize(p.ratio, box.biggest, fit: fit);
            final visible =
                math.min(box.maxWidth, shown.width) *
                math.min(box.maxHeight, shown.height) /
                (shown.width * shown.height);
            final crop = ((1 - visible) * 100).round();
            return Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'photo${widget.index}',
                  child: DuoMedia(
                    aspectRatio: p.ratio,
                    fit: fit,
                    child: CustomPaint(painter: _Landscape(p)),
                  ),
                ),
                PositionedDirectional(
                  bottom: 12,
                  start: 12,
                  child: _Pill(
                    '${fit.name} · ${ratio(p.ratio)} · '
                    '${crop == 0 ? 'no crop' : 'crops $crop%'}',
                  ),
                ),
              ],
            );
          },
        ),
        secondary: _PhotoInfo(photo: p, fit: fit),
      ),
    );
  }
}

String ratio(double r) => switch (r) {
  1 => '1:1',
  _ when (r - 16 / 9).abs() < .01 => '16:9',
  _ when (r - 9 / 16).abs() < .01 => '9:16',
  _ when (r - 21 / 9).abs() < .01 => '21:9',
  _ when (r - 4 / 3).abs() < .01 => '4:3',
  _ when (r - 3 / 4).abs() < .01 => '3:4',
  _ when (r - 3 / 2).abs() < .01 => '3:2',
  _ => '2:3',
};

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            text,
            key: ValueKey(text),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _PhotoInfo extends StatelessWidget {
  const _PhotoInfo({required this.photo, required this.fit});

  final Photo photo;
  final DuoMediaFit fit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ColoredBox(
      color: const Color(0xFF121218),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            iso(photo.title),
            style: text.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${ratio(photo.ratio)} · ${context.copy.photo}',
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 20),
          for (final (f, about) in [
            (DuoMediaFit.smart, context.copy.fits[0]),
            (DuoMediaFit.contain, context.copy.fits[1]),
            (DuoMediaFit.cover, context.copy.fits[2]),
          ])
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: f == fit
                    ? brand.withValues(alpha: .35)
                    : Colors.white.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${f.name}\n$about',
                style: const TextStyle(color: Colors.white, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- lab

class LabPage extends StatelessWidget {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final readout = [
      const _Hint(),
      const SizedBox(height: 12),
      const _ScreenShape(),
      const SizedBox(height: 12),
      const _Readout(),
    ];
    final tools = [
      const DuoKeep(id: 'counter', child: _Counter()),
      const SizedBox(height: 12),
      const DuoKeep(id: 'note', child: _Note()),
      const SizedBox(height: 12),
      const _FoldButtons(),
    ];
    // the counter and note are DuoKeep'd, they carry over between builders
    return DuoLayout(
      // not a lazy ListView: an unbuilt DuoKeep child would lose its state
      closed: (context) => SingleChildScrollView(
        padding: EdgeInsets.all(context.duo.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [...readout, const SizedBox(height: 12), ...tools],
        ),
      ),
      open: (context) => DuoSplit(
        primary: ListView(
          padding: EdgeInsets.all(context.duo.margin),
          children: readout,
        ),
        secondary: ListView(
          padding: EdgeInsets.all(context.duo.margin),
          children: tools,
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    final c = context.copy;
    final hint = switch ((duo.mode, duo.posture)) {
      (_, DuoPosture.book) => c.book,
      (_, DuoPosture.tabletop) => c.tabletop,
      (DuoMode.closedPortrait || DuoMode.closedLandscape, _) => c.closed,
      (DuoMode.openLandscape, _) => c.open,
      (DuoMode.openPortrait, _) => c.openPortrait,
      (DuoMode.splitView, _) => c.split,
      (DuoMode.tablet || DuoMode.desktop, _) => c.other,
    };
    final scheme = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Container(
        key: ValueKey(hint),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primaryContainer, scheme.tertiaryContainer],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: scheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// the window shape morphs between poses, fold in blue, insets in red
class _ScreenShape extends StatelessWidget {
  const _ScreenShape();

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    return SizedBox(
      height: 150,
      child: Center(
        child: TweenAnimationBuilder<Size?>(
          tween: SizeTween(end: duo.size),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          builder: (context, s, _) => AspectRatio(
            aspectRatio: s!.isEmpty ? 1 : s.width / s.height,
            child: CustomPaint(
              painter: _ShapePainter(duo, s, Theme.of(context).colorScheme),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.duo, this.window, this.scheme);

  final DuoData duo;
  final Size window;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    if (window.isEmpty) return;
    final k = size.width / window.width;
    final screen = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    canvas
      ..drawRRect(screen, Paint()..color = scheme.surfaceContainerHighest)
      ..save()
      ..clipRRect(screen);
    final p = duo.padding * k;
    final inset = Paint()..color = Colors.red.withValues(alpha: .35);
    canvas
      ..drawRect(Rect.fromLTWH(0, 0, p.left, size.height), inset)
      ..drawRect(
        Rect.fromLTWH(size.width - p.right, 0, p.right, size.height),
        inset,
      )
      ..drawRect(Rect.fromLTWH(0, 0, size.width, p.top), inset)
      ..drawRect(
        Rect.fromLTWH(0, size.height - p.bottom, size.width, p.bottom),
        inset,
      );
    final fold = duo.fold;
    if (fold != null) {
      final f = Rect.fromLTRB(
        fold.left * k,
        fold.top * k,
        fold.right * k,
        fold.bottom * k,
      );
      final vertical = duo.foldDirection == Axis.vertical;
      canvas.drawLine(
        vertical ? f.topCenter : f.centerLeft,
        vertical ? f.bottomCenter : f.centerRight,
        Paint()
          ..color = Colors.blueAccent
          ..strokeWidth = 3,
      );
    }
    canvas.restore();
    canvas.drawRRect(
      screen,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = scheme.outline,
    );
  }

  @override
  bool shouldRepaint(_ShapePainter old) =>
      old.window != window || old.duo.toString() != duo.toString();
}

class _Readout extends StatelessWidget {
  const _Readout();

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    final p = duo.padding;
    final f = duo.fold;
    final stats = {
      'mode': duo.mode.name,
      'posture': duo.posture.name,
      'size': '${n(duo.size.width)}×${n(duo.size.height)}',
      'iPhone Duo': '${duo.isIphoneDuo}',
      'expanded': '${duo.isExpanded}',
      'columns': '${duo.columns}',
      'rail': '${duo.prefersRail}',
      'fold': f == null
          ? 'none'
          : '${duo.foldDirection!.name} @${n(duo.foldDirection == Axis.vertical ? f.center.dx : f.center.dy)}',
      'separating': '${duo.isSeparating}',
      'safe': '${n(p.left)} ${n(p.top)} ${n(p.right)} ${n(p.bottom)}',
      'grid(150)': '${duo.gridColumns(150)}',
      'platform': duo.platform.name,
    };
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in stats.entries)
          Tooltip(
            message: statHelp[e.key],
            triggerMode: TooltipTriggerMode.tap,
            showDuration: const Duration(seconds: 4),
            child: Container(
              constraints: const BoxConstraints(minWidth: 96),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.key,
                    style: TextStyle(fontSize: 11, color: scheme.outline),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: ScaleTransition(scale: a, child: child),
                    ),
                    child: Text(
                      e.value,
                      key: ValueKey(e.value),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: e.value == 'true'
                            ? Colors.green
                            : e.value == 'false'
                            ? scheme.outline
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.copy.counter,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => setState(() => count--),
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 56,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, a) =>
                    ScaleTransition(scale: a, child: child),
                child: Text(
                  '$count',
                  key: ValueKey(count),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
            IconButton.filled(
              onPressed: () => setState(() => count++),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatefulWidget {
  const _Note();

  @override
  State<_Note> createState() => _NoteState();
}

class _NoteState extends State<_Note> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: context.copy.note,
        prefixIcon: const Icon(Icons.edit_note),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _FoldButtons extends StatelessWidget {
  const _FoldButtons();

  @override
  Widget build(BuildContext context) {
    final c = context.copy;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: () => popCard(context),
          icon: const Icon(Icons.style),
          label: Text(c.popCard),
        ),
        OutlinedButton.icon(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(c.dialog),
              content: Text(c.dialogBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(c.ok),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text(c.dialog),
        ),
      ],
    );
  }

  // full screen overlay so DuoAvoidFold can pick a half
  void popCard(BuildContext context) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => DuoAvoidFold(
        child: GestureDetector(
          onTap: entry.remove,
          child: ColoredBox(
            color: Colors.black26,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text('DuoAvoidFold'),
                        Text(
                          context.copy.cardBody,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
  }
}
