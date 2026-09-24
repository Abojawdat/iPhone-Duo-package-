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
