import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ConversationPage.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SquarePageState();
  }
}

class _SquarePageState extends State<SquarePage> {
  Future<List<dynamic>>? _questionsList;
  List<int> ids=[];

  Future<List<dynamic>> getQuestions() async {
    return [
      {
        'id': 1,
        'username': 'tmpUser',
        'title': 'tmpTitle',
        'content': 'tmpContent',
        'likeCount': 1
      }
    ];
  }

  @override
  void initState() {
    _questionsList = getQuestions();
    _questionsList?.then((data) {
      print("已公开${data.length}个问题");
      for (int i = 0; i < data.length; ++i) {
        ids[i] = data[i]['id'];
      }
    });
    super.initState();
  }

  Future<void> toSearch(String s) {
    return Future.delayed(Duration(seconds: 0));
    // if (s.isEmpty) {
    //   return Future.delayed(Duration(seconds: 0));
    // }
    // return Navigator.of(context).push(
    //   PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) =>
    //         SearchResultPage(searchString: s),
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       const begin = Offset(0.0, 0.3);
    //       const end = Offset.zero;
    //       const curve = Curves.ease;
    //
    //       final tween = Tween(begin: begin, end: end);
    //       final curvedAnimation = CurvedAnimation(
    //         parent: animation,
    //         curve: curve,
    //       );
    //
    //       return SlideTransition(
    //         position: tween.animate(curvedAnimation),
    //         child: child,
    //       );
    //     },
    //   ),
    // );
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
            child: Center(
      child: Column(
        children: [
          Container(
            width: 0.95 * width,
            child: TextField(
              onSubmitted: (String s) => toSearch(s),
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
                  color: Theme.of(context).iconTheme.color,
                  onPressed: () => toSearch(_searchController.text),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  color: Theme.of(context).iconTheme.color,
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
              "问题广场",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 0.03 * height),
          Expanded(
              child: FutureBuilder(
                  future: _questionsList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title:
                                          Text('标题：${snapshot.data?[index]['title']}'),
                                      content:Text('这里是问题具体内容，我还不知道写什么'),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            '确定',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 0.03 * width,
                                right: 0.03 * width,
                              ),
                              height: 0.18 * height,
                              child: Column(
                                children: [
                                  Container(
                                    width: 0.94 * width,
                                    child: Text(
                                      snapshot.data?[index]['title'],
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
                                      snapshot.data?[index]['content'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Icon(
                                              Icons.thumb_up,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            Text(
                                              snapshot.data?[index]['likeCount']
                                                  .toString() as String,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: snapshot.data?.length,
                      );
                    } else {
                      return Text('暂无待回答问题');
                    }
                  })),
        ],
      ),
    )));
  }
}
