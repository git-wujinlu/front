import 'package:demo1/pages/home/AskResultPage.dart';
import 'package:demo1/services/ask_service.dart';
import 'package:demo1/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../../models/request_model.dart';

import 'ConversationPage.dart';

class AskPage extends StatefulWidget {
  const AskPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AskPageState();
  }
}

class _AskPageState extends State<AskPage> {
  Future<List<dynamic>>? _questionsList;

  Future<void> toAsk(String s) {
    if (s.isEmpty) {
      return Future.delayed(Duration(seconds: 0));
    }
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
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

  Future<List<dynamic>> getConversation() async {
    final messageService = MessageService();
    final askService = AskService();
    List<dynamic> _tmpList = await messageService.getConversationList();
    List<dynamic> ans = [];
    for (var item in _tmpList) {
      if (item['user1'] != -1) continue;
      final question = await askService.getQuestionById(item['questionId']);
      print(item);
      ans.add({
        'title': question?['title'],
        'content': question?['content'],
        'createTime': item['createTime'],
        'id': item['id'],
        'status': item['status'],
        'user2Id': item['user2'],
      });
    }
    return ans;
  }

  @override
  void initState() {
    _questionsList = getConversation();
    super.initState();
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
            GestureDetector(
              onTap: () async {
                print(await RequestModel.getHeaders());
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 0.05 * height,
                  top: 0.05 * height,
                ),
                height: 0.3 * height,
                child: Center(child: Image.asset('assets/logo1.png')),
              ),
            ),
            Container(
              width: 0.95 * width,
              child: TextField(
                onSubmitted: (String s) => toAsk(s),
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
                    onPressed: () => toAsk(_searchController.text),
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
                "待回答问题",
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConversationPage(
                                      fromQuestion: false,
                                      user2Id: snapshot.data?[index]
                                          ['user2Id'],
                                      conversationId: snapshot.data?[index]['id'],
                                    ),
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
                                              Container(
                                                width: 66,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '待解答',
                                                    style: TextStyle(
                                                        color: Colors.white),
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
      ),
    );
  }
}
