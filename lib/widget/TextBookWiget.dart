import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:oktoast/oktoast.dart';
class TextBookWiget extends StatefulWidget {
  const TextBookWiget({
    Key key,
    @required this.textBook,
  }) : super(key: key);
  final String textBook;
  @override
  State<StatefulWidget> createState() {
    return _TextBookWiget(this.textBook);
  }
}
class _TextBookWiget extends State<TextBookWiget> {
  String _textBook;
  _TextBookWiget(
      this._textBook,
      ) : super();
  final List<String> _list= ["RJ版","BS版"];
  Widget build(BuildContext context){

    return StoreBuilder<GSYState>(builder: (context, store)
      {
      return
        Column(
        children: _getWidgetList(store),
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      );
      });
    }
    _getWidgetList(store){
      List<Widget> _widgetList = [];
      _widgetList.add(Text("请选择教程",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3)),));
      for(var i = 0;i<_list.length;i++){
        _widgetList.add(CommonUtils.buildBtn(
          _list[i],
          width:ScreenUtil.getInstance().getWidthPx(638),
          height:ScreenUtil.getInstance().getHeightPx(114),
          textColor: _textBook != _list[i]?Color(0xFFffffff):Color(0xFFa83530),
          decorationColor: _textBook != _list[i]?Color(0xFF9fa5aa):Color(0xFFfbd951),
          onTap: _textBook!=_list[i]?()async {
            CommonUtils.showLoadingDialog(context, text: "切换中···");
            var res =  await UserDao.resetTextbookId(_list[i]==_list[0]?1:2);
            Navigator.pop(context);
            setState(() {
              if(res.result){
                _textBook = _list[i];
                UserDao.getUser(isNew: true, store:store);
              }else{
                showToast("教程更换失败，请联系客服");
              }
            });
          }:null,
        ));
      }
      return _widgetList;
    }
}