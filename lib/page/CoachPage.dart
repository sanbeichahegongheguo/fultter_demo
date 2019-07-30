import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class CoachPage extends StatefulWidget{

  @override
  State<CoachPage> createState() {
    // TODO: implement createState
    return _CoachPage();
  }


}

class _CoachPage extends State<CoachPage>{
  @override
  void initState() {
    _getheaderAdvertList();
    _getfootAdvertList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
          color: Color(0xFFf0f4f7),
          child: ListView(
            children: <Widget>[
              Container(
                width:MediaQuery.of(context).size.width,
                height:ScreenUtil.getInstance().getHeightPx(311),
                child: _headerAdvert(),
              ),
              Container(
                width:MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Padding(padding: EdgeInsets.fromLTRB(ScreenUtil.getInstance().getWidthPx(20), ScreenUtil.getInstance().getHeightPx(64), ScreenUtil.getInstance().getWidthPx(20), ScreenUtil.getInstance().getHeightPx(64)),child: _mainBt(),),
              ),
              Container(
                margin: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(33)),
                color: Colors.white,
                width:MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(77)),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left:ScreenUtil.getInstance().getWidthPx(53)),
                        child:  Row(
                          children: <Widget>[
                            Container(
                              width:ScreenUtil.getInstance().getWidthPx(12),
                              height: ScreenUtil.getInstance().getHeightPx(46),
                              decoration:BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                    Radius.circular((30.0))),
                                color: Color(0xFF5fc589),
                              ),
                            ),
                            Text("  精准学习",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3) ),)
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(50),bottom:ScreenUtil.getInstance().getHeightPx(50)),
                        child:  _widgeStudy(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(ScreenUtil.getInstance().getWidthPx(50)),
                child: Container(
                  height:ScreenUtil.getInstance().getHeightPx(212),
                  child: _footAdvert(),
                ),
              )
            ],
          ),
    );
  }
  //头部广告位轮播集合
  List<Widget> _headerAdvertList = List();
  List<String> _headerImgList = ["images/coach/coach-swiper-1.png","images/coach/coach-swiper-2.png"];
  void _getheaderAdvertList() {
    for(var i = 0;i<_headerImgList.length;i++){
      _headerAdvertList.add(Image.asset(
        _headerImgList[i],
        fit: BoxFit.fitWidth,
      ));
    }
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
  //头部广告位轮播
  Widget _swiperBuilder(BuildContext context, int index) {
    return (_headerAdvertList[index]);
  }
  List _mainBtList = [
    {"imgUrl":"images/coach/btn-1.png","title":"跨越式数学王","id":1,"type":2},
    {"imgUrl":"images/coach/btn-2.png","title":"核对答案","id":2,"type":1},
    {"imgUrl":"images/coach/btn-3.png","title":"英语随身听","id":3,"type":2},
    {"imgUrl":"images/coach/btn-3.png","title":"核对答案","id":3,"type":1},
    {"imgUrl":"images/coach/btn-3.png","title":"核对答案","id":3,"type":1},
    {"imgUrl":"images/coach/btn-3.png","title":"核对答案","id":3,"type":1},
  ];
  //中部按钮
  Widget _mainBt(){
    List<Widget> btList = [];
    for(var i = 0;i<_mainBtList.length;i++){
      var positioned = _mainBtList[i]["type"] ==2 ? Positioned(
        top:0,
        right: 0,

        child:Image.asset(
          "images/coach/icon-hot.png",
          width:ScreenUtil.getInstance().getWidthPx(94),
          height:ScreenUtil.getInstance().getHeightPx(33),
        ),
      ):Text("");
      btList.add(
          Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      print("点击按钮id为 ${_mainBtList[i]["id"]}");
                      if(_mainBtList[i]["id"] == 2){
                        NavigatorUtil.goWebView(context,Address.getExerciseBookNew()).then((v){

                        });
                      }
                    },
                    child:Container(
                      width: ScreenUtil.getInstance().getWidthPx(260),
                      child: Image.asset(
                        _mainBtList[i]["imgUrl"],
                        fit: BoxFit.contain,
                        height: ScreenUtil.getInstance().getHeightPx(120),
                      ),
                    ) ,
                  ),

                  positioned
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(10)),
              ),
              Text(_mainBtList[i]["title"],style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(36 / 3),color: Color(0xFF999999)),),
            ],
          )
      );
    }
    var btmsg =Wrap(
//      spacing: ScreenUtil.getInstance().getWidthPx(100), // 主轴(水平)方向间距
      runSpacing: ScreenUtil.getInstance().getHeightPx(30), // 纵轴（垂直）方向间距
      runAlignment:WrapAlignment.center,
      alignment: _mainBtList.length>4?WrapAlignment.start:WrapAlignment.spaceAround,
      children: btList,
    );
    return btmsg;
  }

  List _studyList = [
    {"imgUrl":"images/coach/pe-1.png","id":1},
    {"imgUrl":"images/coach/pe-2.png","id":2},
    {"imgUrl":"images/coach/pe-3.png","id":3},
    {"imgUrl":"images/coach/pe-4.png","id":4},
    {"imgUrl":"images/coach/pe-3.png","id":3},
  ];
  //精准学习
  Widget _widgeStudy (){
    List<Widget> listWidge = [];
    for(var i = 0; i<_studyList.length;i++){
      listWidge.add(
        InkWell(
          onTap: (){print("点击按钮id为 ${_studyList[i]["id"]}");},
          child:Container(
            width: ScreenUtil.getInstance().getWidthPx(500),
            child: Image.asset(
              _studyList[i]["imgUrl"],
              fit: BoxFit.fitWidth,
              width:ScreenUtil.getInstance().getWidthPx(500),
            ),
          ) ,
        ),
      );
    }
    var btmsg =Wrap(
      spacing: ScreenUtil.getInstance().getWidthPx(20), // 主轴(水平)方向间距
      runSpacing: ScreenUtil.getInstance().getHeightPx(27), // 纵轴（垂直）方向间距
      runAlignment:WrapAlignment.center,
      alignment: WrapAlignment.start,
      children: listWidge,
    );
    return btmsg;
  }
  //底部广告位轮播集合
  List<Widget> _footAdvertList = List();
  List<String> _footImgList = ["images/coach/advert-bg.png","images/coach/advert-bg.png"];
  void _getfootAdvertList() {
    for(var i = 0;i<_footImgList.length;i++){
      _footAdvertList.add(Image.asset(
        _footImgList[i],
        fit: BoxFit.fitWidth,
      ));
    }
  }
  //底部广告位
  Widget _footAdvert(){
    var headMsg = Swiper(
      itemBuilder: (BuildContext context, int index) {
        return _swiperFootBuilder(context,index);
      },
      index:0,
      autoplay:false,
      onTap:(index) {
        print("点击了第:$index个");
      },
      itemCount:_footImgList.length,
      pagination: SwiperPagination(
          alignment: Alignment.bottomRight,
          builder: FractionPaginationBuilder(
            color: Colors.white,
            activeColor: Colors.white,
            fontSize: ScreenUtil.getInstance().getSp(30 / 3),
            activeFontSize:ScreenUtil.getInstance().getSp(30 / 3),
          ),
      ),
    );
    return headMsg;
  }
  //底部广告位轮播
  Widget _swiperFootBuilder(BuildContext context, int index) {
    return (_footAdvertList[index]);
  }
}
