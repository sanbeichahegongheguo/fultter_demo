import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';

class RoomPage extends StatefulWidget {
  static final String sName = "room";

  final RoomData roomData;
  final String token;
  final String boardId;
  final String boardToken;
  const RoomPage({Key key, this.roomData, this.token, this.boardId, this.boardToken}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return RoomPageState();
  }
}

class RoomPageState extends State<RoomPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    initializeRtm();
    initializeRtc();
    _local = widget.roomData.user;
    _updateUsers(widget.roomData.room.coVideoUsers);
  }

  AgoraRtmClient _rtmClient;
  AgoraRtmChannel _rtmChannel;
  RoomUser _local;
  RoomUser _teacher;
  List<RoomUser> _others = new List();
  Widget _whiteboard;
  TeacherProvider _teacherProvider = TeacherProvider();
  StudentProvider _studentProvider = StudentProvider();
  RoomTabProvider _roomTabProvider = RoomTabProvider();
  HandTypeProvider _handTypeProvider = HandTypeProvider();
  ChatProvider _chatProvider = ChatProvider();
  final TextEditingController _textController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final _infoStrings = <String>[];
  static final _users = <int>[];
  WhiteboardController _whiteboardController = WhiteboardController();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TeacherProvider>.value(
          value: _teacherProvider,
        ),
        ChangeNotifierProvider<RoomTabProvider>.value(
          value: _roomTabProvider,
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
      ],
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Text(
              widget.roomData.room.roomName,
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
          body: Column(children: <Widget>[
            //视频区域
            _buildVideo(),
            //选项卡
            Consumer<RoomTabProvider>(builder: (context, model, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                      height: 40,
                      width: ScreenUtil.getInstance().screenWidth / 2,
                      child: FlatButton(
                          textColor: model.index == 1 ? Colors.blueAccent : Colors.black26,
                          child: Text(
                            "教材区",
                          ),
                          highlightColor: Colors.transparent,
                          color: Colors.transparent,
                          onPressed: () {
                            if (model.index != 1) {
                              model.switchIndex(1);
                            }
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                  SizedBox(
                    height: 40,
                    width: ScreenUtil.getInstance().screenWidth / 2,
                    child: FlatButton(
                        textColor: model.index == 2 ? Colors.blueAccent : Colors.black26,
                        child: Text(
                          "聊天区",
                        ),
                        highlightColor: Colors.transparent,
                        color: Colors.transparent,
                        onPressed: () {
                          if (model.index != 2) {
                            model.switchIndex(2);
                          }
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                  )
                ],
              );
            }),
            Consumer<RoomTabProvider>(builder: (context, model, child) {
              return Expanded(
                flex: model.index == 1 ? 1 : 0,
                child: Visibility(
                    visible: model.index == 1, replacement: Container(), maintainState: true, child: model.index == 1 ? _buildWhiteboard() : Container()),
              );
            }),
            Consumer<RoomTabProvider>(builder: (context, model, child) {
              return Expanded(
                flex: model.index == 2 ? 1 : 0,
                child: Visibility(
                    visible: model.index == 2,
                    replacement: Container(),
                    maintainState: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        //  点击顶部空白处触摸收起键盘
                        FocusScope.of(context).requestFocus(FocusNode());
                        //                changeNotifier.sink.add(null);
                      },
                      child: _buildChat(),
                    )),
              );
            }),
            Consumer<RoomTabProvider>(builder: (context, model, child) {
              return model.index == 2 ? _buildTextComposer() : Container();
            }),
          ])),
    );
  }

  ///视频区域
  Widget _buildVideo() {
    return Consumer<TeacherProvider>(builder: (context, model, child) {
      return Stack(
        alignment: AlignmentDirectional(0.9, -0.9),
        children: <Widget>[
          Container(
              color: Colors.white,
              height: ScreenUtil.getInstance().getHeightPx(550),
              child: model.user != null && model.user.coVideo == 1 && model.user.enableVideo == 1
                  ? AgoraRenderWidget(model.user.uid)
                  : Container(
                      color: Colors.white,
                      child: Image.asset(
                        'images/ic_teacher.png',
                        width: ScreenUtil.getInstance().screenWidth,
                        height: ScreenUtil.getInstance().getWidthPx(550),
                      ),
                    )),
          Consumer<StudentProvider>(builder: (context, model, child) {
            AgoraRtcEngine.setClientRole(model.user.coVideo == 1 ? ClientRole.Broadcaster : ClientRole.Audience);
            AgoraRtcEngine.muteLocalAudioStream(model.user.enableVideo != 1);
            AgoraRtcEngine.muteLocalVideoStream(model.user.enableAudio != 1);
            if (model.user.enableVideo == 1) {
              AgoraRtcEngine.enableLocalVideo(true);
            }
            if (model.user.enableAudio == 1) {
              AgoraRtcEngine.enableLocalAudio(true);
            }
            Widget widget = Container();
            if (model.user.coVideo == 1) {
              widget = Container(
                  color: Colors.white,
                  height: ScreenUtil.getInstance().getHeightPx(220),
                  width: ScreenUtil.getInstance().getHeightPx(220),
                  child: model.user.coVideo == 1 && model.user.enableVideo == 1
                      ? AgoraRenderWidget(model.user.uid, local: true)
                      : Container(
                          color: Colors.white,
                          child: Image.asset(
                            'images/ic_student.png',
                            width: ScreenUtil.getInstance().screenWidth,
                            height: ScreenUtil.getInstance().getWidthPx(550),
                          )));
            } else if (_others.length > 0) {
              widget = Container(
                  color: Colors.white,
                  height: ScreenUtil.getInstance().getHeightPx(220),
                  width: ScreenUtil.getInstance().getHeightPx(220),
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
          }),
        ],
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
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(children: <Widget>[
                          Flexible(
                              child: new TextField(
                            enabled: !model.muteAllChat,
                            controller: _textController,
                            onChanged: (String text) {
                              _chatProvider.setIsComposing(text.length > 0);
                            },
                            onSubmitted: _handleSubmitted,
                            decoration: InputDecoration.collapsed(hintText: model.muteAllChat ? "禁言中" : '发送消息'),
                          )),
                          !model.muteAllChat
                              ? Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                  child: IconButton(icon: Icon(Icons.send), onPressed: model.isComposing ? () => _handleSubmitted(_textController.text) : null),
                                )
                              : Container()
                        ]));
                  }))),
        ],
      )
    ]);
  }

  ///发送信息
  Future _handleSubmitted(String text) async {
    if (text.trim() == "") return;
    _textController.clear();
    _chatProvider.setIsComposing(false);
    FocusScope.of(context).requestFocus(new FocusNode());
    RoomDao.roomChat(widget.roomData.room.roomId, widget.token, text, widget.roomData.room.roomUuid);
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
      _infoStrings.add(info);
    };

    AgoraRtcEngine.onLeaveChannel = () {
      _infoStrings.add('onLeaveChannel');
      _users.clear();
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      final info = 'userJoined: $uid';
      _infoStrings.add(info);
      _users.add(uid);
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      final info = 'userOffline: $uid';
      _infoStrings.add(info);
      _users.remove(uid);
    };
    AgoraRtcEngine.onFirstRemoteVideoFrame = (int uid, int width, int height, int elapsed) {
      final info = 'firstRemoteVideo: $uid ${width}x $height';
      _infoStrings.add(info);
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
    return Stack(alignment: AlignmentDirectional(0.9, -0.9), children: <Widget>[
      Whiteboard(uuid: widget.boardId, roomToken: widget.boardToken, controller: _whiteboardController),
      Consumer<HandTypeProvider>(builder: (context, model, child) {
        return GestureDetector(
          child: Card(
            elevation: 1,
            color: Colors.white,
            child: Image.asset(
              model.type == 1 ? 'images/ic_hand_up.png' : 'images/ic_hand_down.png',
              width: ScreenUtil.getInstance().getWidthPx(135),
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
                          child: Row(
                            //  mainAxisAlignment:MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0, left: 10, top: 5),
                                child: Text(
                                  model.chatMessageList[i].userName,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                                ),
                                child: Bubble(
                                  style: BubbleStyle(
                                    nip: BubbleNip.leftText,
                                    color: Colors.white,
                                    nipOffset: 5,
                                    nipWidth: 10,
                                    nipHeight: 10,
                                    margin: BubbleEdges.only(right: 50.0),
                                    padding: BubbleEdges.only(top: 8, bottom: 10, left: 10, right: 15),
                                  ),
                                  child: Text(
                                    model.chatMessageList[i].message,
                                    softWrap: true,
                                    style: TextStyle(fontSize: 14.0, color: Colors.black),
                                  ),
                                ),
                                margin: EdgeInsets.only(
                                  bottom: 5.0,
                                ),
                              ),
                            ],
                          ));
                    },
                    childCount: model.chatMessageList.length,
                  ),
                );
              }),
//                        SliverToBoxAdapter(
//                          child: isShowLoading
//                              ? Container(
//                            margin: EdgeInsets.only(top: 5),
//                            height: 50,
//                            child: Center(
//                              child: SizedBox(
//                                width: 25.0,
//                                height: 25.0,
//                                child: CircularProgressIndicator(
//                                  strokeWidth: 3,
//                                ),
//                              ),
//                            ),
//                          )
//                              : new Container(),
//                        ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    AgoraRtcEngine?.leaveChannel();
    AgoraRtcEngine?.destroy();
    _rtmChannel?.leave();
    _rtmClient?.logout();
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
