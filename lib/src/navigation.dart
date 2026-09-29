import 'dart:math' as math;

import 'package:flutter/material.dart';

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
/// the island and the FAB moves into it. glass puts the rail on DuoGlass.
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

  @override
  State<DuoNavigationScaffold> createState() => _DuoNavigationScaffoldState();
}

class _DuoNavigationScaffoldState extends State<DuoNavigationScaffold> {
  // same body element thru bar/rail swaps so page state survives a fold
  final _body = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    final body = KeyedSubtree(key: _body, child: widget.body);
    if (!duo.prefersRail) {
      return Scaffold(
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
    final rail = SafeArea(
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
    final content = MediaQuery.removePadding(
      context: context,
      removeLeft: !right,
      removeRight: right,
      child: body,
    );
    return Scaffold(
      appBar: widget.appBar,
      body: Row(
        textDirection: TextDirection.ltr, // physical order
        children: right
            ? [Expanded(child: content), rail]
            : [rail, Expanded(child: content)],
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
