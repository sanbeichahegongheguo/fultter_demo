import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/dao/RoomDao.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

class UserStarWidget extends StatefulWidget {
  @override
  _UserStarWidgetState createState() => _UserStarWidgetState();
}

class _UserStarWidgetState extends State<UserStarWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserStar();
    });
  }

  getUserStar() {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final starWidgetProvider = Provider.of<StarWidgetProvider>(context, listen: false);
    var param = {"liveCourseallotId": courseProvider.roomData.liveCourseallotId, "roomId": courseProvider.roomData.room.roomUuid};
    print("getuserstar param $param");
    RoomDao.getUserStar(param).then((res) {
      if (res.result != null && res.data != null && res.data["code"] == 200) {
        print(res.data["code"]);
        final star = res.data["data"]["star"];
        if (star != null) {
          starWidgetProvider.setStar(star);
        }
      } else {
        showToast("获取星星失败!!!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StarWidgetProvider>(builder: (context, model, child) {
      return Positioned(
        top: 3,
        left: 5,
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
                      width: ScreenUtil.getInstance().getWidth(10),
                    ),
                  ),
                  label: Text(
                    "${model.star}",
                    style: TextStyle(
                      color: Color(0xFFff8400).withOpacity(1),
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.getInstance().getSp(36) / 4,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
    ;
  }
}
