import 'package:flutter/material.dart';

class AskResultPage extends StatefulWidget {
  final String searchString;

  const AskResultPage({super.key, required this.searchString});

  @override
  State<StatefulWidget> createState() {
    return _AskResultPageState(searchString: this.searchString);
  }
}

class _AskResultPageState extends State<AskResultPage> {
  var selectedList = List.filled(10, false);
  final String searchString;

  _AskResultPageState({required this.searchString});

  void select(int index) {
    setState(() {
      selectedList[index] = !selectedList[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final TextEditingController _searchController = TextEditingController(
      text: searchString,
    );
    List<Widget> getLabel() {
      List<Widget> ans = [];
      for (int i = 1; i <= 3; ++i) {
        ans.add(
          Container(
            padding: EdgeInsets.only(
              top: 0.01 * width,
              bottom: 0.01 * width,
              left: 0.015 * width,
              right: 0.015 * width,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('标签' + i.toString()),
          ),
        );
        ans.add(SizedBox(width: 0.015 * width));
      }
      ans.removeLast();
      return ans;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(),
            Container(
              width: 0.95 * width,
              decoration: BoxDecoration(
                border: Border.all(width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                // onSubmitted: ,
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '输入你想问的问题',
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => print(''),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _searchController.clear,
                  ),
                ),
              ),
            ),
            SizedBox(height: 0.03 * height),
            Flexible(
              flex: 9,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => select(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                        (selectedList[index] == false)
                            ? Colors.white
                            : Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
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
                            child: Image.asset(
                              'assets/img.png',
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
                                    "神山识",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(width: 0.02 * width),
                                  Text(
                                    "回答数：233",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.005 * height),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: getLabel(),
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
                                  '99%',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 0.02 * width),
                                Icon(
                                  Icons.thumb_down,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                Text(
                                  '1%',
                                  style: TextStyle(
                                    color: Colors.green,
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
                itemCount: 10,
              ),
            ),
            Flexible(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
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