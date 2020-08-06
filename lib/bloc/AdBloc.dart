import 'package:flutter/services.dart';
import 'package:flutter_start/common/dao/AdDao.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/models/Adver.dart';
import 'package:rxdart/rxdart.dart';

import 'BlocBase.dart';

class AdBloc extends BlocBase{

  ///Banner
  BehaviorSubject<Adver> _adver = BehaviorSubject<Adver>();
  Sink<Adver> get _adverSink => _adver.sink;
  Stream<Adver> get adverStream => _adver.stream.asBroadcastStream();

  static  final  Map<String,MethodChannel> adChannelMap = new Map();

  ///辅导页面小状元模块栏目
  Future getBanner({String pageName}) async{
    DataResult data = await AdDao.getAppRevScreenAdver(4);
    if(null!=data && data.result){
      print('辅导页面小状元模块栏目');
      if (data.data!=null){
        _adverSink?.add(data.data);
      }else{
        print("pageName $pageName");
        if (pageName!=null){
          print("adChannelMap ${adChannelMap[pageName]}");
          adChannelMap[pageName]?.invokeMethod("refreshBanner");
        }
      }
    }
    await doNext(_adverSink,data);
    return;
  }

  @override
  void dispose() {
    print("AdBloc dispose");
    _adver.close();
  }

}