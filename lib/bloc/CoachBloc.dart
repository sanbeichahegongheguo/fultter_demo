import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/coachDao.dart';
import 'package:flutter_start/models/CoachNotice.dart';
import 'package:rxdart/rxdart.dart';
import 'BlocBase.dart';
class CoachBloc extends BlocBase{
  ///公告
  BehaviorSubject<List<CoachNotice>> _notice = BehaviorSubject<List<CoachNotice>>();
  Sink<List<CoachNotice>> get _noticSink => _notice.sink;
  Observable<List<CoachNotice>> get noticeStream => _notice.stream;

  ///教辅专区广告
  BehaviorSubject<bool> _coachShowBanner = BehaviorSubject<bool>();
  Sink<bool> get _coachShowBannerSink => _coachShowBanner.sink;
  Observable<bool> get coachShowBannerStream => _coachShowBanner.stream;
  static bool _isBanner;

  ///公告
  void getCoachNotice() async{
    DataResult data = await CoachDao.getNotice();
    if(null!=data && data.result){
      _noticSink.add(data.data);
    }else{
      ///请求失败
    }
    await doNext(_noticSink,data);
    return;
  }


  ///是否展示广告
  void showBanner(bool isShow) async{
    _coachShowBannerSink.add(isShow);
//    if (CoachBloc._isBanner == null || CoachBloc._isBanner != isShow){
//      _coachShowBannerSink.add(isShow);
//      CoachBloc._isBanner= isShow;
//    }
  }

  void dispose(){
    print("CoachBloc dispose");
    _notice.close();
    _coachShowBanner.close();
  }
}