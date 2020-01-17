import 'dart:async';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/dao/InfoDao.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/event/http_error_event.dart';
import 'package:flutter_start/common/event/index.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/page/AdminPage.dart';
import 'package:flutter_start/page/CoachPage.dart';
import 'package:flutter_start/page/LearningEmotionPage.dart';
import 'package:flutter_start/page/StudyInfoPage.dart';
import 'package:flutter_start/page/parentReward.dart';
import 'package:redux/redux.dart';

///支持顶部和顶部的TabBar控件
///配合AutomaticKeepAliveClientMixin可以keep住
class GSYTabBarWidget extends StatefulWidget {
  final List<Widget> tabViews;

  final Color backgroundColor;

  final Color indicatorColor;

  final Widget title;

  final Widget drawer;

  final Widget floatingActionButton;


  final ValueChanged<int> onPageChanged;

  final int currentIndex;

  GSYTabBarWidget({
    Key key,
    this.tabViews,
    this.backgroundColor,
    this.indicatorColor,
    this.title,
    this.drawer,
    this.floatingActionButton,
    this.onPageChanged,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  _GSYTabBarState createState() => new _GSYTabBarState(
        tabViews,
        indicatorColor,
        title,
        drawer,
        floatingActionButton,
        onPageChanged,
        currentIndex,
      );
}

class _GSYTabBarState extends State<GSYTabBarWidget> with SingleTickerProviderStateMixin {
  final List<Widget> _tabViews;

  final Color _indicatorColor;

  final Widget _title;

  final Widget _drawer;

  final Widget _floatingActionButton;


  final PageController _pageController = PageController();

  final ValueChanged<int> _onPageChanged;
  StreamSubscription _stream;
  int _currentIndex;
  GlobalKey _globalKey = new GlobalKey();
  int _msgCount = 0;
  int _signTimes = 0;//签到个数
  String _unReadNotice = "0";//消息个数
  TabController _tabController;

  List<String> pageList = [CoachPage.sName,StudyInfoPage.sName,ParentReward.sName,Admin.sName];
  List<int> pageTotal = [289,300,304,313];

  HomeBloc bloc;

  _GSYTabBarState(
    this._tabViews,
    this._indicatorColor,
    this._title,
    this._drawer,
    this._floatingActionButton,
    this._onPageChanged,
    this._currentIndex,
  ) : super();


  @override
  void initState() {
    super.initState();
    bloc =  BlocProvider.of<HomeBloc>(context);
    print("init tabbar ");
    _stream = eventBus.on<HttpErrorEvent>().listen((event) {
      print("home eventBus " + event.toString());
      HttpErrorEvent.errorHandleFunction(event.code, event.message, context);
    });
    _tabController = new TabController(vsync: this, length: 4);
    _signReward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Store<GSYState> store = StoreProvider.of(context);
      _getAppVersionInfo(store.state.userInfo.userId,store);
      UserDao.getUser(isNew:true,store: store);
    });
    initPageMap[pageList[_currentIndex]]=true;
  }

  ///整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    print("_GSYTabBarState dispose");
    _tabController?.dispose();
    _stream?.cancel();
    _stream = null;
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    print("  tabbar build");
    ///底部tab bar
      return new Scaffold(
          drawer: _drawer,
          appBar: PreferredSize(
              child:_buildTitle(),
            preferredSize: Size.fromHeight(ScreenUtil.getInstance().screenHeight * 0.09),
          ),
          body: new PageView(
            controller: _pageController,
            children: _tabViews,
            onPageChanged: (index) {
              callPageLoad(index);
              if (_currentIndex != index) {
                print("bloc.tabbarBloc.callTab $index");
                _currentIndex = index;
                bloc.tabbarBloc.callTab(index);
              }
              _tabController.animateTo(index);
              _onPageChanged?.call(index);
            },
          ),
          bottomNavigationBar: new Material(
              //为了适配主题风格，包一层Material实现风格套用
              color: Colors.white, //底部导航栏主题颜色
              child: Container(
  //              height: MediaQuery.of(context).size.height * 0.08,
                height: ScreenUtil.getInstance().getHeightPx(150),
                child: StreamBuilder<int>(
                    initialData: 0,
                    stream: bloc.tabbarBloc.tabbarBannerStream,
                    builder: (context, AsyncSnapshot<int> snapshot){
                      return TabBar(
                      indicator: BoxDecoration(),
                      indicatorWeight: 1,
                      //TabBar导航标签，底部导航放到Scaffold的bottomNavigationBar中
                      controller: _tabController, //配置控制器
                      tabs: [
                          _renderTab(snapshot.data == 0 ? "images/home/icon_study_select.png" : "images/home/icon_study.png", "辅导", snapshot.data == 0 ? true : false),
                          _renderTab(snapshot.data == 1 ? "images/home/icon_challenge_select.png" : "images/home/icon_challenge.png", "学情", snapshot.data == 1 ? true : false),
                          _renderTab(snapshot.data == 2 ? "images/home/icon_user_select.png" : "images/home/icon_user.png", "家长奖励", snapshot.data == 2 ? true : false),
                          _renderTab(snapshot.data == 3 ? "images/home/icon_parent_select.png" : "images/home/icon_parent.png", "管理", snapshot.data == 3 ? true : false),
                      ],
                      onTap: (index) {
                        print('切换');
                        _onPageChanged?.call(index);
                        _pageController.jumpTo(MediaQuery.of(context).size.width * index);
                      });
                }),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                ),
              )));
  }

  ///查询签到时间
   _signReward() async{
    var res = await InfoDao.signReward();
    if(res != null && res != ""){
      if(res["err"] == 0){
        setState(() {
          _signTimes = res["signTimes"];
        });
      }
    }
  }
  ///获取未读取消息总数
  _getUnReadNotice() async{
    var res = await InfoDao.getUnReadNotice();
    if(res != null && res != ""){
      if(res["success"]["ok"] == 0){
        int unNum = int.parse(res["success"]["data"]);
        setState(() {
          _unReadNotice = unNum > 99 ?"...":unNum.toString();
        });
      }
    }
  }
  ///跳转签到外链
  void _sign(){
    print('签到');
    ApplicationDao.trafficStatistic(2);
    NavigatorUtil.goWebView(context,Address.goH5Sign()).then((v){
        _signReward();
    });
  }
  ///跳转消息
  void _news(){
    print("消息");
    ApplicationDao.trafficStatistic(20);
    NavigatorUtil.goWebView(context,Address.getInfoPage()).then((v){
      _getUnReadNotice();
    });
  }
  ///跳转客服
  void _wxServer(){
    print("客服");
    ApplicationDao.trafficStatistic(94);
    NavigatorUtil.goWebView(context,Address.getWxServer()).then((v){
    });
  }
  static _renderTab(icon, text, isSelect) {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(icon, fit: BoxFit.scaleDown, height: isSelect ? ScreenUtil.getInstance().getHeightPx(65) : ScreenUtil.getInstance().getHeightPx(60)
//            height: isSelect ? 25 : 20,
              ),
          SizedBox(
            height: 2,
          ),
          new Text(
            text,
            style: TextStyle(fontSize: isSelect ? ScreenUtil.getInstance().getSp(33 / 3) : ScreenUtil.getInstance().getSp(32 / 3), color: isSelect ? Color(0xFF5fc589) : Color(0xFF606a81)),
          )
        ],
      ),
    );
  }



  Widget _buildTitle() {
    final SystemUiOverlayStyle overlayStyle = Theme.of(context).primaryColorBrightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return
      Semantics(
        container: true,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: Material(
            color: Color(0xFFf1f2f6),
            child: Semantics(
              explicitChildNodes: true,
              child: SafeArea(
                child: Material(
                  color: Color(0xFFf1f2f6),
                  child: Container(
                    //backgroundColor: Theme.of(context).primaryColor,
                    child: SizedBox(
                      height: ScreenUtil.getInstance().screenHeight * 0.09,
                      child: Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: _sign,
                            child:Container(
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: ScreenUtil.getInstance().getWidthPx(50),
                                    ),
                                    Image.asset(
                                      "images/home/icon_jl.png",
                                      width: ScreenUtil.getInstance().getWidthPx(100),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.getInstance().getWidthPx(25),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "签到奖励",
                                          style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(42 / 3), color: const Color(0xFF333333)),
                                        ),
                                        Text("已经签到$_signTimes天", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(28 / 3), color: const Color(0xFFacb5bc)))
                                      ],
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.getInstance().getWidthPx(30),
                                    ),
                                  ],
                                )
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: _wxServer,
                                child:Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: ScreenUtil.getInstance().getHeightPx(56),
                                        child: Image.asset("images/home/icon_lxr.png", width: ScreenUtil.getInstance().getWidthPx(66)),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.getInstance().getHeightPx(3),
                                      ),
                                      Text("客服", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(30 / 3), color: const Color(0xFFacb5bc))),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _news,
                                child:Container(
                                  padding: EdgeInsets.only(right: 15,left: 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Stack(
                                        fit: StackFit.passthrough,
                                        alignment: AlignmentDirectional(1.9, -1.5),
                                        children: <Widget>[
                                          SizedBox(
                                            key: _globalKey,
                                            height: ScreenUtil.getInstance().getHeightPx(56),
                                            child: Image.asset("images/home/icon_yj.png" ,width: ScreenUtil.getInstance().getWidthPx(66)),
                                          ),
                                          Offstage(
                                            offstage: _unReadNotice == "0",
                                            child: ClipOval(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: ScreenUtil.getInstance().getWidthPx(10) ),
                                                child: Text(_unReadNotice, style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(28 / 3), color: Colors.white)),
                                                decoration: BoxDecoration(color: const Color(0xFFff542b)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.getInstance().getHeightPx(3),
                                      ),
                                      Text("消息", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(30 / 3), color: const Color(0xFFacb5bc))),
                                    ],
                                  ),),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    decoration:BoxDecoration(
                      color: Color(0xFFf1f2f6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }

  Map<String,bool> initPageMap = new Map();
  ///加载页面的时候触发
  void callPageLoad(index){
    //事件统计
    ApplicationDao.trafficStatistic(pageTotal[index]);

    if (initPageMap[pageList[index]]==null){
      print("初始化 ${pageList[index]}");
      initPageMap[pageList[index]]=true;
      return;
    }
    switch (pageList[index]){
      case CoachPage.sName:
        print("切换辅导页面");
        if (Platform.isAndroid){
          bloc.coachBloc.showBanner(true);
          bloc.adBloc.getBanner(pageName: CoachPage.sName);
        }
        _getUnReadNotice();
        break;
      case LearningEmotionPage.sName:
        print("切换学情页面");
        bloc.learningEmotionBloc.getStudyData();
        bloc.learningEmotionBloc.getNewHomeWork();
        break;
      case ParentReward.sName:
        print("切换家长奖励页面");
        if (Platform.isAndroid){
          bloc.adBloc.getBanner(pageName:ParentReward.sName);
          bloc.parentRewardBloc.getTotalStar();
          bloc.parentRewardBloc.showBanner(true);
        }
        break;
      case Admin.sName:
        print("切换管理页面");
        break;
      case StudyInfoPage.sName:
        print("切换新版学情页面");
        bloc.learningEmotionBloc.getStudyData();
        bloc.learningEmotionBloc.getNewHomeWork();
        bloc.learningEmotionBloc.getSynerrData();
        bloc.learningEmotionBloc.getStudymsgQues();
        bloc.learningEmotionBloc.getParentHomeWorkDataTotal();
        break;
    }
  }

  _getAppVersionInfo(userId,Store<GSYState> store){
    //获取获取更新信息在获取公告
    ApplicationDao.getAppVersionInfo(userId).then((data){
      if(null==data || !data.result || data.data.ok!=0 ||data.data.isUp!=1){
        _getAppNotice();
        return;
      }
      if (null!=data&&data.result){
        if (data.data.ok==0){
          if(data.data.isUp==1){
            int must = 0;
            if(Platform.isIOS){
              if (store.state.application.minIosVersion!=""){
                if(CommonUtils.compareVersion(store.state.application.version, store.state.application.minIosVersion)==-1){
                  must = 1;
                }
              }
            }else if (Platform.isAndroid){
              if (store.state.application.minAndroidVersion!=""){
                if (CommonUtils.compareVersion(store.state.application.version, store.state.application.minAndroidVersion)==-1){
                  must = 1;
                }
              }
            }
            CommonUtils.showUpdateDialog(context, data.data,mustUpdate: must).then((_){
              _getAppNotice();
            });
          }
        }
      }
    });
  }

  ///获取APP公告
  _getAppNotice(){
    ApplicationDao.getAppNotice().then((data){
      _getUnReadNotice();
      if (null!=data&&data.result){
        if(data.data["success"]["ok"]==0&&data.data["success"]["advertList"]!=null&&data.data["success"]["advertList"].length!=0){
          var message = data.data["success"]["message"];
          var notice = data.data["success"]["advertList"][0];
          CommonUtils.showAPPNotice(context,notice,message);
        }else{
          ///今天已弹窗，不再弹窗
        }
      }
    });
  }

}
