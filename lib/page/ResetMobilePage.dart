import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:async';

class ResetMobilePage extends StatefulWidget{
  @override
  State<ResetMobilePage> createState() {
    return _ResetMobilePage();
  }
}
class _ResetMobilePage extends State<ResetMobilePage>{
  TextEditingController phoneController = new TextEditingController();
  TextEditingController cordController = new TextEditingController();
  GlobalKey _globalKey = new GlobalKey();
  bool _hasdeleteIcon = false;
  bool _isCord = false;
  bool _isCordSendOk = false;
  bool _isBt = false;
  Timer _countdownTimer;
  @override
  void initState() {
    super.initState();
    phoneController.addListener((){
      RegExp mobile = new RegExp(r"(0|86|17951)?(13[0-9]|15[0-35-9]|17[0678]|18[0-9]|14[57])[0-9]{8}");
      var firstMatch = mobile.firstMatch(phoneController.text);
      if (phoneController.text == "") {
        setState(() {
          _hasdeleteIcon = false;
        });
      }else if(firstMatch == null && phoneController.text.length == 11){
        setState(() {
          print("请输入正确的手机号");
          showToast("请输入正确的手机号");
        });
      }else if(firstMatch != null && phoneController.text.length == 11){
        setState(() {
          print("正确的手机号");
          _isCord = true;
        });
      }else{
        setState(() {
          _hasdeleteIcon = true;
        });
      }
    });
    cordController.addListener((){
      if(cordController.text.length == 6 && _isCordSendOk){
        setState(() {
          print("确定");
          _isBt = true;
        });
      }
    });
  }
  Widget build(BuildContext context){
    return StoreBuilder<GSYState>(builder: (context, store){
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("更改手机号"),
          backgroundColor: Color(0xFFffffff),
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_left), //自定义图标
            onPressed: () {
              _countdownNum != 61? _countdownTimer.cancel():print("==");
              Navigator.pop(context);
            },
          ),
        ),
        body:Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: ScreenUtil.getInstance().getHeightPx(54),
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(50), right: ScreenUtil.getInstance().getWidthPx(50)),
                child: _getTextField("请输入手机号", phoneController, key: _globalKey),
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(50), right: ScreenUtil.getInstance().getWidthPx(50), top: ScreenUtil.getInstance().getHeightPx(60)),
                child: _getTextCodeField("请输入验证码", cordController),
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(50), right: ScreenUtil.getInstance().getWidthPx(50), top: ScreenUtil.getInstance().getHeightPx(60)),
                child:CommonUtils.buildBtn(
                  "确定更改",
                  width:ScreenUtil.getInstance().getWidthPx(638),
                  height:ScreenUtil.getInstance().getHeightPx(114),
                  onTap:_isBt?(){_resetMobile(store);}:null,
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            color: Color(0xFFf0f4f7),
          ),
        ),
      );
    });
  }
  //更改手机号
  _resetMobile(store) async{
    print("store===>${store.state.userInfo.mobile}");
    var res =  await UserDao.resetMobile(store.state.userInfo.mobile, phoneController.text, cordController.text);
    setState(() {
      if (res.result) {
        showToast("更改成功");
        Navigator.pop(context);
        _countdownTimer.cancel();
        UserDao.getUser(isNew: true, store: store);
      } else {
        showToast(res.data);
      }
    });
  }
  int _countdownNum = 61;

  String timeMsg = "发送验证码";
  //倒计时
  void _reGetCountdown() {

    setState(() {
      _countdownTimer =  new Timer.periodic(new Duration(seconds: 1), (timer) {
        setState(() {
          _countdownNum--;
          if (_countdownNum > 0) {
            setState((){
              timeMsg = "发送验证码($_countdownNum)";
              _isCord = false;
            });
          } else {
            _countdownTimer.cancel();
            timeMsg = "重新发送";
            _isCord = true;
          }
        });
      });
    });
  }

  TextFormField _getTextField(String hintText, TextEditingController controller, {bool obscureText, GlobalKey key}) {
    return TextFormField(
      key: key,
      keyboardType: TextInputType.phone,
      obscureText: obscureText ?? false,
      controller: controller,
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black),
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
      decoration: new InputDecoration(
        suffixIcon: _hasdeleteIcon
            ? IconButton(
          onPressed: () {
            setState(() {
              phoneController.text = "";
              _hasdeleteIcon = false;
              _isCord = false;
              cordController.text = "";
              _isBt = false;
            });
          },
          icon: Icon(
            Icons.cancel,
            color: Color(0xFFcccccc),
          ),
        ): Text(""),
        contentPadding: EdgeInsets.all(13),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: ScreenUtil.getInstance().getSp(16)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Color(0xffffffff),
      ),
    );
  }
  TextFormField _getTextCodeField(String hintText, TextEditingController controller, {bool obscureText, GlobalKey key}) {
    return TextFormField(
      key: key,
      keyboardType: TextInputType.phone,
      obscureText: obscureText ?? false,
      controller: controller,
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black),
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
      decoration: new InputDecoration(
        suffixIcon:
        RaisedButton(
          child: Text(timeMsg),
          onPressed: _isCord?() async{
            print("发送验证码");
            _reGetCountdown();
            CommonUtils.showLoadingDialog(context, text: "发送中···");
            var res = await UserDao.sendMobileCode(phoneController.text);
            Navigator.pop(context);
            setState(() {
              if(res.result){
                _countdownNum = 60;
                _isCordSendOk = true;
                showToast("发送成功");
              }else{
                showToast("发送失败，请联系客服！");
              }
            });
          }:null,
        ),
        contentPadding: EdgeInsets.all(13),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: ScreenUtil.getInstance().getSp(16)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Color(0xffffffff),
      ),
    );
  }
}
