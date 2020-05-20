import 'package:fluwx/fluwx.dart' as fluwx;

class ShareWx{


  static wxshare(num,_webPage,_thumbnail,_transaction,_title,_description){
    fluwx.register(appId:"wx6b9c3fe446a8d77d", doOnAndroid: true, doOnIOS: true);
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
  }
}