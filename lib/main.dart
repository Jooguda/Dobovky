import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dobovky Blog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BlogHomePage(),
    );
  }
}

class BlogHomePage extends StatefulWidget {
  const BlogHomePage({Key? key}) : super(key: key);

  @override
  State<BlogHomePage> createState() => _BlogHomePageState();
}

class _BlogHomePageState extends State<BlogHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dobovky'),
      ),
      body: Center(
        child: Text('Blog App'),
      ),
    );
  }
}