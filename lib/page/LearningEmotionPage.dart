import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
class LearningEmotionPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StatefulWidget();
  }

}

class _StatefulWidget extends State<StatefulWidget>{
  @override
  initState() {
    super.initState();
    print("进入学情");
  }
  int _studyIndex = 1;//判断内容加载
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Container(
      color: Color(0xFFf0f4f7),
      child: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            width:MediaQuery.of(context).size.width,
            child: _studymsg(),
          ),
          Padding(
            padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(54),left: ScreenUtil.getInstance().getWidthPx(63),right:ScreenUtil.getInstance().getWidthPx(63)),
            child: Wrap(
              spacing: ScreenUtil.getInstance().getWidthPx(20), // 主轴(水平)方向间距
              runSpacing: ScreenUtil.getInstance().getHeightPx(27), // 纵轴（垂直）方向间距
              runAlignment:WrapAlignment.center,
              alignment:WrapAlignment.spaceBetween,
              children: _footBt()
            ),
          ),
        ],
      ),
    );
  }

  Widget _studymsg(){
    if(_studyIndex == 0){
      //无最新作业和学习记录
      return _notWordStudy();
    }else{
      return _wordStudy();
    }
  }
  //无最新作业和学习记录
  Widget _notWordStudy(){
    var noStudyMsg = Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(172),bottom:ScreenUtil.getInstance().getHeightPx(157) ),
          child: Column(
            children: <Widget>[
              Text("您的孩子还没有",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFF333333)),),
              Text("任何学习记录和作业通知！",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFF333333))),
            ],
          ),
        ),
        Image.asset("images/study/img-q.png",fit: BoxFit.cover,height:ScreenUtil.getInstance().getHeightPx(332) ,),
        Container(
          padding: EdgeInsets.only(top:ScreenUtil.getInstance().getHeightPx(82),bottom:ScreenUtil.getInstance().getHeightPx(50) ),
          child: Text("去“远大小状元学生”做练习吧！",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(36/3),color: Color(0xFFafafaf))),
        ),
        Container(
          padding: EdgeInsets.only(bottom:ScreenUtil.getInstance().getHeightPx(117) ),
          child:  ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              decoration: new BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black12)]
              ),
              child:MaterialButton(
                onPressed: ()=>{},
                minWidth: ScreenUtil.getInstance().getWidthPx(845),
                height:ScreenUtil.getInstance().getHeightPx(133),
                color: Color(0xFFfc6061),
                child:Text("打开“远大小状元学生”",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Colors.white ),),
              ),
            ),
          )
        ),

      ],
    );
    return noStudyMsg;
  }

  //有最新作业和记录
  Widget _wordStudy(){
    var msg = Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical:ScreenUtil.getInstance().getHeightPx(36),horizontal:ScreenUtil.getInstance().getWidthPx(58)),
          width: ScreenUtil.getInstance().getWidthPx(900),
          decoration:BoxDecoration(
            border: new Border.all(width: 1.0, color: Color(0xFFe5e5e5)),
            borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
          ),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: "宋楚乔",
                        style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: ScreenUtil.getInstance().getSp(48/3)
                        ),
                      ),
                      TextSpan(
                        text: "  同学学习情况如下：",
                        style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: ScreenUtil.getInstance().getSp(36/3)
                        ),
                      ),
                    ]
                )),
              ),
              Container(
                padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(77),bottom: ScreenUtil.getInstance().getHeightPx(10)),
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Text("65",style: TextStyle(color: Color(0xFF333333), fontSize: ScreenUtil.getInstance().getSp(54/3)),),
                          Text("本学情做题",style: TextStyle(color: Color(0xFF999999), fontSize: ScreenUtil.getInstance().getSp(36/3)),),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Text("0",style: TextStyle(color: Color(0xFF333333), fontSize: ScreenUtil.getInstance().getSp(54/3)),),
                          Text("本学期错题",style: TextStyle(color: Color(0xFF999999), fontSize: ScreenUtil.getInstance().getSp(36/3)),),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Text("30:28",style: TextStyle(color: Color(0xFF333333), fontSize: ScreenUtil.getInstance().getSp(54/3)),),
                          Text("今日学习耗时",style: TextStyle(color: Color(0xFF999999), fontSize: ScreenUtil.getInstance().getSp(36/3)),),
                        ],
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        )
      ],
    );
    return msg;
  }
  List btList = [
    {"imgUrl":"images/study/icon-look-que.png","id":1,"title":"查看错题"},
    {"imgUrl":"images/study/icon-beat-que.png","id":1,"title":"错题拍拍"},
  ];
  List<Widget> _footBt(){
    List<Widget> btListMsg = [];
    for(var i = 0;i<btList.length;i++){
      btListMsg.add(
        Container(
          width: ScreenUtil.getInstance().getWidthPx(450),
          decoration:BoxDecoration(
            border: new Border.all(width: 1.0, color: Color(0xFFe5e5e5)),
            borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child:MaterialButton(
              minWidth: ScreenUtil.getInstance().getWidthPx(450),
              color: Color(0xFFffffff),
              height:ScreenUtil.getInstance().getHeightPx(215) ,
              onPressed: (){},
              child: Row(
                children: <Widget>[
                  Image.asset(btList[i]["imgUrl"],fit: BoxFit.fitWidth,height:ScreenUtil.getInstance().getHeightPx(100) ,),
                  Padding(padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(36)),child: Text(btList[i]["title"],style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF333333) ),),),
                ],
              ),
            ),
          ),
        )
      );
    }
    return btListMsg;
  }
}