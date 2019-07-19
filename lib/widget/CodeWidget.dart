import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_des/flutter_des.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:oktoast/oktoast.dart';

class CodeWidget extends StatefulWidget {
  const CodeWidget({
    Key key,
    @required this.phone,
  }) : super(key: key);
  final String phone;
  @override
  State<StatefulWidget> createState() {
    return _CodeWidgetState();
  }
}

class _CodeWidgetState extends State<CodeWidget> {
  _CodeWidgetState();
  String _imagesUrl = "http://www.k12china.com/k12-api/base/getValidateCode?t=${DateTime.now().millisecondsSinceEpoch}";
  bool _is = true;
  TextEditingController _controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Flex(direction: Axis.vertical, children: <Widget>[
        new Padding(
            padding: new EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(50)),
            child: new Text(
              "请先按图形输入正确字符",
              style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(18), color: const Color(0xFF666666)),
            )),
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(30),
        ),
        GestureDetector(
          onTap: () {
            if (!_is) {
              return;
            }
            _is = false;
            setState(() {
              _imagesUrl = "http://www.k12china.com/k12-api/base/getValidateCode?t=${DateTime.now().millisecondsSinceEpoch}";
              _is = true;
            });
          },
          child: SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(100),
              child: Container(
                child: CachedNetworkImage(
                  imageUrl: _imagesUrl,
                  placeholder: (context, url) => SpinKitWave(color: Colors.greenAccent, size: 25),
                ),
              )),
        ),
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(10),
        ),
        Container(
          child: Text(
            "看不清？点击图标",
            style: TextStyle(color: const Color(0xFF999999), fontSize: ScreenUtil.getInstance().getSp(36 / 3)),
          ),
        ),
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(30),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: ScreenUtil.getInstance().getHeightPx(70), maxWidth: ScreenUtil.getInstance().getWidthPx(350)),
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
          ),
        ),
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(140),
        ),
        CommonUtils.buildBtn("确定", height: ScreenUtil.getInstance().getHeightPx(135), width: ScreenUtil.getInstance().getWidthPx(515), onTap: () {
          if (_controller.text.length != 4) {
            showToast("请您输入正确字符", position: ToastPosition.top);
            return;
          }
          _checkCode();
        }),
      ]),
    );
  }

  Future _checkCode() async {
//    var data = await UserDao.getImgCode();
    var data = await UserDao.getValidateCode();
    if (ObjectUtil.isNotEmpty(data) && !data.result) {
      showToast(data.data);
      return;
    }
    String key = data["ext1"];
    String value = "$key${widget.phone}";
    var encrypt = await FlutterDes.encrypt(key, value);
//    var data = await UserDao.sendMobileCode(widget.phone);
    if (data.result) {
      print("发送手机验证码");
      Navigator.pop(context);
    } else {
      showToast(data.data);
    }
  }

  Future<Uint8List> consolidateHttpClientResponseBytes(HttpClientResponse response) {
    // response.contentLength is not trustworthy when GZIP is involved
    // or other cases where an intermediate transformer has been applied
    // to the stream.
    final Completer<Uint8List> completer = Completer<Uint8List>.sync();
    final List<List<int>> chunks = <List<int>>[];
    int contentLength = 0;
    response.listen((List<int> chunk) {
      chunks.add(chunk);
      contentLength += chunk.length;
    }, onDone: () {
      final Uint8List bytes = Uint8List(contentLength);
      int offset = 0;
      for (List<int> chunk in chunks) {
        bytes.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      completer.complete(bytes);
    }, onError: completer.completeError, cancelOnError: true);

    return completer.future;
  }
}
