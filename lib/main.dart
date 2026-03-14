import 'package:flutter/material.dart';
import 'screens/blog_list_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const DobovkyApp());
}

class DobovkyApp extends StatelessWidget {
  const DobovkyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ApiService is created once and passed down to screens that need it.
    final apiService = ApiService();

    return MaterialApp(
      title: 'Dobovky Blog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BlogListScreen(apiService: apiService),
      debugShowCheckedModeBanner: false,
    );
  }
}