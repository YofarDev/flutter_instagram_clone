import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_instagram_clone/core/widgets/ig_icon.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icons.dart';
import 'package:flutter_instagram_clone/features/notifications/presentation/widgets/badge_icon.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('count 0 renders bare icon without red dot', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap(BadgeIcon(igIcon: IgIcons.heart, count: 0)));

    expect(
      find.byWidgetPredicate(
        (Widget w) => w is IgIcon && w.data == IgIcons.heart,
      ),
      findsOneWidget,
    );
    expect(find.text('0'), findsNothing);
  });

  testWidgets('count 3 renders red dot with 3', (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(BadgeIcon(igIcon: IgIcons.heart, count: 3)));

    expect(
      find.byWidgetPredicate(
        (Widget w) => w is IgIcon && w.data == IgIcons.heart,
      ),
      findsOneWidget,
    );
    expect(find.text('3'), findsOneWidget);
  });
}
