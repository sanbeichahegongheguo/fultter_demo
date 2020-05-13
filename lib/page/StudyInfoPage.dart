import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/dao/wordDao.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:flutter_start/models/UnitData.dart';
import 'package:flutter_start/models/index.dart';
//新版学情
class StudyInfoPage extends StatefulWidget{
  static const String sName = "StudyInfoPage";
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StudyInfoPage();
  }

}

class _StudyInfoPage extends State<StudyInfoPage> with AutomaticKeepAliveClientMixin<StudyInfoPage>, SingleTickerProviderStateMixin{
  HomeBloc bloc;
  @override
  initState(){
    print("initState 新版学情");
    bloc =  BlocProvider.of<HomeBloc>(context);
    bloc.learningEmotionBloc.getStudyData();
    bloc.learningEmotionBloc.getNewHomeWork();
    bloc.learningEmotionBloc.getSynerrData();
    bloc.learningEmotionBloc.getStudymsgQues();
    bloc.learningEmotionBloc.getParentHomeWorkDataTotal();
    super.initState();
  }

  StudyData _studyMsg = new StudyData();//用户信息
  ///当前状态
  /// noErrorHomeWord 无错题有作业
  /// noErrorNoHomeWord 无错题无作业
  /// noHomeWord 有错题无作业
  /// homeWord 有错题有作业
  var _state = "homeWord";
  List<ParentHomeWork> _parentHomeWorkList  = new List<ParentHomeWork>();//用户作业
  String _homeWorkNum = "0";
  StudyData _studyData;
  int _errorNum = 0;
  List<UnitData> unitData = new  List<UnitData>();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('LearningEmotionPage build');
    return Container(
      color: Color(0xFFf0f4f7),
      child:
      StreamBuilder<StudyData>(
            stream: bloc.learningEmotionBloc.studyDataStream,
            builder: (context, AsyncSnapshot<StudyData> snapshot){
              if(null != snapshot.data){
                _studyData = snapshot.data;
              }
              return StreamBuilder(
                stream: bloc.learningEmotionBloc.getHoweNumStream,
                builder: (context,AsyncSnapshot<int> snapshot) {
                  _homeWorkNum = snapshot.data.toString();

                  return StreamBuilder(
                      stream: bloc.learningEmotionBloc.allUnitStream,
                      builder: (context,AsyncSnapshot<List<UnitData>> snapshot) {
                        if(snapshot.data != null){
                          unitData = snapshot.data;
                        }
                        _errorNum = unitData.length;
                        _setState();
                        return ListView(
                            children: <Widget>[
                              Column(
                                children: setWidgrtMsg(),
                              )
                            ]
                        );
                      }
                  ) ;
              }
            );
            },
      )
    );
  }

  _setState(){
    print("作业数=====>${_homeWorkNum.toString()}");
      var errorNum = _errorNum;
      var homeWordNum = _homeWorkNum.toString();
      /// noErrorHomeWord 无错题有作业
      /// noErrorNoHomeWord 无错题无作业
      /// noHomeWord 有错题无作业
      /// homeWord 有错题有作业
      if(errorNum == 0){
        if(homeWordNum == "0"){
          _state = "noErrorNoHomeWord";
        }else{
          _state = "noErrorHomeWord";
        }
      }else{
        if(homeWordNum == "0"){
          _state = "noHomeWord";
        }else{
          _state = "homeWord";
        }
      }

  }

  List<Widget> setWidgrtMsg(){
    ///更改字眼颜色
    var errorTextColor = Color(0xFF333333);

    //顶部两个按钮的数据
    var topBtns =[
      {
        "title":"完成作业",
        "text":"您还有作业没有完成哦~",
        "bg":"images/study/icon-homeword.png",
        "isRedDot":true,
        "redDotNum":_homeWorkNum == null?"0":_homeWorkNum,
        "fn":(){

          _goWord();
        }
      },
      {
        "title":"考前复习",
        "text":"巩固本学情知识点~",
        "bg":"images/study/icon-review.png",
        "isRedDot":false,
        "redDotNum":0,
        "fn":(){_goH5StudyInfo("testReview");}
      }
    ];

    ///顶部第一个月的数据
    var topOneMonth = {
      "title":"您还有作业还没完成哦~",
      "msg":"",
      "bg":"images/study/icon-homeword.png",
      "btn":"完成作业",
      "isRedDot":true,
      "redDotNum":_homeWorkNum == null?"0":_homeWorkNum,
      "fn":(){_goWord();}
    };

    List<Widget> _studerMsgList = [];
    switch(_state){
      case "noErrorHomeWord":
        print("无错题有作业");
        _studerMsgList.add(setTopBtn(topBtns));
        _studerMsgList.add(setTwoNoErrorMsg(errorTextColor));
        break;
      case "noErrorNoHomeWord":
        print("无错题无作业");
        topBtns = [
          {
            "title":"每日练习",
            "text":"学习提分好帮手",
            "bg":"images/study/icon-practice.png",
            "isRedDot":false,
            "redDotNum":0,
            "fn":(){
              ApplicationDao.trafficStatistic(483);
              _goH5StudyInfo("practice");
            }
          },
          {
            "title":"考前复习",
            "text":"巩固本学情知识点~",
            "bg":"images/study/icon-review.png",
            "isRedDot":false,
            "redDotNum":0,
            "fn":(){
              ApplicationDao.trafficStatistic(487);
              _goH5StudyInfo("testReview");
            }
          }
        ];
        _studerMsgList.add(setTopBtn(topBtns));
        _studerMsgList.add(setTwoNoErrorMsg(errorTextColor));
        break;
      case "noHomeWord":
        print("有错题无作业");
        topBtns = [
          {
            "title":"每日练习",
            "text":"学习提分好帮手",
            "bg":"images/study/icon-practice.png",
            "isRedDot":false,
            "redDotNum":0,
            "fn":(){
              ApplicationDao.trafficStatistic(483);
              _goH5StudyInfo("practice");
            }
          },
          {
            "title":"考前复习",
            "text":"巩固本学情知识点~",
            "bg":"images/study/icon-review.png",
            "isRedDot":false,
            "redDotNum":0,
            "fn":(){
              ApplicationDao.trafficStatistic(487);
              _goH5StudyInfo("testReview");
            }
          }
        ];
        _studerMsgList.add(setTopBtn(topBtns));
        _studerMsgList.add(setUnit(_state));
        break;
      case "homeWord":
        print("有错题有作业");
        _studerMsgList.add(setTopBtn(topBtns));
        _studerMsgList.add(setUnit(_state));
        break;
    }

    return _studerMsgList;
  }

  ///设置单元背景
  setBgStart(int num){
    var type = "";
    if(num == 0){
      type = "images/study/bg-excellent.png";
    }else if(num >= 1 && num<7){
      type = "images/study/bg-commonly.png";
    }else if(num >= 7){
      type = "images/study/bg-dangerous.png";
    }
    return type;
  }

  ///单元内容
  Widget setUnit(type){

    var unit_data = [
      {
        "startBg":"images/study/bg-commonly.png",
        "title":"第一单元",
        "testNum":"共1题",
      },
      {
        "startBg":"images/study/bg-commonly.png",
        "title":"第二单元",
        "testNum":"共99题",
      },
      {
        "startBg":"images/study/bg-dangerous.png",
        "title":"第三单元",
        "testNum":"共13题",
      }
    ];


    List<Widget> btnsWidgetList = [];

    var ctppBtn = Container(
      margin:EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(150)),
      child:MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        minWidth: ScreenUtil.getInstance().getWidthPx(760),
        color: Color(0xFF6ed699),
        height:ScreenUtil.getInstance().getHeightPx(139) ,
        onPressed: (){_goCtpp();},
        child: Text("孩子有错题？拍下来",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFffffff))),
      ),
    );
    ///高频易错题
    var errorBtn = getHigthErrorBtn();
    ///孩子有错
    var lintCttpBtn = Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(38)),
      width: ScreenUtil.getInstance().getWidthPx(760),
      height:ScreenUtil.getInstance().getHeightPx(139) ,
      decoration:BoxDecoration(
      ),
      child:OutlineButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50),),
        borderSide: BorderSide(color:  Color(0xFF6ed699),width: 2),
        onPressed: (){_goCtpp();},
        child: Text("孩子有错题？拍下来",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFF6ed699))),
      ),
    );

    if(type == "homeWord"){
      btnsWidgetList.add(Text("请进入有错题的单元完成练习，全部练习完以后请完成下面的高频易错题。",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: ScreenUtil.getInstance().getSp(48/3),
              color: Color(0xFF999999),
          )
      ));
      btnsWidgetList.add(errorBtn);
      btnsWidgetList.add(lintCttpBtn);
    }else if(type == "noHomeWord"){
      btnsWidgetList.add(
        Padding(
          padding: EdgeInsets.only(bottom: ScreenUtil.getInstance().getHeightPx(0)),
          child:Text("点击以上单元，开始练习！",
            style: TextStyle(
                fontSize: ScreenUtil.getInstance().getSp(48/3),
                color: Color(0xFF999999)
            )
        ) ,)

      );
      btnsWidgetList.add(errorBtn);
      btnsWidgetList.add(lintCttpBtn);
    }
    List<Widget> unitWidgetList = [];
    for(var i = 0;i<unitData.length;i++){
      unitWidgetList.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Image.asset(setBgStart(unitData[i].notIdsCount),fit: BoxFit.cover,height:ScreenUtil.getInstance().getHeightPx(159) ,),
                Container(
                  padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(48)),
                  child: Column(
                    children: <Widget>[
                      Text(unitData[i].racSyntestName,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(56/3),color: Color(0xFF333333),fontWeight: FontWeight.bold)),
                      Padding(
                        padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(36)),
                        child: Text("共${unitData[i].notIdsCount.toString()}题",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFFff7156)),textAlign: TextAlign.left,),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(48)),
              width: ScreenUtil.getInstance().getWidthPx(205),
              height:ScreenUtil.getInstance().getHeightPx(84) ,
              decoration:BoxDecoration(
              ),
              child:OutlineButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50),),
                borderSide: BorderSide(color:  Color(0xFF6ed699),width: 2),
                onPressed: (){_goH5StudyInfo("aUnit?unit=${Uri.encodeComponent(unitData[i].racSyntestName)}&racSyntestId=${unitData[i].racSyntestId}");},
                child: Text("前往",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFF6ed699))),
              ),
            )
          ],
        ),
      );

      if(i != unitData.length-1){
        unitWidgetList.add(
            Container(
              color: Color(0xFFf1f2f6),
              margin:EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(20),bottom: ScreenUtil.getInstance().getHeightPx(20)),
              height: ScreenUtil.getInstance().getHeightPx(5),
            )
        );
      }
    }
    var unitColumn = new Column(children:unitWidgetList);

    var unit = Container(
      margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(35),bottom: ScreenUtil.getInstance().getHeightPx(59)),
      width: ScreenUtil.getInstance().getWidthPx(980),
      padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(30),horizontal:ScreenUtil.getInstance().getWidthPx(54)),
      decoration:BoxDecoration(
        borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
        color:Color(0xFFffffff),
      ),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("掌握得不好的单元有：",
                  style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(48/3),
                    color: Color(0xFF666666)
                )
              ),
              InkWell(
                onTap: (){_goH5StudyInfo("allUnit");},
                child: Text("所有单元 >",
                    style: TextStyle(
                        fontSize: ScreenUtil.getInstance().getSp(42/3),
                        color: Color(0xFF333333)
                    )
                ),
              ),
            ],
          ),
          Container(
            padding:EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(49),bottom: ScreenUtil.getInstance().getHeightPx(49)) ,
            child:unitColumn,
          ),
          Column(
            children: btnsWidgetList,
          )
        ],
      ),
    );
    return unit;
  }

  ///有作业顶部状态
  Widget setTopHomeWork(data){
    var homworkWidget = new Container(
      padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(20),horizontal:ScreenUtil.getInstance().getWidthPx(54)),
      margin:EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(35)) ,
      alignment:Alignment.topLeft,
      decoration:BoxDecoration(
        borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
        color:Color(0xFFffffff),
        image: new DecorationImage(
            image: new AssetImage(data["bg"]),
            alignment:Alignment.bottomRight,
        ),
      ),
      width: ScreenUtil.getInstance().getWidthPx(980),
      child: Column(
        mainAxisAlignment:MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child:Text(data["title"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(54/3),
                      color: Color(0xFF333333),
                      fontWeight:FontWeight.bold,
                    )
                ),
                margin:EdgeInsets.only(bottom:ScreenUtil.getInstance().getHeightPx(30)) ,
              ),
              Container(
                child:Text(data["msg"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(42/3),
                      color: Color(0xFF999999),
                    )
                ),
                margin:EdgeInsets.only(bottom:ScreenUtil.getInstance().getHeightPx(30),left:ScreenUtil.getInstance().getWidthPx(10) ) ,
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
              child: Stack(
                overflow:Overflow.visible,
                children: <Widget>[
                  Container(
                    height:ScreenUtil.getInstance().getHeightPx(81) ,
                    width: ScreenUtil.getInstance().getWidthPx(315),
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                      gradient: LinearGradient(colors: <Color>[
                        Color(0xFFffc23d),
                        Color(0xFFfdd452),
                        Color(0xFFfbe365),
                      ]),
                    ),
                    alignment: Alignment.center,
                    child:MaterialButton(
                      onPressed: data["fn"],
                      child: Text(data["btn"],style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFFc54222))),
                    ) ,
                  ),
                  data['isRedDot']? Positioned(
                    top: -2,
                    right: 0,
                    child: Container(
                      width: ScreenUtil.getInstance().getWidthPx(42),
                      height: ScreenUtil.getInstance().getWidthPx(42),
                      decoration:BoxDecoration(
                        borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                        color:Color(0xFFff542b),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(data['redDotNum'].toString(),textAlign: TextAlign.center,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(36/3),color: Color(0xFFffffff)))
                        ],
                      ),
                    ),
                  ):Text(""),
                ],
              )
          ),

        ],
      ),

    );
    return homworkWidget;
  }

  ///顶部两个按钮状态
  Widget setTopBtn(topBtns){
    List<Widget> rowStack = [];
    for(var i = 0; i <topBtns.length;i++){
      Widget redDot = Text("");
      if(topBtns[i]["isRedDot"]){
        redDot = Positioned(
          top: -10,
          right: 0,
          child: Container(
            width: ScreenUtil.getInstance().getWidthPx(60),
            height: ScreenUtil.getInstance().getWidthPx(60),
            decoration:BoxDecoration(
              borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
              color:Color(0xFFff542b),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(topBtns[i]["redDotNum"].toString(),textAlign: TextAlign.center,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFFffffff)))
              ],
            ),
          ),
        );
      }
      rowStack.add(
          InkWell(
            onTap:topBtns[i]["fn"],
            child: Stack(
          overflow:Overflow.visible,
          children: <Widget>[
            Container(
              width: ScreenUtil.getInstance().getWidthPx(478),
              height: ScreenUtil.getInstance().getHeightPx(205),
              decoration:BoxDecoration(
                  borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
                  color:Color(0xFFffffff),
                  image: new DecorationImage(
                    image: new AssetImage(topBtns[i]["bg"]),
                    alignment:Alignment.bottomRight,
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(30),left: ScreenUtil.getInstance().getWidthPx(30) ),
                    child: Align(alignment:Alignment.centerLeft,child: Text(topBtns[i]["title"],style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(56/3), color: Color(0xFF333333),fontWeight:FontWeight.bold, )),),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(30),left: ScreenUtil.getInstance().getWidthPx(30) ),
                    child: Align(alignment:Alignment.centerLeft,child: Text(topBtns[i]["text"],style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(36/3), color: Color(0xFFb9b8b8))),),
                  )
                ],
              ),
            ),
            redDot
          ],
        ),
          ),
      );
    }

    var btns = new Container(
      margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(35)),
      width: ScreenUtil.getInstance().getWidthPx(980),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: rowStack,
      ),
    );
    return btns;
  }

  ///错题数据第二种页面
  Widget setTwoNoErrorMsg(textColor){
    ///页面数据
    var noHomworkWidget = new Container(
      margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(35),bottom: ScreenUtil.getInstance().getHeightPx(59)),
      width: ScreenUtil.getInstance().getWidthPx(980),
      decoration:BoxDecoration(
        borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
        color:Color(0xFFffffff),
      ),
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(72),horizontal:ScreenUtil.getInstance().getWidthPx(54)),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(10),),
                    child: Text.rich(TextSpan(
                        children:[
                          TextSpan(
                              text:"孩子还没有错题记录，",
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().getSp(56/3),
                                  color: Color(0xFF333333)
                              )
                          ),
                        ]
                    )),
                  ),
                  Text.rich(TextSpan(
                      children:[
                        TextSpan(
                            text:"请让TA先完成高频易错题！",
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().getSp(56/3),
                                color: Color(0xFF333333)
                            )
                        ),
                      ]
                  )),
                ],
              )
          ),
          Padding(
            padding:EdgeInsets.only(bottom:ScreenUtil.getInstance().getHeightPx(150),top:ScreenUtil.getInstance().getHeightPx(40)  ),
            child:Image.asset("images/study/img-q.png",fit: BoxFit.cover,height:ScreenUtil.getInstance().getHeightPx(332) ,),
          ),
          getHigthErrorBtn(),
          Container(
            margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(58)),
            width: ScreenUtil.getInstance().getWidthPx(760),
            height:ScreenUtil.getInstance().getHeightPx(139) ,
            decoration:BoxDecoration(
            ),
            child:OutlineButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50),),
              borderSide: BorderSide(color:  Color(0xFF6ed699),width: 2),
              onPressed: (){_goCtpp();},
              child: Text("孩子有错题？拍下来",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFF6ed699))),
            ),
          )
        ],
      ),
    );
    return noHomworkWidget;
  }
  ///获取一个高频易错题
  getHigthErrorBtn(){
    var _w = StreamBuilder<bool>(
      stream: bloc.learningEmotionBloc.getStudymsgQuesStream,
      builder: (context, AsyncSnapshot<bool> snapshot){
        var model = false;
        Positioned imgPositioned = Positioned(
          top: ScreenUtil.getInstance().getHeightPx(-76),
          right: ScreenUtil.getInstance().getWidthPx(0),
          child: Image.asset("images/study/icon-ok-2.png",fit: BoxFit.cover,height:ScreenUtil.getInstance().getHeightPx(158) ,),
        );
        if (snapshot.data!=null){
           model = snapshot.data;
        };
        return Container(
          padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(80)  ),
          child: Stack(
            overflow:Overflow.visible,
            children: <Widget>[
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                minWidth: ScreenUtil.getInstance().getWidthPx(760),
                color: Color(0xFF6ed699),
                height:ScreenUtil.getInstance().getHeightPx(139) ,
                onPressed: (){ApplicationDao.trafficStatistic(484);_goH5StudyInfo("easyCuot");},
                child: Text("高频易错题",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFffffff))),
              ),
              Positioned(
                top: ScreenUtil.getInstance().getHeightPx(-56),
                left: ScreenUtil.getInstance().getWidthPx(-53),
                child: Container(
                  width: ScreenUtil.getInstance().getWidthPx(251),
                  height: ScreenUtil.getInstance().getHeightPx(87),
                  decoration: BoxDecoration(
                    color: Color(0xFFff542b),
                    borderRadius:BorderRadius.only(topLeft:Radius.circular(50),topRight:Radius.circular(50),bottomLeft:Radius.circular(50),bottomRight:Radius.circular(0)),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("逢周一更新",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(36/3),color: Color(0xFFffffff))),
                  ),
                ),
              ),
              model ?imgPositioned:Text("")
            ],
          ),
        );
      },
    );
    return _w;
  }
  ///去小状元家长介绍
  _goParentInfo(where){
    if(where=='randWork'){
      ApplicationDao.trafficStatistic(302);
    }else if(where=='finishWork'){
      ApplicationDao.trafficStatistic(301);
    }
    NavigatorUtil.goWebView(context,AddressUtil.getInstance().getInfoPage(),router:"parentInfo");
  }
  ///去h5学情
  _goH5StudyInfo(router){
    NavigatorUtil.goWebView(context,AddressUtil.getInstance().goH5StudyInfo(),router:router).then((v){
      bloc.learningEmotionBloc.getStudyData();
      bloc.learningEmotionBloc.getNewHomeWork();
      bloc.learningEmotionBloc.getSynerrData();
      bloc.learningEmotionBloc.getStudymsgQues();
    });
  }
  ///去错题拍拍
  _goCtpp(){
    ApplicationDao.trafficStatistic(305);
    NavigatorUtil.goWebView(context,AddressUtil.getInstance().goCtpp());
  }
  ///去往期作业
  _goWord(){
    ApplicationDao.trafficStatistic(489);
    NavigatorUtil.goWebView(context,AddressUtil.getInstance().goH5StudyInfo(),router:"allHomeword");
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}