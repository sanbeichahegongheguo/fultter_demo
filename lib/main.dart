import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
    primarySwatch: Colors.blue,
    ),
    home: MyHomePage(title: '我是标题'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.add),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10,bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(children: <Widget>[
                Icon(Icons.add_a_photo,color: Colors.blue,),
                Text("相机"),
              ],),
              Column(children: <Widget>[
                Icon(Icons.access_alarms,color: Colors.blue),
                Text("时钟"),
              ],),Column(children: <Widget>[
                Icon(Icons.account_box,color: Colors.blue),
                Text("联系人"),
              ],),Column(children: <Widget>[
                Icon(Icons.audiotrack,color: Colors.blue),
                Text("音乐"),
              ],),Column(children: <Widget>[
                Icon(Icons.favorite,color: Colors.blue),
                Text("我的关心"),
              ],),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Icon(Icons.settings_overscan,size: 80,),
              width: 80,
              height: 80,
              color: Colors.red,
              margin: EdgeInsets.only(left: 10),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Text("设备名称"),
                Text("此处为消息内容部分"),
              ],),
            ),
            Container(child: Text("2019-03-31"),padding: EdgeInsets.only(left: 50),),
          ],
        )
      ],)
    );
  }
}
