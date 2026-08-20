import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_instagram_clone/core/widgets/heart_burst.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icon.dart';

void main() {
  testWidgets('idle burst renders nothing', (WidgetTester tester) async {
    final HeartBurstController controller = HeartBurstController();
    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: <Widget>[HeartBurst(controller: controller)]),
      ),
    );

    expect(find.byType(IgIcon), findsNothing);
  });

  testWidgets('fire pops the heart then collapses after the animation', (
    WidgetTester tester,
  ) async {
    final HeartBurstController controller = HeartBurstController();
    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: <Widget>[HeartBurst(controller: controller)]),
      ),
    );

    controller.fire();
    await tester.pump();

    expect(find.byType(IgIcon), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(IgIcon), findsNothing);
  });

  testWidgets('fire on a detached controller is a no-op', (
    WidgetTester tester,
  ) async {
    final HeartBurstController controller = HeartBurstController();
    controller.fire(); // never attached — must not throw

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: <Widget>[HeartBurst(controller: controller)]),
      ),
    );
    expect(find.byType(IgIcon), findsNothing);
  });

  testWidgets('controller detaches when the burst is disposed', (
    WidgetTester tester,
  ) async {
    final HeartBurstController controller = HeartBurstController();
    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: <Widget>[HeartBurst(controller: controller)]),
      ),
    );

    controller.fire();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    // fire after dispose must not touch the dead state
    controller.fire();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
