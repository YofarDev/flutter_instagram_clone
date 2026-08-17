// test/core/widgets/skeleton_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instagram_clone/core/widgets/skeleton/skeletons.dart';

void main() {
  testWidgets('SkeletonPostCard pumps and animates', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SkeletonPostCard())),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SkeletonPostCard), findsOneWidget);
  });

  testWidgets('SkeletonAvatar renders at requested radius', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: SkeletonAvatar(radius: 16))),
      ),
    );
    final Size size = tester.getSize(find.byType(SkeletonAvatar));
    expect(size.width, 32);
  });
}
