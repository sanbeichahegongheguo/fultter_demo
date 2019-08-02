import 'package:flutter/material.dart';
class StudentAppPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StudentAppPage();
  }

}

class _StudentAppPage extends State<StudentAppPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("远大小状元学生"),
        backgroundColor: Color(0xFFffffff),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Color(0xFF333333),//自定义图标
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Text("12"),
    );
  }
}