# duo_dynamic_sizing showcase

A foldable drawn in 3D that you bend with your hand, with a real app running
inside it: a music player, a photo gallery and a live readout of what the
package sees. Try it in the browser at
https://abojawdat.github.io/iPhone-Duo-package-/ or run it on any phone,
emulator or desktop, no iPhone Duo needed.

```sh
dart pub unpack duo_dynamic_sizing
cd duo_dynamic_sizing-*/example
flutter run
```

- **The handle** on the edge of the phone, the **Hinge** slider, or a drag on
  the empty space around it folds the phone: flat, half open, then shut on its
  cover screen. Let go near either end and it finishes the move.
- **Closed / Book / Open** jump to a posture. **Turn it** rotates the phone,
  which turns the book posture into tabletop.
- **Split View**, on the open Duo, shares the screen with another app. Tap it
  again for the other side.
- **iPhone Duo / Android fold / iPhone / iPad** swaps the device.
- **Guides** paints what the system covers in red (the Duo's Dynamic Island
  strip and home bar) and the fold in blue, a band while the Duo is half open.
- **This device** drops the pretend phone and runs the app on your actual
  screen (a Pixel Fold emulator reports a real hinge and its angle).
- **Play all** goes through every posture by itself. The **Every pose** tab
  lists them, and **Use it** has the install line and a starter.

The app inside is live and takes touches even while the phone is bent.

Things to try:

1. Play a track while closed, then unfold. It keeps playing from the same
   second, with the list next to it.
2. In **Lab**, bump the counter and type a note, then fold and turn the phone.
   Both stay.
3. Turn it, half fold it and open a photo: photo on top, details below the
   fold.
4. Split View left, then right: the rail moves to the island side.
5. Drag the hinge down from flat. Below about 176° the Duo is half open:
   **Lab** says `book`, the 40 pt fold appears and the panes move off it. Then
   pick **This device** on a foldable and bend it for real; **Native API**
   shows what the OS exposes.

`flutter run -t lib/minimal.dart` runs the 40-line app from the README.
