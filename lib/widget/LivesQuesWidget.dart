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
  final bool isReplay;

  const LiveQuesWidget({Key key, this.isReplay = false}) : super(key: key);
  @override
  _LiveQuesWidgetState createState() => _LiveQuesWidgetState();
}

class _LiveQuesWidgetState extends State<LiveQuesWidget> {
  String tag = "LiveQuesWidget";

  ///选择题
  var _selBtnName = ["A", "B", "C", "D", "E", "F"];

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomSelProvider>(builder: (context, model, child) {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      return model.isShow
          ? Container(
              width: courseProvider.coursewareWidth,
              height: ScreenUtil.getInstance().getWidthPx(75),
              decoration: BoxDecoration(
                color: Colors.black54,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: model.op != null ? model.op.length : 4,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: new EdgeInsets.only(right: 10),
                        child: _getOption(index, model),
                      );
                    },
                  ),
                  Container(
                    child: CommonUtils.buildBtn("确定",
                        width: ScreenUtil.getInstance().getWidthPx(89),
                        height: ScreenUtil.getInstance().getWidthPx(58),
                        onTap: () => _submit(model),
                        splashColor: Colors.amber,
                        decorationColor: Color(0xFF3cc969),
                        textColor: Colors.white,
                        textSize: ScreenUtil.getInstance().getSp(8),
                        elevation: 2),
                  ),
                ],
              ))
          : Container();
    });
  }

  _submit(RoomSelProvider model) {
    List an = List();
    List answerOp = List();
    for (int i = 0; i < model.groupValueList.length; i++) {
      if (model.groupValueList[i] > 0) {
        an.add(model.groupValueList[i] - 1);
        answerOp.add(_selBtnName[model.groupValueList[i] - 1]);
      }
    }

    if (an.length < 1) {
      return;
    }
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    var isRight = "F";
    print("model.quesAn  ${model.quesAn} an $an  ");
    final userAnswer = an.join(",");
    if (model.quesAn.join(",") == userAnswer) {
      isRight = "T";
    }
    print("isRight  $isRight");
    final op = model.op;
    var answer =
        '{"answer":"$userAnswer","isRight":"$isRight","quesId":${model.ques.qid},"userAnswer":{"qid":${model.ques.qid},"uan":[{"an":"$userAnswer","r":"$isRight"}]}}';
    var useTime = DateTime.now().difference(model.dateTime).inMilliseconds;
    var liveEventId = 1;
    if (widget.isReplay) {
      liveEventId = 5;
    }
    var param = {
      "catalogId": model.ques.ctatlogid,
      "liveCourseallotId": courseProvider.roomData.liveCourseallotId,
      "liveEventId": liveEventId,
      "quesId": model.ques.qid,
      "isRight": isRight,
      "roomId": courseProvider.roomData.room.roomUuid
    };
    param["answerJson"] = answer;
    param["useTime"] = useTime;
    var ctkDatafrommapId = 49;
    if (widget.isReplay) {
      //回放
      ctkDatafrommapId = 56;
    }
    var qlibParam = {
      "lessonId": model.ques.ctatlogid,
      "quesId": model.ques.qid,
      "isRight": isRight,
      "batchNo": courseProvider.roomData.room.roomUuid,
      "ctkDatafrommapId": ctkDatafrommapId
    };
    qlibParam["costTime"] = useTime;
    qlibParam["userAnswer"] = answer;
    RoomDao.saveQuesToQlib(qlibParam);
    RoomDao.saveQues(param).then((res) {
      Log.f("rewardStar  ${res.toString()}", tag: RoomLandscapePage.sName);
      if (res.result != null && res.data != null && res.data["code"] == 200) {
        model.addTimes();
        courseProvider.closeDialog();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              print("  op     $op");
              return ChangeNotifierProvider<CourseProvider>.value(
                  value: courseProvider,
                  child: ChangeNotifierProvider<RoomSelProvider>.value(
                      value: model,
                      child: LiveQuesDialog(
                        ir: isRight,
                        star: res.data["data"]["star"],
                        an: "${answerOp.join(",")}",
                        times: model.times,
                      )));
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
  }

  _getOption(int index, RoomSelProvider model) {
    return FRadio(
      corner: FRadioCorner.all(50),
      width: ScreenUtil.getInstance().getWidthPx(89),
      height: ScreenUtil.getInstance().getWidthPx(58),
      value: index + 1,
      groupValue: model.groupValueList[index], // model.ques.type == RoomLandscapePageState.MULSEL ? groupValueList[index] : model.val,
      onChanged: (value) {
        print("onChanged value $value");
        if (model.groupValueList[index] == value) {
          model.groupValueList[index] = 0;
        } else {
          model.groupValueList[index] = value;
        }
        if (model.ques.type == RoomLandscapePageState.SEL) {
          for (int i = 0; i < model.groupValueList.length; i++) {
            if (i != index) {
              model.groupValueList[i] = 0;
            }
          }
        }
        model.notify();
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
      border: 0,
      child: Container(
          width: ScreenUtil.getInstance().getWidthPx(89),
          height: ScreenUtil.getInstance().getWidthPx(58),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: Center(
            child: Text(
              "${(model.op != null && model.op.length == 1) ? model.op[index] : _selBtnName[index]}",
              style: TextStyle(color: Color(0xFF3cc969), fontSize: 16),
            ),
          )),
      hoverChild: Text(
        "${(model.op != null && model.op.length == 1) ? model.op[index] : _selBtnName[index]}",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      selectedChild:
          Text("${(model.op != null && model.op.length == 1) ? model.op[index] : _selBtnName[index]}", style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}
