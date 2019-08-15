import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/CountDown.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';

class BuildArchivesPage extends StatefulWidget {
  static final String sName = "buildArchives";
  @override
  State<StatefulWidget> createState() {
    return BuildArchivesState(0);
  }
}

class BuildArchivesState extends State<BuildArchivesPage> with SingleTickerProviderStateMixin{
  TextEditingController stuPhoneController = new TextEditingController();
  TextEditingController stuNewPhoneController = new TextEditingController();
  TextEditingController stuPwdController = new TextEditingController();
  TextEditingController codeController = new TextEditingController();
  BuildArchivesState(this._currentPageIndex) : this._pageController = new PageController(initialPage: _currentPageIndex),super();
  int _currentPageIndex = 0;
  var _pageController;
  bool _haveNextBtn = false;
  ///输入框删除按钮
  bool _hasdeleteIcon = false;
  String _helperText = "";
  bool _inputStuNextBtn = false;
  bool _sendBtn = false;
  bool _recoverTime = true;
  String _topText = '';

  Widget build(BuildContext context){
    return StoreBuilder<GSYState>(builder: (context, store) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: new IconButton(
                icon: new Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF333333),
                ),
                onPressed: () {
                }
            ),
            title: Text(
              _topText,
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
                return _checkHaveStuAccount();
              }else if(index==1){
                return _inputStuAccount();
              }else if(index==2){
                return _checkAddStu();
              }else if(index==3){
                return _bindPhone();
              }
            },
            itemCount: 4,
          ),
        ),
      );
    });
  }

  ///建立孩子学习档案
  Widget _checkHaveStuAccount(){
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(180)),
            child: Text('建立孩子学习档案',style: TextStyle(
              fontSize:ScreenUtil.getInstance().getSp(90/3),
              fontWeight:FontWeight.normal,
            ),),
          ),
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(20)),
            child: Text('获取个性化学习推荐，保存孩子成长记录',style: TextStyle(
                fontSize:ScreenUtil.getInstance().getSp(48/3),
                color: Color(0XFF999999)
            ),
          ),
          ),
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(100)),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('孩子有远大小状元学生账号吗？'),
                GestureDetector(
                  onTap: (){
                    var widgetMsg =  Column(
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil.getInstance().getHeightPx(30),
                        ),
                        Text(
                            '什么是远大小状元学生账号？', style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(54/3), color: const Color(0xFF666666))
                        ),
                        SizedBox(
                          height: ScreenUtil.getInstance().getHeightPx(50),
                        ),
                        Container(
                          padding: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(45),right:ScreenUtil.getInstance().getWidthPx(45)),
                          child: Text(
                              '远大小状元学生是远大教育推出的K12智能教育平台，拥有远大小状元学生帐号可以免费使用远大小状元学生里的学习资源，接受并完成老师布置的练习和个性化学习内容，提高学生学习兴趣与成绩。', style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(48/3), color: const Color(0xFFb3b3b3))
                          ),
                        ),
                      ],
                    );
                    CommonUtils.showEditDialog(context,widgetMsg,height: ScreenUtil.getInstance().getHeightPx(616),width: ScreenUtil.getInstance().getWidthPx(903));
                  },
                  child: Image.asset('images/register/question.png',width: 13, height: 13),
                ),
                ],
              )
          ),
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(100)),
            child: CommonUtils.buildBtn(
                '有',
                width: ScreenUtil.getInstance().getWidthPx(845),
                height: ScreenUtil.getInstance().getHeightPx(120),
                decorationColor: _haveNextBtn ? Color(0xFFf3f3f3) : Color(0xFFf7f7f7),
                splashColor:_haveNextBtn ? Color(0xFFf3f3f3) : Color(0xFFf7f7f7),
                textColor: Colors.black,
                textSize: ScreenUtil.getInstance().getSp(54/3),
                elevation: 2,
                onTap: (){
                  print('xxii');
                  _onChange(1);
                }),
          ),
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(150)),
            child: CommonUtils.buildBtn(
                '没有',
                width: ScreenUtil.getInstance().getWidthPx(845),
                height: ScreenUtil.getInstance().getHeightPx(120),
                decorationColor: _haveNextBtn ? Color(0xFFf3f3f3) : Color(0xFFf7f7f7),
                splashColor:_haveNextBtn ? Color(0xFFf3f3f3) : Color(0xFFf7f7f7),
                textColor: Colors.black,
                textSize: ScreenUtil.getInstance().getSp(54/3),
                elevation: 2,
                onTap: (){
                  NavigatorUtil.goRegester(context,index: 2);
                }),
          ),
        ],
      ),
    );
  }

  ///请输入孩子的学生账号与密码
  Widget _inputStuAccount(){
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(150)),
            child: Column(
              children: <Widget>[
                Text('请输入孩子的',style: TextStyle(
                  fontSize:ScreenUtil.getInstance().getSp(90/3),
                  fontWeight:FontWeight.normal,
                ),),
                Text('学生账号与密码',style: TextStyle(
                  fontSize:ScreenUtil.getInstance().getSp(90/3),
                  fontWeight:FontWeight.normal,
                ),),
              ],
            ),

          ),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(100)),
            child: _getTextField('您的账号/手机号',stuPhoneController,what:'phone',length:11,hasDelete:true,limteLength:true,rule:WhitelistingTextInputFormatter.digitsOnly),
          ),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(40)),
            child: _getTextField('您的密码',stuPwdController,obscureText:true,limteLength:true,length:20,rule:WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[0-9]"))),
          ),
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(40),bottom:ScreenUtil.getInstance().getHeightPx(140)),
            child: Text('忘记密码请打开《远大小状元学生》自行找回哦！',style: TextStyle(
              color: Color(0xFF999999),
              fontSize: ScreenUtil.getInstance().getSp(42/3),
              decoration: TextDecoration.underline,
            ),),
          ),
          CommonUtils.buildBtn(
              '下一步',
              width: ScreenUtil.getInstance().getWidthPx(845),
              height: ScreenUtil.getInstance().getHeightPx(130),
              decorationColor: _inputStuNextBtn ? Color(0xFF6ed699) : Color(0xFFdfdfeb),
              splashColor:_inputStuNextBtn ? Color(0xFF6ed699) : Color(0xFFdfdfeb),
              textColor: Colors.white,
              textSize: ScreenUtil.getInstance().getSp(54/3),
              elevation: 2,
              onTap: (){
                _onChange(2);
              })
        ],
      ),
    );
  }

  ///您的手机号已被以下学生账号使用
  Widget _checkAddStu(){
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(150)),
            child: Column(
              children: <Widget>[
                Text('您的手机号已',style: TextStyle(
                  fontSize:ScreenUtil.getInstance().getSp(90/3),
                  fontWeight:FontWeight.normal,
                ),),
                Text('被以下学生账号使用',style: TextStyle(
                  fontSize:ScreenUtil.getInstance().getSp(90/3),
                  fontWeight:FontWeight.normal,
                ),),
              ],
            ),

          ),
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(100),bottom:ScreenUtil.getInstance().getHeightPx(120)),
            child: Column(
              children: <Widget>[
                ClipOval(
                  child: _isNetwork(null),
                ),
                Container(
                  padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(15)),
                  child:Text('易烊千玺',style: TextStyle(color: Color(0xff333333),fontSize:ScreenUtil.getInstance().getSp(48/3) ),),
                ),
              ],
            ),
          ),
          CommonUtils.buildBtn(
              '直接添加',
              width: ScreenUtil.getInstance().getWidthPx(845),
              height: ScreenUtil.getInstance().getHeightPx(130),
              decorationColor: Color(0xFF6ed699),
              splashColor:Color(0xFF6ed699),
              textColor: Colors.white,
              textSize: ScreenUtil.getInstance().getSp(54/3),
              elevation: 2,
              onTap: (){
              }),
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(60)),
            child: GestureDetector(
              onTap: (){
                _onChange(3);
                setState(() {
                  _topText = '手机绑定';
                });
              },
              child: Text('不添加此学生 >',style: TextStyle(
                color: Color(0xFF999999),
                fontSize: ScreenUtil.getInstance().getSp(48/3),
              ),),
            ),
          ),
        ],
      )
    );
  }

  ///手机绑定
  Widget _bindPhone(){
    return new Container(
      child: new Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(60)),
            child: Column(
              children: <Widget>[
                Text('为保存珍贵的学习记录',style: TextStyle(color: Color(0xff666666),fontSize: ScreenUtil.getInstance().getSp(48/3),)),
                Text('请为孩子的账号登记手机号',style: TextStyle(color: Color(0xff666666),fontSize: ScreenUtil.getInstance().getSp(48/3),)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(80)),
            child: _getTextField('请输入手机号',stuNewPhoneController,what:'phone',length:11,hasDelete:true,limteLength:true,rule:WhitelistingTextInputFormatter.digitsOnly),
          ),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getHeightPx(50),bottom: ScreenUtil.getInstance().getHeightPx(120)),
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                _getTextField('请输入短信验证码',codeController,what:'phone',length:6,hasDelete:false,limteLength:true,rule:WhitelistingTextInputFormatter.digitsOnly),
                GestureDetector(
                  onTap: (){
//                    if(!_sendBtn){
//                      _sendNumberCode();
//                    }
                  },
                  child: Container(
                      margin: EdgeInsets.only(right:ScreenUtil.getInstance().getWidthPx(60)),
                      child: _sendBtn?
                      CountDown(dataTwo: stuNewPhoneController.text,recoverTime:_recoverTime,where: 'rePwd'):
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
          CommonUtils.buildBtn(
              '下一步',
              width: ScreenUtil.getInstance().getWidthPx(845),
              height: ScreenUtil.getInstance().getHeightPx(130),
              decorationColor: _inputStuNextBtn ? Color(0xFF6ed699) : Color(0xFFdfdfeb),
              splashColor:_inputStuNextBtn ? Color(0xFF6ed699) : Color(0xFFdfdfeb),
              textColor: Colors.white,
              textSize: ScreenUtil.getInstance().getSp(54/3),
              elevation: 2,
              onTap: (){
                _onChange(2);
              })
        ],
      ),
    );
  }

  TextField _getTextField(String hintText,TextEditingController controller,{String what,bool obscureText,int length,bool limteLength,dynamic rule,String helpText,bool hasDelete}){
    return TextField(
      controller: controller,
      cursorColor: Color(0xFF333333),
      keyboardType:  what=="phone"?TextInputType.phone:TextInputType.text,
      obscureText: obscureText ?? false,
      inputFormatters: limteLength?[LengthLimitingTextInputFormatter(length),rule]:[],
      decoration: new InputDecoration(
        suffixIcon: _hasdeleteIcon&&hasDelete
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
        fillColor:Color(0xFFf7f7f7),
        hintText: hintText,
        helperText:helpText==''?'':helpText,
        helperStyle: TextStyle(color: Color(0xFFA94442)),
      ),
    );
  }

  void _onChange(int index) {
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

  ///判断用户是否有头像
  _isNetwork(imgUrl) {
    if (imgUrl != null) {
      return CachedNetworkImage(
        imageUrl: imgUrl.toString().replaceAll("fs.k12china-local.com", "192.168.6.30:30781"),
        fit: BoxFit.cover,
        width: ScreenUtil.getInstance().getWidthPx(250),
        height: ScreenUtil.getInstance().getWidthPx(250),
      );
    } else {
      return Image(
        image: AssetImage("images/admin/tx.png"),
        fit: BoxFit.cover,
        width: ScreenUtil.getInstance().getWidthPx(250),
        height: ScreenUtil.getInstance().getWidthPx(250),
      );
    }
  }

}