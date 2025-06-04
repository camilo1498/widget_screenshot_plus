import 'package:flutter/material.dart';

import 'example_list.dart';
import 'example_list_extra.dart';
import 'example_scrollview_extra.dart';
import 'example_single.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Screenshot Plus Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Example Screenshots")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Single Widget Example"),
            onTap: () => _navigateTo(context, const ExampleSinglePage()),
          ),
          ListTile(
            title: const Text("ListView Example"),
            onTap: () => _navigateTo(context, const ExampleListPage()),
          ),
          ListTile(
            title: const Text("ListView + Header/Footer Example"),
            onTap: () => _navigateTo(context, const ExampleListExtraPage()),
          ),
          ListTile(
            title: const Text("ScrollView + Header/Footer Example"),
            onTap: () =>
                _navigateTo(context, const ExampleScrollViewExtraPage()),
          ),
        ],
      ),
    );
  }
}
