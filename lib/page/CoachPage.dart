import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/bloc/AdBloc.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/Adver.dart';
import 'package:flutter_start/models/CoachNotice.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_start/bloc/ModuleBloc.dart';
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
    ApplicationDao.trafficStatistic(1);
    bloc =  BlocProvider.of<HomeBloc>(context);
    bloc.moduleBloc.getCoachXZYModule();
    bloc.jzModuleBloc.getCoachJZModule();
    bloc.adBloc.getBanner();
    bloc.coachBloc.getCoachNotice();
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
              Container(
                margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(33)),
                color: Colors.white,
                width:MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(77)),
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
//                        _widgeStudy(),
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
                  child:  Padding(
                      padding: EdgeInsets.all(ScreenUtil.getInstance().getWidthPx(50)),
                      child:Stack(
                        alignment:AlignmentDirectional(0.85, -0.45),
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil.getInstance().getWidthPx(50)),
                            child: Container(
                              color: Colors.transparent,
                              height:ScreenUtil.getInstance().screenWidth/6.4,
                              child: StreamBuilder<Adver>(
                                  stream: bloc.adBloc.adverStream,
                                  builder: (context, AsyncSnapshot<Adver> snapshot){
                                    print("StreamBuilder adBloc");
                                    return snapshot.data!=null?CommonUtils.buildMyBanner(context,snapshot.data):CommonUtils.buildBanner(AdBloc.adChannelMap,CoachPage.sName);
                                  }
                              ),
                            ),
                          ),
                          Container(
                              child: GestureDetector(
                                child: Image.asset(
                                  'images/parent_reward/closeIcon.png',
                                  width:ScreenUtil.getInstance().getWidthPx(51),
                                ),
                                onTap: (){
                                  bloc.coachBloc.showBanner(false);
                                },
                              )
                          ),
                        ],
                      )
                  ),
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
            NavigatorUtil.goWebView(context,data[index].target).then((v){});
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
                        NavigatorUtil.goWebView(context,data[i].targetUrl).then((v){});
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

  //精准学习
  Widget _widgeStudy (List<Module> data){
    List<Widget> listWidge = [];
    if(null!=data){
      for(var i = 0; i<data.length;i++){
        listWidge.add(
          GestureDetector(
            onTap: (){
              NavigatorUtil.goWebView(context,data[i].targetUrl).then((v){});
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
  bool get wantKeepAlive => true;
}
