// test/core/widgets/ig_icon_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icon.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icons.dart';

void main() {
  testWidgets('IgIcon renders every glyph without throwing', (
    WidgetTester tester,
  ) async {
    final List<IgIconData> all = <IgIconData>[
      IgIcons.home,
      IgIcons.search,
      IgIcons.reels,
      IgIcons.heart,
      IgIcons.comment,
      IgIcons.share,
      IgIcons.bookmark,
      IgIcons.plusSquare,
      IgIcons.moreDots,
      IgIcons.camera,
      IgIcons.chevron,
      IgIcons.grid,
      IgIcons.tagged,
      IgIcons.micOrSend,
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: IgIconTheme(
          active: Colors.black,
          inactive: Colors.grey,
          child: Row(
            children: <Widget>[
              for (final IgIconData d in all)
                IgIcon(d, size: 24, color: Colors.black),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(IgIcon), findsNWidgets(all.length));
  });

  testWidgets('paths stay inside the size box', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: IgIconTheme(
          active: Colors.black,
          inactive: Colors.grey,
          child: Scaffold(
            body: Center(child: IgIcon(IgIcons.home, color: Colors.black)),
          ),
        ),
      ),
    );
    final Rect box = tester.getRect(find.byType(IgIcon));
    expect(box.width, 24);
    expect(box.height, 24);
  });
}
