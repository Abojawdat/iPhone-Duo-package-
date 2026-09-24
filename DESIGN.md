<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/logo.svg" width="72" alt="duo_dynamic_sizing logo">
</p>

<h1 align="center">Why duo_dynamic_sizing works the way it does</h1>

<p align="center">
  <b>English</b> · <a href="https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/DESIGN.ar.md">العربية</a> · <a href="https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/README.md">Back to README</a>
</p>

Every decision below was checked against the iPhone Duo's real numbers and Apple's own guidance. Most of them replaced an earlier idea that didn't hold up, and the rejected ideas are listed too.

---

## 1. Sizes never scale

**Decision:** a 16 pt label stays 16 pt on every screen. When there's more room, layouts gain panes and columns, not bigger widgets.

**Why:** Apple draws both Duo screens at the same physical point size.

| | Pixels per inch | Pixels per point | Points per inch |
| --- | --- | --- | --- |
| Outer screen | 460 | 3.0 | 153.3 |
| Inner screen | 430 | 2.807 (2007 rendered on a 1878 panel) | 153.2 |

A point is the same size on both screens, so the inner screen is simply more space. Scaling by width would multiply everything by 951 ÷ 466 = 2.04: 16 pt text would jump to 33 pt the moment you unfold.

**What we rejected:** screenutil-style width scaling. The very first version of this project (0.0.1) did exactly that, and the research on the real device numbers is what killed it.

## 2. Everything comes from `MediaQuery`

**Decision:** `context.duo` is built only from `MediaQuery.sizeOf`, `paddingOf`, `displayFeaturesOf` and `devicePixelRatioOf`.

**Why:**
- **The window is what your app actually has.** In Split View, Stage Manager or a desktop window, the window is smaller than the device, and layout has to follow the window.
- **Rebuilds are precise.** Those four aspects rebuild a widget on fold, rotation and Split View, but never on keyboard or text-size changes. A test proves it.
- **It can be simulated.** Because the whole package reads `MediaQuery`, `DuoSimulator` can fake any device, in tests and in a running app.

**What we rejected:**
- **`View.of(context).display`:** it isn't reactive, and Apple warns that the main screen is ambiguous on a two-screen device.
- **Device model strings:** they need native code and can't tell you about Split View.
- **Orientation checks:** the Duo's inner screen ignores orientation locks.

## 3. The Duo is recognized by its exact sizes

**Decision:** on iOS at 3x, these windows are the iPhone Duo, with ±1 pt tolerance:

| Window | Mode |
| --- | --- |
| 466 × 678 (or narrower, older SDKs) | `closedPortrait` |
| 678 × 466 | `closedLandscape` |
| 951 × 669 (or down to 75% of it) | `openLandscape` |
| 669 × 951 | `openPortrait` |
| Any narrower slice of the inner screen | `splitView` |

**Why:** no other iPhone has these sizes at 3x. iPads are 2x, and Android and desktop never report iOS. An iPad Stage Manager window of 466 × 678 is therefore never mistaken for a Duo.

**What we rejected:**
- **Aspect-ratio guesses:** Android foldables have similar ratios, which would cause false positives.
- **The `utsname` machine id (`iPhone19,4`):** it needs native code and describes the device, not the window.

## 4. Two panes from 600 × 480

**Decision:** `isExpanded` means at least 600 pt wide **and** 480 pt tall.

**Why:** 600 is Material 3's medium width. Adding the 480 height rule reproduces Apple's own size classes on the Duo exactly:

| Duo window | Apple size class | 600 wide? | 480 tall? | `isExpanded` |
| --- | --- | --- | --- | --- |
| Closed 466 × 678 | compact | no | yes | no ✓ |
| Closed sideways 678 × 466 | compact | yes | no | no ✓ |
| Open 951 × 669 | regular | yes | yes | yes ✓ |
| Open upright 669 × 951 | regular | yes | yes | yes ✓ |
| Split View 475 × 669 | compact | no | yes | no ✓ |

**What we rejected:** a width-only breakpoint. It would give the closed-sideways Duo two cramped panes, and Apple treats that pose as compact.

## 5. State survives by moving, not rebuilding

**Decision:** when the layout changes shape, widgets are moved to their new place with the same element, using Flutter's `GlobalKey` reparenting. `DuoKeep`, `DuoSplit`, `DuoListDetail`, the scaffold body and `DuoSimulator` all do this.

**Why:** you keep everything a user would notice: scroll position, text being typed, selections and running animations. Apple lists continuity across a fold as a requirement, not a nice-to-have.

**What we rejected:**
- **Making developers lift every piece of state up:** it's a burden, and easy to get wrong.
- **`PageStorage` alone:** it only remembers scroll offsets.

## 6. Split at the fold, mirror by direction

**Decision:**
- **Where the split goes:** `DuoSplit` splits exactly on the fold. That's 475.5 pt on the Duo's inner screen, or the hinge Android reports.
- **Offset boxes:** it measures its own position after each frame, so it still lines up when it sits under an app bar or beside a rail.
- **RTL:** in right-to-left apps the panes swap sides, but the split never moves.

**Why:** the hinge decides where the split goes, and the reading direction decides which pane comes first. Mixing the two would put content on the crease.

**What we rejected:**
- **Half of the local box:** it misses the fold whenever the box is offset.
- **Mirroring the geometry in RTL:** it moves the split off the fold.

## 7. Navigation goes where iOS 27 puts it

**Decision:**
- **The Duo:** the rail sits on the physical right, next to the Dynamic Island, in every language, because Apple aligns vertical bars with the hardware.
- **Split View:** the left-hand app gets its rail on the left edge.
- **Open upright:** this is the only pose with a bottom bar.
- **Other devices:** Material 3 rules apply (a rail from 600 pt, start side).
- **`railSide`:** apps that prefer the reading direction everywhere can choose it.

**Robustness (every item below came from the edge-case tests):**
- **Text scale:** labels are capped at 1.3x, the same cap Flutter's own `NavigationBar` uses. 3x accessibility text used to overflow the closed Duo by 47 px.
- **Scrolling:** the rail scrolls when items don't fit. Seven tabs used to overflow the 386 pt of height on the closed-sideways Duo.
- **Long labels** are shortened with an ellipsis.
- **Width:** the rail never takes more than 30% of the window. It keeps its natural 80 pt width by using `IntrinsicWidth` inside that cap. The golden tests caught the first version stretching the rail to 140 pt.

## 8. Smart media fit at 15%

**Decision:** `DuoMediaFit.smart` crops (cover) only when the crop hides at most 15% of the media; otherwise it adds bars (contain).

**Why:** here are the real numbers for the Duo's 951 × 669 inner screen:

| Video | Cover hides | Contain leaves empty | Smart picks |
| --- | --- | --- | --- |
| 16:9 | 20% | 20% | contain |
| 4:3 | 6% | 6% | cover |
| 3:2 | 5% | 5% | cover |

Photos and most social video fill the screen; cinematic video keeps its edges.

**What we rejected:** always cropping, which cuts subtitles and faces, and always letterboxing, which wastes a fifth of a $1,999 screen.

## 9. Pure Dart, no native code

**Decision:** the package has no platform channels, no iOS or Android code and no pods.

**Why:**
- **It works today** with any Flutter from 3.41, any Xcode and any platform, including web and desktop.
- **iOS doesn't pass the hinge to Flutter yet** ([flutter#192515](https://github.com/flutter/flutter/issues/192515)). When it does, `displayFeatures` will carry it and this package picks it up with no change.
- **Apple itself says hinge data is for effects,** not layout. Layout needs the window, and the window is already in Dart.

**What we rejected:** writing a native plugin. It would need Xcode 27.1, work only on iOS, and carry native maintenance. Packages such as [`foldable`](https://pub.dev/packages/foldable) already cover live hinge angles, and they combine well with this one.

## 10. Never crash on bad input

**Decision:** anything a developer can do by accident should degrade gracefully.

| Scenario | Behavior |
| --- | --- |
| `DuoSplit` inside a scroll view or unbounded `Column` | One pane |
| `DuoMedia` with a 0, negative, NaN or infinite ratio | Assertion in debug; fills the box in release |
| 0 × 0 or 150 × 150 window | Works, one pane |
| Tri-fold phone with two hinges | Splits at the first fold |
| Fold outside the window | Ignored |
| No `MaterialApp` or `Navigator` | `DuoListDetail` still works |

These all live in [`test/edge_cases_test.dart`](test/edge_cases_test.dart), and every bug fix gets a case there.

## 11. Tested without the hardware

**Decision:** everything can be tested before the iPhone Duo ships, and without the Xcode 27.1 simulator.

| Test | What it checks |
| --- | --- |
| 97 unit, widget, edge-case and golden tests | Every mode, pose, fold, direction and rail placement, plus pixel references for each pose |
| 9 integration tests on the real macOS app | Taps, folds, Split View, RTL and live window resizing on the real engine |
| Render tool | The animations on this page are real frames of the example app |

## 12. What we deliberately left out

- **The hinge angle on iOS.** The Flutter engine doesn't expose it yet.
- **Native vertical bars** (`toolbarVerticalBehavior`, `ArrangementView`). Flutter has no equivalent, so `DuoNavigationScaffold` mirrors their placement instead.
- **Automatic scaling.** See decision 1.
- **Multi-window scene APIs.** They're outside a layout package.

---

<p align="center">
  <sub>MIT © Mohammad Othman · <a href="https://github.com/Abojawdat/iPhone-Duo-package-">github.com/Abojawdat/iPhone-Duo-package-</a></sub>
</p>
