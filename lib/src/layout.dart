import 'package:flutter/widgets.dart';

import 'duo_data.dart';
import 'window.dart';

/// closed for one pane, open when two fit. Wrap shared parts in DuoKeep.
class DuoLayout extends StatefulWidget {
  const DuoLayout({super.key, required this.closed, required this.open});

  final WidgetBuilder closed;
  final WidgetBuilder open;

  @override
  State<DuoLayout> createState() => _DuoLayoutState();
}

class _DuoLayoutState extends State<DuoLayout> {
  final _keys = <Object, GlobalKey>{};

  @override
  Widget build(BuildContext context) => _DuoKeys(
    keys: _keys,
    child: Builder(
      builder: context.duo.isExpanded ? widget.open : widget.closed,
    ),
  );
}

class _DuoKeys extends InheritedWidget {
  const _DuoKeys({required this.keys, required super.child});

  final Map<Object, GlobalKey> keys;

  @override
  bool updateShouldNotify(_DuoKeys oldWidget) => false;
}

/// Keeps state across a DuoLayout switch, same id in both builders.
class DuoKeep extends StatelessWidget {
  const DuoKeep({super.key, required this.id, required this.child});

  final Object id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keys = context.getInheritedWidgetOfExactType<_DuoKeys>()?.keys;
    assert(keys != null, 'DuoKeep must be inside a DuoLayout.');
    if (keys == null) return child;
    return KeyedSubtree(key: keys.putIfAbsent(id, GlobalKey.new), child: child);
  }
}

/// Two panes when theres room, one when not. Follows the fold like Apple's
/// split ArrangementView, axis and ratio null means at the fold. Side by side
/// panes follow the app text direction (primary on the right in rtl).
class DuoSplit extends StatefulWidget {
  const DuoSplit({
    super.key,
    required this.primary,
    required this.secondary,
    this.single,
    this.axis,
    this.ratio,
    this.textDirection,
  });

  final Widget primary;
  final Widget secondary;

  final Widget? single;

  final Axis? axis;

  final double? ratio;

  final TextDirection? textDirection;

  @override
  State<DuoSplit> createState() => _DuoSplitState();
}

class _DuoSplitState extends State<DuoSplit> {
  final _primary = GlobalKey();
  final _secondary = GlobalKey();

  // measured post frame, 1 frame lag on moves
  Offset _origin = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    final direction =
        widget.textDirection ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    return LayoutBuilder(
      builder: (context, constraints) {
        final panes = splitPanes(
          duo,
          constraints.biggest,
          _origin,
          axis: widget.axis,
          ratio: widget.ratio,
          textDirection: direction,
        );
        final primary = KeyedSubtree(key: _primary, child: widget.primary);
        if (panes == null) return widget.single ?? primary;
        return Stack(
          children: [
            Positioned.fromRect(rect: panes.$1, child: primary),
            Positioned.fromRect(
              rect: panes.$2,
              child: KeyedSubtree(key: _secondary, child: widget.secondary),
            ),
          ],
        );
      },
    );
  }

  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final origin = DuoWindow.originOf(context, box);
    if (origin != _origin) setState(() => _origin = origin);
  }
}

/// Pane rects for DuoSplit, null means one pane.
(Rect, Rect)? splitPanes(
  DuoData duo,
  Size size,
  Offset origin, {
  Axis? axis,
  double? ratio,
  TextDirection textDirection = TextDirection.ltr,
}) {
  // unbounded (scroll view, Column) = no room to split, show one pane
  if (!size.isFinite) return null;
  final box = Offset.zero & size;
  final fold = duo.fold?.shift(-origin);
  final crossesFold = fold != null && fold.overlaps(box);
  final rtl = textDirection == TextDirection.rtl;
  // rtl keeps the split on the fold, only swaps wich pane sits where
  (Rect, Rect) sides(Rect left, Rect right) =>
      rtl ? (right, left) : (left, right);

  if (crossesFold && duo.isSeparating) {
    return duo.foldDirection == Axis.vertical
        ? sides(
            Rect.fromLTRB(0, 0, fold.left.clamp(0, size.width), size.height),
            Rect.fromLTRB(
              fold.right.clamp(0, size.width),
              0,
              size.width,
              size.height,
            ),
          )
        : (
            Rect.fromLTRB(0, 0, size.width, fold.top.clamp(0, size.height)),
            Rect.fromLTRB(
              0,
              fold.bottom.clamp(0, size.height),
              size.width,
              size.height,
            ),
          );
  }

  if (size.width < duo.expandedWidth || size.height < duo.expandedHeight) {
    return null;
  }

  final foldAxis = crossesFold
      ? (duo.foldDirection == Axis.vertical ? Axis.horizontal : Axis.vertical)
      : null;
  final dir =
      axis ??
      foldAxis ??
      (size.width >= size.height ? Axis.horizontal : Axis.vertical);
  final length = dir == Axis.horizontal ? size.width : size.height;
  final double at;
  if (ratio != null) {
    at = length * (rtl && dir == Axis.horizontal ? 1 - ratio : ratio);
  } else if (dir == foldAxis) {
    at = dir == Axis.horizontal ? fold!.center.dx : fold!.center.dy;
  } else {
    at = length / 2;
  }

  return dir == Axis.horizontal
      ? sides(
          Rect.fromLTWH(0, 0, at, size.height),
          Rect.fromLTWH(at, 0, size.width - at, size.height),
        )
      : (
          Rect.fromLTWH(0, 0, size.width, at),
          Rect.fromLTWH(0, at, size.width, size.height - at),
        );
}

/// List and detail. One pane shows the detail once selected, system back
/// calls onClose.
class DuoListDetail<T> extends StatefulWidget {
  const DuoListDetail({
    super.key,
    required this.selected,
    required this.list,
    required this.detail,
    required this.onClose,
    this.empty,
    this.axis = Axis.horizontal,
    this.textDirection,
  });

  final T? selected;
  final WidgetBuilder list;
  final Widget Function(BuildContext context, T item) detail;

  final VoidCallback onClose;

  final WidgetBuilder? empty;

  final Axis? axis;

  final TextDirection? textDirection;

  @override
  State<DuoListDetail<T>> createState() => _DuoListDetailState<T>();
}

class _DuoListDetailState<T> extends State<DuoListDetail<T>> {
  final _list = GlobalKey();
  final _detail = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final item = widget.selected;
    final list = KeyedSubtree(
      key: _list,
      child: Builder(builder: widget.list),
    );
    final detail = KeyedSubtree(
      key: _detail,
      child: item == null
          ? Builder(builder: widget.empty ?? (_) => const SizedBox.shrink())
          : Builder(builder: (context) => widget.detail(context, item)),
    );
    return DuoSplit(
      axis: widget.axis,
      textDirection: widget.textDirection,
      primary: list,
      secondary: detail,
      single: PopScope(
        canPop: item == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) widget.onClose();
        },
        // keeps the list alive and scrolled behind the detail
        child: IndexedStack(
          index: item == null ? 0 : 1,
          children: [list, detail],
        ),
      ),
    );
  }
}

/// Keeps child off a seperating fold, trailing half for book and bottom half
/// for tabletop.
class DuoAvoidFold extends StatelessWidget {
  const DuoAvoidFold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    final s = duo.size;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final anchor = duo.foldDirection == Axis.horizontal
        ? Offset(s.width / 2, s.height)
        : Offset(rtl ? 0 : s.width, s.height / 2);
    return DisplayFeatureSubScreen(anchorPoint: anchor, child: child);
  }
}
