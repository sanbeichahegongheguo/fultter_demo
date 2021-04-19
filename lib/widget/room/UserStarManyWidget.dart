import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/dao/RoomDao.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

class UserStarManyWidget extends StatefulWidget {
  final int star;

  const UserStarManyWidget({Key key, this.star = 0}) : super(key: key);
  @override
  _UserStarManyWidgetState createState() => _UserStarManyWidgetState();
}

class _UserStarManyWidgetState extends State<UserStarManyWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Opacity(
            opacity: 0.79,
            child: new Chip(
              backgroundColor: Color(0xFF000000),
              avatar: Opacity(
                opacity: 1,
                child: Image.asset(
                  "images/live/chat/icon_star.png",
                  width: ScreenUtil.getInstance().getWidth(10),
                ),
              ),
              label: Text(
                "${widget.star}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.getInstance().getSp(36) / 4,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
