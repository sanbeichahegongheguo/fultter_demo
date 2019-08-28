import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:oktoast/oktoast.dart';

class JoinClassPage extends StatefulWidget{
  @override
  State<JoinClassPage> createState() {
    return _JoinClassPage();
  }
}
class _JoinClassPage extends State<JoinClassPage>{
  TextEditingController phoneController = new TextEditingController();
  var _teacherMsg = "";
  String _realName = "";
  String _schoolName = "";
  List _classInfoList = [];
  int _currentPageIndex = 0;
  bool _hasdeleteIcon = false;
  var _pageController = new PageController(initialPage: 0);
  bool _lookup = false;
  @override
  void initState() {
    super.initState();


    phoneController.addListener((){
      print(phoneController.text);
      RegExp mobile = new RegExp(r"(0|86|17951)?(13[0-9]|15[0-35-9]|17[0678]|18[0-9]|14[57])[0-9]{8}");
      var firstMatch = mobile.firstMatch(phoneController.text);
      if(firstMatch == null && phoneController.text.length == 11){
        setState(() {
          print("请输入正确的手机号");
          showToast("请输入正确的手机号");
          _lookup = false;
        });
      }else if(firstMatch  != null && phoneController.text.length == 11){
        print("正确手机号");
        setState(() {
          _lookup = true;
        });
      }else{
        setState(() {
          _lookup = false;
        });
      }
      if(phoneController.text.length>0){
        setState(() {
          _hasdeleteIcon = true;
        });
      }
    });
  }
  Widget build(BuildContext context){
    return StoreBuilder<GSYState>(builder: (context, store) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("更换班级"),
          backgroundColor: Color(0xFFffffff),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0xFF333333),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: new PageView.builder(
            onPageChanged: _pageChange,
            controller: _pageController,
            physics: new NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context,int index){
            print(index);
             if(index == 0){
               return new Container(
                 decoration: BoxDecoration(
                   color: Color(0xFFf0f4f7),
                 ),
                 child: Column(
                     children: <Widget>[
                       Container(
                         padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(84), right: ScreenUtil.getInstance().getWidthPx(84)),
                         child: _getTextField("请输入老师的号码更换班级",phoneController),
                         margin: EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(210), 0, 0),
                       ),
                       Container(

                         child:CommonUtils.buildBtn(
                           "查找",
                           width:ScreenUtil.getInstance().getWidthPx(846),
                           height:ScreenUtil.getInstance().getHeightPx(126),
                           decorationColor: !_lookup?Colors.black12:null,
                           textColor: !_lookup?Colors.white:null,
                           onTap:_lookup?_lookupOnTap:null,
                         ),
                         margin: EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(318), 0, 0),
                       )
                     ],
                   ),
               );
             }else{
               return new Container(
                   decoration: BoxDecoration(
                     color: Color(0xFFf0f4f7),
                   ),
                   child:Column(
                     children: <Widget>[
                       Container(
                         child: Text(_schoolName,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFff6464) ),),
                         margin: EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(67), 0,ScreenUtil.getInstance().getHeightPx(28)),
                       ),
                       Text(_realName+" 老师",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFff6464) )),
                       Column(
                         children: <Widget>[
                           _getClassWidget(),
                          Container(
                            child:CommonUtils.buildBtn(
                              "更换",
                              width:ScreenUtil.getInstance().getWidthPx(846),
                              height:ScreenUtil.getInstance().getHeightPx(126),
                              decorationColor: _classId ==0?Colors.black12:null,
                              textColor: _classId ==0?Colors.white:null,
                              onTap:_classId ==0?null:(){_joinClassTap(store);},
                            ),
                            margin: EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(80), 0, 0),
                          )
                         ],
                       ),
                     ],
                   )
               );
               }
            }
        ),
      );
    });
  }
  //查询老师的班级
  void _lookupOnTap() async{
    print("查找");
    var res =  await UserDao.getTeacherClassList(phoneController.text);
    if(res !=null && res != ""){
        if(res['success']['ok'] == 0){
          setState(() {
          _classInfoList = res['success']['classInfoList'];
          _schoolName = res['success']['schoolName'];
          _realName = res['success']['realName'];
          if(_classInfoList.length >5){
            var showMsg = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "images/admin/guide.png",
                  height: ScreenUtil.getInstance().getHeightPx(421),
                  width: ScreenUtil.getInstance().getWidthPx(315),
                ),
                Padding(padding: EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(94), 0,0),child:
                Text("上下滑动查看更多",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Colors.white),),),
                Padding(padding: EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(105), 0,0),child:ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child:MaterialButton(
                    minWidth: ScreenUtil.getInstance().getWidthPx(519),
                    color: Color(0xFF6ed699),
                    height:ScreenUtil.getInstance().getHeightPx(112) ,
                    onPressed: (){Navigator.pop(context);},
                    child: Text("知道了",style: TextStyle(color:Color(0xFFffffff),),
                    ),
                  ), ),)
              ],
            );
            CommonUtils.showGuide(context,showMsg);
          }
          _onTap(1);
          });
        }else{
          showToast(jsonDecode(res.toString())['success']['message']);
        }
    }
  }
   _joinClassTap(store) async{
    print("更换班级 $_classId");
    var resSameRealName = await UserDao.checkSameRealName(_classId, store.state.userInfo.realName);
    if(resSameRealName.result){
      var res =  await UserDao.joinClass(_classId);
      if(res.result){
        showToast("更换成功");
        Navigator.pop(context);
        UserDao.getUser(isNew: true, store:store);
      }else{
        showToast("更换失败");
      }
    }else{
      showToast(resSameRealName.data);
    }
  }
  int _classId = 0;
  _getClassWidget(){
    List<Widget> _widgetList = [];
    for(var i = 0;i<_classInfoList.length;i++){
      var classMsg = Padding(padding: EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(30), 0,0),child:
          Align(
            child:MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              minWidth: ScreenUtil.getInstance().getWidthPx(600),
              color: _classId==_classInfoList[i]["id"]? Color(0xFF6ed699):Color(0xFFf1f2f6),
              disabledColor: _classId==_classInfoList[i]["id"]? Color(0xFF6ed699):Color(0xFFf1f2f6),
              height:ScreenUtil.getInstance().getHeightPx(112) ,
              onPressed: _classId==_classInfoList[i]["id"]?null:(){setState(() {_classId = _classInfoList[i]["id"];});},
              child: Text(_classInfoList[i]["name"],style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color:_classId==_classInfoList[i]["id"]? Color(0xFFffffff): Color(0xFFafafb0))),
            ),
          alignment: Alignment.center,) ,) ;
          _widgetList.add(classMsg);
    }
    var listView;
    if(_classInfoList.length>5){
      listView = Scrollbar(child: new SingleChildScrollView(child: Column(children: _widgetList,),),);
    }else{
      listView = Padding(padding: EdgeInsets.fromLTRB(0, 0, 0,ScreenUtil.getInstance().getHeightPx(30)),child:Column(children: _widgetList,));
    }
    var viewMsg = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(
                Radius.circular((10.0))),
          ),
          height:_classInfoList.length>5?ScreenUtil.getInstance().getHeightPx(800):null,
          width:ScreenUtil.getInstance().getWidthPx(900),
          margin: EdgeInsets.fromLTRB(0, ScreenUtil.getInstance().getHeightPx(73), 0,0),
          child: Padding(padding: EdgeInsets.all(ScreenUtil.getInstance().getHeightPx(10)),child:Align(alignment: Alignment.center,child: listView,),)
      );
    return viewMsg;
  }
  void _onTap(int index) {
    FocusScope.of(context).requestFocus(FocusNode());
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
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
                    _lookup = false;
                    _hasdeleteIcon = false;
                  });
                },
                icon: Icon(
                  Icons.cancel,
                  color: Color(0xFFcccccc),
                ),
        ): Text(""),
        contentPadding: EdgeInsets.all(15),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: ScreenUtil.getInstance().getSp(16)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Color(0xffffffff),
      ),
    );
  }
  void _pageChange(int index) {
    setState(() {
      if (_currentPageIndex != index) {
        _currentPageIndex = index;
      }
    });
  }
  void text(){
    _currentPageIndex++;
  }

}