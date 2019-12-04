import 'package:flutter/material.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/page/AdminPage.dart';
import 'package:flutter_start/widget/gsy_tabbar_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'CoachPage.dart';
import 'LearningEmotionPage.dart';
import 'StudyInfoPage.dart';
import 'parentReward.dart';
///首页
class HomePage extends StatefulWidget{
  static const String sName = "parentReward";
  @override
  State<HomePage> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}
class _HomePageState extends State<HomePage>  {

  int _exitTime = 0;
  HomeBloc _bloc;

  Future<bool> _exitApp() {
    if ((DateTime.now().millisecondsSinceEpoch - _exitTime) > 2000) {
      showToast('远大小状元家长：再按一次退出',position:ToastPosition.bottom);
      _exitTime = DateTime.now().millisecondsSinceEpoch;
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  void initState() {
    _bloc = HomeBloc();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return _exitApp();
      },
      child: BlocProvider<HomeBloc>(
        bloc: _bloc,
        child: GSYTabBarWidget(
        tabViews: [
          CoachPage(),
          StudyInfoPage(),
          ParentReward(),
          Admin(),
        ],
        backgroundColor: Colors.lightBlueAccent,
        indicatorColor: Colors.lightBlueAccent,
      ),
      )
    );
  }
  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }

}
