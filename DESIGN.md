<p align="center">
  <img src="https://raw.githubusercontent.com/Abojawdat/iPhone-Duo-package-/main/doc/logo.svg" width="72" alt="duo_dynamic_sizing logo">
</p>

<h1 align="center">Why duo_dynamic_sizing works the way it does</h1>

<p align="center">
  <b>English</b> · <a href="https://github.com/Abojawdat/iPhone-Duo-package-/blob/main/DESIGN.ar.md">العربية</a> · <a href="https://github.com/Abojawdat/iPhone-Duo-package-#english">Back to README</a>
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

## 2. Everything comes from `MediaQuery` and the hinge

**Decision:** `context.duo` is built from `MediaQuery.sizeOf`, `paddingOf`, `displayFeaturesOf` and `devicePixelRatioOf`, plus the hinge data of the nearest `DuoHardwareScope`.

**Why:**
- **The window is what your app actually has.** In Split View, Stage Manager or a desktop window, the window is smaller than the device, and layout has to follow the window.
- **Rebuilds are precise.** Those four aspects rebuild a widget on fold, rotation and Split View, but never on keyboard or text-size changes. A test proves it.
- **It can be simulated.** Because the whole package reads `MediaQuery` and the scope, `DuoSimulator` can fake any device, hinge included, in tests and in a running app.
- **The hinge rebuilds layout only when layout changes.** The scope is an `InheritedModel` with two aspects. `context.duo` and `DuoHardware.of` rebuild on posture, fold, camera, size class and bar edge changes; only `DuoHardware.angleOf` readers rebuild on every angle tick. Apple's own guidance is to drive layout from posture and effects from the angle.

**What we rejected:**
- **`View.of(context).display`:** it isn't reactive, and Apple warns that the main screen is ambiguous on a two-screen device.
- **Device model strings:** they need native code and can't tell you about Split View.
- **Orientation checks:** the Duo's inner screen ignores orientation locks.
- **Rebuilding on every angle tick:** the angle updates many times a second while the hinge moves, and relaying out the whole app for each degree would drop frames for no visible change.

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

**Or by its hinge.** When a `DuoHardwareScope` reports a hinge on iOS, the window counts as the Duo even when it matches none of these sizes, for example an app built against an older SDK that iOS letterboxes. The hinge status then picks the mode, a window under 600 × 480 is Split View, and the fold falls back to the window's centre when iOS reports no region.

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
- **Where the split goes:** `DuoSplit` splits exactly on the fold. That's 475.5 pt on the Duo's inner screen, Apple's 40 pt fold region while the Duo is half open, or the hinge Android reports.
- **A fold hugging an edge is ignored:** in Split View the 40 pt region reaches 20 pt into the window beside it. Splitting there would leave a second pane 0 pt wide, so a fold that leaves less than an eighth of the box on either side doesn't split it.
- **Offset boxes:** it measures its own position after each frame, so it still lines up when it sits under an app bar or beside a rail.
- **RTL:** in right-to-left apps the panes swap sides, but the split never moves.

**Why:** the hinge decides where the split goes, and the reading direction decides which pane comes first. Mixing the two would put content on the crease.

**What we rejected:**
- **Half of the local box:** it misses the fold whenever the box is offset.
- **Mirroring the geometry in RTL:** it moves the split off the fold.
- **Splitting wherever a fold touches the box:** it gave Split View apps a 0 pt pane. The edge-case tests caught it.

## 7. Navigation goes where iOS 27 puts it

**Decision:**
- **The Duo:** the rail sits on the side iOS reports for its vertical bar. Until the hinge scope reports one, that's the physical right, next to the Dynamic Island, in every language, because Apple aligns vertical bars with the hardware.
- **Split View:** the left-hand app gets its rail on the left edge.
- **Open upright:** this is the only pose with a bottom bar.
- **Other devices:** Material 3 rules apply (a rail from 600 pt, start side).
- **`railSide`:** apps that prefer the reading direction everywhere can choose it.

**Robustness (every item below came from the edge-case tests):**
- **Text scale:** labels are capped at 1.3x, the same cap Flutter's own `NavigationBar` uses. 3x accessibility text used to overflow the closed Duo by 47 px.
- **Scrolling:** the rail scrolls when items don't fit. Seven tabs used to overflow the 386 pt of height on the closed-sideways Duo.
- **Long labels** are shortened with an ellipsis.
- **Width:** the rail never takes more than 30% of the window. It keeps its natural 80 pt width by using `IntrinsicWidth` inside that cap. The golden tests caught the first version stretching the rail to 140 pt.
- **Glass:** `glass: true` draws the rail on real `UIGlassEffect` on iOS 26+, and on a blur with a 1 px light edge elsewhere. It follows the app's theme, not the system's: a dark app on a light phone first got light-gray glass, which the iPad simulator screenshots caught.

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

## 9. Native code only where the data lives

**Decision:** a small Swift file on iOS and a small Java file on Android feed `DuoHardwareScope`. Web and desktop stay pure Dart, declared as Dart-only plugin platforms so pub.dev still lists all six.

**Why:**
- **The hinge only exists natively.** Flutter's iOS engine doesn't forward it ([flutter#192515](https://github.com/flutter/flutter/issues/192515)), and Android passes the fold but not the angle. Without native code, posture on the Duo can only ever be `closed` or `unknown`.
- **It builds on any Xcode.** Every iOS 27.1 type is looked up at runtime and never named in Swift. A missing or reshaped API turns the feature off instead of crashing, and `DuoHardware.describeNative()` shows what the running OS really exposes.
- **Regions are read during layout.** UIKit has no notification for reserved regions, but it reruns a view's layout when a region read during layout changes. So a clear probe view over the Flutter view reads them in `layoutSubviews`.
- **Java on Android** builds the same on AGP 8 and AGP 9, which set up Kotlin differently.

**What we rejected:**
- **Staying pure Dart:** no posture, fold width or cameras on the Duo until the engine catches up.
- **A companion package:** two installs and two releases for one feature.
- **Wrapping another hinge plugin:** its release schedule and iOS-only scope would become ours.
- **Typed Swift against the 27.1 SDK:** it would force Xcode 27.1 on every app that depends on this package.

## 10. The fold splits only while half open

**Decision:** Apple's fold region separates content only while the hinge reads `partiallyOpen`. Flat, it's a zero-width line at its centre. Closed, there's no fold, because the view is on the cover screen. A zero-width region never splits.

**Why:** the region's `isActive` flag lags the hinge. Laying the phone flat clears it a few milliseconds later, but folding sets it only about a second later, once the hinge comes to rest, and nothing announces the change. Posture is the reliable signal, so `isActive` is only trusted while the hinge status is still unknown.

**What we rejected:** trusting `isActive` alone. Right after the phone is laid flat it can still read true, which would keep a 40 pt gap in every split on a flat screen.

## 11. Dialogs keep their full width by default

**Decision:** `DuoHardwareScope` doesn't write to `MediaQuery.displayFeatures` unless asked with `bridge: DuoBridge.cameras` or `DuoBridge.all`. Even then the fold is published only while half open, never flat, closed or zero-width, and the scope steps aside if Flutter starts reporting folds on iOS itself.

**Why:** Flutter's `DisplayFeatureSubScreen` puts every dialog, bottom sheet, menu and picker on one side of a half-open fold. On the Duo's 951 pt inner screen that turns a full-width dialog into about 455 pt. Adding a dependency mustn't change every Material surface in an app. Our own widgets don't need the bridge: `DuoSplit` and `DuoAvoidFold` read the hinge fold directly.

**What we rejected:** publishing the fold by default, which silently halves every dialog, and publishing the raw regions, which would split layouts on a flat phone.

## 12. Never crash on bad input

**Decision:** anything a developer can do by accident should degrade gracefully.

| Scenario | Behavior |
| --- | --- |
| `DuoSplit` inside a scroll view or unbounded `Column` | One pane |
| `DuoMedia` with a 0, negative, NaN or infinite ratio | Assertion in debug; fills the box in release |
| 0 × 0 or 150 × 150 window | Works, one pane |
| Tri-fold phone with two hinges | Splits at the first fold |
| Fold outside the window | Ignored |
| No `MaterialApp` or `Navigator` | `DuoListDetail` still works |
| Junk or errors from the platform channel | Ignored; the data becomes `DuoHardware.none` |
| No plugin (widget tests, web, desktop) | `DuoHardware.none`, no errors |
| iOS before 27.1, or an API that changed shape | Size classes only; the rest stays empty |
| Android angle before the hinge first moves after a wake | `null`; posture still comes from Android |
| iOS fold region overlapping a Split View window's edge | One pane |

These all live in [`test/edge_cases_test.dart`](test/edge_cases_test.dart), and every bug fix gets a case there.

## 13. Tested without the hardware

**Decision:** everything can be tested before the iPhone Duo ships, and without the Xcode 27.1 simulator. The iOS hinge code is written against the iOS 27.1 API as documented from its SDK headers, and it has run on iOS 26 simulators, where that API is absent. It hasn't run on a Duo yet.

| Test | What it checks |
| --- | --- |
| 141 unit, widget, edge-case and golden tests | Every mode, pose, fold, direction and rail placement, pixel references for each pose, hinge data, bridge modes, junk channel data and rebuild isolation |
| Integration tests on macOS, the iOS simulator and a Pixel Fold emulator | Taps, folds, Split View, RTL, window resizing, the live native side and Liquid Glass on the real engine |
| A live fold on the Pixel Fold emulator | The hinge sensor driven from flat through half open, rapid flapping and shut, and back, with no errors |
| Render tool | The animations on this page are real frames of the example app |

## 14. What we deliberately left out

- **UIKit's own bars** (`toolbarVerticalBehavior`, `ArrangementView`). The rail goes where iOS reports its vertical bar and can sit on real Liquid Glass, but UIKit bar items aren't bridged.
- **Automatic scaling.** See decision 1.
- **Multi-window scene APIs.** They're outside a layout package.

---

<p align="center">
  <sub>MIT © Mohammad Othman · <a href="https://github.com/Abojawdat/iPhone-Duo-package-">github.com/Abojawdat/iPhone-Duo-package-</a></sub>
</p>
