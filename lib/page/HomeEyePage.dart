//用来处理Home页面护眼的功能
import 'dart:async';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/dao/EyeDao.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:oktoast/oktoast.dart';

class HomeEyePage extends StatefulWidget{
  static const String sName = "HomeEyePage";
  @override
  State<HomeEyePage> createState() {
    // TODO: implement createState
    return _HomeEyePage();
  }
}

class _HomeEyePage extends State<HomeEyePage> with AutomaticKeepAliveClientMixin<HomeEyePage>, SingleTickerProviderStateMixin, WidgetsBindingObserver{

  //护眼图标初始位置
  double xPosition = ScreenUtil.getInstance().screenWidth -
      ScreenUtil.getInstance().getWidthPx(136);
  double yPosition = ScreenUtil.getInstance().screenHeight * 0.5;
  bool eyeShow = true;
  double _opacity = 0.0;  // 弹窗渐变
  bool _eyeFatigueShow = true; //眼睛疲劳弹窗
  double _eyeFatigueOpacity = 0.0;  // 眼睛疲劳弹窗渐变
  bool  _overtimeShow = true; // 加时弹窗
  double  _overtimeOpacity = 0.0; // 加时弹窗渐变
  Timer _countdownTimer;  // 计时器：用户每分钟发送一次存储请求
  int countTime = 0;
  int leaveTime = 0;
  String needTime = '00:00'; //需要什么时候才进来app
  bool _delayTarget = false; //是否是延时的时间
  bool _appBack = false; //app是否在后台

  String overTimeStart = '本次加时学习';
  String overTimeEnd = '分钟！为了您的眼睛健康，请注意您的眼睛休息！';

  String normalStart = '为了您的眼睛健康，每次连续上线学习不要超过';
  String normalEnd = '分钟哦！';

  Map<String, String> _times = {
    "normal": '0',
    "really": '0'
  };  //时间统一存储

  @override
  void initState() {
    print("_HomeEyePage initState");
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    // 获取数据
    getMountData();
  }
  
  void getMountData(){

    _getEyeshiieldTime();
    _getStudyTime();
  }

  // 获取用户的护眼信息，用于退出登录重新回来的计时
  void _getLastUserTime(){
    print('开始获取数据' +  SpUtil.getString(Config.Leave_Time));
    var leaveTimeUser = SpUtil.getString(Config.Leave_Time);
    var user = SpUtil.getObject(Config.LOGIN_USER);
    var uid;
    if (user!=null){
      uid = user["userId"];
    }
    if(leaveTimeUser!=null && leaveTimeUser.contains('_')){
      // 判断是否是同个用户
      print(leaveTimeUser.split('_')[0]);
      if(uid.toString() == leaveTimeUser.split('_')[0]){
        print('同个用户,进行退出后最后的值的赋值');
        // 开始计算用户退出的时长为多少
        var currentTime = (new DateTime.now().millisecondsSinceEpoch).toString();
        var diffTime = int.parse(currentTime) - int.parse(leaveTimeUser.split('_')[2]);
        // 如果大于5分钟，则重新计时
        print('差值时间' + diffTime.toString());
        if(diffTime > 300000){
          setState(() {
            countTime = 0;
          });
        }else{
          setState(() {
            countTime = int.parse(leaveTimeUser.split('_')[1]);
          });
        }
        print('赋值成功'+ countTime.toString());
      }else{
        print('用户不同');
      }
    }else{
      print('没有任何数据，不进行操作');
    }
  }

  void _getEyeshiieldTime() async {
    // 假如是延时的时间，则不进行重置
    if(_delayTarget){
      return;
    }
    var res = await EyeDao.getEyeshiieldTime();
    if (res != null && res != "" && res["success"]) {
      // 点击，出现护眼弹框
      setState(() {
        // 如果用户突然重新设置了时间，则重新开始计时
        if(res["data"] != _times["normal"]){
          countTime = 0;
        }
        if(res["data"] != ''){
          _times["normal"] = res["data"];
          _times["really"] = res["data"];
        }else{
          // 如果用户没有设置护眼时间，则默认60分钟
          _times["normal"] = '60';
          _times["really"] = '60';
        }
      });
    }
  }

  void _getStudyTime() async {
    var res = await EyeDao.getStudyTime();
    print('请求接口数据成功');
    print(res);
    if(res["success"] && res['code'] == 200){
      // 如果是禁止的时间，则加时
      if(res['data']['msg'] == 'forbid') {
        var increase = 0 - int.parse(res['data']['result']);
        var now = new DateTime.now();
        var increaseTime = now.add(new Duration(minutes: increase));
        var splitTime = increaseTime.toString().split(' ')[1].split('.')[0].split(':');
        setState(() {
          needTime = splitTime[0] + ':' + splitTime[1];
          _eyeFatigueOpacity = 1.0;
          _eyeFatigueShow = false;
        });
       //
      }else if(res['data']['msg'].contains('delay')){
        // 不是禁锢的时候才进行倒计时和前后台切换
        print('延时的时间');
        setState(() {
          _delayTarget = true;
          _times['really'] = res['data']['result'];
          _times["normal"] = res['data']['msg'].split(':')[1];
          print('加时时间为;'+ _times["normal"] + _times['really'] );
          // 计算出已经流逝的时间
          var _goneTime = int.parse(_times["normal"]) - int.parse(_times['really']);
          // 赋值给已经连续学习
          print('已经连续学习的时间为：'+_goneTime.toString());
          countTime = _goneTime;
          // 进行倒计时
          countEye(true);
        });
      }else{
        _getLastUserTime();
        countEye(false);
      }
    }

  }

  void _saveStudyTotalTime() async {
    var res = await EyeDao.saveStudyTotalTime();
    print('每一分钟保存一次数据');
    print(res);
  }

  void _saveForbidTime() async{
    var res = await EyeDao.saveForbidTime();
    print('禁止学习时间');
    print(res);
    _getStudyTime();
  }

  // 加时学习按钮点击
  void _addOverTime(){
    this.setState((){
      // 关闭眼睛疲劳弹窗
      _eyeFatigueOpacity = 0.0;
      _eyeFatigueShow = true;
      // 打开加时弹窗
      _overtimeOpacity = 1.0;
      _overtimeShow = false;
    });
  }

  // 加时时间的点击
  void _setOverTime(time) async{
    var res = await EyeDao.saveDelayTime(time);
    print('加时学习时间');
    print(res);
    if(res['success'] && res['code']==200){
      //关闭弹窗
      setState(() {
        _overtimeShow = true;
        _overtimeOpacity = 0.0;
      });
      showToast("加时成功");
      _getStudyTime();
    }
  }

  void countEye(tip){
    // 每一分钟调一次接口
   _countdownTimer?.cancel();
    // 如果相差的时间>5分钟，则重新开始计时，如果相差的时间小于5分钟，则不用管
    if(countTime-leaveTime > 5 && !tip){
      print('重新计时');
      countTime = 0;
    }else{
      print('继续计时');
    }
    _countdownTimer =  new Timer.periodic(new Duration(seconds: 60), (timer) {
      setState(() {
        countTime += 1;
      });
      // 如果到了规定的时间,且应用处于前台，则弹出禁锢弹窗
      if(int.parse(_times['really']) == countTime && !_appBack){
        print('到了禁锢时间，弹窗，并取消计时');
        // 发送禁锢时间
        _saveForbidTime();
        setState(() {
          _eyeFatigueOpacity = 1.0;
          _eyeFatigueShow = false;
          eyeShow = true;
          _opacity = 0.0;
        });
        _countdownTimer?.cancel();
      }else{
        // 处于后台5分钟后，不存储数据
        if(countTime-leaveTime > 5 && _appBack){
          print('处于后台五分钟，停止计时');
          _countdownTimer?.cancel();
        }else{
          _saveStudyTotalTime();
        }
      }
      print('定时器：'+countTime.toString());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("切换" + state.toString());
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed:// 应用程序可见，前台
        print('展示的时间为：'+countTime.toString() + '离开的时间：' + leaveTime.toString() + '相差的时间' + (countTime-leaveTime).toString());
        setState(() {
          _appBack = false;
          leaveTime = 0;
        });
        countEye(false);
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        //退出后台后，存储我离开的时间
        setState(() {
          leaveTime = countTime;
          _appBack = true;
        });
        print('离开的时间为'+leaveTime.toString());
        break;
      case AppLifecycleState.suspending: // 申请将暂时暂停
        break;
    }
  }

  @override
  void dispose() async{
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    //用户id + 退出的时间戳 + 目前倒计时的时长
    var user = SpUtil.getObject(Config.LOGIN_USER);
    var uid;
    var currentTime = new DateTime.now().millisecondsSinceEpoch;
    if (user!=null){
      uid = user["userId"];
    }
    await SpUtil.putString(Config.Leave_Time,uid.toString()+ '_' + countTime.toString() + '_' + currentTime.toString());
    print(uid.toString()+ '_' + countTime.toString() + currentTime.toString());
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: ScreenUtil.getInstance().screenWidth,
      height: ScreenUtil.getInstance().screenHeight,
      child: Stack(
        children: <Widget>[
          _eyeIcon(),
          _eyeMessage(),
          _eyeFatigue(),
          _overtime(),
        ],
      ),
    );
  }

  // 护眼图标
  Widget _eyeIcon(){
    return(
        Positioned(
          top: yPosition,
          left: xPosition,
          child: GestureDetector(
            child: Image.asset(
              'images/eye/eyeBg_blue.png',
              width: ScreenUtil.getInstance().getWidthPx(136),
            ),
            onPanUpdate: (tapInfo) {
              // 控制上下左右溢出的情况（控制位置）
              controlPosition(tapInfo);
            },
            onTap: () {
              // 点击，出现护眼弹框
              setState(() {
                _getEyeshiieldTime();
                _opacity = 1;
                eyeShow = false;
              });
            },
          ),
        )
    );
  }

  // 眼睛疲劳弹窗
  Widget  _eyeFatigue(){
    return StoreBuilder<GSYState>(builder: (context, store) {
      return Offstage(
        offstage: _eyeFatigueShow,
        child: Container(
          width: ScreenUtil.getInstance().screenWidth,
          height: ScreenUtil.getInstance().screenHeight,
          decoration: BoxDecoration(color: Color(0x90000000)),
          child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: _eyeFatigueOpacity,
                  child: Center(
                      child: Container(
                        width: ScreenUtil.getInstance().screenWidth * 0.8,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                padding: new EdgeInsets.all(10.0),
                                child: Column(
                                  children: <Widget>[
                                    _fontBasic('眼睛疲劳', 0xfffd5252,
                                        textWeight: FontWeight.w700),
                                    new Container(height: 5.0),
                                    Image.asset(
                                      'images/eye/qBg.png',
                                      width: ScreenUtil.getInstance().getWidthPx(312),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: ScreenUtil.getInstance().screenWidth * 0.8,
                                padding: new EdgeInsets.all(10.0),
                                child: Column(
                                  children: <Widget>[
                                    _fontBasic('温馨提示', 0xfff46f73,
                                        textWeight: FontWeight.w700),
                                    new Container(height: 10.0),
                                    _fontBasic('本次连续在线学习时间已超时，现在是强制休息时间，请您马上休息您的眼睛，并确保在', 0xff707477,
                                        textSize: 18.0,
                                        textMain: needTime,
                                        textEnd: ' (一小时)前不再进入本app学习，如需延时请点以下按钮！',
                                        textMainColor: 0xfff46f73),
                                    new Container(height: 15.0),
                                    CommonUtils.buildBtn("加时学习",
                                        width:
                                        ScreenUtil.getInstance().getWidthPx(846),
                                        height:
                                        ScreenUtil.getInstance().getHeightPx(135),
                                        onTap: () {
                                          _addOverTime();
                                        }),
                                    new Container(height: 15.0),
                                    CommonUtils.buildBtn("退出APP",
                                        width:
                                        ScreenUtil.getInstance().getWidthPx(846),
                                        height:
                                        ScreenUtil.getInstance().getHeightPx(135),
                                        decorationColor: Color(0xfffefefe),
                                        textColor: Color(0xffaaadb0),
                                        splashColor: Color(0xffd3d4d6),
                                        onTap: () {
                                          SystemNavigator.pop();
//                                          _goOut(store);
                                        }),
                                    new Container(height: 10.0),
                                  ],
                                ),
                                decoration: new BoxDecoration(
                                    color: Color(0xFFd7e7f7),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15.0),
                                      bottomRight: Radius.circular(15.0),
                                    )),
                              ),
                            ]
                        ),
                        decoration: new BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                      )
                  )
              )
          ),

        ),
      );
    });
  }

  // 护眼信息弹窗
  Widget _eyeMessage() {
    return Offstage(
      offstage: eyeShow,
      child: Container(
        width: ScreenUtil.getInstance().screenWidth,
        height: ScreenUtil.getInstance().screenHeight,
        decoration: BoxDecoration(color: Color(0x90000000)),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(milliseconds: 200),
            child: Center(
              child: Container(
                width: ScreenUtil.getInstance().screenWidth * 0.8,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        child: Image.asset(
                          'images/eye/closeBt.png',
                          width: ScreenUtil.getInstance().getWidthPx(85),
                        ),
                        onTap: () {
                          // 点击，关闭护眼弹框
                          setState(() {
                            _opacity = _opacity == 1.0 ? 0.0 : 1.0;
                            eyeShow = true;
                          });
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: new EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              _fontBasic('眼睛舒适', 0xff9acd43,
                                  textWeight: FontWeight.w700),
                              new Container(height: 5.0),
                              _fontBasic('已经连续学习', 0xffaeaeae,
                                  textSize: 18.0,
                                  textMain: countTime.toString(),
                                  textEnd: '分钟',
                                  textMainColor: 0xff9acd43),
                              new Container(height: 5.0),
                              Image.asset(
                                'images/eye/bBg.png',
                                width: ScreenUtil.getInstance().getWidthPx(312),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: ScreenUtil.getInstance().screenWidth * 0.8,
                          padding: new EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              _fontBasic('温馨提示', 0xfff46f73,
                                  textWeight: FontWeight.w700),
                              new Container(height: 10.0),
                              _fontBasic(_delayTarget ? overTimeStart : normalStart, 0xff707477,
                                  textSize: 18.0,
                                  textMain: _times["normal"].toString(),
                                  textEnd: _delayTarget ? overTimeEnd : normalEnd,
                                  textMainColor: 0xfff46f73),
                              new Container(height: 15.0),
                              CommonUtils.buildBtn("更改连续学习上限",
                                  width:
                                  ScreenUtil.getInstance().getWidthPx(846),
                                  height:
                                  ScreenUtil.getInstance().getHeightPx(135),
                                  onTap: () {
                                    _goSetEye();
                                  }),
                              new Container(height: 10.0),
                            ],
                          ),
                          decoration: new BoxDecoration(
                              color: Color(0xFFd7e7f7),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                decoration: new BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 加时弹窗
  Widget _overtime(){
    return Offstage(
      offstage: _overtimeShow,
      child: Container(
        width: ScreenUtil.getInstance().screenWidth,
        height: ScreenUtil.getInstance().screenHeight,
        decoration: BoxDecoration(color: Color(0x90000000)),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: _overtimeOpacity,
            duration: Duration(milliseconds: 200),
            child: Center(
              child: Container(
                width: ScreenUtil.getInstance().screenWidth * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(height: 10.0),
                    _fontBasic('需要加时多久？', 0xff333333),
                    new Container(height: 20.0),
                    CommonUtils.buildBtn("30分钟",
                      width:
                      ScreenUtil.getInstance().getWidthPx(646),
                      height:
                      ScreenUtil.getInstance().getHeightPx(135),
                      decorationColor: Color(0xffededed),
                      textColor: Color(0xff989898),
                      splashColor: Color(0xffd3d4d6),
                      onTap: () {
                        _setOverTime(30);
                      }),
                    new Container(height: 20.0),
                    CommonUtils.buildBtn("60分钟",
                        width:
                        ScreenUtil.getInstance().getWidthPx(646),
                        height:
                        ScreenUtil.getInstance().getHeightPx(135),
                        decorationColor: Color(0xffededed),
                        textColor: Color(0xff989898),
                        splashColor: Color(0xffd3d4d6),
                        onTap: () {
                          _setOverTime(60);
                        }),
                    new Container(height: 20.0),
                    CommonUtils.buildBtn("90分钟",
                        width:
                        ScreenUtil.getInstance().getWidthPx(646),
                        height:
                        ScreenUtil.getInstance().getHeightPx(135),
                        decorationColor: Color(0xffededed),
                        textColor: Color(0xff989898),
                        splashColor: Color(0xffd3d4d6),
                        onTap: () {
                          _setOverTime(90);
                        }),
                    new Container(height: 30.0),
                  ],
                ),
                decoration: new BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
              )
            )
          )
        )
      )
    );
  }

  // 字体
  Widget _fontBasic(String text, int textColor,
      {double textSize = 22.0,
        String textMain = '',
        String textEnd = '',
        int textMainColor,
        FontWeight textWeight = FontWeight.w400}) {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              color: Color(textColor),
              fontSize: textSize,
              fontWeight: textWeight),
          children: [
            TextSpan(text: text),
            TextSpan(
                text: textMain,
                style: textMainColor != null
                    ? TextStyle(color: Color(textMainColor))
                    : TextStyle(color: Color(textColor))),
            TextSpan(text: textEnd),
          ]),
    );
  }

  // 目前只处理y轴的控制，后续有需求再增添x轴控制
  void controlPosition(tapInfo) {
    setState(() {
      yPosition += tapInfo.delta.dy;
      // 最小限制
      if (yPosition < 45) {
        yPosition = 45;
        //最大限制
      } else if (yPosition >
          ScreenUtil.getInstance().screenHeight -
              ScreenUtil.getInstance().getWidthPx(136)) {
        yPosition = ScreenUtil.getInstance().screenHeight -
            ScreenUtil.getInstance().getWidthPx(136);
      }
    });
  }

  // 去护眼
  void _goSetEye() {
    print("去护眼");
    // 先关闭弹窗
    setState(() {
      _opacity = _opacity == 1.0 ? 0.0 : 1.0;
      eyeShow = true;
    });
    ApplicationDao.trafficStatistic(316);
    NavigatorUtil.goEyeProtectionPage(context);
  }

  // 退出账号
  Future _goOut(store) async{
    NavigatorUtil.goWelcome(context);
    showToast("退出成功");
    Future.delayed(Duration(milliseconds:500)).then((_){
      UserDao.logout(store,context);
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => Platform.isAndroid;
}