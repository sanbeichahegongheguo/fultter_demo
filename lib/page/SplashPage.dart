
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:redux/redux.dart';

///过度页面
class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {
  bool hadInit = false;
  int _status = 0;
  int _count = 3;
  @override
  void initState() {
    super.initState();
    if (hadInit) {
      return;
    }
    hadInit = true;
    _initAsync();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  void _initAsync() async {
    await SpUtil.getInstance();
    Store<GSYState> store = StoreProvider.of(context);
    new Future.delayed(const Duration(milliseconds: 500), () async {
          //登录
          UserDao.getUser(isNew:true,store: store).then((res){
            if (res != null){
              NavigatorUtil.goHome(context);
            }else{
              NavigatorUtil.goWelcome(context);
            }
          });
    });
//    _loadSplashData();
//    Observable.just(1).delay(new Duration(milliseconds: 500)).listen((_) {
////      SpUtil.putBool(Constant.key_guide, false);
//      if (SpUtil.getBool(Constant.key_guide, defValue: true) &&
//          ObjectUtil.isNotEmpty(_guideList)) {
//        SpUtil.putBool(Constant.key_guide, false);
//        _initBanner();
//      } else {
//        _initSplash();
//      }
//    });
  }
  @override
  Widget build(BuildContext context) {
    return new StoreBuilder<GSYState>(builder: (context, store) {
      return  Material(
        child: Stack(
          children: <Widget>[
            new Offstage(
              offstage: !(_status == 0),
              child: _buildSplashBg(),
            ),
          ],
        ),
      );
    });
  }

  ///背景图
  Widget _buildSplashBg() {
    return new Image.asset(
      "images/splash.png",
      width: double.infinity,
      fit: BoxFit.fill,
      height: double.infinity,
    );
  }
}