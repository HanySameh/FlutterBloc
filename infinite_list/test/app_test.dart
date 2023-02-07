import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_list/app.dart';
import 'package:infinite_list/posts/view/view.dart';

void main() {
  group('App', () {
    testWidgets('renders PostsPage', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(PostsScreen), findsOneWidget);
    });
  });
}
