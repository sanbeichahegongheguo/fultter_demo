import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
void main() {
  runApp(new HomeFragment());
  if (Platform.isAndroid) {
// 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class HomeFragment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeFragmentState();
  }
}

class HomeFragmentState extends State<HomeFragment> {

  final isActive = false;
  @override
  void initState() {
    super.initState();

  }
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
            ),
        Container(
          margin: EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Image.network("http://i0.hdslb.com/bfs/archive/c99223692da0c50e9003157b14a1f5157060fc15.jpg@480w_300h.webp",fit: BoxFit.cover,),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 10,right: 10),
          height: 150,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index){
            return Container(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Image.asset("images/ic_category_t60.png",height: 35,width: 35,),
                      Padding(padding: EdgeInsets.only(top: 5),child:Text("英雄联盟")),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Image.asset("images/ic_category_t60.png",height: 35,width: 35,),
                      Padding(padding: EdgeInsets.only(top: 5),child:Text("英雄联盟")),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Image.asset("images/ic_category_t60.png",height: 35,width: 35,),
                      Padding(padding: EdgeInsets.only(top: 5),child:Text("英雄联盟")),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Image.asset("images/ic_category_t60.png",height: 35,width: 35),
                      Padding(padding: EdgeInsets.only(top: 5),child:Text("英雄联盟")),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Image.asset("images/ic_category_t60.png",height: 35,width: 35,fit: BoxFit.scaleDown,),
                      Padding(padding: EdgeInsets.only(top: 5),child:Text("英雄联盟")),
                    ],
                  ),
                ],
              ),
            );
          },itemCount: 2,),
        ),
        Container(
          decoration:new BoxDecoration(border:new Border(bottom:BorderSide(color: Colors.black12))),
        ),
        Container(
          margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("推荐直播"),
          Row(children: <Widget>[
            Text("换一换",style: TextStyle(color: Colors.black26),),
            Icon(Icons.refresh,color: Colors.black26,)
          ],
          )
        ],),
        ),
            SizedBox(
            height: 500,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 1.2),
                itemBuilder: (context,index){
                  return Container(
                      padding: EdgeInsets.only(left: 15.0, right: 10.0),
                    child: Column(children: <Widget>[
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                            child: Image.network("http://i1.hdslb.com/bfs/archive/162b1dea017c03d37f06b7312c43cf8b956e5765.jpg@320w_200h.webp",fit: BoxFit.cover,width: 190.0,
                              height: 100.0,),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("黑哲君",style: TextStyle(color: Colors.white),),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.perm_identity,color: Colors.white),
                                    Text("14.5万",style: TextStyle(color: Colors.white)),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],

                      ),
                    ],)
                  );
                },itemCount: 6,),
          )
          ],),
      ),
    );
  }
}
