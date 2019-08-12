
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:oktoast/oktoast.dart';

import 'CodeWidget.dart';

class IndexNoticeWidget extends StatefulWidget {
  final data;
  final message;
  IndexNoticeWidget({Key key, this.data,this.message}):super(key: key);

  State<StatefulWidget> createState() {
    return _IndexNoticeWidgetState();
  }

}

class _IndexNoticeWidgetState extends State<IndexNoticeWidget> {
  Widget build(BuildContext context){
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: (){
                print("点击公告");
                print(widget.data["clictUrl"]);
                if(widget.data["clictUrl"]!=null){
                  NavigatorUtil.goWebView(context,widget.data["clictUrl"]);
                }else if(widget.data["clictUrl"]==null&&widget.message=='派发奖励成功'){
                  showToast("领取奖励成功！",position: ToastPosition.center);
                }
                Navigator.pop(context);
              },
              child: CachedNetworkImage(
                imageUrl: widget.data["picUrl"].toString().replaceAll("fs.k12china-local.com", "192.168.6.30:30781"),
                width: MediaQuery.of(context).size.width*0.8,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                child: IconButton(
                  icon: Image.asset("images/btn-close.png",fit: BoxFit.cover,width: ScreenUtil.getInstance().getWidthPx(100),),
                  color: Colors.transparent,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ],
      ),
    );
  }
}