import 'package:flutter/material.dart';

void main() => runApp(HomeFragment());

class HomeFragment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeFragmentState();
  }
}

class HomeFragmentState extends State<HomeFragment> {
  final isActive = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.pinkAccent),
      home: Scaffold(
        appBar:AppBar(
          elevation:0,
          title: Row(children: <Widget>[
            ClipOval(
              child: Image.asset("images/mall_home_commend_default_avater.png",height:kToolbarHeight/2,width: kToolbarHeight/2,),
            ),
            Container(
              margin: EdgeInsets.only(left: 13),
              padding: EdgeInsets.only(left: 4),
              alignment: Alignment.centerLeft,
              width: 160,
              height: kToolbarHeight/2,
              child: Icon(Icons.search,color: Colors.white30,size: 20,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.black26,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              width: 110,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                Image.asset("images/ic_publish_inner_empty_camera.png",height:kToolbarHeight/2,width: kToolbarHeight/2,),
                Image.asset("images/music_icon_song_download.png",height:kToolbarHeight/2,width: kToolbarHeight/2,),
                Image.asset("images/ic_live_player_send_danmaku.png",height:kToolbarHeight/2,width: kToolbarHeight/2,),
              ],
              )
              ,
            )
          ],
          ),
          centerTitle: true,
        ),
        body: ListView(children: <Widget>[
            Container(
              color: Colors.white,
              alignment: Alignment.center,
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration:new BoxDecoration(border:new Border(bottom:BorderSide(color: Colors.pinkAccent))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("直播"),
                      ],
                    ),
                  ),
                  Container(
                    decoration:new BoxDecoration(border:new Border(bottom:BorderSide(color: isActive?Colors.pinkAccent:Colors.white))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                      Text("推荐"),
                    ],
                    ),
                  ),Container(
                    decoration:new BoxDecoration(border:new Border(bottom:BorderSide(color: isActive?Colors.pinkAccent:Colors.white))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("追番"),
                      ],
                    ),
                  ),Container(
                    decoration:new BoxDecoration(border:new Border(bottom:BorderSide(color: isActive?Colors.pinkAccent:Colors.white))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("国家宝藏"),
                      ],
                    ),
                  ),Container(
                    decoration:new BoxDecoration(border:new Border(bottom:BorderSide(color: isActive?Colors.pinkAccent:Colors.white))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("热门"),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],),
      ),
    );
  }
}
