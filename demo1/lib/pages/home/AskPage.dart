import 'package:demo1/pages/home/AskResultPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ConversationPage.dart';

class AskPage extends StatefulWidget {
  const AskPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AskPageState();
  }
}

class _AskPageState extends State<AskPage> {
  Future toAsk(String s) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                AskResultPage(searchString: s),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.3);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  Future AskEnter(String s) {
    return toAsk(s);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final TextEditingController _searchController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 0.1 * height),
            Container(
              height: 0.2 * height,
              child: Center(child: Text("这里放个logo")),
            ),
            Container(
              width: 0.95 * width,
              child: TextField(
                onSubmitted: AskEnter,
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: '输入你想问的问题',
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search),
                    color: Theme.of(
                      context,
                    ).iconTheme.color,
                    onPressed: () => toAsk(_searchController.text),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    color: Theme.of(
                      context,
                    ).iconTheme.color,
                    onPressed: _searchController.clear,
                  ),
                ),
              ),
            ),
            SizedBox(height: 0.03 * height),
            Container(
              width: width,
              padding: EdgeInsets.only(left: 0.03 * width, right: 0.03 * width),
              child: Text(
                "待回答问题",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 0.03 * height),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const ConversationPage(fromQuestion: false),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 0.03 * width,
                        right: 0.03 * width,
                      ),
                      height: 0.18 * height,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  dateFormat.format(now),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 66,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '待解答',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 0.94 * width,
                            child: Text(
                              "问题标题",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 0.94 * width,
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              "问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情问题详情",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
