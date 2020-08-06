import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:fluwx/fluwx.dart';

class ShareWx{


  static wxshare(num,_webPage,_thumbnail,_transaction,_title,_description){
    fluwx.registerWxApi(appId:"wx6b9c3fe446a8d77d", doOnAndroid: true, doOnIOS: true);
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
      case 3:
        scene = fluwx.WeChatScene.SESSION;//收藏
        print("微信小程序");
        break;
    }
    fluwx.shareToWeChat(fluwx.WeChatShareWebPageModel(_webPage,
        thumbnail: _thumbnail,
//        transaction: _transaction,
        title: _title,
        scene: scene,
        description: _description
    )
    );
  }

  ///分享微信小程序
  static chatShareMiniProgramModel(_webPageUrl,_userName,_title,_path,_description,_thumbnail){
    fluwx.registerWxApi(appId:"wx6b9c3fe446a8d77d", doOnAndroid: true, doOnIOS: true);
    fluwx.WeChatScene scene = fluwx.WeChatScene.SESSION;

//     _webPageUrl = "http://www.qq.com";
//     _thumbnail =
//        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534614311230&di=b17a892b366b5d002f52abcce7c4eea0&imgtype=0&src=http%3A%2F%2Fimg.mp.sohu.com%2Fupload%2F20170516%2F51296b2673704ae2992d0a28c244274c_th.png";
//     _title = "Fluwx";
//     _userName = "gh_75ce0db40820";
//     _path = "/pages/index/index";
//     _description = "Fluwx";
//    fluwx.launchMiniProgram(username: _userName);
    var model = new WeChatShareMiniProgramModel(
        webPageUrl: _webPageUrl,
        userName: _userName,
        title: _title,
        path: _path,
        description: _description,
        thumbnail: _thumbnail,
        miniProgramType:WXMiniProgramType.TEST
    );
    fluwx.shareToWeChat(model);
  }

  ///[WXMiniProgramType.RELEASE]正式版
  ///[WXMiniProgramType.TEST]测试版
  ///[WXMiniProgramType.PREVIEW]预览版
  ///打开微信 小程序
  static launchMiniProgram(username,type,path){
    fluwx.registerWxApi(appId:"wx6b9c3fe446a8d77d", doOnAndroid: true, doOnIOS: true);
    WXMiniProgramType miniProgramType = WXMiniProgramType.RELEASE;
    switch(type){
      case 0:
        miniProgramType =  WXMiniProgramType.RELEASE;
        break;
      case 1:
        miniProgramType =  WXMiniProgramType.TEST;
        break;
      case 2:
        miniProgramType =  WXMiniProgramType.PREVIEW;
        break;
    }
    print("username====>${username}");
    fluwx.launchWeChatMiniProgram(username: username,miniProgramType:miniProgramType,path:path);
  }
}