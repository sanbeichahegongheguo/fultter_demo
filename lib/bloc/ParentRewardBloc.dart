import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/dao/moduleDao.dart';
import 'package:flutter_start/models/ConvertGoods.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:rxdart/rxdart.dart';
import 'BlocBase.dart';
class ParentRewardBloc extends BlocBase{
  ///星星
  PublishSubject<String> _starNum = PublishSubject<String>();
  Sink<String> get _starNumSink => _starNum.sink;
  Observable<String> get starNumStream => _starNum.stream;
  ///热门兑换
  PublishSubject<List<ConvertGoods>> _convertGoods = PublishSubject<List<ConvertGoods>>();
  Sink<List<ConvertGoods>> get _convertGoodsSink => _convertGoods.sink;
  Observable<List<ConvertGoods>> get convertGoodsStream => _convertGoods.stream;

  ///获取星星总数
  void getTotalStar() async{
    DataResult data = await UserDao.getTotalStar();
    if(null!=data && data.result){
      _starNumSink.add(data.data);
    }else{
      ///请求失败
    }
    await doNext(_starNumSink,data);
    return;
  }

  ///获取热门兑换
  void getHotGift() async{
    DataResult data = await UserDao.getHotGoodsList();
    if(null!=data && data.result){
      _convertGoodsSink.add(data.data);
    }else{
      ///请求失败
    }
    await doNext(_convertGoodsSink,data);
    return;
  }


  void dispose(){
    _starNum.close();
    _convertGoods.close();
  }
}