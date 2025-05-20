import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo1/providers/theme_provider.dart';
import 'package:demo1/pages/HomePage.dart';
import 'package:demo1/pages/LoginPage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: '航准答',
      theme: themeProvider.theme,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes: {
        '/homepage': (context) => HomePage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
