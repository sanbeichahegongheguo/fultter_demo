import 'dart:async';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/widget/CodeWidget.dart';
class CountDown extends StatefulWidget {
  final callBack;
  final dataTwo;
  CountDown({Key key, this.dataTwo, this.callBack}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CountDownState();
  }
}

class CountDownState extends State<CountDown> with SingleTickerProviderStateMixin{
  Timer _countdownTimer;
  String _codeCountdownStr = '重新获取验证码';
  int _countdownNum = 60;
  String data = '';
  @override
  void initState() {
    this.data = widget.dataTwo;
    print(this.data);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _reGetCountdown();
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(69)),
      child: GestureDetector(
        child: Text(_codeCountdownStr,
          style: TextStyle(color: Color(0xFF89898a), fontSize: ScreenUtil.getInstance().getSp(16))
        ),
        onTap:(){
          setState(() {
            _getCode();
          });
        }
      )
    );
  }
  void _getCode() async{
    if(_codeCountdownStr == '重新获取验证码'){
      var isSend = await CommonUtils.showEditDialog(
      context,
      CodeWidget(phone: data),
      );
      print(isSend);
      if (null != isSend && isSend) {
        _countdownNum = 60;
        _countdownTimer = null;
        _reGetCountdown();
      }
    }
  }
  void _reGetCountdown() {
    Future.delayed(Duration(milliseconds: 200)).then((e) {
      if(!mounted){
        return;
      }
      setState(() {
        if (_countdownTimer != null) {
          return;
        }
        // Timer的第一秒倒计时是有一点延迟的，为了立刻显示效果可以添加下一行。
        _codeCountdownStr = '${_countdownNum--}s后重新发送';
        _countdownTimer =
        new Timer.periodic(new Duration(seconds: 1), (timer) {
          setState(() {
            if (_countdownNum > 0) {
              _codeCountdownStr = '${_countdownNum--}s后重新发送';
            } else {
              _codeCountdownStr = '重新获取验证码';
              _countdownTimer.cancel();
            }
          });
        });
      });
    });
  }
  void dispose() {
    _countdownTimer.cancel();
    _countdownTimer = null;
    super.dispose();
  }
}
