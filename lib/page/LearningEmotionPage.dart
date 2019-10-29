import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/dao/wordDao.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:flutter_start/models/index.dart';

///学情页面
class LearningEmotionPage extends StatefulWidget{
  static const String sName = "learningEmotion";
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LearningEmotionPage();
  }

}

class _LearningEmotionPage extends State<LearningEmotionPage> with AutomaticKeepAliveClientMixin<LearningEmotionPage>, SingleTickerProviderStateMixin{
  HomeBloc bloc;
  @override
  initState(){
    print("initState 学情");
    bloc =  BlocProvider.of<HomeBloc>(context);
    bloc.learningEmotionBloc.getStudyData();
    bloc.learningEmotionBloc.getNewHomeWork();
    bloc.xqModuleBloc.getLEmotionModule();
    super.initState();
  }

  var _learninText = "  同学学习情况如下：";

  StudyData _studyMsg = new StudyData();//用户信息

  List<ParentHomeWork> _parentHomeWorkList  = new List<ParentHomeWork>();//用户作业

  int _studyIndex = 1;//判断内容加载


  @override
  Widget build(BuildContext context) {
      super.build(context);
      print('LearningEmotionPage build');
      return Container(
        color: Color(0xFFf0f4f7),
        child: ListView(
          children: <Widget>[
            StreamBuilder<StudyData>(
              stream: bloc.learningEmotionBloc.studyDataStream,
              builder: (context, AsyncSnapshot<StudyData> snapshot){
                StudyData model = snapshot.data;
                return StreamBuilder<List<ParentHomeWork>>(
                    stream: bloc.learningEmotionBloc.parentHomeWorkStream,
                    builder: (context, AsyncSnapshot<List<ParentHomeWork>> snapshot){
                      _parentHomeWorkList = snapshot.data;
                      return Container(
                        color: Colors.white,
                        width:MediaQuery.of(context).size.width,
                        child: _studymsg(model),
                      );
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(54)),
                  width: ScreenUtil.getInstance().getWidthPx(980),
                  child: StreamBuilder<List<Module>>(
                      stream: bloc.xqModuleBloc.moduleStream,
                      builder: (context, AsyncSnapshot<List<Module>> snapshot){
                        return  _footBt(snapshot.data);
                      }),
                ),
              ],
            )
          ],
        ),
      );
  }

  Widget _studymsg(StudyData studyData){
    if(studyData==null){
      return null;
    }
    _studyMsg = studyData;
    bool isStudy = true;
    bool isWork = false;
    if(_studyMsg.cttotal == "0" && _studyMsg.questotal == "0" && _studyMsg.studyTotaltime == ""){
      isStudy = false;
    }
    if(null==_parentHomeWorkList||_parentHomeWorkList.length == 0){
      isWork = true;
    }
    if(isWork && !isStudy){
      //无最新作业和学习记录信息
      return _notWordStudy();
    }else{
      return _wordStudy(isStudy ,isWork);
    }
  }
  //无最新作业和学习记录
  Widget _notWordStudy(){
    var noStudyMsg = Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(172),bottom:ScreenUtil.getInstance().getHeightPx(157) ),
          child: Column(
            children: <Widget>[
              Text("您的孩子还没有",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFF333333)),),
              Text("任何学习记录和作业通知！",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFF333333))),
            ],
          ),
        ),
        Image.asset("images/study/img-q.png",fit: BoxFit.cover,height:ScreenUtil.getInstance().getHeightPx(332) ,),
        Container(
          padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(82),bottom:ScreenUtil.getInstance().getHeightPx(50) ),
          child: Text("去“远大小状元学生”做练习吧！",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(36/3),color: Color(0xFFafafaf))),
        ),
        Container(
          padding: EdgeInsets.only(bottom:ScreenUtil.getInstance().getHeightPx(117) ),
          child:  MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                onPressed: (){_goParentInfo('openStudent');},
                minWidth: ScreenUtil.getInstance().getWidthPx(845),
                height:ScreenUtil.getInstance().getHeightPx(133),
                color: Color(0xFFfc6061),
                child:Text("打开“远大小状元学生”",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Colors.white ),),
              ),
        ),
      ],
    );
    return noStudyMsg;
  }

  //有最新作业和记录
  Widget _wordStudy(isStudy ,isWork){
    var msg = Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(36),horizontal:ScreenUtil.getInstance().getWidthPx(58)),
          margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(35),bottom: ScreenUtil.getInstance().getHeightPx(59)),
          width: ScreenUtil.getInstance().getWidthPx(980),
          decoration:BoxDecoration(
            border: new Border.all(width: 1.0, color: Color(0xFFe5e5e5)),
            borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
          ),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: SpUtil.getObject(Config.LOGIN_USER)["realName"],
                        style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: ScreenUtil.getInstance().getSp(48/3)
                        ),
                      ),
                      TextSpan(
                        text: _learninText,
                        style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: ScreenUtil.getInstance().getSp(36/3)
                        ),
                      ),
                    ]
                )),
              ),
              Container(
                padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(77),bottom: ScreenUtil.getInstance().getHeightPx(10)),
                child: _learnMsg(isStudy),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal:ScreenUtil.getInstance().getWidthPx(58)),
          margin:EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(30)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width:ScreenUtil.getInstance().getWidthPx(12),
                    height: ScreenUtil.getInstance().getHeightPx(46),
                    decoration:BoxDecoration(
                      borderRadius: new BorderRadius.all(
                          Radius.circular((30.0))),
                      color: Color(0xFF5fc589),
                    ),
                  ),
                  Text("  最新作业",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3) ),)
                ],
              ),


              InkWell(
                onTap: _goWord,
                child:Text("往期作业》",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(36/3),color: Color(0xFF999999)),),
              )
            ],
          ),
        ),
         _wordMsg(_parentHomeWorkList),
      ],
    );
    return msg;
  }
  List btList = [
    {"imgUrl":"images/study/icon-look-que.png","id":1,"title":"查看错题"},
    {"imgUrl":"images/study/icon-beat-que.png","id":1,"title":"错题拍拍"},
  ];

  Widget _footBt(List<Module> data){
    List<Widget> btListMsg = [];
    if(null!=data){
      for(var i = 0;i<data.length;i++){
        btListMsg.add(
            Container(
              width: ScreenUtil.getInstance().getWidthPx(450),
              decoration:BoxDecoration(
                border: new Border.all(width: 1.0, color: Color(0xFFe5e5e5)),
                borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
              ),
              child:MaterialButton(
                elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minWidth: ScreenUtil.getInstance().getWidthPx(450),
                  color: Color(0xFFffffff),
                  height:ScreenUtil.getInstance().getHeightPx(215) ,
                  onPressed: (){
                    if(data[i].eventId!=0){
                      ApplicationDao.trafficStatistic(data[i].eventId);
                    }
                    NavigatorUtil.goWebView(context,data[i].targetUrl).then((v){});
                  },
                  child: Row(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl:data[i].iconUrl,
                          height:ScreenUtil.getInstance().getHeightPx(100),
                          fit: BoxFit.fitWidth,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(36)),
                          child:
                          Text(data[i].name, style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF333333) ),),),
                      ],
                    ),
                ),
            )
        );
      }
    }
    var btmsg =Wrap(
      runSpacing: ScreenUtil.getInstance().getHeightPx(27), // 纵轴（垂直）方向间距
      runAlignment:WrapAlignment.center,
      alignment:WrapAlignment.spaceBetween,
      children: btListMsg,
    );
    return btmsg;
  }


  //作业内容
  _wordMsg(data){
    List<Widget> msgList = [];
    var msg;
    if(null!=data && data.length >0){
      var last = data.length==1?1:2;
      for(var i = 0;i<last;i++){
        msgList.add(
          InkWell(
            onTap: (){_goParentInfo('randWork');},
            child:Container(
            width: ScreenUtil.getInstance().getWidthPx(980),
            decoration:BoxDecoration(
              border: new Border.all(width: 1.0, color: Color(0xFFe5e5e5)),
              borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
            ),
            padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(15),horizontal:ScreenUtil.getInstance().getWidthPx(58)),
            margin:EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(30)),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(14),horizontal:ScreenUtil.getInstance().getWidthPx(15)),
                      margin: EdgeInsets.only(right:ScreenUtil.getInstance().getWidthPx(24) ),
                      decoration:BoxDecoration(
                        color: Color(0xFF5fc589),
                        borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      child: Text(_judgeWordType(_parentHomeWorkList[i].hwType),style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(36/3),color: Color(0xFFffffff) ),),
                    ),
                    Text(_setTime(_parentHomeWorkList[i].time),style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(32/3),color: Color(0xFF999999) ),),
                  ],
                ),
                Container(
                  width: ScreenUtil.getInstance().getWidthPx(970),
                  height: ScreenUtil.getInstance().getHeightPx(2),
                  color: Color(0xFFf4f4f4),
                  margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(18) ),
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(48),right:ScreenUtil.getInstance().getWidthPx(30),bottom:ScreenUtil.getInstance().getHeightPx(48)  ),
                        child: Text(_parentHomeWorkList[i].content,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF333333) ),),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Image.asset(_parentHomeWorkList[i].state==1?"images/study/icon-ok.png":"images/study/icon-no.png",width: ScreenUtil.getInstance().getHeightPx(120),height:ScreenUtil.getInstance().getHeightPx(120)),
                        height: ScreenUtil.getInstance().getHeightPx(120),
                        width: ScreenUtil.getInstance().getHeightPx(120),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          )
        );
      }
      msgList.add(
        Container(
          margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(58)),
          child: MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              minWidth: ScreenUtil.getInstance().getWidthPx(515),
              color: Color(0xFFfbd953),
              height:ScreenUtil.getInstance().getHeightPx(139) ,
              onPressed: (){_goParentInfo('finishWork');},
              child: Text("完成作业",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFa83530))),
            ),
        )
      );
      msg = Container(
        child: Column(
          children: msgList,
        ),
      );
    }else{
      msg = Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(90),bottom: ScreenUtil.getInstance().getHeightPx(33)),
              child: Image.asset("images/study/img-q.png",fit: BoxFit.cover,height:ScreenUtil.getInstance().getHeightPx(332) ,),
            ),
            Text("最近两周老师无最新作业！",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF999999)),),
            Container(
              margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(58)),
              child:MaterialButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  minWidth: ScreenUtil.getInstance().getWidthPx(515),
                  color: Color(0xFF6ed699),
                  height:ScreenUtil.getInstance().getHeightPx(139) ,
                  onPressed: (){_goParentInfo('mineExercise');},
                  child: Text("自主练习",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFffffff))),
              ),
            ),

          ],
        ),
      );
    }
    return msg;
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
  ///处理时间格式
  String _setTime(String timeData){
    print(timeData);
    print("DateTime${DateUtil.getDateStrByMs(36)}");
    var time  = DateUtil.formatDate(DateTime.parse(timeData),format:DataFormats.zh_y_mo_d);
    return time;
  }
  //学习记录内容
  _learnMsg(isStudy){
    var msg;
    if(isStudy){
      _learninText = " 同学学习情况如下：";
      msg = Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text(_studyMsg.questotal+"",style: TextStyle(color: Color(0xFF333333), fontSize: ScreenUtil.getInstance().getSp(54/3)),),
                Container(
                  margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("本学期做题",style: TextStyle(color: Color(0xFF999999), fontSize: ScreenUtil.getInstance().getSp(36/3)),),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text(_studyMsg.cttotal+"",style: TextStyle(color: Color(0xFF333333), fontSize: ScreenUtil.getInstance().getSp(54/3)),),
                Container(
                  margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(15)),
                  decoration:BoxDecoration(
                      border: new Border(left: BorderSide(width: 1.0, color: Color(0xFFe5e5e5)),right:  BorderSide(width: 1.0, color: Color(0xFFe5e5e5)))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("本学期错题",style: TextStyle(color: Color(0xFF999999), fontSize: ScreenUtil.getInstance().getSp(36/3)),),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text(getTimeStrBySecond(_studyMsg.studyTotaltime != ""?_studyMsg.studyTotaltime:"0"),style: TextStyle(color: Color(0xFF333333), fontSize: ScreenUtil.getInstance().getSp(54/3)),),
                Container(
                  margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("今日学习耗时",style: TextStyle(color: Color(0xFF999999), fontSize: ScreenUtil.getInstance().getSp(36/3)),),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }else{
      _learninText = " 同学尚无学习记录!";
      msg = Container(
        child:MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            minWidth: ScreenUtil.getInstance().getWidthPx(515),
            color: Color(0xFF6ed699),
            height:ScreenUtil.getInstance().getHeightPx(139) ,
            onPressed: (){},
            child: Text("自主练习",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFffffff))),
          ),
      );
    }
   return msg;
  }
  ///处理时间
  String getTimeStrBySecond(String secondTime) {
    var second = int.parse(secondTime);
    var time = DateUtil.formatDate(DateTime(0, 0, 0, 0, second, 0),format:DataFormats.h_m);
    return time;
  }

  ///去小状元家长介绍
  _goParentInfo(where){
    if(where=='randWork'){
      ApplicationDao.trafficStatistic(302);
    }else if(where=='finishWork'){
      ApplicationDao.trafficStatistic(301);
    }
    NavigatorUtil.goWebView(context,Address.getInfoPage(),router:"parentInfo");
  }
  ///去往期作业
  _goWord(){
    ApplicationDao.trafficStatistic(303);
    NavigatorUtil.goHomeWorkDuePage(context);
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }
}