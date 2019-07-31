import 'dart:async';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/widget/CodeWidget.dart';
class CountDown extends StatefulWidget {
  final callBack;
  final dataTwo;
  final recoverTime;
  final where;
  CountDown({Key key, this.dataTwo, this.callBack, this.recoverTime, this.where}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CountDownState();
  }
}

class CountDownState extends State<CountDown> with SingleTickerProviderStateMixin{
  Timer _countdownTimer;
  String _codeCountdownStr = '';
  int _countdownNum = 59;
  String data = '';
  bool _recoverTime= true;
  String where = '';
  @override
  void initState() {
    this.data = widget.dataTwo;
    this._recoverTime = widget.recoverTime;
    this.where = widget.where;
    print(this.data);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(this._recoverTime){
      _reGetCountdown();
    }else{
      setState(() {
        _codeCountdownStr = '重新获取验证码';
      });
    }
    return Container(
      child: GestureDetector(
        child: this.where =='rePwd'?Text(_codeCountdownStr,
          style: TextStyle(color: Color(0xFF6ed699), fontSize: ScreenUtil.getInstance().getSp(48 / 3))
        ):Text(_codeCountdownStr,
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
        _countdownNum = 59;
        _countdownTimer = null;
        setState(() {
          this._recoverTime = true;
        });
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
