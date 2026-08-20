import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instagram_clone/core/utils/haptics.dart';

void main() {
  testWidgets('AppHaptics calls never throw on test bindings', (
    WidgetTester tester,
  ) async {
    AppHaptics.tab();
    AppHaptics.like();
    AppHaptics.follow();
    AppHaptics.success();
    expect(true, isTrue);
  });
}
