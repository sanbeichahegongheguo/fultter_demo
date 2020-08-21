import 'package:flutter/material.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:provider/provider.dart';

class InputButtomWidget extends StatelessWidget {

  final TextEditingController controller;
  final ValueChanged<String>  onChanged;
  final ValueChanged<String> onSubmitted;
  InputButtomWidget({this.onSubmitted, this.controller, this.onChanged});

  @override

  @override
  Widget build(BuildContext context) {

    final padding = MediaQuery.of(context).padding;

    return new Scaffold(
      backgroundColor: Colors.transparent,
      body: new Column(
        children: <Widget>[
          Expanded(
              child: new GestureDetector(
                child: new Container(
                  color: Colors.transparent,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )
          ),
          new Container(
              color: Color(0xFFF4F4F4),
              padding: EdgeInsets.only(left: 16 + padding.left,top: 8,bottom: 8,right: 16),
              child:  Container(
                decoration: BoxDecoration(
                    color: Colors.white
                ),
                child: Row(children: <Widget>[
                  Flexible(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      style: TextStyle(
                          fontSize: 16
                      ),
                      //设置键盘按钮为发送
                      textInputAction: TextInputAction.send,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: (val){
                        //点击发送调用
                        Navigator.pop(context);
                        onSubmitted(val);
                      },
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: '输入内容',
                        isDense: true,
                        contentPadding: EdgeInsets.only(left: 10,top: 5,bottom: 5,right: 10),
                        border: const OutlineInputBorder(
                          gapPadding: 0,
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                 Consumer<ChatProvider>(builder: (context, model, child) {
                      return Container(
                      margin:  EdgeInsets.symmetric(horizontal: 1.0),
                      child:  IconButton(
                      icon:  Icon(Icons.send,color: model.isComposing?Colors.blueAccent:Colors.grey,),
                      onPressed: (){
                        if (model.isComposing){
                          onSubmitted(controller.text);
                          Navigator.pop(context);
                        }
                      },
                      ));
                }),
                ],),
              )
          )
        ],
      ),
    );

  }
}

//过度路由
class PopRoute extends PopupRoute{
  final Duration _duration = Duration(milliseconds: 300);
  Widget child;

  PopRoute({@required this.child});

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Duration get transitionDuration => _duration;

}
