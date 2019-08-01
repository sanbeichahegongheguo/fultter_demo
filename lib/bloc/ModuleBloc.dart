import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/dao/moduleDao.dart';
import 'package:flutter_start/models/ConvertGoods.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:rxdart/rxdart.dart';
import 'BlocBase.dart';
class ModuleBloc extends BlocBase{
  ///模块栏目
  PublishSubject<List<Module>> _module = PublishSubject<List<Module>>();
  Sink<List<Module>> get _moduleSink => _module.sink;
  Observable<List<Module>> get moduleStream => _module.stream;

  ///辅导页面小状元模块栏目
  void getCoachXZYModule() async{
    DataResult data = await ModuleDao.getModule(1,Config.coachXZYModule);
    print('辅导页面小状元模块栏目');
    print(data.data);
    if(null!=data && data.result){
      _moduleSink.add(data.data);
    }else{
      ///请求失败
    }
    await doNext(_moduleSink,data);
    return;
  }

  ///辅导页面小状元模块栏目
  void getCoachJZModule() async{
    DataResult data = await ModuleDao.getModule(2,Config.coachJZModule);
    print('辅导页面小状元模块栏目');
    print(data.data);
    if(null!=data && data.result){
      _moduleSink.add(data.data);
    }else{
      ///请求失败
    }
    await doNext(_moduleSink,data);
    return;
  }

  ///学情页面底部模块栏目
  void getLEmotionModule() async{
    DataResult data = await ModuleDao.getModule(3,Config.lEmotionModule);
    print('学情页面底部模块栏目');
    print(data.data);
    if(null!=data && data.result){
      _moduleSink.add(data.data);
    }else{
      ///请求失败
    }
    await doNext(_moduleSink,data);
    return;
  }

  ///家长奖励底部模块栏目
  void getParentBottomModule() async{
    DataResult data = await ModuleDao.getModule(4,Config.parentRewardModule);
    print('家长奖励底部模块数据');
    print(data.data);
    if(null!=data && data.result){
      _moduleSink.add(data.data);
    }else{
      ///请求失败
    }
    await doNext(_moduleSink,data);
    return;
  }

  void dispose(){
    _module.close();
  }
}