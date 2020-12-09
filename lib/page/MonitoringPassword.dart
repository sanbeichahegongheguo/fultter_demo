import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:oktoast/oktoast.dart';
import '../common/net/address_util.dart';

class MonitoringPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MonitoringPassword();
  }
}

class _MonitoringPassword extends State<MonitoringPassword> {
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _confirmPasswordController = new TextEditingController();
  bool _isNew = false;
  bool _isConfirm = false;
  String _newText = " ";
  String _confirmText = " ";

  bool isCheckPassword = true;

  @override
  initState() {
    super.initState();
    _getCheckPassword();
    _newPasswordController.addListener(() {
      RegExp mobile = new RegExp(r"^[0-9]*$");
      var firstMatch = mobile.firstMatch(_newPasswordController.text);
      if (firstMatch != null && _newPasswordController.text.length == 4) {
        setState(() {
          _isNew = true;
          _newText = " ";
        });
      } else if (firstMatch == null && _newPasswordController.text.length != 4) {
        setState(() {
          _isNew = false;
          _newText = "密码只能为数字，长度为4";
        });
      } else {
        setState(() {
          _isNew = false;
        });
      }
    });

    _confirmPasswordController.addListener(() {
      if (_newPasswordController.text == _confirmPasswordController.text && _isNew) {
        setState(() {
          _isConfirm = true;
          _confirmText = " ";
        });
      } else if (_confirmPasswordController.text.length != 4 && _isNew && _newPasswordController.text != _confirmPasswordController.text) {
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
    return StoreBuilder<GSYState>(builder: (context, store) {
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("设置监护密码", style: TextStyle(color: Color(0XFFffffff))),
            backgroundColor: Color(0xFF60c589),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Color(0XFFffffff),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: new Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFf0f4f7),
              ),
              child: Column(
                children: <Widget>[_getNotify(), _getTips(), _getBtns(), _getInputs()],
              )));
    });
  }

  _getCheckPassword() async {
    var dataResult = await UserDao.getCheckPassword();
    var ext1 = dataResult["success"]["ext1"];
    setState(() {
      if (ext1 == "T") {
        isCheckPassword = true;
        print("用户已设置密码");
      } else if (ext1 == "F") {
        isCheckPassword = false;
        print("用户未设置密码");
      }
    });
  }

  _getNotify() {
    var notify = new Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil.getInstance().getHeightPx(25),
        ),
        width: double.infinity,
        color: Color(0xFFffe699),
        child: new Text(
          "已设置过密码，可清除密码重新设置",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ScreenUtil.getInstance().getSp(48 / 3),
          ),
        ));
    return !isCheckPassword ? Text("") : notify;
  }

  _getTips() {
    var tips = new Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(55), horizontal: ScreenUtil.getInstance().getWidthPx((45))),
      margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(60)),
      width: ScreenUtil.getInstance().getWidthPx((800)),
      decoration: new BoxDecoration(border: new Border.all(color: Color(0xFFd9d9d9), width: 0.5), borderRadius: new BorderRadius.all(new Radius.circular(5.0))),
      child: Text(
        "提示：远大小状元学生端的核对收录作业需要设置监护密码才能使用。",
        style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(48 / 3)),
      ),
    );
    return tips;
  }

  _getBtns() {
    var btns = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CommonUtils.buildBtn("修改密码",
            width: ScreenUtil.getInstance().getWidthPx(638),
            height: ScreenUtil.getInstance().getHeightPx(114),
            decorationColor: Color(0xFF60c589),
            textColor: Color(0xFFffffff),
            splashColor: Color(0xFF4ace7f), onTap: () {
          ApplicationDao.trafficStatistic(570);
          NavigatorUtil.goChangeGuardPassword(context).then((v) {
            _getCheckPassword();
          });
        }),
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(54),
        ),
        CommonUtils.buildBtn("清除密码",
            width: ScreenUtil.getInstance().getWidthPx(638),
            height: ScreenUtil.getInstance().getHeightPx(114),
            decorationColor: Color(0xFF60c589),
            textColor: Color(0xFFffffff),
            splashColor: Color(0xFF4ace7f), onTap: () {
          ApplicationDao.trafficStatistic(571);
          NavigatorUtil.goDelGuardPassword(context).then((v) {
            _getCheckPassword();
          });
        }),
      ],
    );

    return !isCheckPassword ? Text("") : btns;
  }

  _getInputs() {
    var inpust = new Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: ScreenUtil.getInstance().getWidthPx(70), top: ScreenUtil.getInstance().getHeightPx(20), right: ScreenUtil.getInstance().getWidthPx(70)),
          child: _getTextField("设置家长监护密码(4位数字)", _newPasswordController),
        ),
        Container(
          padding: EdgeInsets.only(
              left: ScreenUtil.getInstance().getWidthPx(80), top: ScreenUtil.getInstance().getHeightPx(20), right: ScreenUtil.getInstance().getWidthPx(70)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _newText,
              style: TextStyle(color: Color(0xFFA94442)),
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.only(
                left: ScreenUtil.getInstance().getWidthPx(70), top: ScreenUtil.getInstance().getHeightPx(20), right: ScreenUtil.getInstance().getWidthPx(70)),
            child: _getTextField("再输一次新密码（4位数字）", _confirmPasswordController)),
        Container(
          padding: EdgeInsets.only(
              left: ScreenUtil.getInstance().getWidthPx(80),
              top: ScreenUtil.getInstance().getHeightPx(20),
              right: ScreenUtil.getInstance().getWidthPx(70),
              bottom: ScreenUtil.getInstance().getHeightPx(80)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _confirmText,
              style: TextStyle(color: Color(0xFFA94442)),
            ),
          ),
        ),
        MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          onPressed: _isConfirm ? _addPassword : null,
          minWidth: ScreenUtil.getInstance().getWidthPx(521),
          height: ScreenUtil.getInstance().getHeightPx(133),
          color: Color(0xFF60c589),
          disabledColor: Colors.black26,
          child: Text(
            "确认",
            style: TextStyle(
              fontSize: ScreenUtil.getInstance().getSp(54 / 3),
              color: _isConfirm ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ],
    );

    return isCheckPassword ? Text("") : inpust;
  }

  ///添加密码
  _addPassword() async {
    var res = await UserDao.editCheckPassword(_newPasswordController.text);
    if (res["success"]["ok"] == 0) {
      showToast("设置成功");
      _getCheckPassword();
      setState(() {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _isNew = false;
        _isConfirm = false;
        _newText = " ";
        _confirmText = " ";
      });
    } else {
      showToast("设置失败");
    }
  }

  TextFormField _getTextField(String hintText, TextEditingController controller, {GlobalKey key}) {
    return TextFormField(
      key: key,
      keyboardType: TextInputType.phone,
      obscureText: true,
      controller: controller,
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black, textBaseline: TextBaseline.alphabetic),
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

  _goParentInfo() {
    NavigatorUtil.goWebView(context, AddressUtil.getInstance().getInfoPage(), router: "parentInfo");
  }
}
