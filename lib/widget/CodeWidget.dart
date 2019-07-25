import 'dart:async';
import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_des/flutter_des.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_start/common/config/config.dart';
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
  bool _canBtn = true;
  TextEditingController _controller = new TextEditingController();
  Widget _image;
  String _cookieCode;
  String _userSign;
  @override
  void initState() {
    super.initState();
    _getImgCode();
  }

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
              _image = null;
              _cookieCode = "";
              _userSign = "";
              _getImgCode();
              _is = true;
            });
          },
          child: SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(100),
              child: Container(
                child: _image ?? SpinKitWave(color: Colors.greenAccent, size: 25),
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

  Future _getImgCode() async {
    var data = await UserDao.getImgCode();
    if (ObjectUtil.isEmpty(data) || !data.result) {
      showToast("获取失败,请稍后重试");
      return;
    }
    setState(() {
      _cookieCode = data.data["cookieCode"];
      _userSign = data.data["userSign"];
      _image = Image.memory(Base64Decoder().convert(data.data["data"]));
    });
  }

  Future _checkCode() async {
    try{
      CommonUtils.showLoadingDialog(context, text: "");
      var codeDataJson = {"code": _controller.text, "cookieCode": _cookieCode, "userSign": _userSign};
      var validateCodeData = await UserDao.getValidateCode(widget.phone);
      if (ObjectUtil.isNotEmpty(validateCodeData) && !validateCodeData.result) {
        showToast(validateCodeData.data);
        Navigator.pop(context);
        return;
      }
      String key = validateCodeData.data["ext1"];
      String value = "$key${widget.phone}";
      String encrypt = await FlutterDes.encryptToHex(value, key, iv: Config.DES_IV);
      var data = await UserDao.sendMobileCodeWithValiCode(encrypt, key, jsonEncode(codeDataJson));
      Navigator.pop(context);
      if (data.result) {
        print("发送手机验证码");
        Navigator.pop(context, true);
      } else {
        if (ObjectUtil.isNotEmpty(data.data)) {
          showToast(data.data);
        }
      }
    }catch(e){
      Navigator.pop(context);
      print(e);
    }
  }
}
