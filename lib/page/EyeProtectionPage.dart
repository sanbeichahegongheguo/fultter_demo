import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/widget/ShareToWeChat.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'WebViewPage.dart';

class EyeProtectionPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EyeProtectionPage();
  }

}

class _EyeProtectionPage extends State<EyeProtectionPage> {
  List<String> timeList = ["30分钟", "60分钟", "90分钟"];
  String _timeName = "";

  @override
  initState() {
    super.initState();
    _getEyeshiieldTime();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StoreBuilder<GSYState>(builder: (context, store) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("护眼设置"),
          backgroundColor: Color(0xFFffffff),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0xFF333333),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: new Container(
            decoration: BoxDecoration(
              color: Color(0xFFf0f4f7),
            ),
            child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil.getInstance().getWidthPx(950),
                      margin: EdgeInsets.all(
                          ScreenUtil.getInstance().getHeightPx(40)),
                      child: Column(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(
                              ScreenUtil.getInstance().getWidthPx(56)),
                          child: RichText(
                              text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "该栏目设置的时间，会同时在“远大小状元学生”和“远大小状元家长”app生效。为了孩子的用眼健康着想,我们建议每天连续在线学习时间不要超过"),
                                    TextSpan(text: "1小时",
                                        style: TextStyle(
                                            color: Color(0xFFff9494))),
                                    TextSpan(text: "。"),
                                  ],
                                  style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().getSp(
                                          48 / 3),
                                      color: Color(0xFF959595)
                                  )
                              )
                          ),
                        ),
                        Column(
                          children: _getTimeListWidget(),
                        ),
                        Padding(
                          padding: EdgeInsets.all(
                              ScreenUtil.getInstance().getWidthPx(56)),
                          child: RichText(
                              text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "温馨提示：如果学生当天学习超时，需要输入家长密码方可继续学习。"),
                                  ],
                                  style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().getSp(
                                          42 / 3),
                                      color: Color(0xFFff9494)
                                  )
                              )
                          ),
                        ),
                      ],),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.all(
                            Radius.circular((10.0))),
                      ),
                    ),
                  ],
                )
            )
        ),
//        bottomNavigationBar: new Container(
//          width: ScreenUtil.getInstance().getWidthPx(963),
//          height: ScreenUtil.getInstance().getHeightPx(216),
//          color: Color(0xFFffffff),
//          child: Align(
//              child: MaterialButton(
//                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                    onPressed: _goParentInfo,
//                    minWidth: ScreenUtil.getInstance().getWidthPx(983),
//                    height: ScreenUtil.getInstance().getHeightPx(150),
//                    color: Color(0xFFfc6061),
//                    child: Text("打开“远大小状元学生”", style: TextStyle(
//                        fontSize: ScreenUtil.getInstance().getSp(54 / 3),
//                        color: Colors.white),),
//                  ),
//          ),
//        ),
      );
    });
  }

  void _getEyeshiieldTime() async {
    var res = await UserDao.getEyeshiieldTime();
    if (res != null && res != "") {
      if (res["success"]) {
        setState(() {
          _timeName = res["data"] + "分钟";
        });
      }
    }
  }

  //设置按钮
  _getTimeListWidget() {
    List<Widget> listWiget = [];
    for (var i = 0; i < timeList.length; i++) {
      var widgetList = Padding(
          padding: EdgeInsets.all(ScreenUtil.getInstance().getHeightPx(15),),
          child:MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              onPressed: _timeName != timeList[i] ? () async {
                await UserDao.saveEyeshiieldTime(i + 1);
                ApplicationDao.trafficStatistic(317);
                setState(() {
                  _timeName = timeList[i];
                });
              } : null,
              minWidth: ScreenUtil.getInstance().getWidthPx(521),
              height: ScreenUtil.getInstance().getHeightPx(133),
              color: Color(0xFFeeeeee),
              disabledColor: Color(0xFFfbd953),
              child: Text(timeList[i], style: TextStyle(
                  fontSize: ScreenUtil.getInstance().getSp(54 / 3),
                  color: _timeName == timeList[i] ? Color(0xFFa83530) : Color(
                      0xFF999999)),),
            ),
      );
      listWiget.add(widgetList);
    }
    return listWiget;
  }

  _goParentInfo() {
    NavigatorUtil.goWebView(context,AddressUtil.getInstance().getInfoPage(),router:"parentInfo");
  }
}
