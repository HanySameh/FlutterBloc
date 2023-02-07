import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_list/posts/posts.dart';

void main() {
  group('PostEvent', () {
    group('PostFetched', () {
      test('supports value comparison', () {
        expect(PostFetched(), PostFetched());
      });
    });
  });
}
