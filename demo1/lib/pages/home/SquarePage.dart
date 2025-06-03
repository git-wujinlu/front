import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/message_service.dart';
import '../../services/user_service.dart';
import 'ConversationPage.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SquarePageState();
  }
}

class _SquarePageState extends State<SquarePage> {
  final messageService = MessageService();
  Future<List<dynamic>>? _questionsList;
  List<int> ids = [];
  int nowPage = 0;

  Future<List<dynamic>> getQuestions() async {
    print("准备获取第${nowPage + 1}页公开对话");
    Map<String, dynamic> publics =
        await messageService.getPublicConversations(nowPage + 1, 10);
    if (publics['records'].length > 0) {
      ++nowPage;
      return publics['records'];
    }
    return [];
  }

  @override
  void initState() {
    _questionsList = getQuestions();
    _questionsList?.then((data) {
      print("已公开${data.length}个问题");
      for (int i = 0; i < data.length; ++i) {
        print("已设置第一个问题的id为${data[i]['id']}");
        ids.add(data[i]['id']);
      }
      print(ids);
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

  Future<dynamic> getQuestion(int id) async {
    List<dynamic> _messages = await messageService.getConversationById(id);

    return _messages;
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
                                      title: Text(
                                          '标题：${snapshot.data?[index]['title']}'),
                                      content: SingleChildScrollView(
                                          child: SizedBox(
                                        width: 0.9 * width,
                                        height: 0.5 * height,
                                        child: FutureBuilder(
                                            future: getQuestion(ids[index]),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              } else if (snapshot.hasData) {
                                                return ListView.builder(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0.05 * width,
                                                      vertical: 8),
                                                  itemCount:
                                                      snapshot.data?.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final msg = snapshot.data?[
                                                        snapshot.data?.length -
                                                            1 -
                                                            index];
                                                    final isMe = msg['isMe'];

                                                    final bubble = Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxWidth:
                                                                  0.7 * width),
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                        color: isMe
                                                            ? Colors
                                                                .purple.shade700
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        msg['text'],
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: isMe
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    );

                                                    return Align(
                                                      alignment: isMe
                                                          ? Alignment
                                                              .centerRight
                                                          : Alignment
                                                              .centerLeft,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // if (!isMe) ...[avatar, const SizedBox(width: 8)],
                                                          bubble,
                                                          // if (isMe) ...[const SizedBox(width: 8), avatar],
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                return Text("错误");
                                              }
                                            }),
                                        // child: ListView.builder(
                                        //   padding: EdgeInsets.symmetric(horizontal: 0.05 * width, vertical: 8),
                                        //   itemCount: _messages.length,
                                        //   itemBuilder: (context, index) {
                                        //     final msg = _messages[_messages.length - 1 - index];
                                        //     final isMe = msg['isMe'];
                                        //
                                        //     final bubble = Container(
                                        //       constraints: BoxConstraints(maxWidth: 0.7 * width),
                                        //       margin: const EdgeInsets.symmetric(vertical: 4),
                                        //       padding: const EdgeInsets.all(10),
                                        //       decoration: BoxDecoration(
                                        //         color: isMe ? Colors.purple.shade700 : Colors.white,
                                        //         borderRadius: BorderRadius.circular(8),
                                        //       ),
                                        //       child: Text(
                                        //         msg['text'],
                                        //         style: TextStyle(
                                        //           fontSize: 16,
                                        //           color: isMe ? Colors.white : Colors.black,
                                        //         ),
                                        //       ),
                                        //     );
                                        //
                                        //     return Align(
                                        //       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                        //       child: Row(
                                        //         mainAxisSize: MainAxisSize.min,
                                        //         crossAxisAlignment: CrossAxisAlignment.start,
                                        //         children: [
                                        //           // if (!isMe) ...[avatar, const SizedBox(width: 8)],
                                        //           bubble,
                                        //           // if (isMe) ...[const SizedBox(width: 8), avatar],
                                        //         ],
                                        //       ),
                                        //     );
                                        //   },
                                        // ),
                                      )),
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
