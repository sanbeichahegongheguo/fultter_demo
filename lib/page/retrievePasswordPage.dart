
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/common/utils/CountDown.dart';
import 'package:flutter_start/widget/CodeWidget.dart';
import 'package:oktoast/oktoast.dart';

class retrievePasswordPage extends StatefulWidget {
  static final String sName = "retrievePassword";

  @override
  State<StatefulWidget> createState() {
    return retrievePasswordState();
  }
}
class retrievePasswordState extends State<retrievePasswordPage> with SingleTickerProviderStateMixin {
  TextEditingController userPhoneController = new TextEditingController();
  TextEditingController codeController = new TextEditingController();
  TextEditingController newPwdController = new TextEditingController();
  TextEditingController newPwdSureController = new TextEditingController();

  var _pageController = new PageController(initialPage: 0);
  ///当前步骤
  int _currentStep = 0;
  int _currentPageIndex = 0;
  ///输入框删除按钮
  bool _hasdeleteIcon = false;
  ///发送验证码按钮
  bool _sendBtn = false;
  ///输入验证码的下一步
  bool _phoneNext = false;
  bool _codeNext = false;
  String _titleName = '重设密码';
  String _helpText = '';

  ///设置新密码的下一步
  bool _setPwdNext = false;
  bool _setPwdNewNext = false;

  bool _recoverTime = true;

  void initState() {
    super.initState();
    newPwdController.addListener((){
      bool _letterStandard = newPwdController.text.contains(new RegExp("[a-zA-Z]"));
      bool _numberStandard = newPwdController.text.contains(new RegExp("[0-9]"));
      bool _pwdStandard = _letterStandard&&_numberStandard;
      if(newPwdController.text != ''&&newPwdController.text.length > 5&&newPwdController.text.length < 21&&_pwdStandard){
        setState(() {
          _setPwdNext = true;
        });
      }else{
        setState(() {
          _setPwdNext = false;
        });
      }
    });

    newPwdSureController.addListener((){
      if(newPwdSureController.text != ''&&newPwdSureController.text == newPwdController.text){
        setState(() {
          _setPwdNewNext = true;
        });
      }else{
        setState(() {
          _setPwdNewNext = false;
        });
      }
    });

    userPhoneController.addListener((){
      if (userPhoneController.text == "") {
        setState(() {
          _hasdeleteIcon = false;
        });
      } else {
        setState(() {
          _hasdeleteIcon = true;
        });
      }
      if (userPhoneController.text.length > 10) {
        setState(() {
          _phoneNext = true;
        });
      }else{
        setState(() {
          _phoneNext = false;
        });
      }
    });
    codeController.addListener((){
      if (codeController.text.length > 5) {
        setState(() {
          _codeNext = true;
        });
      }else{
        setState(() {
          _codeNext = false;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor:  Color(0xFFf1f2f6),
      appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          //居中显示
          centerTitle: true,
          leading: new IconButton(
              icon: new Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF333333),
              ),
              onPressed: () {
                print(_currentStep);
                if(_currentStep==0||_currentStep==2){
                  NavigatorUtil.goLogin(context);
                }else if(_currentStep==1){
                  _nextStep(0);
                  setState(() {
                    _recoverTime = false;
                    _titleName = '重设密码';
                  });
                }
              }
          ),
          title: Text(
            _titleName,
            style: TextStyle(color: Color(0xFF333333), fontSize:ScreenUtil.getInstance().getSp(19)),)
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: new PageView.builder(
          onPageChanged:_pageChange,
          controller: _pageController,
          physics: new NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context,int index){
            if(index==0){
              return _sendCode();
            }else if(index==1){
              return _setPwd();
            }else if(index==2){
              return _setSuccess();
            }
          },
          itemCount: 3,
        ),
      ),
    );
  }

  ///发送验证码
  Widget _sendCode(){
    return new Container(
      child: new Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(100)),
              child: _getTextField('您的手机号',userPhoneController,'phone',length:11,hasDelete:true,limteLength:true,rule:WhitelistingTextInputFormatter.digitsOnly)
          ),
          Container(
              padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(50)),
              child: Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  _getTextField('请输入验证码',codeController,'phone',length:6,hasDelete:false,limteLength:true,rule:WhitelistingTextInputFormatter.digitsOnly),
                  GestureDetector(
                    onTap: (){
                      if(!_sendBtn){
                        _sendNumberCode();
                      }
                    },
                    child: Container(
                        margin: EdgeInsets.only(right:ScreenUtil.getInstance().getWidthPx(60)),
                        child: _sendBtn?
                        CountDown(dataTwo: userPhoneController.text,recoverTime:_recoverTime,where: 'rePwd'):
                        Text('发送验证码',style: TextStyle(
                            color: Color(0xFF6ed699),
                            fontSize: ScreenUtil.getInstance().getSp(48 / 3)
                        ),
                        )
                    ),
                  ),
                ],
              ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(120)),
            child: CommonUtils.buildBtn(
                '下一步',
                width: ScreenUtil.getInstance().getWidthPx(845),
                height: ScreenUtil.getInstance().getHeightPx(135),
                splashColor:_codeNext&&_phoneNext&&_sendBtn?Color(0xFF6ed699):Color(0xFFdfdfeb),
                decorationColor:_codeNext&&_phoneNext&&_sendBtn?Color(0xFF6ed699):Color(0xFFdfdfeb),
                textColor:Color(0xFFffffff),
                onTap: (){
                  if(_codeNext&&_phoneNext&&_sendBtn){
                    _checkCode();
                  }else{
                    if(!_codeNext&&!_phoneNext){
                      showToast('请输入正确的信息！');
                    }else{
                      showToast('请先发送验证码！');
                    }
                  }
                }),
          ),
        ],
      ),
    );
  }

  ///设置新密码
  Widget _setPwd(){
    return Container(
      child: new Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(100)),
              child: _getTextField('输入新密码',newPwdController,'',limteLength:true,length:20,rule:WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[0-9]")))
          ),
          Container(
              padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(50)),
              child: _getTextField('再次输入新密码',newPwdSureController,'',limteLength:true,length:20,rule:WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[0-9]")),helpText:_helpText)
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(120)),
            child: CommonUtils.buildBtn(
                '确认更改',
                width: ScreenUtil.getInstance().getWidthPx(845),
                height: ScreenUtil.getInstance().getHeightPx(135),
                splashColor:_setPwdNext&&_setPwdNewNext?Color(0xFF6ed699):Color(0xFFdfdfeb),
                decorationColor:_setPwdNext&&_setPwdNewNext?Color(0xFF6ed699):Color(0xFFdfdfeb),
                textColor:Color(0xFFffffff),
                onTap: (){
                  _checkNewPwd();
                }),
          ),
        ],
      ),
    );
  }

  ///已设定了新密码
  Widget _setSuccess(){
    return new Container(
      child: new Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(35),top: ScreenUtil.getInstance().getHeightPx(100)),
            child:Align(
              alignment: Alignment.topLeft,
              child: Text('请牢记您的账号和密码！',style: TextStyle(
                color: Color(0xFFff6464),
                fontSize: ScreenUtil.getInstance().getSp(48/3),
              )),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(50)),
            width: ScreenUtil.getInstance().getWidthPx(1010),
            height: ScreenUtil.getInstance().getHeightPx(320),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              border: new Border.all(color: Color(0xFFe6e6e7)),
              borderRadius: new BorderRadius.all(
              Radius.circular((10.0))),
              ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('您的账号：${userPhoneController.text}',style: TextStyle(
                  color: Color(0xFF959595),
                  fontSize: ScreenUtil.getInstance().getSp(54/3),
                )),
                Text('您的密码：${newPwdSureController.text}',style: TextStyle(
                  color: Color(0xFF959595),
                  fontSize: ScreenUtil.getInstance().getSp(54/3),
                )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(100)),
            child: CommonUtils.buildBtn(
                '登录',
                width: ScreenUtil.getInstance().getWidthPx(845),
                height: ScreenUtil.getInstance().getHeightPx(135),
                splashColor:Color(0xFF6ed699),
                decorationColor:Color(0xFF6ed699),
                textColor:Color(0xFFffffff),
                onTap: (){
                  NavigatorUtil.goLogin(context,account:(userPhoneController.text).toString(),password:(newPwdSureController.text).toString());
                }),
          ),
        ],
      ),
    );
  }
  
  
  ///输入框
  TextField _getTextField(String hintText,TextEditingController controller,String what,{bool obscureText,int length,bool hasDelete,bool limteLength,dynamic rule,String helpText}){
    return TextField(
      controller: controller,
      cursorColor: Color(0xFF333333),
      style: TextStyle(textBaseline:TextBaseline.alphabetic),
      keyboardType:  what=="phone"?TextInputType.phone:TextInputType.text,
      obscureText: obscureText ?? false,
      inputFormatters: limteLength?[LengthLimitingTextInputFormatter(length),rule]:[],
      decoration: new InputDecoration(
        suffixIcon: _hasdeleteIcon&&hasDelete
            ? IconButton(
          onPressed: () {
            setState(() {
              controller.text = "";
              _hasdeleteIcon = (controller.text.isNotEmpty);
            });
          },
          icon: Icon(
            Icons.cancel,
            color: Color(0xFFcccccc),
          ),
        )
            : Text(""),
        contentPadding: EdgeInsets.all(13),
        hintStyle: TextStyle(fontSize: ScreenUtil.getInstance().getSp(16)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none
        ),
        filled:true,
        fillColor:Color(0xFFFFFFFF),
        hintText: hintText,
        helperText:helpText==''?'':helpText,
        helperStyle: TextStyle(color: Color(0xFFA94442)),
      ),
    );
  }

  void _checkNewPwd(){
    bool letterStandard = newPwdController.text.contains(new RegExp("[a-zA-Z]"));
    bool numberStandard = newPwdController.text.contains(new RegExp("[0-9]"));
    bool pwdStandard = letterStandard&&numberStandard;
    setState(() {
      if(newPwdController.text == ''){
        _helpText = '请输入新密码';
      }else if(newPwdController.text.length < 6||newPwdController.text.length > 20){
        _helpText = '新密码要求6-20位字符';
      }else if(!pwdStandard){
        _helpText = '新密码至少包含数字、字母两种元素';
      }else if(newPwdSureController.text == ''){
        _helpText = '请再次输入新密码';
      }else if(newPwdSureController.text != newPwdController.text){
        _helpText = '两次密码不匹配，请重新输入';
      }else{
        _setNewPwd();
      }
    });
  }

  void _setNewPwd() async{
    CommonUtils.showLoadingDialog(context, text: "正在更改···");
    DataResult data = await UserDao.forgetRePwd(userPhoneController.text,codeController.text,newPwdSureController.text);
    Navigator.pop(context);
    if(data.result){
      setState(() {
        _helpText = '';
        _titleName = '已设定了新密码';
        _nextStep(2);
      });
    }else{
      showToast(data.data);
    }
    print(data.result);
  }


  void _nextStep(int index) {
    print(index);
    setState(() {
      _currentStep = index;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  void _pageChange(int index) {
    setState(() {
      if (_currentPageIndex != index) {
        _currentPageIndex = index;
      }
    });
  }

  void _sendNumberCode() async{
    var isSend = await CommonUtils.showEditDialog(
      context,
      CodeWidget(phone: userPhoneController.text),
    );
    if (null != isSend && isSend) {
      setState(() {
        _sendBtn = true;
      });
    }
  }

  ///校验手机验证码
  void _checkCode() async{
    CommonUtils.showLoadingDialog(context, text: "验证中···");
    DataResult data = await UserDao.checkCode(userPhoneController.text,codeController.text);
    Navigator.pop(context);
    if(data.result){
      _nextStep(1);
      setState(() {
        _titleName = '设置新密码';
        _hasdeleteIcon = false;
      });
    }else{
      showToast(data.data);
    }
  }

}