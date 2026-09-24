<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/banner.svg" width="100%" alt="duo_dynamic_sizing: adaptive layout for the foldable iPhone Duo and every other screen">
</p>

<p align="center">
  <b>English</b> · <a href="https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/README.ar.md">العربية</a>
</p>

<p align="center">
  <a href="https://pub.dev/packages/duo_dynamic_sizing"><img src="https://img.shields.io/pub/v/duo_dynamic_sizing?style=flat-square&color=6D5DFC&labelColor=0A0B14&label=pub" alt="pub version"></a>
  <img src="https://img.shields.io/badge/iPhone_Duo-ready-22D3EE?style=flat-square&labelColor=0A0B14" alt="iPhone Duo ready">
  <img src="https://img.shields.io/badge/Flutter-3.41%2B-A855F7?style=flat-square&labelColor=0A0B14" alt="Flutter 3.41+">
  <img src="https://img.shields.io/badge/native_code-none-8B7CFF?style=flat-square&labelColor=0A0B14" alt="no native code">
  <img src="https://img.shields.io/badge/RTL-ready-34D399?style=flat-square&labelColor=0A0B14" alt="RTL ready">
  <a href="https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-9AA0B8?style=flat-square&labelColor=0A0B14" alt="MIT license"></a>
</p>

<p align="center">
  <b>One <code>context.duo</code> that knows if the phone is folded, open, sideways or sharing the screen.</b><br>
  Widgets that lay out, navigate and keep state the way iOS 27 does on Apple's first foldable.<br>
  Pure Dart. Works today on iOS, Android, web and desktop, in English, Arabic and every other language.
</p>

---

## See it in action

Every clip below is the real [example app](example/lib/main.dart) running this package, rendered frame by frame. Nothing is mocked up.

### 1. Fold and unfold

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/fold.webp" width="100%" alt="The same email stays open while an iPhone Duo unfolds from one pane into list and detail">
</p>

**What happens:** closed, the email fills the 466 pt outer screen. Open the phone and the list slides back in beside the same email, still scrolled where you left it.<br>
**Why:** Apple treats continuity across a fold as a requirement. People fold in the middle of reading and expect to land exactly where they were. Nothing here rebuilds from scratch: the package moves the same widget element to its new place.<br>
**Code:** `DuoListDetail` inside `DuoNavigationScaffold`, nothing else.

### 2. Split View

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/split.webp" width="100%" alt="The app shrinks into Split View and its rail jumps to the outer edge">
</p>

**What happens:** a second app joins. Yours shrinks live from 951 to 475 pt. The moment it becomes a Split View slice, its rail jumps from the island side to its own outer edge, and the list collapses to one pane.<br>
**Why:** that's where iOS 27 puts the bars of the left-hand app. Every intermediate width is laid out for real, so there's no snapping between a few hand-picked sizes.<br>
**Code:** nothing extra. `context.duo.isSplit` tells you when it happens.

### 3. Half open: tabletop and book

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/postures.webp" width="100%" alt="An Android foldable bends into tabletop and book posture and the layout follows the hinge">
</p>

**What happens:** on a table, the video jumps above the fold and the controls drop to the bottom half. Held like a book, the controls slide to the trailing half.<br>
**Why:** a bent screen has two surfaces. Content that straddles the crease is hard to read and hard to tap, and Apple's guidance says the same.<br>
**Code:** `DuoSplit` for the two halves, `DuoAvoidFold` for floating controls, `context.duo.posture` to decide.

### 4. Rotation

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/rotate.webp" width="100%" alt="The closed and the open iPhone Duo rotate and the navigation follows">
</p>

**What happens:** closed and turned sideways, the island moves to the top and the rail stays on the side. Open and turned upright, the rail becomes a bottom bar, the one pose where iOS keeps horizontal bars.<br>
**Why:** the Duo's inner screen ignores orientation locks, so your layout has to follow the window, not the device orientation.<br>
**Code:** `DuoNavigationScaffold` decides with `context.duo.prefersRail`.

### 5. Resizable windows

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/resize.webp" width="100%" alt="A desktop window is dragged from phone width to wide and the layout keeps up">
</p>

**What happens:** a desktop window is dragged from 360 to 1240 pt. The mode, the number of panes and the navigation all update on every frame.<br>
**Why:** the same rules that handle the Duo handle iPad Stage Manager, web browsers and desktop windows. One set of layout decisions covers every screen.<br>
**Code:** the same app, with no platform checks.

### 6. English and Arabic

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/rtl.webp" width="100%" alt="The app flips from English to a right-to-left Arabic interface">
</p>

**What happens:** the app switches to Arabic. The list moves to the right and the detail to the left, while the split stays exactly on the physical fold.<br>
**Why:** reading direction decides where the primary pane goes; the hinge decides where the split goes. Mixing those two up would put content on the crease.<br>
**Code:** automatic from your app's `Directionality`. Override with `textDirection:` and `railSide:`.

### 7. Media fit

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/anim/media.webp" width="100%" alt="The same 16:9 video cycles through contain, cover and smart fit">
</p>

**What happens:** the same 16:9 video cycles through `contain` (bars), `cover` (cropped) and `smart`, which crops only when it loses less than 15%.<br>
**Why:** the inner screen is √2 shaped, so 16:9 video leaves 134 pt of black bars. Sometimes a small crop is the better trade, and sometimes it isn't.<br>
**Code:** `DuoMedia(aspectRatio: 16 / 9, child: player)`.

## iPhone Duo, every pose

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/iphone-duo.webp" width="100%" alt="The showcase app on the iPhone Duo closed, open, upright, sideways and in Split View">
</p>

| Pose | Window (pt) | What your app gets |
| --- | --- | --- |
| **Closed** | 466 × 678 | One pane. The rail sits on the right, next to the vertical Dynamic Island. |
| **Closed, sideways** | 678 × 466 | One pane in landscape. |
| **Open** | 951 × 669 | Two panes, split exactly at the fold. |
| **Open, upright** | 669 × 951 | Two panes and a bottom bar. |
| **Split View** | about 475 × 669 | One pane per app, each with its rail on its own outer edge. |

## And every other screen

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/everywhere.webp" width="100%" alt="The same app on an iPhone, an Android foldable in book and tabletop posture, and an iPad">
</p>

On Android foldables the package reads the real fold from `MediaQuery.displayFeatures`. Phones, tablets, web and desktop get the same widgets, driven by window size.

## Install

```sh
flutter pub add duo_dynamic_sizing
```

Needs Flutter 3.41+ (Dart 3.11+). There's no setup, no platform code and no permissions.

## Minimal example

A complete app in about 40 lines: a mail list that becomes list + detail when there's room, with the right navigation on every screen. It's [`example/lib/minimal.dart`](example/lib/minimal.dart); run it with `flutter run -t lib/minimal.dart`.

```dart
import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Inbox()));

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  int tab = 0;
  int? open;

  @override
  Widget build(BuildContext context) {
    return DuoNavigationScaffold(
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
        list: (_) => ListView.builder(
          itemCount: 30,
          itemBuilder: (_, i) => ListTile(
            title: Text('Message $i'),
            selected: i == open,
            onTap: () => setState(() => open = i),
          ),
        ),
        detail: (_, i) => Center(child: Text('Message $i')),
      ),
    );
  }
}
```

The same code gives you all of this:

| Screen | Result |
| --- | --- |
| iPhone Duo closed | the list, and the message full screen once tapped; rail by the island |
| iPhone Duo open | list and message side by side, split at the fold |
| Split View | one pane, rail on the app's outer edge |
| Android foldable half open | panes split exactly at the hinge |
| iPhone | one pane, bottom bar |
| iPad, desktop, web | list and message side by side, side rail |
| Arabic or Hebrew app | everything mirrored, still split at the fold |

Reading the window yourself works anywhere:

```dart
final duo = context.duo; // rebuilds on fold, rotation and Split View

if (duo.isExpanded) { /* two panes */ }
duo.mode;             // DuoMode.openLandscape
duo.safe.right;       // 59, the Dynamic Island side
duo.gridColumns(160); // even across the fold
```

## Why it's built this way

The short version is below. The full reasoning, with the alternatives we rejected, is in [DESIGN.md](https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/DESIGN.md) ([العربية](https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/DESIGN.ar.md)).

- **Sizes never scale.** Both Duo screens have the same physical point size, about 153 points per inch. Width-scaled 16 pt text would jump to 33 pt when you unfold, so layouts gain panes, not bigger widgets.
- **Everything comes from `MediaQuery`.** That makes it reactive, testable and simulator-friendly, and it only rebuilds when the window really changes.
- **Pure Dart.** It works today on every Flutter version from 3.41 and every platform, with no Xcode 27.1 or pods required.
- **The iPhone Duo is detected by its exact screen sizes** at 3x on iOS, so iPads, Android phones and desktop windows are never mistaken for it.
- **State survives every fold** because the package moves widgets instead of rebuilding them.
- **Tested hard:** 97 unit, widget, edge-case and golden tests, plus 10 integration tests on the real macOS app.

## What's inside

| | |
| --- | --- |
| `context.duo` | Mode, open or closed, panes, fold, posture, per-side safe areas, margins, grid columns. |
| `DuoLayout` + `DuoKeep` | Separate closed and open layouts that keep shared widgets' state and scroll position. |
| `DuoSplit` | Two panes aligned to the fold or hinge, one pane when there's no room. Flutter's take on Apple's split `ArrangementView`. |
| `DuoListDetail` | Mail-style list and detail, with system back and fold continuity handled. |
| `DuoNavigationScaffold` | Bottom bar or side rail, placed where iOS 27 puts its vertical bars. `railSide` picks the side for LTR and RTL apps. |
| `DuoAvoidFold` | Keeps controls off a half-open fold: trailing half in book posture, bottom half on a table. |
| `DuoMedia` | Fits 16:9 video to the √2 screen, cropping only when little is lost. |
| `DuoSimulator` + `DuoPose` | Every iPhone Duo pose, Android folds, iPhone and iPad, on any device and in widget tests. |
| `DuoDebugOverlay` | Live readout of mode, size, safe area and fold. |

## `context.duo`

| Member | Type | What it tells you |
| --- | --- | --- |
| `mode` | `DuoMode` | `closedPortrait`, `closedLandscape`, `openLandscape`, `openPortrait`, `splitView`, `tablet`, `desktop` |
| `isIphoneDuo` | `bool` | The window matches an iPhone Duo screen. |
| `isOpen`, `isClosed`, `isSplit` | `bool` | Device state. |
| `isExpanded`, `columns` | `bool`, `int` | Room for two panes (600 × 480 and up). Drive layout off these. |
| `fold`, `foldDirection` | `Rect?`, `Axis?` | Where the fold runs, in window coordinates. |
| `isSeparating`, `posture` | `bool`, `DuoPosture` | Half-open fold or hinge: `flat`, `book`, `tabletop`, `closed`. |
| `safe`, `symmetricSafe` | `EdgeInsets` | Per-side insets, or the mirrored maximum for centred content. |
| `margin` | `double` | 16 on compact widths, 24 otherwise (Material 3). |
| `prefersRail` | `bool` | Side rail instead of a bottom bar. |
| `gridColumns(minWidth)` | `int` | Columns that fit, kept even across a vertical fold. |

Change the thresholds for a subtree with `DuoScope(expandedWidth: 700, child: ...)`.

## Widgets

**Two layouts, one state.** `DuoKeep` moves the same element between layouts instead of rebuilding it:

```dart
DuoLayout(
  closed: (_) => DuoKeep(id: 'feed', child: const Feed()),
  open: (_) => Row(children: [
    Expanded(child: DuoKeep(id: 'feed', child: const Feed())),
    const Expanded(child: Trends()),
  ]),
)
```

**Panes that follow the fold:**

```dart
DuoSplit(primary: const Player(), secondary: const UpNext())
```

**Controls that dodge the crease:**

```dart
Stack(children: [
  const VideoPlayer(),
  const DuoAvoidFold(
    child: Align(alignment: Alignment.bottomCenter, child: Controls()),
  ),
])
```

**Video that fits the screen:**

```dart
DuoMedia(aspectRatio: 16 / 9, child: player) // smart: crops up to 15%, else letterboxes
```

## RTL and LTR

Everything follows your app's `Directionality`, so Arabic, Hebrew and Persian apps get mirrored layouts with no extra code. When panes swap sides, the split still lands exactly on the physical fold.

| | LTR app | RTL app |
| --- | --- | --- |
| `DuoSplit`, `DuoListDetail` | Primary (list) on the left | Primary (list) on the right |
| `DuoAvoidFold`, book posture | Right half | Left half |
| `DuoSplit(ratio: .3)` | Primary takes 30% on the left | Primary takes 30% on the right |

You choose where the navigation rail goes with `railSide`:

| `railSide` | iPhone Duo | Everywhere else |
| --- | --- | --- |
| `auto` (default) | Right, next to the Dynamic Island, like iOS 27's vertical bars in every language | Start side: left in LTR, right in RTL |
| `start` | Start side | Start side |
| `end` | End side | End side |
| `left`, `right` | Always that side | Always that side |

```dart
DuoNavigationScaffold(railSide: DuoRailSide.start, ...) // follow the reading direction everywhere
DuoListDetail(textDirection: TextDirection.ltr, ...)     // pin one layout, whatever the app uses
```

## Test every pose without a device

```dart
testWidgets('unfolding keeps the draft', (tester) async {
  await tester.pumpWidget(
    const DuoSimulator(pose: DuoPose.closedPortrait, child: MyApp()),
  );
  await tester.enterText(find.byType(TextField), 'draft');

  await tester.pumpWidget(
    const DuoSimulator(pose: DuoPose.openLandscape, child: MyApp()),
  );
  expect(find.text('draft'), findsOneWidget);
});
```

Built-in poses: `closedPortrait`, `closedLandscape`, `openLandscape`, `openPortrait`, `splitLeft`, `splitRight`, `foldableBook`, `foldableTabletop`, `iPhone`, `iPad`. You can also build your own with `DuoPose(...)`.

To see the live values while you develop:

```dart
MaterialApp(
  builder: (context, child) =>
      DuoDebugOverlay(enabled: kDebugMode, child: child!),
)
```

## Shipping on the iPhone Duo

- **Build with the iOS 27.1 SDK (Xcode 27.1).** Apps built with older SDKs run letterboxed on the inner screen.
- **Adopt the UIScene lifecycle.** Xcode 27 builds crash at launch without it. Flutter 3.41+ migrates an unmodified `AppDelegate` for you; see Flutter's [UIScene guide](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate).
- **Don't count on orientation locks.** The inner screen ignores `SystemChrome.setPreferredOrientations`.
- **Never cache sizes in `State`.** Read `MediaQuery` or `context.duo` in `build`.
- **Treat left and right insets separately.** The Dynamic Island runs down one side.
- **Pause media on `paused`, not `inactive`.** In Split View your app stays visible while `inactive`.
- **Keep taps off the fold when half open.** Use `DuoAvoidFold` and `DuoSplit`.

## The iPhone Duo at a glance

| | Outer screen | Inner screen |
| --- | --- | --- |
| Diagonal | 5.4″ | 7.6″ |
| Panel | 1398 × 2034 px, 460 ppi | 1878 × 2670 px, 430 ppi |
| Points (what Flutter sees) | 466 × 678 @3x | 669 × 951 @3x, drawn at 2007 × 2853 then scaled to the panel |
| Size class | compact | regular × regular |

Apple announced it on 9 September 2026, and it ships on 23 October 2026 with iOS 27.1. It measures 164.6 × 117.8 mm open, 84.1 × 117.8 mm closed, and weighs 254 g.

## Limitations

- **No hinge angle or half-open posture on iOS yet.** Flutter's iOS engine doesn't forward the iPhone Duo hinge to Dart ([flutter#192515](https://github.com/flutter/flutter/issues/192515)). Until it does, `posture` on the Duo is `closed` or `unknown`, and the fold is the known physical centre line. When the engine starts reporting it, this package picks it up automatically through `displayFeatures`. For live hinge angles today, pair it with a native plugin such as [`foldable`](https://pub.dev/packages/foldable).
- **Simulator safe areas are estimates.** Apple hasn't published the Duo's inset values, so `DuoPose` uses 59 pt and 21 pt. Real devices always use the live values.
- **The Split View side is inferred** from which side has the Dynamic Island inset.
- **Native vertical bars have no Flutter equivalent.** `DuoNavigationScaffold` mirrors their placement with Material widgets.

## Example

```sh
cd example
flutter run                    # the full showcase with a pose picker
flutter run -t lib/minimal.dart # the 40-line app above
```

In the showcase, pick any pose from the chip bar to simulate it on whatever device you're using, turn on **RTL** for the Arabic version, or choose **This device** to run it for real.

## Contributing

Bug reports and pull requests are welcome in the [issue tracker](https://github.com/Abojawdat/iPhone-Duo-package-/issues). If something looks off on a real iPhone Duo, a screenshot with `DuoDebugOverlay` turned on helps a lot.

<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/logo.svg" width="56" alt="duo_dynamic_sizing logo"><br>
  <sub>MIT © Mohammad Othman</sub><br>
  <sub>iPhone and iPhone Duo are trademarks of Apple Inc. This package isn't affiliated with or endorsed by Apple.</sub>
</p>
