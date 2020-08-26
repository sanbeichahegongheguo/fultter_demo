import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/dao/RoomDao.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/Log.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/page/RoomLandscape.dart';
import 'package:flutter_start/provider/provider.dart';
import 'package:flutter_start/widget/LiveQuesDialog.dart';
import 'package:fradio/fradio.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

class LiveQuesWidget extends StatefulWidget {
  @override
  _LiveQuesWidgetState createState() => _LiveQuesWidgetState();
}

class _LiveQuesWidgetState extends State<LiveQuesWidget> {
  String tag = "LiveQuesWidget";

  ///选择题
  var _selBtnName = ["A", "B", "C", "D", "E", "F"];

  @override
  Widget build(BuildContext context) {
    List groupValueList = List.generate(6, (index) => 0);
    return Consumer<RoomSelProvider>(builder: (context, model, child) {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      return model.isShow
          ? Align(
              alignment: Alignment(0.11, 0.9),
              child: Stack(
                alignment: Alignment(0.0, -2.1),
                children: <Widget>[
                  Container(
                      width: model.op != null && model.op.length == 2 ? ScreenUtil.getInstance().getWidthPx(400) : ScreenUtil.getInstance().getWidthPx(580),
                      height: ScreenUtil.getInstance().getWidthPx(100),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.all(Radius.circular(50.0)),
                        border: new Border.all(
                          //添加边框
                          width: 1, //边框宽度
                          color: Color(0xFFececec), //边框颜色
                        ),
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Colors.black, //阴影颜色
                            blurRadius: 1, //阴影大小
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: ScreenUtil.getInstance().getWidthPx(20),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: model.op != null ? model.op.length : 4,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: index == 4 ? 0 : 10),
                                      child: FRadio(
                                        corner: FRadioCorner.all(30),
                                        normalColor: Color(0XFFb1dab7),
                                        width: ScreenUtil.getInstance().getWidthPx(75),
                                        height: ScreenUtil.getInstance().getWidthPx(75),
                                        value: index + 1,
                                        groupValue: model.ques.type == RoomLandscapePageState.MULSEL ? groupValueList[index] : model.val,
                                        onChanged: (value) {
                                          if (model.ques.type == RoomLandscapePageState.MULSEL) {
                                            if (groupValueList[index] == value) {
                                              groupValueList[index] = 0;
                                            } else {
                                              groupValueList[index] = value;
                                            }
                                            model.notify();
                                          } else {
                                            model.switchVal(value);
                                          }
                                        },
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xff3cc969),
                                            Color(0xff43cf70),
                                            Color(0xff3eb765),
                                            Color(0xff3daa60),
                                          ],
                                          begin: Alignment(-0.1, -0.9),
                                          end: Alignment(1.0, 1.0),
                                          stops: [0.0, 0.2, 0.7, 1.0],
                                        ),
                                        selectedColor: Color(0xff3cc969),
                                        hasSpace: false,
                                        border: 1.5,
                                        child: Text(
                                          "${(model.op != null && model.op.length == 1) ? model.op[index] : _selBtnName[index]}",
                                          style: TextStyle(color: Color(0xFF3cc969), fontSize: 16),
                                        ),
                                        hoverChild: Text(
                                          "${(model.op != null && model.op.length == 1) ? model.op[index] : _selBtnName[index]}",
                                          style: TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                        selectedChild: Text("${(model.op != null && model.op.length == 1) ? model.op[index] : _selBtnName[index]}",
                                            style: TextStyle(color: Colors.white, fontSize: 16)),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: CommonUtils.buildBtn("提交",
                                width: ScreenUtil.getInstance().getWidthPx(130), height: ScreenUtil.getInstance().getHeightPx(250), onTap: () {
                              if (model.val < 1) {
                                return;
                              }
                              var isRight = "F";
                              print("model.quesAn  ${model.quesAn} (model.val - 1) ${(model.val - 1)} ${model.quesAn == (model.val - 1)}");
                              if (model.quesAn.toString() == (model.val - 1).toString()) {
                                isRight = "T";
                              }
                              final val = model.val;
                              final op = model.op;
                              var answer =
                                  '{"answer":"${model.val - 1}","isRight":"$isRight","quesId":${model.ques.qid},"userAnswer":{"qid":${model.ques.qid},"uan":[{"an":"${model.val - 1}","r":"$isRight"}]}}';
                              var useTime = DateTime.now().difference(model.dateTime).inMilliseconds;
                              var param = {
                                "catalogId": model.ques.ctatlogid,
                                "liveCourseallotId": courseProvider.roomData.liveCourseallotId,
                                "liveEventId": 1,
                                "quesId": model.ques.qid,
                                "isRight": isRight,
                                "roomId": courseProvider.roomData.room.roomUuid
                              };
                              param["answerJson"] = answer;
                              param["useTime"] = useTime;
                              var qlibParam = {
                                "lessonId": model.ques.ctatlogid,
                                "quesId": model.ques.qid,
                                "isRight": isRight,
                                "batchNo": courseProvider.roomData.room.roomUuid,
                                "ctkDatafrommapId": 49
                              };
                              qlibParam["costTime"] = useTime;
                              qlibParam["userAnswer"] = answer;
                              RoomDao.saveQuesToQlib(qlibParam);
                              RoomDao.saveQues(param).then((res) {
                                Log.f("rewardStar  ${res.toString()}", tag: RoomLandscapePage.sName);
                                if (res.result != null && res.data != null && res.data["code"] == 200) {
                                  courseProvider.closeDialog();
                                  NavigatorUtil.showGSYDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        print("  op     $op");
                                        return LiveQuesDialog(
                                          ir: isRight,
                                          star: res.data["data"]["star"],
                                          an: "${(op != null && op.length == 1) ? op[val - 1] : _selBtnName[val - 1]}",
                                        );
                                      }).then((_) {
                                    print("LiveQuesDialog back");
                                    try {
                                      if (res.data["data"]["star"] > 0) {
                                        courseProvider.showStarDialog(res.data["data"]["star"]);
                                      }
                                    } catch (e) {
                                      print(e);
                                    }
                                  });
                                } else {
                                  showToast("提交失败请稍后重试!!!");
                                }
                              });
                              model.setIsShow(false);
                            },
                                splashColor: Colors.amber,
                                decorationColor: Color(0xFF3cc969),
                                textColor: Colors.white,
                                textSize: ScreenUtil.getInstance().getSp(8),
                                elevation: 2),
                          ),
                          SizedBox(
                            width: ScreenUtil.getInstance().getWidthPx(20),
                          ),
                        ],
                      )),
                  Stack(
                    alignment: AlignmentDirectional(0.0, 1.2),
                    children: <Widget>[
                      Container(
                          alignment: Alignment.topCenter,
                          height: ScreenUtil.getInstance().getWidthPx(40),
                          width: ScreenUtil.getInstance().getWidthPx(150),
                          child: Text("单选题"),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.all(Radius.circular(50.0)),
                            border: new Border.all(
                              //添加边框
                              width: 1, //边框宽度
                              color: Color(0xFFececec), //边框颜色
                            ),
                            boxShadow: <BoxShadow>[
                              new BoxShadow(
                                color: Colors.black, //阴影颜色
                                blurRadius: 1, //阴影大小
                              ),
                            ],
                          )),
                      Container(
                        color: Colors.white,
                        height: ScreenUtil.getInstance().getWidthPx(10),
                        width: ScreenUtil.getInstance().getWidthPx(150),
                      )
                    ],
                  ),
                ],
              ),
            )
          : Container();
    });
  }
}
