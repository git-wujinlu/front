import 'package:demo1/services/ask_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../services/user_service.dart';

class AskResultPage extends StatefulWidget {
  final String searchString;

  const AskResultPage({super.key, required this.searchString});

  @override
  State<StatefulWidget> createState() {
    return _AskResultPageState(searchString: this.searchString);
  }
}

class _AskResultPageState extends State<AskResultPage> {
  final AskService _askService = new AskService();
  var selectedList = List.filled(10, false);
  final String searchString;
  Future<List<dynamic>>? _searchList;
  List<int> ids = List.filled(10, 0);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  _AskResultPageState({required this.searchString});

  void select(int index) {
    setState(() {
      selectedList[index] = !selectedList[index];
    });
  }

  List<int> getSelectedId() {
    List<int> ans = List.empty(growable: true);
    for (int i = 0; i < selectedList.length; ++i) {
      if (selectedList[i] == true) ans.add(ids[i]);
    }
    return ans;
  }

  @override
  void initState() {
    _searchList = _askService.search(searchString);
    _searchList?.then((data) {
      for (int i = 0; i < data.length; ++i) {
        ids[i] = data[i]['id'];
      }
    });
    _searchController.text = searchString;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    List<Widget> getLabel(List<dynamic> a) {
      List<Widget> ans = [];
      for (int i = 0; i < a.length; ++i) {
        ans.add(
          Container(
            padding: EdgeInsets.only(
              top: 0.01 * width,
              bottom: 0.01 * width,
              left: 0.015 * width,
              right: 0.015 * width,
            ),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.grey[600]
                  : Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(a[i]),
          ),
        );
        if (i < a.length + 1) ans.add(SizedBox(width: 0.015 * width));
      }
      return ans;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(),
            Container(
              width: 0.95 * width,
              child: TextField(
                onSubmitted: (String s) {
                  if (s.isEmpty) {
                    Navigator.pop(context);
                  }
                  setState(() {
                    _searchList = _askService.search(s);
                    _searchList?.then((data) {
                      for (int i = 0; i < data.length; ++i) {
                        ids[i] = data[i]['id'];
                      }
                    });
                  });
                },
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
                    onPressed: () {
                      if (_searchController.text.isEmpty) {
                        Navigator.pop(context);
                      }
                      setState(() {
                        _searchList =
                            _askService.search(_searchController.text);
                      });
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    color: Theme.of(context).iconTheme.color,
                    onPressed: () {
                      _searchController.clear;
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 0.03 * height),
            Flexible(
              flex: 9,
              child: FutureBuilder(
                future: _searchList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => select(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: (selectedList[index] == false)
                                  ? themeProvider.isDarkMode
                                      ? Theme.of(context).cardTheme.color
                                      : Colors.white
                                  : themeProvider.isDarkMode
                                      ? Colors.deepPurple.shade600
                                      : Colors.deepPurple.shade100,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                            padding: EdgeInsets.only(
                              top: 0.012 * height,
                              bottom: 0.012 * height,
                              left: 0.03 * width,
                              right: 0.03 * width,
                            ),
                            margin: EdgeInsets.only(
                              top: 0.01 * height,
                              bottom: 0.01 * height,
                              left: 0.03 * width,
                              right: 0.03 * width,
                            ),
                            height: 0.1 * height,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipOval(
                                  child:
                                      (UserService.getFullAvatarUrl(snapshot.data?[index]['avatar']).isEmpty)
                                          ? Image.asset(
                                              'assets/img.png',
                                              width: 0.12 * width,
                                              height: 0.12 * width,
                                              fit: BoxFit.fill,
                                            )
                                          : Image.network(
                                        UserService.getFullAvatarUrl(snapshot.data?[index]['avatar']),
                                              width: 0.12 * width,
                                              height: 0.12 * width,
                                              fit: BoxFit.fill,
                                            ),
                                ),
                                SizedBox(width: 0.03 * width),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          snapshot.data?[index]['username'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(width: 0.02 * width),
                                        Text(
                                          "回答数：${(snapshot.data?[index]['userful_count'].toString()) as String}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.005 * height),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: getLabel(
                                        snapshot.data?[index]['tags'],
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.thumb_up,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      Text(
                                        snapshot.data?[index]['like_count']
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
                          ),
                        );
                      },
                      itemCount: snapshot.data?.length,
                    );
                  } else if (snapshot.hasError) {
                    return Text('发生了一个错误');
                  }
                  return Text('暂时没有回答');
                },
              ),
            ),
            Flexible(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('标题：${_searchController.text}'),
                          content: Container(
                            width: 0.8 * width,
                            child: TextField(
                              controller: _contentController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '问题详情',
                              ),
                              maxLines: null,
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                '取消',
                                style: TextStyle(color: Colors.grey),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text(
                                '确定',
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () async {
                                if (await _askService.askQuestion(
                                    _searchController.text,
                                    _contentController.text,
                                    getSelectedId())) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 0.04 * height,
                    width: 0.3 * width,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        "确定提问",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
