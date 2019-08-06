import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/coachDao.dart';
import 'package:flutter_start/models/CoachNotice.dart';
import 'package:rxdart/rxdart.dart';
import 'BlocBase.dart';
class CoachBloc extends BlocBase{
  ///公告
  PublishSubject<List<CoachNotice>> _notice = PublishSubject<List<CoachNotice>>();
  Sink<List<CoachNotice>> get _noticSink => _notice.sink;
  Observable<List<CoachNotice>> get noticeStream => _notice.stream;

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

  void dispose(){
    print("CoachBloc dispose");
    _notice.close();
  }
}