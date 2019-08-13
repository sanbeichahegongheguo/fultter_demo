import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
class ShareToWeChat extends StatefulWidget{
    const ShareToWeChat({
      Key key,
      @required this.webPage,
      @required this.thumbnail,
      @required this.transaction,
      @required this.description,
      @required this.title,
    }): super(key: key);
    final String webPage;
    final String thumbnail;
    final String transaction;
    final String title;
    final String description;
    // TODO: implement createState
    @override
    State<StatefulWidget> createState() {
      return _StatefulWidget(this.webPage,this.thumbnail,this.transaction,this.title,this.description);
    }
}
class _StatefulWidget extends State<ShareToWeChat>{
  String _thumbnail;
  String _webPage;
  String _transaction;
  String _title;
  String _description;
  _StatefulWidget(
    this._webPage,
    this._thumbnail,
    this._transaction,
    this._title,
    this._description,
  ) : super();
  @override
  initState(){
    super.initState();
    fluwx.register(appId:"wx6b9c3fe446a8d77d", doOnAndroid: true, doOnIOS: true);
  }
  void _share(int num){
    fluwx.WeChatScene scene = fluwx.WeChatScene.SESSION;
    switch(num){
      case 0:
        scene = fluwx.WeChatScene.SESSION;//会话
        print("会话");
        break;
      case 1:
        scene = fluwx.WeChatScene.TIMELINE;//朋友圈
        print("朋友圈");
        break;
      case 2:
        scene = fluwx.WeChatScene.FAVORITE;//收藏
        print("收藏");
        break;
    }
    fluwx.share(fluwx.WeChatShareWebPageModel(
        webPage: _webPage,
        thumbnail: _thumbnail,
        transaction: _transaction,
        title: _title,
        scene: scene,
        description: _description
    )
    );
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    List _shareMsg = [
      {"icon":Icon(Icons.chat_bubble,size:ScreenUtil.getInstance().getHeightPx(100),color:Color(0xFF5fc589),),"title":"会话","id":1},
      {"icon":Icon(Icons.camera,size:ScreenUtil.getInstance().getHeightPx(100),color:Color(0xFF5fc589),),"title":"朋友圈","id":1},
      {"icon":Icon(Icons.star,size:ScreenUtil.getInstance().getHeightPx(100),color:Color(0xFF5fc589),),"title":"收藏","id":1}
    ];
    List<Widget> _shareList(){
      List<Widget> shareList = [];
      for(int i = 0;i<_shareMsg.length;i++){
        shareList.add(
            Padding(
              padding:EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(40)),
              child: Container(
                child: GestureDetector(
                  onTap: (){
                    _share(i);
                    },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _shareMsg[i]["icon"],
                      Padding(
                        padding: EdgeInsets.only(top:2),
                        child: Text(
                          _shareMsg[i]["title"],
                          style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(36 / 3) , color:Color(0xFF606a81)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        );
      }
      return shareList;
    }

    // TODO: implement build
    return GestureDetector(
      onTap: (){ },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              color: Color(0xFFffffff),
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                children: _shareList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}