# duo_dynamic_sizing

Pure-Dart Flutter package: adaptive layout for Apple's foldable iPhone Duo and every other screen. Published as `duo_dynamic_sizing`, repo https://github.com/Abojawdat/iPhone-Duo-package-.

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
cd example && flutter run       # showcase with a pose picker
flutter test --update-goldens test/golden_test.dart   # goldens, macOS only (skipped elsewhere)
cd example && flutter test integration_test -d macos  # real app, every pose. keep its window visible: macOS throttles hidden windows and the run crawls
cd example && flutter drive -d macos --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart  # same + screenshots in example/build/screens
```

Regenerate every image and animation in `doc/` (real renders of the example app; Arabic uses macOS's SF Arabic):

```sh
cd example && flutter test tool/render.dart && python3 ../tool/pack_visuals.py   # needs Pillow
```

Outputs: stills in `doc/*.webp`, `doc/fold.webp` (also a pub.dev screenshot), and scenario animations in `doc/anim/*.webp` (kept out of the pub archive by `.pubignore`). `doc/banner.svg` (animated, SMIL) and `doc/logo.svg` are hand-written SVGs.

## Docs (English + Arabic, keep them in sync)

- `README.md` (also the pub.dev page) is bilingual: the navigator buttons (`doc/nav/*.svg`) jump to `#english` and `#arabic`. The Arabic section mirrors the English one; its prose sits in `<div dir="rtl">` blocks, and code blocks go outside them so they stay LTR. Images use absolute `raw.githubusercontent.com/.../main/...` URLs.
- `DESIGN.md` / `DESIGN.ar.md`: every design decision, its reason and the rejected alternative.
- `example/lib/minimal.dart` is the README's minimal example; keep both copies identical.
- Any behavior change updates both languages in the same commit. Keep the logo geometry in sync with `_LogoPainter` in `example/tool/render.dart`.

## Layout

- `lib/src/duo_data.dart`: `DuoData` (`context.duo`), `DuoMode`, `DuoPosture`, `DuoScope`, `DuoBuilder`, and the Duo size table (`_duoMode`).
- `lib/src/layout.dart`: `DuoLayout` + `DuoKeep`, `DuoSplit` + `splitPanes`, `DuoListDetail`, `DuoAvoidFold`.
- `lib/src/navigation.dart`: `DuoNavigationScaffold` (bar or rail, rail by the island on the Duo).
- `lib/src/media.dart`: `DuoMedia` (smart fit).
- `lib/src/tools.dart`: `DuoPose`, `DuoSimulator`, `DuoDebugOverlay`.
- `lib/src/window.dart`: internal, not exported. Lets `DuoSplit` measure against the simulated window.

## Rules

- **Pure Dart only.** No platform channels or native code; that's the package's reason to exist (`foldable` and `nitro_fold_duo` cover native hinge data).
- **Everything derives from `MediaQuery`,** so widgets reading `context.duo` rebuild on fold, rotation and split, and on nothing else. Don't read `View` or `Display`.
- **Never scale sizes.** Both Duo screens share point density (about 153 pt/in); layouts gain panes, not bigger widgets.
- **Layout goes off `isExpanded` (600 × 480), not `mode`.** `mode` describes the device.
- **State continuity comes from GlobalKey reparenting** (`DuoKeep`, `DuoSplit` panes, `DuoListDetail`, the scaffold body key, the stable Stack in `DuoSimulator`). Any change to tree shape between poses needs a key, or state resets on fold. Tests cover this.
- **Direction:** panes and `DuoAvoidFold` follow the ambient `Directionality`; `textDirection` overrides it on `DuoSplit` and `DuoListDetail`. In RTL, `splitPanes` swaps which pane sits where but keeps the split on the physical fold. The rail uses `DuoRailSide`, where `auto` means the physical right on the Duo and the start side elsewhere.
- **Duo detection means exact sizes on iOS at 3x only,** with ±1 pt tolerance, partial windows for older SDKs, and Split View slices. Keep iPads (2x), Android and web from matching.
- **iOS gives no hinge or posture.** It's `unknown` until flutter/flutter#192515 lands; then `displayFeatures` carries it and the Android path handles it with no changes here.
- **Rail sizing:** keep `IntrinsicWidth` inside the 30% width cap. A bounded `NavigationRail` stretches to fill its width, which silently took 60 pt from the content before the goldens caught it.
- **Edge cases live in `test/edge_cases_test.dart`:** zero and tiny windows, bad input, unbounded layouts, tri-folds, rapid folding, 3x text, keyboard rebuilds. Add a case there for every bug fix.
- **The Flutter floor is 3.41 (Dart 3.11).** The local SDK is newer, so don't use APIs added after 3.41.

## iPhone Duo facts

- Outer: 1398×2034 px, 460 ppi, which is 466×678 pt @3x.
- Inner: 1878×2670 px, 430 ppi, drawn at 2007×2853 = 669×951 pt @3x.
- Open pose is 951×669 with the fold at x = 475.5. Split View is 50/50.
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
