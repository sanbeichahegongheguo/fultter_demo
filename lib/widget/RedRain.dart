import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientation/orientation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'StarDialog.dart';
class RedRain extends StatefulWidget {
  @override
  _RedRainState createState() => _RedRainState();
}

class _RedRainState extends State<RedRain> with TickerProviderStateMixin   {
  Animation _animation;
  final GlobalKey globalKey1 = GlobalKey();
  int _starNum = 35;
  @override
  void initState() {
    super.initState();
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
//    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
//      ..addListener(() {
//        setState(() {});
//      });
//    _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceOut);
  }
  List<AnimationController> _controllerList;
  List<Animation>  _animationList;
  List<_AnimationProvider>  _prociderList;
  List<double> leftList;
  List<int> secondList = [1000,2000,3000,3000,4100,4200,4300,5500,5800,5100,6100,7200,8000,9100,9300,10000,10100,11200,12000,13100,14100,14300,15000,16100,16200,17000,17500,18000,18100,19000,19000,20100,20200,20300,20010];
  Map<int,Object> _starMap= Map();
  List<int> completed = List();
  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    if (_prociderList==null){
      _prociderList =  List.generate(_starNum, (index) {
        return _AnimationProvider();
      });
    }
    if (_controllerList==null){
      _controllerList =  List.generate(_starNum, (index) {
        return AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
          ..addListener(() {
            _prociderList[index].notify();
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              completed.add(index);
              if (completed.length == _starNum){
                //播放完毕
                print("123123");
                Navigator.pop(context,_starMap.length);
              }
            }
          })
        ;
      });
    }
    if (_animationList==null){
      _animationList =  List.generate(_starNum, (index) {
        return _animation = Tween(begin: -100.0, end: heightScreen).chain(CurveTween(curve: Curves.linear)).animate(_controllerList[index]);
      });
    }
    if (leftList==null){
      leftList =  List.generate(_starNum, (index) {
        return Random().nextInt((widthSrcreen-100).toInt()).toDouble();
      });
    }
    var list =  List.generate(_starNum, (index) {
      return ChangeNotifierProvider.value(
          value: _prociderList[index],
         child: Consumer<_AnimationProvider>(builder: (context, model, child) {
           return Positioned(
             left:  leftList[index],
             top: _animationList[index].value,
             child: GestureDetector(
               onTap: (){
                 _starMap[index] = Object;
                 print("$index ${_starMap[index]}");
                 _prociderList[index].notify();
               },
               child:  _starMap[index]==null ? Image.asset("images/live/rainStar.png",
                 height: 100,
                 width:100,
                 alignment: Alignment.center,
               ):Container(),
             ),
           );
         }),
      );
    });
    for(int i= 0; i<_controllerList.length;i++){
      Future.delayed(Duration(milliseconds:secondList[i]),(){
        _controllerList[i].forward();
      });
    }
    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: ChangeNotifierProvider(
        create:(_) => _StatusProvider(),
        child: Container(
          color: Colors.transparent.withAlpha(10),
          key: globalKey1,
          width: widthSrcreen,
          height: heightScreen,
          child: GestureDetector(
            child: Stack(
              children:list,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controllerList?.forEach((element) {
      element?.dispose();
    });
//    _prociderList.forEach((element) {
//      element?.dispose();
//    });
  }

}

class _AnimationProvider with ChangeNotifier {
  int _type = 2 ;

  int get type => _type;

  switchType(int type) {
    _type = type;
    notifyListeners();
  }
  notify(){
    notifyListeners();
  }
}

class _StatusProvider with ChangeNotifier {
  int _type = 0 ;

  int get type => _type;

  switchType(int type) {
    _type = type;
    notifyListeners();
  }
}