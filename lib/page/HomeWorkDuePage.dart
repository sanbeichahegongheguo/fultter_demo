import 'dart:async';
import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_start/common/dao/wordDao.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';

class HomeWorkDuePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeWorkDuePage();
  }

}

class _HomeWorkDuePage extends State<HomeWorkDuePage>{
  List _wordList = [];//作业集合
  int _pageNum = 1;//页码数
  String _footMsg = "上拉加载更多！";
  @override
  initState(){
    print("进入往期作业");
    super.initState();
    _getParentHomeWorkDataList(_pageNum);
  }
    GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
    GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
    GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();

    // TODO: implement build
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("往期作业"),
          backgroundColor: Color(0xFFffffff),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0xFF333333),//自定义图标
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
            color: Color(0xFFf0f4f7),
            child: new EasyRefresh(
              key: _easyRefreshKey,
              refreshHeader: BezierCircleHeader(
                key: _headerKey,
                color: Colors.black12,
                backgroundColor: Color(0xFFf0f4f7),
              ),
              refreshFooter: BezierBounceFooter(
                key: _footerKey,
                color: Colors.black12,
                backgroundColor: Color(0xFFf0f4f7),
              ),
              child: new ListView.builder(
                  //ListView的Item
                    itemCount: _wordList.length+1,
                    padding: EdgeInsets.symmetric(horizontal:ScreenUtil.getInstance().getWidthPx(30)),
                    itemBuilder: (BuildContext context, int index) {

                      if(index != _wordList.length){
                        return  _getWordBodyMsg(index);
                      }else{
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(15)),
                          alignment: Alignment.center,
                          child: Text(_footMsg,style: TextStyle(color: Color(0xFF999999)),),
                        );
                      }

                      ;
                    }),
              onRefresh: () async {
                await new Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _pageNum = 1;
                    _footMsg = "上拉加载更多！";
                    _getParentHomeWorkDataList(_pageNum);
                  });
                });
              },
              loadMore: () async {
                await new Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _pageNum++;
                    _getParentHomeWorkDataList(_pageNum);
                  });
                });
              },
            )
          ),
        );

  }
  ///获取作业集合
  void _getParentHomeWorkDataList(pageNum)async{
    var res = await WordDao.getParentHomeWorkDataList(pageNum);
    if(res["success"]["ok"] == 0){
      setState(() {
        if(pageNum == 1){
          _wordList =  res["success"]["hwmeWorkList"];
          if(_wordList.length <5){
            _footMsg = "没有更多了";
          }
        }else{
          if(res["success"]["hwmeWorkList"] != null && res["success"]["hwmeWorkList"] != ""){
            _wordList.addAll(res["success"]["hwmeWorkList"]);
          }
          if(_pageNum-1 == res["success"]["maxPage"] ){
            _footMsg = "没有更多了";
            _pageNum = res["success"]["maxPage"];
          }
        }
        print("作业：${_wordList.length}    页码$_pageNum");
      });
    }
  }
  Widget _getWordBodyMsg(num){

      bool isT = _wordList[num]["isFinished"]=="T";//是否完成
      var _iconImg = isT? Container(
        child: Image.asset(_wordList[num]["isFinished"]=="T"?"images/study/icon-ok.png":"",width: ScreenUtil.getInstance().getHeightPx(120),height:ScreenUtil.getInstance().getHeightPx(120)),
        height: ScreenUtil.getInstance().getHeightPx(120),
        width: ScreenUtil.getInstance().getHeightPx(120),
      ):Text("");//显示图标
      int _hwType = _wordList[num]['hwType'];//作业类型
      String _startDate = _wordList[num]["startDate"];//作业时间
      var _hwContent = _wordList[num]["hwContent"];//作业内容
      String _state = "已完成";
      int acc = 0;
      var _stateColor = Color(0xFF5fc589);
      if(_hwType == 2){
        var _osHwJson =  jsonDecode(_hwContent);
        _hwContent = _osHwJson["ksLessonList"][0]["ksLessonName"];
      }
      if(_wordList[num]["extJson"] != null && _wordList[num]["extJson"] != ""&& _wordList[num]["extJson"] != "null"){
        isT = true;
        acc = jsonDecode(_wordList[num]["extJson"])["rate"];
        _state = isT ?"$acc%正确":"未完成";
        _stateColor = isT ? Color(0xFFffb236) : Color(0xFFfb6060);
      }else{
        _state = isT ?"已完成":"未完成";
        _stateColor = isT ? Color(0xFF5fc589) : Color(0xFFfb6060);
      }
      return   InkWell(
        onTap: _goParentInfo,
        child: Container(
          width: ScreenUtil.getInstance().getWidthPx(800),
          decoration:BoxDecoration(
            border: new Border.all(width: 1.0, color: Color(0xFFe5e5e5)),
            borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
          ),
          padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(15),horizontal:ScreenUtil.getInstance().getWidthPx(30)),
          margin:EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(30)),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                flex: 1,
                child:Container(
                  margin: EdgeInsets.only(bottom:ScreenUtil.getInstance().getHeightPx(80)),
                  alignment: Alignment.topLeft,
                  child: Image.asset("images/study/previous_icon.png",width: ScreenUtil.getInstance().getWidthPx(100),height:ScreenUtil.getInstance().getWidthPx(100)),
                ),
              ),
              Expanded(
                flex: 7,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text("[${_judgeWordType(_hwType)}]",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFF2dc1ae) ),),
                            Container(
                              padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(10),horizontal:ScreenUtil.getInstance().getWidthPx(15)),
                              margin: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(24) ),
                              decoration:BoxDecoration(
                                color: _stateColor,
                                borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
                              ),
                              child: Text(_state,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(26/3),color: Color(0xFFffffff) ),),
                            ),
                          ],
                        ),
                        Text(_startDate,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(32/3),color: Color(0xFF999999) ),),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(48),right:ScreenUtil.getInstance().getWidthPx(30),bottom:ScreenUtil.getInstance().getHeightPx(48)  ),
                            child: Text(_hwContent,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF333333) ),),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: _iconImg,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      );

  }
  _goParentInfo(){
    NavigatorUtil.goWebView(context,Address.getInfoPage(),router:"parentInfo").then((v){
    });
  }
  ///判断作业类型
  String _judgeWordType(int type){
    String data = "作业";
    switch (type){
      case 2:
        data = "口算作业";
        break;
      case 10:
        data = "笔头作业";
        break;
      case 11:
        data = "同步作业";
        break;
      case 13:
        data = "错题核对收录";
        break;
      case 14:
        data = "专项作业";
        break;
      case 15:
        data = "试卷错题收集";
        break;
    }
    return data;
  }

}