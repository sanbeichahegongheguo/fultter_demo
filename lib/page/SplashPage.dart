
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:redux/redux.dart';

import 'HomePage.dart';
import 'PhoneLoginPage.dart';

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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (BuildContext context) => HomePage()),
                    (Route<dynamic> route) => false,
              );
            }else{
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (BuildContext context) => PhoneLoginPage()),
                    (Route<dynamic> route) => false,
              );
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
    return Container(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          child: Flex(direction: Axis.vertical, children: <Widget>[
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(269),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(70),
            ),
            Container(
              child: Image.asset(
                "images/phone_login/center.png",
                width: ScreenUtil.getInstance().getWidthPx(542),
                height: ScreenUtil.getInstance().getHeightPx(447),
              ),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(100),
            ),
            Expanded(
              child: Container(
                  padding: EdgeInsets.only(bottom: ScreenUtil.getInstance().getHeightPx(55)),
                  alignment: AlignmentDirectional.bottomCenter,
                  // ignore: static_access_to_instance_member
                  child: Flex(direction: Axis.vertical, mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "images/phone_login/bottom.png",
                          fit: BoxFit.scaleDown,
                          height: ScreenUtil.getInstance().getHeightPx(77),
                          width: ScreenUtil.getInstance().getWidthPx(77),
                        ),
                        Text("  远大小状元家长", style: TextStyle(color: Colors.black, fontSize: ScreenUtil.getInstance().getSp(14)))
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeightPx(20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text("Copyright © Yondor.All Rights Reserved.", style: TextStyle(color: Color(0xFF666666), fontSize: ScreenUtil.getInstance().getSp(11)))],
                    )
                  ])),
              flex: 2,
            ),
          ]),
        ),
      ),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: const FractionalOffset(0.5, 0.0),
          end: const FractionalOffset(0.5, 1.0),
          colors: <Color>[Color(0xFFcdfdd3), Color(0xFFe2fff0)],
        ),
      ),
    );
  }
}