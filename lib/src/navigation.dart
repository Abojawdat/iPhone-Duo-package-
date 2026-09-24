import 'package:flutter/material.dart';

import 'duo_data.dart';

/// Where DuoNavigationScaffold puts its rail. auto = iOS 27 style on the Duo
/// (by the island, any language) and the start side elsewhere.
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
/// the island and the FAB moves into it.
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
    final rail = SafeArea(
      left: !right,
      right: right,
      top: false,
      bottom: false,
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        removeRight: true,
        child: NavigationRail(
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          leading: widget.floatingActionButton,
          destinations: [
            for (final d in widget.destinations)
              NavigationRailDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: Text(d.label),
              ),
          ],
        ),
      ),
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
      // island is on the right so only the right split app has a right inset
      DuoRailSide.auto when duo.isIphoneDuo =>
        !duo.isSplit || duo.padding.right > duo.padding.left,
      DuoRailSide.auto => rtl,
    };
  }
}
