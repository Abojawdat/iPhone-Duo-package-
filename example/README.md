# duo_dynamic_sizing playground

A small app to see and test the package: a music player, a photo gallery and a
live readout of what the package sees. It runs on any phone, emulator or
desktop, no iPhone Duo needed.

```sh
dart pub unpack duo_dynamic_sizing
cd duo_dynamic_sizing-*/example
flutter run
```

A help sheet opens on start and explains everything. In short:

- **Pose chips** under the phone switch the screen: iPhone Duo closed, open,
  half open, Split View, Android foldables, iPhone, iPad, or **real device**
  for your actual screen (a Pixel Fold emulator reports a real hinge and its
  angle).
- **Tour** folds and unfolds by itself every few seconds.
- **Red** areas are what the system covers (the Duo's Dynamic Island strip and
  home bar). The **blue** line is the fold, and a blue band is the 40 pt fold
  iOS reports while the Duo is half open.
- The other buttons: help, guides, debug overlay, Arabic (right to left), 2x
  text, dark mode.

Things to try:

1. Play a track while closed, then unfold. It keeps playing from the same
   second, with the list next to it.
2. In **Lab**, bump the counter and type a note, then switch poses. Both stay.
3. On **foldableTabletop**, open a photo: photo on top, details below the fold.
4. Compare **splitLeft** and **splitRight**: the rail moves to the island side.
5. On **halfOpenBook**, the list and player move off the 40 pt fold. Then pick
   **real device** on a foldable and bend it: **Lab** shows the posture and the
   live angle, and **Native API** shows what the OS exposes.

`flutter run -t lib/minimal.dart` runs the 40-line app from the README.
