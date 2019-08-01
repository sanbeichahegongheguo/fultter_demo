import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/dao/wordDao.dart';
import 'package:flutter_start/models/index.dart';
import 'package:rxdart/rxdart.dart';

import 'BlocBase.dart';

class LearningEmotionBloc extends BlocBase{

  bool _requested = false;

  bool get requested => _requested;
  ///学习情况
  PublishSubject<StudyData> _studyData = PublishSubject<StudyData>();
  Sink<StudyData> get _studyDataSink => _studyData.sink;
  Observable<StudyData> get studyDataStream => _studyData.stream;
  ///最新作业
  PublishSubject<List<ParentHomeWork>> _parentHomeWork = PublishSubject<List<ParentHomeWork>>();
  Sink<List<ParentHomeWork>> get _parentHomeWorkSink => _parentHomeWork.sink;
  Observable<List<ParentHomeWork>> get parentHomeWorkStream => _parentHomeWork.stream;

  ///获取学生本学期做题数和错题数及当天学习时间
  Future<void> getStudyData() async {
    var res = await WordDao.getStudyData();
    if(null!=res && res.result){
      _studyDataSink.add(res.data);
    }
    await doNext(_studyDataSink,res);
    _requested = true;
    return;
  }

  ///获取学生本学期做题数和错题数及当天学习时间
  void getNewHomeWork() async{
    var res = await WordDao.getNewHomeWork();
    if(null!=res && res.result){
      print("11  ${res.data}");
      _parentHomeWorkSink.add(res.data);
    }
    await doNext(_parentHomeWorkSink,res);
    _requested = true;
    return;
  }


  void dispose(){
    _parentHomeWork.close();
    _studyData.close();
  }
}