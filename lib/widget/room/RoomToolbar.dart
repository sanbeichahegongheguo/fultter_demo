import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:provider/provider.dart';

///房间工具栏
///画笔 举手 排行榜 聊天
///
class RoomToolbar extends StatefulWidget {
  @override
  RoomToolbarProvider model;

  Widget textComposer;

  Widget liveRank;

  RoomToolbar({Key key, this.model,this.textComposer,this.liveRank}) : super(key: key);

  _RoomToolbarState createState() => _RoomToolbarState();
}

class _RoomToolbarState extends State<RoomToolbar> {
  ///获取工具按钮
  List<Widget> getToolBarButtons() {
    List<Widget> widgetList = [];
    widget.model.toolbarDatas.forEach((e) {
      widgetList.add(Padding(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil.getInstance().getHeightPx(24),
          horizontal: ScreenUtil.getInstance().getWidthPx(28),
        ),
        child: InkResponse(
          highlightColor: Colors.transparent,
          child: Image.asset(
            e["type"] != widget.model.selectState
                ? e["image"]
                : e["imageSelect"],
            width: ScreenUtil.getInstance().getHeightPx(225),
            height: ScreenUtil.getInstance().getHeightPx(225),
          ),
          onTap: () {
            widget.model.setSelectState(e["type"]);
          },
        ),
      ));
    });
    return widgetList;
  }

  ///获取工具
  Widget getToolWidget() {
    switch (widget.model.selectState) {
      case 1:
        return Container(
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
              ...getColorsTool(),
            ],
          ),
        );
      case 2:
        return Container();
      case 3:
        return toolContainer(
          child: widget.liveRank,
        );
      case 4:
        return toolContainer(
          child: widget.textComposer,
        );
    }
    return Container();
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
    List<Widget> widgetList = [];
    widget.model.toolColors.forEach((element) {
      widgetList.add(
        Container(
          decoration: BoxDecoration(
            color: Color(element),
            borderRadius: new BorderRadius.all(Radius.circular(50.0)),
          ),
          width: ScreenUtil.getInstance().getWidthPx(25),
          height: ScreenUtil.getInstance().getWidthPx(25),
          margin: EdgeInsets.symmetric(
            horizontal: ScreenUtil.getInstance().getHeightPx(15),
          ),
        ),
      );
    });
    widgetList.add(
      Container(
        margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil.getInstance().getHeightPx(15),
        ),
        child: Image.asset(
          "images/live/toolbar/icon_eraser.png",
          width: ScreenUtil.getInstance().getWidthPx(25),
          height: ScreenUtil.getInstance().getWidthPx(25),
        ),
      ),
    );
    return widgetList;
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:widget.model.selectState == 1 ? CrossAxisAlignment.start: CrossAxisAlignment.end,
      children: <Widget>[
        getToolWidget(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ...getToolBarButtons(),
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(30),
            ),
          ],
        ),
      ],
    );
  }
}
