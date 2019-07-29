import 'dart:convert';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/address.dart';
class parentReward extends StatefulWidget{
  @override
  State<parentReward> createState() {
    // TODO: implement createState
    return _parentReward();
  }
}

class _parentReward extends State<parentReward> with SingleTickerProviderStateMixin{
  //头部广告位轮播集合
  List<Widget> _headerAdvertList = List();
  List<String> _headerImgList = ["images/parent_reward/banner.png","images/parent_reward/banner.png"];
  List _hotGiftList = SpUtil.getObjectList(Config.hotGiftList)==null?[]:SpUtil.getObjectList(Config.hotGiftList);
  List _btnList = [
    {"imgUrl":"images/parent_reward/scholarshipIcon.png","name":"兑换奖学金"},
    {"imgUrl":"images/parent_reward/starDrawIcon.png","name":"星星抽奖"},
    {"imgUrl":"images/parent_reward/exchangeCardBtn.png","name":"兑换卡牌"},
  ];
  bool _showBanner = false;
  dynamic _totalStarNum = SpUtil.getString(Config.starNum)==null?'':SpUtil.getString(Config.starNum);
  @override
  void initState() {
    _getheaderAdvertList();
    _getHotGift();
    _getTotalStar();
    super.initState();
  }

  void _getheaderAdvertList() {
    for(var i = 0;i<_headerImgList.length;i++){
      _headerAdvertList.add(Image.asset(
        _headerImgList[i],
        fit: BoxFit.fitWidth,
      ));
    }
  }

  void _getTotalStar() async{
    DataResult data = await UserDao.getTotalStar();
    if(data.result){
      setState(() {
        _totalStarNum = data.data;
      });
    }else{
      ///请求失败
    }
  }

  void _getHotGift() async{
    DataResult data = await UserDao.getHotGoodsList();
    if(data.result){
      setState(() {
         _hotGiftList = data.data;
      });
    }else{
      ///请求失败
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Color(0xFFf0f4f7),
      child: ListView(
        children: <Widget>[
          Offstage(
            offstage: _showBanner,
            child: Container(
                width:MediaQuery.of(context).size.width,
                height:ScreenUtil.getInstance().getHeightPx(135),
                child: Stack(
                  children: <Widget>[
                    _headerAdvert(),
                    Container(
                      padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(8),left:ScreenUtil.getInstance().getWidthPx(10)),
                      child: GestureDetector(
                        child: Image.asset(
                          'images/parent_reward/closeIcon.png',
                          height: ScreenUtil.getInstance().getHeightPx(51),
                          width:ScreenUtil.getInstance().getWidthPx(51),
                        ),
                        onTap: (){
                          setState(() {
                            _showBanner = true;
                          });
                        },
                      )
                    ),
                  ],
                )
            ),
          ),
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
            width: 200,
            child: _btnBody(),
          ),
        ],
      ),
    );
  }


  //头部广告位轮播
  Widget _swiperBuilder(BuildContext context, int index) {
    return (_headerAdvertList[index]);
  }

  //头部广告位
  Widget _headerAdvert(){
    var headMsg = Swiper(
      itemBuilder: (BuildContext context, int index) {
        return _swiperBuilder(context,index);
      },
      index:0,
      autoplay:true,
      onTap:(index) {
        print("点击了第:$index个");
      },
      duration:500,
      itemCount:_headerImgList.length,
    );
    return headMsg;
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

              NavigatorUtil.goWebView(context, Address.GameH5Address());
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
          _hotExchangeBody(),
          Container(
            margin: EdgeInsets.only(bottom:ScreenUtil.getInstance().getHeightPx(50)),
            child: Align(
              alignment: Alignment.center,
              child: Text('更多实物兑换',style: TextStyle(
                color: Color(0xFF999999),
                decoration: TextDecoration.underline,
              ),),
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
                            child: new Text(_totalStarNum),
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
                      Container(
                        padding: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(20),top:ScreenUtil.getInstance().getHeightPx(10) ),
                        child: Text('我的礼物',
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().getSp(38 / 3),
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFFFFF)
                            )),
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
  Widget _hotExchangeBody(){
    List<Widget> giftList = [];
    for(var i = 0;i<_hotGiftList.length;i++){
      giftList.add(
        Container(
              width: ScreenUtil.getInstance().getWidthPx(300),
              height: ScreenUtil.getInstance().getHeightPx(200),
              decoration: BoxDecoration(
                border: new Border.all(color: Color(0xFFe6e6e7)),
                borderRadius: new BorderRadius.all(
                    Radius.circular((10.0))),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _hotGiftList[i]["name"].contains('奖学金')?
                  Image.asset(
                    'images/parent_reward/redPatImg.png',
                    height: ScreenUtil.getInstance().getHeightPx(120),
                    fit: BoxFit.fitHeight,
                  ):
                  Image.network(
                    _hotGiftList[i]['minPicUrl'],
                    height: ScreenUtil.getInstance().getHeightPx(120),
                    fit: BoxFit.fitHeight,
                  ),
                  Container(
                    margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(10)),
                    child: Text(_hotGiftList[i]['name'],
                      style: TextStyle(
                          color: Color(0xFF999999)
                      ),),
                  ),
                ],
              ),
            )
      );
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

  //其他按钮入口
  Widget _btnBody(){
    List<Widget> binList = [];
    for(var i = 0;i<_btnList.length;i++){
      var positioned = _btnList[i]["name"] =='星星抽奖' ? Positioned(
        top:0,
        right: 0,
        child:Image.asset(
          "images/parent_reward/hotIcon.png",
          width:ScreenUtil.getInstance().getWidthPx(113),
          height:ScreenUtil.getInstance().getHeightPx(58),
        ),
      ):Text("");
      binList.add(
          Container(
            alignment: Alignment.center,
            width: ScreenUtil.getInstance().getWidthPx(300),
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      _btnList[i]['imgUrl'],
                      height: ScreenUtil.getInstance().getHeightPx(140),
                      width: ScreenUtil.getInstance().getHeightPx(140),
                      fit: BoxFit.fitHeight,
                    ),
                    Container(
                      width: ScreenUtil.getInstance().getWidthPx(800),
                      margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(10)),
                      child: Container(
                        alignment: Alignment.center,
                        child : Text(_btnList[i]['name'],
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
      );
    }
    var btnMsg = Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(40)),
      child: Wrap(
//        spacing: ScreenUtil.getInstance().getWidthPx(40), // 主轴(水平)方向间距
        runSpacing: ScreenUtil.getInstance().getHeightPx(30), // 纵轴（垂直）方向间距
        alignment: WrapAlignment.spaceEvenly,
        children: binList,
      ),
    );
    return btnMsg;
  }
}



