# duo_dynamic_sizing

Flutter package: adaptive layout for Apple's foldable iPhone Duo and every other screen, with live hinge data from small native parts (Swift on iOS, Java on Android). Web and desktop stay pure Dart. Published as `duo_dynamic_sizing`, repo https://github.com/Abojawdat/iPhone-Duo-package-.

## Working with the maintainer

- **Before any big task,** ask a round of clarifying questions with a recommended option. They like to be asked.
- **Commits:** authored by them only, with no `Co-Authored-By` or AI trailers. Push straight to `main` unless they ask for pull requests.
- **Irreversible actions** (publishing, deleting, force-pushing, re-tagging) need their explicit OK.
- **Docs change in both languages** (English + Arabic) in the same commit.

## Commands

```sh
flutter pub get
flutter analyze                 # must be clean
flutter test                    # test/duo_data_test.dart (logic), test/widgets_test.dart (poses)
dart format lib test example    # 80 cols
cd example && flutter run       # the 3D showcase, also the live demo
flutter test --update-goldens test/golden_test.dart   # goldens, macOS only (skipped elsewhere)
cd example && flutter test integration_test -d macos  # real app, every pose. keep its window visible: macOS throttles hidden windows and the run crawls
cd example && flutter drive -d macos --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart  # same + screenshots in example/build/screens
cd example && flutter test integration_test/hardware_test.dart -d <device>   # the live native side on macOS, an iOS simulator or an Android emulator
cd example && flutter test integration_test/fold_sweep_test.dart -d emulator-5554  # watches a live fold for 30 s; skips without a hinge
```

Run integration files one at a time on macOS (launching the next app while the last one quits fails with "Unable to start the app"). The Pixel 9 Pro Fold emulator moves its hinge with `adb -s emulator-5554 emu sensor set hinge-angle0 <degrees>`. Folding it shut puts it to sleep and reopening doesn't wake it, so the next run can't reach the app: wake it with `adb -s emulator-5554 shell input keyevent KEYCODE_WAKEUP` and `adb -s emulator-5554 shell wm dismiss-keyguard`. The iOS hinge APIs need Xcode 27.1 and the Duo simulator; on iOS 26 simulators the plugin runs and reports only size classes.

Regenerate every image and animation in `doc/` (real renders of the example app; Arabic uses macOS's SF Arabic):

```sh
cd example && flutter test tool/render.dart && python3 ../tool/pack_visuals.py   # needs Pillow
```

Outputs: stills in `doc/*.webp`, `doc/fold.webp` and `doc/hinge.webp` (also pub.dev screenshots), and scenario animations in `doc/anim/*.webp` (kept out of the pub archive by `.pubignore`).

`doc/glass.webp` is built from real iOS screenshots, because `UIGlassEffect` can't render in a test. Retake them on the iPad Pro 13-inch simulator, which fits each Duo screen at 1:1: `cd example && flutter build ios --simulator --debug -t tool/glass_demo.dart`, install and launch it with `xcrun simctl`, screenshot the rail (`xcrun simctl io <id> screenshot rail.png`), then after 15 s the floating bar (`bar.png`), run `python3 ../tool/crop_glass.py rail.png bar.png`, then `flutter test tool/render.dart --plain-name "glass gallery"` and pack. Every render passes `glass: true` to `DuoApp`. `doc/banner.svg` (animated, SMIL) and `doc/logo.svg` are hand-written SVGs. The logo is the app icon: `cd example && python3 tool/make_icon.py` regenerates every platform's icon from the same geometry.

## Example and live demo

- `example/lib/showcase.dart` is what `flutter run` and the live demo open: a foldable drawn in 3D that folds by hand. `example/lib/fold_view.dart` is its 3D body. `.github/workflows/demo.yml` builds it for the web and puts it on GitHub Pages on every push to `main`: https://abojawdat.github.io/iPhone-Duo-package-/
- **One live app, never two.** `DuoApp` is built once under a GlobalKey, pictured every frame by a `SnapshotWidget` and painted onto both halves by `Fold3D`. Building it once per half would look the same and lose state on every fold.
- **Touches go through the same bend.** `RenderFold.hitTest` uses the matrices `Fold3D` painted with. Change one and the other has to follow.
- **Below 28° the cover screen is the lit one,** and the app is laid out for the closed pose. Above it the inner screen is, bent to the hinge angle.
- `Playground` and `DuoApp` stay in `example/lib/main.dart`: `tool/render.dart`, `tool/glass_demo.dart` and the integration tests import them.
- The package depends on `flutter_web_plugins` because it declares a web plugin. Without it no web app using the package compiles.
- The demo app's `AppBar` is clear whenever the aurora background is on, so the color reaches the top of the screen. Render the docs again after touching it.

## Docs (English + Arabic, keep them in sync)

- `README.md` (also the pub.dev page) is bilingual: the navigator buttons (`doc/nav/*.svg`) at the top jump to `#english` and `#arabic`. The Arabic section is a shorter mirror of the English one (reference tables stay English-only), because pub.dev drops 5 points when over 20% of the README's non-space characters are non-ASCII. It's at about 16.6% since 2.0.0; check with `pana .` (needs `brew install webp`) before adding Arabic text; its prose sits in `<div dir="rtl">` blocks, and code blocks go outside them so they stay LTR. Images use absolute `raw.githubusercontent.com/.../main/...` URLs.
- `DESIGN.md` / `DESIGN.ar.md`: every design decision, its reason and the rejected alternative.
- `example/lib/minimal.dart` is the README's minimal example; keep both copies identical.
- Any behavior change updates both languages in the same commit. Keep the logo geometry in sync with `_LogoPainter` in `example/tool/render.dart`.

## Layout

- `lib/src/duo_data.dart`: `DuoData` (`context.duo`), `DuoMode`, `DuoPosture`, `DuoScope`, `DuoBuilder`, and the Duo size table (`_duoMode`).
- `lib/src/layout.dart`: `DuoLayout` + `DuoKeep`, `DuoSplit` + `splitPanes`, `DuoListDetail`, `DuoAvoidFold`.
- `lib/src/navigation.dart`: `DuoNavigationScaffold` (bar or rail, rail by the island on the Duo).
- `lib/src/media.dart`: `DuoMedia` (smart fit).
- `lib/src/tools.dart`: `DuoPose`, `DuoSimulator`, `DuoDebugOverlay`.
- `lib/src/hardware.dart`: `DuoHardware` (hinge data, parsing, streams, `describeNative`), `DuoHardwareScope` (an `InheritedModel` with layout and angle aspects, plus the `displayFeatures` bridge), and the Dart-only plugin class for web and desktop.
- `lib/src/glass.dart`: `DuoGlass` (a `UiKitView` of `UIGlassEffect` on iOS, a blur elsewhere).
- `lib/src/window.dart`: internal, not exported. Lets `DuoSplit` measure against the simulated window.
- `ios/duo_dynamic_sizing/Sources/duo_dynamic_sizing/`: `DuoDynamicSizingPlugin.swift` (probe view, hinge interaction, reserved regions, size classes, bar edge) and `DuoGlass.swift`. Built by both SwiftPM (`Package.swift`) and CocoaPods (`ios/duo_dynamic_sizing.podspec`).
- `android/src/main/java/.../DuoDynamicSizingPlugin.java`: the hinge angle sensor.

## Rules

- **Native code only for hinge data.** On iOS, never name an iOS 27 type in Swift: look it up at runtime (`NSClassFromString`, `responds(to:)` before every KVC read), so any Xcode builds the package and a missing API turns the feature off instead of crashing. Android stays Java (AGP 8 and 9 set up Kotlin differently). Keep web, macOS, Windows and Linux declared as Dart-only plugin platforms (`dartPluginClass` / `fileName` to `src/hardware.dart`), or pub.dev drops them.
- **Everything derives from `MediaQuery` and `DuoHardwareScope`,** so widgets reading `context.duo` rebuild on fold, rotation, split and posture, and on nothing else. Layout readers use the layout aspect; only `DuoHardware.angleOf` rebuilds on every angle tick. Don't read `View` or `Display`.
- **Never scale sizes.** Both Duo screens share point density (about 153 pt/in); layouts gain panes, not bigger widgets.
- **Layout goes off `isExpanded` (600 × 480), not `mode`.** `mode` describes the device.
- **State continuity comes from GlobalKey reparenting** (`DuoKeep`, `DuoSplit` panes, `DuoListDetail`, the scaffold body key, the stable Stack in `DuoSimulator`). Any change to tree shape between poses needs a key, or state resets on fold. Tests cover this.
- **Direction:** panes and `DuoAvoidFold` follow the ambient `Directionality`; `textDirection` overrides it on `DuoSplit` and `DuoListDetail`. In RTL, `splitPanes` swaps which pane sits where but keeps the split on the physical fold. The rail uses `DuoRailSide`, where `auto` means the side iOS reports for its vertical bar, else the physical right on the Duo, and the start side elsewhere.
- **Duo detection means exact sizes on iOS at 3x,** with ±1 pt tolerance, partial windows for older SDKs, and Split View slices, or a hinge reported on iOS by `DuoHardwareScope`. Keep iPads (2x), Android and web from matching; an Android hinge sensor never makes a Duo.
- **Posture, not `isActive`, decides whether the iOS fold separates.** The region's `isActive` lags the hinge by up to a second. Half open, the fold is the 40 pt region; flat, a zero-width line at its centre; closed, none. Zero-width regions never split.
- **The `displayFeatures` bridge stays off by default.** Publishing a half-open fold makes every Flutter dialog and sheet half width. Our own widgets read the hinge fold directly (`DuoSplit`, `DuoAvoidFold`). The scope stands down if flutter/flutter#192515 lands and the engine reports features itself.
- **The simulator never shows the real hinge.** `DuoSimulator` always wraps its window in `DuoHardwareScope(hardware: pose.hardware ?? DuoHardware.none)`.
- **In widget tests, never `await` a platform-channel cancel.** Fake async time never delivers the reply and the test hangs; use `unawaited(sub.cancel())` and pump.
- **The glass rail's background extension slides, it doesn't mirror.** A backdrop `ImageFilter.matrix` with a negative scale renders nothing on Impeller (iOS and Android), inside real apps and under transforms, though a bare probe can seem to work. Keep the shift, keep the content painting before the rail (the row flips its `textDirection` instead of its children), and check it on the iOS simulator, not just macOS.
- **Rail sizing:** keep `IntrinsicWidth` inside the 30% width cap. A bounded `NavigationRail` stretches to fill its width, which silently took 60 pt from the content before the goldens caught it.
- **Edge cases live in `test/edge_cases_test.dart`:** zero and tiny windows, bad input, unbounded layouts, tri-folds, rapid folding, 3x text, keyboard rebuilds. Add a case there for every bug fix.
- **The Flutter floor is 3.41 (Dart 3.11).** The local SDK is newer, so don't use APIs added after 3.41.

## iPhone Duo facts

- Outer: 1398×2034 px, 460 ppi, which is 466×678 pt @3x.
- Inner: 1878×2670 px, 430 ppi, drawn at 2007×2853 = 669×951 pt @3x.
- Open pose is 951×669 with the fold at x = 475.5. Split View is 50/50.
- iOS 27.1 reports the fold (`divisionRegionKind`) as a 40 pt region, x 455.5 to 495.5, still present but inactive while flat; the inner camera (`occlusionRegionKind`) is active only while in use. Region frames include their margins.
- `UIHingeStatus` is unknown 0, closed 1, partiallyOpen 2, fullyOpen 3. `UIHinge.angle` is radians, 0 shut and π flat. `UIVerticalBarEdge` is unspecified 0, leading 1, trailing 2; the Swift side converts it to the physical side.
- The vertical Dynamic Island is on the right. `DuoPose` insets (59 / 21) are estimates.

## Style

- Comments are minimal, short and plain: no `[bracket]` dartdoc refs.
- Keep one short doc line per public type (pub.dev docs score).
- Commits are authored by the maintainer, with no AI or co-author trailers.

## Release (GitHub Actions publishes to pub.dev)

1. Bump `version` in `pubspec.yaml`, add a `CHANGELOG.md` entry, push to `main` and wait for CI to go green.
2. `git tag vX.Y.Z && git push origin vX.Y.Z`. `publish.yml` checks the tag matches the pubspec, runs the tests, then publishes over OIDC (no secrets). It waits for approval in the `pub.dev` environment, and skips if the version already exists.
3. Automated publishing is set up on pub.dev (repo `Abojawdat/iPhone-Duo-package-`, tag pattern `v{{version}}`, environment `pub.dev`). Each tag run waits for the maintainer's approval in GitHub → Actions → Review deployments.
4. README images are absolute `raw.githubusercontent.com/.../main/doc/...` URLs, so they also render on pub.dev.

**Checking CI without the `gh` CLI:** `curl -s "https://api.github.com/repos/Abojawdat/iPhone-Duo-package-/actions/runs?per_page=5"`. For failures, use each job's `check_run_url` + `/annotations`; job logs need admin rights, which is why `ci.yml` prints `pub publish --dry-run` output and `git diff` as error annotations.
