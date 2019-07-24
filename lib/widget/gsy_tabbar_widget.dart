import 'dart:async';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/event/http_error_event.dart';
import 'package:flutter_start/common/event/index.dart';

///支持顶部和顶部的TabBar控件
///配合AutomaticKeepAliveClientMixin可以keep住
class GSYTabBarWidget extends StatefulWidget {
  final List<Widget> tabViews;

  final Color backgroundColor;

  final Color indicatorColor;

  final Widget title;

  final Widget drawer;

  final Widget floatingActionButton;

  final TarWidgetControl tarWidgetControl;

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
    this.tarWidgetControl,
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
        tarWidgetControl,
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

  final TarWidgetControl _tarWidgetControl;

  final PageController _pageController = PageController();

  final ValueChanged<int> _onPageChanged;
  StreamSubscription _stream;
  int _currentIndex;
  GlobalKey _globalKey = new GlobalKey();
  int _msgCount = 0;

  Widget _MsgWidget = new Container();

  _GSYTabBarState(
    this._tabViews,
    this._indicatorColor,
    this._title,
    this._drawer,
    this._floatingActionButton,
    this._tarWidgetControl,
    this._onPageChanged,
    this._currentIndex,
  ) : super();

  TabController _tabController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _MsgWidget = _buildMsgWidget();
      });
    });
    super.initState();
    _stream = eventBus.on<HttpErrorEvent>().listen((event) {
      print("home eventBus " + event.toString());
      HttpErrorEvent.errorHandleFunction(event.code, event.message, context);
    });
    _tabController = new TabController(vsync: this, length: 4);
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
    List<Widget> tabs = [
      _renderTab(_currentIndex == 0 ? "images/home/icon_study_select.png" : "images/home/icon_study.png", "辅导", _currentIndex == 0 ? true : false),
      _renderTab(_currentIndex == 1 ? "images/home/icon_challenge_select.png" : "images/home/icon_challenge.png", "学情", _currentIndex == 1 ? true : false),
      _renderTab(_currentIndex == 2 ? "images/home/icon_user_select.png" : "images/home/icon_user.png", "家长奖励", _currentIndex == 2 ? true : false),
      _renderTab(_currentIndex == 3 ? "images/home/icon_parent_select.png" : "images/home/icon_parent.png", "管理", _currentIndex == 3 ? true : false),
    ];

    ///底部tab bar
    return new Scaffold(
        drawer: _drawer,
        appBar: new AppBar(
          elevation: 0,
          leading: Row(
            children: <Widget>[
              SizedBox(
                width: ScreenUtil.getInstance().getWidthPx(50),
              ),
              Image.asset(
                "images/home/icon_jl.png",
                width: ScreenUtil.getInstance().getWidthPx(100),
              ),
            ],
          ),
          titleSpacing: 1,
          //backgroundColor: Theme.of(context).primaryColor,
          backgroundColor: Color(0xFFf1f2f6),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "签到奖励",
                style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(42 / 3), color: const Color(0xFF333333)),
              ),
              Text("已经签到5天", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(28 / 3), color: const Color(0xFFacb5bc)))
            ],
          ),
          actions: <Widget>[
            Stack(
              alignment: AlignmentDirectional(0.0, 0.8),
              children: <Widget>[
                Center(
                  child: IconButton(icon: Image.asset("images/home/icon_lxr.png", width: ScreenUtil.getInstance().getWidthPx(66))),
                ),
                Text("客服", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(28 / 3), color: const Color(0xFFacb5bc))),
              ],
            ),
            Stack(
              alignment: AlignmentDirectional(0.0, 0.8),
              children: <Widget>[
                Stack(
                  fit: StackFit.passthrough,
                  alignment: AlignmentDirectional.topCenter,
                  children: <Widget>[
                    Center(
                      child: IconButton(key: _globalKey, icon: Image.asset("images/home/icon_yj.png", width: ScreenUtil.getInstance().getWidthPx(61))),
                    ),
//                    Container(
////      margin: EdgeInsets.only(top: position.dy),
//                      child: ClipOval(
//                        child: Container(
//                          child: Text("10", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(28 / 3), color: Colors.white)),
//                          decoration: BoxDecoration(color: const Color(0xFFff542b)),
//                        ),
//                      ),
//                    ),
                    _MsgWidget,
                  ],
                ),
                Text("消息", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(28 / 3), color: const Color(0xFFacb5bc))),
              ],
            ),
          ],
        ),
        body: new PageView(
          controller: _pageController,
          children: _tabViews,
          onPageChanged: (index) {
            print("onPageChanged : $index");
            if (_currentIndex != index) {
              setState(() {
                _currentIndex = index;
              });
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
              child: new TabBar(
                indicator: BoxDecoration(),
                indicatorWeight: 1,
                //TabBar导航标签，底部导航放到Scaffold的bottomNavigationBar中
                controller: _tabController, //配置控制器
                tabs: tabs,
                onTap: (index) {
                  _onPageChanged?.call(index);
                  _pageController.jumpTo(MediaQuery.of(context).size.width * index);
                }, //tab标签的下划线颜色
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
            )));
  }

  static _renderTab(icon, text, isSelect) {
    return new Tab(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Image.asset(icon, fit: BoxFit.scaleDown, height: isSelect ? ScreenUtil.getInstance().getHeightPx(65) : ScreenUtil.getInstance().getHeightPx(60)
//            height: isSelect ? 25 : 20,
              ),
          SizedBox(
            height: 2,
          ),
          new Text(
            text,
            style: TextStyle(fontSize: isSelect ? ScreenUtil.getInstance().getSp(38 / 3) : ScreenUtil.getInstance().getSp(32 / 3), color: isSelect ? Color(0xFF5fc589) : Color(0xFF606a81)),
          )
        ],
      ),
    );
  }

  Widget _buildMsgWidget() {
    RenderBox renderObject = _globalKey.currentContext.findRenderObject();
    final position = renderObject.localToGlobal(Offset.zero);
    double screenW = MediaQuery.of(context).size.width;
    double currentW = renderObject.paintBounds.size.width;
    double currentH = renderObject.paintBounds.size.height;
    return Container(
      margin: EdgeInsets.only(top: currentH / 2 - ScreenUtil.getInstance().getHeightPx(22), left: ScreenUtil.getInstance().getWidthPx(58)),
      child: ClipOval(
        child: Container(
          child: Text("10", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(28 / 3), color: Colors.white)),
          decoration: BoxDecoration(color: const Color(0xFFff542b)),
        ),
      ),
    );
  }
}

class TarWidgetControl {
  List<Widget> footerButton = [];
}
