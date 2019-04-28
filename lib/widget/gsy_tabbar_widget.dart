import 'package:flutter/material.dart';

///支持顶部和顶部的TabBar控件
///配合AutomaticKeepAliveClientMixin可以keep住
class GSYTabBarWidget extends StatefulWidget {
  ///底部模式type
  static const int BOTTOM_TAB = 1;

  ///顶部模式type
  static const int TOP_TAB = 2;

  final int type;

  final List<Widget> tabItems;

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
    this.type,
    this.tabItems,
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
        type,
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
  final int _type;

  final List<Widget> _tabViews;

  final Color _indicatorColor;

  final Widget _title;

  final Widget _drawer;

  final Widget _floatingActionButton;

  final TarWidgetControl _tarWidgetControl;

  final PageController _pageController = PageController();

  final ValueChanged<int> _onPageChanged;

  _GSYTabBarState(
    this._type,
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
    _tabController = new TabController(vsync: this, length: widget.tabItems.length);
  }

  ///整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///底部tab bar
    return new Scaffold(
        drawer: _drawer,
        appBar: _title!=null?new AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: _title,
        ):null,
        body: new PageView(
          controller: _pageController,
          children: _tabViews,
          onPageChanged: (index) {
            _tabController.animateTo(index);
            _onPageChanged?.call(index);
          },
        ),
        bottomNavigationBar: new Material(
          //为了适配主题风格，包一层Material实现风格套用
          color: Colors.white, //底部导航栏主题颜色
          child:  Container(
            height: MediaQuery.of(context).size.height*0.08,
            child: new TabBar(
              indicator: BoxDecoration(
              ),
              indicatorWeight:1,
              //TabBar导航标签，底部导航放到Scaffold的bottomNavigationBar中
              controller: _tabController, //配置控制器
              tabs: widget.tabItems,
              onTap: (index) {
                _onPageChanged?.call(index);
                _pageController.jumpTo(MediaQuery.of(context).size.width * index);
              }, //tab标签的下划线颜色
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey,width: 0.5)),
            ),
          )
        ));
  }
}

class TarWidgetControl {
  List<Widget> footerButton = [];
}
