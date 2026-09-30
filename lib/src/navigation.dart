import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'duo_data.dart';
import 'glass.dart';
import 'hardware.dart';

/// Where DuoNavigationScaffold puts its rail. auto = the system's vertical bar
/// edge when iOS reports it, else by the island on the Duo (any language) and
/// the start side elsewhere.
enum DuoRailSide { auto, start, end, left, right }

/// Nav item for DuoNavigationScaffold.
class DuoDestination {
  const DuoDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
}

/// Bottom bar or side rail per prefersRail. On the Duo the rail sits right by
/// the island and the FAB moves into it. glass puts the rail on DuoGlass, and
/// background runs under the body and the rail so the glass shows it.
class DuoNavigationScaffold extends StatefulWidget {
  const DuoNavigationScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.railSide = DuoRailSide.auto,
    this.glass = false,
    this.background,
  }) : assert(
         destinations.length >= 2,
         'Navigation needs at least two destinations.',
       );

  final List<DuoDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final DuoRailSide railSide;
  final bool glass;
  final Widget? background;

  @override
  State<DuoNavigationScaffold> createState() => _DuoNavigationScaffoldState();
}

class _DuoNavigationScaffoldState extends State<DuoNavigationScaffold> {
  // same body element thru bar/rail swaps so page state survives a fold
  final _body = GlobalKey();

  // same tree with or without a background, so toggling it keeps state
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(child: widget.background ?? const SizedBox.shrink()),
      _scaffold(context, widget.background == null ? null : Colors.transparent),
    ],
  );

  Widget _scaffold(BuildContext context, Color? fill) {
    final duo = context.duo;
    final body = KeyedSubtree(key: _body, child: widget.body);
    if (!duo.prefersRail) {
      return Scaffold(
        backgroundColor: fill,
        appBar: widget.appBar,
        body: body,
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onDestinationSelected,
          destinations: [
            for (final d in widget.destinations)
              NavigationDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: d.label,
              ),
          ],
        ),
      );
    }

    final right = _railOnRight(duo);
    // rail only pads its leading edge so we pad the real side ourself
    // long labels or huge text can't push the body off screen
    final Widget capped = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: math.max(80, duo.size.width * .3)),
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        removeRight: true,
        // natural width (80) unless labels are huge, then the cap.
        // same 1.3 label cap NavigationBar uses
        child: IntrinsicWidth(
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: NavigationRail(
              backgroundColor: widget.glass ? Colors.transparent : null,
              scrollable: true,
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              leading: widget.floatingActionButton,
              destinations: [
                for (final d in widget.destinations)
                  NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(
                      d.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    final strip = SafeArea(
      left: !right,
      right: right,
      top: false,
      bottom: false,
      child: widget.glass
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: DuoGlass(borderRadius: 28, child: capped),
            )
          : capped,
    );
    // under glass the content beside the rail runs on under it, blurred,
    // like Apple's background extension, so the glass shows real color
    final rail = widget.glass
        ? Stack(
            children: [
              Positioned.fill(child: _Extension(contentOnLeft: right)),
              strip,
            ],
          )
        : strip;
    final content = MediaQuery.removePadding(
      context: context,
      removeLeft: !right,
      removeRight: right,
      child: body,
    );
    return Scaffold(
      backgroundColor: fill,
      appBar: widget.appBar,
      // content always paints first so the extension can mirror it; the
      // direction only picks the physical side
      body: Row(
        textDirection: right ? TextDirection.ltr : TextDirection.rtl,
        children: [
          Expanded(child: content),
          rail,
        ],
      ),
    );
  }

  bool _railOnRight(DuoData duo) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return switch (widget.railSide) {
      DuoRailSide.left => false,
      DuoRailSide.right => true,
      DuoRailSide.start => rtl,
      DuoRailSide.end => !rtl,
      DuoRailSide.auto when duo.hardware.barEdge != DuoBarEdge.none =>
        duo.hardware.barEdge == DuoBarEdge.right,
      // island is on the right so only the right split app has a right inset
      DuoRailSide.auto when duo.isIphoneDuo =>
        !duo.isSplit || duo.padding.right > duo.padding.left,
      DuoRailSide.auto => rtl,
    };
  }
}

// repaints the content beside it, blurred, inside its own bounds
class _Extension extends LeafRenderObjectWidget {
  const _Extension({required this.contentOnLeft});

  final bool contentOnLeft;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderExtension(contentOnLeft);

  @override
  void updateRenderObject(BuildContext context, _RenderExtension render) =>
      render.contentOnLeft = contentOnLeft;
}

class _RenderExtension extends RenderBox {
  _RenderExtension(this._contentOnLeft);

  bool _contentOnLeft;
  set contentOnLeft(bool value) {
    if (value == _contentOnLeft) return;
    _contentOnLeft = value;
    markNeedsPaint();
  }

  final _clip = LayerHandle<ClipRectLayer>();
  final _extend = LayerHandle<BackdropFilterLayer>();

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // slide the neighbouring strip's width of content over. Apple mirrors
    // it instead, but a flipped backdrop renders nothing on Impeller
    final shift = Float64List.fromList([
      1, 0, 0, 0, //
      0, 1, 0, 0, //
      0, 0, 1, 0, //
      _contentOnLeft ? size.width : -size.width, 0, 0, 1,
    ]);
    _extend.layer ??= BackdropFilterLayer();
    _extend.layer!.filter = ui.ImageFilter.compose(
      outer: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      inner: ui.ImageFilter.matrix(shift),
    );
    _clip.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      (context, offset) =>
          context.pushLayer(_extend.layer!, (context, offset) {}, offset),
      oldLayer: _clip.layer,
    );
  }

  @override
  void dispose() {
    _clip.layer = null;
    _extend.layer = null;
    super.dispose();
  }
}
