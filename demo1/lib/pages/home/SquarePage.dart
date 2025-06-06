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
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<int> ids = [];
  int nowPage = 0;

  Future<List<dynamic>> getQuestions() async {
    print("准备获取第${nowPage + 1}页公开对话");
    Map<String, dynamic> publics = await messageService.getPublicConversations(
        nowPage + 1, 10, _searchText);
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
        print("已设置第${ids.length + 1}个问题的id为${data[i]['id']}");
        ids.add(data[i]['id']);
      }
      print(ids);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _questionsList?.then((data) {
          getQuestions().then((newData) {
            for (int i = 0; i < newData.length; ++i) {
              print("已设置第${ids.length + 1}个问题的id为${newData[i]['id']}");
              ids.add(newData[i]['id']);
            }
            setState(() {
              data.addAll(newData);
            });
          });
        });
      }
    });
    super.initState();
  }

  void toSearch(String s) {
    nowPage = 0;
    _searchText = s;
    ids.clear();
    setState(() {
      _questionsList = getQuestions();
      _questionsList?.then((data) {
        print("已公开${data.length}个问题");
        for (int i = 0; i < data.length; ++i) {
          print("已设置第${ids.length + 1}个问题的id为${data[i]['id']}");
          ids.add(data[i]['id']);
        }
        print(ids);
      });
    });
  }

  Future<dynamic> getQuestion(int id) async {
    List<dynamic> _messages = await messageService.getConversationById(id);
    return _messages;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
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
                hintText: '输入你想搜索的问题',
                prefixIcon: IconButton(
                  icon: Icon(Icons.search),
                  color: Theme.of(context).iconTheme.color,
                  onPressed: () => toSearch(_searchController.text),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  color: Theme.of(context).iconTheme.color,
                  onPressed: () {
                    _searchController.text='';
                    toSearch('');
                  },
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
                                              } else if (snapshot
                                                      .data?.isNotEmpty ??
                                                  false) {
                                                int asker = snapshot.data?[
                                                    (snapshot.data?.length) -
                                                        1]['fromId'];
                                                return ListView.builder(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0.05 * width,
                                                      vertical: 8),
                                                  itemCount:
                                                      snapshot.data?.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final msg = snapshot.data?[
                                                        (snapshot
                                                                .data?.length) -
                                                            1 -
                                                            index];
                                                    print(msg);
                                                    final isMe =
                                                        msg['fromId'] == asker;

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
                                                        msg['content'],
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
                                                          bubble,
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else if (snapshot
                                                  .data.isEmpty) {
                                                return Text("无详细对话");
                                              } else {
                                                return Text("错误");
                                              }
                                            }),
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
                                      snapshot.data?[index]['content']?? '',
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
                                          dateFormat.format(
                                              snapshot.data?[index]
                                                          ['createTime'] !=
                                                      null
                                                  ? DateTime.parse(
                                                      snapshot.data?[index]
                                                          ['createTime'])
                                                  : DateTime.now()),
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
                        controller: _scrollController,
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
