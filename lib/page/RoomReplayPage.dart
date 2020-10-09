import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:better_socket/better_socket.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/const/LiveRoom.dart';
import 'package:flutter_start/models/replayData.dart';
import 'package:flutter_start/widget/ReplayProgress.dart';
import 'package:flutter_start/widget/seekbar/flutter_seekbar.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/RoomDao.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/Log.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/ChatMessage.dart';
import 'package:flutter_start/models/Courseware.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/models/RoomUser.dart';
import 'package:flutter_start/provider/provider.dart';
import 'package:flutter_start/widget/DIYKeyboard.dart';
import 'package:flutter_start/widget/GamePayleWidget.dart';
import 'package:flutter_start/widget/InputButtomWidget.dart';
import 'package:flutter_start/widget/LiveRankWidget.dart';
import 'package:flutter_start/widget/LiveTimerWidget.dart';
import 'package:flutter_start/widget/LiveTopDialog.dart';
import 'package:flutter_start/widget/LivesQuesWidget.dart';
import 'package:flutter_start/widget/RedPacket.dart';
import 'package:flutter_start/widget/RedRain.dart';
import 'package:flutter_start/widget/StarGif.dart';
import 'package:flutter_start/widget/UserStarWidget.dart';
import 'package:flutter_start/widget/courseware_video.dart';
import 'package:flutter_start/widget/expanded_viewport.dart';
import 'package:flutter_start/widget/seekbar/seekbar.dart';
import 'package:flutter_start/widget/starsWiget.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:oktoast/oktoast.dart';
import 'package:orientation/orientation.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:yondor_whiteboard/whiteboard.dart';

class RoomReplayPage extends StatefulWidget {
  static final String sName = "RoomLandscape";
  final RoomData roomData;
  final String token;
  const RoomReplayPage({Key key, this.roomData, this.token}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return RoomReplayPageState(roomData);
  }
}

class RoomReplayPageState extends State<RoomReplayPage> with SingleTickerProviderStateMixin, LogBase {
  static const String mp4 = LiveRoomConst.mp4;
  static const String ppt = LiveRoomConst.ppt;
  static const String h5 = LiveRoomConst.h5;
  static const String SEL = LiveRoomConst.SEL; //1:SEL 选择题
  static const String MULSEL = LiveRoomConst.MULSEL; //2:SEL 多选择题
  static const String JUD = LiveRoomConst.JUD; //4:JUD 判断题
  static const String RANRED = LiveRoomConst.RANRED; //80:RANRED 随机红包
  static const String REDRAIN = LiveRoomConst.REDRAIN; //81:REDRAIN 红包雨
  static const String TIMER = LiveRoomConst.TIMER; //timer  定时器
  static const String BREAK = LiveRoomConst.BREAK;
  static const String EVENT_HAND = LiveRoomConst.EVENT_HAND; //是否举手事件
  static const String BOARD = LiveRoomConst.BOARD; //白板切换事件
  static const String EVENT_BOARD = LiveRoomConst.EVENT_BOARD; //白板切换事件
  static const String EVENT_JOIN_SUCCESS = LiveRoomConst.EVENT_JOIN_SUCCESS; //加入房间返回成功事件
  static const String EVENT_CURRENT = LiveRoomConst.EVENT_CURRENT; //加入房间成功返回当前事件

  CourseProvider _courseProvider;
  ReplayProgressProvider _replayProgressProvider = ReplayProgressProvider();
  RoomReplayPageState(RoomData roomData) {
    _courseProvider = CourseProvider(1, roomData: roomData, closeDialog: closeDialog, showStarDialog: showStarDialog);
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      OrientationPlugin.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    }
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
    orientation = 1;
//    _initWebsocketManager();
//    initializeRtm();
//    initializeRtc();
    if (Platform.isIOS) {
      HomeIndicator.deferScreenEdges([ScreenEdge.bottom, ScreenEdge.top]);
    }
    _initWhiteboardController();
  }

  int orientation = 0;
  AgoraRtmClient _rtmClient;
  AgoraRtmChannel _rtmChannel;
  var socket;
  RoomUser _local;
  RoomUser _teacher;
  List<RoomUser> _others = new List();
  Widget _whiteboard;
  Res _currentRes;
  TeacherProvider _teacherProvider = TeacherProvider();
  StudentProvider _studentProvider = StudentProvider();
  HandTypeProvider _handTypeProvider = HandTypeProvider();
  RoomShowTopProvider _roomShowTopProvider = RoomShowTopProvider();
  ResProvider _resProvider = ResProvider();
  BoardProvider _boardProvider = BoardProvider();
  ChatProvider _chatProvider = ChatProvider();
  RoomSelProvider _roomSelProvider = RoomSelProvider();
  HandProvider _handProvider = HandProvider();
  LiveTimerProvider _liveTimerProvider = LiveTimerProvider();
  StarWidgetProvider _starWidgetProvider = StarWidgetProvider();
  WebViewPlusController _webViewPlusController;
  int _isPlay;
  int _time;
  final TextEditingController _textController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final _infoStrings = <String>[];
  static final _users = <int>[];
  WhiteboardController _whiteboardController = WhiteboardController();
  Timer _hiddenTopTimer;
  FlickManager flickManager;
  FijkPlayer _teacherPlayer = FijkPlayer();
  Timer _socketPingTimer;
  Duration _socketPingDuration = Duration(seconds: 45);
  bool isShowDialog = false;
  double testV = 0.0;
  bool isShowTip = true;
  Timer isShowTipTimer;
  @override
  Widget build(BuildContext context) {
    var coursewareWidth = (ScreenUtil.getInstance().screenWidth * 0.8) - MediaQuery.of(context).padding.left;
    var maxWidth = coursewareWidth > ScreenUtil.getInstance().screenHeight * 1.5 ? ScreenUtil.getInstance().screenHeight * 1.5 : coursewareWidth;
    print(
        "top ${MediaQuery.of(context).padding.top} bottom ${MediaQuery.of(context).padding.bottom} left ${MediaQuery.of(context).padding.left} right ${MediaQuery.of(context).padding.right}");
    _courseProvider.setCoursewareWidth(coursewareWidth, maxWidth);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<CourseProvider>.value(
            value: _courseProvider,
          ),
          ChangeNotifierProvider<TeacherProvider>.value(
            value: _teacherProvider,
          ),
          ChangeNotifierProvider<HandTypeProvider>.value(
            value: _handTypeProvider,
          ),
          ChangeNotifierProvider<StudentProvider>.value(
            value: _studentProvider,
          ),
          ChangeNotifierProvider<ChatProvider>.value(
            value: _chatProvider,
          ),
          ChangeNotifierProvider<RoomShowTopProvider>.value(
            value: _roomShowTopProvider,
          ),
          ChangeNotifierProvider<ResProvider>.value(
            value: _resProvider,
          ),
          ChangeNotifierProvider<BoardProvider>.value(
            value: _boardProvider,
          ),
          ChangeNotifierProvider<RoomSelProvider>.value(
            value: _roomSelProvider,
          ),
          ChangeNotifierProvider<HandProvider>.value(
            value: _handProvider,
          ),
          ChangeNotifierProvider<LiveTimerProvider>.value(
            value: _liveTimerProvider,
          ),
          ChangeNotifierProvider<StarWidgetProvider>.value(
            value: _starWidgetProvider,
          ),
          ChangeNotifierProvider<ReplayProgressProvider>.value(
            value: _replayProgressProvider,
          ),
        ],
        child: WillPopScope(
          onWillPop: () {
            _back();
            return Future.value(false);
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Scaffold(
                resizeToAvoidBottomPadding: false,
                appBar: PreferredSize(
                    child: Offstage(
                      offstage: true,
                      child: AppBar(
                        elevation: 0,
                        centerTitle: true,
                        title: Text(
                          widget.roomData.courseware.name,
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Color(0xFFffffff),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          color: Color(0xFF333333), //自定义图标
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.07)),
                body: SafeArea(
                    left: false,
                    right: Platform.isAndroid,
                    bottom: Platform.isAndroid,
                    child: Padding(
                        padding: EdgeInsets.only(top: ScreenUtil.getInstance().statusBarHeight, left: MediaQuery.of(context).padding.left),
                        child: Stack(
                          children: <Widget>[
                            Row(children: <Widget>[
                              //课件窗口
                              _buildCourseware(),
                              //右边栏
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    //视频窗口
                                    _buildVideo(),
                                    //聊天窗口
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          //  点击顶部空白处触摸收起键盘
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          showTopAndBottom();
                                        },
                                        child: _buildChat(),
                                      ),
                                    ),
//                                    _buildTextComposer(),
                                  ],
                                ),
                              )
                            ]),
//                            Consumer<CourseProvider>(builder: (context, model, child) {
//                              return model.status == 1 ? UserStarWidget() : Container();
//                            }),
                            Consumer<CourseProvider>(builder: (context, model, child) {
                              return model.status == 1 ? _getLiveTimerWidget() : Container();
                            }),
//                            Consumer<CourseProvider>(builder: (context, model, child) {
//                              return model.status == 1 ? _buildRank() : Container();
//                            }),
                            Consumer<CourseProvider>(builder: (context, model, child) {
                              return model.status == 1
                                  ? Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: _buildSel(),
                                    )
                                  : Container();
                            }),
                            _buildTop(),
                            ReplayProgress(
                              whiteboardController: _whiteboardController,
                              teacherPlayer: _teacherPlayer,
                              handleSocketMsg: _handleSocketMsg,
                              showTopAndBottom: showTopAndBottom,
                            ),
                          ],
                        )))),
          ),
        ));
  }

  ///倒计时组件
  _getLiveTimerWidget() {
    return Consumer<LiveTimerProvider>(builder: (context, model, child) {
      print("model.time ${model.time}");
      return model.isShow
          ? Positioned(
              right: ScreenUtil.getInstance().screenWidth * 0.2,
              top: 0,
              child: LiveTimerWidget(
                time: model.time,
                callback: () {
                  model.show(false, 0);
                },
              ),
            )
          : Container();
    });
  }

  _buildRank() {
    return Align(
        alignment: Alignment.topLeft, child: LiveRankWidget(liveCourseallotId: widget.roomData.liveCourseallotId, roomId: widget.roomData.room.roomUuid));
  }

  closeDialog() {
    if (!ModalRoute.of(context).isCurrent) {
      Navigator.of(context).pop();
    }
  }

  ///构建选择题
  Widget _buildSel() {
    return LiveQuesWidget(
      isReplay: true,
    );
  }

  Widget _buildCourseware() {
    return Consumer2<CourseProvider, ResProvider>(builder: (context, courseStatusModel, resModel, child) {
      Widget result;
      print("left with:${courseStatusModel.coursewareWidth} height:${ScreenUtil.getInstance().screenHeight}");
      if (courseStatusModel.status == 0) {
        result = Container(
          child: Stack(
            alignment: Alignment(-0.9, -0.9),
            children: <Widget>[
              GestureDetector(
                  onTap: () => _roomShowTopProvider.setIsShow(true),
                  child: Container(
                      alignment: Alignment.center,
                      color: Colors.black,
                      child: Image.file(
                        File("${widget.roomData.courseware.localPath}/${widget.roomData.courseware.findFirst().data.ps.pic}"),
                        fit: BoxFit.contain,
                      ))),
            ],
          ),
        );
      } else if (resModel.res != null && resModel.res.screenId != null && resModel.res.screenId > 0) {
        result = GestureDetector(
          key: ValueKey("screen"),
          child: Container(child: AgoraRenderWidget(resModel.res.screenId)),
          onTap: () => _roomShowTopProvider.setIsShow(true),
        );
      } else if (resModel.res != null) {
        if (resModel.res.type == h5) {
          if (Platform.isIOS) {
//            if (resModel.isShow == null || !resModel.isShow) {
//              Future.delayed(Duration(milliseconds: 500), () {
//                _boardProvider.setTestBoard(0);
//                Future.delayed(Duration(milliseconds: 500), () {
//                  _boardProvider.setTestBoard(1);
//                });
//              });
//            }
          }
          print("${resModel.isShow == null || !resModel.isShow}resModel.isShow == null || !resModel.isShow");
          result = Container(
            color: Colors.black,
            child: WebViewPlus(
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              javascriptMode: JavascriptMode.unrestricted,
              javascriptChannels: <JavascriptChannel>[
                JavascriptChannel(
                    name: 'Courseware',
                    onMessageReceived: (JavascriptMessage message) async {
                      var msg = jsonDecode(message.message);
                      Log.f("@收到Courseware 回调 $msg", tag: RoomReplayPage.sName);
                      Store<GSYState> store = StoreProvider.of(context);
                      BetterSocket.sendMsg(jsonEncode({
                        "Event": {
                          "event": "event-doCourseware",
                          "msg": '{"qid":${resModel.res.qid},"isFinish":true,"uid":${store.state.userInfo.userId}}',
                        }
                      }));
                    })
              ].toSet(),
              onWebViewCreated: (controller) async {
                _webViewPlusController = controller;
                print("loadurl ${widget.roomData.courseware.localPath + "/" + await CommonUtils.urlJoinUser(resModel.res.data.ps.h5url)}");
                controller.loadUrl(widget.roomData.courseware.localPath + "/" + await CommonUtils.urlJoinUser(resModel.res.data.ps.h5url));
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                new Factory<OneSequenceGestureRecognizer>(
                  () => new EagerGestureRecognizer(),
                ),
              ].toSet(),
            ),
          );
        } else if (resModel.res.type == ppt ||
            resModel.res.type == BREAK ||
            resModel.res.type == JUD ||
            resModel.res.type == SEL ||
            resModel.res.type == MULSEL ||
            resModel.res.type == RANRED ||
            resModel.res.type == REDRAIN) {
          result = GestureDetector(
            child: Container(
                child: Image.file(
              File(widget.roomData.courseware.localPath + "/" + resModel.res.data.ps.pic),
              fit: BoxFit.contain,
            )),
            onTap: () => _roomShowTopProvider.setIsShow(true),
          );
        } else if (resModel.res.type == mp4) {
          if (flickManager == null) {
            File file = File(widget.roomData.courseware.localPath + "/" + resModel.res.data.ps.mp4);
            flickManager = FlickManager(
              autoPlay: _isPlay != null && _isPlay == 1,
              videoPlayerController: file.existsSync()
                  ? VideoPlayerController.file(file)
                  : VideoPlayerController.network(widget.roomData.courseware.domain + resModel.res.data.ps.mp4),
            );
            if (_time != null && _time > 0) {
              Future.delayed(Duration(seconds: 2), () async {
                if (_isPlay != null && _isPlay == 1) {
                  flickManager.flickControlManager?.seekTo(Duration(seconds: _time + 2));
                  flickManager?.flickControlManager?.play();
                } else {
                  flickManager.flickControlManager?.seekTo(Duration(seconds: _time));
                }
              });
            }
          }
          result = Container(
            child: CoursewareVideo(flickManager,
                pic: "${widget.roomData.courseware.localPath}/${resModel.res.data.ps.pic}", soundAction: () => _roomShowTopProvider.setIsShow(true)),
          );
        }
      }

      if (!(resModel.res != null && resModel.res.screenId != null && resModel.res.screenId > 0)) {
        result = Container(
          color: (resModel.res == null && courseStatusModel.status != 0) ? Colors.white : Colors.black,
          width: courseStatusModel.coursewareWidth,
          child: Center(
            child: Container(
              width: courseStatusModel.maxWidth,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 800),
                    child: result != null
                        ? Container(
                            key: ValueKey("${resModel?.res?.qid ?? 0}"),
                            child: result,
                          )
                        : Container(),
                  ),
                  Consumer<BoardProvider>(builder: (context, model, child) {
                    print("courseStatusModel.isInitBoardView ${courseStatusModel.isInitBoardView}");
                    var show = true;
                    if (courseStatusModel.isInitBoardView) {
                      show = (courseStatusModel.status == 1 && model.enableBoard == 1);
                      if (show) {
                        if (resModel != null && resModel.res != null && resModel.res.type != null && resModel.res.type == h5 && model.testBoard == 0) {
                          show = false;
                        } else if (resModel != null &&
                            resModel.res != null &&
                            resModel.res.type != null &&
                            resModel.res.type == h5 &&
                            resModel.isShow != null &&
                            resModel.isShow) {
                          show = false;
                        }
                      }
                    }

                    return Offstage(
                        offstage: Platform.isIOS ? false : !(show),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            (Platform.isIOS && !show)
                                ? Positioned(
                                    width: 1,
                                    height: 1,
                                    child: Container(
                                      child: _buildWhiteboard(),
                                    ))
                                : Positioned(
                                    child: Container(
                                    child: _buildWhiteboard(),
                                  )),
                            (Platform.isIOS && !show)
                                ? Container()
                                : GestureDetector(
                                    onTap: () {
                                      showTopAndBottom(isShow: show);
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      width: courseStatusModel.maxWidth,
                                      height: ScreenUtil.getInstance().screenHeight,
                                    ),
                                  )
                          ],
                        ));
                  }),

                  (resModel != null && resModel.res != null && resModel.res.type != null && resModel.res.type == h5) &&
                          (resModel.isShow == null || !resModel.isShow)
                      ? Container(
                          color: Colors.transparent,
                          width: courseStatusModel.maxWidth,
                          height: ScreenUtil.getInstance().screenHeight,
                          child: GestureDetector(
                            onTap: () {
                              if (isShowTip) {
                                isShowTip = false;
                                showToast("等待老师开始游戏");
                                if (isShowTipTimer == null || !isShowTipTimer.isActive) {
                                  isShowTipTimer = Timer(Duration(milliseconds: 3000), () {
                                    isShowTip = true;
                                  });
                                }
                              }
                            },
                          ),
                        )
                      : Container(
                          height: 0,
                          width: 0,
                        ),
                  //举手按钮
                  Consumer<HandProvider>(builder: (context, model, child) {
                    if (courseStatusModel.status == 1 && !model.enableHand && _handTypeProvider.type != 1) {
                      Future.microtask(() => _handTypeProvider.switchType(1));
                    }
                    if (courseStatusModel.status == 0 && model.enableHand) {
                      Future.microtask(() => model.setEnableHand(false));
                    }
                    return Offstage(
                      offstage: !(courseStatusModel.status == 1 && model.enableHand),
                      child: Align(
                        alignment: AlignmentDirectional(0.9, 0.9),
                        child: Consumer<HandTypeProvider>(builder: (context, model, child) {
                          return GestureDetector(
                            child: Container(
                              child: Image.asset(
                                model.type == 1 ? 'images/ic_hand_up.png' : 'images/ic_hand_down.png',
                                width: ScreenUtil.getInstance().getHeightPx(225),
                              ),
                            ),
                            onTap: () {
                              _hand();
                            },
                          );
                        }),
                      ),
                    );
                  }),
                  //学生视频

                  Offstage(
                    offstage: !(courseStatusModel.status == 1),
                    child: Align(
                      alignment: AlignmentDirectional(0.98, -0.98),
                      child: _buildStudentVideo(),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }

      return result;
    });
  }

  ///左上角 星星
  Widget _starWidget() {
    return Consumer<StarWidgetProvider>(builder: (context, model, child) {
      return Positioned(
        top: 12,
        left: 20,
        child: new Container(
          color: Color(0xFF00000021),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Opacity(
                opacity: 0.9,
                child: new Chip(
                  backgroundColor: Color(0xFF000000).withOpacity(0.7),
                  avatar: Opacity(
                    opacity: 1,
                    child: Image.asset(
                      "images/live/chat/icon_star.png",
                      width: ScreenUtil.getInstance().getWidth(15),
                    ),
                  ),
                  label: Text(
                    "${model.star}",
                    style: TextStyle(
                      color: Color(0xFFff8400).withOpacity(1),
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.getInstance().getSp(42) / 4,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  gameStart() async {
//    return NavigatorUtil.showGSYDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return GamePayleWidget();
//        });
    print("gameStart gameStart");
    Future(() {
      return Navigator.push(context, PopRoute(child: GamePayleWidget()));
    });
//    Future.delayed(Duration(milliseconds: 500), () {
//
//    });
  }

  Widget _buildTop() {
    return Consumer<RoomShowTopProvider>(builder: (context, model, child) {
      return Positioned(
          top: 0,
          child: AnimatedOpacity(
            opacity: model.isShow ? 1 : 0,
            duration: new Duration(seconds: 1),
            child: model.isShow
                ? Container(
                    color: Colors.black38,
                    height: ScreenUtil.getInstance().screenHeight * 0.13,
                    width: ScreenUtil.getInstance().screenWidth,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                            icon: new Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: ScreenUtil.getInstance().getSp(10),
                            ),
                            onPressed: () {
                              _back();
                            }),
                        SizedBox(
                          width: ScreenUtil.getInstance().getWidthPx(12),
                        ),
                        Text(widget.roomData.courseware.name, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getInstance().getSp(10)))
                      ],
                    ))
                : Container(),
          ));
    });
  }

  ///视频区域
  Widget _buildVideo() {
    FijkView result = FijkView(
      width: ScreenUtil.getInstance().screenWidth * 0.2,
      height: ScreenUtil.getInstance().getHeightPx(550),
      player: _teacherPlayer,
      color: Colors.black,
      panelBuilder: (FijkPlayer player, FijkData data, BuildContext context, Size viewSize, Rect texturePos) {
        return Container();
      },
      cover: Image.asset('images/ic_teacher.png', fit: BoxFit.fill).image,
    );
    return result;
    return Consumer2<TeacherProvider, CourseProvider>(builder: (context, teacherModel, courseStatusModel, child) {
      final flag = courseStatusModel.status == 1 && teacherModel.user != null && teacherModel.user.coVideo == 1 && teacherModel.user.enableVideo == 1;
      return Container(
//              alignment:Alignment.center,
//              color: Colors.red,
          width: ScreenUtil.getInstance().screenWidth * 0.2,
          height: ScreenUtil.getInstance().getHeightPx(550),
          child: flag
              ? AgoraRenderWidget(teacherModel.user.uid)
              : Container(
                  color: Colors.white,
                  child: Image.asset('images/ic_teacher.png', fit: BoxFit.fill, width: ScreenUtil.getInstance().screenWidth * 0.2
//                    height: ScreenUtil.getInstance().getWidthPx(200),
                      ),
                ));
    });
  }

  Widget _buildStudentVideo() {
    return Consumer<StudentProvider>(builder: (context, model, child) {
//      AgoraRtcEngine.setClientRole(model.user.coVideo == 1 ? ClientRole.Broadcaster : ClientRole.Audience);
//      if (_teacher != null && _teacher.coVideo == 1 && model.user.coVideo == 1) {
//        AgoraRtcEngine.muteLocalAudioStream(model.user.enableVideo != 1);
//        AgoraRtcEngine.muteLocalVideoStream(model.user.enableAudio != 1);
//        if (model.user.enableVideo == 1) {
//          AgoraRtcEngine.enableLocalVideo(true);
//        }
//        if (model.user.enableAudio == 1) {
//          AgoraRtcEngine.enableLocalAudio(true);
//        }
//      }

      Widget widget = Container();
//      if (model.user.coVideo == 1) {
//        widget = Container(
//            color: Colors.white,
//            width: ScreenUtil.getInstance().screenWidth * 0.15,
//            height: ScreenUtil.getInstance().getHeightPx(500),
//            child: model.user.coVideo == 1 && model.user.enableVideo == 1
//                ? AgoraRenderWidget(model.user.uid, local: true)
//                : Container(
//                    color: Colors.white,
//                    child: Image.asset(
//                      'images/ic_student.png',
//                    )));
//      } else if (_others.length > 0) {
//        widget = Container(
//            color: Colors.white,
//            width: ScreenUtil.getInstance().screenWidth * 0.15,
//            height: ScreenUtil.getInstance().getHeightPx(500),
//            child: _others[0].coVideo == 1 && _others[0].enableVideo == 1
//                ? AgoraRenderWidget(_others[0].uid)
//                : Container(
//                    color: Colors.white,
//                    child: Image.asset(
//                      'images/ic_student.png',
//                      width: ScreenUtil.getInstance().screenWidth,
//                      height: ScreenUtil.getInstance().getWidthPx(550),
//                    )));
//      }
      return widget;
    });
  }

  ///聊天内容
  Widget _buildTextComposer() {
    return Stack(children: <Widget>[
      GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            decoration: BoxDecoration(),
          )),
      Column(
        children: <Widget>[
          Divider(height: 1.0),
          Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: IconTheme(
                  data: IconThemeData(color: Theme.of(context).accentColor),
                  child: Consumer<ChatProvider>(builder: (context, model, child) {
                    return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(children: <Widget>[
                          Flexible(
                              child: InkWell(
                            child: TextField(
                              readOnly: true,
                              controller: _textController,
                              onChanged: (String text) {
                                model.setIsComposing(_textController.text.length > 0);
                              },
                              onTap: () {
                                _showKeyboard(model);
                              },
                              onSubmitted: _handleSubmitted,
                              decoration: InputDecoration.collapsed(hintText: model.muteAllChat ? "禁言中" : '发送消息'),
                            ),
                          )),
                          !model.muteAllChat
                              ? Container(
                                  margin: EdgeInsets.symmetric(horizontal: 1.0),
                                  child: IconButton(icon: Icon(Icons.send), onPressed: model.isComposing ? () => _handleSubmitted(_textController.text) : null),
                                )
                              : Container()
                        ]));
                  }))),
        ],
      )
    ]);
  }

  ///弹出键盘
  void _showKeyboard(model) {
    if (model.muteAllChat) {
      return;
    }
    closeDialog();
    NavigatorUtil.showGSYDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Keyboard(controller: _textController, sendExpression: _sendIcon, submit: () => {_handleSubmitted(_textController.text)});
        });
    // showDialog(
    //     barrierColor: Color.fromRGBO(255, 255, 255, 0.1),
    //     context: context,
    //     barrierDismissible: true,
    //     builder: (BuildContext context) {
    //       return Keyboard(
    //           controller: _textController,
    //           sendExpression: _sendIcon,
    //           submit: () => {_handleSubmitted(_textController.text)});
    //     });
  }

  ///发送表情
  Future<void> _sendIcon(msg) async {
    _handleSubmitted("[/" + msg + "]");
  }

  ///发送信息
  Future<void> _handleSubmitted(String text) async {
    if (text.trim() == "") return;
    _textController.clear();
    _chatProvider.setIsComposing(false);
    FocusScope.of(context).requestFocus(new FocusNode());
    RoomDao.roomChat(widget.roomData.room.roomId, widget.token, text);
  }

  ///初始化消息
  Future<void> initializeRtm() async {
    _rtmClient = await AgoraRtmClient.createInstance(Config.APP_ID);
    print("rtmToken ${widget.roomData.user.rtmToken}  uid ${widget.roomData.user.uid.toString()}");
    _rtmClient.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      _handlePeerMsg(message, peerId);
    };
    _rtmClient.onConnectionStateChanged = (int state, int reason) {
      _log('Connection state changed: ' + state.toString() + ', reason: ' + reason.toString());
      if (state == 5) {
        _rtmClient.logout();
        _log('Logout.');
      }
    };
    await _rtmClient.login(widget.roomData.user.rtmToken, widget.roomData.user.uid.toString());
    _rtmChannel = await _createChannel(widget.roomData.room.channelName);
    await _rtmChannel.join();
    Store<GSYState> store = StoreProvider.of(context);
    Log.d("Store<GSYState> ${store.state.userInfo.toJson()}", tag: RoomReplayPage.sName);
    try {
      List<Map<String, String>> attributes = List();
      Map<String, String> attribute = Map();
      attribute["uid"] = store.state.userInfo.userId.toString();
      attribute["role"] = "student";
      attribute["name"] = store.state.userInfo.realName;
      if (!ObjectUtil.isEmptyString(store.state.userInfo.headUrl)) {
        attribute["url"] = store.state.userInfo.headUrl;
      }
      attribute.forEach((key, value) {
        attributes.add({"key": key, "value": value});
      });
      print("=======================attribute attribute >$attributes");
      _rtmClient.setLocalUserAttributes(attributes);
    } catch (e) {
      print("=======================>${e.toString()}");
    }
  }

  _handlePeerMsg(AgoraRtmMessage message, String peerId) {
    _log("Peer msg: " + peerId + ", msg: " + message.text);
    var msgJson = jsonDecode(message.text);
    switch (msgJson["cmd"]) {
      //co-video operation msg
      case 1:
        if (msgJson["data"]["type"] == (CoVideoType.REJECT.index + 1)) {
          showToast("老师拒绝了你的连麦申请！");
        } else if (msgJson["data"]["type"] == (CoVideoType.ACCEPT.index + 1)) {
          _handTypeProvider.switchType(0);
          showToast("老师接受了你的连麦申请！");
        } else if (msgJson["data"]["type"] == (CoVideoType.ABORT.index + 1)) {
          _handTypeProvider.switchType(1);
          showToast("连麦结束！");
        }
        break;
    }
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _rtmClient.createChannel(name);
    channel.onMemberJoined = (AgoraRtmMember member) {
      _log("Member joined: " + member.userId + ', channel: ' + member.channelId);
    };
    channel.onMemberLeft = (AgoraRtmMember member) {
      _log("Member left: " + member.userId + ', channel: ' + member.channelId);
    };
    channel.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
      _handleMsg(message, member);
    };
    channel.onMemberCountUpdated = (int count) {
      _log("Channel onMemberCountUpdated:  count:$count ");
    };
    channel.onError = (err) {
      _log("Channel err:  err:$err ");
    };
    return channel;
  }

  _handleMsg(AgoraRtmMessage message, AgoraRtmMember member) {
    _log("Channel msg: " + member.userId + ", msg: " + message.text);
    var msgJson = jsonDecode(message.text);
    switch (msgJson["cmd"]) {
      case 1: //simple chat msg
        ChatMessage chatMessage = ChatMessage(
            timestamp: msgJson["timestamp"],
            userId: msgJson["data"]["userId"],
            userName: msgJson["data"]["userName"],
            type: msgJson["data"]["type"],
            message: msgJson["data"]["message"]);
        _chatProvider.insertChatMessageList(chatMessage);
        break;
      case 2: // user join or leave msg
        break;
      case 3: //room attributes updated msg
        _whiteboardController.updateRoom(isBoardLock: msgJson["data"]["lockBoard"]);
        _chatProvider.setMuteAllChat(msgJson["data"]["muteAllChat"] == 1);
        if (msgJson["data"]["courseState"] != _courseProvider.status) {
          _courseProvider.setStatus(msgJson["data"]["courseState"]);
        }
        break;
      case 4: //user attributes updated msg
        List<RoomUser> coVideoUsers = new List();
        msgJson["data"].forEach((item) {
          coVideoUsers.add(RoomUser.fromJson(item));
        });
        _updateUsers(coVideoUsers);
        break;
      case 5: //replay msg
    }
  }

  Future<void> initializeRtc() async {
    await AgoraRtcEngine.create(Config.APP_ID);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(ClientRole.Audience);
    await AgoraRtcEngine.enableDualStreamMode(false);
    await AgoraRtcEngine.setRemoteDefaultVideoStreamType(0);
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(480, 360);
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(widget.roomData.user.rtcToken, widget.roomData.room.channelName, widget.roomData.user.userName, widget.roomData.user.uid);
    if (_teacher != null) {
      _teacherProvider.notifier(_teacher);
    }
  }

  bool _enableLocalVideo = false;
  bool _enableLocalAudio = false;
  _startVideo(RoomUser user) async {
    print("_startVideo ::_local $_local");
    AgoraRtcEngine.setClientRole(user.coVideo == 1 ? ClientRole.Broadcaster : ClientRole.Audience);
    if (_teacher != null && _teacher.coVideo == 1 && user.coVideo == 1) {
      if (!_enableLocalVideo) {
        _enableLocalVideo = true;
        AgoraRtcEngine.enableLocalVideo(true);
      }
      if (!_enableLocalAudio) {
        _enableLocalVideo = true;
        AgoraRtcEngine.enableLocalAudio(true);
      }
      AgoraRtcEngine.muteLocalAudioStream(user.enableAudio == 0);
      AgoraRtcEngine.muteLocalVideoStream(user.enableVideo == 0);
    } else if (user.coVideo == 0) {
      _enableLocalVideo = false;
      _enableLocalAudio = false;
      AgoraRtcEngine.muteLocalAudioStream(true);
      AgoraRtcEngine.muteLocalVideoStream(true);
      AgoraRtcEngine.enableLocalVideo(false);
      AgoraRtcEngine.enableLocalAudio(false);
    }
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      final info = 'onError: $code';
      print("onError: $code");
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      final info = 'onJoinChannel: $channel, uid: $uid';
      print("onJoinChannelSuccess: $info");
    };

    AgoraRtcEngine.onLeaveChannel = () {
      _infoStrings.add('onLeaveChannel');
      print("onLeaveChannel");
      _users.clear();
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      final info = 'userJoined: $uid';
      print("onUserJoined : $info");
      if (_teacher != null && _teacher.screenId == uid) {
        _resProvider.setScreen(uid);
      }
      _users.add(uid);
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      final info = 'userOffline: $uid';
      print("onUserOffline : $info");
      if (_teacher != null && _teacher.screenId == uid) {
        _resProvider.setScreen(0);
      }
      _users.remove(uid);
    };
    AgoraRtcEngine.onFirstRemoteVideoFrame = (int uid, int width, int height, int elapsed) {
      final info = 'firstRemoteVideo: $uid ${width}x $height';
      print("onFirstRemoteVideoFrame : $info");
    };
  }

  void _log(String info) {
    print(info);
    _infoStrings.insert(0, info);
  }

  void _updateUsers(List<RoomUser> coVideoUsers) {
    RoomUser local;
    RoomUser teacher;
    List<RoomUser> others = new List();
    coVideoUsers?.forEach((u) {
      if (u.isTeacher()) {
        teacher = u;
      } else if (u.userId == _local.userId) {
        local = u;
      } else {
        others.add(u);
      }
    });

    if (ObjectUtil.isNotEmpty(teacher)) {
      _teacher = teacher;
    } else {
      _teacher?.coVideo = 0;
    }
    _teacherProvider.notifier(_teacher);

    if (ObjectUtil.isNotEmpty(local)) {
      _local = local;
    } else {
      _local?.coVideo = 0;
    }
    _startVideo(_local);
    _others.clear();
    _others.addAll(others);
    _studentProvider.notifier(_local);
  }

  ///白板区域
  Widget _buildWhiteboard() {
    if (_whiteboard == null) {
      _whiteboard = Container(
          child: Whiteboard(
              appIdentifier: "w0MeEJFIEeqZsrtGYadcXg/CnI3nUtyIcYaNg",
              uuid: widget.roomData.boardId,
              roomToken: widget.roomData.boardToken,
              controller: _whiteboardController,
              isReplay: 1));
    }
    return _whiteboard;
  }

  _hand() async {
    if (_handTypeProvider.type == 1) {
      //举手
      await RoomDao.roomCoVideo(widget.roomData.room.roomId, widget.token, CoVideoType.APPLY);
    } else {
      //取消连麦
//      var res = await RoomDao.roomCoVideo(widget.roomData.room.roomId, widget.token, _local.coVideo == 1 ? CoVideoType.EXIT : CoVideoType.CANCEL);
//      if (res.data["msg"] == "Success") {
//        _handTypeProvider.switchType(1);
//      }
    }
  }

  double fontSize = ScreenUtil.getInstance().getSp(12 / 2);

  ///聊天区域
  Widget _buildChat() {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: Scrollable(
        physics: AlwaysScrollableScrollPhysics(),
        controller: listScrollController,
        axisDirection: AxisDirection.up,
        viewportBuilder: (context, offset) {
          return ExpandedViewport(
            offset: offset,
            axisDirection: AxisDirection.up,
            slivers: <Widget>[
              SliverExpanded(),
              Consumer<ChatProvider>(builder: (context, model, child) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (c, i) {
                      return Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(right: 5.0, left: 3, top: 5, bottom: 5),
                          child: new Flex(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  model.chatMessageList[i].userName + ":",
                                  style: TextStyle(fontSize: fontSize, color: Colors.black),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: _getChatWidget(model.chatMessageList[i].message),
                              )
                            ],
                          ));
                    },
                    childCount: model.chatMessageList.length,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  ///获取一个聊天
  _getChatWidget(msg) {
    var _box;
    switch (msg) {
      case "[/1]":
        _box = _getImageWidgt("1Icon");
        break;
      case "[/2]":
        _box = _getImageWidgt("2Icon");
        break;
      case "[/666]":
        _box = _getImageWidgt("666Icon");
        break;
      case "[/flower]":
        _box = _getImageWidgt("flowerIcon");
        break;
      case "[/gift]":
        _box = _getImageWidgt("giftIcon");
        break;
      case "[/heartIcon]":
        _box = _getImageWidgt("heartIcon");
        break;
      case "[/zan]":
        _box = _getImageWidgt("zanIcon");
        break;
      case "[/ok]":
        _box = _getImageWidgt("okIcon");
        break;
      default:
        _box = Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            msg,
            style: TextStyle(fontSize: fontSize, color: Colors.black87),
          ),
        );
    }
    return _box;
  }

  ///获取一个图标
  _getImageWidgt(name) {
    return new Row(
      children: [
        new Image.asset(
          "images/live/chat/${name}.png",
          height: ScreenUtil.getInstance().getWidthPx(25),
        )
      ],
    );
  }

  _initWhiteboardController() async {
    final courseRecordData = widget.roomData.courseRecordData;
    //开始时间
    var beginTimestamp = courseRecordData.startTime;
    //时长
    var duration = (courseRecordData.endTime - courseRecordData.startTime).abs();
    _replayProgressProvider.init(duration: Duration(milliseconds: duration));

    _whiteboardController.onCreated = (result) async {
      print("_whiteboardController  $result");
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _courseProvider.setInitBoardView(true);
      });
      await _teacherPlayer.setOption(FijkOption.formatCategory, "fflags", "fastseek");
      await _teacherPlayer.setOption(FijkOption.hostCategory, "request-audio-focus", 1);
      await _teacherPlayer.setDataSource(courseRecordData.url, autoPlay: false, showCover: true).catchError((e) {
        print("setDataSource error: $e");
      });
      _whiteboardController.startReplay(beginTimestamp: beginTimestamp, duration: duration, mediaURL: courseRecordData.url);
    };
    var params = {
      "liveCourseallotId": _courseProvider.roomData.liveCourseallotId,
      "roomId": _courseProvider.roomData.room.roomUuid,
      "startTime": courseRecordData.startTime,
      "endTime": courseRecordData.endTime
    };
    print("RoomDao.getReplayInfo param $params");
    final res = await RoomDao.getReplayInfo(params);
    if (!res.result) {
      showToast("#1出错啦！！");
      return;
    }
    ReplayData data = res.data;
    data.list.forEach((ReplayItem element) {
//      element.playTime = element.t - courseRecordData.startTime + 12000;
      element.playTime = element.pt;
      var decode = json.decode(element.op);
      final jsonText = decode["Event"]["msg"];
      element.op = jsonText;
    });
    _courseProvider.roomData.courseRecordData.coursewareOp = data;
    print("_courseProvider.roomData.courseRecordData.coursewareOp ${_courseProvider.roomData.courseRecordData.coursewareOp}");
  }

  _initWebsocketManager() async {
    String key = await httpManager.getAuthorization();
    //设置监听
    BetterSocket.addListener(onOpen: (httpStatus, httpStatusMessage) {
      Log.i("onOpen---httpStatus:$httpStatus  httpStatusMessage:$httpStatusMessage", tag: RoomReplayPage.sName);
      _socketPingTimer?.cancel();
      _socketPingTimer = null;
      _socketPingTimer = Timer.periodic(_socketPingDuration, (timer) {
        Log.d('sendMsg : ping', tag: RoomReplayPage.sName);
        BetterSocket.sendMsg('{"Ping":{}}');
      });
    }, onMessage: (message) {
      Log.d('newMsg : $message', tag: RoomReplayPage.sName);
      try {
        SocketMsg socketMsg = SocketMsg.fromJson(jsonDecode(message.toString()));
        _handleSocketMsg(socketMsg);
      } catch (e) {
        Log.e("_handleSocketMsg ${e.toString()} ", tag: RoomReplayPage.sName);
      }
    }, onClose: (code, reason, remote) {
      Log.f("onClose---code:$code  reason:$reason  remote:$remote", tag: RoomReplayPage.sName);
      Future.delayed(Duration(milliseconds: 500), () async {
        BetterSocket.connentSocket(AddressUtil.getInstance().socketUrl(key, widget.roomData.room.roomUuid));
      });
    }, onError: (message) {
      Log.w("IOWebSocketChannel onError $message ", tag: RoomReplayPage.sName);
    });
    BetterSocket.connentSocket(AddressUtil.getInstance().socketUrl(key, widget.roomData.room.roomUuid));

//   socket = WebsocketManager(AddressUtil.getInstance().socketUrl(key, "yondor"));
//   socket.onMessage((dynamic message) {
//     print('newMsg : $message');
//     try{
//        SocketMsg socketMsg = SocketMsg.fromJson(jsonDecode(message.toString()));
//       _handleSocketMsg(socketMsg);
//     }catch(e){
//        Log.e("_handleSocketMsg ${e.toString()} ");
//     }
//   });
//   socket.onClose((dynamic message) {
//     Log.i("socket Close message $message ");
//     socket.connect();
//   });
//   socket.connect();
  }

  _handleSocketMsg(SocketMsg socketMsg) {
    switch (socketMsg.type) {
      case ppt:
      case h5:
      case mp4:
      case BREAK:
      case EVENT_CURRENT:
        _handleCourseware(socketMsg);
        break;
      case BOARD:
        _closeVideo();
        _resProvider.setRes(null);
        _currentRes = null;
        break;
      case EVENT_BOARD:
        _boardProvider.setEnableBoard(socketMsg.text == "1" ? 1 : 0);
        break;
//      case EVENT_HAND:
//        _handProvider.setEnableHand(socketMsg.text != null && socketMsg.text == "1" ? true : false);
//        break;
      case EVENT_JOIN_SUCCESS:
        if (socketMsg.text == "") {
          return;
        }
        //处理课件内容
        var msg = jsonDecode(socketMsg.text);
        _boardProvider.setEnableBoard(msg["enableBoard"]);
        //处理题目信息
        var e = msg["questEvent"];
        if (e != null) {
          if (e["type"] == null) {
            return;
          }
          if (e["type"] == SEL || e["type"] == JUD || e["type"] == MULSEL) {
            _handleSEL(e["text"], isCheck: true);
          } else if (e["type"] == RANRED) {
            _handleRANRED(e["text"], isCheck: true);
          } else if (e["type"] == REDRAIN) {
            _handleREDRAIN(e["text"], isCheck: true);
          }
        }
        break;
      case SEL:
      case JUD:
      case MULSEL:
        _handleSEL(socketMsg.text);
        break;
//      case RANRED:
//        _handleRANRED(socketMsg.text);
//        break;
//      case REDRAIN:
//        _handleREDRAIN(socketMsg.text);
//        break;
      case TIMER:
        _handleTIMER(socketMsg.text);
        break;
    }
  }

  _handleCourseware(SocketMsg socketMsg) async {
    if (socketMsg.text == "") {
      _resProvider.setRes(null);
      return;
    }
    Courseware courseware = widget.roomData.courseware;
    //处理课件内容
    var msg = jsonDecode(socketMsg.text);
    var qid = msg["qid"];
    var isShow = msg["isShow"];
    Res ques = courseware.findQues(qid);
    if (ques == null) {
      showToast("出错了!!!");
      return;
    }
    if (ques.type == JUD || ques.type == SEL || ques.type == MULSEL) {
      _handleSEL(socketMsg.text, isCheck: true);
      return;
    }
    if (ques.type == mp4 && msg["time"] == null) {
      msg["time"] = 0;
    }
    if (_currentRes == null && socketMsg.type == "event-current" && ques.type == mp4) {
      DateTime now = DateTime.now();
      DateTime quesTimeBy = DateUtil.getDateTimeByMs(socketMsg.timestamp);
      int inSeconds = now.difference(quesTimeBy).inSeconds;
      print("相差时间 inSeconds  $inSeconds");
      msg["time"] = msg["time"] + inSeconds;
    }
    Log.d("1111111111111 ${msg["time"]}", tag: RoomReplayPage.sName);
    if (ques != null && ques.type == mp4) {
      _isPlay = msg["isPlay"];
      _time = msg["time"];
    }

    if (_currentRes != null && _currentRes.qid == ques.qid) {
      if (_currentRes.type == mp4) {
        var isPlay = msg["isPlay"];
        var time = msg["time"];
        print("_currentRes.type == mp4 $isPlay  $time");
        if (flickManager != null && flickManager.flickVideoManager != null) {
          if (flickManager.flickVideoManager.isPlaying && isPlay == 0) {
            print(" flickManager?.flickControlManager?.autoPause();");
            flickManager?.flickControlManager?.autoPause();
            if (time != null && time > 0) {
              flickManager?.flickControlManager?.seekTo(Duration(seconds: time));
            }
          } else if (flickManager.flickVideoManager.isPlaying && isPlay == 1) {
            if (time != null && time > 0) {
              flickManager?.flickControlManager?.seekTo(Duration(seconds: time));
              flickManager?.flickControlManager?.play();
            }
          } else if (flickManager.flickVideoManager.isVideoEnded && isPlay == 1) {
            if (time != null && time > 0) {
              flickManager?.flickControlManager?.seekTo(Duration(seconds: time));
              flickManager?.flickControlManager?.play();
            }
            flickManager?.flickControlManager?.play();
          } else if (!flickManager.flickVideoManager.isPlaying && isPlay == 1) {
            flickManager?.flickControlManager?.autoResume();
            if (time != null && time > 0) {
              flickManager?.flickControlManager?.seekTo(Duration(seconds: time));
              flickManager?.flickControlManager?.play();
            } else {
              flickManager?.flickControlManager?.play();
            }
          }
        }
      } else {
        var _resShow;
        if (isShow != null) {
          _resShow = isShow == 1;
        }
        if (ques.type == h5 && isShow != null) {
          if (isShow == 1) {
            gameStart();
          } else {
            //结束游戏
//            gameOver(ques: ques);
            return;
          }
        }
        _resProvider.setRes(ques, isShow: _resShow);
      }
    } else {
      //切换新页面
      if ((_currentRes != null && _currentRes.type == mp4 && ques.type != mp4)) {
        _closeVideo();
      }
      if (ques.type == mp4 && _currentRes != null && _currentRes.type == mp4) {
        if (flickManager.flickVideoManager.videoPlayerController.dataSource != "${widget.roomData.courseware.domain}${ques.data.ps.mp4}") {
          File file = File(widget.roomData.courseware.localPath + "/" + ques.data.ps.mp4);
          flickManager?.handleChangeVideo(
              file.existsSync() ? VideoPlayerController.file(file) : VideoPlayerController.network(widget.roomData.courseware.domain + ques.data.ps.mp4));
        }
      } else {
        var _resShow;
        if (isShow != null) {
          _resShow = isShow == 1;
        }
        if (ques.type == h5 && isShow != null && isShow == 1) {
          if (isShow == 1) {
            gameStart();
          } else {
            //结束游戏
//            gameOver(ques: ques);
            return;
          }
        }

        //只展示图片不操作
        if (_currentRes == null || isShow == null) {
          _resProvider.setRes(ques, isShow: _resShow);
        }
      }
    }
    _currentRes = ques;
  }

  gameOver() async {
//    _webViewPlusController.evaluateJavascript('window.gameOver();');
  }

  //处理定时器
  _handleTIMER(text) async {
    var msg = jsonDecode(text);
    var t = msg["t"];
    _liveTimerProvider.show(t != 0 ? true : false, t);
  }

  _handleREDRAIN(text, {isCheck = false}) async {
    Courseware courseware = widget.roomData.courseware;
    var msg = jsonDecode(text);
    var qid = msg["qid"];
    Res ques = courseware.findQues(qid);
    if (ques == null) {
      showToast("出错了!!!");
      return;
    }
    var flag = false;
    if (isCheck) {
      //检查是否已经领奖
      var param = {
        "catalogId": ques.ctatlogid,
        "liveCourseallotId": widget.roomData.liveCourseallotId,
        "liveEventId": 4,
        "quesId": ques.qid,
        "roomId": widget.roomData.room.roomUuid
      };
      final res = await RoomDao.isRewardStar(param);
      if (res.result != null && res.data != null && res.data["code"] == 200) {
        if (!res.data["data"]["is"]) {
          flag = true;
        }
      } else {
        showToast("检查失败请稍后重试!!!");
      }
    }
    if (!isCheck || flag) {
      Navigator.push(context, PopRoute(child: RedRain())).then((value) {
        if (value == null || value == 0) {
          return;
        }
        var param = {
          "catalogId": ques.ctatlogid,
          "liveCourseallotId": widget.roomData.liveCourseallotId,
          "liveEventId": 4,
          "quesId": ques.qid,
          "star": value,
          "roomId": widget.roomData.room.roomUuid
        };
        RoomDao.rewardStar(param).then((res) {
          Log.f("rewardStar  ${res.toString()}", tag: RoomReplayPage.sName);
          if (res.result != null && res.data != null && res.data["code"] == 200) {
            if (res.data["data"]["status"] == 1) {
              showStarDialog(value);
            }
          } else {
            showToast("领取失败请稍后重试!!!");
          }
        });
      });
    }
  }

  _handleRANRED(text, {isCheck = false}) async {
    Courseware courseware = widget.roomData.courseware;
    var msg = jsonDecode(text);
    var qid = msg["qid"];
    Res ques = courseware.findQues(qid);
    if (ques == null) {
      showToast("出错了!!!");
      return;
    }
    var flag = false;
    if (isCheck) {
      //检查是否已经领奖
      var param = {
        "catalogId": ques.ctatlogid,
        "liveCourseallotId": widget.roomData.liveCourseallotId,
        "liveEventId": 3,
        "quesId": ques.qid,
        "roomId": widget.roomData.room.roomUuid
      };
      final res = await RoomDao.isRewardStar(param);
      if (res.result != null && res.data != null && res.data["code"] == 200) {
        if (!res.data["data"]["is"]) {
          flag = true;
        }
      } else {
        showToast("检查失败请稍后重试!!!");
      }
    }
    if (!isCheck || flag) {
      showRedPacketDialog().then((value) {
        if (value == null || value == 0) {
          return;
        }
        var param = {
          "catalogId": ques.ctatlogid,
          "liveCourseallotId": widget.roomData.liveCourseallotId,
          "liveEventId": 3,
          "quesId": ques.qid,
          "star": value,
          "roomId": widget.roomData.room.roomUuid
        };
        RoomDao.rewardStar(param).then((res) {
          Log.f("rewardStar  ${res.toString()}", tag: RoomReplayPage.sName);
          if (res.result != null && res.data != null && res.data["code"] == 200) {
            if (res.data["data"]["status"] == 1) {
              showStarDialog(value);
            }
          } else {
            showToast("领取失败请稍后重试!!!");
          }
        });
      });
    }
  }

  _handleSEL(text, {isCheck = false}) async {
    Courseware courseware = widget.roomData.courseware;
    var msg = jsonDecode(text);
    var qid = msg["qid"];
    var isShow = msg["isShow"];
    Res ques = courseware.findQues(qid);
    if (ques == null) {
      showToast("出错了!!!");
      return;
    }

    if (_currentRes == null || (_currentRes.qid != ques.qid && isShow == null)) {
      if ((_currentRes != null && _currentRes.type == mp4 && ques.type != mp4)) {
        _closeVideo();
      }
      _resProvider.setRes(ques);
      _currentRes = ques;
    }
    if (isShow == null) {
      //只展示图片
      return;
    }
    var flag = false;
    if (isCheck && isShow == 1) {
      //检查是否已经领奖
      var param = {
        "catalogId": ques.ctatlogid,
        "liveCourseallotId": widget.roomData.liveCourseallotId,
        "liveEventId": 1,
        "quesId": ques.qid,
        "roomId": widget.roomData.room.roomUuid
      };
      final res = await RoomDao.isDoQues(param);
      if (res.result != null && res.data != null && res.data["code"] == 200) {
        if (!res.data["data"]["is"]) {
          flag = true;
        }
      } else {
        showToast("检查失败请稍后重试!!!");
      }
    }

    if (!isCheck || flag) {
      var an = ques.data.an as Map;
      var as = an["as"];
      var op = an["op"];
//      (op as List).addAll(op as List);
      _roomSelProvider.setIsShow(isShow == 1, ques: ques, op: op, quesAn: as[0], dateTime: DateTime.now());
      if (isShow == 0) {
        //获取排行榜前三用户
        var param = {"liveCourseallotId": widget.roomData.liveCourseallotId, "liveEventId": 1, "quesId": ques.qid, "roomId": widget.roomData.room.roomUuid};
        Log.f("RoomDao.quesTop param $param", tag: RoomReplayPage.sName);
        final res = await RoomDao.quesTop(param);
        if (res.result != null && res.data != null && res.data["code"] == 200) {
          Log.f(res.data, tag: RoomReplayPage.sName);
          if (res.data["data"] != null && res.data["data"].length > 0) {
            showLiveTopDialog(res.data["data"]);
          } else {
            Log.i("该题目无人上榜 ${res.data}", tag: RoomReplayPage.sName);
          }
        } else {
          Log.e("查询题目前三排行榜失败！！", tag: RoomReplayPage.sName);
          showToast("网络错误!!!");
        }
      }
    }
  }

  Future showLiveTopDialog(data) {
    closeDialog();
    return showDialog(
        context: context,
        builder: (context) {
          return MediaQuery(

              ///不受系统字体缩放影响
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window).copyWith(textScaleFactor: 1),
              child: ChangeNotifierProvider<CourseProvider>.value(value: _courseProvider, child: LiveTopDialog(data: data)));
        });
  }

  Future rewardFirstStar() async {
    //检查是否已经领奖
    var flag = false;
    var param = {
      "catalogId": widget.roomData.courseware.id,
      "liveCourseallotId": widget.roomData.liveCourseallotId,
      "liveEventId": 2,
      "roomId": widget.roomData.room.roomUuid
    };
    final res = await RoomDao.isRewardStar(param);
    if (res.result != null && res.data != null && res.data["code"] == 200) {
      if (!res.data["data"]["is"]) {
        flag = true;
      }
    } else {
      showToast("检查失败请稍后重试!!!");
    }
    if (flag) {
      var s = Random().nextInt(15) + 10;
      var param = {
        "catalogId": widget.roomData.courseware.id,
        "liveCourseallotId": widget.roomData.liveCourseallotId,
        "liveEventId": 2,
        "star": s,
        "roomId": widget.roomData.room.roomUuid
      };
      RoomDao.rewardStar(param).then((res) {
        Log.f("rewardStar  ${res.toString()}", tag: RoomReplayPage.sName);
        if (res.result != null && res.data != null && res.data["code"] == 200) {
          if (res.data["data"]["status"] == 1) {
            closeDialog();
            showDialog(
                context: context,
                builder: (context) {
                  return MediaQuery(

                      ///不受系统字体缩放影响
                      data: MediaQueryData.fromWindow(WidgetsBinding.instance.window).copyWith(textScaleFactor: 1),
                      child: StarGif(
                        starNum: s,
                      ));
                });
          }
        } else {
          showToast("领取失败请稍后重试!!!");
        }
      });
    }
  }

  Future showStarDialog(int num) {
    return _startForward(num);
    // return NavigatorUtil.showGSYDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return StarDialog(
    //         starNum: num,
    //       );
    //     });
  }

  Future showRedPacketDialog() {
    closeDialog();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChangeNotifierProvider<CourseProvider>.value(value: _courseProvider, child: RedPacketDialog());
        });
  }

  ///启动获取星星动画
  _startForward(num) {
    closeDialog();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ChangeNotifierProvider<StarWidgetProvider>.value(value: _starWidgetProvider, child: Start(frequency: num));
        });
  }

  @override
  void dispose() {
    if (orientation == 1) {
      OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    }
    _closeVideo();

    AgoraRtcEngine?.leaveChannel();
    AgoraRtcEngine?.destroy();
    _rtmChannel?.leave();
    _rtmClient?.logout();
    _hiddenTopTimer?.cancel();
    _socketPingTimer?.cancel();
    socket?.close();
    _teacherPlayer?.release();
    BetterSocket.close();
    socket = null;
    _currentRes = null;
    super.dispose();
  }

  _closeVideo() async {
    print("_closeVideo _closeVideo _closeVideo");
    flickManager?.dispose();
    flickManager = null;
    _isPlay = null;
    _time = null;
  }

  _back() {
    if (orientation == 1) {
      if (Platform.isIOS) {
        OrientationPlugin.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
      orientation = 0;
      OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    }
    if (Platform.isIOS) {
      HomeIndicator.deferScreenEdges([]);
    }
    Future.delayed(Duration(milliseconds: 500), () async {
      Navigator.pop(context);
    });
  }

  @override
  String tagName() {
    return RoomReplayPage.sName;
  }

  void print(msg, {int level = Log.fine}) {
    funMap[level](msg, tag: tagName());
  }

  showTopAndBottom({bool isShow = true}) {
    if (!isShow) {
      _roomShowTopProvider.setIsShow(false);
      _replayProgressProvider.setIsShow(false);
      return;
    }
    if (_roomShowTopProvider.isShow && _replayProgressProvider.isShow) {
      _roomShowTopProvider.setIsShow(false);
      _replayProgressProvider.setIsShow(false);
    } else {
      _roomShowTopProvider.setIsShow(true);
      _replayProgressProvider.setIsShow(true);
    }

//    if (_roomShowTopProvider.isShow && _replayProgressProvider.isShow) {
//      _hiddenTopTimer.cancel();
//      _hiddenTopTimer = Timer(Duration(seconds: 6), () {
//        showTopAndBottom(isShow: false);
//      });
//    }
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isAndroid || Platform.isFuchsia) {
      return child;
    } else {
      return super.buildViewportChrome(context, child, axisDirection);
    }
  }
}
