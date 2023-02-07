import 'package:flutter/material.dart';

import 'posts/view/view.dart';

class App extends MaterialApp {
  const App({super.key}) : super(home: const PostsScreen());
  @override
  bool get debugShowCheckedModeBanner => false;
}
