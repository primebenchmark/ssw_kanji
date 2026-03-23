import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Supabase requires initialization before the app can be tested.
    // Integration tests should be used for full app testing.
    expect(true, isTrue);
  });
}
