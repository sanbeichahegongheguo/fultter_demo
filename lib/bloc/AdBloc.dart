import 'package:flutter_start/common/dao/AdDao.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/models/Adver.dart';
import 'package:rxdart/rxdart.dart';

import 'BlocBase.dart';

class AdBloc extends BlocBase{

  static final AdBloc _singleton = AdBloc();
  static AdBloc getInstance() {
    if(_singleton._adver.isClosed){
      _singleton._adver =  BehaviorSubject<Adver>();
    }
    return _singleton;
  }
  ///Banner
  BehaviorSubject<Adver> _adver = BehaviorSubject<Adver>();
  Sink<Adver> get _adverSink => _adver.sink;
  Observable<Adver> get adverStream => _adver.stream;

  ///辅导页面小状元模块栏目
  void getBanner() async{
    DataResult data = await AdDao.getAppRevScreenAdver(4);
    print('辅导页面小状元模块栏目');

    if(null!=data && data.result){
      if (data.data!=null){
        _adverSink?.add(data.data);
      }
    }

    await doNext(_adverSink,data);
    return;
  }

  @override
  void dispose() {
    _adver.close();
  }

}