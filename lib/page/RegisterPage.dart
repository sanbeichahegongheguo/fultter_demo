import 'dart:convert';
import 'package:flustars/flustars.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/common/utils/pin_input_text_field.dart';
import 'package:flutter_start/common/utils/CountDown.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/widget/CodeWidget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:redux/redux.dart';

class RegisterPage extends StatefulWidget {
  static final String sName = "register";

  final String from;
  final bool isLogin;
  final int index;
  final String userPhone;
  final String stuPhone;
  final String head;
  final String name;
  final int userId;
  final int registerState;

  RegisterPage({this.from,this.isLogin,this.index=0,this.userPhone,this.registerState, this.head,this.name, this.userId, this.stuPhone});

  @override
  State<StatefulWidget> createState() {
    return RegisterState(index);
  }
}

class RegisterState extends State<RegisterPage> with SingleTickerProviderStateMixin{
  TextEditingController userPhoneController = new TextEditingController();
  TextEditingController schoolController = new TextEditingController();
  TextEditingController teacherNameController = new TextEditingController();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController userPasswordController = new TextEditingController();
  PinEditingController pinEditingController = new PinEditingController(pinLength:6,autoDispose:false);
  RegisterState(this._currentPageIndex) : this._pageController = new PageController(initialPage: _currentPageIndex),super();
  //输入框删除按钮
  bool _hasdeleteIcon = false;
  //输入手机框下一步按钮
  bool nextBtn = false;
  bool keyBordTarget = false;
  int _currentPageIndex = 0;
  var _pageController;
  ///标题栏
  String _titleName = "输入手机号";
  String _schoolName = "";
  String gradeName = "";
  int _schoolId = 0;
  ///协议选中未选中状态
  bool _AgreementCheck = true;
  ///学校下拉列表
  bool _expand = true;

  //选择年级颜色和年级信息
  List<bool> color = [false,false,false,false,false,false];
  List<String> list = ['一年级','二年级','三年级','四年级','五年级','六年级'];

  bool _classNextBtn = false;
  bool _viewPassword = false;
  bool _viewPasswordText = false;

  bool _lengthStandard = false;
  bool _includeStandard = false;

  //验证码是否已经验证过
  bool _checkCodeTarget = false;

  List<String> classList = [];
  List<bool> classListColor = [];

  List<dynamic> _schoolList = [];
  List<dynamic> classesList = [];

  dynamic _classId = 0;
  int _className = 0;
  int _gradeName = 0;

  //当前步骤
  int _currentStep = 0;

  String _helperText = "";

  bool _recoverTime = true;
  ///整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    print("RegisterState dispose");
    userPasswordController?.dispose();
    userNameController?.dispose();
   userPhoneController?.dispose();
   schoolController?.dispose();
   teacherNameController?.dispose();
   pinEditingController?.dispose();
    super.dispose();

  }
  @override
  void initState() {
    super.initState();
    print(widget.from);
    if (null!=widget.userPhone&&widget.userPhone!=""){
      userPhoneController.text = widget.userPhone ;
    }
    userPasswordController.addListener((){
      if (userPasswordController.text == "") {
        setState(() {
          _viewPassword = false;
        });
      } else {
        setState(() {
          _viewPassword = true;
        });
      }
    });

    userNameController.addListener((){
      if (userNameController.text == "") {
        setState(() {
          _hasdeleteIcon = false;
        });
      } else {
        setState(() {
          _hasdeleteIcon = true;
        });
      }
    });
    pinEditingController.addListener(() {
      if(pinEditingController.text.length<6&&_checkCodeTarget){
        setState(() {
          _checkCodeTarget = false;
        });
      }
      if(pinEditingController.text.length==6&&!_checkCodeTarget){
        _checkCodeTarget = true;
        if (null!=widget.isLogin && widget.isLogin && widget.registerState==2){
          _login();
          print('我走登录');
        }else if(null!=widget.isLogin && !widget.isLogin &&widget.registerState==3){
          _changeParent();
          print('验证登录,改136的家长为135家长');
        }else{
          _checkCode();
          print('我走注册');
        }
      }
    });
    schoolController.addListener((){
      if (schoolController.text == "") {
        setState(() {
          _hasdeleteIcon = false;
          _expand = true;
        });
      } else {
        setState(() {
          _searchSchool();
        });
      }
    });
    userPhoneController.addListener(() {
      RegExp exp = RegExp(
          r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
      bool matched = exp.hasMatch(userPhoneController.text);
      if (userPhoneController.text == "") {
        setState(() {
          _hasdeleteIcon = false;
        });
      } else {
        setState(() {
          _hasdeleteIcon = true;
        });
      }
      ///长度大于10，且手机号码格式正确进入下一步
      if (userPhoneController.text.length > 10&&matched&&_AgreementCheck) {
        if(this.keyBordTarget == false){
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            this.keyBordTarget = true;
          });
        }
        if (this.nextBtn == false) {
          setState(() {
            this.nextBtn = true;
          });
        }
      } else {
        setState(() {
          this.keyBordTarget = false;
        });
        if (this.nextBtn == true) {
          setState(() {
            this.nextBtn = false;
          });
        }
      }
    });
  }

  //构建ui
  Widget build(BuildContext context){
    setState(() {
      if(_currentPageIndex == 0){
        _titleName = '输入手机号';
      }else if(_currentPageIndex == 1){
        _titleName = '验证手机号';
      }else if(_currentPageIndex == 2 || _currentPageIndex == 3 || _currentPageIndex == 4){
        _titleName = '填写学校班级';
      }else{
        _titleName = '姓名与密码设置';
      }
    });
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return StoreBuilder<GSYState>(builder: (context, store) {
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
                  setState(() {
                    _helperText = '';
                  });
                  if (null!=widget.isLogin && !widget.isLogin){
                    //判断当前步骤
                    print('当前步骤');
                    print(_currentPageIndex);
                    if(_currentPageIndex==0){
                      NavigatorUtil.goLogin(context);
                    }else if(_currentPageIndex==1){
                      if(widget.registerState==3){
                        NavigatorUtil.goBuildArchives(context,registerState:widget.registerState,index: 2,userPhone:widget.userPhone,head:widget.head,name:widget.name,userId:widget.userId);
                      }else{
                        _onTap(0);
                        setState(() {
                          _titleName = '输入手机号';
                          pinEditingController.text = '';
                        });
                      }
                    }else if(_currentPageIndex==2){
                      if(widget.registerState==1){
                        ///进入建立档案页面
                        NavigatorUtil.goBuildArchives(context,registerState:widget.registerState,index: 0,userPhone:widget.userPhone);
                      }else if(widget.registerState==3){
                        NavigatorUtil.goBuildArchives(context,registerState:widget.registerState,index: 2,userPhone:widget.userPhone,head:widget.head,name:widget.name,userId:widget.userId);
                      }else{
                        _onTap(1);
                        setState(() {
                          _recoverTime = false;
                          _titleName = '验证手机号';
                          pinEditingController.text = '';
                        });
                      }
                    }else if(_currentPageIndex==3){
                      _onTap(2);
                    }else if(_currentPageIndex==4){
                      _onTap(3);
                      setState(() {
                        _titleName = '填写学校班级';
                        pinEditingController.text = '';
                      });
                    }else if(_currentPageIndex==5){
                      _onTap(4);
                      setState(() {
                        _titleName = '填写学校班级';
                        pinEditingController.text = '';
                      });

                    }
                  }else{
                    print('返回哦');
                    NavigatorUtil.goWelcome(context);
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
                return _editPhoneNumber();
              }else if(index==1){
                return _editCode();
              }else if(index==2){
                return _editSchool();
              }else if(index==3){
                return _editGrade();
              }else if(index==4){
                return _editClass();
              }else if(index==5){
                return _editNameAndPassword();
              }
            },
            itemCount: 6,
          ),
        ),
      );
     });

  }

  //搜索学校
  void _searchSchool() async{
    DataResult data = await UserDao.searchSchool('base','school',schoolController.text,'');
    if(data.data['error']==0){
      setState(() {
        this._schoolList = data.data['schoollist'];
        _hasdeleteIcon = true;
        _expand = false;
        _helperText = '';
      });
    }else{
      setState(() {
        _expand = true;
        _helperText = '搜索不到相应学校！';
      });
    }
  }

  //校验手机验证码
  void _checkCode() async{
    CommonUtils.showLoadingDialog(context, text: "验证中···");
    DataResult data = await UserDao.checkCode(userPhoneController.text,pinEditingController.text);
    Navigator.pop(context);
    if(data.result){
      print('传过来的信息');
      print(widget.registerState);
      ///判断走1还是3的流程
      if(widget.registerState==1){
        ///进入建立档案页面
        NavigatorUtil.goBuildArchives(context,registerState:widget.registerState,index: 0,userPhone:widget.userPhone);
      }else if(widget.registerState==3){
        NavigatorUtil.goBuildArchives(context,registerState:widget.registerState,index: 2,userPhone:widget.userPhone,head:widget.head,name:widget.name);
      }else{
        _onTap(2);
        setState(() {
          _titleName = '填写学校班级';
          _hasdeleteIcon = false;
        });
      }
    }else{
      setState(() {
        _checkCodeTarget = true;
      });
      showToast(data.data);
    }
  }

  void _login() async {
    _checkCodeTarget = true;
    Store<GSYState> store = StoreProvider.of(context);
    CommonUtils.showLoadingDialog(context, text: "登陆中···");
    DataResult data = await UserDao.login(userPhoneController.text,"", store,code: pinEditingController.text);
    Navigator.pop(context);
    if (data.result) {
      showToast("登录成功 ${data.data.realName}");
      Future.delayed(Duration(milliseconds:500)).then((_){
        NavigatorUtil.goHome(context);
      });
    } else {
      if (null != data.data) {
        showToast(data?.data ?? "");
      }
      setState(() {
        _checkCodeTarget = true;
      });
    }
  }

  void _changeParent() async{
    print(userPhoneController.text);
    print(widget.userId);
    print(pinEditingController.text);
    Store<GSYState> store = StoreProvider.of(context);
    CommonUtils.showLoadingDialog(context);
    DataResult data = await UserDao.updateParentMobile(userPhoneController.text,widget.userId,pinEditingController.text);
    Navigator.pop(context);
    if(data.result){
//      showToast(data.data["message"]);
      _login();
    }else{
      setState(() {
        _checkCodeTarget = true;
      });
      if (data!=null&&data.data?.code !=null &&data.data?.code ==400){
        showToast("验证码错误！");
      }
    }
  }

  //姓名与设置密码步骤
  Widget _editNameAndPassword(){
    return new Container(
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(120)),
              child: _getTextField('请输入您的孩子姓名',userNameController,'')
          ),
          Container(
              padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(40)),
              child: TextField(
                style: TextStyle(textBaseline:TextBaseline.alphabetic),
                controller: userPasswordController,
                cursorColor: Color(0xFF333333),
                obscureText: !_viewPasswordText ?? false,
                inputFormatters:[LengthLimitingTextInputFormatter(20),
                  WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[0-9]")),
                ],
                decoration: new InputDecoration(
                  suffixIcon: _viewPassword
                      ? IconButton(
                    onPressed: () {
                      setState(() {
                        _viewPasswordText = !_viewPasswordText;
                      });
                    },
                    icon: !_viewPasswordText?IconButton(
                      icon: Image.asset('images/register/closeEye.png'),
                      iconSize: 45.0,
                      color: Color(0xFF000000),
                    ):Icon(
                      Icons.remove_red_eye,
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
                  hintText: '请设置密码',
                ),
                onChanged: (text) {
                  _checkPasswordStandard(text);
                },
              )
          ),
          Container(
            padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(40)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _passwordTip(' 密码要求6-20位字符','length'),
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(10),
                ),
                _passwordTip(' 至少包含数字、字母其中两种元素','include'),
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(10),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(40)),
                  child: Text(
                      ' *  建议避免使用生日，姓名和连续数字',
                    style: TextStyle(
                      color:Color(0xFFff6464),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(453)),
            child: CommonUtils.buildBtn(
                '下一步',
                width: ScreenUtil.getInstance().getWidthPx(845),
                height: ScreenUtil.getInstance().getHeightPx(135),
                splashColor:Color(0xFF6ed699),
                decorationColor:_lengthStandard&&_includeStandard&&_hasdeleteIcon?Color(0xFF6ed699):Color(0xFFdfdfeb),
                textColor:Color(0xFFffffff),
                onTap: (){
                  _setPwdBtnCheck();
                }),
          ),
          SizedBox(
            height: ScreenUtil.getInstance().getWidthPx(65),
          ),
          Container(
            child: Text("注册信息须真实有效，否则礼物无法派送",
                style: TextStyle(color: Color(0xFFff6464),  fontSize: ScreenUtil.getInstance().getSp(13.41),
                )
            ),
          ),
          SizedBox(
            height: ScreenUtil.getInstance().getWidthPx(55),
          ),
          Container(
            child: GestureDetector(
              onTap: (){
                linkTo('wxServer');
              },
              child:Text(
              "有问题？找客服！",
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: ScreenUtil.getInstance().getSp(14.82),
                decoration: TextDecoration.underline,
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  //密码验证规则
  _checkPasswordStandard(text){
    bool letterStandard = text.contains(new RegExp("[a-zA-Z]"));
    bool numberStandard = text.contains(new RegExp("[0-9]"));
    if(text.length>=6&&text.length<=20){
      setState(() {
        _lengthStandard = true;
      });
    }else{
      setState(() {
        _lengthStandard = false;
      });
    }
    if(letterStandard&&numberStandard){
      setState(() {
        _includeStandard = true;
      });
    }else{
      setState(() {
        _includeStandard = false;
      });
    }
  }

  //已有账号弹框
  void _setPwdBtnCheck() async{
    ///验证中文名
    RegExp exp = RegExp(r'^[\u4E00-\u9FA5]{2,4}$');
    bool isName = exp.hasMatch(userNameController.text);
    bool isSurname = false;
    ///验证姓氏是否合法
    DataResult data = await UserDao.checkname(userNameController.text);
    if(data.data['err']==0){
      isSurname = true;
    }else{
      isSurname = false;
    }
    if(_lengthStandard&&_includeStandard&&_hasdeleteIcon&&isName&&isSurname){
      DataResult data = await UserDao.checkSameRealNamePhone(_classId,userNameController.text,userPhoneController.text);
      if(data.data['err']==1){
        ///用户已存在
        dynamic json = jsonDecode(jsonDecode(data.data['ext1']));
        print(json["mobile"]);
        var widgetMsg =  Column(
        children: <Widget>[
          SizedBox(
            height: ScreenUtil.getInstance().getHeightPx(30),
          ),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil.getInstance().getHeightPx(35)),
            child:Align(
              alignment: Alignment.topLeft,
              child: Text(
                '${json["realname"]} 家长已有',
                style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(18), color: const Color(0xFF666666))),
            ),
          ),

          SizedBox(
            height: ScreenUtil.getInstance().getHeightPx(30),
          ),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42)),
            child: Text(
                '${json["mobile"]} 为手机号的账号，请使用旧手机号登录，谢谢！',
                style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(16), color: const Color(0xFF666666))),
          ),
          SizedBox(
            height: ScreenUtil.getInstance().getHeightPx(80),
          ),
          CommonUtils.buildBtn("更换手机号",
              height: ScreenUtil.getInstance().getHeightPx(120),
              width: ScreenUtil.getInstance().getWidthPx(515),
              onTap: (){
                NavigatorUtil.goRegester(context);
                //跳转到更换手机号
              }),
          SizedBox(
            height: ScreenUtil.getInstance().getHeightPx(30),
          ),
          CommonUtils.buildBtn("原号码登录",
              height: ScreenUtil.getInstance().getHeightPx(120),
              width: ScreenUtil.getInstance().getWidthPx(515),
              onTap: (){
                NavigatorUtil.goWelcome(context);
              }),
        ],
      );
        if(this._classNextBtn){
          CommonUtils.showEditDialog(context,widgetMsg,height: ScreenUtil.getInstance().getHeightPx(650),width: ScreenUtil.getInstance().getWidthPx(903));
        }
      }else if(data.data['err']==0||data.data['err']==401){
        String className = "$gradeName年级$_className班";
        CommonUtils.showLoadingDialog(context, text: "注册中···");
        DataResult registerDate;
        print('选择没有学生账号密码过来的');
        print(widget.registerState);
        if(widget.registerState==3){
          registerDate = await UserDao.register('JZZC',widget.stuPhone,userPasswordController.text,userNameController.text,'S',_classId,_schoolId,className,_gradeName,_className,parentPhone:userPhoneController.text);
        }else{
          registerDate = await UserDao.register('JZZC',userPhoneController.text,userPasswordController.text,userNameController.text,'S',_classId,_schoolId,className,_gradeName,_className);
        }
        Navigator.pop(context);
        print('注册信息');
        print(registerDate.data);
        if(!registerDate.data['success']){
          showToast(registerDate.data['message']);
        }else{
          print(registerDate.data);
          showToast('注册成功！');
          NavigatorUtil.goLogin(context,account:(userPhoneController.text).toString(),password:(userPasswordController.text).toString());
        }
        ///进行注册
      }else{
        showToast(data.data['msg']);
      }
    }else if(!isName||!isSurname){
      showToast("姓名不合法!");
    }else if(!_hasdeleteIcon){
      showToast("请输入您的孩子姓名!");
    }
    else if(!_lengthStandard){
      showToast("密码要求6-20位字符!");
    }else if(!_includeStandard){
      showToast("密码至少包含数字,字母其中两种元素!");
    }
  }

  //密码提示
  Widget _passwordTip(String tipText,String where){
    return new Container(
      padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(48)),
      child: new Row(
        children: <Widget>[
          where == 'length'?
          Icon(
            Icons.fiber_manual_record,
            size: 8,
            color: _lengthStandard?Color(0xFF85d874):Color(0xFF999999),
          ):
          Icon(
            Icons.fiber_manual_record,
            size: 8,
            color: _includeStandard?Color(0xFF85d874):Color(0xFF999999),
          ),
          Text(
            tipText,
            style: TextStyle(
              color:Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  //输入手机号步骤
  Widget _editPhoneNumber(){
    return new Container(
      child:  new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: ScreenUtil.getInstance().getHeightPx(45), top:ScreenUtil.getInstance().getHeightPx(130)),
                child:Text('开始注册前，请先验证您的手机号！', style: TextStyle(color: Color(0xFFff6464), fontSize: ScreenUtil.getInstance().getSp(16.93))),
              ),
              Container(
                  padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(60)),
                  child: _getTextField('请输入您的手机号',userPhoneController,'phone')
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(100), right: ScreenUtil.getInstance().getWidthPx(100), top: ScreenUtil.getInstance().getHeightPx(160)),
                child: Material(
                  color: Colors.transparent,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    onTap: () {
                      _checkPhone();
                    },
                    splashColor: nextBtn ? Color(0xFF6ed699) : Color(0xFFdfdfeb),
                    child: Ink(
                      height: ScreenUtil.getInstance().getHeightPx(120),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: nextBtn ? Color(0xFF6ed699) : Color(0xFFdfdfeb),
                      ),
                      child: Center(
                        child: Text(
                          '下一步',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 20.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _bottomAgreement(),
        ],
      )
    );
  }

  //判断手机号格式
  void _checkPhone() async{
    setState(() {
      _recoverTime = true;
    });
    RegExp exp = RegExp(
        r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    bool matched = exp.hasMatch(userPhoneController.text);
    if(this.nextBtn&&matched&&_AgreementCheck){
      CommonUtils.showLoadingDialog(context, text: "验证手机号中···");
      DataResult data = await UserDao.checkHaveAccount(userPhoneController.text, 'P');
      Navigator.pop(context);
       if(data.result){
         print(data.result);
         print(data.data == "1");
          if(data.data == "1"){
            var isSend = await CommonUtils.showEditDialog(
              context,
              CodeWidget(phone: userPhoneController.text),
            );
            print('isSend');
            print(isSend);
            if (null != isSend && isSend) {
              _onTap(1);
            }
          }else{
            showToast("该手机号已注册！",position: ToastPosition.center);
          }
       }
    }else if(!_AgreementCheck){
      showToast("请先同意协议！",position: ToastPosition.center);
    }else{
      showToast("请输入正确的手机号！",position: ToastPosition.center);
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  //输入验证码步骤
  Widget _editCode(){
    return new Container(
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: ScreenUtil.getInstance().getHeightPx(45), top:ScreenUtil.getInstance().getHeightPx(87)),
            child:Text('请输入短信验证码',
                style: TextStyle(color: Color(0xFF333333), fontSize: ScreenUtil.getInstance().getSp(20),fontWeight: FontWeight.w700)),
          ),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil.getInstance().getHeightPx(45), top:ScreenUtil.getInstance().getHeightPx(20)),
            child:Text('验证码已发送到：${userPhoneController.text}',
                style: TextStyle(color: Color(0xFF89898a), fontSize: ScreenUtil.getInstance().getSp(18))),
          ),
          Container(
            height: ScreenUtil.getInstance().getHeightPx(200),
            padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(45),right: ScreenUtil.getInstance().getWidthPx(45), top:ScreenUtil.getInstance().getHeightPx(100)),
            child: new PinInputTextField(
                pinLength: 6,
                pinEditingController:pinEditingController,
                decoration:BoxLooseDecoration(
                  gapSpace:ScreenUtil.getInstance().getWidthPx(58),
                ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(69)),
            child:CountDown(dataTwo: userPhoneController.text,recoverTime:_recoverTime),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left:ScreenUtil.getInstance().getHeightPx(20),top:ScreenUtil.getInstance().getHeightPx(50)),
            child:GestureDetector(
              onTap: (){
                linkTo('wxServer');
              },
              child: Text('收不到验证码？',
                  style: TextStyle(
                    color: Color(0xFFff6464),
                    fontSize: ScreenUtil.getInstance().getSp(14.82),
                    decoration: TextDecoration.underline,
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  //填写学校
  Widget _editSchool(){
    return new Stack(
      children: <Widget>[
        new Offstage(
          offstage: _expand,
          child: _buildListView(),
        ),
        new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidth(20), top: ScreenUtil.getInstance().getHeightPx(117)),
                      child:Text('您的孩子所在学校是：', style: TextStyle(color: Color(0xFF333333), fontSize:ScreenUtil.getInstance().getSp(16.93))),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(25)),
                      child: _getTextField('',schoolController,''),
                    ),
                  ]
              ),
              _bottomInfo(),
            ],
          ),
        ),
      ],
    );
  }

  //填写年级
  Widget _editGrade(){
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(93),top: ScreenUtil.getInstance().getHeightPx(114)),
                child:Align(
                  alignment: Alignment.topLeft,
                  child: Text(_schoolName, style: TextStyle(color: Color(0xFF333333), fontSize:ScreenUtil.getInstance().getSp(16.93),fontWeight: FontWeight.w700)),
                )
                ),
              Container(
                margin: new EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(20), 0, 0),
                width: ScreenUtil.getInstance().getWidthPx(1000),
                height: ScreenUtil.getInstance().getHeightPx(940),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(15),
                  ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeightPx(20),
                    ),
                    Text(
                        '您的孩子属于哪个年级？',
                        style: TextStyle(color: Color(0xFF999999), fontSize:ScreenUtil.getInstance().getSp(14.82))
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeightPx(10),
                    ),
                    Text(
                        '注意：如在7-8月注册，应选择暑假前所在年级',
                        style: TextStyle(color: Color(0xFFff6464), fontSize:ScreenUtil.getInstance().getSp(13.41))
                    ),
                    Container(
                      padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(60)),
                      height: ScreenUtil.getInstance().getHeightPx(760),
                      child: GridView.count(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          crossAxisCount: 2, // 横向item个数
                          padding: EdgeInsets.all(ScreenUtil.getInstance().getWidthPx(90)), // 内边距
                          crossAxisSpacing: ScreenUtil.getInstance().getWidthPx(80), // 横向间距
                          mainAxisSpacing: ScreenUtil.getInstance().getHeightPx(60), // 竖向间距
                          childAspectRatio: 2.5,
                          children: getGradeWidgetList(),
                      ),
                    )
                  ],
                ),
              ),
            ]
          ),
          _bottomInfo(),
        ],
      ),
    );
  }

  //填写班级
  Widget _editClass(){
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(93),top: ScreenUtil.getInstance().getHeightPx(114)),
                child:Align(
                  alignment: Alignment.topLeft,
                  child: Text(_schoolName, style: TextStyle(color: Color(0xFF333333), fontSize:ScreenUtil.getInstance().getSp(16.93),fontWeight: FontWeight.w700)),
                )
                ),
              Container(
                margin: new EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(20), 0, 0),
                width: ScreenUtil.getInstance().getWidthPx(1000),
                height: ScreenUtil.getInstance().getHeightPx(940),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(15),
                  ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeightPx(40),
                    ),
                    Text(
                        '您的孩子属于${this.gradeName}年级几班？',
                        style: TextStyle(color: Color(0xFF999999), fontSize:ScreenUtil.getInstance().getSp(14.82))
                    ),
                    Container(
                      padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(30)),
                      height: ScreenUtil.getInstance().getHeightPx(760),
                      child: GridView.count(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          crossAxisCount: 4, // 横向item个数
                          padding: EdgeInsets.all(ScreenUtil.getInstance().getWidthPx(30)), // 内边距
                          crossAxisSpacing: ScreenUtil.getInstance().getWidthPx(20), // 横向间距
                          mainAxisSpacing: ScreenUtil.getInstance().getHeightPx(60), // 竖向间距
                          childAspectRatio: 2,
                          children: getClassWidgetList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil.getInstance().getHeightPx(35),
              ),
              CommonUtils.buildBtn(
                  '下一步',
                  width: ScreenUtil.getInstance().getWidthPx(845),
                  height: ScreenUtil.getInstance().getHeightPx(135),
                  decorationColor: _classNextBtn ? Color(0xFF6ed699) : Color(0xFFdfdfeb),
                  splashColor:_classNextBtn ? Color(0xFF6ed699) : Color(0xFFdfdfeb),
                  textColor: Colors.white,
                  textSize: ScreenUtil.getInstance().getSp(19.05),
                  elevation: 2,
                  onTap: (){
                    _checkClassNextBtn();
                })
            ]
          ),
          _bottomInfo(),
        ],
      ),
    );
  }

  //验证数学老师姓
  _checkMathTeacher(teacherSurnname){
      print('验证数学老师的姓名');
      print(teacherSurnname);
      if(teacherNameController.text==teacherSurnname  || teacherNameController.text == teacherSurnname.substring(0,1)){
        showToast("验证成功",position: ToastPosition.top);
        Navigator.pop(context);
        setState(() {
          if(userNameController.text!=''){
            _hasdeleteIcon = true;
          }else{
            _hasdeleteIcon = false;
          }
        });
        _onTap(5);
      }else{
        showToast("抱歉！您输入的数学老师姓名或姓氏错误！",position: ToastPosition.top);
      }
  }

  //确认班级下一步
  void _checkClassNextBtn() async{
    if(_AgreementCheck){
      String teacherName = "";
      print(_classId);
      if(_classId==''){
        _onTap(5);
      }else{
        DataResult data = await UserDao.chooseClass(_classId);
        print(data.data['msg']['error']);
        if(data.data['msg']['error']=="0"){
          teacherName = data.data['teacherName'];
          print('老师的姓名');
          print(teacherName);
          print(teacherName.substring(0,1));
          if (data.data['teacherName']!='' && data.data['teacherName'] != '云老师') {
            var widgetMsg =  Column(
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(30),
                ),
                Text(
                    '请回答以下问题加入班级',
                    style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(18), color: const Color(0xFF666666))),
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(140),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: ScreenUtil.getInstance().getHeightPx(70), maxWidth: ScreenUtil.getInstance().getWidthPx(640)),
                  child: TextFormField(
                    controller: teacherNameController,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    style: TextStyle( fontSize: ScreenUtil.getInstance().getSp(14), color: Colors.black,textBaseline:TextBaseline.alphabetic),
                    decoration: new InputDecoration(
                      hintText: '您的孩子的数学老师姓什么？',
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(50),
                ),
                CommonUtils.buildBtn("验证", height: ScreenUtil.getInstance().getHeightPx(135), width: ScreenUtil.getInstance().getWidthPx(515),onTap: (){
                  _checkMathTeacher(teacherName);
//                  _checkMathTeacher(teacherName.substring(0,1));
                }),
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(50),
                ),
                Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: "验证不通过？",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: ScreenUtil.getInstance().getSp(12),
                        ),
                      ),
                      TextSpan(
                        text: "找客服！",
                        style: TextStyle(
                          color: Color(0xFF5fc589),
                          fontSize: ScreenUtil.getInstance().getSp(12),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          linkTo('wxServer');
                        },
                      ),
                    ]
                )),
              ],
            );
            if(this._classNextBtn){
              CommonUtils.showEditDialog(context,widgetMsg,height: ScreenUtil.getInstance().getHeightPx(650),width: ScreenUtil.getInstance().getWidthPx(903));
            }
          } else if (data.data['teacherName'] == '云老师') {
            //直接跳转到设置密码
            _onTap(5);
          }
        }else if (data.data['msg']['error'] == "21") {
          showToast('此班级不存在！');
          return;
        }
      }
    }else{
      showToast('请先同意协议！');
    }
  }

  List<Widget> getClassWidgetList() {
    return this.classList.map((item) => getItemClassContainer(item)).toList();
  }

  Widget getItemClassContainer(String item) {
    return Container(
      alignment: Alignment.center,
      child: CommonUtils.buildBtn(
          item,
          splashColor:Color(0xFF6ed699),
          decorationColor:this.classListColor[this.classList.indexOf(item)]?Color(0xFF6ed699):Color(0xFFf1f2f6),
          textColor:this.classListColor[this.classList.indexOf(item)]?Color(0xFFffffff):Color(0xFF666666),
          onTap: (){
            _checkClass(item,this.classList.indexOf(item));
          }),
    );
  }

  //遍历年级数组
  List<Widget> getGradeWidgetList() {
    return this.list.map((item) => getItemGradeContainer(item)).toList();
  }

  //返回年级按钮列表
  Widget getItemGradeContainer(String item) {
    return Container(
      child: CommonUtils.buildBtn(
          item,
          splashColor:Color(0xFF6ed699),
          decorationColor:this.color[this.list.indexOf(item)]?Color(0xFF6ed699):Color(0xFFf1f2f6),
          textColor:this.color[this.list.indexOf(item)]?Color(0xFFffffff):Color(0xFF666666),
          onTap: (){
            _checkGrade(item,this.list.indexOf(item));
          }),
    );
  }

  //选择年级，变色，下一页，选择班级
  void _checkGrade(item,index) async{
    if(_AgreementCheck){
      CommonUtils.showLoadingDialog(context, text: "正在选择年级···");
      DataResult data = await UserDao.chooseSchool(_schoolId,index+1);
      Navigator.pop(context);
      setState(() {
        this._gradeName = index+1;
        if(index == 0){
          this.gradeName = '一';
        }else if(index == 1){
          this.gradeName = '二';
        }else if(index == 2){
          this.gradeName = '三';
        }else if(index == 3){
          this.gradeName = '四';
        }else if(index == 4){
          this.gradeName = '五';
        }else if(index == 5){
          this.gradeName = '六';
        }
      });
      if(this.color.indexOf(true)==-1){
        setState(() {
          this.color[index] = true;
        });
      }else{
        setState(() {
          this.color = [false,false,false,false,false,false];
          this.color[index] = true;
        });
      }
      if(data.data['success']){
        setState(() {
          this.classList = [];
          this.classListColor = [];
          this.classesList = [];
          this._classId = 0;
        });
        print('classList的');
        print(this.classList);
        this.classesList = data.data['ext1'];
        for (int i = 0; i < 20; i++) {
          this.classList.add((i+1).toString()+'班');
          this.classListColor.add(false);
        }
        for (int i = 0; i < classesList.length; i++) {
          if(classesList[i]['classNum']>20){
            this.classList.add(classesList[i]['classNum'].toString()+'班');
            this.classListColor.add(false);
          }else if (classesList[i]['classNum'] == 0) {
            this.classList.insert(0,'0班');
            this.classListColor.add(false);
          }else{
            print('我进来这里了');
          }
        }
      }else{
        setState(() {
          this.classList = [];
          this.classListColor = [];
          this.classesList = [];
          this._classId = 0;
        });
        for (int i = 0; i < 20; i++) {
          this.classList.add((i+1).toString()+'班');
          this.classListColor.add(false);
        }
      }
      this._onTap(4);
    }else{
      showToast("请先阅读协议！");
    }
  }

  //选择班级，变色
  _checkClass(item,index){
    //当前班级
    int currentClass = index+1;
    print(currentClass);
    if(this.classesList.length==0){
      print('不存在');
      setState((){
        _classId = '';
        _className = currentClass;
      });
    }else{
      if(this.classesList.length>20){
        print('存在外层');
        setState((){
          _classId = this.classesList[index]['id'];
          _className = this.classesList[index]['classNum'];
        });
        print(_classId);
        print(_className);
      }else{
        for (var singleClass in this.classesList) {
          //当前选择的班级是否存在，存在的话
          if(currentClass==singleClass['classNum']){
            print('存在');
            setState((){
              _classId = singleClass['id'];
              _className = singleClass['classNum'];
            });
            break;
          }else{
            print('不存在，内层');
            setState((){
              _classId = '';
              _className = currentClass;
            });
          }
        }
      }

    }
    if(this.classListColor.indexOf(true)!=-1){
      setState((){
        var colorLength = this.classListColor.length;
        this.classListColor = [];
        for (int i = 0; i < colorLength; i++) {
          this.classListColor.add(false);
        }
      });
    }
    setState(() {
      this.classListColor[index] = true;
      this._classNextBtn = true;
      print(userNameController.text);
      this._hasdeleteIcon = false;
    });
  }

  //协议
  Widget _bottomAgreement(){
    return new Column(
        children: <Widget>[
          Container(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  child: _AgreementCheck ? new Icon(
                    Icons.check_circle,
                    color: Color(0xFF5fc589),
                    size:16.0,
                  ):new Icon(
                    Icons.radio_button_unchecked,
                    color: Color(0xFF5fc589),
                    size:16.0,
                  ),
                  onTap: () {
                    RegExp exp = RegExp(
                        r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
                    bool matched = exp.hasMatch(userPhoneController.text);
                    setState(() {
                      _AgreementCheck = !_AgreementCheck;
                      if(!_AgreementCheck){
                        this.nextBtn = false;
                      }
                      else if(_AgreementCheck&&userPhoneController.text.length > 10&&matched){
                        this.nextBtn = true;
                      }
                    });
                  },
                ),
                Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: "已阅读并同意",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: ScreenUtil.getInstance().getSp(11),
                        ),
                      ),
                      TextSpan(
                        text: "《远大教育用户服务协议》",
                        style: TextStyle(
                          color: Color(0xFF5fc589),
                          fontSize: ScreenUtil.getInstance().getSp(11),
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          linkTo('education');
                        },
                      ),
                      TextSpan(
                        text: "与",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: ScreenUtil.getInstance().getSp(11),
                        ),
                      ),
                      TextSpan(
                        text: "《远大教育隐私协议》",
                        style: TextStyle(
                          color: Color(0xFF5fc589),
                          fontSize: ScreenUtil.getInstance().getSp(11),
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          linkTo('privacy');
                        },
                      ),
                    ]
                )),
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil.getInstance().getHeightPx(58),
          ),
        ]
    );
  }

  //跳转
  void linkTo(where){
    if(where == 'education'){
      NavigatorUtil.goWebView(context, AddressUtil.getInstance().getEducation());
    }else if(where == 'privacy'){
      NavigatorUtil.goWebView(context, AddressUtil.getInstance().getPrivacy());
    }else if(where == 'wxServer'){
      NavigatorUtil.goWebView(context, AddressUtil.getInstance().getWxServer());
    }
  }

  //底部信息
  Widget _bottomInfo(){
    return new Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 0),
            alignment: AlignmentDirectional.bottomCenter,
            child: Text("注册信息须真实有效，否则礼物无法派送",
                style: TextStyle(color: Color(0xFFff6464),  fontSize: ScreenUtil.getInstance().getSp(13.41),
                )
            ),
          ),
          SizedBox(
            height: ScreenUtil.getInstance().getWidthPx(55),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 0),
            alignment: AlignmentDirectional.bottomCenter,
            child: GestureDetector(
              onTap: (){
                linkTo('wxServer');
              },
              child:Text(
              "有问题？找客服！",
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: ScreenUtil.getInstance().getSp(14.82),
                decoration: TextDecoration.underline,
              ),
            ),
            ),
          ),
          SizedBox(
            height: ScreenUtil.getInstance().getWidthPx(80),
          ),
          Container(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  child:_AgreementCheck ? new Icon(
                    Icons.check_circle,
                    color: Color(0xFF5fc589),
                    size:16.0,
                  ):new Icon(
                    Icons.radio_button_unchecked,
                    color: Color(0xFF5fc589),
                    size:16.0,
                  ),
                  onTap: () {
                    setState(() {
                      _AgreementCheck = !_AgreementCheck;
                    });
                  },
                ),
                Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: "已阅读并同意",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: ScreenUtil.getInstance().getSp(11),
                        ),
                      ),
                      TextSpan(
                        text: "《远大教育用户服务协议》",
                        style: TextStyle(
                          color: Color(0xFF5fc589),
                          fontSize: ScreenUtil.getInstance().getSp(11),
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          linkTo('education');
                        },
                      ),
                      TextSpan(
                        text: "与",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: ScreenUtil.getInstance().getSp(11),
                        ),
                      ),
                      TextSpan(
                        text: "《远大教育隐私协议》",
                        style: TextStyle(
                          color: Color(0xFF5fc589),
                          fontSize: ScreenUtil.getInstance().getSp(11),
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          linkTo('privacy');
                        },
                      ),
                    ]
                )),
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil.getInstance().getHeightPx(58),
          ),
        ]
    );
  }

  //下拉框的子类
  List<Widget> _buildItems() {
    List<Widget> list = new List();
    if(_schoolList!=null){
      for(var school in _schoolList){
        list.add(GestureDetector(
          child: Container(
            alignment: AlignmentDirectional.center,
            padding: new EdgeInsets.all(8.0),
            child: Text("${school['name']}(${school['provinceName']}${school['cityName']}${school['districtName']})", style: TextStyle(fontSize: 18.0)),
            decoration: BoxDecoration(border: (_schoolList[_schoolList.length-1]['name']) != (school['name']) ? Border(bottom: BorderSide(color: Color(0xFFc1c5c8), width: 0.5)) : Border()),
          ),
          onTap: () {
            chooseShool(school['id'],"${school['cityName']}${school['districtName']}${school['name']}");
          },
        ));
      }
    }
    return list;
  }

  //选择学校
  void chooseShool(schoolId,schollName) async{
    CommonUtils.showLoadingDialog(context, text: "请等待···");
    DataResult data = await UserDao.chooseSchool(schoolId,1);
    Navigator.pop(context);
    if(_AgreementCheck){
      setState(() {
        FocusScope.of(context).requestFocus(new FocusNode());
        _expand = true;
        _schoolId = schoolId;
        _schoolName = schollName;
        _helperText = '';
        _onTap(3);
      });
    }else if(!_AgreementCheck){
      showToast("请先同意协议！");
    }
  }
  //下拉框
  Widget _buildListView(){
    List<Widget> children = _buildItems();
    return Container(
      height: ScreenUtil.getInstance().screenHeight * 0.64,
      padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), top:ScreenUtil.getInstance().getHeightPx(350),right: ScreenUtil.getInstance().getWidthPx(42)),
      child: Card(
        color: Color(0xFFFFFFFF),
        child: Center(
          child: ListView(
            children: children,
          ),
        ),
      ),
    );
  }
  
  //输入框
  TextField _getTextField(String hintText,TextEditingController controller,String what,{bool obscureText}){
    return TextField(
      controller: controller,
      cursorColor: Color(0xFF333333),
      style: TextStyle(textBaseline:TextBaseline.alphabetic),
      keyboardType:  what=="phone"?TextInputType.phone:TextInputType.text,
      obscureText: obscureText ?? false,
      inputFormatters: what=="phone"?[LengthLimitingTextInputFormatter(11),WhitelistingTextInputFormatter.digitsOnly]:[],
      decoration: new InputDecoration(
        suffixIcon: _hasdeleteIcon
            ? IconButton(
          onPressed: () {
            setState(() {
              controller.text = "";
              _helperText = "";
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
        helperText: _helperText,
        helperStyle: TextStyle(color: Color(0xFFA94442)),
      ),
    );
  }

  void _onTap(int index) {
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
}
