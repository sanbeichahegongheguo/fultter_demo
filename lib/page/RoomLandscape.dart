import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/Courseware.dart';
import 'package:flutter_start/widget/DIYKeyboard.dart';
import 'package:flutter_start/widget/InputButtomWidget.dart';
import 'package:flutter_start/widget/LiveRankWidget.dart';
import 'package:flutter_start/widget/LiveTopDialog.dart';
import 'package:flutter_start/widget/StarGif.dart';
import 'package:flutter_start/widget/RedPacket.dart';
import 'package:flutter_start/widget/RedRain.dart';
import 'package:flutter_start/widget/StarDialog.dart';
import 'package:flutter_start/widget/LiveQuesDialog.dart';
import 'package:flutter_start/widget/courseware_video.dart';
import 'package:flutter_start/widget/starsWiget.dart';
import 'package:fradio/fradio.dart';
import 'package:fsuper/fsuper.dart';
import 'package:yondor_whiteboard/whiteboard.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/RoomDao.dart';
import 'package:flutter_start/models/ChatMessage.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/models/RoomUser.dart';
import 'package:flutter_start/provider/provider.dart';
import 'package:flutter_start/widget/bubble.dart';
import 'package:flutter_start/widget/expanded_viewport.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';
import 'package:orientation/orientation.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/utils/Log.dart';
import 'package:better_socket/better_socket.dart';
import 'package:redux/redux.dart';
import 'dart:math';

class RoomLandscapePage extends StatefulWidget {
  static final String sName = "RoomLandscape";

  final RoomData roomData;
  final String token;
  final String boardId;
  final String boardToken;
  const RoomLandscapePage({Key key, this.roomData, this.token, this.boardId, this.boardToken}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return RoomLandscapePageState(courseState: roomData.room.courseState);
  }
}

class RoomLandscapePageState extends State<RoomLandscapePage> with SingleTickerProviderStateMixin {
  final int courseState;
  static const String mp4 = "MP4";
  static const String ppt = "PIC";
  static const String h5 = "HTM";
  static const String SEL = "SEL"; //1:SEL 选择题
  static const String RANRED = "RANRED"; //80:RANRED 随机红包
  static const String REDRAIN = "REDRAIN"; //81:REDRAIN 红包雨

  CourseStatusProvider _courseStatusProvider;
  RoomLandscapePageState({this.courseState = 0}) {
    _courseStatusProvider = CourseStatusProvider(courseState);
  }

  @override
  void initState() {
    super.initState();
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
    orientation = 1;
    _initWebsocketManager();
    initializeRtm();
    initializeRtc();
    _local = widget.roomData.user;
    _updateUsers(widget.roomData.room.coVideoUsers);
    Future.delayed(Duration(milliseconds: 1000)).then((e) {
      rewardFirstStar();
    });
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

  int _isPlay;
  int _time;
  final TextEditingController _textController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final _infoStrings = <String>[];
  static final _users = <int>[];
  WhiteboardController _whiteboardController = WhiteboardController();
  Timer _hiddenTopTimer;
  FlickManager flickManager;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
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
          ChangeNotifierProvider<CourseStatusProvider>.value(
            value: _courseStatusProvider,
          ),
        ],
        child: WillPopScope(
          onWillPop: () {
            if (orientation == 1) {
              OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
              orientation = 0;
              Future.delayed(Duration(milliseconds: 500), () async {
                Navigator.pop(context);
              });
            }
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
                    child: Padding(
                        padding: EdgeInsets.only(top: ScreenUtil.getInstance().statusBarHeight),
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
                            _buildRank(),
                            _buildSel(),
                            _buildTop(),
                            _starWidget(),
                          ],
                        )))),
          ),
        ));
  }

  _buildRank() {
    return Align(
        alignment: Alignment.topLeft, child: LiveRankWidget(liveCourseallotId: widget.roomData.liveCourseallotId, roomId: widget.roomData.room.roomUuid));
  }

  ///选择题
  var _selBtnName = ["A", "B", "C", "D", "E", "F"];

  ///构建选择题
  Widget _buildSel() {
    return Consumer<RoomSelProvider>(builder: (context, model, child) {
      return model.isShow
          ? Align(
              alignment: Alignment(0.11, 0.9),
              child: Stack(
                alignment: Alignment(0.0, -2.1),
                children: <Widget>[
                  Container(
                      width: model.op != null && model.op.length == 2 ? ScreenUtil.getInstance().getWidthPx(400) : ScreenUtil.getInstance().getWidthPx(580),
                      height: ScreenUtil.getInstance().getWidthPx(100),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.all(Radius.circular(50.0)),
                        border: new Border.all(
                          //添加边框
                          width: 1, //边框宽度
                          color: Color(0xFFececec), //边框颜色
                        ),
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Colors.black, //阴影颜色
                            blurRadius: 1, //阴影大小
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: ScreenUtil.getInstance().getWidthPx(20),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: model.op != null ? model.op.length : 4,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: index == 4 ? 0 : 10),
                                      child: FRadio(
                                        corner: FRadioCorner.all(30),
                                        normalColor: Color(0XFFb1dab7),
                                        width: ScreenUtil.getInstance().getWidthPx(75),
                                        height: ScreenUtil.getInstance().getWidthPx(75),
                                        value: index + 1,
                                        groupValue: model.val,
                                        onChanged: (value) {
                                          model.switchVal(value);
                                        },
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xff3cc969),
                                            Color(0xff43cf70),
                                            Color(0xff3eb765),
                                            Color(0xff3daa60),
                                          ],
                                          begin: Alignment(-0.1, -0.9),
                                          end: Alignment(1.0, 1.0),
                                          stops: [0.0, 0.2, 0.7, 1.0],
                                        ),
                                        selectedColor: Color(0xff3cc969),
                                        hasSpace: false,
                                        border: 1.5,
                                        child: Text(
                                          "${(model.op != null && model.op.length == 2) ? model.op[index] : _selBtnName[index]}",
                                          style: TextStyle(color: Color(0xFF3cc969), fontSize: 13),
                                        ),
                                        hoverChild: Text(
                                          "${(model.op != null && model.op.length == 2) ? model.op[index] : _selBtnName[index]}",
                                          style: TextStyle(color: Colors.white, fontSize: 13),
                                        ),
                                        selectedChild: Text("${(model.op != null && model.op.length == 2) ? model.op[index] : _selBtnName[index]}",
                                            style: TextStyle(color: Colors.white, fontSize: 13)),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: CommonUtils.buildBtn("提交",
                                width: ScreenUtil.getInstance().getWidthPx(130), height: ScreenUtil.getInstance().getHeightPx(250), onTap: () {
                              if (model.val < 1) {
                                return;
                              }
                              var isRight = "F";
                              if (model.quesAn == (model.val - 1)) {
                                isRight = "T";
                              }
                              final val = model.val;
                              final op = model.op;
                              var answer =
                                  '{"answer":"${model.val - 1}","isRight":"$isRight","quesId":${model.ques.qid},"userAnswer":{"qid":${model.ques.qid},"uan":[{"an":"${model.val - 1}","r":"$isRight"}]}}';
                              var useTime = DateTime.now().difference(model.dateTime).inMilliseconds;
                              var param = {
                                "catalogId": model.ques.ctatlogid,
                                "liveCourseallotId": widget.roomData.liveCourseallotId,
                                "liveEventId": 1,
                                "quesId": model.ques.qid,
                                "isRight": isRight,
                                "roomId": widget.roomData.room.roomUuid
                              };
                              param["answerJson"] = answer;
                              param["useTime"] = useTime;

                              var qlibParam = {
                                "lessonId": model.ques.ctatlogid,
                                "quesId": model.ques.qid,
                                "isRight": isRight,
                                "batchNo": widget.roomData.room.roomUuid,
                                "ctkDatafrommapId": 49
                              };
                              qlibParam["costTime"] = useTime;
                              qlibParam["userAnswer"] = answer;
                              RoomDao.saveQuesToQlib(qlibParam);
                              RoomDao.saveQues(param).then((res) {
                                Log.f("rewardStar  ${res.toString()}", tag: RoomLandscapePage.sName);
                                if (res.result != null && res.data != null && res.data["code"] == 200) {
                                  NavigatorUtil.showGSYDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        print("  op     $op");
                                        return LiveQuesDialog(
                                          ir: isRight,
                                          star: res.data["data"]["star"],
                                          an: "${(op != null && op.length == 2) ? op[val - 1] : _selBtnName[val - 1]}",
                                        );
                                      });
                                } else {
                                  showToast("提交失败请稍后重试!!!");
                                }
                              });
                              model.setIsShow(false);
                            },
                                splashColor: Colors.amber,
                                decorationColor: Color(0xFF3cc969),
                                textColor: Colors.white,
                                textSize: ScreenUtil.getInstance().getSp(8),
                                elevation: 2),
                          ),
                          SizedBox(
                            width: ScreenUtil.getInstance().getWidthPx(20),
                          ),
                        ],
                      )),
                  Stack(
                    alignment: AlignmentDirectional(0.0, 1.2),
                    children: <Widget>[
                      Container(
                          alignment: Alignment.topCenter,
                          height: ScreenUtil.getInstance().getWidthPx(40),
                          width: ScreenUtil.getInstance().getWidthPx(150),
                          child: Text("单选题"),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.all(Radius.circular(50.0)),
                            border: new Border.all(
                              //添加边框
                              width: 1, //边框宽度
                              color: Color(0xFFececec), //边框颜色
                            ),
                            boxShadow: <BoxShadow>[
                              new BoxShadow(
                                color: Colors.black, //阴影颜色
                                blurRadius: 1, //阴影大小
                              ),
                            ],
                          )),
                      Container(
                        color: Colors.white,
                        height: ScreenUtil.getInstance().getWidthPx(10),
                        width: ScreenUtil.getInstance().getWidthPx(150),
                      )
                    ],
                  ),
                ],
              ),
            )
          : Container();
    });
  }

  Widget _buildCourseware() {
    return Consumer2<CourseStatusProvider, ResProvider>(builder: (context, courseStatusModel, resModel, child) {
      Widget result;
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
                      width: ScreenUtil.getInstance().screenWidth * 0.8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            "images/live/awaitIcon.png",
                            width: ScreenUtil.getInstance().getWidthPx(200),
                            fit: BoxFit.contain,
                          ),
                          Text(
                            "老师正赶过来，请准备好纸笔耐心等待~",
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
      } else if (resModel.res != null && resModel.res.screenId != null && resModel.res.screenId > 0) {
        result = GestureDetector(
          key: ValueKey("screen"),
          child: Container(width: ScreenUtil.getInstance().screenWidth * 0.8, child: AgoraRenderWidget(resModel.res.screenId)),
          onTap: () => _roomShowTopProvider.setIsShow(true),
        );
      } else if (resModel.res != null) {
        if (resModel.res.type == h5) {
          result = Container(
            width: ScreenUtil.getInstance().screenWidth * 0.8,
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
                print("loadurl ${widget.roomData.courseware.localPath + "/" + await CommonUtils.urlJoinUser(resModel.res.data.ps.h5url)}");
                controller.loadUrl(widget.roomData.courseware.localPath + "/" + await CommonUtils.urlJoinUser(resModel.res.data.ps.h5url));
              },
            ),
          );
        } else if (resModel.res.type == ppt) {
          result = GestureDetector(
            child: Container(
                width: ScreenUtil.getInstance().screenWidth * 0.8,
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
              videoPlayerController: file.existsSync()
                  ? VideoPlayerController.file(file)
                  : VideoPlayerController.network(widget.roomData.courseware.domain + resModel.res.data.ps.mp4),
            );

            if (_time != null && _time > 0) {
              Future.delayed(Duration(seconds: 2), () async {
                flickManager.flickControlManager?.seekTo(Duration(seconds: _time + 2));
              });
            }
          }
          result = Container(
            width: ScreenUtil.getInstance().screenWidth * 0.8,
            child: CoursewareVideo(flickManager,
                pic: "${widget.roomData.courseware.localPath}/${resModel.res.data.ps.pic}", soundAction: () => _roomShowTopProvider.setIsShow(true)),
          );
        }
      }

      if (!(resModel.res != null && resModel.res.screenId != null && resModel.res.screenId > 0)) {
        result = Container(
          width: ScreenUtil.getInstance().screenWidth * 0.8,
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
                return Offstage(
                  offstage: !(courseStatusModel.status == 1 && model.enableBoard == 1),
                  child: Stack(
                    alignment: AlignmentDirectional(0.9, -0.9),
                    children: <Widget>[
                      _buildWhiteboard(),
                      _buildStudentVideo(),
                    ],
                  ),
                );
              })
            ],
          ),
        );
      }

      if ((resModel.res == null || resModel.res.type != mp4) && _isPlay != null) {
        print("MP4 close111");
        _closeVideo();
      }
      return result;
    });
  }

  ///左上角 星星
  Widget _starWidget() {
    return Consumer2<TeacherProvider, CourseStatusProvider>(builder: (context, teacherModel, courseStatusModel, child) {
      return courseStatusModel.status == 1
          ? Positioned(
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
                          "2050",
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
            )
          : Container();
    });
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
                              size: ScreenUtil.getInstance().getSp(12),
                            ),
                            onPressed: () {
                              if (orientation == 1) {
                                OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
                              }
                              Future.delayed(Duration(milliseconds: 500), () async {
                                Navigator.pop(context);
                              });
                            }),
                        SizedBox(
                          width: ScreenUtil.getInstance().getWidthPx(15),
                        ),
                        Text(widget.roomData.courseware.name, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getInstance().getSp(12)))
                      ],
                    ))
                : Container(),
          ));
    });
  }

  ///视频区域
  Widget _buildVideo() {
    return Consumer2<TeacherProvider, CourseStatusProvider>(builder: (context, teacherModel, courseStatusModel, child) {
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
      AgoraRtcEngine.setClientRole(model.user.coVideo == 1 ? ClientRole.Broadcaster : ClientRole.Audience);
      if (_teacher != null && _teacher.coVideo == 1 && model.user.coVideo == 1) {
        AgoraRtcEngine.muteLocalAudioStream(model.user.enableVideo != 1);
        AgoraRtcEngine.muteLocalVideoStream(model.user.enableAudio != 1);
        if (model.user.enableVideo == 1) {
          AgoraRtcEngine.enableLocalVideo(true);
        }
        if (model.user.enableAudio == 1) {
          AgoraRtcEngine.enableLocalAudio(true);
        }
      }

      Widget widget = Container();
      if (model.user.coVideo == 1) {
        widget = Container(
            color: Colors.white,
            height: ScreenUtil.getInstance().getHeightPx(440),
            width: ScreenUtil.getInstance().getHeightPx(550),
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
            height: ScreenUtil.getInstance().getWidthPx(220),
            width: ScreenUtil.getInstance().getWidthPx(220),
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
                                _chatProvider.setIsComposing(text.length > 0);
                              },
                              onTap: () {
                                _showKeyboard(model);
                              },
                              onSubmitted: _handleSubmitted,
                              decoration: InputDecoration.collapsed(hintText: model.muteAllChat ? "禁言中" : '发送消息'),
                            ),
                            // onTap: model.muteAllChat
                            //     ? null
                            //     : () {
                            //         Navigator.push(
                            //             context,
                            //             PopRoute(
                            //                 child: ChangeNotifierProvider<
                            //                         ChatProvider>.value(
                            //                     value: _chatProvider,
                            //                     child: InputButtomWidget(
                            //                       onChanged: (String text) {
                            //                         _chatProvider
                            //                             .setIsComposing(
                            //                                 text.length > 0);
                            //                       },
                            //                       controller: _textController,
                            //                       onSubmitted: _handleSubmitted,
                            //                     ))));
                            //         print("#1 123123");
                            //       },
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
        if (msgJson["data"]["courseState"] != _courseStatusProvider.status) {
          _courseStatusProvider.setStatus(msgJson["data"]["courseState"]);
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
    configuration.dimensions = Size(1920, 1080);
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(widget.roomData.user.rtcToken, widget.roomData.room.channelName, widget.roomData.user.userName, widget.roomData.user.uid);
    if (_teacher != null) {
      _teacherProvider.notifier(_teacher);
    }
  }

  _startVideo() async {
    print("_startVideo ::_local $_local");
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
      _startVideo();
    } else {
      _local?.coVideo = 0;
    }
    _others.clear();
    _others.addAll(others);
    _studentProvider.notifier(_local);
  }

  ///白板区域
  Widget _buildWhiteboard() {
    if (_whiteboard == null) {
      _whiteboard = Whiteboard(
          appIdentifier: "w0MeEJFIEeqZsrtGYadcXg/CnI3nUtyIcYaNg", uuid: widget.boardId, roomToken: widget.boardToken, controller: _whiteboardController);
    }
    return Stack(alignment: AlignmentDirectional(0.9, 0.9), children: <Widget>[
      _whiteboard,
      Consumer<HandTypeProvider>(builder: (context, model, child) {
        return GestureDetector(
          child: Card(
            elevation: 1,
            color: Colors.white,
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
    ]);
  }

  _hand() async {
    if (_handTypeProvider.type == 1) {
      //举手
      await RoomDao.roomCoVideo(widget.roomData.room.roomId, widget.token, CoVideoType.APPLY);
    } else {
      //取消连麦
      var res = await RoomDao.roomCoVideo(widget.roomData.room.roomId, widget.token, _local.coVideo == 1 ? CoVideoType.EXIT : CoVideoType.CANCEL);
      if (res.data["msg"] == "Success") {
        _handTypeProvider.switchType(1);
      }
    }
  }

  double fontSize = ScreenUtil.getInstance().getSp(12);

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

  _initWebsocketManager() async {
    String key = await httpManager.getAuthorization();
    //设置监听
    BetterSocket.addListener(onOpen: (httpStatus, httpStatusMessage) {
      Log.i("onOpen---httpStatus:$httpStatus  httpStatusMessage:$httpStatusMessage", tag: RoomLandscapePage.sName);
    }, onMessage: (message) {
      Log.d('newMsg : $message', tag: RoomLandscapePage.sName);
      try {
        SocketMsg socketMsg = SocketMsg.fromJson(jsonDecode(message.toString()));
        _handleSocketMsg(socketMsg);
      } catch (e) {
        Log.e("_handleSocketMsg ${e.toString()} ", tag: RoomLandscapePage.sName);
      }
    }, onClose: (code, reason, remote) {
      Log.f("onClose---code:$code  reason:$reason  remote:$remote", tag: RoomLandscapePage.sName);
      Future.delayed(Duration(milliseconds: 500), () async {
        BetterSocket.connentSocket(AddressUtil.getInstance().socketUrl(key, widget.roomData.room.roomUuid));
      });
    }, onError: (message) {
      Log.w("IOWebSocketChannel onError $message ", tag: RoomLandscapePage.sName);
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
    Courseware courseware = widget.roomData.courseware;
    switch (socketMsg.type) {
      case ppt:
      case h5:
      case mp4:
      case "event-current":
        if (socketMsg.text == "") {
          _resProvider.setRes(null);
          return;
        }
        //处理课件内容
        var msg = jsonDecode(socketMsg.text);
        var qid = msg["qid"];
        Res ques = courseware.findQues(qid);
        if (ques == null) {
          showToast("出错了!!!");
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
        Log.d("1111111111111 ${msg["time"]}", tag: RoomLandscapePage.sName);
        if (ques != null && ques.type == mp4) {
          _isPlay = msg["isPlay"];
          _time = msg["time"];
        }

        if (_currentRes != null && _currentRes.qid == ques.qid) {
          if (_currentRes.type == mp4) {
            var isPlay = msg["isPlay"];
            var time = msg["time"];
            if (flickManager != null && flickManager.flickVideoManager != null) {
              if (flickManager.flickVideoManager.isPlaying && isPlay == 0) {
                flickManager?.flickControlManager?.autoPause();
              } else if (flickManager.flickVideoManager.isPlaying && isPlay == 1) {
                if (time != null && time > 0) {
                  flickManager?.flickControlManager?.seekTo(Duration(seconds: time));
                }
              } else if (flickManager.flickVideoManager.isVideoEnded && isPlay == 1) {
                if (time != null && time > 0) {
                  flickManager?.flickControlManager?.seekTo(Duration(seconds: time));
                }
                flickManager?.flickControlManager?.play();
              } else if (!flickManager.flickVideoManager.isPlaying && isPlay == 1) {
                flickManager?.flickControlManager?.autoResume();
                if (time != null && time > 0) {
                  flickManager?.flickControlManager?.seekTo(Duration(seconds: time));
                }
              }
            }
          }
        } else {
          _resProvider.setRes(ques);
        }
        _currentRes = ques;
        break;
      case "board":
        _resProvider.setRes(null);
        _currentRes = null;
        break;
      case "event-board":
        _boardProvider.setEnableBoard(socketMsg.text == "1" ? 1 : 0);
        break;
      case "event-join-success":
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
          if (e["type"] == SEL) {
            _handleSEL(e["text"], isCheck: true);
          } else if (e["type"] == RANRED) {
            _handleRANRED(e["text"], isCheck: true);
          } else if (e["type"] == REDRAIN) {
            _handleREDRAIN(e["text"], isCheck: true);
          }
        }
        break;
      case SEL:
        _handleSEL(socketMsg.text);
        break;
      case RANRED:
        _handleRANRED(socketMsg.text);
        break;
      case REDRAIN:
        _handleREDRAIN(socketMsg.text);
        break;
    }
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
    return showDialog(
        context: context,
        builder: (context) {
          return MediaQuery(

              ///不受系统字体缩放影响
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window).copyWith(textScaleFactor: 1),
              child: LiveTopDialog(data: data));
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
    return NavigatorUtil.showGSYDialog(
        context: context,
        builder: (BuildContext context) {
          return RedPacketDialog();
        });
  }

  ///启动获取星星动画
  _startForward(num) {
    return NavigatorUtil.showGSYDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new Start(frequency: num);
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
    socket?.close();
    BetterSocket.close();
    socket = null;
    _currentRes = null;
    super.dispose();
  }

  _closeVideo() {
    flickManager?.dispose();
    flickManager = null;
    _isPlay = null;
    _time = null;
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
