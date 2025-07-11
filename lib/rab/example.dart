import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  Test({super.key});
  final List<String> country = [
    "Syria",
    "Egyot",
    "Italy",
    "USA",
    "Russia",
    "Lebanon",
    "China",
    "Australia",
    "Canada",
    "Germany",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example'), centerTitle: true),
      body: Column(
        children: [
          Icon(Icons.mail),
          Icon(Icons.star),
          IconButton(onPressed: () {}, icon: Icon(Icons.abc)),
          Text(country[2].toUpperCase()),
          ElevatedButton(onPressed: () {}, child: Text("Show !!")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.info),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Test(), debugShowCheckedModeBanner: false);
  }
}
