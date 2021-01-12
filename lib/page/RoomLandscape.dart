import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:better_socket/better_socket.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/const/LiveRoom.dart';
import 'package:flutter_start/common/dao/RoomDao.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/Log.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/common/utils/ping.dart';
import 'package:flutter_start/models/ChatMessage.dart';
import 'package:flutter_start/models/Courseware.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/models/RoomUser.dart';
import 'package:flutter_start/provider/provider.dart';
import 'package:flutter_start/widget/DIYKeyboard.dart';
import 'package:flutter_start/widget/GamePayleWidget.dart';
import 'package:flutter_start/widget/InputButtomWidget.dart';
import 'package:flutter_start/widget/LiveQuesDialog.dart';
import 'package:flutter_start/widget/LiveRankWidget.dart';
import 'package:flutter_start/widget/LiveTimerWidget.dart';
import 'package:flutter_start/widget/LiveTopDialog.dart';
import 'package:flutter_start/widget/LivesQuesWidget.dart';
import 'package:flutter_start/widget/RedPacket.dart';
import 'package:flutter_start/widget/RedRain.dart';
import 'package:flutter_start/widget/StarDialog.dart';
import 'package:flutter_start/widget/StarGif.dart';
import 'package:flutter_start/widget/UserStarWidget.dart';
import 'package:flutter_start/widget/courseware_video.dart';
import 'package:flutter_start/widget/expanded_viewport.dart';
import 'package:flutter_start/widget/room/EyerestWidget.dart';
import 'package:flutter_start/widget/room/Mp3PlayerWidget.dart';
import 'package:flutter_start/widget/room/RoomEduSocket.dart';
import 'package:flutter_start/widget/starsWiget.dart';
import 'package:fradio/fradio.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:oktoast/oktoast.dart';
import 'package:orientation/orientation.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:yondor_whiteboard/whiteboard.dart';

class RoomLandscapePage extends StatefulWidget {
  static final String sName = "RoomLandscape";

  final RoomData roomData;
  final String token;
  const RoomLandscapePage({Key key, this.roomData, this.token}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return RoomLandscapePageState(roomData);
  }
}

class RoomLandscapePageState extends State<RoomLandscapePage> with SingleTickerProviderStateMixin, LogBase, WidgetsBindingObserver {
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

  RoomLandscapePageState(RoomData roomData) {
    _courseProvider = CourseProvider(roomData.room.courseState, roomData: roomData, closeDialog: closeDialog, showStarDialog: showStarDialog);
    _chatProvider.setMuteAllChat(roomData.room.muteAllChat == 1);
  }

  CourseProvider _courseProvider;
  int orientation = 0;
  AgoraRtmClient _rtmClient;
  RoomEduSocket _roomEduSocket;
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
  Mp3PlayerProvider _mp3PlayerProvider = Mp3PlayerProvider();
  EyerestProvider _eyerestProvider = EyerestProvider();
  WhiteboardProvider _whiteboardProvider = WhiteboardProvider();
  NetworkQualityProvider _networkQualityProvider = NetworkQualityProvider();
  ScreenProvider _screenProvider = ScreenProvider();
  WebViewPlusController _webViewPlusController;
  int _isPlay;
  int _time;
  final TextEditingController _textController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final _infoStrings = <String>[];
  static final _users = <int>[];
  WhiteboardController _whiteboardController = WhiteboardController();
  Timer _hiddenTopTimer;
  FijkPlayer flickManager = FijkPlayer();
  Timer _socketPingTimer;
  Timer _socketLossTimer;
  Duration _socketPingDuration = Duration(seconds: 45);
  Duration _socketLossDuration = Duration(seconds: 10);
  bool isShowDialog = false;
  bool isShowTip = true;
  Timer isShowTipTimer;
  FocusNode _textFocusNode = FocusNode();
  StreamSubscription<ConnectivityResult> _subscription;
  Timer _connectivityNoneTimer;
  List<SocketMsg> msgList = List();
  bool _isIos13 = true;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initConnectivity();
    if (Platform.isIOS) {
      OrientationPlugin.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    }
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
    orientation = 1;
    _initWebsocketManager();
    _local = widget.roomData.user;
    if (widget.token == null || widget.token == "") {
      _initYondorRtm();
    } else {
      initializeRtm();
    }
    initializeRtc().then((value) {
      this._updateUsers(widget.roomData.room.coVideoUsers);
    });
    if (Platform.isIOS) {
      HomeIndicator.deferScreenEdges([ScreenEdge.bottom, ScreenEdge.top]);
    }
    Future.delayed(Duration(milliseconds: 1000)).then((e) {
      rewardFirstStar();
    });
    _textController.addListener(() {
      _chatProvider.setIsComposing(_textController.text.length > 0);
    });
    _initWhiteBoard();
    if (Platform.isIOS) {
      _isIos13 = CommonUtils.ios13();
      print("is ios13  $_isIos13");
    }
    getMsgList();
  }

  _initWhiteBoard() async {
    _whiteboardController.onCreated = (result) {
      print("_whiteboardController  $result");
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _courseProvider.setInitBoardView(true);
      });
    };
    _whiteboardController.onRoomPhaseChanged = (result) {
      _whiteboardProvider.setRoomPhase(result);
    };
  }

  _initYondorRtm() async {
    _roomEduSocket = RoomEduSocket();
    _roomEduSocket.init(widget.roomData.user.userId);
    var key = await httpManager.getAuthorization();
    _roomEduSocket.join(key, widget.roomData.room.roomUuid);
    _roomEduSocket.onMemberJoined = (AgoraRtmMember member) {
      _log("Member joined: " + member.userId + ', channel: ' + member.channelId);
    };
    _roomEduSocket.onMemberLeft = (AgoraRtmMember member) {
      _log("Member left: " + member.userId + ', channel: ' + member.channelId);
    };
    _roomEduSocket.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
      _handleMsg(message, member);
    };
    _roomEduSocket.onMemberCountUpdated = (int count) {
      _log("Channel onMemberCountUpdated:  count:$count ");
    };
    _roomEduSocket.onError = (err) {
      _log("Channel err:  err:$err ");
    };
    _roomEduSocket.onMessageReceivedUser = (AgoraRtmMessage message, String peerId) {
      _handlePeerMsg(message, peerId);
    };
  }

  initConnectivity() async {
    _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      print("Connectivity = $result");
      if (result == ConnectivityResult.none) {
        print("网络无连接！！！！");
        if (_connectivityNoneTimer != null && _connectivityNoneTimer.isActive) {
          _connectivityNoneTimer?.cancel();
        }
        _connectivityNoneTimer = null;
        _connectivityNoneTimer = Timer(Duration(seconds: 10), () {
          //'网络无连接' 关闭本地音视频
          _local?.coVideo = 0;
          _local?.enableVideo = 0;
          _local?.enableAudio = 0;
          _startVideo(_local);
        });
      } else {
        _connectivityNoneTimer?.cancel();
        _connectivityNoneTimer = null;
      }
    });
  }

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
          ChangeNotifierProvider<Mp3PlayerProvider>.value(
            value: _mp3PlayerProvider,
          ),
          ChangeNotifierProvider<EyerestProvider>.value(
            value: _eyerestProvider,
          ),
          ChangeNotifierProvider<NetworkQualityProvider>.value(
            value: _networkQualityProvider,
          ),
          ChangeNotifierProvider<WhiteboardProvider>.value(
            value: _whiteboardProvider,
          ),
          ChangeNotifierProvider<ScreenProvider>.value(
            value: _screenProvider,
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
                                          _roomShowTopProvider.setIsShow(true);
                                        },
                                        child: _buildChat(),
                                      ),
                                    ),
                                    _buildTextComposer(),
                                  ],
                                ),
                              )
                            ]),
                            Consumer2<CourseProvider, ScreenProvider>(builder: (context, courseModel, screenModel, child) {
                              return courseModel.status == 1 && screenModel.screenId > 0
                                  ? GestureDetector(
                                      child: Container(width: courseModel.coursewareWidth, child: AgoraRenderWidget(screenModel.screenId)),
                                      onTap: () => _roomShowTopProvider.setIsShow(true),
                                    )
                                  : Container();
                            }),
                            Consumer<CourseProvider>(builder: (context, model, child) {
                              return model.status == 1 ? UserStarWidget() : Container();
                            }),
                            Consumer<CourseProvider>(builder: (context, model, child) {
                              return model.status == 1 ? _getLiveTimerWidget() : Container();
                            }),
                            Consumer<CourseProvider>(builder: (context, model, child) {
                              return model.status == 1 ? _buildRank() : Container();
                            }),
                            Consumer<CourseProvider>(builder: (context, model, child) {
                              return model.status == 1
                                  ? Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: _buildSel(),
                                    )
                                  : Container();
                            }),
                            Consumer<CourseProvider>(builder: (context, model, child) {
                              return model.status == 1
                                  ? Consumer<Mp3PlayerProvider>(builder: (context, model, child) {
                                      return Mp3PlayerWidget();
                                    })
                                  : Container();
                            }),
                            Consumer<CourseProvider>(builder: (context, model, child) {
                              return model.status == 1
                                  ? Consumer<EyerestProvider>(builder: (context, model, child) {
                                      return model.isShow ? EyerestWidget(flickManager: model.flickManager) : Container();
                                    })
                                  : Container();
                            }),
                            _buildNetBad(),
                            _buildTop(),
                          ],
                        )))),
          ),
        ));
  }

  _buildNetBad() {
    return Consumer2<NetworkQualityProvider, CourseProvider>(builder: (context, model, courseModel, child) {
      return model.isBad() && courseModel.status == 1
          ? Container(
              width: _courseProvider.coursewareWidth,
              color: Colors.red.withOpacity(0.8),
              height: ScreenUtil.getInstance().getHeight(50),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          AssetImage(model.images),
                          color: Colors.white,
                        ),
                        Text(
                          "网络信号差，请检查网络～",
                          style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getInstance().getSp(13 / 2)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          : Container();
    });
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
    return LiveQuesWidget();
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            "images/live/awaitIcon.png",
                            width: ScreenUtil.getInstance().getWidthPx(200),
                            fit: BoxFit.contain,
                          ),
                          Text(
                            DateTime.now().isAfter(courseStatusModel.roomData.endTime) ? "下课啦~" : "请准备好纸笔耐心等待~",
                            style: TextStyle(color: Colors.orange),
                          )
                        ],
                      ))),
              Image.asset(
                "images/live/logo.png",
//                    width:ScreenUtil.getInstance().getWidthPx(200),
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      } else if (resModel.res != null) {
        if (resModel.res.type == h5) {
          result = _buildWebView(resModel);
        } else if (resModel.res.type == ppt ||
            resModel.res.type == BREAK ||
            resModel.res.type == JUD ||
            resModel.res.type == SEL ||
            resModel.res.type == MULSEL ||
            resModel.res.type == RANRED ||
            resModel.res.type == REDRAIN) {
          result = _buildPic(resModel);
        } else if (resModel.res.type == mp4) {
          result = _buildMp4(resModel);
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
                  _isIos13
                      ? AnimatedSwitcher(
                          duration: Duration(milliseconds: 800),
                          child: result != null
                              ? Container(
                                  key: ValueKey("${resModel?.res?.qid ?? 0}"),
                                  child: result,
                                )
                              : Container(),
                        )
                      : result != null
                          ? Container(
                              key: ValueKey("${resModel?.res?.qid ?? 0}"),
                              child: result,
                            )
                          : Container(),
                  Consumer<BoardProvider>(builder: (context, model, child) {
                    print("courseStatusModel.isInitBoardView ${courseStatusModel.isInitBoardView}");
                    print(
                        " 等待老师开始游戏 ${(resModel != null && resModel.res != null && resModel.res.type != null && resModel.res.type == h5) && (resModel.isShow == null || !resModel.isShow)}");
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
                        offstage: !(show),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Stack(
                              children: [
                                _buildWhiteboard(),
                                Consumer<WhiteboardProvider>(builder: (context, model, child) {
                                  print("model.roomPhase  ${model.roomPhase} ");
                                  return model.roomPhase != "connected"
                                      ? Positioned.fill(
                                          child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SpinKitRing(
                                                size: ScreenUtil.getInstance().getSp(28),
                                                color: Color(0xFF195FA4),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "${LiveRoomConst.ROOM_PHASE_NAME[model.roomPhase]}···",
                                                style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(8)),
                                              )
                                            ],
                                          ),
                                        ))
                                      : Container(height: 0, width: 0);
                                }),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                _roomShowTopProvider.setIsShow(true);
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
                  }), //学生视频
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

  Widget _buildMp4(ResProvider resModel) {
    return FijkView(
      player: flickManager,
      color: Colors.black,
//      panelBuilder: (FijkPlayer player, FijkData data, BuildContext context, Size viewSize, Rect texturePos) {
//        return Container();
//      },
      cover: Image.file(File('${widget.roomData.courseware.localPath}/${resModel.res.data.ps.pic}'), fit: BoxFit.contain).image,
    );
  }

  Widget _buildPic(ResProvider resModel) {
    return GestureDetector(
      child: Container(
          child: Image.file(
        File(widget.roomData.courseware.localPath + "/" + resModel.res.data.ps.pic),
        fit: BoxFit.contain,
      )),
      onTap: () => _roomShowTopProvider.setIsShow(true),
    );
  }

  Widget _buildWebView(ResProvider resModel) {
    if (Platform.isIOS) {
      final _ms = _isIos13 ? 800 : 1000;
      if (resModel.isShow == null || !resModel.isShow) {
        Future.delayed(Duration(milliseconds: _ms), () {
          _boardProvider.setTestBoard(0);
          Future.delayed(Duration(milliseconds: _ms), () {
            _boardProvider.setTestBoard(1);
          });
        });
      }
    }
    print("${resModel.isShow == null || !resModel.isShow}resModel.isShow == null || !resModel.isShow");
    return Container(
      color: Colors.black,
      child: WebViewPlus(
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: 'Courseware',
              onMessageReceived: (JavascriptMessage message) async {
                var msg = jsonDecode(message.message);
                Log.f("@收到Courseware 回调 $msg", tag: RoomLandscapePage.sName);
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
          if (ObjectUtil.isEmptyString(resModel.res.data.ps.password)) {
            print("loadurl ${widget.roomData.courseware.localPath + "/" + await CommonUtils.urlJoinUser(resModel.res.data.ps.h5url)}");
            controller.loadUrl(widget.roomData.courseware.localPath + "/" + await CommonUtils.urlJoinUser(resModel.res.data.ps.h5url));
          } else {
            var password = resModel.res.data.ps.password;
            String filterPsw = password.substring(12, 13) +
                password.substring(9, 10) +
                password.substring(6, 7) +
                password.substring(3, 4) +
                password.substring(7, 8) +
                password.substring(11, 12) +
                password.substring(15, 16) +
                password.substring(10, 11);
            var toURL = widget.roomData.courseware.localPath + "/" + await CommonUtils.urlJoinUser(resModel.res.data.ps.h5url + "?h5code=$filterPsw");
            print("Roomlandscape@onWebViewCreated loadurl===>$toURL");
            controller.loadUrl(toURL);
          }
        },
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          new Factory<OneSequenceGestureRecognizer>(
            () => new EagerGestureRecognizer(),
          ),
        ].toSet(),
      ),
    );
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

  gameOver({Res ques, bool isSwitch = false}) async {
    if (!isSwitch) {
      //不是切换课件才结束
      _webViewPlusController.evaluateJavascript('window.gameOver();');
    }

    if (ques == null) {
      return null;
    }
    var flag = false;
    //检查是否已经领奖
    var param = {
      "catalogId": ques.ctatlogid,
      "liveCourseallotId": widget.roomData.liveCourseallotId,
      "liveEventId": 7,
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
    if (flag) {
      var star = 10;
      var param = {
        "catalogId": ques.ctatlogid,
        "liveCourseallotId": widget.roomData.liveCourseallotId,
        "liveEventId": 7,
        "quesId": ques.qid,
        "star": star,
        "roomId": widget.roomData.room.roomUuid
      };
      RoomDao.rewardStar(param).then((res) {
        Log.f("rewardStar  ${res.toString()}", tag: RoomLandscapePage.sName);
        if (res.result != null && res.data != null && res.data["code"] == 200) {
          if (res.data["data"]["status"] == 1) {
            showStarDialog(star);
          }
        } else {
          showToast("领取失败请稍后重试!!!");
        }
      });
    }
  }

  Widget _buildTop() {
    return Consumer<RoomShowTopProvider>(builder: (context, model, child) {
      if ((_hiddenTopTimer == null || !_hiddenTopTimer.isActive) && model.isShow == true) {
        _hiddenTopTimer = Timer(Duration(seconds: 4), () {
          model.setIsShow(false);
        });
      }

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
    return Consumer2<TeacherProvider, CourseProvider>(builder: (context, teacherModel, courseStatusModel, child) {
      final flag = courseStatusModel.status == 1 && teacherModel.user != null && teacherModel.user.coVideo == 1 && teacherModel.user.enableVideo == 1;

      return Container(
//              alignment:Alignment.center,
//              color: Colors.red,
          width: ScreenUtil.getInstance().screenWidth * 0.2,
          height: ScreenUtil.getInstance().getHeightPx(550),
          child: flag
              ? Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    AgoraRenderWidget(teacherModel.user.uid),
                    Consumer<NetworkQualityProvider>(builder: (context, model, child) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1, left: 1),
                        child: Image.asset(
                          model.images,
                          fit: BoxFit.contain,
                          width: ScreenUtil.getInstance().getWidth(11),
                        ),
                      );
                    })
                  ],
                )
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
      Widget widget = Container();

      if (model.user != null) {
        if (model.user.coVideo == 1) {
          widget = Container(
              color: Colors.white,
              width: ScreenUtil.getInstance().screenWidth * 0.15,
              height: ScreenUtil.getInstance().getHeightPx(350),
              child: model.user.coVideo == 1 && model.user.enableVideo == 1
                  ? AgoraRenderWidget(model.user.uid, local: true)
                  : Container(
                      color: Colors.white,
                      child: Image.asset(
                        'images/ic_student.png',
                      )));
        } else if (_others.length > 0) {
          widget = Container(
              color: Colors.white,
              width: ScreenUtil.getInstance().screenWidth * 0.15,
              height: ScreenUtil.getInstance().getHeightPx(350),
              child: _others[0].coVideo == 1 && _others[0].enableVideo == 1
                  ? AgoraRenderWidget(_others[0].uid)
                  : Container(
                      color: Colors.white,
                      child: Image.asset(
                        'images/ic_student.png',
                        width: ScreenUtil.getInstance().screenWidth,
                        height: ScreenUtil.getInstance().getWidthPx(550),
                      )));
        }
      }

      return Offstage(
        offstage: !(_courseProvider.status == 1),
        child: Align(
          alignment: AlignmentDirectional(0.98, -0.98),
          child: widget,
        ),
      );
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
                        margin: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
//                          Container(
//                              margin: EdgeInsets.symmetric(horizontal: 0),
//                            child: IconButton(icon: Icon(Icons.sentiment_satisfied), onPressed:(){_showKeyboard(model);} ),
//                          ),
                          InkWell(
                            onTap: () => {_showKeyboard(model)},
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                                child: Icon(
                                  Icons.sentiment_satisfied,
                                  color: Colors.black26,
                                )),
                          ),
                          Flexible(
                              child: InkWell(
                            child: TextField(
                              readOnly: model.muteAllChat,
                              controller: _textController,
                              focusNode: _textFocusNode,
                              onChanged: (String text) {
                                model.setIsComposing(_textController.text.length > 0);
                              },
                              onTap: model.muteAllChat
                                  ? () {
                                      _textFocusNode.unfocus();
                                    }
                                  : () {
//                                _showKeyboard(model);
                                      Navigator.push(
                                          context,
                                          PopRoute(
                                              child: ChangeNotifierProvider<ChatProvider>.value(
                                                  value: _chatProvider,
                                                  child: InputButtomWidget(
                                                    onChanged: (String text) {
                                                      _chatProvider.setIsComposing(text.length > 0);
                                                    },
                                                    controller: _textController,
                                                    onSubmitted: _handleSubmitted,
                                                  )))).then((_) {
                                        FocusScope.of(context).requestFocus(_textFocusNode);
                                        _textFocusNode.unfocus();
                                        print("122");
                                      });
                                      print("#1 123123");
                                    },
                              onSubmitted: _handleSubmitted,
                              decoration: InputDecoration.collapsed(hintText: model.muteAllChat ? "禁言中" : '发送消息'),
                            ),
                          )),
                          !model.muteAllChat
                              ? InkWell(
                                  onTap: model.isComposing ? () => _handleSubmitted(_textController.text) : null,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                                    child: Icon(
                                      Icons.send,
                                      color: model.isComposing ? Colors.blueAccent : Colors.grey,
                                    ),
                                  ),
                                )
//                          Container(
//                                  margin: EdgeInsets.symmetric(horizontal: 0),
//                                  child: IconButton(icon: Icon(Icons.send), onPressed: model.isComposing ? () => _handleSubmitted(_textController.text) : null),
//                                )
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
    RoomDao.roomChat(widget.roomData.room.roomId, widget.token, text, widget.roomData.room.roomUuid, liveCourseallotId: widget.roomData.liveCourseallotId)
        .then((res) {
      if (res != null && !res.result) {
        showToast(res.data);
      }
    });
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
    Log.d("Store<GSYState> ${store.state.userInfo.toJson()}", tag: RoomLandscapePage.sName);
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
          Future.microtask(() => _handTypeProvider.switchType(0));
          showToast("老师接受了你的连麦申请！");
        } else if (msgJson["data"]["type"] == (CoVideoType.ABORT.index + 1)) {
          Future.microtask(() => _handTypeProvider.switchType(1));
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

  _handleMsg(AgoraRtmMessage message, AgoraRtmMember member) async {
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
        msgJson["data"]["list"].forEach((item) {
          if (item["userId"] == _local.userId) {
            if (item["coVideo"] == 0) {
              _local?.role = item["role"];
              _local?.coVideo = 0;
              _local?.enableVideo = 0;
              _local?.enableAudio = 0;
              _startVideo(_local);
              _studentProvider.notifier(_local);
            }
          }
        });
        break;
      case 3: //room attributes updated msg
        // if (_courseProvider.isInitBoardView) {
        //   _whiteboardController.updateRoom(isBoardLock: msgJson["data"]["lockBoard"]);
        // }
        _chatProvider.setMuteAllChat(msgJson["data"]["muteAllChat"] == 1);
        if (msgJson["data"]["courseState"] != _courseProvider.status) {
          _courseProvider.setStatus(msgJson["data"]["courseState"]);
          if (_courseProvider.status == 1) {
            await AgoraRtcEngine?.muteAllRemoteVideoStreams(false);
            await AgoraRtcEngine?.muteAllRemoteAudioStreams(false);
          } else if (_courseProvider.status == 0) {
            await AgoraRtcEngine?.muteAllRemoteVideoStreams(true);
            await AgoraRtcEngine?.muteAllRemoteAudioStreams(true);
          }
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
    await AgoraRtcEngine.setAudioProfile(AudioProfile.MusicHighQuality, AudioScenario.GameStreaming);
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(480, 360);
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    print("appid:${Config.APP_ID} rtctoken:${widget.roomData.user.rtcToken} channelname:${widget.roomData.room.channelName}  uid:${widget.roomData.user.uid}");
    await AgoraRtcEngine.joinChannel(widget.roomData.user.rtcToken, widget.roomData.room.channelName, widget.roomData.user.userName, widget.roomData.user.uid);

    if (_courseProvider.status == 0) {
      await AgoraRtcEngine?.muteAllRemoteVideoStreams(true);
      await AgoraRtcEngine?.muteAllRemoteAudioStreams(true);
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
//      _whiteboardController?.setWritable(true);
    } else if (user.coVideo == 0) {
      _enableLocalVideo = false;
      _enableLocalAudio = false;
      AgoraRtcEngine.muteLocalAudioStream(true);
      AgoraRtcEngine.muteLocalVideoStream(true);
      AgoraRtcEngine.enableLocalVideo(false);
      AgoraRtcEngine.enableLocalAudio(false);
//      _whiteboardController?.setWritable(false);
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
        _screenProvider.setScreenId(uid);
        // _resProvider.setScreen(uid);
      }
      _users.add(uid);
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      final info = 'userOffline: $uid';
      print("onUserOffline : $info");
      if (_teacher != null && _teacher.screenId == uid) {
        _screenProvider.setScreenId(0);
        // _resProvider.setScreen(0);
      }
      _users.remove(uid);
    };
    AgoraRtcEngine.onFirstRemoteVideoFrame = (int uid, int width, int height, int elapsed) {
      final info = 'firstRemoteVideo: $uid ${width}x $height';
      print("onFirstRemoteVideoFrame : $info");
    };

    AgoraRtcEngine.onNetworkQuality = (int uid, int txQuality, int rxQuality) {
//      print("onNetworkQuality : uid :$uid  txQuality:$txQuality  rxQuality:$rxQuality  ", level: Log.debug);

      if (uid == 0 && _courseProvider.status != 0) {
        int val = max<int>(txQuality, rxQuality);
        _networkQualityProvider.setNetworkQuality(val);
      }
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
      _local?.enableVideo = 0;
      _local?.enableAudio = 0;
    }
    _startVideo(_local);
    _others.clear();
    _others.addAll(others);
    _studentProvider.notifier(_local);
  }

  ///白板区域
  Widget _buildWhiteboard() {
    if (_whiteboard == null) {
      print("widget.roomData.boardId ${widget.roomData.boardId}");
      Store<GSYState> store = StoreProvider.of(context);
      Map userPayload = {
        "ydID": store.state.userInfo.userId.toString(),
        "userId": widget.roomData.user.uid,
        "identity": widget.roomData.user.role == 1 ? "host" : "guest",
        "userName": store.state.userInfo.realName,
        "userIcon": store.state.userInfo.headUrl,
      };
      // String userPayload = jsonEncode(userPayloadMap);
      _whiteboard = Whiteboard(
          appIdentifier: "w0MeEJFIEeqZsrtGYadcXg/CnI3nUtyIcYaNg",
          uuid: widget.roomData.boardId,
          roomToken: widget.roomData.boardToken,
          controller: _whiteboardController,
          userPayload: userPayload);
    }
    return _whiteboard;
  }

  _hand() async {
    if (_handTypeProvider.type == 1) {
      //举手
      _handTypeProvider.switchType(0);
      if (widget.token == null || widget.token == "") {
        await RoomDao.yondorRoomCoVideo(widget.roomData.room.roomId, CoVideoType.APPLY);
      } else {
        await RoomDao.roomCoVideo(widget.roomData.room.roomId, widget.token, CoVideoType.APPLY);
      }
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
          padding: const EdgeInsets.only(top: 2),
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

  _initWebsocketManager() async {
    String key = await httpManager.getAuthorization();
    //设置监听
    BetterSocket.addListener(onOpen: (httpStatus, httpStatusMessage) {
      Log.i("onOpen---httpStatus:$httpStatus  httpStatusMessage:$httpStatusMessage", tag: RoomLandscapePage.sName);
      _socketPingTimer?.cancel();
      _socketPingTimer = null;
      _socketPingTimer = Timer.periodic(_socketPingDuration, (timer) {
        Log.i('sendMsg : ping', tag: RoomLandscapePage.sName);
        BetterSocket.sendMsg('{"Ping":{}}');
      });
      _socketLossTimer?.cancel();
      _socketLossTimer = null;
      _socketLossTimer = Timer.periodic(_socketLossDuration, (timer) {
        Log.i('sendMsg : GetCurrent', tag: RoomLandscapePage.sName);
        BetterSocket.sendMsg('{"GetCurrent":{}}');
      });
    }, onMessage: (message) {
      Log.i('newMsg : $message', tag: RoomLandscapePage.sName);
      try {
        SocketMsg socketMsg = SocketMsg.fromJson(jsonDecode(message.toString()));
        Future(() => _handleSocketMsg(socketMsg));
      } catch (e) {
        Log.e("_handleSocketMsg ${e.toString()} ", tag: RoomLandscapePage.sName);
      }
    }, onClose: (code, reason, remote) {
      Log.i("onClose---code:$code  reason:$reason  remote:$remote", tag: RoomLandscapePage.sName);
      Future.delayed(Duration(milliseconds: 500), () async {
        BetterSocket.connentSocket(AddressUtil.getInstance().socketUrl(key, widget.roomData.room.roomUuid));
      });
    }, onError: (message) {
      Log.w("IOWebSocketChannel onError $message ", tag: RoomLandscapePage.sName);
      if (Platform.isIOS) {
        Future.delayed(Duration(milliseconds: 500), () async {
          BetterSocket.connentSocket(AddressUtil.getInstance().socketUrl(key, widget.roomData.room.roomUuid));
        });
      }
    });
    BetterSocket.connentSocket(AddressUtil.getInstance().socketUrl(key, widget.roomData.room.roomUuid));
  }

  SocketMsg _lastCoursewaretMsg;
  SocketMsg _lastQuesMsg;
  SocketMsg _lastTimerMsg;
  SocketMsg _lastEyerestMsg;
  SocketMsg _lastMp3MsgMsg;
  _handleSocketMsg(SocketMsg socketMsg) {
    switch (socketMsg.type) {
      case ppt:
      case h5:
      case mp4:
      case BREAK:
      case LiveRoomConst.EVENT_CURRENT:
        _lastCoursewaretMsg = socketMsg;
        Future(() => _handleCourseware(socketMsg));
        break;
      case LiveRoomConst.BOARD:
        if ((_currentRes != null && _currentRes.type == mp4)) {
          _resetVideo();
        }
        _resProvider.setRes(null);
        _currentRes = null;
        break;
      case LiveRoomConst.EVENT_BOARD:
        _boardProvider.setEnableBoard(socketMsg.text == "1" ? 1 : 0);
        break;
      case LiveRoomConst.EVENT_HAND:
        _handProvider.setEnableHand(socketMsg.text != null && socketMsg.text == "1" ? true : false);
        break;
      case LiveRoomConst.EVENT_JOIN_SUCCESS:
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
        _lastQuesMsg = socketMsg;
        _handleSEL(socketMsg.text);
        break;
      case RANRED:
        _lastQuesMsg = socketMsg;
        _handleRANRED(socketMsg.text);
        break;
      case REDRAIN:
        _lastQuesMsg = socketMsg;
        _handleREDRAIN(socketMsg.text);
        break;
      case TIMER:
        _lastTimerMsg = socketMsg;
        _handleTIMER(socketMsg.text);
        break;
      case LiveRoomConst.MP3:
        _lastMp3MsgMsg = socketMsg;
        _mp3PlayerProvider.handle(widget.roomData.courseware, socketMsg);
        break;
      case LiveRoomConst.EYEREST:
        _lastEyerestMsg = socketMsg;
        _eyerestProvider.handle(widget.roomData.courseware, socketMsg);
        break;
      case LiveRoomConst.EVENT_STAR:
        _handleSTAR(socketMsg.text);
        break;
      case LiveRoomConst.EVENT_ALL:
        _handleEventAll(socketMsg);
        break;
    }
  }

  _handleEventAll(SocketMsg socketMsg) {
    //处理课件内容
    var msg = jsonDecode(socketMsg.text);
    var coursewareEvent = msg["coursewareEvent"];
    var questEvent = msg["questEvent"];
    var timerEvent = msg["timerEvent"];
    var eyerestEvent = msg["eyerestEvent"];
    var mp3Event = msg["mp3Event"];
    if (coursewareEvent != null) {
      SocketMsg coursewaretMsg = SocketMsg.fromJson(coursewareEvent);
      if (_lastCoursewaretMsg == null || _lastCoursewaretMsg.timestamp < coursewaretMsg.timestamp) {
        _handleCourseware(coursewaretMsg);
      }
    }
    if (questEvent != null) {
      SocketMsg questMsg = SocketMsg.fromJson(questEvent);
      if (_lastQuesMsg == null || _lastQuesMsg.timestamp < questMsg.timestamp) {
        _lastQuesMsg = questMsg;
        if (questMsg.type == SEL || questMsg.type == JUD || questMsg.type == MULSEL) {
          _handleSEL(questMsg.text, isCheck: true);
        } else if (questMsg.type == RANRED) {
          _handleRANRED(questMsg.text, isCheck: true);
        } else if (questMsg.type == REDRAIN) {
          _handleREDRAIN(questMsg.text, isCheck: true);
        }
      }
    }
    if (timerEvent != null) {
      SocketMsg timerMsg = SocketMsg.fromJson(timerEvent);
      if (_lastTimerMsg == null || _lastTimerMsg.timestamp < timerMsg.timestamp) {
        _lastTimerMsg = timerMsg;
        _handleTIMER(timerMsg.text);
      }
    }
    if (eyerestEvent != null) {
      SocketMsg eyerestMsg = SocketMsg.fromJson(eyerestEvent);
      if (_lastEyerestMsg == null || _lastEyerestMsg.timestamp < eyerestMsg.timestamp) {
        _lastEyerestMsg = eyerestMsg;
        _eyerestProvider.handle(widget.roomData.courseware, socketMsg);
      }
    }
    if (mp3Event != null) {
      SocketMsg mp3Msg = SocketMsg.fromJson(mp3Event);
      if (_lastMp3MsgMsg == null || _lastMp3MsgMsg.timestamp < mp3Msg.timestamp) {
        _lastMp3MsgMsg = mp3Msg;
        _mp3PlayerProvider.handle(widget.roomData.courseware, socketMsg);
      }
    }
  }

  _handleSTAR(text) {
    var msg = jsonDecode(text);
    //  "cid":  param.CatalogId,
    //		"qid":  param.QuesId,
    //		"uid":  user.ID,
    //		"star": param.Star,
    //		"msg":  fmt.Sprintf("%s获得%d星星奖励", name, param.Star),
    //		"eid":  param.LiveEventId,
    var eid = msg["eid"];
    var uid = msg["uid"];
    var star = msg["star"];
    if (eid == 12 && uid.toString() == _local.userUuid) {
      if (star > 0) {
        showStarDialog(star);
      }
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
      if (msg["isPlay"] != null && msg["isPlay"] == 1) {
        print("相差时间 _isPlay  ${msg["isPlay"]}");
        msg["time"] = msg["time"] + inSeconds;
      }
    }
    if (ques != null && ques.type == mp4) {
      _isPlay = msg["isPlay"];
      _time = msg["time"];
    }
    Log.d("1111111111111 ${msg["time"]}", tag: RoomLandscapePage.sName);

    if (_currentRes != null && _currentRes.qid == ques.qid) {
      if (_currentRes.type == mp4) {
        var isPlay = msg["isPlay"];

        var time = msg["time"];
        if (flickManager.state == FijkState.asyncPreparing || flickManager.state == FijkState.initialized || flickManager.isPlayable()) {
          if (isPlay == 1) {
            if (time != null && time > 0) {
              Log.d("暂停  flickManager?.seekTo $time ", tag: RoomLandscapePage.sName);
              await flickManager?.seekTo(Duration(seconds: time).inMilliseconds + 500);
            }
            if (flickManager.state == FijkState.completed) {
              await flickManager?.seekTo(0);
            }
            if (flickManager.state != FijkState.started) {
              await flickManager?.start();
            }
          } else {
            if (time != null && time > 0) {
              Log.d("暂停  flickManager?.seekTo $time ", tag: RoomLandscapePage.sName);
              await flickManager?.seekTo(Duration(seconds: time).inMilliseconds);
            }
            Log.d("暂停  flickManager?.pause()", tag: RoomLandscapePage.sName);
            await flickManager?.start();
            Future.delayed(Duration(milliseconds: 300), () {
              flickManager?.pause();
            });
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
            gameOver(ques: ques);
            return;
          }
        }
        _resProvider.setRes(ques, isShow: _resShow);
      }
    } else {
      //切换新页面
      _mp3PlayerProvider.close();
      _eyerestProvider.close();
      if ((_currentRes != null && _currentRes.type == mp4 && ques.type != mp4)) {
        await _resetVideo();
      }
      if (ques.type == mp4 && _currentRes != null && _currentRes.type == mp4) {
        if (flickManager.dataSource != "${widget.roomData.courseware.domain}${ques.data.ps.mp4}" ||
            flickManager.dataSource != "${widget.roomData.courseware.localPath}/${ques.data.ps.mp4}") {
          File file = File(widget.roomData.courseware.localPath + "/" + ques.data.ps.mp4);
          String network = widget.roomData.courseware.domain + ques.data.ps.mp4;
          if (flickManager.state != FijkState.idle) {
            await flickManager.reset();
          }
          await flickManager.setDataSource(file.existsSync() ? file.path : network, showCover: true).catchError((e) {
            print("setDataSource error: $e");
          });
          if (_time != null && _time > 0) {
            Future(() async {
              await flickManager?.start();
              await flickManager?.seekTo(Duration(seconds: _time).inMilliseconds);
              Future.delayed(Duration(seconds: 1), () {
                if (_isPlay != null && _isPlay == 1) {
                  flickManager?.seekTo(Duration(seconds: _time).inMilliseconds + 2000);
                }
              });
              await flickManager?.pause();
              if (_isPlay != null && _isPlay == 1) {
                flickManager?.start();
              }
            });
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
            gameOver(ques: ques, isSwitch: true);
            return;
          }
        }
        if (ques.type == mp4) {
          File file = File(widget.roomData.courseware.localPath + "/" + ques.data.ps.mp4);
          String network = widget.roomData.courseware.domain + ques.data.ps.mp4;
          await flickManager.setOption(FijkOption.playerCategory, "enable-accurate-seek", 1);
          await flickManager.setOption(FijkOption.hostCategory, "request-audio-focus", 1);
          await flickManager.setOption(FijkOption.formatCategory, "fflags", "fastseek");
          await flickManager.setOption(FijkOption.playerCategory, "framedrop", 5);
          await flickManager.setDataSource(file.existsSync() ? file.path : network, showCover: true).catchError((e) {
            print("setDataSource error: $e");
          });
          if (_time != null && _time > 0) {
            Future(() async {
              await flickManager?.start();
              await flickManager?.seekTo(Duration(seconds: _time).inMilliseconds);
              Future.delayed(Duration(seconds: 1), () {
                if (_isPlay != null && _isPlay == 1) {
                  flickManager?.seekTo(Duration(seconds: _time).inMilliseconds + 2000);
                }
              });
              await flickManager?.pause();
              if (_isPlay != null && _isPlay == 1) {
                flickManager?.start();
              }
            });
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
        if (null == value || value == 0) {
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
          Log.f("rewardStar  ${res.toString()}", tag: RoomLandscapePage.sName);
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
        if (value != null) {
          var param = {
            "catalogId": ques.ctatlogid,
            "liveCourseallotId": widget.roomData.liveCourseallotId,
            "liveEventId": 3,
            "quesId": ques.qid,
            "star": value,
            "roomId": widget.roomData.room.roomUuid
          };
          RoomDao.rewardStar(param).then((res) {
            Log.f("rewardStar  ${res.toString()}", tag: RoomLandscapePage.sName);
            if (res.result != null && res.data != null && res.data["code"] == 200) {
              if (res.data["data"]["status"] == 1) {
                showStarDialog(value);
              }
            } else {
              showToast("领取失败请稍后重试!!!");
            }
          });
        }
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
      //切换新页面
      _mp3PlayerProvider.close();
      _eyerestProvider.close();
      if ((_currentRes != null && _currentRes.type == mp4 && ques.type != mp4)) {
        _resetVideo();
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
      if (isShow == 1) {
        if (ques.qid != _resProvider.res.qid) {
          //只在当前窗口弹出
          return;
        }
      }
      _roomSelProvider.setIsShow(isShow == 1, ques: ques, op: op, quesAn: as, dateTime: DateTime.now());
      if (isShow == 0) {
        //获取排行榜前三用户
        var param = {"liveCourseallotId": widget.roomData.liveCourseallotId, "liveEventId": 1, "quesId": ques.qid, "roomId": widget.roomData.room.roomUuid};
        Log.f("RoomDao.quesTop param $param", tag: RoomLandscapePage.sName);
        final res = await RoomDao.quesTop(param);
        if (res.result != null && res.data != null && res.data["code"] == 200) {
          Log.f(res.data, tag: RoomLandscapePage.sName);
          if (res.data["data"] != null && res.data["data"].length > 0) {
            showLiveTopDialog(res.data["data"]);
          } else {
            Log.i("该题目无人上榜 ${res.data}", tag: RoomLandscapePage.sName);
          }
        } else {
          Log.e("查询题目前三排行榜失败！！", tag: RoomLandscapePage.sName);
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
        Log.f("rewardStar  ${res.toString()}", tag: RoomLandscapePage.sName);
        if (res.result != null && res.data != null && res.data["code"] == 200) {
          if (res.data["data"]["status"] == 1) {
            _starWidgetProvider.addStar(s);
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
    if (num > 0) {
      return _startForward(num);
    }
    return null;
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
    if (_isIos13) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ChangeNotifierProvider<StarWidgetProvider>.value(value: _starWidgetProvider, child: Start(frequency: num));
          });
    } else {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ChangeNotifierProvider<StarWidgetProvider>.value(value: _starWidgetProvider, child: StarDialog(starNum: num));
          });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (orientation == 1) {
      OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    }
    AgoraRtcEngine?.leaveChannel();
    AgoraRtcEngine?.destroy();
    _rtmChannel?.leave();
    _rtmClient?.logout();
    _hiddenTopTimer?.cancel();
    _socketPingTimer?.cancel();
    _socketLossTimer?.cancel();
    socket?.close();
    BetterSocket.close();
    flickManager?.release();
    socket = null;
    _currentRes = null;
    _subscription?.cancel();
    _mp3PlayerProvider.close();
    _eyerestProvider.close();
    _textController?.dispose();
    PaintingBinding.instance.imageCache.clear();
    _roomEduSocket?.close();
    super.dispose();
  }

  _resetVideo() async {
    await flickManager?.reset();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("RoomLandscapePageState 切换" + state.toString());
    switch (state) {
      case AppLifecycleState.resumed:
        print('RoomLandscapePageState 处于前台展示');
        if (_courseProvider.status == 1) {
          AgoraRtcEngine?.muteAllRemoteVideoStreams(false);
          AgoraRtcEngine?.muteAllRemoteAudioStreams(false);
        }
        break;
      case AppLifecycleState.inactive:
        print('RoomLandscapePageState 处于非活动状态，并且未接收用户输入');
        break;
      case AppLifecycleState.paused:
        AgoraRtcEngine?.muteAllRemoteVideoStreams(true);
        AgoraRtcEngine?.muteAllRemoteAudioStreams(true);
        break;
      default:
        break;
    }
  }

  getMsgList() async {
    print("@getMsgList");
    try {
      final res = await RoomDao.getMsgList(widget.roomData.liveCourseallotId, widget.roomData.room.roomId);
      if (res.result != null && res.result && res.data != null) {
        if (res.data is List<ChatMessage>) {
          final list = res.data;
          list.insertAll(0, _chatProvider.chatMessageList);
          _chatProvider.setChatMessageList(list);
        } else {
          _chatProvider.setChatMessageList(List<ChatMessage>());
        }
      } else {
        _chatProvider.setChatMessageList(List<ChatMessage>());
      }
    } catch (e) {
      print("@@getMsgList $e");
      _chatProvider.setChatMessageList(List<ChatMessage>());
    }
  }

  @override
  String tagName() {
    return RoomLandscapePage.sName;
  }

  void print(msg, {int level = Log.fine}) {
    funMap[level](msg, tag: tagName());
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
