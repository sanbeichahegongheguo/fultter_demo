import 'package:flutter/material.dart';

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
  int _currentIndex = 0;

  _GSYTabBarState(
    this._tabViews,
    this._indicatorColor,
    this._title,
    this._drawer,
    this._floatingActionButton,
    this._tarWidgetControl,
    this._onPageChanged,
  ) : super();

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 4);
  }

  ///整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      _renderTab(_currentIndex == 0 ? "images/home/icon_study_select.png" : "images/home/icon_study.png", "学习", _currentIndex == 0 ? true : false),
      _renderTab(_currentIndex == 1 ? "images/home/icon_challenge_select.png" : "images/home/icon_challenge.png", "挑战", _currentIndex == 1 ? true : false),
      _renderTab(_currentIndex == 2 ? "images/home/icon_user_select.png" : "images/home/icon_user.png", "个人中心", _currentIndex == 2 ? true : false),
      _renderTab(_currentIndex == 3 ? "images/home/icon_parent_select.png" : "images/home/icon_parent.png", "家长专区", _currentIndex == 3 ? true : false),
    ];

    ///底部tab bar
    return new Scaffold(
        drawer: _drawer,
        appBar: _title != null
            ? new AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: _title,
              )
            : null,
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
              height: MediaQuery.of(context).size.height * 0.08,
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
          Image.asset(
            icon,
            fit: BoxFit.scaleDown,
            height: isSelect ? 25 : 20,
          ),
          SizedBox(
            height: 2,
          ),
          new Text(
            text,
            style: TextStyle(fontSize: isSelect ? 13 : 12, color: isSelect ? Color(0xFF17b4ff) : Color(0xFF606a81)),
          )
        ],
      ),
    );
  }
}

class TarWidgetControl {
  List<Widget> footerButton = [];
}
