import 'package:flutter/material.dart';

class AskPage extends StatefulWidget {
  const AskPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AskPageState();
  }
}

class _AskPageState extends State<AskPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final TextEditingController _searchController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              // color: Colors.red,
              height: 0.1 * height,
            ),
            Container(
              height: 0.2 * height,
              child: Center(child: Text("这里放个logo")),
            ),
            Container(
              width: 0.95 * width,
              decoration: BoxDecoration(
                border: Border.all(width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '输入你想问的问题',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
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
                  return Container(
                    padding: EdgeInsets.only(
                      left: 0.03 * width,
                      right: 0.03 * width,
                    ),
                    height: 0.1 * height,
                    child: Text(index.toString()),
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
