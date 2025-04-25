import 'package:demo1/pages/HomePage.dart';
import 'package:demo1/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo1/providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Flutter Demo',
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
