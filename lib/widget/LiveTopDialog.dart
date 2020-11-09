import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:fsuper/fsuper.dart';

class LiveTopDialog extends StatefulWidget {
  final List<dynamic> data;

  const LiveTopDialog({Key key, this.data}) : super(key: key);
  @override
  _LiveTopDialogState createState() => _LiveTopDialogState();
}

class _LiveTopDialogState extends State<LiveTopDialog> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  var isBack = 0;
  Timer _timer;
  Duration _timeoutSeconds = const Duration(seconds: 3);
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    _timer = Timer(_timeoutSeconds, () => back);
    final screenSize = MediaQuery.of(context).size;
    var _maxContentHeight = screenSize.height * 0.8;
    return ScaleTransition(
        scale: _controller,
        child: FSuper(
          height: screenSize.height,
          width: screenSize.width * 0.8,
          onClick: back,
          onChild1Click: () => {},
          child1: FSuper(
            corner: FCorner.all(15),
            backgroundColor: Colors.white,
            height: ScreenUtil.getInstance().getHeightPx(950),
            width: ScreenUtil.getInstance().getWidthPx(380),
            child1Alignment: Alignment.topCenter,
            child1Margin: EdgeInsets.only(top: -ScreenUtil.getInstance().getHeightPx(300)),
            child1: Image.asset(
              "images/live/top/icon.png",
              width: ScreenUtil.getInstance().getWidthPx(350),
              height: ScreenUtil.getInstance().getHeightPx(535),
            ),
            child2Alignment: Alignment.topCenter,
            child2Margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(150)),
            child2: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeight(25)),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              alignment: Alignment(0.0, 0.88),
                              children: <Widget>[
                                Image.asset("images/live/top/NO2Icon.png", width: ScreenUtil.getInstance().getWidthPx(80)),
                                widget.data.length > 1
                                    ? ClipOval(
                                        child: getHeaderImg(widget.data[1]["headerImg"]),
                                      )
                                    : ClipOval(child: getHeaderImg(null))
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.getInstance().getHeightPx(10),
                            ),
                            Text(widget.data.length > 1 ? "2.${widget.data[1]["name"]}" : "",
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().getSp(6),
                                    color: Colors.grey,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal))
                          ],
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil.getInstance().getWidthPx(40),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeight(15)),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              alignment: Alignment(0.0, 0.88),
                              children: <Widget>[
                                Image.asset("images/live/top/NO1Icon.png", width: ScreenUtil.getInstance().getWidthPx(80)),
                                widget.data.length > 0
                                    ? ClipOval(
                                        child: getHeaderImg(widget.data[0]["headerImg"]),
                                      )
                                    : ClipOval(child: getHeaderImg(null))
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.getInstance().getHeightPx(10),
                            ),
                            Text(widget.data.length > 0 ? "1.${widget.data[0]["name"]}" : "",
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().getSp(6),
                                    color: Colors.deepOrangeAccent,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal))
                          ],
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil.getInstance().getWidthPx(40),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeight(25)),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              alignment: Alignment(0.0, 0.88),
                              children: <Widget>[
                                Image.asset("images/live/top/NO3Icon.png", width: ScreenUtil.getInstance().getWidthPx(80)),
                                widget.data.length > 2
                                    ? ClipOval(
                                        child: getHeaderImg(widget.data[2]["headerImg"]),
                                      )
                                    : ClipOval(child: getHeaderImg(null))
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.getInstance().getHeightPx(10),
                            ),
                            Text(widget.data.length > 2 ? "3.${widget.data[2]["name"]}" : "",
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().getSp(6),
                                    color: Colors.grey,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal))
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().getHeightPx(45),
                  ),
                  Text("恭喜以上同学最快回答问题！",
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().getSp(6), color: Colors.grey, decoration: TextDecoration.none, fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
          child2: Image.asset(
            "images/live/top/closeBtn.png",
            width: ScreenUtil.getInstance().getWidthPx(65),
            height: ScreenUtil.getInstance().getWidthPx(65),
          ),
          onChild2Click: back,
          child2Alignment: Alignment.bottomCenter,
          child2Margin: EdgeInsets.only(bottom: ScreenUtil.getInstance().getHeightPx(150)),
        ));
  }

  getHeaderImg(imgUrl) {
    if (imgUrl != null && imgUrl != "") {
      return CachedNetworkImage(
        imageUrl: imgUrl.toString().replaceAll("fs.k12china-local.com", "192.168.6.30:30781"),
        fit: BoxFit.cover,
        width: ScreenUtil.getInstance().getWidthPx(75),
        height: ScreenUtil.getInstance().getWidthPx(75),
        errorWidget: (BuildContext context, String url, dynamic error) {
          return Image(
            image: AssetImage("images/admin/tx.png"),
            fit: BoxFit.cover,
            width: ScreenUtil.getInstance().getWidthPx(75),
            height: ScreenUtil.getInstance().getWidthPx(75),
          );
        },
      );
    } else {
      return Image(
        image: AssetImage("images/admin/tx.png"),
        fit: BoxFit.cover,
        width: ScreenUtil.getInstance().getWidthPx(75),
        height: ScreenUtil.getInstance().getWidthPx(75),
      );
    }
  }

  back() {
    if (isBack == 0) {
      isBack = 1;
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    print("LiveTopDialog dispose");
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
