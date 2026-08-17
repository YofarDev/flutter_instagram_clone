// test/core/widgets/ig_nav_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_nav_bar.dart';

Widget _wrap({required IgNavBar bar}) =>
    MaterialApp(home: Scaffold(bottomNavigationBar: bar));

void main() {
  testWidgets('renders 5 unlabeled destinations', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        bar: IgNavBar(
          currentIndex: 0,
          onBranchSelected: (_) {},
          onCreate: () {},
          unreadCount: 0,
        ),
      ),
    );
    expect(find.byType(IgNavBar), findsOneWidget);
    expect(find.text('Feed'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('create tab reports via onCreate, not branch index', (
    WidgetTester tester,
  ) async {
    int? branch;
    bool created = false;
    await tester.pumpWidget(
      _wrap(
        bar: IgNavBar(
          currentIndex: 0,
          onBranchSelected: (int i) => branch = i,
          onCreate: () => created = true,
          unreadCount: 0,
        ),
      ),
    );
    // 5 icon buttons in order: home, search, plus, reels, avatar
    final Finder icons = find.byType(GestureDetector);
    await tester.tap(icons.at(2));
    expect(created, isTrue);
    expect(branch, isNull);
  });
}
