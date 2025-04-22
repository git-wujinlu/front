import 'package:demo1/pages/home/AskPage.dart';
import 'package:demo1/pages/home/MessagePage.dart';
import 'package:demo1/pages/home/SelfPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;
  final List _pages = [AskPage(), MessagePage(), SelfPage()];

  void _changePageIndex(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final PageController _pageControoller = PageController();
    return Scaffold(
      body: PageView(
        controller: _pageControoller,
        onPageChanged: _changePageIndex,
        children: [AskPage(), MessagePage(), SelfPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (int index) {
          _pageControoller.animateToPage(
            index,
            duration: Duration(milliseconds: 150),
            curve: Curves.easeInOut,
          );
        },
        selectedItemColor: Colors.deepPurple.shade700,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "问答"),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: "消息"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
        ],
      ),
    );
  }
}
