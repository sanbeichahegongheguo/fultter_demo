import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:oktoast/oktoast.dart';


class ResetPasswordPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StatefulWidget();
  }
}
class _StatefulWidget  extends State<ResetPasswordPage>{
  TextEditingController _ordPasswordController = new TextEditingController();
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _confirmPasswordController = new TextEditingController();
  bool _isOrd = false;
  bool _isNew = false;
  bool _isConfirm = false;
  String _ordText = " ";
  String _newText = " ";
  String _confirmText = " ";
  @override
  void initState() {
    super.initState();
    _ordPasswordController.addListener((){
      if(_ordPasswordController.text.length>0){
        setState(() {
          _isOrd = true;
        });
      }else{
        setState(() {
          _isOrd = false;
        });
      }

    });
    _newPasswordController.addListener((){
      RegExp mobile = new RegExp(r"^(?=.*\d)(?=.*[a-z])[a-zA-Z\d]{6,20}$");
      var firstMatch = mobile.firstMatch(_newPasswordController.text);
      if(firstMatch != null){
        setState(() {
        _isNew = true;
        _newText = " ";
        });
      }else if(firstMatch == null && _newPasswordController.text.length > 6){
        setState(() {
          _isNew = false;
          _newText = "密码只能为数字加字母，长度在6-20之间";
        });
      } else{
        setState(() {
          _isNew = false;
        });
      }
    });
    _confirmPasswordController.addListener((){
      print("_newPasswordController.text===>${_newPasswordController.text}");
      print("_ordPasswordController.text===>${_ordPasswordController.text}");
      print("_isOrd.text===>${_isOrd}");
      print("_isNew.text===>${_isNew}");
      if(_newPasswordController.text == _confirmPasswordController.text && _isOrd && _isNew){
        setState(() {
        _isConfirm = true;
        _confirmText = " ";
        });
      }else if(_confirmPasswordController.text.length > 6 && _isOrd && _isNew && _newPasswordController.text != _confirmPasswordController.text){
        setState(() {
          _isConfirm = false;
          _confirmText = "两次输入的密码不一致";
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StoreBuilder<GSYState>(builder: (context, store){
      return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text("更改密码"),
            backgroundColor: Color(0xFFffffff),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios), //自定义图标
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFf0f4f7),
          ),
          child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(70),top:ScreenUtil.getInstance().getHeightPx(80) , right: ScreenUtil.getInstance().getWidthPx(70)),
                  child: _getTextField("旧密码",_ordPasswordController),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(80),top:ScreenUtil.getInstance().getHeightPx(20) , right: ScreenUtil.getInstance().getWidthPx(70)),
                  child:Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_ordText,style: TextStyle(color: Color(0xFFA94442)),),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(70),top:ScreenUtil.getInstance().getHeightPx(20) , right: ScreenUtil.getInstance().getWidthPx(70)),
                  child: _getTextField("新密码(请输入6-20位数字加字母的密码)",_newPasswordController),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(80),top:ScreenUtil.getInstance().getHeightPx(20) , right: ScreenUtil.getInstance().getWidthPx(70)),
                  child:Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_newText,style: TextStyle(color: Color(0xFFA94442)),),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(70),top:ScreenUtil.getInstance().getHeightPx(20) , right: ScreenUtil.getInstance().getWidthPx(70)),
                  child:_getTextField("确认密码",_confirmPasswordController)
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(80),top:ScreenUtil.getInstance().getHeightPx(20) , right: ScreenUtil.getInstance().getWidthPx(70),bottom:ScreenUtil.getInstance().getHeightPx(80) ),
                  child:Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_confirmText,style: TextStyle(color: Color(0xFFA94442)),),
                  ),
                ),
                MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    onPressed:_isConfirm?_resetPassword:null,
                    minWidth: ScreenUtil.getInstance().getWidthPx(521),
                    height:ScreenUtil.getInstance().getHeightPx(133),
                    color:Color(0xFFfbd953),
                    disabledColor:Colors.black26,
                    child:Text("更改密码",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color:_isConfirm?Color(0xFFa83530): Colors.white70,),
                  ),
                ),
              ],
          ),
        ),
      );
    });
  }
  //更改密码
  _resetPassword() async{
    var res =  await UserDao.resetPassword(_ordPasswordController.text,_newPasswordController.text);
    print("res.result === ${res.result}");
    if(null!=res && res.result){
      showToast("更改成功");
      Navigator.pop(context);
    }else{
      showToast(res.data);
    }
  }
  TextFormField _getTextField(String hintText, TextEditingController controller, { GlobalKey key}) {
    return TextFormField(
      key: key,
      keyboardType: TextInputType.text,
      obscureText: true,
      controller: controller,
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black),
      inputFormatters: [LengthLimitingTextInputFormatter(20)],
      decoration: new InputDecoration(
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