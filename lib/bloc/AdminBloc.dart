import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:rxdart/rxdart.dart';

import 'BlocBase.dart';

class AdminBloc extends BlocBase{
  ///分享金
  BehaviorSubject<String> _shareNum = BehaviorSubject<String>();
  Sink<String> get _shareNumSink => _shareNum.sink;
  Stream<String> get shareNumStream => _shareNum.stream;

  ///会员包
  BehaviorSubject<bool> _vipPackage= BehaviorSubject<bool>();
  Sink<bool> get _vipPackageSink => _vipPackage.sink;
  Stream<bool> get vipPackageStream => _vipPackage.stream;

  void getVipPackage() async {
    var data = await UserDao.permission("ZYB___ ");
    if(data["data"] != null){
      _vipPackageSink.add(data["data"]["Valid"]);
    }else{
      _vipPackageSink.add(false);
    }
    return;
  }

  void getTotalStar() async{
    var user = SpUtil.getObject(Config.LOGIN_USER);
    int data = await UserDao.totalGainedMoney(user["userId"]);
    _shareNumSink.add(data.toString());
//    await doNext(_shareNumSink,data);
    return;
  }




  @override
  void dispose() {
    _shareNum.close();
    // TODO: implement dispose
  }

}