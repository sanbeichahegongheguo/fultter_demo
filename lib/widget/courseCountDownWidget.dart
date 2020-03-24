import 'dart:async';
import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';

class CourseCountDownWidget extends StatefulWidget {
   CourseCountDownWidget({
    Key key,
     @required this.countdown,
    @required this.productId,
    @required this.courseallotId,
    @required this.courseStatus,
  }) : super(key: key);
   final int countdown;
  final int productId;
  final int courseallotId;
  final String courseStatus;
  @override
  State<StatefulWidget> createState() {
    return _CourseCountDownWidget(countdown,productId,courseallotId,courseStatus);
  }
}

class _CourseCountDownWidget extends State<CourseCountDownWidget> {
  _CourseCountDownWidget(this._countdown,this._productId,this._courseallotId,this._courseStatus
      ) : super();
  String _hour = "00";//时
  String _minute = "00";//分
  String _second = "00";//秒
  static Timer _timer;//计时器
  int _countdown;
  int _productId;
  int _courseallotId;
  String _courseStatus;
  bool _isTimer = true;
  String _start;//"T":正在上课 "F":未上课 "O":进入课堂
  HomeBloc bloc;
  @override
  void initState() {
    bloc =  BlocProvider.of<HomeBloc>(context);
    _start  = _courseStatus;
    super.initState();
  }

  void dispose() {
    super.dispose();
    cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    if(_isTimer && _start !="O"){
      _countDown();
    }


    // TODO: implement build
    return StreamBuilder<int>(
        stream: bloc.coachBloc.getCountdownStream,
        builder: (context, AsyncSnapshot<int> snapshot){
          if(snapshot.data != null){
            _countdown = snapshot.data;
          }
          return  new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _getDownView(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        left:ScreenUtil.getInstance().getWidthPx(406)
                    ),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      color: _start != "F" ?Color(0xFFfd716b):Color(0xFFa7a3a3),
                      padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getWidthPx(26),horizontal:ScreenUtil.getInstance().getWidthPx(52) ),
                      onPressed: (){_goBroadcastHor(_productId,_courseallotId);},
                      child: Text(_getName(_start),style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFFffffff))),
                    ),
                  ),
                ],
              )
            ],
          ) ;
        });


  }
  _getDownView(){
    var view = Container(
      child: Row(
        children: <Widget>[
          Text("离开课还有", style: TextStyle(
            fontSize: ScreenUtil.getInstance().getSp(36/3),
            color: Color(0xFF999999),
          )),
          Container(
            decoration:new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                color:Color(0xFFf2f2f2)
            ),
            padding: EdgeInsets.all(ScreenUtil.getInstance().getWidthPx(10)),
            child: Text(_hour),
          ),
          Text("：", style: TextStyle(
            fontSize: ScreenUtil.getInstance().getSp(36/3),
            color: Color(0xFF999999),
          )),
          Container(
            decoration:new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                color:Color(0xFFf2f2f2)
            ),
            padding: EdgeInsets.all(ScreenUtil.getInstance().getWidthPx(10)),
            child: Text(_minute),
          ),
          Text("：", style: TextStyle(
            fontSize: ScreenUtil.getInstance().getSp(36/3),
            color: Color(0xFF999999),
          )),
          Container(
            decoration:new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                color:Color(0xFFf2f2f2)
            ),
            padding: EdgeInsets.all(ScreenUtil.getInstance().getWidthPx(10)),
            child: Text(_second),
          )
        ],
      ),
    );
    if(_start == "O"){
      view = Container(
        child: Row(
          children: <Widget>[
            Text("课程正在上课中", style: TextStyle(
              fontSize: ScreenUtil.getInstance().getSp(36/3),
              color: Color(0xFF999999),
            )),
          ],
        ),
      );
    }else{

    }
    return view;
  }
  _getName(data){
    var name = "";
    switch(data){
      case "O":
        name = "正在上课";
        break;
      case "T":
        name = "进入课堂";
        break;
      case "F":
        name = "即将上课";
        break;
    }
    return name;
  }
  //跳转到课程中心
  _goBroadcastHor(productId,courseallotId){
    ApplicationDao.trafficStatistic(547);
    NavigatorUtil.goWebView(
        context,Address.goBroadcastHor()+
        "?productId="+productId.toString()+
        "&courseallotId="+courseallotId.toString()+
        "&:ROTATE"
    ).then((v){
      bloc.coachBloc.getMainLastCourse();
    });
  }
  ///倒计时
  _countDown(){
    _isTimer = false;
    _timer =  new Timer.periodic(new Duration(seconds: 1), (timer) {
        _countdown--;
        bloc.coachBloc.getCountdownSink(_countdown);
        if(_countdown <= 0){
          _start = "O";
          _second = "00";
          _minute = "00";
          _hour = "00";
          cancelTimer();
          return;
        }
        var c =  _countdown*1000;
        var d = int.parse((c/1000/60/60/24).floor().toString());
        var h = int.parse((c/1000 / 60 / 60 - (24 * d)).toInt().toString());
        var m = int.parse((c/1000 / 60 - (24 * 60 * d) - (60 * h)).toInt().toString());
        var s = int.parse((c/1000 - (24 * 60 * 60 * d) - (60 * 60 * h) - (60 * m)).toInt().toString());

        if(c <= 10*60*1000){
          _start = "T";
        }

        if(h<10){
          _hour = "0" + h.toString();
        }else{
          _hour = h.toString();
        }
        if(m<10){
          _minute = "0" + m.toString();
        }else{
          _minute = m.toString();
        }
        if(s<10){
          _second = "0" + s.toString();
        }else{
          _second = s.toString();
        }
        print(_countdown);
      });
  }
  ///清除计时器
  static cancelTimer() {
    _timer?.cancel();
  }
}