import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/moduleDao.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/models/ConvertGoods.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:rxdart/rxdart.dart';
import 'BlocBase.dart';

class ParentRewardBloc extends BlocBase {
  ///星星
  BehaviorSubject<String> _starNum = BehaviorSubject<String>();
  Sink<String> get _starNumSink => _starNum.sink;
  Stream<String> get starNumStream => _starNum.stream;

  ///热门兑换
  BehaviorSubject<List<ConvertGoods>> _convertGoods =
      BehaviorSubject<List<ConvertGoods>>();
  Sink<List<ConvertGoods>> get _convertGoodsSink => _convertGoods.sink;
  Stream<List<ConvertGoods>> get convertGoodsStream => _convertGoods.stream;

  ///家长专区广告
  BehaviorSubject<bool> _parentShowBanner = BehaviorSubject<bool>();
  Sink<bool> get _parentShowBannerSink => _parentShowBanner.sink;
  Stream<bool> get parentShowBannerStream => _parentShowBanner.stream;
  static bool _isBanner;

  ///模块栏目
  BehaviorSubject<List<Module>> _module = BehaviorSubject<List<Module>>();
  Sink<List<Module>> get _moduleSink => _module.sink;
  Stream<List<Module>> get moduleStream => _module.stream;

  ///获取星星总数
  void getTotalStar() async {
    DataResult data = await UserDao.getTotalStar();
    if (null != data && data.result) {
      _starNumSink.add(data.data);
    } else {
      ///请求失败
    }
    await doNext(_starNumSink, data);
    return;
  }

  ///获取热门兑换
  void getHotGift() async {
    DataResult data = await UserDao.getHotGoodsList();
    if (null != data && data.result) {
      _convertGoodsSink.add(data.data);
    } else {
      ///请求失败
    }
    await doNext(_convertGoodsSink, data);
    return;
  }

  ///是否展示广告
  void showBanner(bool isShow) async {
//    _parentShowBannerSink.add(isShow);
    if (ParentRewardBloc._isBanner == null ||
        ParentRewardBloc._isBanner != isShow) {
      _parentShowBannerSink.add(isShow);
      ParentRewardBloc._isBanner = isShow;
    }
  }

  ///家长奖励顶部模块栏目
  void getParentTopModule() async {
    DataResult data =
        await ModuleDao.getModule(6, Config.parentTopRewardModule);
    print('家长奖励底部模块数据');
    print(data.data);
    if (null != data && data.result) {
      _moduleSink.add(data.data);
    } else {
      ///请求失败
    }
    await doNext(_moduleSink, data);
    return;
  }

  void dispose() {
    _starNum.close();
    _convertGoods.close();
    _parentShowBanner.close();
    _module.close();
  }
}
