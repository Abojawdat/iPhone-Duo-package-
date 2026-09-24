import 'package:flutter/widgets.dart';

/// Internal, marks the fake window box in the simulator.
class DuoWindow extends InheritedWidget {
  const DuoWindow({super.key, required this.box, required super.child});

  final GlobalKey box;

  static Offset originOf(BuildContext context, RenderBox box) {
    final window = context
        .getInheritedWidgetOfExactType<DuoWindow>()
        ?.box
        .currentContext
        ?.findRenderObject();
    return box.localToGlobal(Offset.zero, ancestor: window);
  }

  @override
  bool updateShouldNotify(DuoWindow oldWidget) => box != oldWidget.box;
}
