import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/dao/wordDao.dart';
import 'package:flutter_start/models/UnitData.dart';
import 'package:flutter_start/models/index.dart';
import 'package:rxdart/rxdart.dart';

import 'BlocBase.dart';

class LearningEmotionBloc extends BlocBase{

  bool _requested = false;

  bool get requested => _requested;
  ///学习情况
  BehaviorSubject<StudyData> _studyData = BehaviorSubject<StudyData>();
  Sink<StudyData> get _studyDataSink => _studyData.sink;
  Stream<StudyData> get studyDataStream => _studyData.stream;
  ///最新作业
  BehaviorSubject<List<ParentHomeWork>> _parentHomeWork = BehaviorSubject<List<ParentHomeWork>>();
  Sink<List<ParentHomeWork>> get _parentHomeWorkSink => _parentHomeWork.sink;
  Stream<List<ParentHomeWork>> get parentHomeWorkStream => _parentHomeWork.stream;

  ///所有单元
  BehaviorSubject<List<UnitData>> _getSynerrData = BehaviorSubject<List<UnitData>>();
  Sink<List<UnitData>> get _allUnitSink => _getSynerrData.sink;
  Stream<List<UnitData>> get allUnitStream => _getSynerrData.stream;

  ///所有单元
  BehaviorSubject<bool>  _getStudymsgQues = BehaviorSubject<bool> ();
  Sink<bool> get _getStudymsgQuesSink => _getStudymsgQues.sink;
  Stream<bool> get getStudymsgQuesStream => _getStudymsgQues.stream;

  ///所有单元
  BehaviorSubject<dynamic>  _getHoweNum = BehaviorSubject<dynamic> ();
  Sink<dynamic> get _getHoweNumSink => _getHoweNum.sink;
  Stream<dynamic> get getHoweNumStream => _getHoweNum.stream;



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
      _parentHomeWorkSink.add(res.data);
    }
    await doNext(_parentHomeWorkSink,res);
    _requested = true;
    return;
  }
  ///获取所有单元
  void getSynerrData() async{
    var res = await WordDao.getSynerrData();
    if(null!=res && res.result){
      _allUnitSink.add(res.data);
    }
    await doNext(_allUnitSink,res);
    _requested = true;
    return;
  }
  //获取数据是否完成
  void getStudymsgQues() async{
    var res = await WordDao.getStudymsgQues();
    if(null!=res && res.result){
      _getStudymsgQuesSink.add(res.data);
    }
    await doNext(_getStudymsgQuesSink,res);
    _requested = true;
    return;
  }

  ///获取本学期未完成作业数量
  void getParentHomeWorkDataTotal() async{
    var res = await WordDao.getParentHomeWorkDataTotal();
    print('未完成未完成');
    print(res.data);
    if(null!=res && res.result){
      _getHoweNumSink.add(res.data);
    }
    await doNext(_getHoweNumSink,res);
    _requested = true;
    return;
  }

  void dispose(){
    _parentHomeWork.close();
    _studyData.close();
    _getSynerrData.close();
    _getStudymsgQues.close();
    _getHoweNum.close();
  }
}