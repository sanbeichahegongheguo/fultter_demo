import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:oktoast/oktoast.dart';


class ChangeGuardPassword extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChangeGuardPassword();
  }
}
class _ChangeGuardPassword  extends State<ChangeGuardPassword>{
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
    _ordPasswordController.addListener(() async{
      if(_ordPasswordController.text.length==4){
        var ischeck = await checkPassword();
        setState(() {
          if(ischeck){
            _isOrd = true;
            _ordText = "";
          }else{
            _isOrd = false;
            _ordText = "请输入正确的密码";
          }
        });
      }else{
        setState(() {
          _isOrd = false;
          _ordText = "密码只能为数字，长度为4";
        });
      }
      print("_isOrd===>${_isOrd}");

    });
    _newPasswordController.addListener((){
      RegExp mobile = new RegExp(r"^[0-9]*$");
      var firstMatch = mobile.firstMatch(_newPasswordController.text);
      print("firstMatch===${firstMatch} ${_newPasswordController.text}");
      if(firstMatch != null  && _newPasswordController.text.length == 4){
        setState(() {
          _isNew = true;
          _newText = " ";
        });
      }else if(firstMatch == null && _newPasswordController.text.length != 4){
        setState(() {
          _isNew = false;
          _newText = "密码只能为数字，长度为4";
        });
      } else{
        setState(() {
          _isNew = false;
        });
      }
      print("_isNew===>${_isNew}");
    });
    _confirmPasswordController.addListener((){
      if(_newPasswordController.text == _confirmPasswordController.text && _isOrd && _isNew){
        setState(() {
          _isConfirm = true;
          _confirmText = " ";
        });
      }else if(_confirmPasswordController.text.length != 4 && _isOrd && _isNew && _newPasswordController.text != _confirmPasswordController.text){
        setState(() {
          _isConfirm = false;
          _confirmText = "两次输入的密码不一致";
        });
      }
      print("_isConfirm===>${_isConfirm}");

    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StoreBuilder<GSYState>(builder: (context, store){
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("修改监护密码",style:TextStyle(color: Color(0XFFffffff))),
          backgroundColor: Color(0xFF60c589),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0XFFffffff),
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
                child: _getTextField("旧密码(4位数字)",_ordPasswordController),
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
                child: _getTextField("新密码(4位数字)",_newPasswordController),
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
                  child:_getTextField("再输一次新密码（4位数字）",_confirmPasswordController)
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
                color:Color(0xFF60c589),
                disabledColor:Colors.black26,
                child:Text("确认修改",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color:_isConfirm? Colors.white: Colors.white70,),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  checkPassword() async{
     var dataResult = await UserDao.checkPassword(_ordPasswordController.text);
     print("dataResult====>${dataResult}");
     var ext1 = dataResult["success"]["ext1"];
     bool isCheck = true;
       if(ext1 == "T"){
         print("正确");
         isCheck = true;
       }else if(ext1 == "F"){
         print("错误");
         isCheck = false;
       }
       return isCheck;
  }

  //更改密码
  _resetPassword() async{
    print(_ordPasswordController.text);
    print(_newPasswordController.text);
    var res =  await UserDao.editCheckPassword(_newPasswordController.text);
    if(res["success"]["ok"] == 0){
      showToast("修改成功");
      Navigator.pop(context);
    }else{
      showToast("修改失败");
    }
  }
  TextFormField _getTextField(String hintText, TextEditingController controller, { GlobalKey key}) {
    return TextFormField(
      key: key,
      keyboardType: TextInputType.phone,
      obscureText: true,
      controller: controller,
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black,textBaseline:TextBaseline.alphabetic),
      inputFormatters: [LengthLimitingTextInputFormatter(4)],
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