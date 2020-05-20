
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/widget/CodeWidget.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:async';

class DelGuardPassword extends StatefulWidget{
  @override
  State<DelGuardPassword> createState() {
    return _DelGuardPassword();
  }
}
class _DelGuardPassword extends State<DelGuardPassword>{
  TextEditingController phoneController = new TextEditingController();
  TextEditingController cordController = new TextEditingController();
  GlobalKey _globalKey = new GlobalKey();
  bool _hasdeleteIcon = false;
  bool _isCord = false;///判断是否点击发送验证码
  bool _isCordSendOk = false;///判断验证码是否正确
  bool _isBt = false;///确定按钮是否点击
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
          _isCord = false;
        });
      }else if(firstMatch == null && phoneController.text.length == 11){
        setState(() {
          print("请输入正确的手机号");
          showToast("请输入正确的手机号");
          _isCord = false;
        });
      }else if(firstMatch != null && phoneController.text.length == 11 && _countdownNum == 61){
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
    cordController.addListener(() async{
      if(cordController.text.length == 6 && _isCordSendOk){

        setState(() {
          print("确定");
          _isBt = true;
        });
      }
    });
  }

  _checkCode() async{
    var res =  await UserDao.mobileCheckCode(phoneController.text, cordController.text);
    print("清除面膜====>${res}");
    var ok = res["success"]["ok"];
    if (ok == '0' || ok == 0) {
      return true;
    }else if (ok == '206' || ok == 206) {
      showToast("验证码错误，验证失败！");
      return false;
    } else {
      showToast("验证码错误，验证失败！");
      return false;
    }
  }

  Widget build(BuildContext context){
    return StoreBuilder<GSYState>(builder: (context, store){
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("清除监护密码",style:TextStyle(color: Color(0XFFffffff))),
          backgroundColor: Color(0xFF60c589),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0XFFffffff),
            onPressed: () {
              Navigator.pop(context,"12");
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
                child:MaterialButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  minWidth: ScreenUtil.getInstance().getWidthPx(521),
                  onPressed:_isBt?(){_resetMobile(store);}:null,
                  height:ScreenUtil.getInstance().getHeightPx(133),
                  color:Color(0xFF60c589),
                  disabledColor:Colors.black26,
                  child:Text("确认修改",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color:_isBt? Colors.white: Colors.white70,),
                  ),
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
    var ischeckCode = await  _checkCode();
    if(!ischeckCode){
      return;
    }else{
      var res =  await UserDao.delCheckPassword();
      setState(() {
        if (res["success"]["ok"] == 0) {
          showToast("清除成功");
          Navigator.pop(context);
          _countdownTimer.cancel();
          UserDao.getUser(isNew: true, store: store);
        } else {
          showToast("清除失败");
        }
      });
    }
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
            _countdownNum = 61;
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
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black,textBaseline:TextBaseline.alphabetic),
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
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black,textBaseline:TextBaseline.alphabetic),
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
      decoration: new InputDecoration(
        suffixIcon:
        RaisedButton(
          color: Color(0xFFffbf40),
          splashColor:Color(0xFFeeab25),
          child: Text(timeMsg),
          textColor: Color(0xFF333333),
          disabledTextColor:Color(0xFFffffff),
          onPressed: _isCord?() async{
            print("发送验证码");
            var isSend = await CommonUtils.showEditDialog(
              context,
              CodeWidget(phone:phoneController.text),
            );
            if (null != isSend && isSend) {
              print("成功");
              CommonUtils.showLoadingDialog(context, text: "发送中···");
              Navigator.pop(context);
              setState(() {
                _countdownNum = 60;
                _reGetCountdown();
                _isCordSendOk = true;
              });
            }else{
              showToast("验证码验证有误，请重新发送");
            }
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
