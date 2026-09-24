# duo_dynamic_sizing

Pure-Dart Flutter package: adaptive layout for Apple's foldable iPhone Duo and every other screen. Published as `duo_dynamic_sizing`, repo https://github.com/Abojawdat/iPhone-Duo-package-.

## Handoff: what to do next (written 2026-09-24)

**Where things stand:**
- **Version:** 1.0.1 is on `main` and is **not on pub.dev yet**.
- **CI:** `.github/workflows/ci.yml` is green on Flutter 3.41.9 and the latest stable.
- **Tests:** 97 package tests pass locally, plus 9 integration tests on macOS.
- **Docs:** the README is bilingual (English + Arabic, with a navigator between them).
- **Publishing:** `.github/workflows/publish.yml` publishes to pub.dev when a `vX.Y.Z` tag is pushed.

**Next, in this order.** When a new chat starts, show the maintainer this list and ask which steps are done.

1. **[maintainer] First publish, by hand.** pub.dev can only automate packages that already exist. In this folder run `flutter pub publish`, check the file list, type `y`, and sign in with Google. Verify that https://pub.dev/packages/duo_dynamic_sizing shows 1.0.1. Never publish on their behalf: it's irreversible and needs their Google account.
2. **[maintainer] Turn on automation on pub.dev.** Go to https://pub.dev/packages/duo_dynamic_sizing/admin → Automated publishing and set:
   - enable publishing from GitHub Actions
   - repository `Abojawdat/iPhone-Duo-package-`
   - tag pattern `v{{version}}`
   - tick "Require GitHub Actions environment" and set it to `pub.dev`
3. **[maintainer] Require their approval for releases.** GitHub → Settings → Environments → `pub.dev` (create it if missing) → Required reviewers → add themselves. Optionally add a tag ruleset for `v*` limited to admins.
4. **[Claude] Once 1–3 are confirmed:**
   - Make sure `main` still has `version: 1.0.1` and nothing unreleased.
   - Run `git tag v1.0.1 && git push origin v1.0.1`.
   - Watch the "Publish to pub.dev" run. It should find 1.0.1 already on pub.dev, skip publishing, and finish green. If reviewers are set, the maintainer has to approve the run first.
5. **[Claude] After it's verified,** delete this Handoff section and commit.

**Checking CI without the `gh` CLI (it isn't installed):**
- **Runs:** `curl -s "https://api.github.com/repos/Abojawdat/iPhone-Duo-package-/actions/runs?per_page=5"`
- **Failure details:** use each job's `check_run_url` + `/annotations`. Job logs need admin rights, which is why `ci.yml` prints `pub publish --dry-run` output and `git diff` as error annotations.

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
3. The very first version has to be published by hand with `flutter pub publish` (see Handoff). pub.dev can't create a package from CI.
4. README images are absolute `raw.githubusercontent.com/.../main/doc/...` URLs, so they also render on pub.dev.
