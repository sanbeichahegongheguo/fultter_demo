import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/common/utils/pin_input_text_field.dart';

class RegisterPage extends StatefulWidget {
  static final String sName = "register";
  @override
  State<StatefulWidget> createState() {
    return RegisterState();
  }
}

class RegisterState extends State<RegisterPage> with SingleTickerProviderStateMixin{
  TextEditingController userPhoneController = new TextEditingController();
  bool _hasdeleteIcon = false;
  bool nextBtn = false;
  bool keyBordTarget = false;
  int _currentPageIndex = 0;
  var _pageController = new PageController(initialPage: 0);
  @override
  void initState() {
    super.initState();
    userPhoneController.addListener(() {
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
  Widget build(BuildContext context){
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
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
                print("返回首页");
                NavigatorUtil.goWelcome(context);
              }
          ),
          title: Text(
            '输入手机号',
            style: TextStyle(color: Color(0xFF333333), fontSize:ScreenUtil.getInstance().getSp(19)),)
      ),
      body: new PageView.builder(
        onPageChanged:_pageChange,
        controller: _pageController,
        physics: new NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context,int index){
          print("页码：$index");
          if(index==0){
            return new Container(
              child:  Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: ScreenUtil.getInstance().getHeightPx(45), top:ScreenUtil.getInstance().getHeightPx(130)),
                    child:Text('开始注册前，请先验证您的手机号！', style: TextStyle(color: Color(0xFFff6464), fontSize: ScreenUtil.getInstance().getSp(16.93))),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(42), right: ScreenUtil.getInstance().getWidthPx(42), top: ScreenUtil.getInstance().getWidthPx(260)),
                      child: _getTextField('请输入您的手机号',userPhoneController)
                  ),
                  Container(
                    padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(100), right: ScreenUtil.getInstance().getWidthPx(100), top: ScreenUtil.getInstance().getWidthPx(684)),
                    child: Material(
                      //带给我们Material的美丽风格美滋滋。你也多看看这个布局
//                  elevation: 10.0,
                      color: Colors.transparent,
                      shape: const StadiumBorder(),
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        onTap: () {
                          _onTap(2);
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        //来个飞溅美滋滋。
                        splashColor: nextBtn ? Color(0xFFfbd951) : Color(0xFFdfdfeb),
                        child: Ink(
                          height: ScreenUtil.getInstance().getHeightPx(120),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: nextBtn ? Color(0xFFfbd951) : Color(0xFFdfdfeb),
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
            );
          }else{

            return new Container(
              child:  Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: ScreenUtil.getInstance().getHeightPx(45), top:ScreenUtil.getInstance().getHeightPx(87)),
                    child:Text('请输入短信验证码',
                        style: TextStyle(color: Color(0xFF333333), fontSize: ScreenUtil.getInstance().getSp(20),fontWeight: FontWeight.w700)),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: ScreenUtil.getInstance().getHeightPx(45), top:ScreenUtil.getInstance().getHeightPx(155)),
                    child:Text('验证码已发送到13211227524',
                        style: TextStyle(color: Color(0xFF89898a), fontSize: ScreenUtil.getInstance().getSp(18))),
                  ),
                  Container(
                    height: ScreenUtil.getInstance().getHeightPx(420),
                    padding: EdgeInsets.only(left: ScreenUtil.getInstance().getHeightPx(45),right: ScreenUtil.getInstance().getHeightPx(45), top:ScreenUtil.getInstance().getHeightPx(310)),
                    child: PinInputTextField(),
                  ),
                ],
              ),
            );
          }
        },
        itemCount: 2,
      ),
    );
  }

  //输入框
  TextField _getTextField(String hintText,TextEditingController controller){
    return TextField(
      controller: controller,
      cursorColor: Color(0xFF333333),
      inputFormatters: controller=="userPhoneController"?[]:[LengthLimitingTextInputFormatter(11),WhitelistingTextInputFormatter.digitsOnly],
      decoration: new InputDecoration(
        suffixIcon: _hasdeleteIcon
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
      ),
    );
  }

  void _onTap(int index) {
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