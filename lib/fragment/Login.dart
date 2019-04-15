import 'package:flutter/material.dart';


class LoginWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('Hello Wolrd', style: TextStyle(fontSize: 22.0, color: Colors.white),),
        ),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: const FractionalOffset(0.5, 0.0),
          end: const FractionalOffset(0.5, 1.0),
          colors: <Color>[Colors.blue, Colors.blue],
        ),
      ),
      ),
    );
  }
}