import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_start/common/dao/RoomDao.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/common/utils/Log.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:frefresh/frefresh.dart';
import 'package:fsuper/fsuper.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';

class LiveRankWidgetV2 extends StatefulWidget {
  final String roomId;
  final int liveCourseallotId;

  const LiveRankWidgetV2({Key key, this.roomId, this.liveCourseallotId})
      : super(key: key);

  @override
  _LiveRankWidgeV2tState createState() => _LiveRankWidgeV2tState();
}

class _LiveRankWidgeV2tState extends State<LiveRankWidgetV2> {
  String tag = "LiveRankWidget";
  List quesDataList = List();
  Map quesMyData = Map();
  List starDataList = List();
  Map starMyData = Map();
  Color textColor = Color(0xFF666666);

  /// 创建控制器
  FRefreshController controller = FRefreshController();
  _TypeProvider _typeProvider = _TypeProvider();
  _OpacityProvider _opacityProvider = _OpacityProvider();
  _XYProvider _xyProvider = _XYProvider();
  Store<GSYState> store;

  //图标初始位置
  double xPosition;
  double yPosition;

  @override
  void initState() {
    getData();
    getUserData();
    getStarData();
    getUserStarData();
  }

  bool _isIos13 = DeviceInfo.instance.ios13();

  @override
  Widget build(BuildContext context) {
    store = StoreProvider.of(context);
    final screenSize = MediaQuery.of(context).size;
    xPosition = ScreenUtil.getInstance().screenWidth -
        MediaQuery.of(context).padding.right -
        ScreenUtil.getInstance().getWidthPx(55);
    yPosition = ScreenUtil.getInstance().screenHeight * 0.5;
    _xyProvider.setPosition(x: xPosition, y: yPosition);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    return ChangeNotifierProvider.value(
      value: _opacityProvider,
      child: Consumer<_OpacityProvider>(builder: (context, model, child) {
        return _buildBody(model, courseProvider);
      }),
    );
  }

  Widget _buildBody(model, courseProvider) {
    return Container(
      child: ChangeNotifierProvider.value(
          value: _typeProvider,
          child: Consumer<_TypeProvider>(builder: (context, model, child) {
            var dataList = model.type == 0 ? starDataList : quesDataList;
            var maData = model.type == 0 ? starMyData : quesMyData;
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    // Expanded(
                    //     child: FlatButton(
                    //         textColor: model.type == 0 ? Colors.white : Color(0xFFb2b1b9),
                    //         child: Text("星星榜"),
                    //         highlightColor: Colors.transparent,
                    //         color: model.type == 0 ? Color(0xffb2b1b9) : Colors.transparent,
                    //         onPressed: () {
                    //           model.switchType(0);
                    //         },
                    //         shape: RoundedRectangleBorder(
                    //             side: BorderSide(color: Colors.grey, width: 0.5),
                    //             borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))))),
                    // Expanded(
                    //   child: FlatButton(
                    //       textColor: model.type == 1 ? Colors.white : Color(0xFFb2b1b9),
                    //       child: Text(
                    //         "答题榜",
                    //       ),
                    //       highlightColor: Colors.transparent,
                    //       color: model.type == 1 ? Color(0xffb2b1b9) : Colors.transparent,
                    //       onPressed: () {
                    //         model.switchType(1);
                    //         print("switchType");
                    //       },
                    //       shape: RoundedRectangleBorder(
                    //           side: BorderSide(color: Colors.grey, width: 0.5),
                    //           borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)))),
                    // )
                    Expanded(
                      child: InkWell(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "星星榜",
                                style: TextStyle(
                                    color: model.type == 1
                                        ? Colors.white
                                        : Color(0xffAEAEAE)),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.getInstance().getHeightPx(15),
                            ),
                            model.type == 1
                                ? Container(
                                    width: ScreenUtil.getInstance()
                                        .getWidthPx(125),
                                    height:
                                        ScreenUtil.getInstance().getHeightPx(8),
                                    color: Color(0xFFAEAEAE),
                                  )
                                : Container(),
                          ],
                        ),
                        onTap: () {
                          model.switchType(1);
                        },
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "答题榜",
                                style: TextStyle(
                                    color: model.type == 0
                                        ? Colors.white
                                        : Color(0xffAEAEAE)),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.getInstance().getHeightPx(15),
                            ),
                            model.type == 0
                                ? Container(
                                    width: ScreenUtil.getInstance()
                                        .getWidthPx(125),
                                    height:
                                        ScreenUtil.getInstance().getHeightPx(8),
                                    color: Color(0xFFAEAEAE),
                                  )
                                : Container(),
                          ],
                        ),
                        onTap: () {
                          model.switchType(0);
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 0.2))),
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(15),
                ),
                Expanded(
                  child: dataList == null || dataList.length == 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset("images/live/rank/noneQueIcon.png",
                                width: ScreenUtil.getInstance().getWidthPx(150),
                                height:
                                    ScreenUtil.getInstance().getWidthPx(150)),
                            SizedBox(
                              height: ScreenUtil.getInstance().getWidthPx(10),
                            ),
                            Text("  暂无${model.type == 0 ? "星星" : "答题"}榜数据！",
                                style: TextStyle(color: Color(0xFFb2b1b9))),
                          ],
                        )
                      : FRefresh(
                          headerHeight: 60.0,
                          controller: controller,
                          header: Container(
                            width: 60.0,
                            height: 60.0,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: OverflowBox(
                              maxHeight: 100.0,
                              maxWidth: 100.0,
                              child: SpinKitRing(
                                color: Colors.grey,
                                size: 20,
                                lineWidth: 4,
                              ),
                            ),
                          ),
                          child: ListView.builder(
                            itemCount: dataList.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (_, i) {
                              return _buildLine(
                                  _getIcon(i),
                                  dataList[i]["headerImg"],
                                  dataList[i]["realName"],
                                  model.type == 0
                                      ? dataList[i]["star"]
                                      : dataList[i]["answerCount"],
                                  model.type,
                                  (i + 1).toString());
                            },
                          ),
                          onRefresh: () async {
                            /// 通过 controller 结束刷新
                            if (model.type == 0) {
                              await getStarData();
                              await getUserStarData();
                            } else {
                              await getData();
                              await getUserData();
                            }
                            controller.finishRefresh();
                          },
                        ),
                ),
                Container(
                  child: _buildLine(
                      _getIcon(maData["rank"] != null && maData["rank"] > 0
                          ? maData["rank"] - 1
                          : -1),
                      store.state.userInfo.headUrl,
                      "${store.state.userInfo.realName}",
                      model.type == 0 ? maData["star"] : maData["answerCount"],
                      model.type,
                      maData["rank"],
                      height: ScreenUtil.getInstance().getHeightPx(200),
                      color: Color(0xFFECB22B)),
                  decoration: BoxDecoration(
                    color: Color(0xff6666661),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(40),
                )
              ],
            );
          })),
    );
  }

   _getIcon(i) {
    if (i == null) {
      return "";
    }
    return i == 0
        ? getRankContainer(i+1,Color(0xffEC672B))
        : i == 1
            ? getRankContainer(i+1,Color(0xffEC922B))
            : i == 2
                ? getRankContainer(i+1,Color(0xffECB22B))
                : "";
  }

  Widget getRankContainer(int i,color){
    return Container(
      alignment: Alignment.center,
      width: ScreenUtil.getInstance().getWidthPx(40),
      height: ScreenUtil.getInstance().getWidthPx(40),
      decoration: BoxDecoration(
        color:color ,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        "${i}",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  _buildLine(topIcon, headerImg, realName, star, type, rank, {height, color}) {
    return Container(
      alignment: Alignment.centerLeft,
      height: height ?? ScreenUtil.getInstance().getHeightPx(180),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: ScreenUtil.getInstance().getWidthPx(10),
              ),
              topIcon != ""
                  ? topIcon
                  : Container(
                      alignment: Alignment.center,
                      width: ScreenUtil.getInstance().getWidthPx(40),
                      height: ScreenUtil.getInstance().getWidthPx(40),
                      child: Text(
                        "${rank == null || rank == -1 ? "暂未上榜" : rank}",
                        style: TextStyle(color: color ?? textColor),
                      ),
                    ),
              SizedBox(
                width: ScreenUtil.getInstance().getWidthPx(15),
              ),
              // ClipOval(
              //   child: CommonUtils.getHeaderImg("$headerImg",
              //       width: ScreenUtil.getInstance().getWidthPx(55),
              //       height: ScreenUtil.getInstance().getWidthPx(55)),
              // ),
              Text(
                "$realName",
                style: TextStyle(color: color ?? textColor),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                "$star ${type == 0 ? "" : "题"}",
                style: TextStyle(color: color ?? textColor),
              ),
              SizedBox(
                width: ScreenUtil.getInstance().getWidthPx(15 / 2),
              ),
              Image.asset(
                type == 0
                    ? "images/live/toolbar/icon_right.png"
                    : "images/live/toolbar/icon_star.png",
                width: ScreenUtil.getInstance().getWidthPx(28),
                height: ScreenUtil.getInstance().getWidthPx(28),
              ),
              SizedBox(
                width: ScreenUtil.getInstance().getWidthPx(15 / 2),
              ),
            ],
          )
        ],
      ),
    );
  }

  _testDataList() {
    quesDataList = List.generate(30, (index) {
      return {
        "userId": 1,
        "star": 5,
        "answerCount": 1,
        "rank": 1,
        "realName": "陈祥佳",
        "HeaderImg": ""
      };
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _eyeIcon() {
    return (Positioned(
      top: yPosition,
      left: xPosition,
      child: GestureDetector(
        child: Image.asset(
          'images/live/rank/btn-rank.png',
          width: ScreenUtil.getInstance().getWidthPx(55),
        ),
        onPanUpdate: (tapInfo) {
          // 控制上下左右溢出的情况（控制位置）
          controlPosition(tapInfo);
        },
        onTap: () {
          if (_opacityProvider.opacity != 1) {
            getData();
            getUserData();
            getStarData();
            getUserStarData();
          }
          _opacityProvider.setOpacity(_opacityProvider.opacity == 1 ? 0 : 1);
        },
      ),
    ));
  }

  // 目前只处理y轴的控制，后续有需求再增添x轴控制
  void controlPosition(tapInfo) {
    yPosition += tapInfo.delta.dy;
    // 最小限制
    if (yPosition < 45) {
      yPosition = 45;
      //最大限制
    } else if (yPosition >
        ScreenUtil.getInstance().screenHeight -
            ScreenUtil.getInstance().getWidthPx(55)) {
      yPosition = ScreenUtil.getInstance().screenHeight -
          ScreenUtil.getInstance().getWidthPx(55);
    }
    _xyProvider.setPosition(y: yPosition);
  }

  getData() async {
    var params = {
      "catalogId": widget.liveCourseallotId,
      "moLiveMapId": 1,
      "pageNo": 1,
      "pageSize": 20,
      "batchNo": widget.roomId
    };
    var res = await RoomDao.roomRankList(params);
    Log.f("roomRankList  ${res.toString()}", tag: tag);
    if (res.result != null && res.data != null && res.data["code"] == 200) {
      quesDataList = res.data["data"]["data"];
      _typeProvider.notify();
    } else {
      showToast("查询失败请稍后重试!!!");
    }
  }

  getUserData() async {
    var params = {
      "catalogId": widget.liveCourseallotId,
      "moLiveMapId": 1,
      "pageNo": 1,
      "pageSize": 20,
      "batchNo": widget.roomId
    };
    var res = await RoomDao.roomRankUser(params);
    Log.f("roomRankList  ${res.toString()}", tag: tag);
    if (res.result != null && res.data != null && res.data["code"] == 200) {
      quesMyData = res.data["data"];
      _typeProvider.notify();
    } else {
      showToast("查询失败请稍后重试!!!");
    }
  }

  getStarData() async {
    var params = {
      "liveCourseallotId": widget.liveCourseallotId,
      "pageNo": 1,
      "pageSize": 20,
      "roomId": widget.roomId
    };
    var res = await RoomDao.roomStarRankList(params);
    Log.f("roomRankList  ${res.toString()}", tag: tag);
    if (res.result != null && res.data != null && res.data["code"] == 200) {
      starDataList = res.data["data"]["data"];
      _typeProvider.notify();
    } else {
      showToast("查询失败请稍后重试!!!");
    }
  }

  getUserStarData() async {
    var params = {
      "liveCourseallotId": widget.liveCourseallotId,
      "roomId": widget.roomId
    };
    var res = await RoomDao.roomStarRankUser(params);
    Log.f("roomRankList  ${res.toString()}", tag: tag);
    if (res.result != null && res.data != null && res.data["code"] == 200) {
      starMyData = res.data["data"];
      _typeProvider.notify();
    } else {
      showToast("查询失败请稍后重试!!!");
    }
  }
}

class _TypeProvider with ChangeNotifier {
  int _type = 0;

  int get type => _type;

  switchType(int type) {
    _type = type;
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }
}

class _OpacityProvider with ChangeNotifier {
  double _opacity = 0.0;

  double get opacity => _opacity;

  setOpacity(double opacity) {
    _opacity = opacity;
    notifyListeners();
  }
}

class _XYProvider with ChangeNotifier {
  double _xPosition;
  double _yPosition;

  double get xPosition => _xPosition;

  double get yPosition => _yPosition;

  setPosition({double x, double y}) {
    _xPosition = x ?? _xPosition;
    _yPosition = y ?? _xPosition;
    notifyListeners();
  }
}
