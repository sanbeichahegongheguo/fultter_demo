import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/bloc/AdBloc.dart';
import 'package:flutter_start/bloc/BlocBase.dart';
import 'package:flutter_start/bloc/HomeBloc.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/Adver.dart';
import 'package:flutter_start/models/ConvertGoods.dart';
import 'package:flutter_start/models/Module.dart';
import 'package:redux/redux.dart';
///家长奖励页面
class ParentReward extends StatefulWidget{
  static const String sName = "parentReward";
  @override
  State<ParentReward> createState() {
    // TODO: implement createState
    return _ParentReward();
  }
}

class _ParentReward extends State<ParentReward> with AutomaticKeepAliveClientMixin<ParentReward>, SingleTickerProviderStateMixin{

  HomeBloc bloc;
  List _btnList = [
    {"imgUrl":"images/parent_reward/scholarshipIcon.png","name":"兑换奖学金"},
    {"imgUrl":"images/parent_reward/starDrawIcon.png","name":"星星抽奖"},
    {"imgUrl":"images/parent_reward/exchangeCardBtn.png","name":"兑换卡牌"},
  ];
  bool _showBanner = true;

  @override
  void initState() {
    print("_ParentReward initState");
    bloc =  BlocProvider.of<HomeBloc>(context);
    bloc.parentRewardBloc.getTotalStar();
    bloc.parentRewardBloc.getHotGift();
    bloc.parentModuleBloc.getParentBottomModule();
    bloc.adBloc.getBanner();
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
          (store.state.application.showBanner==1&&store.state.application.showRewardBanner==1)?StreamBuilder<bool>(
            stream: bloc.parentRewardBloc.parentShowBannerStream,
            initialData: true,
            builder: (context,AsyncSnapshot<bool> show){
              return  Offstage(
                offstage: !show.data,
                child: Container(
                    width:MediaQuery.of(context).size.width,
                    height:ScreenUtil.getInstance().getHeightPx(135),
                    child: Stack(
                      children: <Widget>[
                        StreamBuilder<Adver>(
                            stream: bloc.adBloc.adverStream,
                            builder: (context, AsyncSnapshot<Adver> snapshot){
                              return snapshot.data!=null?CommonUtils.buildMyBanner(context,snapshot.data):CommonUtils.buildBanner(AdBloc.adChannelMap,ParentReward.sName);
                            }
                        ),
                        Container(
                            alignment:AlignmentDirectional(0.91, -0.5),
                            child: GestureDetector(
                              child: Image.asset(
                                'images/parent_reward/closeIcon.png',
                                width:ScreenUtil.getInstance().getWidthPx(51),
                              ),
                              onTap: (){
                                bloc.parentRewardBloc.showBanner(false);
                              },
                            )
                        ),
                      ],
                    )
                ),
              );
            },
          ):Container(),
          Container(
            color: Color(0xFFFFFFFF),
            child: _activity(),
          ),
          Container(
            margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(30)),
            color: Color(0xFFFFFFFF),
            child: _hotExchange(),
          ),
          Container(
            child:StreamBuilder<List<Module>>(
                stream: bloc.parentModuleBloc.moduleStream,
                builder: (context, AsyncSnapshot<List<Module>> snapshot){
                  return  _btnBody(snapshot.data);
                }),
//            _btnBody(),
          ),
        ],
      ),
    );
  }



  //百万答题，天神传说
  Widget _activity(){
    return Container(
      margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(20),bottom:ScreenUtil.getInstance().getHeightPx(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Image.asset(
              'images/parent_reward/millionsBtn.png',
              height: ScreenUtil.getInstance().getHeightPx(318),
              width:ScreenUtil.getInstance().getWidthPx(515),
            ),
            onTap: (){
              NavigatorUtil.goWebView(context, Address.MillionH5Address());
            },
          ),
          GestureDetector(
            child: Image.asset(
              'images/parent_reward/cardGameBtn.png',
              height: ScreenUtil.getInstance().getHeightPx(318),
              width:ScreenUtil.getInstance().getWidthPx(515),
            ),
            onTap: (){
              NavigatorUtil.goWebView(context, Address.GameH5Address());
            },
          ),
        ],
      ),
    );
  }

  //热门兑换
  Widget _hotExchange(){
    return Container(
      child: Column(
        children: <Widget>[
          _hotExchangeTitle(),
          StreamBuilder<List<ConvertGoods>>(
              stream: bloc.parentRewardBloc.convertGoodsStream,
              builder: (context, AsyncSnapshot<List<ConvertGoods>> snapshot){
                return  _hotExchangeBody(snapshot.data);
              }),
          GestureDetector(
            onTap: (){
              NavigatorUtil.goWebView(context,Address.StarMallAddress(),router:'moreGift').then((v){});
            },
            child: Container(
              margin: EdgeInsets.only(bottom:ScreenUtil.getInstance().getHeightPx(50)),
              child: Align(
                alignment: Alignment.center,
                child: Text('更多实物兑换',style: TextStyle(
                  color: Color(0xFF999999),
                  decoration: TextDecoration.underline,
                ),),
              ),
            ),
          ),

        ],
      ),
    );
  }

  //热门兑换头部
  Widget _hotExchangeTitle(){
    return Container(
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(25)),
                  child: GestureDetector(
                    onTap: (){
                      NavigatorUtil.goWebView(context,Address.getInfoPage(),router:'starRecord').then((v){});
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(25),top:ScreenUtil.getInstance().getHeightPx(5)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              color: Color(0xFFf0f4f7),
                              width: ScreenUtil.getInstance().getWidthPx(280),
                              height:ScreenUtil.getInstance().getHeightPx(65),
                              child: StreamBuilder<String>(
                                  stream: bloc.parentRewardBloc.starNumStream,
                                  builder: (context, AsyncSnapshot<String> snapshot){
                                    return Text(snapshot.data??"");
                                  }),
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                        Image.asset(
                          'images/parent_reward/starIcon.png',
                          height: ScreenUtil.getInstance().getHeightPx(71),
                          width:ScreenUtil.getInstance().getWidthPx(74),
                        ),
                      ],
                    ),
                  )
                )
            ),
            Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  child:Text('热门兑换', style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(48 / 3))),
                )
            ),
            Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(60)),
                  child:  Stack(
                    children: <Widget>[
                      Image.asset(
                        'images/parent_reward/myGiftBtn.png',
                        height: ScreenUtil.getInstance().getHeightPx(75),
                        width:ScreenUtil.getInstance().getWidthPx(180),
                        fit: BoxFit.fitWidth,
                      ),
                      GestureDetector(
                        onTap: (){
                          NavigatorUtil.goWebView(context,Address.StarMallAddress()).then((v){});
                        },
                        child: Container(
                          padding: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(20),top:ScreenUtil.getInstance().getHeightPx(10) ),
                          child: Text('我的礼物',
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().getSp(38 / 3),
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFFFFF)
                              )),
                        ),
                      ),
                    ],
                  ),
                )
            )
          ],
        )
    );
  }

  //热门兑换礼物
  Widget _hotExchangeBody(List<ConvertGoods> data){
    List<Widget> giftList = [];
    if (null!=data){
      for(var i = 0;i<data.length;i++){
        giftList.add(
            Container(
              width: ScreenUtil.getInstance().getWidthPx(300),
              height: ScreenUtil.getInstance().getHeightPx(200),
              decoration: BoxDecoration(
                border: new Border.all(color: Color(0xFFe6e6e7)),
                borderRadius: new BorderRadius.all(
                    Radius.circular((10.0))),
              ),
              child: GestureDetector(
                onTap: (){
                  NavigatorUtil.goWebView(context, data[i].convertUrl);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    data[i].name.contains('奖学金')?
                    Image.asset(
                      'images/parent_reward/redPatImg.png',
                      height: ScreenUtil.getInstance().getHeightPx(120),
                      fit: BoxFit.fitHeight,
                    ):
                    CachedNetworkImage(
                      imageUrl:data[i].minPicUrl,
                      height: ScreenUtil.getInstance().getHeightPx(120),
                      fit: BoxFit.fitHeight,
                    ),
                    Container(
                      margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(10)),
                      child: Text(data[i].name,
                        style: TextStyle(
                            color: Color(0xFF999999)
                        ),),
                    ),
                  ],
                ),
              )
            )
        );
      }
    }
    var giftmsg = Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(40)),
      child: Wrap(
        spacing: ScreenUtil.getInstance().getWidthPx(40), // 主轴(水平)方向间距
        runSpacing: ScreenUtil.getInstance().getHeightPx(30), // 纵轴（垂直）方向间距
        runAlignment:WrapAlignment.center,
        children: giftList,
      ),
    );
    return giftmsg;
  }

  //底部栏目模块按钮入口
  Widget _btnBody(List<Module> data){
    print('底部栏目模块按钮入口');
    List<Widget> binList = [];
    if(null!=data){
      for(var i = 0;i<data.length;i++){
        var positioned = data[i].status!='' ? Positioned(
          top:0,
          right: 0,
          child:Container(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset(
                  "images/parent_reward/hotIcon.png",
                  width:ScreenUtil.getInstance().getWidthPx(113),
                  height:ScreenUtil.getInstance().getHeightPx(58),
                ),
                Text(data[i].status,style: TextStyle(
                  color: Color(0xFFFFFFFF)
                ),),
              ],
            )
            ),
          )
          :Text("");
        binList.add(
            Container(
              alignment: Alignment.center,
              width: ScreenUtil.getInstance().getWidthPx(300),
              child: GestureDetector(
                onTap: (){
                  NavigatorUtil.goWebView(context,data[i].targetUrl).then((v){});
                },
                child: Stack(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl:data[i].iconUrl,
                          height: ScreenUtil.getInstance().getHeightPx(140),
                          width: ScreenUtil.getInstance().getHeightPx(140),
                          fit: BoxFit.fitHeight,
                        ),
                        Container(
                          width: ScreenUtil.getInstance().getWidthPx(800),
                          margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(10)),
                          child: Container(
                            alignment: Alignment.center,
                            child : Text(data[i].name,
                              style: TextStyle(
                                  color: Color(0xFF999999)
                              ),),
                          ),
                        ),
                      ],
                    ),
                    positioned
                  ],
                ),
              )
            )
        );
      }
    }
    var btnMsg = Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(40)),
      child: Wrap(
        runSpacing: ScreenUtil.getInstance().getHeightPx(30), // 纵轴（垂直）方向间距
        alignment: WrapAlignment.spaceEvenly,
        children: binList,
      ),
    );
    return btnMsg;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}



