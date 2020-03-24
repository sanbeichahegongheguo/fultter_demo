import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/coachDao.dart';
import 'package:flutter_start/models/CoachNotice.dart';
import 'package:flutter_start/widget/courseCountDownWidget.dart';
import 'package:rxdart/rxdart.dart';
import 'BlocBase.dart';
class CoachBloc extends BlocBase{
  ///公告
  BehaviorSubject<List<CoachNotice>> _notice = BehaviorSubject<List<CoachNotice>>();
  Sink<List<CoachNotice>> get _noticSink => _notice.sink;
  Observable<List<CoachNotice>> get noticeStream => _notice.stream;

  ///获取可查看课程
  BehaviorSubject<String>  _getCoachNotice = BehaviorSubject<String> ();
  Sink<String> get _getCoachNoticeSink => _getCoachNotice.sink;
  Observable<String> get getCoachNoticeStream => _getCoachNotice.stream;

  ///倒计时
  BehaviorSubject<int>  _getCountdown = BehaviorSubject<int> ();
  Sink<int> get _getCountdownSink => _getCountdown.sink;
  Observable<int> get getCountdownStream => _getCountdown.stream;

  ///教辅专区广告
  BehaviorSubject<bool> _coachShowBanner = BehaviorSubject<bool>();
  Sink<bool> get _coachShowBannerSink => _coachShowBanner.sink;
  Observable<bool> get coachShowBannerStream => _coachShowBanner.stream;
  static bool _isBanner;

  ///获取可查看课程
  void getMainLastCourse() async{
    DataResult data =await CoachDao.getMainLastCourse();
    _getCoachNoticeSink.add(data.data);
//    setCourseCountDownWidget(null);
    await doNext(_getCoachNoticeSink,data);
    return;
  }

  void getCountdownSink(data){
    _getCountdownSink.add(data);
  }

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
//    _coachShowBannerSink.add(isShow);
    if (CoachBloc._isBanner == null || CoachBloc._isBanner != isShow){
      _coachShowBannerSink.add(isShow);
      CoachBloc._isBanner= isShow;
    }
  }

  void dispose(){
    print("CoachBloc dispose");
    _notice.close();
    _coachShowBanner.close();
    _getCoachNotice.close();
    _getCountdown.close();
  }
}