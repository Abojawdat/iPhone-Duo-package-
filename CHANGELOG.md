## 2.0.0

Live hinge data on iOS and Android. The package now ships a small native side, so this is a major release.

Breaking:

* The package is a Flutter plugin now, with a Swift file for iOS and a Java file for Android. iOS apps need a deployment target of 15.0 or newer, which Xcode 27.1 requires anyway. Web and desktop stay pure Dart.
* `DuoPose.values` has two more poses, `halfOpenBook` and `halfOpenTabletop`, after `splitRight`.
* `DuoSplit` and `splitPanes` ignore a fold that leaves less than an eighth of the box on one side, so a fold hugging a Split View window's edge no longer makes a 0 pt pane.

New:

* `DuoHardwareScope` and `DuoHardware`: on iOS 27.1, the live hinge angle and status, Apple's fold region (40 pt while half open), camera regions, size classes and the vertical bar edge; on Android foldables, the hinge angle and status from the hinge sensor. `context.duo` picks it all up: the real posture on the Duo, plus `hardware`, `cameras` and `cameraInsets`.
* Layout readers never rebuild on angle ticks. `DuoHardware.angleOf` and `DuoHardware.angleStream` give the live angle.
* `bridge` (`none`, `cameras`, `all`) optionally publishes the fold and cameras to `MediaQuery.displayFeatures`. It's off by default, so dialogs and sheets keep their full width.
* `DuoHardware.describeNative()` shows what the running OS exposes, for bug reports.
* `DuoGlass`: real Liquid Glass on iOS 26+ and a blur elsewhere, following the app's light or dark theme. `DuoNavigationScaffold(glass: true)` puts the rail on it.
* `DuoRailSide.auto` follows the side iOS reports for its vertical bar.
* `DuoAvoidFold` avoids the iOS hinge fold, bridged or not.
* The Duo is recognized from its hinge even when an older SDK letterboxes the window.
* `DuoPose.hardware` simulates hinge data, and `DuoSimulator` never lets the real device's hinge leak into the fake window. Its guides draw the fold band and cameras in use.
* Example: the Lab shows the hinge status, live angle, cameras and bar edge, with a Native API button; the playground's rail is on Liquid Glass on iOS; `lib/minimal.dart` wraps its app in `DuoHardwareScope`.
* Tests: hinge parsing, junk channel data, a missing plugin, bridge modes, rebuild isolation and new edge cases, plus integration tests for the live native side and a live fold sweep, run on macOS, the iOS simulator and a Pixel Fold emulator.
* README and DESIGN, in English and Arabic, cover live hinge data. A new README animation shows the Duo bending like a book and on a table while the angle counts down and the panes move off the fold, and the banner and social preview now read Live hinge, Fold aware, Split View and Liquid Glass.

## 1.0.10

Docs only, no code changes:

* A **Try it** button at the top of the README jumps to a new "Try it in 30 seconds" section: three commands that download and run the example app, and what to do first. Both languages have it, and the Example section at the bottom uses the same commands.

## 1.0.9

Docs only, no code changes:

* README captions describe the new example in English and Arabic: the track that keeps playing through a fold, the photo that sits above the fold on a table, and the 16:9 photo that cycles through the media fit modes.

## 1.0.8

Docs only, no code changes:

* Every README image and animation is re-rendered from the new example app, in light mode: the fold, Split View, half-open postures, rotation, resizing, Arabic and media fit, plus the pose galleries and the social preview.

## 1.0.7

Docs only, no code changes:

* New package logo, the same design as the example app icon: an open iPhone Duo with a record on one screen, a sunset on the other and the fold glowing between them. It replaces the old logo in `doc/logo.svg` and the README banner.

## 1.0.6

Docs only, no code changes:

* The Example tab on pub.dev is now a short guide: the three commands to run the playground, what every control does, what the red and blue areas mean, and four things to try.

## 1.0.5

Example only, no package code changes:

* The example app has its own icon on Android, iOS, macOS and web: an open iPhone Duo with music on one screen and a photo on the other, the fold glowing between them. `example/tool/make_icon.py` regenerates every size.
* The app is called Duo Playground on every platform.

## 1.0.4

Example only, no package code changes:

* New example app: a music player, a photo gallery and a live `context.duo` lab, with a pose picker, an automatic fold tour, a help sheet that explains every control and an English / Iraqi Arabic switch.
* Integration tests drive the new app through every pose.

## 1.0.3

Docs only, no code changes:

* The Arabic README section, DESIGN.ar.md and the example app's Arabic text are now in Iraqi (Baghdadi) Arabic.
* The author section links the issues page in both languages.

## 1.0.2

Docs only, no code changes:

* README credits @Abojawdat with links to the GitHub profile and source, and keeps a single English / Arabic navigator at the top.
* Smoother README on fast scrolling: smaller animations and a banner without blur filters.
* Shorter Arabic README section, so the README passes pub.dev's English-content check (160/160 pub points).

## 1.0.1

Fixes found by edge-case testing:

* `DuoSplit` and `DuoListDetail` no longer crash inside scroll views or unbounded `Column`s; they fall back to one pane.
* `DuoMedia` rejects a zero, negative, NaN or infinite `aspectRatio` in debug, and `fitSize` never returns NaN or infinity.
* `DuoNavigationScaffold`'s rail scrolls when destinations don't fit (7 tabs on the closed-sideways Duo), caps label text at 1.3x like `NavigationBar` (3x accessibility text no longer overflows), shortens very long labels with an ellipsis, and never takes more than 30% of the window.

Other changes:

* Example now runs on macOS, and the showcase pose picker wraps so every chip can be reached with a mouse.
* Integration tests that drive the real app through every pose, RTL, Split View, tabletop media and live window resizing.
* Golden tests for every `DuoPose`, RTL and tabletop media.
* Bilingual README (English and Arabic on one page, with a navigator between them), `DESIGN.ar.md`, a design decisions page, six new scenario animations rendered from the real app, a 40-line minimal example, and an Arabic version of the showcase in RTL.

## 1.0.0

* First stable release.
* `context.duo` / `DuoData`: exact iPhone Duo modes (closed, sideways, open, upright, Split View), Android fold and hinge posture, tablet and desktop modes, per-side safe areas, margins and fold-aware grid columns.
* Layout: `DuoLayout` + `DuoKeep`, `DuoSplit`, `DuoListDetail`, `DuoAvoidFold`.
* `DuoNavigationScaffold`: bottom bar or side rail, placed next to the Dynamic Island on the Duo.
* `DuoMedia`: smart media fit for the √2 inner screen.
* `DuoSimulator`, `DuoPose` and `DuoDebugOverlay` for previews and widget tests.
* Full RTL and LTR support: mirrored panes that stay on the fold, `textDirection` overrides and `DuoRailSide` for the navigation rail.
