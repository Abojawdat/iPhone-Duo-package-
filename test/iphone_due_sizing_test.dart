import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iphone_due_sizing/iphone_due_sizing.dart';

void main() {
  testWidgets('scales relative to design size', (tester) async {
    late double w, h, r;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(786, 852)),
        child: IphoneSizing(
          child: Builder(builder: (_) {
            w = 10.w;
            h = 10.h;
            r = 10.r;
            return const SizedBox();
          }),
        ),
      ),
    );
    expect(w, 20);
    expect(h, 10);
    expect(r, 10);
  });
}
