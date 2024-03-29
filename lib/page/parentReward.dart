import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/bloc/AdBloc.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/BannerUtil.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/Adver.dart';
import 'package:flutter_start/models/ConvertGoods.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:redux/redux.dart';

///家长奖励页面
class ParentReward extends StatefulWidget {
  static const String sName = "parentReward";
  @override
  State<ParentReward> createState() {
    // TODO: implement createState
    return _ParentReward();
  }
}

class _ParentReward extends State<ParentReward>
    with
        AutomaticKeepAliveClientMixin<ParentReward>,
        SingleTickerProviderStateMixin {
  HomeBloc bloc;

  @override
  void initState() {
    print("_ParentReward initState");
    bloc = BlocProvider.of<HomeBloc>(context);
    bloc.parentRewardBloc.getTotalStar();
    bloc.parentRewardBloc.getHotGift();
    bloc.parentModuleBloc.getParentBottomModule();
    bloc.parentRewardBloc.getParentTopModule();
    // bloc.parentModuleBloc.getParentTopModule();
    bloc.adBloc.getBanner();
    if (Platform.isIOS) {
      bloc.parentRewardBloc.showBanner(true);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('_ParentReward build');
    Store<GSYState> store = StoreProvider.of(context);
    return Container(
      color: Color(0xFFf0f4f7),
      child: ListView(
        children: <Widget>[
          (store.state.application.showBanner == 1 &&
                  store.state.application.showRewardBanner == 1)
              ? StreamBuilder<bool>(
                  stream: bloc.parentRewardBloc.parentShowBannerStream,
                  initialData: true,
                  builder: (context, AsyncSnapshot<bool> show) {
                    return Offstage(
                      offstage: !show.data,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: ScreenUtil.getInstance().getHeightPx(135),
                        child: StreamBuilder<Adver>(
                            stream: bloc.adBloc.adverStream,
                            builder: (context, AsyncSnapshot<Adver> snapshot) {
                              return Stack(
                                children: <Widget>[
                                  snapshot.data != null
                                      ? BannerUtil.buildMyBanner(
                                          context, snapshot.data)
                                      : BannerUtil.buildBanner(
                                          AdBloc.adChannelMap,
                                          ParentReward.sName,
                                          bloc: bloc.parentRewardBloc),
                                  snapshot.data != null
                                      ? Container(
                                          alignment:
                                              AlignmentDirectional(0.91, -0.5),
                                          child: GestureDetector(
                                            child: Image.asset(
                                              'images/parent_reward/closeIcon.png',
                                              width: ScreenUtil.getInstance()
                                                  .getWidthPx(51),
                                            ),
                                            onTap: () {
                                              if (snapshot.data != null) {
                                                BannerUtil.sendData(
                                                    snapshot.data,
                                                    BannerUtil
                                                        .BANNER_SKIP_ADVERT);
                                              }
                                              bloc.parentRewardBloc
                                                  .showBanner(false);
                                            },
                                          ))
                                      : Container(),
                                ],
                              );
                            }),
                      ),
                    );
                  },
                )
              : Container(),
          Container(
            color: Color(0xFFFFFFFF),
            child: StreamBuilder<List<Module>>(
                stream: bloc.parentRewardBloc.moduleStream,
                builder: (context, AsyncSnapshot<List<Module>> snapshot) {
                  return _getExerciseWidget(snapshot.data);
                }),
          ),
          Container(
            margin:
                EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(30)),
            color: Color(0xFFFFFFFF),
            child: _hotExchange(),
          ),
          StreamBuilder<List<Module>>(
            stream: bloc.parentModuleBloc.moduleStream,
            builder: (context, AsyncSnapshot<List<Module>> snapshot) {
              return _btnBody(snapshot.data);
            },
          ),
        ],
      ),
    );
  }

  ///每日练习
  Widget _getExerciseWidget(List<Module> data) {
    print("===========================");
    print("每日练习========>$data");
    print("===========================");
    if (data == null) {
      return Container();
    }
    if (data.length == 0) {
      return Container();
    }

    List<Widget> _icon = [];
    for (int i = 0; i < data.length; i++) {
      _icon.add(_getIconText(
        data[i].iconUrl,
        data[i].name,
        data[i].openType,
        data[i].targetUrl,
        eventId: data[i].eventId,
      ));
    }
    return Container(
      padding: new EdgeInsets.symmetric(
          vertical: ScreenUtil.getInstance().getHeightPx(48)),
      margin: new EdgeInsets.symmetric(
          horizontal: ScreenUtil.getInstance().getWidthPx(56)),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "每日练习",
                  style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(48 / 3),
                  ),
                ),
                TextSpan(
                  text: "（做任务拿星星奖励）",
                  style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(36 / 3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: new EdgeInsets.only(
              top: ScreenUtil.getInstance().getHeightPx(35),
            ),
            child: new Wrap(
              direction: Axis.horizontal,
              runSpacing: 10, // 纵轴（垂直）方向间距
              children: _icon,
            ),
          )
        ],
      ),
    );
  }

  ///图标加文字上下居中Widget
  Widget _getIconText(String icon, String text, int openType, String targetUrl,
      {eventId = 0}) {
    return GestureDetector(
      onTap: () {
        if (eventId != 0) {
          ApplicationDao.trafficStatistic(eventId);
        }
        NavigatorUtil.goWebView(context, targetUrl, openType: openType)
            .then((v) {
          bloc.parentRewardBloc.getTotalStar();
        });
      },
      child: new Container(
        width: (ScreenUtil.getInstance().screenWidth -
                ScreenUtil.getInstance().getWidthPx(112)) /
            3,
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: icon,
              height: ScreenUtil.getInstance().getHeightPx(144),
              width: ScreenUtil.getInstance().getHeightPx(144),
            ),
            Container(
              padding: new EdgeInsets.only(
                top: ScreenUtil.getInstance().getHeightPx(15),
              ),
              child: Text(
                text,
                style: TextStyle(
                    color: Color(0XFF999999),
                    fontSize: ScreenUtil.getInstance().getSp(48 / 4)),
              ),
            )
          ],
        ),
      ),
    );
  }

  //百万答题，天神传说
  Widget _activity() {
    return Container(
      margin: EdgeInsets.only(
          top: ScreenUtil.getInstance().getHeightPx(20),
          bottom: ScreenUtil.getInstance().getHeightPx(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Image.asset(
              'images/parent_reward/millionsBtn.png',
              height: ScreenUtil.getInstance().getHeightPx(318),
              width: ScreenUtil.getInstance().getWidthPx(515),
            ),
            onTap: () {
              ApplicationDao.trafficStatistic(45);
              NavigatorUtil.goWebView(
                      context, AddressUtil.getInstance().MillionH5Address())
                  .then((v) {
                bloc.parentRewardBloc.getTotalStar();
              });
            },
          ),
          GestureDetector(
            child: Image.asset(
              'images/parent_reward/cardGameBtn.png',
              height: ScreenUtil.getInstance().getHeightPx(318),
              width: ScreenUtil.getInstance().getWidthPx(515),
            ),
            onTap: () {
              ApplicationDao.trafficStatistic(240);
              NavigatorUtil.goWebView(
                      context, AddressUtil.getInstance().GameH5Address())
                  .then((v) {
                bloc.parentRewardBloc.getTotalStar();
              });
            },
          ),
        ],
      ),
    );
  }

  //热门兑换
  Widget _hotExchange() {
    return Container(
      child: Column(
        children: <Widget>[
          _hotExchangeTitle(),
          StreamBuilder<List<ConvertGoods>>(
              stream: bloc.parentRewardBloc.convertGoodsStream,
              builder: (context, AsyncSnapshot<List<ConvertGoods>> snapshot) {
                return _hotExchangeBody(snapshot.data);
              }),
          GestureDetector(
            onTap: () {
              ApplicationDao.trafficStatistic(311);
              NavigatorUtil.goWebView(
                      context, AddressUtil.getInstance().StarMallAddress(),
                      router: 'moreGift')
                  .then((v) {
                bloc.parentRewardBloc.getTotalStar();
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                  bottom: ScreenUtil.getInstance().getHeightPx(50)),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '更多实物兑换',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //热门兑换头部
  Widget _hotExchangeTitle() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            flex: 2,
            child: Container(
                padding: EdgeInsets.only(
                    left: ScreenUtil.getInstance().getWidthPx(25)),
                child: GestureDetector(
                  onTap: () {
                    ApplicationDao.trafficStatistic(308);
                    NavigatorUtil.goWebView(
                            context, AddressUtil.getInstance().getInfoPage(),
                            router: 'starRecord')
                        .then((v) {
                      bloc.parentRewardBloc.getTotalStar();
                    });
                  },
                  child: Stack(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenUtil.getInstance().getWidthPx(25),
                            top: ScreenUtil.getInstance().getHeightPx(5)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            color: Color(0xFFf0f4f7),
                            width: ScreenUtil.getInstance().getWidthPx(280),
                            height: ScreenUtil.getInstance().getHeightPx(65),
                            child: StreamBuilder<String>(
                                stream: bloc.parentRewardBloc.starNumStream,
                                builder:
                                    (context, AsyncSnapshot<String> snapshot) {
                                  return Text(snapshot.data ?? "");
                                }),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      Image.asset(
                        'images/parent_reward/starIcon.png',
                        height: ScreenUtil.getInstance().getHeightPx(71),
                        width: ScreenUtil.getInstance().getWidthPx(74),
                      ),
                    ],
                  ),
                ))),
        Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: Text('热门兑换',
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(48 / 3))),
            )),
        Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(
                  left: ScreenUtil.getInstance().getWidthPx(60)),
              child: Stack(
                children: <Widget>[
                  Image.asset(
                    'images/parent_reward/myGiftBtn.png',
                    height: ScreenUtil.getInstance().getHeightPx(75),
                    width: ScreenUtil.getInstance().getWidthPx(180),
                    fit: BoxFit.fitWidth,
                  ),
                  GestureDetector(
                    onTap: () {
                      ApplicationDao.trafficStatistic(309);
                      NavigatorUtil.goWebView(context,
                              AddressUtil.getInstance().StarMallAddress())
                          .then((v) {
                        bloc.parentRewardBloc.getTotalStar();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          left: ScreenUtil.getInstance().getWidthPx(20),
                          top: ScreenUtil.getInstance().getHeightPx(10)),
                      child: Text('我的礼物',
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().getSp(38 / 3),
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFFFFF))),
                    ),
                  ),
                ],
              ),
            ))
      ],
    ));
  }

  //热门兑换礼物
  Widget _hotExchangeBody(List<ConvertGoods> data) {
    List<Widget> giftList = [];
    if (null != data) {
      for (var i = 0; i < data.length; i++) {
        giftList.add(Container(
            width: ScreenUtil.getInstance().getWidthPx(300),
            height: ScreenUtil.getInstance().getHeightPx(200),
            decoration: BoxDecoration(
              border: new Border.all(color: Color(0xFFe6e6e7)),
              borderRadius: new BorderRadius.all(Radius.circular((10.0))),
            ),
            child: GestureDetector(
              onTap: () {
                NavigatorUtil.goWebView(context, data[i].convertUrl).then((v) {
                  bloc.parentRewardBloc.getTotalStar();
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  data[i].name.contains('奖学金')
                      ? Image.asset(
                          'images/parent_reward/redPatImg.png',
                          height: ScreenUtil.getInstance().getHeightPx(120),
                          fit: BoxFit.fitHeight,
                        )
                      : CachedNetworkImage(
                          imageUrl: data[i].minPicUrl,
                          height: ScreenUtil.getInstance().getHeightPx(120),
                          fit: BoxFit.fitHeight,
                        ),
                  Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil.getInstance().getHeightPx(10)),
                    child: Text(
                      data[i].name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ],
              ),
            )));
      }
    }
    var giftmsg = Container(
      margin: EdgeInsets.symmetric(
          vertical: ScreenUtil.getInstance().getHeightPx(40)),
      child: Wrap(
        spacing: ScreenUtil.getInstance().getWidthPx(40), // 主轴(水平)方向间距
        runSpacing: ScreenUtil.getInstance().getHeightPx(30), // 纵轴（垂直）方向间距
        runAlignment: WrapAlignment.center,
        children: giftList,
      ),
    );
    return giftmsg;
  }

  //底部栏目模块按钮入口
  Widget _btnBody(List<Module> data) {
    print('底部栏目模块按钮入口');
    List<Widget> binList = [];
    if (null != data) {
      for (var i = 0; i < data.length; i++) {
        var positioned = data[i].status != ''
            ? Positioned(
                top: 0,
                right: 0,
                child: Container(
                    child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Image.asset(
                      "images/parent_reward/hotIcon.png",
                      width: ScreenUtil.getInstance().getWidthPx(113),
                      height: ScreenUtil.getInstance().getHeightPx(58),
                    ),
                    Text(
                      data[i].status,
                      style: TextStyle(color: Color(0xFFFFFFFF)),
                    ),
                  ],
                )),
              )
            : Text("");
        binList.add(Container(
            alignment: Alignment.center,
            width: (ScreenUtil.getInstance().screenWidth -
                    ScreenUtil.getInstance().getWidthPx(180)) /
                3,
            child: GestureDetector(
              onTap: () {
                if (data[i].eventId != 0) {
                  ApplicationDao.trafficStatistic(data[i].eventId);
                }
                NavigatorUtil.goWebView(context, data[i].targetUrl,
                        openType: data[i].openType)
                    .then((v) {
                  bloc.parentRewardBloc.getTotalStar();
                });
              },
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: data[i].iconUrl,
                        height: ScreenUtil.getInstance().getHeightPx(140),
                        width: ScreenUtil.getInstance().getHeightPx(140),
                        fit: BoxFit.fitHeight,
                      ),
                      Container(
                        width: ScreenUtil.getInstance().getWidthPx(800),
                        margin: EdgeInsets.only(
                            top: ScreenUtil.getInstance().getHeightPx(10)),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            data[i].name,
                            style: TextStyle(color: Color(0xFF999999)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  positioned
                ],
              ),
            )));
      }
    }
    var btnMsg = Container(
      margin: EdgeInsets.symmetric(
          vertical: ScreenUtil.getInstance().getHeightPx(40),
          horizontal: ScreenUtil.getInstance().getWidthPx(36)),
      child: Wrap(
        runSpacing: ScreenUtil.getInstance().getHeightPx(30), // 纵轴（垂直）方向间距
        spacing: ScreenUtil.getInstance().getWidthPx(30), // 主轴(水平)方向间距
        children: binList,
      ),
    );
    return btnMsg;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => Platform.isAndroid;
}
