import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/bloc/AdBloc.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/Adver.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_start/bloc/ModuleBloc.dart';

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
    bloc =  BlocProvider.of<HomeBloc>(context);
    bloc.moduleBloc.getCoachXZYModule();
    bloc.jzModuleBloc.getCoachJZModule();
    bloc.adBloc.getBanner();
    _getheaderAdvertList();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
          color: Color(0xFFf0f4f7),
          child: ListView(
            children: <Widget>[
              Container(
                width:MediaQuery.of(context).size.width,
                height:ScreenUtil.getInstance().getHeightPx(311),
                child: _headerAdvert(),
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
              )
            ],
          ),
    );
  }
  //头部广告位轮播集合
  List<Widget> _headerAdvertList = List();
  List<String> _headerImgList = ["images/coach/coach-swiper-1.png","images/coach/coach-swiper-2.png"];
  void _getheaderAdvertList() {
    for(var i = 0;i<_headerImgList.length;i++){
      _headerAdvertList.add(Image.asset(
        _headerImgList[i],
        fit: BoxFit.fitWidth,
      ));
    }
  }
  //头部广告位
  Widget _headerAdvert(){
    var headMsg = Swiper(
        itemBuilder: (BuildContext context, int index) {
          return _swiperBuilder(context,index);
        },
        index:0,
        autoplay:true,
        onTap:(index) {
          print("点击了第:$index个");
        },
      duration:500,
      itemCount:_headerImgList.length,
    );
    return headMsg;
  }
  //头部广告位轮播
  Widget _swiperBuilder(BuildContext context, int index) {
    return (_headerAdvertList[index]);
  }
  List _mainBtList = [
    {"imgUrl":"images/coach/btn-1.png","title":"跨越式数学王","id":1,"type":2},
    {"imgUrl":"images/coach/btn-2.png","title":"核对答案","id":2,"type":1},
    {"imgUrl":"images/coach/btn-3.png","title":"英语随身听","id":3,"type":2},
    {"imgUrl":"images/coach/btn-3.png","title":"核对答案","id":3,"type":1},
    {"imgUrl":"images/coach/btn-3.png","title":"核对答案","id":3,"type":1},
    {"imgUrl":"images/coach/btn-3.png","title":"核对答案","id":3,"type":1},
  ];
  //中部按钮
  Widget _mainBt(List<Module> data){
    List<Widget> btList = [];
    if(null!=data){
      for(var i = 0;i<data.length;i++){
        var positioned = data[i].status == 'free' ? Positioned(
          top:0,
          right: 0,
          child:Image.asset(
            "images/coach/icon-hot.png",
            width:ScreenUtil.getInstance().getWidthPx(94),
            height:ScreenUtil.getInstance().getHeightPx(33),
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
      alignment: _mainBtList.length>4?WrapAlignment.start:WrapAlignment.spaceAround,
      children: btList,
    );
    return btmsg;
  }

  List _studyList = [
    {"imgUrl":"images/coach/pe-1.png","id":1},
    {"imgUrl":"images/coach/pe-2.png","id":2},
    {"imgUrl":"images/coach/pe-3.png","id":3},
    {"imgUrl":"images/coach/pe-4.png","id":4},
    {"imgUrl":"images/coach/pe-3.png","id":3},
  ];
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
