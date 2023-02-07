import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_list/posts/posts.dart';

void main() {
  group('PostState', () {
    test('supports value comparison', () {
      expect(const PostState(), const PostState());
      expect(
        const PostState().toString(),
        const PostState().toString(),
      );
    });
  });
}
