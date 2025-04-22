import 'package:demo1/pages/HomePage.dart';
import 'package:demo1/pages/LoginPage.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes: {
        '/homepage': (context) => HomePage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}