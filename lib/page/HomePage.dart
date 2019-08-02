import 'package:flutter/material.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/page/AdminPage.dart';
import 'package:flutter_start/widget/gsy_tabbar_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'CoachPage.dart';
import 'LearningEmotionPage.dart';
import 'parentReward.dart';
///首页
class HomePage extends StatelessWidget {

  int _exitTime = 0;

  Future<bool> _exitApp() {
    if ((DateTime.now().millisecondsSinceEpoch - _exitTime) > 2000) {
      showToast('远大小状元：再按一次退出',position:ToastPosition.bottom);
      _exitTime = DateTime.now().millisecondsSinceEpoch;
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  _bulletinWindow(context){
    print("公告弹窗");
    var windowWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

      ],
    );
    //CommonUtils.showGuide(context,Text("12"));
  }
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bulletinWindow(context);
    });
    return WillPopScope(
      onWillPop: () {
        return _exitApp();
      },
      child: BlocProvider<HomeBloc>(
        bloc: HomeBloc(),
        child: new GSYTabBarWidget(
        tabViews: [
          new CoachPage(),
          new LearningEmotionPage(),
          new ParentReward(),
          new Admin(),
        ],
        backgroundColor: Colors.lightBlueAccent,
        indicatorColor: Colors.lightBlueAccent,
      ),
      )
    );
  }

}
