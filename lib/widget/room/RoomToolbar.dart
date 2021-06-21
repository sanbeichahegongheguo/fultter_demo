import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:provider/provider.dart';
import 'package:yondor_whiteboard/whiteboard.dart';

///房间工具栏
///画笔 举手 排行榜 聊天
///
class RoomToolbar extends StatefulWidget {
  RoomToolbarProvider model;
  BoardProvider boardProvider;
  WhiteboardController whiteboardController;
  Widget textComposer;
  int userGrantBoard;
  Widget liveRank;
  final Function handCall;

  RoomToolbar({Key key, this.model, this.textComposer, this.liveRank, this.handCall, this.boardProvider, this.whiteboardController, this.userGrantBoard = 0})
      : super(key: key);

  @override
  _RoomToolbarState createState() => _RoomToolbarState();
}

class _RoomToolbarState extends State<RoomToolbar> {
  List<Widget> colorsToolList;

  final crossFadeState = ValueNotifier(CrossFadeState.showSecond);
  List toolColors = [0xFFFC2700, 0xFFFED501, 0xFF1523E5, 0xFF95CD38];
  Toolbar paintBar = Toolbar(image: 'images/live/toolbar/paint.png', imageSelect: "images/live/toolbar/paint_select.png", type: 1);
  Toolbar handleBar = Toolbar(image: 'images/live/toolbar/handle.png', imageSelect: "images/live/toolbar/handle_select.png", type: 2);
  Toolbar rankingBar = Toolbar(image: 'images/live/toolbar/ranking.png', imageSelect: "images/live/toolbar/ranking_select.png", type: 3);
  Toolbar chatBar = Toolbar(image: 'images/live/toolbar/chat.png', imageSelect: "images/live/toolbar/chat_select.png", type: 4);
  _RoomToolbarState() {
    colorsToolList = getColorsTool();
  }
  @override
  Widget build(BuildContext context) {
    colorsToolList = getColorsTool();
    return Row(
      crossAxisAlignment: (widget.boardProvider.grantBoard == 1 && widget.model.selectState != 3 && widget.model.selectState != 4)
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: <Widget>[
        getToolWidget(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.boardProvider.grantBoard == 1 && widget.userGrantBoard == 1)
              getToolBarButton(
                toolbar: paintBar,
                isSelect: true,
                onTap: () {
                  widget.model.setSelectState(paintBar.type);
                  crossFadeState.value = crossFadeState.value == CrossFadeState.showFirst ? CrossFadeState.showSecond : CrossFadeState.showFirst;
                },
              ),
            Consumer3<HandProvider, CourseProvider, HandTypeProvider>(builder: (context, handProvider, courseProvider, handTypeProvider, child) {
              if (courseProvider.status == 1 && !handProvider.enableHand && handTypeProvider.type != 1) {
                Future.microtask(() => handTypeProvider.switchType(1));
              }
              if (courseProvider.status == 0 && handProvider.enableHand) {
                Future.microtask(() => handProvider.setEnableHand(false));
              }
              return Offstage(
                offstage: !(handProvider.enableHand),
                child: getToolBarButton(
                  toolbar: handleBar,
                  isSelect: handTypeProvider.type != 1,
                  onTap: () => widget?.handCall?.call(),
                ),
              );
            }),
            getToolBarButton(
              toolbar: rankingBar,
              isSelect: widget.model.selectState == rankingBar.type,
              onTap: () => widget.model.setSelectState(rankingBar.type),
            ),
            getToolBarButton(
              toolbar: chatBar,
              isSelect: widget.model.selectState == chatBar.type,
              onTap: () => widget.model.setSelectState(chatBar.type),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(30),
            ),
          ],
        ),
      ],
    );
  }

  Widget getToolBarButton({Toolbar toolbar, bool isSelect = false, Function onTap}) {
    return Padding(
      padding: EdgeInsets.only(
        top: ScreenUtil.getInstance().getHeightPx(24),
        bottom: ScreenUtil.getInstance().getHeightPx(24),
        right: ScreenUtil.getInstance().getWidthPx(28),
        left: ScreenUtil.getInstance().getWidthPx(12),
      ),
      child: InkResponse(
        highlightColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: 70, maxHeight: 70),
          child: Image.asset(
            isSelect ? toolbar.imageSelect : toolbar.image,
            width: ScreenUtil.getInstance().getHeightPx(225),
            height: ScreenUtil.getInstance().getHeightPx(225),
          ),
        ),
        onTap: () {
          onTap?.call();
        },
      ),
    );
  }

  ///获取工具
  Widget getToolWidget() {
    if (widget.model.selectState == 3) {
      return toolContainer(
        child: widget.liveRank,
      );
    } else if (widget.model.selectState == 4) {
      return toolContainer(
        child: widget.textComposer,
      );
    } else if (widget.boardProvider.grantBoard == 1 && widget.userGrantBoard == 1) {
      return _buildGrantBoard();
    }
    return Container();
  }

  _buildGrantBoard() {
    return ValueListenableProvider<CrossFadeState>.value(
      value: crossFadeState,
      child: AnimatedCrossFade(
        duration: Duration(milliseconds: 400),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState: crossFadeState.value,
        firstChild: Container(
          decoration: BoxDecoration(
            border: new Border.all(color: Color(0xFF707070), width: 0.5),
            color: Color(0xFF797883),
            borderRadius: new BorderRadius.all(Radius.circular(20.0)),
          ),
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtil.getInstance().getHeightPx(24),
            horizontal: ScreenUtil.getInstance().getWidthPx(15),
          ),
          child: Row(
            children: [
              ...colorsToolList,
            ],
          ),
        ),
        secondChild: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              border: new Border.all(color: Color(0xFF707070), width: 0.5),
              color: Color(0xFF797883),
            ),
            padding: EdgeInsets.all(ScreenUtil.getInstance().getHeightPx(24)),
            child: InkResponse(
              onTap: () async {
                crossFadeState.value = crossFadeState.value == CrossFadeState.showFirst ? CrossFadeState.showSecond : CrossFadeState.showFirst;
                widget.model.setToolIndex(99);
              },
              child: widget.boardProvider.appliance == Appliance.pencil
                  ? _getColor(widget.boardProvider.pencilColor ?? Colors.black)
                  : _getImage("images/live/toolbar/icon_eraser.png"),
            ),
          ),
        ),
      ),
    );
  }

  Widget toolContainer({Widget child}) {
    return Container(
      decoration: BoxDecoration(
        border: new Border.all(color: Color(0xFF3A384E), width: 0.5),
        color: Color(0xFF3A384E),
        borderRadius: new BorderRadius.all(Radius.circular(4.0)),
      ),
      width: ScreenUtil.getInstance().getWidthPx(300),
      height: ScreenUtil.getInstance().getHeightPx(1292),
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil.getInstance().getHeightPx(29),
        horizontal: ScreenUtil.getInstance().getWidthPx(15),
      ),
      margin: EdgeInsets.symmetric(
        vertical: ScreenUtil.getInstance().getHeightPx(29),
      ),
      child: child,
    );
  }

  List<Widget> getColorsTool() {
    List<Widget> toolList = [];
    for (int i = 0; i < toolColors.length; i++) {
      var c = toolColors[i];
      toolList.add(
        InkResponse(
          onTap: () async {
            Color color = Color(c);
            List<int> rgbColor = [color.red, color.green, color.blue];
            print("rgbColor  $rgbColor");
            widget.model.setToolIndex(i);
            crossFadeState.value = crossFadeState.value == CrossFadeState.showFirst ? CrossFadeState.showSecond : CrossFadeState.showFirst;
            await widget.whiteboardController.setAppliance(Appliance.pencil);
            await widget.whiteboardController.setStrokeColor(rgbColor);
          },
          child: _getColor(
            Color(c),
          ),
        ),
      );
    }

    toolList.add(
      InkResponse(
        onTap: () {
          widget.model.setToolIndex(4);
          crossFadeState.value = crossFadeState.value == CrossFadeState.showFirst ? CrossFadeState.showSecond : CrossFadeState.showFirst;
          widget.whiteboardController.setAppliance(Appliance.eraser);
        },
        child: _getImage("images/live/toolbar/icon_eraser.png"),
      ),
    );
    return toolList;
  }

  _getColor(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: new BorderRadius.all(Radius.circular(50.0)),
      ),
      width: ScreenUtil.getInstance().getWidthPx(25),
      height: ScreenUtil.getInstance().getWidthPx(25),
      margin: EdgeInsets.all(
        ScreenUtil.getInstance().getHeightPx(15),
      ),
    );
  }

  _getImage(String image) {
    return Container(
      margin: EdgeInsets.all(
        ScreenUtil.getInstance().getHeightPx(15),
      ),
      child: Image.asset(
        image,
        width: ScreenUtil.getInstance().getWidthPx(25),
        height: ScreenUtil.getInstance().getWidthPx(25),
      ),
    );
  }
}
