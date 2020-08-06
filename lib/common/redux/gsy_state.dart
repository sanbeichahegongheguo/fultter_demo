import 'package:flutter/material.dart';
import 'package:flutter_start/common/redux/middleware/epic_middleware.dart';
import 'package:flutter_start/common/redux/user_redux.dart';
import 'package:flutter_start/models/Application.dart';
import 'package:flutter_start/models/user.dart';
import 'package:redux/redux.dart';

import 'application_redux.dart';

/**
 * Redux全局State
 * Created by guoshuyu
 * Date: 2018-07-16
 */

///全局Redux store 的对象，保存State数据
class GSYState {
  User userInfo;
  ///用户信息

  ///当前手机平台默认语言
  Locale platformLocale;

  ///版本号
  String version;
  ///关于
  Application application;

  ///构造方法
  GSYState({this.userInfo,this.application});
}

///创建 Reducer
///源码中 Reducer 是一个方法 typedef State Reducer<State>(State state, dynamic action);
///我们自定义了 appReducer 用于创建 store
GSYState appReducer(GSYState state, action) {
  return GSYState(
    ///通过 UserReducer 将 GSYState 内的 userInfo 和 action 关联在一起
    userInfo: UserReducer(state.userInfo, action),
    application:ApplicationReducer(state.application,action)
  );
}

final List<Middleware<GSYState>> middleware = [
  EpicMiddleware<GSYState>(userInfoEpic),
  UserInfoMiddleware(),
];
