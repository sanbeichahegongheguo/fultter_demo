import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';

class Keyboard extends StatefulWidget {
  final sendExpression;
  final submit;
  TextEditingController controller;
  Keyboard({Key key, this.controller, this.sendExpression, this.submit}) : super(key: key);

  @override
  _KeyboardState createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> animation;

  ///键盘宽度 高度自适应
  double _width = 260;

  ///间距
  double _spacing = 1;

  ///键盘状态
  bool _start = true;

  ///字体大小
  double _fontSize = 22;

  ///键盘内容
  List<String> _keyNames = [
    "icon1",
    "icon2",
    "ok",
    "666",
    "zan",
    "＋",
    "1",
    "4",
    "7",
    ".",
    "－",
    "2",
    "5",
    "8",
    "0",
    "×",
    "3",
    "6",
    "9",
    "^",
    "÷",
    "＝",
    // "@",//替换键盘
    "~",
    "确定"
  ];

  ///键盘内容
  List<String> _sentimentNames = ["icon1", "icon2", "ok", "666", "flower", "gift", "zan", "heartIcon", "^", "*", "确定"];
  bool _isIos13 = DeviceInfo.instance.ios13();
  @override
  void initState() {
    super.initState();
    if (_isIos13) {
      _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
      animation = Tween(begin: Offset(0.0, 1.0), end: Offset.zero).animate(_controller);
      _controller?.forward();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  ///获取一个数字自定义键盘
  List<Widget> getKeyboard() {
    List<Widget> _list = [];
    for (int i = 0; i < _keyNames.length; i++) {
      String element = _keyNames[i];
      _list.add(Material(
          child: InkWell(
        onTap: () => {_onKeyboard(element)},
        child: Container(
          height: getKeyboardHeight(element),
          width: _width / 5,
          child: Center(
            child: getKeyboardBox(element),
          ),
        ),
      )));
    }
    return _list;
  }

  ///获取一个表情自定义键盘
  List<Widget> getSentimentKeyboard() {
    List<Widget> _list = [];
    for (int i = 0; i < _sentimentNames.length; i++) {
      String element = _sentimentNames[i];
      _list.add(Material(
          child: InkWell(
        onTap: () => {_onKeyboard(element)},
        child: Container(
          height: getKeyboardHeight(element),
          width: getKeyboardWidth(element),
          child: Center(
            child: getKeyboardBox(element),
          ),
        ),
      )));
    }
    return _list;
  }

  ///根据键盘内容改变宽度
  getKeyboardWidth(element) {
    double _h = 0;
    if (element == "^" || element == "*" || element == "确定") {
      _h = _width / 5;
    } else {
      _h = (_width - _width / 5) / 2;
    }
    return _h;
  }

  ///根据键盘内容改变高度
  getKeyboardHeight(element) {
    double _h = 0;
    switch (element) {
      case "确定":
        _h = _width / 5 * 2 + _spacing;
        break;
      default:
        _h = _width / 5;
    }
    return _h;
  }

  ///根据内容 获取键位
  getKeyboardBox(element) {
    var _box;
    switch (element) {
      case "~":
        _box = new Icon(Icons.backspace, color: Color(0xFF707070));
        break;
      case "^":
        _box = new Icon(Icons.arrow_drop_down, color: Color(0xFF707070));
        break;
      case "*":
        _box = _getImageWidgt("icon-123");
        break;
      case "@":
        _box = new Icon(Icons.sentiment_satisfied, color: Color(0xFF707070));
        break;
      case "icon1":
        _box = _getImageWidgt("1Icon");
        break;
      case "icon2":
        _box = _getImageWidgt("2Icon");
        break;
      case "666":
        _box = _getImageWidgt("666Icon");
        break;
      case "flower":
        _box = _getImageWidgt("flowerIcon");
        break;
      case "gift":
        _box = _getImageWidgt("giftIcon");
        break;
      case "heartIcon":
        _box = _getImageWidgt("heartIcon");
        break;
      case "zan":
        _box = _getImageWidgt("zanIcon");
        break;
      case "ok":
        _box = _getImageWidgt("okIcon");
        break;
      default:
        _box = new Text(element, textDirection: TextDirection.rtl, maxLines: 2, style: TextStyle(color: Color(0xFF707070), fontSize: _fontSize));
        break;
    }
    return _box;
  }

  ///获取一个图标
  _getImageWidgt(name) {
    return new Image.asset(
      "images/live/chat/${name}.png",
      height: _width / 5 / 3,
    );
  }

  ///退出
  _back() {
    _controller?.reset();
    Navigator.pop(context);
  }

  ///点击键盘
  _onKeyboard(String element) {
    print(element);
    switch (element) {
      case "~":
        print("widget.controller.text===>${widget.controller.text != null}");
        if (widget.controller.text.length > 0) {
          widget.controller.text = widget.controller.text.substring(0, widget.controller.text.length - 1);
        }
        break;
      case "^":
        _back();
        break;
      case "确定":
        widget.submit();
        _back();
        break;
      case "@":
        setState(() {
          _start = false;
        });
        break;
      case "*":
        setState(() {
          _start = true;
        });
        break;
      case "icon1":
        widget.sendExpression("1");
        _back();
        break;
      case "icon2":
        widget.sendExpression("2");
        _back();
        break;
      case "666":
        widget.sendExpression("666");
        _back();
        break;
      case "flower":
        widget.sendExpression("flower");
        _back();
        break;
      case "gift":
        widget.sendExpression("gift");
        _back();
        break;
      case "heartIcon":
        widget.sendExpression("heartIcon");
        _back();
        break;
      case "zan":
        widget.sendExpression("zan");
        _back();
        break;
      case "ok":
        widget.sendExpression("ok");
        _back();
        break;
      default:
        widget.controller.text += element;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Container(
      color: Color(0xFFeeeeee),
      height: _width / 5 * 5 + _spacing * 4,
      child: new Wrap(
        direction: Axis.vertical,
        spacing: _spacing, // 主轴(水平)方向间距
        runSpacing: _spacing, // 纵轴（垂直）方向间距
        alignment: WrapAlignment.start, //沿主轴方向居中
        children: _start ? getKeyboard() : getSentimentKeyboard(),
      ),
    );
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: <Widget>[
        Positioned(
            right: 20,
            bottom: 45,
            child: _isIos13
                ? SlideTransition(
                    position: animation,
                    //将要执行动画的子view
                    child: body)
                : body),
      ],
    );
  }
}
