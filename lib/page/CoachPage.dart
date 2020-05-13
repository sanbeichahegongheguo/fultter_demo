import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/bloc/AdBloc.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/BannerUtil.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/Adver.dart';
import 'package:flutter_start/models/CoachNotice.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:flutter_start/widget/courseCountDownWidget.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:redux/redux.dart';

///辅导页面
class CoachPage extends StatefulWidget{
  static const String sName = "coach";
  @override
  State<CoachPage> createState() {
    // TODO: implement createState
    return _CoachPage();
  }

}




class _CoachPage extends State<CoachPage> with AutomaticKeepAliveClientMixin<CoachPage>, SingleTickerProviderStateMixin{
   HomeBloc bloc;



  @override
  void initState() {
//    ApplicationDao.trafficStatistic(1);
    bloc =  BlocProvider.of<HomeBloc>(context);
    bloc.coachBloc.getMainLastCourse();
    bloc.moduleBloc.getCoachXZYModule();
    bloc.jzModuleBloc.getCoachJZModule();
    bloc.coachBloc.getCoachNotice();
    bloc.adBloc.getBanner();
    if(Platform.isIOS){
      bloc.coachBloc.showBanner(true);

    }
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Store<GSYState> store = StoreProvider.of(context);
    print("CoachPage build");
    return Container(
          color: Color(0xFFf0f4f7),
          child: ListView(
            children: <Widget>[
              Container(
                width:MediaQuery.of(context).size.width,
                height:ScreenUtil.getInstance().getHeightPx(311),
                child: StreamBuilder<List<CoachNotice>>(
                    stream: bloc.coachBloc.noticeStream,
                    builder: (context, AsyncSnapshot<List<CoachNotice>> snapshot){
                      return  _headerAdvert(snapshot.data);
                    }),
              ),
              Container(
                width:MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(ScreenUtil.getInstance().getWidthPx(20), ScreenUtil.getInstance().getHeightPx(64), ScreenUtil.getInstance().getWidthPx(20), ScreenUtil.getInstance().getHeightPx(64)),
                  child: StreamBuilder<List<Module>>(
                      stream: bloc.moduleBloc.moduleStream,
                      builder: (context, AsyncSnapshot<List<Module>> snapshot){
                        return  _mainBt(snapshot.data);
                      }),
//                  _mainBt()
                ),
              ),
              //课程中心模块
              StreamBuilder<String>(
              stream: bloc.coachBloc.getCoachNoticeStream,
              builder: (context, AsyncSnapshot<String> snapshot){
                if(snapshot.data != null){
                  return  _getCoachNotice(snapshot.data);
                }else{
                  return Text("");
                }
              }),
              //精准学习模块
              Container(
                margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(33)),
                color: Colors.white,
                width:MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(50)),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(53)),
                        child:  Row(
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
                            Text("  精准学习",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3) ),)
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(50),bottom:ScreenUtil.getInstance().getHeightPx(50)),
                        child:  StreamBuilder<List<Module>>(
                            stream: bloc.jzModuleBloc.moduleStream,
                            builder: (context, AsyncSnapshot<List<Module>> snapshot){
                              return  _widgeStudy(snapshot.data);
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              (store.state.application.showBanner==1&&store.state.application.showCoachBanner==1)?StreamBuilder<bool>(
              stream: bloc.coachBloc.coachShowBannerStream,
              initialData: true,
              builder: (context,AsyncSnapshot<bool> show){
                return Offstage(
                  offstage: !show.data,
                  child: StreamBuilder<Adver>(
                  stream: bloc.adBloc.adverStream,
                  builder: (context, AsyncSnapshot<Adver> snapshot){
                    return Padding(
                        padding: EdgeInsets.only(top:ScreenUtil.getInstance().getWidthPx(100),right: ScreenUtil.getInstance().screenWidth*0.03,left: ScreenUtil.getInstance().screenWidth*0.03),
                        child:Stack(
                          alignment:AlignmentDirectional(0.95, -0.65),
                          children: <Widget>[
                             Container(
                                color: Colors.transparent,
                                height:ScreenUtil.getInstance().screenWidth/6.4,
                                child: snapshot.data!=null?BannerUtil.buildMyBanner(context,snapshot.data):BannerUtil.buildBanner(AdBloc.adChannelMap,CoachPage.sName,bloc: bloc.coachBloc)
                              ),
                            (snapshot.data!=null)?Container(
                                child: GestureDetector(
                                  child: Image.asset(
                                    'images/parent_reward/closeIcon.png',
                                    width:ScreenUtil.getInstance().getWidthPx(51),
                                  ),
                                  onTap: (){
                                    if(snapshot.data!=null){
                                      BannerUtil.sendData(snapshot.data, BannerUtil.BANNER_SKIP_ADVERT);
                                    }
                                    bloc.coachBloc.showBanner(false);
                                  },
                                )
                            ):Container(),
                          ],
                        )
                    );
                  }),
                );
              }):Container(),
            ],
          ),
    );
  }

  //头部广告位
  Widget _headerAdvert(List<CoachNotice> data){
    var headMsg;
    if(null!=data && data.length >0 ){
      headMsg= Swiper(
        itemBuilder: (BuildContext context, int index) {
          return new CachedNetworkImage(
            imageUrl:data[index].picUrl,
            fit: BoxFit.fill,
          );
        },
        index:0,
        autoplay:data.length!=1?true:false,
        loop:data.length!=1?true:false,
        onTap:(index) {
          if(data[index].target!=""){
            NavigatorUtil.goWebView(context,data[index].target).then((v){
              bloc.coachBloc.getMainLastCourse();
            });
          }
          if(data[index].eventId!=null){
            ApplicationDao.trafficStatistic(data[index].eventId);
          }
        },
        duration:500,
        itemCount:data.length,
      );
    }else{
      headMsg = Container();
    }
    return headMsg;
  }

  //中部按钮
  Widget _mainBt(List<Module> data){
    List<Widget> btList = [];
    if(null!=data){
      for(var i = 0;i<data.length;i++){
        var positioned = data[i].status != '' ? Positioned(
          top:0,
          right: 0,
          child:Container(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.asset(
                    "images/coach/icon-hot.png",
                    width:ScreenUtil.getInstance().getWidthPx(94),
                    height:ScreenUtil.getInstance().getHeightPx(33),
                  ),
                  Text(data[i].status,style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: ScreenUtil.getInstance().getSp(25 / 3),
                  ),),
                ],
              )
          ),
        ):Text("");
        btList.add(
            Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        if(data[i].eventId!=null && data[i].eventId!=0 ){
                          ApplicationDao.trafficStatistic(data[i].eventId);
                        }
                        NavigatorUtil.goWebView(context,data[i].targetUrl,openType:data[i].openType).then((v){
                          bloc.coachBloc.getMainLastCourse();
                        });
                      },
                      child:Container(
                        width: ScreenUtil.getInstance().getWidthPx(260),
                        child: CachedNetworkImage(
                          imageUrl:data[i].iconUrl,
                          height: ScreenUtil.getInstance().getHeightPx(120),
                          fit: BoxFit.contain,
                        ),
                      ) ,
                    ),
                    positioned
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(10)),
                ),
                Text(data[i].name,style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(36 / 3),color: Color(0xFF999999)),),
              ],
            )
        );
      }
    }
    var btmsg =Wrap(
//      spacing: ScreenUtil.getInstance().getWidthPx(100), // 主轴(水平)方向间距
      runSpacing: ScreenUtil.getInstance().getHeightPx(30), // 纵轴（垂直）方向间距
      runAlignment:WrapAlignment.center,
      alignment: (data!=null && data.length>4)?WrapAlignment.start:WrapAlignment.spaceAround,
      children: btList,
    );
    return btmsg;
  }
  //跳转到课程中心
   _goCourseCenter(){
     ApplicationDao.trafficStatistic(548);
     NavigatorUtil.goWebView(context,AddressUtil.getInstance().goCourseCenter(),openType: 2).then((v){
       bloc.coachBloc.getMainLastCourse();
     });
   }

   //跳转到课程中心
   _goBroadcastHor(productId,courseallotId){
     ApplicationDao.trafficStatistic(547);
     NavigatorUtil.goWebView(
         context,AddressUtil.getInstance().goBroadcastHor()+
         "?productId="+productId.toString()+
         "&courseallotId="+courseallotId.toString()+
         "&:ROTATE"
     ,openType: 2).then((v){
       bloc.coachBloc.getMainLastCourse();
     });
   }

  ///倒计时
   int countdown;



   ///获取课程中心布局courseallotId
   Widget _getCoachNotice(data){

     print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
     print(data);
     print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
     if(data == "null" || data == null){
       return Text("");
     }
//     data = '{"productId":159,"productName":"","courseStatus":"O","startDate":"2020-03-23","endDate":"2020-03-23","courseName":"五年级应用题专题-相遇问题","peLiveCourseallotId":569838,"countdown":60,"nextCourseStartTime":"2020-03-23T19:30:00+08:00","nextCourseEndTime":"2020-03-23T20:40:00+08:00"}';
     var dataJson =  jsonDecode(data.toString());

     var courseName = dataJson["courseName"];//课时名称
     var startDate = _getStartDate(dataJson["startDate"]);//开始时间
     var timeDate = _getTime(dataJson["nextCourseStartTime"]) +"-"+ _getTime(dataJson["nextCourseEndTime"]);//获取开始结束时间
     countdown = dataJson["countdown"];//倒计时时间
     var productId = dataJson["productId"];//课时id


     var courseallotId = dataJson["peLiveCourseallotId"];//目录id
     var courseStatus = dataJson["courseStatus"];//是否在上课
     var coachView = Container(
       margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(33)),
       color: Colors.white,
       width:MediaQuery.of(context).size.width,
       child: Padding(
         padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(50)),
         child: Column(
           children: <Widget>[
             Padding(
               padding: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(53)),
               child:  Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: <Widget>[
                   new Row(
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
                       Text("  我的课程",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3) )),
                     ],
                   ),
                   Padding(
                     padding: EdgeInsets.only(right:ScreenUtil.getInstance().getWidthPx(53)),
                     child: InkWell(
                       onTap: (){ _goCourseCenter();},
                       child: Text("课程中心 >",
                           style: TextStyle(
                               fontSize: ScreenUtil.getInstance().getSp(42/3),
                               color: Color(0xFF999999)
                           )
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             Padding(
                 padding: EdgeInsets.only(
                     right:ScreenUtil.getInstance().getWidthPx(53),
                     left:ScreenUtil.getInstance().getWidthPx(53),
                     top:ScreenUtil.getInstance().getHeightPx(10),
                     bottom:ScreenUtil.getInstance().getHeightPx(50)
                 ),
                 child:  Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: <Widget>[
                     Image.asset(
                       "images/coach/icon-course.png",
                       width:ScreenUtil.getInstance().getWidthPx(232),
                       height:ScreenUtil.getInstance().getHeightPx(255),
                     ),
                     Container(
                       alignment: Alignment.topLeft,
                       margin: EdgeInsets.only(
                           left:ScreenUtil.getInstance().getWidthPx(38)
                       ),
                       child: new Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                         crossAxisAlignment:CrossAxisAlignment.start,
                         children: <Widget>[
                           //标题区域
                           Container(
                             margin: EdgeInsets.only(
                               top:ScreenUtil.getInstance().getHeightPx(25),
                             ),
                             child: Row(
                               children: <Widget>[
                                 Container(
                                   margin: EdgeInsets.only(
                                     right:ScreenUtil.getInstance().getWidthPx(25),
                                   ),
                                   decoration:new BoxDecoration(
                                       borderRadius: BorderRadius.only(topLeft:Radius.circular(4.0),bottomRight:Radius.circular(4.0)),
                                       color:Color(0xFFfb7d5f)
                                   ),
                                   padding: EdgeInsets.all(ScreenUtil.getInstance().getWidthPx(9)),
                                   child: Text("数学",style: TextStyle(color: Color(0xFFffffff))),
                                 ),
                                 Container(
                                   width: ScreenUtil.getInstance().getWidthPx(600),
                                   padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getWidthPx(9)),
                                   child: Text(courseName,
                                     softWrap:true,
                                     style: TextStyle(
                                         fontSize: ScreenUtil.getInstance().getSp(48/3),
                                         color: Color(0xFF666666)
                                     ),
                                     textAlign: TextAlign.left,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           //时间区域
                           Container(
                             margin:EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(10)),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.start,
                               crossAxisAlignment:CrossAxisAlignment.start,
                               children: <Widget>[
                                 Text(startDate+" ·  "+timeDate,
                                     style: TextStyle(
                                       fontSize: ScreenUtil.getInstance().getSp(36/3),
                                       color: Color(0xFF999999),
                                     )),
                               ],
                             ),
                           ),
                           //倒计时区域
                           _countDownView(countdown,productId,courseallotId,courseStatus),
                           //上课按钮
                         ],
                       ),
                     ),
                   ],
                 )
             ),
           ],
         ),
       ),
     );
     return coachView;
  }

   CourseCountDownWidget courseCountDownWidget;


    _countDownView(countdown,productId,courseallotId,courseStatus){
//     var courseCountDownWidget  = new CourseCountDownWidget(countdown:200,productId:productId,courseallotId:courseallotId,courseStatus:"F");
     print("倒计时${countdown}");
     bloc.coachBloc.getCountdownSink(countdown);
//     courseCountDownWidget  = new CourseCountDownWidget(countdown:countdown,productId:productId,courseallotId:courseallotId,courseStatus:courseStatus);
//
    var _start = courseStatus;
     return  new Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
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
                 onPressed: (){_goBroadcastHor(productId,courseallotId);},
                 child: Text(_getName(_start),style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFFffffff))),
               ),
             ),
           ],
         )
       ],
     ) ;
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
  ///获取开始月日
  String _getStartDate(data){
    var date = "";
    try {
      date = data.split('-')[1] + "月" + data.split('-')[2] + "日";
    }catch(e){

    }
    return date;
  }
  ///获取开始结束时间
  String _getTime(data){
    var date = "";
    try {
      var time = data.split('T')[1].split('+')[0];
      date = time.split(':')[0] +":"+ time.split(':')[1];
    }catch(e){

    }
    return date;
  }
  //精准学习
  Widget _widgeStudy (List<Module> data){
    List<Widget> listWidge = [];
    if(null!=data){
      for(var i = 0; i<data.length;i++){
        listWidge.add(
          GestureDetector(
            onTap: (){
              if(data[i].eventId!=null && data[i].eventId!=0){
                ApplicationDao.trafficStatistic(data[i].eventId);
              }
              NavigatorUtil.goWebView(context,data[i].targetUrl,openType: data[i].openType).then((v){
                bloc.coachBloc.getMainLastCourse();
              });
            },
            child:Container(
              width: ScreenUtil.getInstance().getWidthPx(500),
              child: CachedNetworkImage(
              imageUrl:data[i].iconUrl,
              width:ScreenUtil.getInstance().getWidthPx(500),
              fit: BoxFit.fitWidth,
            ),
            ) ,
          ),
        );
      }
    }
    var btmsg =Wrap(
      spacing: ScreenUtil.getInstance().getWidthPx(20), // 主轴(水平)方向间距
      runSpacing: ScreenUtil.getInstance().getHeightPx(27), // 纵轴（垂直）方向间距
      runAlignment:WrapAlignment.center,
      alignment: WrapAlignment.start,
      children: listWidge,
    );
    return btmsg;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => Platform.isAndroid;
}
